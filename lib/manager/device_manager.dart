import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/utils/extensions.dart';

import '../common/local_device_cache.dart';
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
  List<Device> shareDeviceList = [];

  /// 所有设备（我的 + 分享）
  List<Device> get allDevices => [...mineDeviceList, ...shareDeviceList];

  /// 设备状态流订阅
  StreamSubscription<DeviceState>? _deviceStateSubscription;

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
    shareDeviceList = devices.share;

    // 根据本地缓存先展示设备状态
    Map deviceMap = await LocalDeviceCache.fetchDevicesDataMap(
        userId: UserInfo.instance.userId);
    for (Device device in allDevices) {
      if (deviceMap.containsKey(device.uuid)) {
        device.state = deviceMap[device.uuid]!.state;
      }
    }

    // 异步更新设备在线状态
    _updateDevState();
    // 刷新云服务状态
    DeviceCloudServiceManager.instance
        .refreshCloudServicesStatus(devices: allDevices);

    // 保存到本地缓存
    LocalDeviceCache.saveDevicesState(
        userId: UserInfo.instance.userId, deviceList: allDevices);
  }

  /// 从服务器批量更新设备在线状态
  void _updateDevState() async {
    try {
      await AccountAPI.instance.xcGetDevicesState(
          uuids: allDevices.map((e) => e.uuid).toList());
      LocalDeviceCache.saveDevicesState(
          userId: UserInfo.instance.userId, deviceList: allDevices);
    } catch (e) {
      debugPrint('更新设备状态失败: $e');
    }
  }

  /// 开始监听设备状态变更
  void startDeviceStateListener({VoidCallback? onStateChanged}) {
    _deviceStateSubscription?.cancel();
    _deviceStateSubscription =
        AccountAPI.instance.deviceStateStream.listen((event) {
      final device = allDevices.firstWhereOrNull((e) => e.uuid == event.uuid);
      if (device != null) {
        device.state = event.state;
        onStateChanged?.call();
      }
    });
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
    stopDeviceStateListener();
    mineDeviceList.clear();
    shareDeviceList.clear();
  }
}
