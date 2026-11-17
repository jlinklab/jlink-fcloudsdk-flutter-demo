import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'door_lock_human_sensor_controller.dart';

///人体感应
class DoorLockHumanSensorPage extends StatelessWidget {
  final String deviceId;
  final DoorLockSetConfig initSetConfig;

  const DoorLockHumanSensorPage({
    super.key,
    required this.deviceId,
    required this.initSetConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockHumanSensorController(
        context: context,
        deviceId: deviceId,
        initSetConfig: initSetConfig,
      ),
      child: Consumer<DoorLockHumanSensorController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: !controller.writing,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(title: const Text('人体感应')),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SwitchListTile(
                          title: const Text('人体感应'),
                          subtitle: const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text('开启后，有人靠近时，会主动唤醒门锁并验证识别'),
                          ),
                          value: controller.open,
                          onChanged: controller.writing
                              ? null
                              : (_) => _changeSwitch(context, controller),
                        ),
                        if (controller.open)
                          ...controller.distanceValues.map(
                            (value) => _distanceItem(controller, value),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _distanceItem(
    DoorLockHumanSensorController controller,
    int value,
  ) {
    const titles = ['短距', '中距', '长距'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, indent: 16, endIndent: 16),
        ListTile(
          title: Text(titles[value]),
          trailing: controller.value == value
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
          onTap: controller.writing || controller.value == value
              ? null
              : () => controller.changeValue(value),
        ),
      ],
    );
  }

  Future<void> _changeSwitch(
    BuildContext context,
    DoorLockHumanSensorController controller,
  ) async {
    if (controller.open && controller.pirOpen) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('提示'),
          content: const Text('关闭人体感应后逗留侦测功能将会失效，确认关闭？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('确认'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      if (!await controller.closePirConfig()) return;
    }
    await controller.changeSwitch();
  }
}
