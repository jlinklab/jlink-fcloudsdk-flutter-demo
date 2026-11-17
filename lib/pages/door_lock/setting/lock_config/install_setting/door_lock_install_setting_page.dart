import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'door_lock_install_setting_controller.dart';
import 'door_lock_motor_time_set_page.dart';
import 'door_lock_motor_torque_set_page.dart';
import 'door_lock_unlock_direction_set_page.dart';

///安装设置
class DoorLockInstallSettingPage extends StatelessWidget {
  final String deviceId;
  final DoorLockSetConfig initSetConfig;

  const DoorLockInstallSettingPage({
    super.key,
    required this.deviceId,
    required this.initSetConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockInstallSettingController(
        context: context,
        deviceId: deviceId,
        initSetConfig: initSetConfig,
      ),
      child: Consumer<DoorLockInstallSettingController>(
        builder: (context, controller, _) {
          final children = <Widget>[];
          void addItem(Widget item) {
            if (children.isNotEmpty) {
              children.add(
                const Divider(height: 1, indent: 16, endIndent: 16),
              );
            }
            children.add(item);
          }

          if (controller.showUnlockDirection) {
            addItem(_arrowItem(
              title: '开锁方向',
              value: controller.unlockDirectionText,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DoorLockUnlockDirectionSetPage(
                      deviceId: deviceId,
                      initSetConfig: initSetConfig,
                    ),
                  ),
                );
                controller.refreshValues();
              },
            ));
          }
          if (controller.showMotorTorque) {
            addItem(_arrowItem(
              title: '电机扭矩',
              value: controller.motorTorqueText,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DoorLockMotorTorqueSetPage(
                      deviceId: deviceId,
                      initSetConfig: initSetConfig,
                    ),
                  ),
                );
                controller.refreshValues();
              },
            ));
          }
          if (controller.showMotorTime) {
            addItem(_arrowItem(
              title: '电机堵转时间',
              value: controller.motorTimeText,
              onTap: () async {
                if (!_checkDeviceAvailable(controller)) return;
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        DoorLockMotorTimeSetPage(deviceId: deviceId),
                  ),
                );
                await controller.refreshMotorTime();
              },
            ));
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF7F7F9),
            appBar: AppBar(title: const Text('安装设置')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Column(
                      mainAxisSize: MainAxisSize.min, children: children),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _checkDeviceAvailable(DoorLockInstallSettingController controller) {
    final device = controller.device;
    if (device.sleepState == DeviceSleepState.deepSleep) {
      KToast.show(status: '设备处于深度休眠，无法唤醒');
      return false;
    }
    if (device.sleepState == DeviceSleepState.sleeping ||
        device.sleepState == DeviceSleepState.preSleep) {
      KToast.show(status: '设备正在休眠，请唤醒后重试');
      return false;
    }
    if (device.doolockCmdStatus == DoolockCmdStatus.offline) {
      KToast.show(status: '设备离线，请稍后重试');
      return false;
    }
    return true;
  }

  Widget _arrowItem({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Color(0xFF777777))),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}
