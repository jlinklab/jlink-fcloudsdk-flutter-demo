import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:screenshot/screenshot.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/manager/device_config_manager.dart';
import 'package:fcloudsdk/utils/extensions.dart';
import 'package:fcloudsdk_example/utils/text_width_util.dart';

class JpegChnTitleHelper {
  static final JpegChnTitleHelper instance = JpegChnTitleHelper._();
  static const FontWeight _watermarkFontWeight = FontWeight.w400;
  static const double _legacyLatticeFontSize = 14.5;
  static const double _legacyOutlineOpacity = 0.55;

  JpegChnTitleHelper._();

  /// 新图片水印流程入口：
  /// 查询水印字符参数（ChnTitleOSDCharParam，command 1360），
  /// 根据参数渲染主/辅码流通道标题 JPG 图片下发到设备（JpegChnTitleOSD，command 1046）
  Future<void> getJpegChnTitle(String deviceId, String editName) async {
    final res = await DeviceConfigManager.getConfigToObject<Map<String, dynamic>>(
      deviceId: deviceId,
      commandName: DeviceJsonName.chnTitleOSDCharParam,
      command: 1360,
      throwError: true,
    );
    await jpegChnTitleOSD(deviceId, res, editName);
  }

  /// 图片水印处理：
  /// 渲染水印文字为主/辅码流 JPG 并下发，成功后修改通道标题
  Future<void> jpegChnTitleOSD(
      String deviceId, Map jpegMap, String editName) async {
    if (jpegMap.isEmpty) {
      return;
    }
    double mainStreamHeight = (jpegMap['MainStreamHeight'] as num).toDouble();
    double subStreamHeight = (jpegMap['SubStreamHeight'] as num).toDouble();
    Color textColor = _intToColor(jpegMap['TextColor']);
    Color bgColor = _intToColor(jpegMap['BackColor']);
    final screenshotController = ScreenshotController();

    // 主码流通道标题
    double mainFontSize = TextWidthUtil.getMaxFontSize(
        text: editName, containerHeight: mainStreamHeight);
    double mainWidth = TextWidthUtil.calculateContainerWidth(
        text: editName, fontSize: mainFontSize);
    final adjustedMainWidth = _adjustToMultipleOf8(mainWidth);
    final Widget mainScreenWidget = Container(
      height: mainStreamHeight,
      color: bgColor,
      child: Center(
          child: Text(editName,
              style: TextStyle(
                  fontSize: mainFontSize,
                  color: textColor,
                  fontWeight: _watermarkFontWeight))),
    );

    // 辅码流通道标题
    double subFontSize = TextWidthUtil.getMaxFontSize(
        text: editName,
        containerHeight: subStreamHeight,
        fontWeight: _watermarkFontWeight);
    double subWidth = TextWidthUtil.calculateContainerWidth(
        text: editName,
        fontSize: subFontSize,
        fontWeight: _watermarkFontWeight);
    final adjustedSubWidth = _adjustToMultipleOf8(subWidth);
    final Widget subScreenWidget = Container(
      height: subStreamHeight,
      color: bgColor,
      child: Center(
          child: Text(editName,
              style: TextStyle(
                  fontSize: subFontSize,
                  color: textColor,
                  fontWeight: _watermarkFontWeight))),
    );

    // 主码流base64
    Uint8List mainImageBytes = await screenshotController.captureFromWidget(
      mainScreenWidget,
      targetSize: Size(adjustedMainWidth, mainStreamHeight),
    );
    String mainBase64String = '';
    Uint8List? jpgMainBytes =
        convertPngToJpgWithLibrary(mainImageBytes, quality: 80);
    if (jpgMainBytes != null) {
      mainBase64String = base64Encode(jpgMainBytes);
    }

    // 辅码流base64
    Uint8List subImageBytes = await screenshotController.captureFromWidget(
      subScreenWidget,
      targetSize: Size(adjustedSubWidth, subStreamHeight),
    );
    String subBase64String = '';
    Uint8List? jpgSubBytes =
        convertPngToJpgWithLibrary(subImageBytes, quality: 80);
    if (jpgSubBytes != null) {
      subBase64String = base64Encode(jpgSubBytes);
    }

    if (mainBase64String.isEmpty || subBase64String.isEmpty) {
      throw XCloudAPIException(
          code: -1, commandId: 1046, message: 'jpeg base64 empty');
    }

    Map map = {
      'Channel': 0,
      'MainStreamJpegBase64': mainBase64String,
      'SubStreamJpegBase64': subBase64String
    };
    await DeviceConfigManager.setConfig(
      deviceId: deviceId,
      command: 1046,
      commandName: DeviceJsonName.jpegChnTitleOSD,
      config: jsonEncode(map),
    );

    /// 下发图片成功后再修改通道标题
    await changeDeviceChannelTitle(editName, deviceId);
  }

