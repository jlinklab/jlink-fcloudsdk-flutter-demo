import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fcloudsdk/manager/device_config_manager.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/manager/device_property_manager.dart';
import 'package:fcloudsdk_example/manager/idr_property_manager.dart';
import 'package:fcloudsdk_example/pages/device_ability/device_ability_manager.dart';
import 'package:fcloudsdk_example/pages/device_setting/aov/device_aov_work_mode_page.dart';
import 'package:fcloudsdk_example/pages/device_setting/aov/device_battery_manage_page.dart';
import 'package:fcloudsdk_example/utils/map_utils.dart';

///AOV设置列表项
class AovListItem {
  AovListItem({required this.title, this.extraInfo, this.onTap});

  ///标题
  String title;

  ///右侧附加信息，如电量百分比/工作模式
  String? extraInfo;

  ///点击回调
  GestureTapCallback? onTap;
}

///AOV设备配置控制器
class DeviceAovSettingController extends ChangeNotifier {
  final BuildContext context;
  final String deviceId;

  DeviceAovSettingController({required this.context, required this.deviceId}) {
    _aovConfigData();
    _startListenBattery();
    if (DevicePropertyManager.instance.isAOV(deviceId: deviceId)) {
      getDevAovWorkMode();
    }
  }

  ///aov相关设置
  List<AovListItem> aovConfigList = [];

  ///电池管理项
  AovListItem? _batteryItem;

  ///工作模式项
  AovListItem? _workModeItem;

  ///当前电量
  int currentPower = 0;

  ///当前AOV工作模式
  DeviceWorkMode currentMode = DeviceWorkMode.unknown;

  ///电量上报句柄
  int _uploadHandle = -1;

  StreamSubscription? _batterySubscription;

  _aovConfigData() async {
    aovConfigList.clear();

    bool isAov = DevicePropertyManager.instance.isAOV(deviceId: deviceId);
    bool isLowPower =
        DevicePropertyManager.instance.isLowPower(deviceId: deviceId);

    //是否支持电池管理
    bool supportBatteryManager =
        await DeviceAbilityManager.getAbilityEnableIfNeed(
            deviceId: deviceId,
            type: DeviceAbilityType.bOtherFunctionSupportBatteryManager);

    //是否支持消费类灯光/基础白光
    bool consumerLightMode = await DeviceAbilityManager.getAbilityEnableIfNeed(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionConsumerLightMode);
    bool cameraWhiteLight = await DeviceAbilityManager.getAbilityEnableIfNeed(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportCameraWhiteLight);

    //是否支持4G流量卡切换
    bool net4GDualSim = await DeviceAbilityManager.getAbilityEnableIfNeed(
        deviceId: deviceId,
        type: DeviceAbilityType.bNetServerFunctionNet4GDualSim);

    if (isLowPower || (isAov && supportBatteryManager)) {
      _batteryItem = AovListItem(
        title: TR.current.TR_Setting_Battery_Management,
        extraInfo: currentPower > 0 ? '$currentPower%' : null,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  DeviceBatteryManagePage(deviceId: deviceId)));
        },
      );
      aovConfigList.add(_batteryItem!);
    }

        ///工作模式：AOV设备
    if (isAov) {
      _workModeItem = AovListItem(
        title: TR.current.TR_Setting_Mode_Of_Work,
        extraInfo: transWorkModeToDisplay(),
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  DeviceAovWorkModePage(deviceId: deviceId)));
          //返回后刷新工作模式显示
          getDevAovWorkMode();
        },
      );
      aovConfigList.add(_workModeItem!);
    }

    ///灯光设置：AOV设备 且 支持消费类灯光和白光
    if (isAov && consumerLightMode && cameraWhiteLight) {
      aovConfigList.add(AovListItem(
        title: TR.current.TR_Light_Settings,
        onTap: () {
          //TODO 跳转灯光设置页
        },
      ));
    }

    ///4G网络切换：AOV设备 且 支持4G流量卡切换
    // if (isAov && net4GDualSim) {
    //   aovConfigList.add(AovListItem(
    //     title: TR.current.TR_Setting_4G_Network_Switching,
    //     onTap: () {
    //       //TODO 跳转4G网络切换页
    //     },
    //   ));
    // }

    if (context.mounted) {
      notifyListeners();
    }
  }

  ///监听电量上报
  void _startListenBattery() async {
    _batterySubscription =
        IDRPropertyManager.instance.eleStream(deviceId).listen((event) {
      int? level = event?.level;
      if (level != null && level > 0) {
        currentPower = level;
        _batteryItem?.extraInfo = '$currentPower%';
        notifyListeners();
      }
    });
    _uploadHandle = await IDRPropertyManager.instance
        .makeStartUploadProperty(deviceId: deviceId);
  }

  ///获取配置 - Dev.AovWorkMode
  Future getDevAovWorkMode() async {
    try {
      var response = await DeviceConfigManager.getConfigToObject(
          deviceId: deviceId, commandName: DeviceJsonName.aovWorkMode);
      currentMode =
          DeviceWorkMode.mode(MapParser.queryString(response, 'Mode', ''));
      if (DevicePropertyManager.instance.isAOV(deviceId: deviceId)) {
        _workModeItem?.extraInfo = transWorkModeToDisplay();
      }
      if (context.mounted) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Dev.AovWorkMode-------------error--${e.toString()}-');
    }
  }

  String transWorkModeToDisplay() {
    String workModeStr = '';
    if (currentMode == DeviceWorkMode.balance) {
      workModeStr = TR.current.TR_Setting_Power_Saving_Mode;
    } else if (currentMode == DeviceWorkMode.performance) {
      workModeStr = TR.current.TR_Setting_Performance;
    } else if (currentMode == DeviceWorkMode.custom) {
      workModeStr = TR.current.mode_customize;
    }
    return workModeStr;
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    IDRPropertyManager.instance
        .makeStopUploadProperty(deviceId: deviceId, handle: _uploadHandle);
    super.dispose();
  }
}

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
    DeviceWorkMode mode;
    if (str == 'Balance') {
      mode = DeviceWorkMode.balance;
    } else if (str == 'Performance') {
      mode = DeviceWorkMode.performance;
    } else if (str == 'Custom') {
      mode = DeviceWorkMode.custom;
    } else {
      mode = DeviceWorkMode.unknown;
    }
    return mode;
  }
}
