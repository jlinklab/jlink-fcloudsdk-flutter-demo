import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/network/controller/door_lock_net_manage_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///网络设置首页
class DoorLockNetManagePage extends StatefulWidget {
  final String deviceId;

  const DoorLockNetManagePage({super.key, required this.deviceId});

  @override
  State<DoorLockNetManagePage> createState() => _DoorLockNetManagePageState();
}

class _DoorLockNetManagePageState extends State<DoorLockNetManagePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockNetManageController(
          context: context, deviceId: widget.deviceId),
      child: Consumer<DoorLockNetManageController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F7F9),
            appBar: AppBar(title: Text(controller.title)),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _wifiSignalImage(),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(TR.current.TR_DoorLock_Wifi_Name),
                          trailing: Text(
                            controller.wifiName ?? '',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        ListTile(
                          title: Text(TR.current.TR_Device_Wifi_Signal_Level),
                          trailing: Text(
                            '${controller.wifiLevel}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.wifi_tethering_off),
                          title:
                              Text(TR.current.TR_DoorLock_Settings_Reset_Net),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: controller.jumpResetNet,
                        ),
                        if (controller.supportNetCheck)
                          ListTile(
                            leading: const Icon(Icons.network_check),
                            title:
                                Text(TR.current.TR_DoorLock_Settings_Net_Check),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: controller.jumpNetCheck,
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

  ///顶部wifi信号示意图
  Widget _wifiSignalImage() {
    return const Center(
      child: Icon(Icons.wifi, size: 64, color: Color(0xFF4A90E2)),
    );
  }
}
