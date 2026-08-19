import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_ability/device_ability_manager.dart';
import 'package:fcloudsdk_example/utils/map_utils.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///AOV工作模式
enum DeviceWorkMode {
  unknown,
  balance,
  performance,
  custom;

  String toStr() {
    switch (this) {
      case DeviceWorkMode.balance:
        return 'Balance';
      case DeviceWorkMode.performance:
        return 'Performance';
      case DeviceWorkMode.custom:
        return 'Custom';
      default:
        return 'Unknown';
    }
  }

  static DeviceWorkMode mode(String str) {
    if (str == 'Balance') {
      return DeviceWorkMode.balance;
    } else if (str == 'Performance') {
      return DeviceWorkMode.performance;
    } else if (str == 'Custom') {
      return DeviceWorkMode.custom;
    }
    return DeviceWorkMode.unknown;
  }
}

///AOV工作模式控制器
class DeviceAovWorkModeController extends ChangeNotifier {
  final String deviceId;

  DeviceAovWorkModeController({required this.deviceId}) {
    _init();
  }

  ///工作模式配置
  Map<String, dynamic>? workModeConfig;

  ///AOV能力集
  Map<String, dynamic>? aovAbility;

  ///是否支持双光
  bool supportDoubleLightBoxCamera = false;

  ///是否AOV新工作模式（独立控制）
  bool aovWorkModeIndieControl = false;

  ///当前模式
  DeviceWorkMode currentMode = DeviceWorkMode.unknown;

  ///是否正在加载
  bool isLoading = true;

  ///初始化
  _init() async {
    try {
      await Future.wait([
        _getSysFunctions(),
        _getAovAbility(),
        _getDevAovWorkMode(),
      ]);
      _refresh(); // 刷新 currentMode，内部调用 notifyListeners()
      isLoading = false;
      // isLoading 状态变化需再次通知 UI 从 loading 切换到内容页
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      KToast.show(status: kErrorMsg(e));
    }
  }

