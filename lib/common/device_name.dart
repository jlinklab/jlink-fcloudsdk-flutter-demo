import 'package:flutter/material.dart';
import 'package:fcloudsdk_example/common/match.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:intl/intl.dart';

///设备名称输入提示文案
String deviceNameHintText() {
  final String localeName =
      Intl.defaultLocale ?? Intl.systemLocale.toString().split('_').first;
  if (localeName.startsWith('zh')) {
    return '设备名称长度为2-20位';
  }
  return '设备名称长度为2-32位';
}

///校验设备名称
///空、长度不通过时给出对应提示，[showError] 为 false 时只返回结果不提示
Future<bool> checkDeviceNameVaild(String name, BuildContext context,
    {bool showError = true}) async {
  if (showError) {
    KToast.show();
  }

  ///不允许输入为 ‘ ’
  if (name.trim().isEmpty) {
    if (showError) {
      KToast.show(status: '设备名不能为空');
    }
    return false;
  }

  ///长度校验：含中文 2-20 个字符；不含中文 2-32 个字符
  final bool containsChinese = JFMatch.containsChinese(name);
  final int maxLength = containsChinese ? 20 : 32;
  if (name.length < 2 || name.length > maxLength) {
    if (showError) {
      KToast.show(status: containsChinese ? '设备名称长度为2-20位' : '设备名称长度为2-32位');
    }
    return false;
  }

  if (showError) {
    KToast.dismiss();
  }
  return true;
}
