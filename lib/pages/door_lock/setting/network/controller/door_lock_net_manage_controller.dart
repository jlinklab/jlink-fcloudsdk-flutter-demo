import 'dart:async';

import 'package:fcloudsdk_example/api/device_api.dart';
import 'package:fcloudsdk_example/common/event.dart';
import 'package:fcloudsdk_example/event/event.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/models/device_type.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/network/door_lock_net_check_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/network/door_lock_reset_net_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/network/usecase/door_lock_wifi_config_jumper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:flutter/material.dart';

///网络设置首页：wifi信息展示与重置网络/网络检测入口
class DoorLockNetManageController extends DoorLockPageController {
  @override
  final String deviceId;

  ///wifi名称
  String? wifiName;

  ///wifi信号强度（dBm换算为0-100）
  int wifiLevel = 0;

  ///控制器是否已销毁，销毁后不再刷新视图
  bool _disposed = false;

  ///重新配网成功事件订阅：刷新wifi信息
  StreamSubscription<DoorLockResetNetSuccessEvent>? _resetNetSuccessSub;

  DoorLockNetManageController(
      {required super.context, required this.deviceId}) {
    createDoorLockAPI();

    queryWifiInfo();

    _resetNetSuccessSub =
        eventBus.on<DoorLockResetNetSuccessEvent>().listen((event) {
      if (event.deviceId != deviceId) {
        return;
      }
      queryWifiInfo();
    });
  }

  @override
  dispose() {
    _disposed = true;
    _resetNetSuccessSub?.cancel();
    _resetNetSuccessSub = null;
    super.dispose();
  }

  ///标题：海外锁为网络管理，国内锁为网络设置
  String get title => DoorLockHelper.isOverSeaDoorLock(deviceId)
      ? TR.current.TR_DoorLock_Settings_Net_Manage
      : TR.current.TR_Setting_Network_Set;

  ///涂鸦蓝牙设备与涂鸦BK海外锁（视频款/无视频款）不支持网络检测
  bool get supportNetCheck =>
      !DoorLockHelper.isTuYaBluetoothDevice(device.parentPid) &&
      !DoorLockHelper.isTuyaBKOverseasVideoDevice(device.parentPid) &&
      !DoorLockHelper.isTuyaBKOverseasNoneVideoDevice(device.parentPid) &&
      device.localUiKey != DeviceLocalUIKeyType.BK100W_NoVideo.type;

  ///查询wifi名称与信号强度
  queryWifiInfo() async {
    try {
      var response = await deviceAPI.getDevicePropStatus(
          deviceId: deviceId, props: ['wifiSignal', 'wifiName']);
      if (response is Map) {
        if (response.containsKey('wifiSignal')) {
          wifiLevel = IotDeviceUtil.convertdBm2RSSI(
              int.tryParse('${response['wifiSignal']}') ?? 0);
        }
        if (response.containsKey('wifiName')) {
          wifiName = response['wifiName']?.toString();
        }
      }
    } catch (e) {
      ///
    }
    _notify();
  }

  ///重置网络：蓝牙WiFi不共存设备需先清空设备网络，其余直接重新配网
  jumpResetNet() async {
    ///跳配网前停止蓝牙断连倒计时，防止休眠断连
    doorLockBleApi?.cancelDisConnectCount();

    if (DoorLockHelper.isBleAndWifiIncompatible(deviceId)) {
      _pushPage(DoorLockResetNetPage(deviceId: deviceId));
      return;
    }

    DoorLockWifiConfigJumper.jumpBlueConfig(this, onComplete: queryWifiInfo);
  }

  ///网络检测
  jumpNetCheck() {
    _pushPage(DoorLockNetCheckPage(deviceId: deviceId));
  }

  ///进入子页
  _pushPage(Widget page) {
    if (pageContext == null || !pageContext!.mounted) {
      return;
    }
    Navigator.of(pageContext!).push(MaterialPageRoute(builder: (_) => page));
  }

  _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
