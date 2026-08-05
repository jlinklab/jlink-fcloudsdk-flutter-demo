import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/api/share_api.dart';
import 'package:xcloudsdk_flutter_example/manager/device_manager.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/model/model.dart';
import 'package:xcloudsdk_flutter_example/utils/push_notification.dart';

/// 设备列表 UI 状态管理
/// 仅负责驱动 UI 刷新，实际数据操作委托给 [DeviceManager] 单例
/// 外部类需要获取设备数据时，请直接使用 [DeviceManager.instance]
class DevListViewModel extends ChangeNotifier {
  StreamSubscription<String>? _pushSubscription;

  DevListViewModel() {
    _initAlarm();
    _startListening();
  }

  /// 我的设备列表（代理到 DeviceManager）
  List<Device> get mineDevs => DeviceManager.instance.mineDeviceList;

  /// 分享的设备列表（代理到 DeviceManager）
  List<Device> get shareDevs => DeviceManager.instance.shareDeviceList;

  /// 初始化报警服务
  Future<void> _initAlarm() async {
    // 下面的参数目前版本的XCloudSDK都不再校验了，传空即可，报警初始化也可以提前不需要等拿到账号密码
    // {
    //     "user": "",
    //     "pwd": "",
    //     "language": "",
    //     "tk": "",
    //     "userid": ""
    // }
    AlarmMessageInitModel model = AlarmMessageInitModel(
      language: 'Chinese',
      user: '',
      pwd: '',
      tk: '',
      userid: '',
    );
    await JFApi.xcAlarmMessage.xcAlarmInit(model);
  }

  /// 开始监听设备状态变更
  void _startListening() {
    DeviceManager.instance.startDeviceStateListener(
      onStateChanged: () => notifyListeners(),
    );

    ///杰峰推送监听
    _pushSubscription = AlarmMessageAPI().jfpushStream.listen((event) {
      showNotificationFromJson(event);
    });
  }

  /// 刷新设备列表
  Future<void> onRefresh() async {
    await DeviceManager.instance.refreshDeviceList();
    notifyListeners();
  }

  /// 接受分享设备
  Future<void> acceptShare(SharedDevice device) async {
    await shareAPI.acceptSharedDevice(device.shareId, device.nickname ?? '');
    await onRefresh();
  }

  /// 拒绝分享设备
  Future<void> refuseShare(SharedDevice device) async {
    await shareAPI.refuseSharedDevice(device.shareId);
    await onRefresh();
  }

  /// 删除设备
  Future<void> deleteDev(String devId, int type) async {
    DeviceManager.instance.removeDevice(deviceId: devId, type: type);
    await onRefresh();
  }

  @override
  void dispose() {
    _pushSubscription?.cancel();
    DeviceManager.instance.stopDeviceStateListener();
    super.dispose();
  }
}