  /// 修改通道标题：
  /// 图片水印流程会先下发给设备图片水印，成功后再修改通道标题
  Future<void> changeDeviceChannelTitle(String editName, String deviceId) async {
    var videoWidget = await DeviceConfigManager.getConfigToObject<
            List<Map<String, dynamic>>>(
        deviceId: deviceId, commandName: DeviceJsonName.aVEncVideoWidget);
    Map<String, dynamic>? chanelTitle =
        videoWidget.firstWhereOrNull((e) => e.containsKey('ChannelTitle'));
    if (chanelTitle != null && chanelTitle['ChannelTitle'] != null) {
      chanelTitle['ChannelTitle']['Name'] = editName;
    }
    Map<String, dynamic>? chanelTitleAttr = videoWidget
        .firstWhereOrNull((e) => e.containsKey('ChannelTitleAttribute'));
    if (chanelTitleAttr != null &&
        chanelTitleAttr['ChannelTitleAttribute'] != null) {
      chanelTitleAttr['ChannelTitleAttribute']['EncodeBlend'] = true;
      chanelTitleAttr['ChannelTitleAttribute']['PreviewBlend'] = true;
    }
    await DeviceConfigManager.setConfig(
        deviceId: deviceId,
        commandName: DeviceJsonName.aVEncVideoWidget,
        config: jsonEncode(videoWidget));
  }

  /// 数字转Color（等价 JFConvert.decimalToColor/numberToColor）
  Color _intToColor(dynamic value) {
    final int num = value is int ? value : int.tryParse('$value') ?? 0;
    return Color(0xFF000000 | num);
  }

  /// 调整到最接近的 8 的倍数
  double _adjustToMultipleOf8(double width) {
    double ceilValue = ((width + 7) / 8).floor() * 8;
    double floorValue = (width / 8).floor() * 8;

    if ((ceilValue - width).abs() < (width - floorValue).abs()) {
      return ceilValue;
    }
    return floorValue;
  }

