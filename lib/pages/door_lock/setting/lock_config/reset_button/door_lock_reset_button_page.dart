import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'door_lock_reset_button_controller.dart';

///重置键
class DoorLockResetButtonPage extends StatelessWidget {
  final String deviceId;
  final DoorLockSetConfig initSetConfig;

  const DoorLockResetButtonPage({
    super.key,
    required this.deviceId,
    required this.initSetConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockResetButtonController(
        context: context,
        deviceId: deviceId,
        initSetConfig: initSetConfig,
      ),
      child: Consumer<DoorLockResetButtonController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: !controller.writing,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(title: const Text('重置键')),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      child: Column(
                        children: [
                          _optionItem(
                            title: '开启',
                            description: '可同时长按门锁上的开锁键与关锁键来恢复出厂设置',
                            selected: controller.resetButton == 0,
                            enabled: !controller.writing,
                            onTap: () => _confirmChange(context, controller, 0),
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          _optionItem(
                            title: '关闭',
                            description:
                                '用户无法通过长按门锁上的开锁键与关锁键来恢复出厂设置，只能通过APP进行恢复出厂设置',
                            selected: controller.resetButton == 1,
                            enabled: !controller.writing,
                            onTap: () => _confirmChange(context, controller, 1),
                          ),
                        ],
                      ),
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
    required String description,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(description),
      ),
      trailing: selected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: enabled ? onTap : null,
    );
  }

  Future<void> _confirmChange(
    BuildContext context,
    DoorLockResetButtonController controller,
    int value,
  ) async {
    if (controller.resetButton == value) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('提示'),
        content: Text(value == 0 ? '确认启用重置键？' : '确认禁用重置键？'),
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
    if (confirmed == true) {
      await controller.changeSwitch(value);
    }
  }
}
