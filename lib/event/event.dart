///设备出图成功事件，更新设备的配置信息缓存等
class PreviewRenderedEvent {}


/// 远程开锁结果
class RemoteUnlockResultEvent {
  final String deviceId;
  final String time;
  final bool success;

  RemoteUnlockResultEvent(
      {required this.deviceId, required this.time, required this.success});
}

/// 远程开锁被反锁拒绝（门已反锁，开锁失败）
class ReverseLockFailEvent {
  final String deviceId;
  final String time;

  ReverseLockFailEvent({required this.deviceId, required this.time});
}

/// 蓝牙在线状态变化
class BlueOnlineEvent {
  final String uuid;
  final String deviceId;
  final bool online;
  final bool isChanged;
  BlueOnlineEvent({
    required this.uuid,
    required this.deviceId,
    required this.online,
    required this.isChanged,
  });
}

/// 设备在线/休眠状态变化（服务器设备状态流下发）
///
///门锁首页监听此事件重算指令通道状态（doolockCmdStatus），
///让开关锁按钮及时随在线/休眠状态变色
class DeviceStateUpdateEvent {
  final String deviceId;

  DeviceStateUpdateEvent({required this.deviceId});
}

/// 远程开关锁结果推送（锁真实执行动作后服务器推送 DoorLockOpen/DoorLockClose）
///
///远程命令受理成功不代表锁已动作，开关锁页面等待此事件
///把转圈替换为成功提示
///[isUnlock] true 开锁 / false 关锁
class RemoteLockActionResultEvent {
  final String deviceId;
  final bool isUnlock;

  RemoteLockActionResultEvent({required this.deviceId, required this.isUnlock});
}