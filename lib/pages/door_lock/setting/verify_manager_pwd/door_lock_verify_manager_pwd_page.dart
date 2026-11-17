import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'door_lock_verify_manager_pwd_controller.dart';

///管理员密码验证页面
class DoorLockVerifyManagerPwdPage extends StatelessWidget {
  final String deviceId;

  const DoorLockVerifyManagerPwdPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockVerifyManagerPwdController(
        context: context,
        deviceId: deviceId,
      ),
      child: Consumer<DoorLockVerifyManagerPwdController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: !controller.verifying,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(title: const Text('锁具管理员验证')),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 56,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '进入安装设置前需要验证锁具管理员密码',
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
                          style: const TextStyle(color: Color(0xFF777777)),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          enabled: !controller.verifying,
                          obscureText: true,
                          autofocus: true,
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
                            if (!controller.verifying) {
                              _verify(context, controller);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: controller.verifying ||
                                  controller.password.isEmpty
                              ? null
                              : () => _verify(context, controller),
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _verify(
    BuildContext context,
    DoorLockVerifyManagerPwdController controller,
  ) async {
    final verified = await controller.verify();
    if (verified && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
