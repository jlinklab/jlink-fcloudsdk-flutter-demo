import 'dart:io';
import 'dart:typed_data';

import 'package:fcloudsdk/api/api_center.dart';
import 'package:flutter/services.dart';

/// 鸿蒙自定义报警音录制辅助。
///
/// `record_ohos` 当前把 `AudioEncoder.wav` 实际录成了 AAC 容器，不适合直接上传给设备。
/// 这里单独通过宿主通道录制原始 PCM，并在 Flutter 侧包装成标准 WAV 供本地试听。
class OhosAlarmAudioRecord {
  OhosAlarmAudioRecord._();

  static const MethodChannel _channel =
      MethodChannel('com.lib.flyCam.ohos.alarm_audio_record');

  static const int _maxDeviceAudioSize = 84 * 1024;
  static const int _deviceAudioAlignSize = 32;

  /// 录制参数与原生保持一致：8k、单声道、16bit PCM。
  static const int sampleRate = 8000;
  static const int channelCount = 1;
  static const int bitsPerSample = 16;

  /// 根据试听 WAV 路径推导同目录下的 PCM 文件路径。
  static String buildRawPcmPath(String wavFilePath) {
    if (wavFilePath.endsWith('.wav')) {
      return '${wavFilePath.substring(0, wavFilePath.length - 4)}.pcm';
    }
    return '$wavFilePath.pcm';
  }

  /// 开始录制原始 PCM。
  static Future<bool> startRecord({required String pcmFilePath}) async {
    bool started = await JFApi.ohosApi.startPcmRecord(pcmFilePath);
    return started == true;
  }

  /// 结束录制并返回实际生成的 PCM 路径。
  static Future<String> stopRecord() async {
    final String path = await JFApi.ohosApi.stopPcmRecord();
    return path;
  }

  /// 取消当前录制并删除原始 PCM 临时文件。
  static Future<void> cancelRecord() async {
    await JFApi.ohosApi.cancelPcmRecord();
  }

  /// 规范化 PCM 文件大小，和现有上传逻辑保持一致：
  /// 1. 最大不超过 84KB；
  /// 2. 文件长度按 32 字节对齐。
  static Future<void> normalizePcmFile(String pcmFilePath) async {
    final File pcmFile = File(pcmFilePath);
    if (!await pcmFile.exists()) {
      return;
    }

    Uint8List bytes = await pcmFile.readAsBytes();
    if (bytes.isEmpty) {
      return;
    }

    int targetLength = bytes.length;
    if (targetLength > _maxDeviceAudioSize) {
      targetLength = _maxDeviceAudioSize;
    }
    if (targetLength % _deviceAudioAlignSize != 0) {
      targetLength = targetLength - targetLength % _deviceAudioAlignSize;
    }

    if (targetLength <= 0) {
      await pcmFile.writeAsBytes(const <int>[], flush: true);
      return;
    }

    if (targetLength != bytes.length) {
      bytes = Uint8List.fromList(bytes.sublist(0, targetLength));
      await pcmFile.writeAsBytes(bytes, flush: true);
    }
  }

  /// 使用 PCM 数据生成标准 WAV 文件，供页面本地试听。
  static Future<void> buildWavFileFromPcm({
    required String pcmFilePath,
    required String wavFilePath,
  }) async {
    final File pcmFile = File(pcmFilePath);
    if (!await pcmFile.exists()) {
      throw const FileSystemException('pcm file not found');
    }

    final Uint8List pcmBytes = await pcmFile.readAsBytes();
    final Uint8List wavHeader = _buildWavHeader(pcmBytes.length);
    final File wavFile = File(wavFilePath);
    await wavFile.parent.create(recursive: true);

    final BytesBuilder bytesBuilder = BytesBuilder(copy: false)
      ..add(wavHeader)
      ..add(pcmBytes);
    await wavFile.writeAsBytes(bytesBuilder.takeBytes(), flush: true);
  }

  static Uint8List _buildWavHeader(int pcmDataLength) {
    final ByteData header = ByteData(44);
    const int byteRate = sampleRate * channelCount * bitsPerSample ~/ 8;
    const int blockAlign = channelCount * bitsPerSample ~/ 8;
    final int riffChunkSize = 36 + pcmDataLength;

    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, riffChunkSize, Endian.little);
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6d); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // space
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, channelCount, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, pcmDataLength, Endian.little);
    return header.buffer.asUint8List();
  }
}
