import 'dart:core';

import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/device_ability/device_ability_manager.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/controller/device_audio_upload_base_controller.dart';

class DeviceAlarmCustomVoiceController extends DeviceAudioUploadBaseController {
  DeviceAlarmCustomVoiceController({
    required BuildContext context,
    required String deviceId,
  }) : super(context: context, deviceId: deviceId) {
    queryRecordTime();
    super.textFeildHintText = TR.current.TR_Please_Enter_Alarm_Tips;
  }

  void queryRecordTime() async {
    if (callVoiceAbility == false) {
      /// 老设备判断是否支持呼唤音
      bool supportCallVoice = await DeviceAbilityManager.queryAbility(
          deviceId: deviceId,
          type: DeviceAbilityType.bOtherFunctionSupportAlarmVoiceTipsType);
      callVoiceAbility = supportCallVoice;
    }
  }
}
