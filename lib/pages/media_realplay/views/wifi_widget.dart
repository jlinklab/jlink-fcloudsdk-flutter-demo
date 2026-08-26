import 'package:flutter/material.dart';
import 'package:fcloudsdk/manager/device_config_manager.dart';
import 'package:fcloudsdk/media/controller/media_controller.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/utils/map_utils.dart';

///Wifi 信号展示
class WifiWidget extends StatefulWidget {
  const WifiWidget(
      {super.key,
      required this.deviceId,
      required this.support,
      this.mediaController});

  final String deviceId;
  final bool support;
  final MediaController? mediaController;

  @override
  State<WifiWidget> createState() => _WifiWidgetState();
}

class _WifiWidgetState extends State<WifiWidget> {
  @override
  void initState() {
    super.initState();
    _getWifiLevel();
  }

  @override
  void didUpdateWidget(covariant WifiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 出图刷新能力集后需要重新请求
    if (widget.support && !oldWidget.support) {
      _getWifiLevel();
    }
  }

  int wifiLevel = -1;

  void _getWifiLevel() async {
    try {
      if (widget.support) {
        final response =
            await DeviceConfigManager.getConfigToObject<Map<String, dynamic>>(
                deviceId: widget.deviceId,
                commandName: DeviceJsonName.wifiRouteInfo,
                command: 1020,
                timeout: 5000);
        if ((response.getBoolValue(key: "WlanStatus", defaultValue: false) &&
                !response.getBoolValue(
                    key: "Eth0Status", defaultValue: true)) ||
            response["WlanStatus"] == null) {
          wifiLevel = response.getIntValue(key: "SignalLevel", defaultValue: 0);
          if (mounted) {
            setState(() {});
          }
        }
      }
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    if (wifiLevel <= 0) {
      return const SizedBox();
    }

    return Positioned(
      top: 20,
      left: 15,
      child: Text(
        TR.current.wifiSignalLevel(wifiLevel),
        style: const TextStyle(fontSize: 13, color: Colors.white),
      ),
    );
  }
}
