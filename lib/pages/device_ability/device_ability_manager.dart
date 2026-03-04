import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';

enum DeviceAbilityType {
  ///OtherFunction ************************************************************

  /// 是否支持双目变焦录像拼接缩放
  bOtherFunctionSupportMultiLensSplicingWfsRecordStream,

  /// 是否支持录像模式设置
  bOtherFunctionSupportRecMainOrExtUseMainType,

  /// 是否支持 《隐藏》 上下翻转
  bOtherFunctionSupportHidePictureFlip,

  /// 是否支持 《隐藏》 左右翻转
  bOtherFunctionSupportHidePictureMirror,

  ///是否支持警戒提示音选择
  bOtherFunctionSupportAlarmVoiceTipsType,

  ///AlarmFunction ************************************************************

  ///是否支持人形检测, 如果支持, 则要展示 [智能警戒]
  bAlarmFunctionPEAInHumanPed,
}

class DeviceAbilityManager {
  static final DeviceAbilityManager instance = DeviceAbilityManager();
  final Map<String, Map> allDataAbilityMap = {};

  ///一般进入预览或者进入设置时，调用下这个接口
  static update({required String deviceId}) async {
    try {
      final resultMap = await JFApi.xcDevice
          .xcDeviceSystemFunctionAbility(deviceId: deviceId);
      if (resultMap['SystemFunction'] != null) {
        Map systemFunctionMap = resultMap['SystemFunction'];
        DeviceAbilityManager.instance.allDataAbilityMap[deviceId] =
            systemFunctionMap;
        debugPrint(jsonEncode(systemFunctionMap));
      }
    } catch (e) {
      debugPrint('能力级请求失败：${KErrorMsg(e)}');
      rethrow;
    }
  }

  ///[isUpdate] 是否需重最新的能力级
  static Future<bool> queryAbility(
      {required String deviceId,
      required DeviceAbilityType type,
      bool isUpdate = false}) async {
    if (isUpdate) {
      await DeviceAbilityManager.update(deviceId: deviceId);
    }
    if (DeviceAbilityManager.instance.allDataAbilityMap[deviceId] == null) {
      return false;
    }
    bool isSupport = false;
    final Map abilityMap =
        DeviceAbilityManager.instance.allDataAbilityMap[deviceId]!;
    isSupport = getAbilityEnable(abilityMap, type);
    return isSupport;
  }

  static bool getAbilityEnable(Map abilityMap, DeviceAbilityType type) {
    bool isSupport = false;
    switch (type) {
      ///OtherFunction ********************
      case DeviceAbilityType
            .bOtherFunctionSupportMultiLensSplicingWfsRecordStream:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']![
                    'SupportMultiLensSplicingWfsRecordStream'] !=
                null) {
          isSupport = abilityMap['OtherFunction']![
              'SupportMultiLensSplicingWfsRecordStream']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSupportHidePictureFlip:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportHidePictureFlip'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['SupportHidePictureFlip']! as bool;
        }
        break;
      case DeviceAbilityType.bOtherFunctionSupportHidePictureMirror:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportHidePictureMirror'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['SupportHidePictureMirror']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSupportAlarmVoiceTipsType:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportAlarmVoiceTipsType'] != null) {
          isSupport = abilityMap['OtherFunction']!['SupportAlarmVoiceTipsType']!
              as bool;
        }
        break;

      ///AlarmFunction ********************
      case DeviceAbilityType.bAlarmFunctionPEAInHumanPed:
        if (abilityMap['AlarmFunction'] != null &&
            abilityMap['AlarmFunction']!['PEAInHumanPed'] != null) {
          isSupport = abilityMap['AlarmFunction']!['PEAInHumanPed']! as bool;
        }
        break;
      default:
        isSupport = false;
        return false;
    }
    return isSupport;
  }
}