  Future<String> buildLegacyWatermarkMark(
      {required String deviceId, required String editName}) async {
    try {
      const int latticeHeight = 24;
      const int renderScale = 4;
      const double latticeFontSize = _legacyLatticeFontSize;
      final screenshotController = ScreenshotController();

      final rawWidth = TextWidthUtil.calculateContainerWidth(
          text: editName, fontSize: latticeFontSize);
      final targetWidth = _ceilToMultipleOf8(rawWidth).clamp(8, 2048).toInt();
      final renderWidth = targetWidth * renderScale;
      const renderHeight = latticeHeight * renderScale;
      const outlineOffset = renderScale >= 4 ? 2.0 : 1.0;
      final outlineColor =
          Colors.black.withValues(alpha: _legacyOutlineOpacity);

      final Widget latticeWidget = Container(
        width: renderWidth.toDouble(),
        height: renderHeight.toDouble(),
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: renderScale.toDouble()),
          child: Text(editName,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: latticeFontSize * renderScale,
                color: Colors.white,
                fontWeight: _watermarkFontWeight,
                height: 1.0,
                shadows: _buildOutlineShadows(outlineOffset, outlineColor),
              )),
        ),
      );
      final pngBytes = await screenshotController.captureFromWidget(
        latticeWidget,
        targetSize: Size(renderWidth.toDouble(), renderHeight.toDouble()),
      );

      final latticeBytes = _buildLatticeBytesFromPng(
          pngBytes: pngBytes,
          width: targetWidth,
          height: latticeHeight,
          renderScale: renderScale);
      if (latticeBytes == null) {
        return editName;
      }
      final hexData = _bytesToHex(latticeBytes);
      final encodedMark =
          '__XC_LATTICE_V1__|$targetWidth|$latticeHeight|$hexData';

      return encodedMark;
    } catch (e) {
      return editName;
    }
  }

  double _ceilToMultipleOf8(double width) {
    final normalized = width <= 0 ? 8 : width.ceilToDouble();
    return ((normalized + 7) ~/ 8) * 8.0;
  }

  Uint8List? _buildLatticeBytesFromPng(
      {required Uint8List pngBytes,
      required int width,
      required int height,
      required int renderScale,
      int darkThreshold = 160,
      int avgThreshold = 220,
      int alphaThreshold = 110,
      int avgAlphaThreshold = 88}) {
    final image = img.decodeImage(pngBytes);
    final requiredWidth = width * renderScale;
    final requiredHeight = height * renderScale;
    if (image == null ||
        image.width < requiredWidth ||
        image.height < requiredHeight) {
      return null;
    }

    final bytes = Uint8List((width * height) ~/ 8);
    int bitIndex = 0;
    int byteIndex = 0;
    int darkPixelCount = 0;
    final blockArea = renderScale * renderScale;
    final minDarkCount =
        ((blockArea * 0.25).floor()).clamp(2, blockArea).toInt();
    final minAlphaCount =
        ((blockArea * 0.2).floor()).clamp(2, blockArea).toInt();
    final isTransparentMode = _isTransparentCapture(
        image, requiredWidth, requiredHeight,
        alphaTransparentThreshold: 8);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int darkCount = 0;
        int brightnessSum = 0;
        int alphaCount = 0;
        int alphaSum = 0;

        final blockStartX = x * renderScale;
        final blockStartY = y * renderScale;
        for (int yy = 0; yy < renderScale; yy++) {
          for (int xx = 0; xx < renderScale; xx++) {
            final pixel = image.getPixel(blockStartX + xx, blockStartY + yy);
            final brightness = ((pixel.r + pixel.g + pixel.b) / 3).round();
            final alpha = pixel.a.toInt();
            brightnessSum += brightness;
            alphaSum += alpha;
            if (brightness <= darkThreshold) {
              darkCount++;
            }
            if (alpha >= alphaThreshold) {
              alphaCount++;
            }
          }
        }

        final avgBrightness = brightnessSum / blockArea;
        final avgAlpha = alphaSum / blockArea;
        final shouldSet = isTransparentMode
            ? (alphaCount >= minAlphaCount || avgAlpha >= avgAlphaThreshold)
            : (darkCount >= minDarkCount || avgBrightness <= avgThreshold);
        if (shouldSet) {
          bytes[byteIndex] |= (1 << (7 - bitIndex));
          darkPixelCount++;
        }
        bitIndex++;
        if (bitIndex == 8) {
          bitIndex = 0;
          byteIndex++;
        }
      }
    }

    if (darkPixelCount <= 0) {
      return null;
    }
    return bytes;
  }

  bool _isTransparentCapture(img.Image image, int width, int height,
      {int alphaTransparentThreshold = 8}) {
    final points = <List<int>>[
      [0, 0],
      [width - 1, 0],
      [0, height - 1],
      [width - 1, height - 1]
    ];
    int alphaSum = 0;
    for (final p in points) {
      final pixel = image.getPixel(p[0], p[1]);
      alphaSum += pixel.a.toInt();
    }
    final avgAlpha = alphaSum / points.length;
    return avgAlpha <= alphaTransparentThreshold;
  }

  String _bytesToHex(Uint8List data) {
    final buffer = StringBuffer();
    for (final b in data) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  List<Shadow> _buildOutlineShadows(double outlineOffset, Color outlineColor) {
    return [
      Shadow(
          color: outlineColor,
          offset: Offset(-outlineOffset, 0),
          blurRadius: 0),
      Shadow(
          color: outlineColor, offset: Offset(outlineOffset, 0), blurRadius: 0),
      Shadow(
          color: outlineColor,
          offset: Offset(0, -outlineOffset),
          blurRadius: 0),
      Shadow(
          color: outlineColor, offset: Offset(0, outlineOffset), blurRadius: 0),
    ];
  }

  Uint8List? convertPngToJpgWithLibrary(Uint8List pngBytes,
      {int quality = 85}) {
    // 解码 PNG
    img.Image? image = img.decodeImage(pngBytes);
    if (image == null) return null;

    // 编码为 JPEG
    Uint8List jpgBytes =
        Uint8List.fromList(img.encodeJpg(image, quality: quality));
    return jpgBytes;
  }
}
