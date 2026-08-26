import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_ability/device_ability_manager.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

class DeviceImageSettingController extends ChangeNotifier {
  final String deviceId;
  final int channel;

  /// Page在build时设置，用于在用户交互时获取安全的context
  BuildContext? _pageContext;

  /// 获取安全的BuildContext，仅在widget已挂载时返回
  BuildContext get pageContextSafe {
    assert(_pageContext != null,
        'Page context not set. Call updatePageContext in build().');
    final ctx = _pageContext;
    if (ctx != null && ctx.mounted) {
      return ctx;
    }
    throw FlutterError('Page context is not mounted. Cannot show dialog.');
  }

  /// 供Page在build中调用，更新当前context引用
  void updatePageContext(BuildContext ctx) {
    _pageContext = ctx;
  }

  List<Widget> dataSource = [];

  // 状态字段
  int aeSensitivity = 3; // 1-6, 默认一般
  bool pictureFlip = false; // 上下翻转
  bool pictureMirror = false; // 左右翻转
  bool blcMode = false; // 背光补偿
  int dayNightColor = 0; // 日夜模式

  // 能力集
  bool supportSoftPhotosensitive = false; // 是否支持软光敏（决定日夜模式3档或5档）
  bool supportBT = false; // 是否支持宽动态（决定宽动态入口是否显示）
  bool supportJpegChnTitleOSD = false; // 是否支持图片水印（决定水印入口是否显示）
  bool _supportHidePictureFlip = false; // 是否隐藏上下翻转
  bool _supportHidePictureMirror = false; // 是否隐藏左右翻转

  bool get supportVerticalPictureFlip => !_supportHidePictureFlip;
  bool get supportHorizontalPictureFlip => !_supportHidePictureMirror;

  // 原始数据
  Map<String, dynamic> _mapCameraParam = {};

  /// 最近一次保存失败的错误信息
  String? _saveErrorMsg;

  DeviceImageSettingController(
    this.deviceId,
    this.channel,
  ) {
    _init();
  }

  void _init() {
    _queryAllConfig();
  }

  // ==================== 初始化查询 ====================

  void _queryAllConfig() async {
    await _queryAbilities();
    await _queryCameraParam();
  }

