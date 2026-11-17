import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'door_lock_pir_config_controller.dart';

///逗留侦测
class DoorLockPirConfigPage extends StatelessWidget {
  final String deviceId;
  final DoorLockSetConfig initSetConfig;

  const DoorLockPirConfigPage({
    super.key,
    required this.deviceId,
    required this.initSetConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockPirConfigController(
        context: context,
        deviceId: deviceId,
        initSetConfig: initSetConfig,
      ),
      child: Consumer<DoorLockPirConfigController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: !controller.writing,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(title: const Text('逗留侦测')),
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
                          title: const Text('逗留侦测'),
                          subtitle: const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              '检测到有人在锁前方停留指定时间内未验证开锁，则进行逗留报警并联网上报云端',
                            ),
                          ),
                          value: controller.open,
                          onChanged: controller.writing
                              ? null
                              : (_) => _changeSwitch(context, controller),
                        ),
                        if (controller.open && controller.supportSecond)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text('逗留侦测（秒）'),
                                    ),
                                    Text('${controller.draftValue.round()} 秒'),
                                  ],
                                ),
                                Slider(
                                  value: controller.draftValue,
                                  min: controller.min.toDouble(),
                                  max: controller.max.toDouble(),
                                  divisions: controller.sliderDivisions,
                                  label: '${controller.draftValue.round()}',
                                  onChanged: controller.writing
                                      ? null
                                      : controller.updateDraftValue,
                                  onChangeEnd: controller.writing
                                      ? null
                                      : (newValue) {
                                          final target = newValue.round();
                                          if (target != controller.value) {
                                            controller.changeValue(target);
                                          }
                                        },
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${controller.min}'),
                                    Text('${controller.max}'),
                                  ],
                                ),
                              ],
                            ),
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

  Future<void> _changeSwitch(
    BuildContext context,
    DoorLockPirConfigController controller,
  ) async {
    if (!controller.open && !controller.humanSensorOpen) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('提示'),
          content: const Text('逗留侦测功能需要同时开启人体感应，是否开启？'),
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
      if (!await controller.openHumanSensor()) return;
    }
    await controller.changeSwitch();
  }
}
