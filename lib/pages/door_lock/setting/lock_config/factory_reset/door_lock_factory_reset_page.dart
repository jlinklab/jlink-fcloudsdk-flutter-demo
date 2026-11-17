import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'door_lock_factory_reset_controller.dart';

///锁具恢复出厂设置
class DoorLockFactoryResetPage extends StatelessWidget {
  final String deviceId;

  const DoorLockFactoryResetPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockFactoryResetController(
        context: context,
        deviceId: deviceId,
      ),
      child: Consumer<DoorLockFactoryResetController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: !controller.working,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(title: const Text('锁具管理员验证')),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (controller.resetCompleted) ...[
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  '锁具已恢复出厂，但设备尚未从当前账号移除。',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 15,
                                  ),
                                ),
                              ] else ...[
                                const Text(
                                  '恢复出厂前需要验证锁具管理员密码',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '请输入${controller.minLength}～${controller.maxLength}位数字管理员密码',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF777777),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextField(
                                  enabled: !controller.working,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  maxLength: controller.maxLength,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: '管理员密码',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: controller.updatePassword,
                                  onSubmitted: (_) {
                                    if (!controller.working) {
                                      _confirmStart(context, controller);
                                    }
                                  },
                                ),
                              ],
                              if (controller.working) ...[
                                const SizedBox(height: 20),
                                Text(
                                  controller.progressText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF777777),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: controller.working
                                    ? null
                                    : () => _confirmStart(context, controller),
                                child: Text(
                                  controller.resetCompleted ? '重新移除设备' : '确定',
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Future<void> _confirmStart(
    BuildContext context,
    DoorLockFactoryResetController controller,
  ) async {
    if (!controller.resetCompleted && !controller.validatePassword()) return;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          controller.resetCompleted ? '重新移除设备？' : '确定移除并恢复出厂设置？',
        ),
        content: Text(
          controller.resetCompleted
              ? '锁具已经恢复出厂，本次只会重试从当前账号移除设备。'
              : '设备将取消配网，指纹、密码等所有锁端信息将被删除，设备将从当前账号移除且分享失效。此操作不可撤销。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确认', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await controller.start();
    if (success && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
