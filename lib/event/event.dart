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