  ///获取设备能力
  Future _getSysFunctions() async {
    try {
      await DeviceAbilityManager.update(deviceId: deviceId);
      final abilityMap = DeviceAbilityManager.instance.allDataAbilityMap[deviceId];
      if (abilityMap != null) {
        //检查是否支持双光
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportDoubleLightBoxCamera'] != null) {
          supportDoubleLightBoxCamera =
              abilityMap['OtherFunction']!['SupportDoubleLightBoxCamera'] as bool;
        }
        //检查是否支持AOV独立控制
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['AovWorkModeIndieControl'] != null) {
          aovWorkModeIndieControl =
              abilityMap['OtherFunction']!['AovWorkModeIndieControl'] as bool;
        }
      }
    } catch (e) {
      debugPrint('_getSysFunctions error: $e');
    }
  }

  ///获取配置 - Dev.AovWorkMode
  Future _getDevAovWorkMode() async {
    try {
      var response = await JFApi.xcDevice.xcDevGetSysConfig(
          deviceId: deviceId, commandName: "Dev.AovWorkMode");
      if (response.containsKey('Ret') && response['Ret'] == 100) {
        var map = response['Dev.AovWorkMode'];
        if (map is Map) {
          workModeConfig = Map<String, dynamic>.from(map);
        }
      }
    } catch (e) {
      debugPrint('Dev.AovWorkMode error: $e');
      rethrow;
    }
  }

  ///获取能力集 - Ability.AovAbility
  Future _getAovAbility() async {
    try {
      var response = await JFApi.xcDevice.xcDevGetSysConfig(
          deviceId: deviceId, commandName: "Ability.AovAbility");
      if (response.containsKey('Ret') && response['Ret'] == 100) {
        var map = response['Ability.AovAbility'];
        if (map is Map) {
          aovAbility = Map<String, dynamic>.from(map);
        }
      }
    } catch (e) {
      debugPrint('Ability.AovAbility error: $e');
    }
  }

  ///刷新当前状态
  _refresh() {
    currentMode = DeviceWorkMode.mode(
        MapParser.queryString(workModeConfig, 'Mode', ''));
    notifyListeners();
  }

  ///获取模式副标题描述
  String getModeSubTitle(DeviceWorkMode mode) {
    if (workModeConfig == null) return '';

    if (mode == DeviceWorkMode.custom) {
      return '';
    }

    var config = {};
    if (mode == DeviceWorkMode.balance) {
      config = workModeConfig!['Balance'] ?? {};
    } else if (mode == DeviceWorkMode.performance) {
      config = workModeConfig!['Performance'] ?? {};
    } else {
      return '';
    }

    var fps = config['Fps'];
    if (fps == null) return '';

    if (aovWorkModeIndieControl) {
      var alarmHoldTime = config['AlarmHoldTime'];
      var recordLength = config['RecordLength'];
      if (supportDoubleLightBoxCamera) {
        return TR.current.TR_Setting_Aov_Blance_tips(
            '${fps}fps', '${alarmHoldTime}s', '${recordLength}s');
      } else {
        return TR.current.TR_Setting_AOV_BlackLight_Blance_Tips(
            '${fps}fps', '${alarmHoldTime}s', '${recordLength}s');
      }
    } else {
      if (supportDoubleLightBoxCamera) {
        return TR.current.TR_Setting_AOV_FPS_Description(fps);
      } else {
        return TR.current.TR_Setting_AOV_BlackLight_FPS_Description(fps);
      }
    }
  }

  ///切换工作模式
  changeWorkMode(DeviceWorkMode mode) async {
    try {
      KToast.show();
      await _saveWorkMode(mode);
      currentMode = mode;
      notifyListeners();
      KToast.dismiss();
    } catch (e) {
      KToast.dismiss();
      await _getDevAovWorkMode();
      _refresh();
      KToast.show(status: kErrorMsg(e));
    }
  }

  ///保存工作模式
  Future _saveWorkMode(DeviceWorkMode mode) async {
    workModeConfig!['Mode'] = mode.toStr();
    await _saveDevAovWorkMode();
  }

  ///保存DevAovWorkMode配置
  Future _saveDevAovWorkMode() async {
    var jsonStr = jsonEncode(workModeConfig);
    await JFApi.xcDevice.xcDevSetSysConfig(
        deviceId: deviceId,
        commandName: 'Dev.AovWorkMode',
        config: jsonStr,
        configLen: jsonStr.length,
        command: 1040,
        timeout: 5000);
  }

  ///修改自定义FPS
  saveFPS(String value) async {
    if (workModeConfig == null || workModeConfig!['Custom'] == null) return;
    try {
      KToast.show();
      workModeConfig!['Custom']['Fps'] = value;
      await _saveDevAovWorkMode();
      notifyListeners();
      KToast.dismiss();
    } catch (e) {
      KToast.dismiss();
      await _getDevAovWorkMode();
      _refresh();
      KToast.show(status: kErrorMsg(e));
    }
  }

  ///修改自定义报警间隔
  saveAlarmHoldTime(String value) async {
    if (workModeConfig == null || workModeConfig!['Custom'] == null) return;
    try {
      KToast.show();
      workModeConfig!['Custom']['AlarmHoldTime'] = value;
      await _saveDevAovWorkMode();
      notifyListeners();
      KToast.dismiss();
    } catch (e) {
      KToast.dismiss();
      await _getDevAovWorkMode();
      _refresh();
      KToast.show(status: kErrorMsg(e));
    }
  }

  ///修改最大录像时长
  saveRecordLength(int value) async {
    if (workModeConfig == null || workModeConfig!['Custom'] == null) return;
    try {
      KToast.show();
      workModeConfig!['Custom']['RecordLength'] = value;
      await _saveDevAovWorkMode();
      notifyListeners();
      KToast.dismiss();
    } catch (e) {
      KToast.dismiss();
      await _getDevAovWorkMode();
      _refresh();
      KToast.show(status: kErrorMsg(e));
    }
  }

  ///获取自定义模式当前FPS显示
  String get customFpsDisplay {
    if (workModeConfig == null) return '';
    var config = workModeConfig!['Custom'];
    if (config == null) return '';
    return '${config['Fps']}fps';
  }

  ///获取自定义模式当前报警间隔显示
  String get customAlarmHoldTimeDisplay {
    if (workModeConfig == null) return '';
    var config = workModeConfig!['Custom'];
    if (config == null) return '';
    var value = config['AlarmHoldTime'];
    if (value == '0') return 'Real';
    return '${value}s';
  }

  ///获取自定义模式当前录像时长显示
  String get customRecordLengthDisplay {
    if (workModeConfig == null) return '';
    var config = workModeConfig!['Custom'];
    if (config == null) return '';
    return '${config['RecordLength']}s';
  }

  ///获取FPS可选列表
  List<String> get fpsOptions {
    if (aovAbility == null || aovAbility!['VideoFps'] == null) return [];
    return (aovAbility!['VideoFps'] as List).map((e) => '$e').toList();
  }

  ///获取报警间隔可选列表
  List<int> get alarmHoldTimeOptions {
    if (aovAbility == null ||
        aovAbility!['AlarmHoldTime'] == null ||
        aovAbility!['AlarmHoldTime']['HoldTimeList'] == null) {
      return [];
    }
    return (aovAbility!['AlarmHoldTime']['HoldTimeList'] as List)
        .map((e) => e as int)
        .toList();
  }

  ///获取录像时长可选列表
  List<int> get recordLengthOptions {
    if (aovAbility == null ||
        aovAbility!['RecordLength'] == null ||
        aovAbility!['RecordLength']['RecordLengthList'] == null) {
      return [];
    }
    return (aovAbility!['RecordLength']['RecordLengthList'] as List)
        .map((e) => e as int)
        .toList();
  }
}
