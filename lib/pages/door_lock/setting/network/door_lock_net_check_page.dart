import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/network/controller/door_lock_net_check_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///网络检测页
class DoorLockNetCheckPage extends StatelessWidget {
  final String deviceId;

  const DoorLockNetCheckPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          DoorLockNetCheckController(context: context, deviceId: deviceId),
      child: Consumer<DoorLockNetCheckController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F7F9),
            appBar:
                AppBar(title: Text(TR.current.TR_DoorLock_Settings_Net_Check)),
            body: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _stateImage(controller),
                        const SizedBox(height: 20),
                        _countDownText(controller),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: SizedBox(
                            ///文案固定两行高度，单行/双行切换不影响整体高度
                            height: 44,
                            width: double.infinity,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                controller.stateText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 15, color: Color(0xFF1E1E1E)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _reCheckButton(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  ///状态图：检测中/成功/失败
  Widget _stateImage(DoorLockNetCheckController controller) {
    switch (controller.status) {
      case DoorLockNetCheckStatus.nostart:
      case DoorLockNetCheckStatus.failed:
        return const Icon(Icons.wifi_off, size: 120, color: Color(0xFFFF5A5A));
      case DoorLockNetCheckStatus.checking:
        return const SizedBox(
          width: 120,
          height: 120,
          child: Center(
            child: SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
        );
      case DoorLockNetCheckStatus.success:
        return const Icon(Icons.wifi, size: 120, color: Color(0xFF4CAF50));
    }
  }

  ///检测中的剩余时间：完成后保留固定高度占位，避免状态切换时图标位置跳动
  Widget _countDownText(DoorLockNetCheckController controller) {
    return SizedBox(
      height: 21,
      child: controller.status != DoorLockNetCheckStatus.checking
          ? const SizedBox()
          : Text(
              '${controller.countdown}s',
              style: const TextStyle(fontSize: 15, color: Color(0xFF9CA9B9)),
            ),
    );
  }

  ///结果出来后显示重新检测按钮
  Widget _reCheckButton(DoorLockNetCheckController controller) {
    if (controller.status == DoorLockNetCheckStatus.checking) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 12, 40, 40),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: controller.startCheck,
          child: Text(TR.current.TR_DoorLock_Settings_Re_Check),
        ),
      ),
    );
  }
}
