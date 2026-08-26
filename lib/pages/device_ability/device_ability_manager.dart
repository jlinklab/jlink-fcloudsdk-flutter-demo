import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';

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

  /// 是否支持获取电池信息
  bOtherFunctionGetBatteryInfo,

  /// 是否支持电池管理
  bOtherFunctionSupportBatteryManager,

  /// 是否支持消费类灯光
  bOtherFunctionConsumerLightMode,

  /// 是否支持基础白光
  bOtherFunctionSupportCameraWhiteLight,

  /// 是否支持低功耗工作模式切换
  bOtherFunctionSupportLPWorkModeSwitchV2,

  /// 是否支持低功耗设备唤醒和预览时长
  bOtherFunctionLowPowerWorkTime,

  ///AlarmFunction ************************************************************

  ///是否支持人形检测, 如果支持, 则要展示 [智能警戒]
  bAlarmFunctionPEAInHumanPed,

  ///NetServerFunction ************************************************************

  /// 是否支持获取4G信号强度
  bNetServerFunctionNet4GSignalLevel,

  /// 是否支持4G流量卡切换
  bNetServerFunctionNet4GDualSim,

  /// 是否支持双光枪机
  bOtherFunctionSupportDoubleLightBoxCamera,

  /// 是否支持灯光亮度
  bOtherFunctionSupportSetBrightness,

  /// 支持自动灯光模式下的灵敏度设置
  bOtherFunctionSoftLedThr,

  /// 是否支持微光控制
  bOtherFunctionMicroFillLight,

  /// 是否支持图片水印
  bOtherFunctionJpegChnTitleOSD,
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
          isSupport = abilityMap['OtherFunction']!['SupportSetVolume']! as bool;
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

      case DeviceAbilityType.bOtherFunctionGetBatteryInfo:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['GetBatteryInfo'] != null) {
          isSupport = abilityMap['OtherFunction']!['GetBatteryInfo']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSupportBatteryManager:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['BatteryManager'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['BatteryManager']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionConsumerLightMode:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['ConsumerLightMode'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['ConsumerLightMode']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSupportCameraWhiteLight:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportCameraWhiteLight'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['SupportCameraWhiteLight']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSupportLPWorkModeSwitchV2:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportLPWorkModeSwitchV2'] !=
                null) {
          isSupport = abilityMap['OtherFunction']!['SupportLPWorkModeSwitchV2']!
              as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionLowPowerWorkTime:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['LowPowerWorkTime'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['LowPowerWorkTime']! as bool;
        }
        break;

      ///NetServerFunction ********************
      case DeviceAbilityType.bNetServerFunctionNet4GSignalLevel:
        if (abilityMap['NetServerFunction'] != null &&
            abilityMap['NetServerFunction']!['Net4GSignalLevel'] != null) {
          isSupport =
              abilityMap['NetServerFunction']!['Net4GSignalLevel']! as bool;
        }
        break;

      case DeviceAbilityType.bNetServerFunctionNet4GDualSim:
        if (abilityMap['NetServerFunction'] != null &&
            abilityMap['NetServerFunction']!['Net4GDualSim'] != null) {
          isSupport =
              abilityMap['NetServerFunction']!['Net4GDualSim']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSupportDoubleLightBoxCamera:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportDoubleLightBoxCamera'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['SupportDoubleLightBoxCamera']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSupportSetBrightness:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SupportSetBrightness'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['SupportSetBrightness']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionSoftLedThr:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['SoftLedThr'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['SoftLedThr']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionMicroFillLight:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['MicroFillLight'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['MicroFillLight']! as bool;
        }
        break;

      case DeviceAbilityType.bOtherFunctionJpegChnTitleOSD:
        if (abilityMap['OtherFunction'] != null &&
            abilityMap['OtherFunction']!['JpegChnTitleOSD'] != null) {
          isSupport =
              abilityMap['OtherFunction']!['JpegChnTitleOSD']! as bool;
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

  ///如果没有缓存就实时获取
  static Future<bool> getAbilityEnableIfNeed(
      {required String deviceId, required DeviceAbilityType type}) async {
    if (DeviceAbilityManager.instance.allDataAbilityMap[deviceId] == null) {
      await DeviceAbilityManager.update(deviceId: deviceId);
    }
    bool isSupport = false;
    final Map? abilityMap =
        DeviceAbilityManager.instance.allDataAbilityMap[deviceId];
    if (abilityMap != null) {
      isSupport = getAbilityEnable(abilityMap, type);
    }
    return isSupport;
  }
}
