import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fcloudsdk/manager/device_config_manager.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_ability/device_ability_manager.dart';
import 'package:fcloudsdk_example/pages/device_setting/aov/model/white_light_bean.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

/// AOV灯光设置控制器
class DeviceAovLightSetController extends ChangeNotifier {
  final String deviceId;
  final BuildContext context;

  DeviceAovLightSetController({required this.deviceId, required this.context}) {
    _init();
  }

  // 能力支持
  bool supportWhiteLight = false;
  bool supportDoubleLightBoxCamera = false;
  bool supportSetBrightness = false;
  bool supportSoftLedThr = false;
  bool supportStatusLed = false;
  bool supportMicroFillLight = false;

  // 数据
  WhiteLightBean? _whiteLightBean;
  Map<String, dynamic>? _cameraParamEx;
  Map<String, dynamic>? _fbExtraStateCtrl;
  List<int> cameraDayLightModes = [];

  // 状态
  int softLedThr = 3;
  bool ledStatus = false;
  bool microFillLightStatus = false;
  bool isLoading = true;

  // 白光灯开关状态
  bool get isWhiteLightOn => _whiteLightBean?.workMode != 'Close';
  bool get isAutoLight => _whiteLightBean?.workMode == 'Auto';
  bool get isTimingLight => _whiteLightBean?.workMode == 'Timing';
  int get brightness => _whiteLightBean?.brightness ?? 0;

  // 双光设备模式
  bool get isGeneralNight => _whiteLightBean?.workMode == 'Close';
  bool get isFullColor => _whiteLightBean?.workMode == 'Auto';
  bool get isDoubleLight => _whiteLightBean?.workMode == 'Intelligent';

