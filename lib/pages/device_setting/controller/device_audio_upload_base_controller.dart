import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/api/mobile_systeminfo/MobileSystemInfo_api.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/common/common_path.dart';
import 'package:xcloudsdk_flutter_example/utils/permission_utils.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

import '../../../../generated/l10n.dart';

abstract class DeviceAudioUploadBaseController with ChangeNotifier {
  final BuildContext context;
  final String deviceId;

  int channel = 0;

  //是否需要展示tts功能
  bool isShowTTs = false;

  ///是否是文字转语音
  bool _isTTS = false;

  bool get isTTS => isShowTTs ? _isTTS : false;

  set setIsTTS(bool value) {
    _isTTS = value;

    //切换tab重置状态
    recordTime = _recordAudioLength;

    notifyListeners();

    /// 结束正在试听
    if (_onAudition) {
      audioPlayer.release();
    }

    /// 结束正在录音
    if (isRecording) {
      onEndRecord(forceEnd: true);
    }

    ///兜底
    if (recorderTimer != null) {
      recorderTimer!.cancel();
      recorderTimer = null;
    }
  }

  /// 是否支持呼唤音
  bool callVoiceAbility = false;

  int get recordFileTimeLenth => callVoiceAbility ? 10 : 3;

  ///0: 男， 1女， -1默认不选
  int _sexType = -1;

  int get sexType => _sexType;

  set setSexType(int value) {
    _sexType = value;
    notifyListeners();
  }

  int recordTime = 0;
  Timer? recorderTimer;

  /// 音频播放器
  final AudioPlayer audioPlayer = AudioPlayer();

  /// 音频录制对象
  final mRecorder = AudioRecorder();

  bool _onAudition = false;

  bool permissionMicrophone = false;

  ValueNotifier<bool> isCanSubmitByRecord = ValueNotifier(false);

  ValueNotifier<bool> get isCanSubmitByTransform {
    if (sexType != -1 && ttsVoiceText.value.isNotEmpty) {
      return ValueNotifier(true);
    }
    return ValueNotifier(false);
  }

  ValueNotifier<String> ttsVoiceText = ValueNotifier('');

  String get audioFilePath =>
      isTTS ? _audioFilePathByTransform : _audioFilePathByRecord;

  String _audioFilePathByRecord = '';
  String _audioFilePathByTransform = '';

  bool isRecording = false;

  String textFeildHintText = '';

  //缓存语音录制时长
  int _recordAudioLength = 0;

  DeviceAudioUploadBaseController(
      {required this.context, required this.deviceId}) {
    _initTTS();

    deleteDirectoryFiles();

    audioPlayer.onPlayerStateChanged.listen((event) {
      switch (event) {
        case PlayerState.stopped:
          recorderTimer?.cancel();
          recorderTimer = null;
          _onAudition = false;

          notifyListeners();
          break;
        case PlayerState.playing:
          _onAudition = true;
          break;
        case PlayerState.paused:
          _onAudition = true;
          break;
        case PlayerState.completed:
          //试听结束，更新试听文件的时长
          if (!isTTS) {
            recordTime = _recordAudioLength;
          }

          recorderTimer?.cancel();
          recorderTimer = null;
          _onAudition = false;

          notifyListeners();
          break;
        case PlayerState.disposed:
          break;
      }
    });
  }

  ///上传
  onSubmit() async {
    if (isTTS) {
      if (ttsVoiceText.value.isNotEmpty &&
          (ttsVoiceText.value != _lastSucText)) {
        //提交前，检查是否需要重新生成语音文件
        debugPrint('txt has changed, regenerate voice');
        await onGenVoice();
      }
    }

    if (audioFilePath.isEmpty || !File(audioFilePath).existsSync()) {
      return;
    }
    int fileSize = fileSizeAtPath(audioFilePath);
    if (kDebugMode) {
      debugPrint('audio_fileSize:$fileSize');
    }
    Map rMap = {
      'Name': 'OPFile',
      'OPFile': {
        'FileType': 1,
        'Channel': [channel],
        'FilePurpose': 0,
        'FileSize': fileSize ~/ 2,
        'FileName': 'customAlarmVoice.pcm', //写死的这个不能修改，并不是自定义
        'Parameter': {
          'BitRate': 128000,
          'SampleRate': 8000,
          'SampleBit': 8,
          'EncodeType': 'G711_ALAW',
        },
      },
    };

    final String requestJsStr = jsonEncode(rMap);
    KToast.show();
    try {
      await JFApi.xcDevice.xcStartSendFileToDevice(
          deviceId: deviceId,
          paramJsStr: requestJsStr,
          filePath: audioFilePath,
          timeout: 10000);

      KToast.show(status: TR.current.Upload_S);
      await Future.delayed(const Duration(milliseconds: 800));
      if (context.mounted) {
        context.pop(true);
      }
    } catch (error) {
      KToast.show(status: KErrorMsg(error));
    } finally {
      _lastSucText = null;
    }
  }

