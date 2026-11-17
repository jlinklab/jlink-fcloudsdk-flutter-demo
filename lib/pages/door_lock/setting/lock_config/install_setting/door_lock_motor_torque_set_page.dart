import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'door_lock_motor_torque_set_controller.dart';

///电机扭矩设置
class DoorLockMotorTorqueSetPage extends StatelessWidget {
  final String deviceId;
  final DoorLockSetConfig initSetConfig;

  const DoorLockMotorTorqueSetPage({
    super.key,
    required this.deviceId,
    required this.initSetConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockMotorTorqueSetController(
        context: context,
        deviceId: deviceId,
        initSetConfig: initSetConfig,
      ),
      child: Consumer<DoorLockMotorTorqueSetController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: !controller.writing,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(title: const Text('电机扭矩')),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Column(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 48,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '请谨慎修改',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '扭矩过小可能导致无法正常开关锁，扭矩过大可能增加堵转风险，请根据门的实际情况选择。',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Column(
                      children: [
                        _optionItem(
                          title: '小',
                          selected: controller.motorTorque == 0,
                          onTap: () => controller.changeMotorTorque(0),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _optionItem(
                          title: '中',
                          selected: controller.motorTorque == 1,
                          onTap: () => controller.changeMotorTorque(1),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _optionItem(
                          title: '大',
                          selected: controller.motorTorque == 2,
                          onTap: () => controller.changeMotorTorque(2),
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

  Widget _optionItem({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: selected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: onTap,
    );
  }
}
