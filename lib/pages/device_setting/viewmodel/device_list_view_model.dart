import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/api/share_api.dart';
import 'package:xcloudsdk_flutter_example/manager/device_manager.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/model/model.dart';
import 'package:xcloudsdk_flutter_example/utils/push_notification.dart';

/// 低功耗设备状态类型
const int _kLowPowerStateType = 8;

/// 设备列表 UI 状态管理
/// 仅负责驱动 UI 刷新，实际数据操作委托给 [DeviceManager] 单例
/// 外部类需要获取设备数据时，请直接使用 [DeviceManager.instance]
class DevListViewModel extends ChangeNotifier {
  StreamSubscription<String>? _pushSubscription;

  /// 低功耗设备详细状态缓存（deviceId -> state）
  /// state 值: 0=离线, 1=在线, 2=浅度休眠, 3=唤醒中, 4=已唤醒, 5=深度休眠, 6=准备休眠
  final Map<String, int> _lowPowerDevStates = {};

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
    _pushSubscription = AlarmMessageAPI.instance.jfpushStream.listen((event) {
      showNotificationFromJson(event);
    });
  }

  /// 刷新设备列表
  Future<void> onRefresh() async {
    await DeviceManager.instance.refreshDeviceList();
    // 查询低功耗设备的详细状态
    await _queryLowPowerDevStates();
    notifyListeners();
  }

  /// 获取低功耗设备的详细状态
  /// 通过 xcGetDeviceState 接口查询，而非直接使用 device.state
  int getLowPowerDevState(String deviceId) {
    return _lowPowerDevStates[deviceId] ?? 0;
  }

  /// 批量查询低功耗设备的详细休眠状态
  Future<void> _queryLowPowerDevStates() async {
    final lowPowerDevices = DeviceManager.instance.allDevices
        .where((d) => d.isLowPowerType)
        .toList();
    for (var device in lowPowerDevices) {
      try {
        final state = await JFApi.xcDevice.xcGetDeviceState(
          deviceId: device.uuid,
          stateType: _kLowPowerStateType,
        );
        _lowPowerDevStates[device.uuid] = state;
      } catch (e) {
        debugPrint('查询低功耗设备状态失败: ${device.uuid}, $e');
      }
    }
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