  /// 读取文件大小
  int fileSizeAtPath(String filePath) {
    final file = File(filePath);
    if (file.existsSync()) {
      return file.lengthSync();
    }
    return 0;
  }

  void deleteDirectoryFiles() async {
    final voiceDirectory =
        await kGenLocalDirectoryPath(dirName: 'alarm_bell_voice');
    final directory = Directory(voiceDirectory);
    if (directory.existsSync()) {
      // 获取目录下的所有文件和子目录
      directory.listSync().forEach((fileSystemEntity) {
        if (fileSystemEntity is File) {
          fileSystemEntity.deleteSync(); // 删除文件
        }
      });
    }
  }

  Future<String> generateRandomVoiceFilePath(
      int length, String hasExistFilePath,
      {bool record = false}) async {
    final voiceDirectory =
        await kGenLocalDirectoryPath(dirName: 'alarm_bell_voice');
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    String randomStr = String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
    final filePath =
        '$voiceDirectory/$randomStr${record ? 'record' : 'transform'}transform.wav';
    if (filePath == hasExistFilePath) {
      return generateRandomVoiceFilePath(length, hasExistFilePath,
          record: record);
    }
    return filePath;
  }

  String onConvertRecordTimeStr() {
    final minutes = recordTime ~/ 60;
    final seconds = recordTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  checkMicPhonePermission() async {
    try {
      KToast.show();

      permissionMicrophone = await PermissionUtils.checkPermission(
          permission: XPermission.microphone);
      KToast.dismiss();
    } catch (e) {
      KToast.dismiss();
    }
    return;
  }

  /// 只有中文下支持tts
  _initTTS() async {
    String deviceLanguage =
        await MobileSystemAPI.instance.xcLocalePreferredLanguage();
    isShowTTs = deviceLanguage.toLowerCase().startsWith('zh');
    notifyListeners();
  }

  onStartRecord() async {
    /// 正在试听，结束试听
    if (_onAudition) {
      audioPlayer.stop();
    }

    // if (isRecording || await mRecorder.isRecording()) {
    //   return;
    // }

    if (isRecording) {
      return;
    }

    ///先判断权限
    if (permissionMicrophone == false) {
      await checkMicPhonePermission();
      if (permissionMicrophone == false) {
        KToast.show(status: TR.current.audio_ability_unsupport);
      } else {
        onStartRecord();
      }
      return;
    }

    File tempFile = File(_audioFilePathByRecord);

    ///如果存在，先删了
    if (await tempFile.exists()) {
      await tempFile.delete();
      _audioFilePathByRecord = '';
      isCanSubmitByRecord.value = false;
    }
    _audioFilePathByRecord = await generateRandomVoiceFilePath(
        6, _audioFilePathByRecord,
        record: true);
    try {
      //延时，不然试听时点击录音，会无法录音
      await Future.delayed(const Duration(milliseconds: 200));
      //用户允许运用麦克风之后开端录音
      await mRecorder.start(
          const RecordConfig(
              encoder: AudioEncoder.wav,
              bitRate: 128000,
              sampleRate: 8000,
              numChannels: 1),
          path: _audioFilePathByRecord);
      isRecording = true;
      recordTime = 0;
      recorderTimer?.cancel();
      recorderTimer =
          Timer.periodic(const Duration(seconds: 1), (Timer t) async {
        recordTime++;
        notifyListeners();
        if (recordTime >= recordFileTimeLenth) {
          ///大于规定时间内秒自动暂停
          await onEndRecord();
        }
      });
    } catch (e) {
      //
    }
    notifyListeners();
  }

  onEndRecord({bool forceEnd = false}) async {
    if (recordTime < 1 && forceEnd == false) {
      KToast.show(status: TR.current.Recording_Times_Not_DURATION);
      return Future(() => null);
    }

    if (recorderTimer != null) {
      recorderTimer!.cancel();
      recorderTimer = null;
    }

    if (isRecording) {
      //防止重复调用（用户在临结束时点击，此时有可能因为时序问题，导致多次调用）
      isRecording = false;
      try {
        final tempVoiceFilePath = await mRecorder.stop();
        if (tempVoiceFilePath != null) {
          isCanSubmitByRecord.value = true;

          ///语音录制结束，标记语音时长（最多：[recordFileTimeLenth]）
          _recordAudioLength = recordTime;
        }
      } catch (e) {
        //
      }
    }

    notifyListeners();
  }

  onAudition() {
    if (_onAudition) {
      return;
    }

    if (audioFilePath.isEmpty) {
      return;
    }

    if (isTTS == false) {
      recordTime = _recordAudioLength;
      recorderTimer?.cancel();
      recorderTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        recordTime--;
        if (recordTime <= 0) {
          recordTime = 0;
        }

        notifyListeners();
      });
    }

