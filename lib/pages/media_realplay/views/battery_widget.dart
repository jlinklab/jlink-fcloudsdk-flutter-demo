import 'package:flutter/material.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/manager/idr_property_manager.dart';

/// 电量等级+充电状态展示
class BatteryWidget extends StatelessWidget {
  const BatteryWidget({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 35,
      left: 0,
      child: StreamBuilder<EleEntry?>(
        stream: IDRPropertyManager.instance.eleStream(deviceId),
        builder: (context, snapshot) {
          final EleEntry? data = snapshot.data;
          if (data == null || data.level == null) {
            return const SizedBox();
          }
          return Text(
            TR.current.batteryInfo(
                data.level!, data.isCharging == true ? TR.current.chargingYes : TR.current.chargingNo),
            style: const TextStyle(fontSize: 13, color: Colors.white),
          );
        },
      ),
    );
  }
}
