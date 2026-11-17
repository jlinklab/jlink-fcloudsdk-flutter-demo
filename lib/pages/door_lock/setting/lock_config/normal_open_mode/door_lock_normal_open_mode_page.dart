import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'door_lock_normal_open_mode_controller.dart';

///常开模式
class DoorLockNormalOpenModePage extends StatelessWidget {
  final String deviceId;
  final DoorLockSetConfig initSetConfig;

  const DoorLockNormalOpenModePage({
    super.key,
    required this.deviceId,
    required this.initSetConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockNormalOpenModeController(
        context: context,
        deviceId: deviceId,
        initSetConfig: initSetConfig,
      ),
      child: Consumer<DoorLockNormalOpenModeController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: !controller.saving,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(title: const Text('常开模式')),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(child: _buildContent(context, controller)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: controller.saving
                              ? null
                              : () async {
                                  final config = await controller.saveConfig();
                                  if (config != null && context.mounted) {
                                    Navigator.of(context).pop(config);
                                  }
                                },
                          child: controller.saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('保存'),
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

  Widget _buildContent(
    BuildContext context,
    DoorLockNormalOpenModeController controller,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (controller.supportTemp) ...[
          Card(
            elevation: 0,
            color: Colors.white,
            child: SwitchListTile(
              title: const Text('临时常开'),
              subtitle: const Text('开门后可在门锁键盘输入 5# 开启或关闭常开'),
              value: controller.tempOpen,
              onChanged: controller.saving ? null : controller.updateTempOpen,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Card(
          elevation: 0,
          color: Colors.white,
          child: SwitchListTile(
            title: Text(controller.supportTemp ? '限时常开' : '常开模式'),
            subtitle: const Text('在设定的星期和时间内保持常开'),
            value: controller.open,
            onChanged: controller.saving ? null : controller.updateOpen,
          ),
        ),
        if (controller.open) ...[
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      '重复',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: List.generate(7, (day) {
                        const names = ['日', '一', '二', '三', '四', '五', '六'];
                        return ChoiceChip(
                          label: Text(names[day]),
                          selected: controller.weeks.contains(day),
                          onSelected: controller.saving
                              ? null
                              : (selected) =>
                                  controller.updateWeek(day, selected),
                        );
                      }),
                    ),
                  ),
                  const Divider(height: 24),
                  SwitchListTile(
                    title: const Text('全天开启'),
                    value: controller.allDayOpen,
                    onChanged:
                        controller.saving ? null : controller.updateAllDay,
                  ),
                  if (!controller.allDayOpen) ...[
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _timeItem(
                      context: context,
                      title: '开始时间',
                      minutes: controller.startTime,
                      enabled: !controller.saving,
                      onChanged: controller.updateStartTime,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _timeItem(
                      context: context,
                      title: '结束时间',
                      minutes: controller.endTime,
                      enabled: !controller.saving,
                      onChanged: controller.updateEndTime,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _timeItem({
    required BuildContext context,
    required String title,
    required int minutes,
    required bool enabled,
    required ValueChanged<int> onChanged,
  }) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final text =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(color: Colors.grey)),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: enabled
          ? () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: hour, minute: minute),
              );
              if (time != null) onChanged(time.hour * 60 + time.minute);
            }
          : null,
    );
  }
}
