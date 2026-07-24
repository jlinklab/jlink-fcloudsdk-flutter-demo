import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/utils/extensions.dart';

import '../models/user_instance.dart';
import '../pages/cloud/device_cloud_service_manager.dart';
import '../pages/device_setting/model/model.dart';

/// 设备数据统一管理单例
/// 负责设备列表的获取、缓存、状态监听等数据层逻辑
/// UI 层通过 [DevListViewModel] 驱动刷新，外部类可直接通过 [DeviceManager.instance] 获取数据
class DeviceManager {
  static final DeviceManager instance = DeviceManager._();

  DeviceManager._();

  /// 我的设备列表
  List<Device> mineDeviceList = [];

  /// 分享的设备列表
  List<SharedDevice> shareDeviceList = [];

  ///分享的待接受的列表
  List<SharedDevice> sharedNotAgreeDeviceList = [];

  /// 所有设备（我的 + 分享）
  List<Device> get allDevices => [...mineDeviceList, ...shareDeviceList];

  /// 设备状态流订阅
  StreamSubscription<DeviceState>? _deviceStateSubscription;

  /// 设备状态变更回调（由 UI 层注册）
  VoidCallback? _onDeviceStateChanged;

  /// 根据设备序列号获取设备对象
  Device? getDevice({required String deviceId}) {
    return allDevices.firstWhereOrNull((e) => e.uuid == deviceId);
  }

  /// 判断是否存在设备
  bool hasDevice({required String deviceId}) {
    return allDevices.firstWhereOrNull((e) => e.uuid == deviceId) != null;
  }

  /// 同步设备列表（APP 的设备列表不一定从 SDK 获取，主动同步到 DeviceManager）
  Future<void> setMineDeviceList({required List<Device> deviceList}) async {
    mineDeviceList.clear();
    mineDeviceList.addAll(deviceList);
  }

  /// 从服务器刷新设备列表
  Future<void> refreshDeviceList() async {
    if (UserInfo.instance.isLogin == false) return;

    final devicesJson = await JFApi.xcAccount.xcQueryDeviceList();
    final devices = Devices.fromJson(devicesJson);
    mineDeviceList = devices.mine;
    // 来自分享的设备，根据 ret 值分流处理
    final List<Device> rawShareDevices = devices.share;
    shareDeviceList.clear();
    sharedNotAgreeDeviceList.clear();
    for (var device in rawShareDevices) {
      if (device is SharedDevice) {
        final SharedDevice sharedDevice = device;
        if (sharedDevice.ret == 1) {
          // 已接受分享的设备，加入分享设备列表
          shareDeviceList.add(sharedDevice);
        } else if (sharedDevice.ret != 4) {
          // ret ！= 4,未接受分享放在sharedNotAgreeDeviceList列表等同意
          sharedNotAgreeDeviceList.add(sharedDevice);
        }
      }
    }

    // 确保监听已启动
    _ensureStateListener();
    // 异步更新设备在线状态
    _updateDevState();
    // 刷新云服务状态
    DeviceCloudServiceManager.instance
        .refreshCloudServicesStatus(devices: allDevices);
  }

  /// 从服务器批量更新设备在线状态
  void _updateDevState() async {
    try {
      await AccountAPI.instance
          .xcGetDevicesState(uuids: allDevices.map((e) => e.uuid).toList());
    } catch (e) {
      debugPrint('更新设备状态失败: $e');
    }
  }

  /// 确保设备状态监听已启动
  void _ensureStateListener() {
    if (_deviceStateSubscription == null && _onDeviceStateChanged != null) {
      _deviceStateSubscription =
          AccountAPI.instance.deviceStateStream.listen((event) {
        final device = allDevices.firstWhereOrNull((e) => e.uuid == event.uuid);
        if (device != null) {
          debugPrint('${device.uuid} 拿到设备状态 ${event.state}');
          device.state = event.state;
          _onDeviceStateChanged?.call();
        }
      });
    }
  }

  /// 开始监听设备状态变更，并注册回调
  void startDeviceStateListener({VoidCallback? onStateChanged}) {
    _onDeviceStateChanged = onStateChanged;
    _deviceStateSubscription?.cancel();
    _deviceStateSubscription = null;
    _ensureStateListener();
  }

  /// 停止监听设备状态变更
  void stopDeviceStateListener() {
    _deviceStateSubscription?.cancel();
    _deviceStateSubscription = null;
  }

  /// 删除设备（仅从本地列表移除）
  void removeDevice({required String deviceId, required int type}) {
    if (type == 0) {
      mineDeviceList.removeWhere((e) => e.uuid == deviceId);
    } else if (type == 1) {
      shareDeviceList.removeWhere((e) => e.uuid == deviceId);
    }
  }

  /// 释放资源
  void dispose() {
    mineDeviceList.clear();
    shareDeviceList.clear();
    sharedNotAgreeDeviceList.clear();
  }
}
