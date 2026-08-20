import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:screenshot/screenshot.dart';
import 'package:fcloudsdk_example/utils/text_width_util.dart';

class JpegChnTitleHelper {
  static final JpegChnTitleHelper instance = JpegChnTitleHelper._();
  static const FontWeight _watermarkFontWeight = FontWeight.w400;
  static const double _legacyLatticeFontSize = 14.5;
  static const double _legacyOutlineOpacity = 0.55;

  JpegChnTitleHelper._();

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