  Future<void> _init() async {
    try {
      await _getAbilities();
      await Future.wait([
        supportWhiteLight ? _getWhiteLight() : Future.value(),
        supportStatusLed ? _getFbExtraStateCtrl() : Future.value(),
        supportDoubleLightBoxCamera ? _getCameraDayLightModes() : Future.value(),
        (supportMicroFillLight || supportSoftLedThr)
            ? _getCameraParamEx()
            : Future.value(),
      ]);
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      if (context.mounted) Navigator.of(context).pop();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getAbilities() async {
    await DeviceAbilityManager.update(deviceId: deviceId);
    supportWhiteLight = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportCameraWhiteLight);
    supportDoubleLightBoxCamera = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportDoubleLightBoxCamera);
    supportSetBrightness = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportSetBrightness);
    supportSoftLedThr = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId, type: DeviceAbilityType.bOtherFunctionSoftLedThr);
    supportStatusLed = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportStatusLed);
    supportMicroFillLight = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionMicroFillLight);
  }

  // 白光灯开关
  Future<void> toggleWhiteLight() async {
    _whiteLightBean?.workMode = !isWhiteLightOn ? 'Auto' : 'Close';
    await _saveWhiteLight();
    notifyListeners();
  }

  // 自动灯光
  Future<void> setAutoLight() async {
    _whiteLightBean?.workMode = 'Auto';
    await _saveWhiteLight();
    notifyListeners();
  }

  // 定时灯光
  Future<void> setTimingLight() async {
    _whiteLightBean?.workMode = 'Timing';
    await _saveWhiteLight();
    notifyListeners();
  }

  // 红外夜视（双光设备）
  Future<void> setGeneralNightVision() async {
    _whiteLightBean?.workMode = 'Close';
    await _saveWhiteLight();
    notifyListeners();
  }

  // 星光全彩（双光设备）
  Future<void> setFullColorVision() async {
    _whiteLightBean?.workMode = 'Auto';
    await _saveWhiteLight();
    notifyListeners();
  }

  // 双光警戒（双光设备）
  Future<void> setDoubleLightVision() async {
    _whiteLightBean?.workMode = 'Intelligent';
    await _saveWhiteLight();
    notifyListeners();
  }

  // 设置亮度
  Future<void> setBrightness(int value) async {
    _whiteLightBean?.brightness = value;
    await _saveWhiteLight();
    notifyListeners();
  }

  // 设置开始时间
  Future<void> setStartTime(int hour, int minute) async {
    if (_whiteLightBean == null) return;
    if (_whiteLightBean!.workPeriod.eHour == hour &&
        _whiteLightBean!.workPeriod.eMinute == minute) {
      KToast.show(status: TR.current.Start_And_End_Time_Unable_Equal);
      return;
    }
    _whiteLightBean!.workPeriod.sHour = hour;
    _whiteLightBean!.workPeriod.sMinute = minute;
    await _saveWhiteLight();
    notifyListeners();
  }

  // 设置结束时间
  Future<void> setEndTime(int hour, int minute) async {
    if (_whiteLightBean == null) return;
    if (_whiteLightBean!.workPeriod.sHour == hour &&
        _whiteLightBean!.workPeriod.sMinute == minute) {
      KToast.show(status: TR.current.Start_And_End_Time_Unable_Equal);
      return;
    }
    _whiteLightBean!.workPeriod.eHour = hour;
    _whiteLightBean!.workPeriod.eMinute = minute;
    await _saveWhiteLight();
    notifyListeners();
  }

  // 状态灯开关
  Future<void> toggleStatusLed() async {
    ledStatus = !ledStatus;
    _fbExtraStateCtrl?['ison'] = ledStatus ? 1 : 0;
    await _saveFbExtraStateCtrl();
    notifyListeners();
  }

  // 微光控制开关
  Future<void> toggleMicroFillLight() async {
    microFillLightStatus = !microFillLightStatus;
    _cameraParamEx?['MicroFillLight'] = microFillLightStatus ? 1 : 0;
    await _saveCameraParamEx();
    notifyListeners();
  }

  // 设置灵敏度
  Future<void> setSoftLedThr(int value) async {
    softLedThr = value;
    _cameraParamEx?['SoftLedThr'] = softLedThr;
    await _saveCameraParamEx();
    notifyListeners();
  }

  String get startTimeText {
    final sHour = _whiteLightBean?.workPeriod.sHour.toString().padLeft(2, '0') ?? '00';
    final sMinute = _whiteLightBean?.workPeriod.sMinute.toString().padLeft(2, '0') ?? '00';
    return '$sHour:$sMinute';
  }

  String get endTimeText {
    final eHour = _whiteLightBean?.workPeriod.eHour.toString().padLeft(2, '0') ?? '00';
    final eMinute = _whiteLightBean?.workPeriod.eMinute.toString().padLeft(2, '0') ?? '00';
    return '$eHour:$eMinute';
  }

  String softLedThrDisplay(int value) {
    List<String> levelArray = [
      TR.current.TR_PIR_lowest,
      TR.current.TR_PIR_Lower,
      TR.current.level_middle,
      TR.current.TR_PIR_Higher,
      TR.current.TR_PIR_Hightext,
    ];
    if (value < 1 || value > levelArray.length) {
      return TR.current.TR_Unknow;
    }
    return levelArray[value - 1];
  }

  // ==================== 数据获取 ====================

  Future<void> _getWhiteLight() async {
    var response = await DeviceConfigManager.getConfigToObject<Map<String, dynamic>>(
        deviceId: deviceId, commandName: DeviceJsonName.whiteLight);
    if (response.isNotEmpty) {
      _whiteLightBean = WhiteLightBean.fromJson(response);
    }
  }

  Future<void> _getFbExtraStateCtrl() async {
    _fbExtraStateCtrl = await DeviceConfigManager.getConfigToObject(
        deviceId: deviceId, commandName: DeviceJsonName.fbExtraStateCtrl);
    if (supportStatusLed) {
      ledStatus = (_fbExtraStateCtrl?['ison'] ?? 0) == 1;
    }
  }

  Future<void> _getCameraParamEx() async {
    _cameraParamEx = await DeviceConfigManager.getConfigToObject<Map<String, dynamic>>(
        deviceId: deviceId, commandName: DeviceJsonName.cameraParamEx);
    microFillLightStatus = (_cameraParamEx?['MicroFillLight'] ?? 0) == 1;
    softLedThr = (_cameraParamEx?['SoftLedThr'] as int?) ?? 3;
  }

  Future<void> _getCameraDayLightModes() async {
    var response = await DeviceConfigManager.getConfigToObject<List>(
        deviceId: deviceId,
        commandName: DeviceJsonName.cameraDayLightModes,
        command: 1360);
    cameraDayLightModes = response.map((e) => e['value'] as int).toList();
  }

  // ==================== 数据保存 ====================

  Future<void> _saveWhiteLight() async {
    try {
      KToast.show();
      var jsonStr = jsonEncode(_whiteLightBean!.toJson());
      await DeviceConfigManager.setConfig(
          deviceId: deviceId,
          commandName: DeviceJsonName.whiteLight,
          config: jsonStr,
          configLength: jsonStr.length);
    } catch (e) {
      await _getWhiteLight();
      KToast.show(status: kErrorMsg(e));
    } finally {
      KToast.dismiss();
    }
  }

  Future<void> _saveFbExtraStateCtrl() async {
    try {
      KToast.show();
      var jsonStr = jsonEncode(_fbExtraStateCtrl);
      await DeviceConfigManager.setConfig(
          deviceId: deviceId,
          commandName: DeviceJsonName.fbExtraStateCtrl,
          config: jsonStr,
          configLength: jsonStr.length);
    } catch (e) {
      await _getFbExtraStateCtrl();
      KToast.show(status: kErrorMsg(e));
    } finally {
      KToast.dismiss();
    }
  }

  Future<void> _saveCameraParamEx() async {
    try {
      KToast.show();
      var jsonStr = jsonEncode([_cameraParamEx]);
      await DeviceConfigManager.setConfig(
          deviceId: deviceId,
          commandName: DeviceJsonName.cameraParamEx,
          config: jsonStr,
          configLength: jsonStr.length);
    } catch (e) {
      await _getCameraParamEx();
      KToast.show(status: kErrorMsg(e));
    } finally {
      KToast.dismiss();
    }
  }
}