  /// 查询设备能力
  Future<void> _queryAbilities() async {
    // 查询翻转能力
    _supportHidePictureFlip = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportHidePictureFlip);
    _supportHidePictureMirror = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportHidePictureMirror);

    // 查询SupportSoftPhotosensitive和SupportBT（直接从能力集缓存中获取）
    final abilityMap =
        DeviceAbilityManager.instance.allDataAbilityMap[deviceId];
    if (abilityMap != null && abilityMap['OtherFunction'] != null) {
      final otherFunction = abilityMap['OtherFunction'];
      supportSoftPhotosensitive =
          otherFunction['SupportSoftPhotosensitive'] == true;
      supportBT = otherFunction['SupportBT'] == true;
    }

    // 查询图片水印能力（先查缓存，无缓存则实时更新）
    supportJpegChnTitleOSD = await DeviceAbilityManager.getAbilityEnableIfNeed(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionJpegChnTitleOSD);
    notifyListeners();
  }

  /// 获取Camera.Param配置
  Future<void> _queryCameraParam() async {
    try {
      const command = 'Camera.Param';
      final resultMap = await JFApi.xcDevice.xcDevGetChnConfig(
        deviceId: deviceId,
        channelNo: channel,
        commandName: command,
        command: 1042,
        timeout: 15000,
      );
      if (resultMap['Ret'] != null && resultMap['Ret'] == 100) {
        _mapCameraParam =
            Map<String, dynamic>.from(resultMap['$command.[$channel]'] ?? {});
        _parseCameraParam();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('查询相机参数失败: ${kErrorMsg(e)}');
    }
  }

  /// 解析Camera.Param
  void _parseCameraParam() {
    // AE灵敏度
    final aeValue = _mapCameraParam['AeSensitivity'];
    if (aeValue != null) {
      aeSensitivity = aeValue is int ? aeValue : int.tryParse('$aeValue') ?? 3;
    }

    // 上下翻转
    final flipValue = _mapCameraParam['PictureFlip'] ?? '0x00000000';
    pictureFlip = _parseHexValue(flipValue) != 0;

    // 左右翻转
    final mirrorValue = _mapCameraParam['PictureMirror'] ?? '0x00000000';
    pictureMirror = _parseHexValue(mirrorValue) != 0;

    // 背光补偿
    final blcValue = _mapCameraParam['BLCMode'] ?? '0x00000000';
    blcMode = _parseHexValue(blcValue) != 0;

    // 日夜模式
    final dnValue = _mapCameraParam['DayNightColor'] ?? '0x00000000';
    dayNightColor = _parseHexValue(dnValue);
  }

  /// 解析hex字符串为int
  int _parseHexValue(dynamic value) {
    if (value is int) return value;
    final str = '$value';
    if (str.startsWith('0x') || str.startsWith('0X')) {
      return int.tryParse(str.substring(2), radix: 16) ?? 0;
    }
    return int.tryParse(str) ?? 0;
  }

  /// 将int转为hex字符串格式 "0x00000000" / "0x00000001"
  String _toHexString(int value) {
    return '0x${value.toRadixString(16).padLeft(8, '0')}';
  }

  // ==================== 设置方法 ====================

  /// 保存Camera.Param（AE灵敏度、翻转、背光补偿、日夜模式），返回是否成功
  Future<bool> _setCameraParam() async {
    _mapCameraParam['AeSensitivity'] = aeSensitivity;
    _mapCameraParam['PictureFlip'] = _toHexString(pictureFlip ? 1 : 0);
    _mapCameraParam['PictureMirror'] = _toHexString(pictureMirror ? 1 : 0);
    _mapCameraParam['BLCMode'] = _toHexString(blcMode ? 1 : 0);
    _mapCameraParam['DayNightColor'] = _toHexString(dayNightColor);

    final jsonStr = jsonEncode(_mapCameraParam);
    try {
      await JFApi.xcDevice.xcDevSetChnConfig(
        deviceId: deviceId,
        channelNo: channel,
        commandName: 'Camera.Param',
        config: jsonStr,
        configLen: jsonStr.length + 1,
        command: 1040,
        timeout: 15000,
      );
      return true;
    } catch (e) {
      _saveErrorMsg = kErrorMsg(e);
      debugPrint('保存相机参数失败: $_saveErrorMsg');
      return false;
    }
  }

  // ==================== 统一保存 ====================

  /// 统一保存：参考Android DevCameraSetActivity.tryToSaveConfig的交互，
  /// 收集所有控件状态后一次性发起保存请求，成功后返回true，由页面退出
  Future<bool> tryToSaveConfig() async {
    KToast.show();
    // 保存Camera.Param（AE灵敏度、翻转、背光补偿、日夜模式）
    if (!await _setCameraParam()) {
      await _restoreConfigAfterSaveFailed();
      return false;
    }
    KToast.show(status: TR.current.saveSuccess);
    return true;
  }

  /// 保存失败后重新查询设备配置恢复页面状态，并提示错误
  Future<void> _restoreConfigAfterSaveFailed() async {
    await _queryCameraParam();
    KToast.show(status: _saveErrorMsg ?? TR.current.saveFailed);
  }

  // ==================== 交互方法 ====================
  // 各项设置仅更新本地状态，保存请求统一由tryToSaveConfig发起；
  // 值变化后先_buildUI重建界面（刷新档位名称等显示），再notifyListeners通知刷新

  /// 设置AE灵敏度
  void setAeSensitivity(int value) {
    aeSensitivity = value;
    notifyListeners();
  }

  /// 设置上下翻转
  void setPictureFlip(bool value) {
    pictureFlip = value;
    notifyListeners();
  }

  /// 设置左右翻转
  void setPictureMirror(bool value) {
    pictureMirror = value;
    notifyListeners();
  }

  /// 设置背光补偿
  void setBlcMode(bool value) {
    blcMode = value;
    notifyListeners();
  }

  /// 设置日夜模式
  void setDayNightColor(int value) {
    dayNightColor = value;
    notifyListeners();
  }

  // ==================== 显示名称 ====================

  /// AE灵敏度显示名称
  String get aeSensitivityName {
    final names = [
      TR.current.recordQualityVeryBad, // 1
      TR.current.recordQualityBad, // 2
      TR.current.recordQualityNormal, // 3
      TR.current.recordQualityGood, // 4
      TR.current.recordQualityVeryGood, // 5
      TR.current.recordQualityBestGood, // 6
    ];
    if (aeSensitivity >= 1 && aeSensitivity <= 6) {
      return names[aeSensitivity - 1];
    }
    return TR.current.recordQualityNormal;
  }

  /// 日夜模式显示名称
  String get dayNightColorName {
    switch (dayNightColor) {
      case 0:
        return TR.current.autoInfrared;
      case 1:
        return TR.current.whiteLightColor;
      case 2:
        return TR.current.blackWhiteMode;
      case 4:
        return TR.current.smartWarmLight;
      case 5:
        return TR.current.smartInfrared;
      default:
        return TR.current.autoInfrared;
    }
  }

  /// 获取日夜模式可选列表
  List<int> get dayNightOptions {
    if (supportSoftPhotosensitive) {
      return [0, 1, 2, 4, 5]; // 5档
    }
    return [0, 1, 2]; // 3档
  }

  /// 日夜模式选项显示名称
  String dayNightOptionName(int value) {
    switch (value) {
      case 0:
        return TR.current.autoInfrared;
      case 1:
        return TR.current.whiteLightColor;
      case 2:
        return TR.current.blackWhiteMode;
      case 4:
        return TR.current.smartWarmLight;
      case 5:
        return TR.current.smartInfrared;
      default:
        return '';
    }
  }

  // ==================== 弹窗 ====================

  /// 显示AE灵敏度选择弹窗
  void showAeSensitivityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(TR.current.aeSensitivity),
          children: List.generate(6, (index) {
            final value = 6 - index; // 从6到1
            final isSelected = aeSensitivity == value;
            return SimpleDialogOption(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setAeSensitivity(value);
              },
              child: Row(
                children: [
                  Text(_aeLevelName(value)),
                  const Spacer(),
                  if (isSelected) const Icon(Icons.check, color: Colors.blue),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  String _aeLevelName(int value) {
    final names = {
      6: TR.current.recordQualityBestGood,
      5: TR.current.recordQualityVeryGood,
      4: TR.current.recordQualityGood,
      3: TR.current.recordQualityNormal,
      2: TR.current.recordQualityBad,
      1: TR.current.recordQualityVeryBad,
    };
    return names[value] ?? '';
  }

  /// 显示日夜模式选择弹窗
  void showDayNightColorDialog(BuildContext context) {
    final options = dayNightOptions;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(TR.current.dayNightMode),
          children: options.map((value) {
            final isSelected = dayNightColor == value;
            return SimpleDialogOption(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setDayNightColor(value);
              },
              child: Row(
                children: [
                  Text(dayNightOptionName(value)),
                  const Spacer(),
                  if (isSelected) const Icon(Icons.check, color: Colors.blue),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
