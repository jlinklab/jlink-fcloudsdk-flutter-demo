import 'dart:math';

import 'package:flutter/material.dart';

class TextWidthUtil {
  /// 计算文本实际渲染宽度
  static double calculateTextWidth({
    required String text,
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    String fontFamily = '',
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }

  /// 根据文本和边距计算容器宽度
  static double calculateContainerWidth({
    required String text,
    required double fontSize,
    double horizontalPadding = 8,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    double textWidth = calculateTextWidth(
        text: text, fontSize: fontSize, fontWeight: fontWeight);
    return textWidth + horizontalPadding;
  }

  /// 调整为 8 的倍数
  static int adjustToMultipleOf8(double width, {bool roundUp = true}) {
    if (roundUp) {
      return ((width + 7) / 8).floor() * 8;
    } else {
      return (width / 8).round() * 8;
    }
  }

  /// 一步到位：获取最终的 targetWidth
  static int getTargetWidth({
    required String text,
    required double fontSize,
    double horizontalPadding = 32,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    double containerWidth = calculateContainerWidth(
      text: text,
      fontSize: fontSize,
      horizontalPadding: horizontalPadding,
      fontWeight: fontWeight,
    );
    return adjustToMultipleOf8(containerWidth, roundUp: true);
  }

  /// 根据高度获取最大字号
  static double getMaxFontSize({
    required String text,
    required double containerHeight,
    double maxFontSize = 100,
    double minFontSize = 8,
    int maxLines = 1,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    double result = minFontSize;

    for (double fontSize = maxFontSize; fontSize >= minFontSize; fontSize--) {
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
      )..layout();

      if (painter.height <= containerHeight) {
        result = fontSize;
        break;
      }
    }

    return result;
  }

  static double calculateTwoTextHeight(
      String text1, String text2, double maxWidth, double maxHeight,
      {TextStyle style = const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      )}) {
    // 计算第一个文本的高度
    final textPainter1 = TextPainter(
      text: TextSpan(text: text1, style: style),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    // 计算第二个文本的高度
    final textPainter2 = TextPainter(
      text: TextSpan(text: text2, style: style),
      maxLines: 5,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    // 返回总高度
    return min(
        maxHeight,
        (text1.isNotEmpty ? textPainter1.height : 0) +
            (text2.isNotEmpty ? textPainter2.height : 0));
  }
}
