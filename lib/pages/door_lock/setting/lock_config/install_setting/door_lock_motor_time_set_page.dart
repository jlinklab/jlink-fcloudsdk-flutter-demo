import 'package:fcloudsdk_example/pages/door_lock/setting/verify_manager_pwd/door_lock_verify_manager_pwd_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'door_lock_motor_time_set_controller.dart';

///电机堵转时间设置
class DoorLockMotorTimeSetPage extends StatelessWidget {
  final String deviceId;

  const DoorLockMotorTimeSetPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockMotorTimeSetController(
        context: context,
        deviceId: deviceId,
      ),
      child: Consumer<DoorLockMotorTimeSetController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: !controller.working,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(title: const Text('电机堵转时间')),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Column(
                      children: [
                        for (var index = 0;
                            index < controller.motorTimeOptions.length;
                            index++) ...[
                          _optionItem(
                            title: _motorTimeText(
                              controller.motorTimeOptions[index],
                            ),
                            selected: controller.selectMotorTime ==
                                controller.motorTimeOptions[index],
                            onTap: () => _selectValue(
                              context,
                              controller,
                              controller.motorTimeOptions[index],
                            ),
                          ),
                          if (index < controller.motorTimeOptions.length - 1)
                            const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                        ],
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

  String _motorTimeText(int value) => value == 0 ? '默认' : '$value ms';

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

  Future<void> _selectValue(
    BuildContext context,
    DoorLockMotorTimeSetController controller,
    int value,
  ) async {
    if (controller.working || value == controller.currentMotorTime) return;
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DoorLockVerifyManagerPwdPage(deviceId: deviceId),
      ),
    );
    if (verified != true || !context.mounted) return;
    await controller.changeMotorTime(value);
  }
}
