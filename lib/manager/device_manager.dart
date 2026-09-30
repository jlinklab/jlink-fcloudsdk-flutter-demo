import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/utils/extensions.dart';
import 'package:fcloudsdk_example/api/door_lock_api.dart';
import 'package:fcloudsdk_example/manager/push_manager.dart';
import 'package:fcloudsdk_example/manager/user_group_manager.dart';

import '../models/user_instance.dart';
import '../pages/cloud/device_cloud_service_manager.dart';
import '../models/device_model.dart';

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

  ///根据设备序列号获取设备名字
  String? getDeviceName({required String deviceId}) {
    return allDevices.firstWhereOrNull((e) => e.uuid == deviceId)?.nickname;
  }

  /// 同步设备列表（APP 的设备列表不一定从 SDK 获取，主动同步到 DeviceManager）
  Future<void> setMineDeviceList({required List<Device> deviceList}) async {
    mineDeviceList.clear();
    mineDeviceList.addAll(deviceList);
  }

  /// 从服务器刷新设备列表（JVSS接口）
  Future<void> refreshDeviceList() async {
    if (UserInfo.instance.isLogin == false) return;

    ///同时刷新家庭组（静默获取默认家庭组ID）
    await UserGroupManager.instance.refreshUserGroups();

    ///JVSS接口获取我的设备列表（过滤掉分享设备）
    final devicesJson = await doorlockAPI.getUserDeviceListByPage();
    final devices = Devices.fromJson(devicesJson);
    mineDeviceList = devices.mine;

    ///JVSS接口获取分享设备列表
    shareDeviceList.clear();
    sharedNotAgreeDeviceList.clear();
    try {
      final sharedJson = await doorlockAPI.getSharedDeviceList({
        'page': 0,
        'limit': 999,
      });
      if (sharedJson != null && sharedJson['data'] != null) {
        final List<Device> rawShareDevices = (sharedJson['data'] as List)
            .map<SharedDevice>((e) => SharedDevice.fromJson(e))
            .toList();
        // 根据 ret 值分流处理
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
      }
    } catch (e) {
      debugPrint('获取分享设备列表失败: $e');
    }

    // 确保监听已启动
    _ensureStateListener();
    // 异步更新设备在线状态
    _updateDevState();
    // 刷新云服务状态
    await DeviceCloudServiceManager.instance
        .refreshCloudServicesStatus(devices: allDevices);
    subscribeAllDevice();
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

  ///订阅设备列表
  Future<void> subscribeAllDevice() async {
    var needs = DeviceManager.instance.allDevices
        .where((e) =>
            e.hasPermission(permission: DevicePermission.DP_ModifyConfig) ||
            e.hasPermission(permission: DevicePermission.DP_AlarmPush))
        .map((e) => e.uuid)
        .toList();
    await PushManager.instance.subscribeBatch(deviceIdList: needs);
  }

  ///更新设备信息
  Future<void> updateDevice(
      {required String deviceId,
      int? state,
      String? nickname,
      String? adminToken,
      String? username,
      String? password,
      List<Map<String, dynamic>>? propList}) async {
    Device? device = mineDeviceList.firstWhereOrNull((e) => e.uuid == deviceId);

    if (device == null) {
      return;
    }
    if (state != null) {
      device.state = state;
    }
    if (username != null) {
      device.userName = username;
    }
    if (password != null) {
      device.password = password;
    }
    if (adminToken != null) {
      device.adminToken = adminToken;
    }
    if (nickname != null) {
      device.nickname = nickname;
    }
    device.propList = propList ?? device.propList;
  }

  /// 释放资源
  void dispose() {
    stopDeviceStateListener();
    mineDeviceList.clear();
    shareDeviceList.clear();
    sharedNotAgreeDeviceList.clear();
  }
}
