import 'package:fcloudsdk_example/pages/door_lock/setting/quick/door_lock_quick_fun_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///快捷功能页面
class DoorLockQuickFunPage extends StatefulWidget {
  final String deviceId;

  const DoorLockQuickFunPage({super.key, required this.deviceId});

  @override
  State<DoorLockQuickFunPage> createState() => _DoorLockQuickFunPageState();
}

class _DoorLockQuickFunPageState extends State<DoorLockQuickFunPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => DoorLockQuickFunController(
            context: context, deviceId: widget.deviceId),
        child: Consumer<DoorLockQuickFunController>(
            builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F7F9),
            appBar: AppBar(
              title: const Text('快捷功能'),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildItem(
                        title: '远程开锁密码验证',
                        tips: '开启后，使用远程开锁时需要输入手机解锁密码，或者验证手机的指纹或人脸',
                        isOn: controller.remoteUnlockVerify,
                        onValueChange: (isOn) {
                          controller.changeRemoteUnlockVerify(isOn);
                        },
                      ),
                      const SizedBox(height: 10),
                      if (controller.showUserManagerVerify)
                        _buildItem(
                          title: '用户管理密码验证',
                          tips: '开启后，使用用户管理时需要输入手机解锁密码，或者验证手机的指纹或人脸',
                          isOn: controller.userManagerVerify,
                          onValueChange: (isOn) {
                            controller.changeUserManagerVerify(isOn);
                          },
                        ),
                      const SizedBox(height: 10),
                      if (controller.showRemoteUnlockShow)
                        _buildItem(
                          title: '远程开锁按钮显示',
                          tips: '开启后，可以在主页面增加开锁功能按钮。此功能需要设备支持。',
                          isOn: controller.remoteUnlockShow,
                          onValueChange: (isOn) {
                            controller.changeRemoteUnlockShow(isOn);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }));
  }

  Widget _buildItem({
    required String title,
    required String tips,
    required bool isOn,
    required ValueChanged<bool> onValueChange,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(top: 14, bottom: 14, left: 22, right: 22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(fontSize: 16, color: Color(0xFF1E1E1E)),
                ),
                const SizedBox(height: 6),
                Text(
                  tips,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: isOn,
            onChanged: onValueChange,
          ),
        ],
      ),
    );
  }
}
