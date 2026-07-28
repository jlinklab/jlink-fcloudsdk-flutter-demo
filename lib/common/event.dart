import 'package:event_bus/event_bus.dart';

final EventBus eventBus = EventBus();

class RemoveDeviceUpdateEvent {
  final int type;

  RemoveDeviceUpdateEvent({required this.type});
}