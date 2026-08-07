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

  ///是否支持状态灯
  bOtherFunctionSupportStatusLed,

  ///是否支持提示音开关
  bOtherFunctionSupportCloseVoiceTip,

  ///是否支持日夜切换灵敏度
  bOtherFunctionSupportDNChangeByImage,

  ///是否支持全双工对讲
  bOtherFunctionSupportTwoWayVoiceTalk,

  ///是否支持音量调节(喇叭)
  bOtherFunctionSupportSetVolume,

  ///是否支持音量调节(麦克风)
  bOtherFunctionSupportSetInVolume,

  /// 是否AOV设备
  bOtherFunctionSupportAovMode,

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
      debugPrint('能力级请求失败：${kErrorMsg(e)}');
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

      case DeviceAbilityType.bOtherFunctionSupportStatusLed:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportStatusLed'] != null) {
          isSupport = abilityMap['OtherFunction']!['SupportStatusLed']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSupportCloseVoiceTip:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportCloseVoiceTip'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['SupportCloseVoiceTip']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSupportDNChangeByImage:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportDNChangeByImage'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['SupportDNChangeByImage']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSupportTwoWayVoiceTalk:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportTwoWayVoiceTalk'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['SupportTwoWayVoiceTalk']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSupportSetVolume:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportSetVolume'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['SupportSetVolume']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSupportSetInVolume:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportSetInVolume'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['SupportSetInVolume']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSupportAovMode:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['AovMode'] != null) {
          isSupport = abilityMap['OtherFunction']!['AovMode']! as bool;
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

  ///只走缓存
  static bool getLocalAbilityEnable(
      {required String deviceId, required DeviceAbilityType type}) {
    if (DeviceAbilityManager.instance.allDataAbilityMap[deviceId] == null) {
      return false;
    }
    bool isSupport = false;
    final Map abilityMap =
        DeviceAbilityManager.instance.allDataAbilityMap[deviceId]!;
    isSupport = getAbilityEnable(abilityMap, type);
    return isSupport;
  }
}
