import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'door_lock_stay_detective_controller.dart';

///海外锁人形侦测
class DoorLockStayDetectivePage extends StatelessWidget {
  final String deviceId;
  final DoorLockSetConfig initSetConfig;

  const DoorLockStayDetectivePage({
    super.key,
    required this.deviceId,
    required this.initSetConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockStayDetectiveController(
        context: context,
        deviceId: deviceId,
        initSetConfig: initSetConfig,
      ),
      child: Consumer<DoorLockStayDetectiveController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: !controller.writing,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(title: const Text('人形侦测')),
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
                          title: const Text('人形侦测'),
                          subtitle: const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              '检测到有人在锁前方停留指定时间内未验证开锁，则进行人形侦测报警并联网上报云端',
                            ),
                          ),
                          value: controller.open,
                          onChanged: controller.writing
                              ? null
                              : (_) => _changeSwitch(context, controller),
                        ),
                        if (controller.open && controller.supportSecond)
                          _timeSlider(controller),
                        if (controller.open)
                          ...controller.distanceValues.map(
                            (value) => _distanceItem(controller, value),
                          ),
                      ],
                    ),
                  ),
                  if (controller.showPowerTip)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '开启该功能会增加门锁耗电量',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 13,
                              ),
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

  Widget _timeSlider(DoorLockStayDetectiveController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: Text('人形侦测（秒）')),
              Text('${controller.draftValue.round()} 秒'),
            ],
          ),
          Slider(
            value: controller.draftValue,
            min: controller.min.toDouble(),
            max: controller.max.toDouble(),
            divisions: controller.sliderDivisions,
            label: '${controller.draftValue.round()}',
            onChanged: controller.writing ? null : controller.updateDraftValue,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${controller.min}'),
              Text('${controller.max}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _distanceItem(
    DoorLockStayDetectiveController controller,
    int value,
  ) {
    const titles = ['短距', '中距', '长距'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, indent: 16, endIndent: 16),
        ListTile(
          title: Text(titles[value]),
          trailing: controller.humanSensorValue == value
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
          onTap: controller.writing || controller.humanSensorValue == value
              ? null
              : () => controller.changeDistance(value),
        ),
      ],
    );
  }

  Future<void> _changeSwitch(
    BuildContext context,
    DoorLockStayDetectiveController controller,
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
