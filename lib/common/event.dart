import 'package:event_bus/event_bus.dart';

final EventBus eventBus = EventBus();

class RemoveDeviceUpdateEvent {
  final int type;

  RemoveDeviceUpdateEvent({required this.type});
}

/// 接收固件文件事件（三端原生拦截分享文件后的结果）
class ReceiveFileEvent {
  /// 接收结果码：0 成功，负数错误码
  final int code;

  ReceiveFileEvent(this.code);
}