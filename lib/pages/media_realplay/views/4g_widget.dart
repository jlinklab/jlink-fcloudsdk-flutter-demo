import 'package:flutter/material.dart';
import 'package:fcloudsdk/manager/device_config_manager.dart';
import 'package:fcloudsdk/media/controller/media_controller.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';

///4g 信号展示
class Signal4GWidget extends StatefulWidget {
  const Signal4GWidget(
      {super.key,
      required this.deviceId,
      required this.support,
      this.mediaController});

  final String deviceId;
  final bool support;
  final MediaController? mediaController;

  @override
  State<Signal4GWidget> createState() => _Signal4GWidgetState();
}

class _Signal4GWidgetState extends State<Signal4GWidget> {
  int signal4GLevel = -1;

  @override
  void initState() {
    super.initState();
    _getSingle4GLevel();
  }

  @override
  void didUpdateWidget(covariant Signal4GWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 出图刷新能力集后需要重新请求 4G 信号
    if (widget.support && !oldWidget.support) {
      _getSingle4GLevel();
    }
  }

  void _getSingle4GLevel() async {
    try {
      if (widget.support) {
        final response = await DeviceConfigManager.getConfigToObject(
            deviceId: widget.deviceId,
            commandName: DeviceJsonName.g4Info,
            command: 1020,
            timeout: 5000);
        signal4GLevel = response['SignalLevel'] ?? 0;
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    if (signal4GLevel <= 0) {
      return const SizedBox();
    }
    return Positioned(
        top: 20,
        left: 0,
        child: Text(
          TR.current.signal4GLevel(signal4GLevel),
          style: const TextStyle(fontSize: 13, color: Colors.white),
        ));
  }
}
