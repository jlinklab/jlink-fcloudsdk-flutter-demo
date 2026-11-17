import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'door_opening_direction_self_check_controller.dart';

///开锁方向自检
class DoorOpeningDirectionSelfCheckPage extends StatelessWidget {
  final String deviceId;

  const DoorOpeningDirectionSelfCheckPage({
    super.key,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorOpeningDirectionSelfCheckController(
        context: context,
        deviceId: deviceId,
      ),
      child: Consumer<DoorOpeningDirectionSelfCheckController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F7F9),
            appBar: AppBar(title: const Text('开锁方向自检')),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 100),
                            Icon(
                              controller.selfCheckSuccess
                                  ? Icons.check_circle_outline
                                  : Icons.lock_open_rounded,
                              size: 160,
                              color: controller.selfCheckSuccess
                                  ? Colors.green
                                  : Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 40),
                            Text(
                              controller.tipsText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF1E1E1E),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 30),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: controller.checking
                              ? null
                              : () async {
                                  final completed =
                                      await controller.handlePrimaryAction();
                                  if (completed && context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                          child: Text(controller.primaryButtonText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