    audioPlayer.play(DeviceFileSource(audioFilePath));
    _onAudition = true;
  }

  String? _lastSucText;

  ///文字转语音
  onGenVoice() async {
    if (ttsVoiceText.value.isEmpty) {
      return;
    }
    KToast.show();
    String voice = sexType == 1 ? 'female' : 'male';
    String urlString = 'https://tts.xmcsrv.net/tts';
    var request = http.Request('POST', Uri.parse(urlString));
    request.body = '{"text":"${ttsVoiceText.value}","voice":"$voice"}';
    request.headers['Content-Type'] = 'application/json';

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      KToast.show(status: TR.current.operator_failed);
      return;
    }

    File tempFile = File(_audioFilePathByTransform);

    ///如果存在，先删了
    if (await tempFile.exists()) {
      await tempFile.delete();
      _audioFilePathByTransform = '';
      // isCanSubmitByTransform.value = false;
      // notifyListeners();
    }
    final filePath = await generateRandomVoiceFilePath(
        6, _audioFilePathByTransform,
        record: false);
    File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes, flush: true);
    int fileSize = await file.length();
    bool fileSizeTooLarge = false;
    if (fileSize >= 84 * 1024) {
      if (fileSize > 84 * 1024) {
        fileSizeTooLarge = true;
      }
      var bytes = await file.readAsBytes();
      await file.writeAsBytes(bytes.sublist(0, 84 * 1024));
    } else {
      if (fileSize % 32 != 0) {
        fileSize = fileSize - fileSize % 32;
        var bytes = await file.readAsBytes();
        await file.writeAsBytes(bytes.sublist(0, fileSize));
      }
    }

    if (fileSizeTooLarge) {
      KToast.show(status: TR.current.TR_File_Size_Exceed_Max_Size);
      _audioFilePathByTransform = '';
      isCanSubmitByTransform.value = false;
      notifyListeners();
      return;
    }

    if (await file.exists()) {
      KToast.dismiss();
      _audioFilePathByTransform = file.path;
      isCanSubmitByTransform.value = true;
      _lastSucText = ttsVoiceText.value;
      notifyListeners();
    } else {
      _audioFilePathByTransform = '';
      isCanSubmitByTransform.value = false;
      notifyListeners();
      KToast.show(status: TR.current.operator_failed);
    }
  }

  ///获取文件列表
  Future<void> getDeviceFileList() async {
    try {
      var command = {'Action': 'ListFiles', 'Path': '/mnt/mtd/NetFile'};

      String commendJson = jsonEncode(command);

      final result = await JFApi.xcDevice.xcDevSetSysConfigWithPData(
          deviceId: deviceId,
          command: 3500,
          commandName: 'OPFile',
          config: commendJson,
          configLen: commendJson.length,
          timeout: 15000);
      debugPrint(result.toString());
    } catch (e) {
      KToast.show(status: KErrorMsg(e));
    }
  }

  ///删除指定文件
  void deleteDeviceFileAction() async {
    var command = {'Action': 'Remove', 'FileName': 'customAlarmVoice.pcm'};
    String commendJson = jsonEncode(command);
    try {
      await JFApi.xcDevice.xcDevSetSysConfig(
          deviceId: deviceId,
          commandName: 'OPFile',
          config: commendJson,
          configLen: commendJson.length,
          command: 3500,
          timeout: 1500);
      KToast.show(status: '删除成功');

      deleteDirectoryFiles();
    } catch (e) {
      KToast.show(status: KErrorMsg(e));
    }
  }

  @override
  void dispose() {
    recorderTimer?.cancel();
    recorderTimer ??= null;

    audioPlayer.release();

    if (isRecording) {
      onEndRecord(forceEnd: true);
    }

    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!hasListeners) {
      return;
    }

    if (!context.mounted) {
      return;
    }
    super.notifyListeners();
  }
}
