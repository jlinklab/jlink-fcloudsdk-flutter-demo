import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/network/controller/door_lock_reset_net_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///重置网络（清空设备网络）页
class DoorLockResetNetPage extends StatefulWidget {
  final String deviceId;

  const DoorLockResetNetPage({super.key, required this.deviceId});

  @override
  State<DoorLockResetNetPage> createState() => _DoorLockResetNetPageState();
}

class _DoorLockResetNetPageState extends State<DoorLockResetNetPage> {
  ///用户已确认中断后允许退出
  bool _allowBack = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockResetNetController(
          context: context, deviceId: widget.deviceId),
      child: Consumer<DoorLockResetNetController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: _allowBack,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && controller.clearCmdSent) {
                _showInterruptDialog(controller);
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(
                title: Text(TR.current.TR_DoorLock_Settings_Reset_Net),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () {
                    _back(controller);
                  },
                ),
              ),
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    _illustrationImage(),
                    const SizedBox(height: 12),
                    _tipText(),
                    const SizedBox(height: 12),
                    _stepText(controller.step1Text),
                    _stepText(controller.step2Text),
                    _stepText(controller.step3Text),
                    const Spacer(),
                    if (controller.showButton)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: controller.startClearNet,
                          child: Text(controller.buttonText),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ///返回处理：已发送清网命令时弹窗确认
  _back(DoorLockResetNetController controller) {
    if (controller.clearCmdSent && !_allowBack) {
      _showInterruptDialog(controller);
      return;
    }
    _exitPage(controller);
  }

  ///退出本页（流程已结束或用户已确认中断）
  _exitPage(DoorLockResetNetController controller) {
    _allowBack = true;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  _showInterruptDialog(DoorLockResetNetController controller) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: Text(TR.current.TR_DoorLock_Clear_Net_Interrupt_Tip),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _exitPage(controller);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  ///顶部示意图
  Widget _illustrationImage() {
    return const Center(
      child:
          Icon(Icons.wifi_tethering_off, size: 120, color: Color(0xFF4A90E2)),
    );
  }

  ///操作提示：按键部分高亮
  Widget _tipText() {
    var coloredText = TR.current.TR_DoorLock_Clear_Net_Tip_Ios_Colored;
    var fullText = TR.current.TR_DoorLock_Clear_Net_Tip_Ios(coloredText);
    const baseStyle = TextStyle(fontSize: 15, color: Color(0xFF1E1E1E));

    ///高亮部分在完整文案中定位，拆为前/中/后三段
    var index = fullText.indexOf(coloredText);
    if (index < 0) {
      return Text(fullText, textAlign: TextAlign.center, style: baseStyle);
    }
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: fullText.substring(0, index)),
          TextSpan(
            text: coloredText,
            style: const TextStyle(fontSize: 15, color: Color(0xFFFF8D42)),
          ),
          TextSpan(text: fullText.substring(index + coloredText.length)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  ///流程步骤文案
  Widget _stepText(String? text) {
    return Visibility(
      visible: text != null,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(
          text ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E1E1E)),
        ),
      ),
    );
  }
}
