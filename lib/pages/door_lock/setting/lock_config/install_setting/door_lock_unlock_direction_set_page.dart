import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'door_lock_unlock_direction_set_controller.dart';

///开锁方向设置
class DoorLockUnlockDirectionSetPage extends StatelessWidget {
  final String deviceId;
  final DoorLockSetConfig initSetConfig;

  const DoorLockUnlockDirectionSetPage({
    super.key,
    required this.deviceId,
    required this.initSetConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockUnlockDirectionSetController(
        context: context,
        deviceId: deviceId,
        initSetConfig: initSetConfig,
      ),
      child: Consumer<DoorLockUnlockDirectionSetController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: !controller.writing,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(title: const Text('开锁方向')),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _InstallWarning(
                    text: '请根据锁具实际安装方向进行设置，错误的方向可能导致门锁无法正常使用。',
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Column(
                      children: [
                        _optionItem(
                          title: '左开',
                          selected: controller.unlockDirection == 0,
                          onTap: () => controller.changeDirection(0),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _optionItem(
                          title: '右开',
                          selected: controller.unlockDirection == 1,
                          onTap: () => controller.changeDirection(1),
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

class _InstallWarning extends StatelessWidget {
  final String text;

  const _InstallWarning({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
        const SizedBox(height: 8),
        const Text(
          '请谨慎修改',
          style: TextStyle(
            color: Colors.red,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 13),
        ),
      ],
    );
  }
}
