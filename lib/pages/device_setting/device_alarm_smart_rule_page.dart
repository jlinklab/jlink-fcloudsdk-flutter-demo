import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import 'controller/device_alarm_smart_rule_controller.dart';

class DeviceAlarmSmartRulePage extends StatefulWidget {
  final String deviceId;
  const DeviceAlarmSmartRulePage({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  State<DeviceAlarmSmartRulePage> createState() =>
      _DeviceAlarmSmartRulePageState();
}

class _DeviceAlarmSmartRulePageState extends State<DeviceAlarmSmartRulePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceAlarmSmartRuleController(
        context: context,
        deviceId: widget.deviceId,
      ),
      builder: (context, child) {
        return Consumer<DeviceAlarmSmartRuleController>(
          builder: (context, controller, child) {
            return Scaffold(
              appBar: AppBar(
                title: Text(TR.current.TR_Rule_Setting),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: controller.dataSource
                        .map((e) => _buildItem(e, controller))
                        .toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildItem(
      SmartRuleItemModel model, DeviceAlarmSmartRuleController controller) {
    switch (model.type) {
      case SmartRuleItemType.switchType:
        return ListTile(
          title: Text(model.title),
          trailing: Switch(
            value: model.switchValue,
            onChanged: (value) {
              model.onSwitchChanged?.call(value);
            },
          ),
        );
      case SmartRuleItemType.arrow:
        return ListTile(
          title: Text(
            model.title,
            style: TextStyle(
              color: model.selected ? Colors.blue : Colors.black,
            ),
          ),
          trailing: model.selected
              ? const Icon(Icons.check_circle, color: Colors.blue)
              : const Icon(Icons.chevron_right),
          onTap: model.onTap,
        );
    }
  }
}
