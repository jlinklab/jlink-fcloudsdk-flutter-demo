import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'door_lock_auto_lock_controller.dart';

///自动关锁
class DoorLockAutoLockPage extends StatelessWidget {
  final String deviceId;
  final DoorLockSetConfig initSetConfig;

  const DoorLockAutoLockPage({
    super.key,
    required this.deviceId,
    required this.initSetConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockAutoLockController(
        context: context,
        deviceId: deviceId,
        initSetConfig: initSetConfig,
      ),
      child: Consumer<DoorLockAutoLockController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: !controller.writing,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(
                title: Text(controller.isBle ? '自动关锁' : '自动关锁设置'),
              ),
              body: controller.isBle
                  ? _buildBlePage(context, controller)
                  : _buildIotPage(controller),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlePage(
    BuildContext context,
    DoorLockAutoLockController controller,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _bleItems(context, controller),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '经过以上设定的时间，锁会自动关闭。开启或修改设置后，请先开一次锁使时间生效。',
                style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ],
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: controller.writing
                  ? null
                  : () async {
                      final success = await controller.saveBle();
                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
              child: const Text('保存'),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _bleItems(
    BuildContext context,
    DoorLockAutoLockController controller,
  ) {
    final items = <Widget>[];
    if (!controller.autoLockAlwaysOn) {
      items.add(SwitchListTile(
        title: const Text('自动关锁'),
        value: controller.open,
        onChanged: controller.writing ? null : controller.updateOpen,
      ));
    }
    if (controller.open) {
      if (items.isNotEmpty) {
        items.add(const Divider(height: 1, indent: 16, endIndent: 16));
      }
      items.add(ListTile(
        title: const Text('延迟时间（秒）'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(controller.delayText),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: controller.writing
            ? null
            : () => _selectDelayTime(context, controller),
      ));
      if (controller.isCustom) {
        items.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            controller: controller.customController,
            enabled: !controller.writing,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: '自定义时间（${controller.min}-${controller.max}秒）',
              suffixText: '秒',
            ),
          ),
        ));
      }
    }
    return items;
  }

  Future<void> _selectDelayTime(
    BuildContext context,
    DoorLockAutoLockController controller,
  ) async {
    final result = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ...controller.fixedTimes.map(
              (time) => ListTile(
                title: Text('$time 秒'),
                trailing: !controller.isCustom && controller.autoValue == time
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(time),
              ),
            ),
            ListTile(
              title: const Text('自定义'),
              trailing: controller.isCustom
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () => Navigator.of(sheetContext).pop(-1),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    if (result == -1) {
      controller.selectCustom();
    } else {
      controller.selectFixedTime(result);
    }
  }

  Widget _buildIotPage(DoorLockAutoLockController controller) {
    final items = <Widget>[];
    if (!controller.autoLockAlwaysOn) {
      items.add(_modeItem(
        title: '手动',
        selected: !controller.isAuto,
        enabled: !controller.writing,
        onTap: () => controller.changeMode(false),
      ));
      items.add(const Divider(height: 1, indent: 16, endIndent: 16));
      items.add(_modeItem(
        title: '自动',
        subtitle: controller.canChangeTime ? '门锁将在设定时间后自动关闭' : '当前设备不支持调整关锁时间',
        selected: controller.isAuto,
        enabled: !controller.writing,
        onTap: () => controller.changeMode(true),
      ));
    }
    if (controller.isAuto && controller.canChangeTime) {
      if (items.isNotEmpty) {
        items.add(const Divider(height: 1, indent: 16, endIndent: 16));
      }
      items.add(Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('关锁时间：${controller.draftValue.toInt()} 秒'),
            Slider(
              value: controller.draftValue,
              min: controller.min.toDouble(),
              max: controller.max.toDouble(),
              onChanged:
                  controller.writing ? null : controller.updateDraftValue,
              onChangeEnd: controller.writing
                  ? null
                  : (_) => controller.changeValue(
                        controller.draftValue.toInt(),
                      ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${controller.min} 秒'),
                Text('${controller.max} 秒'),
              ],
            ),
          ],
        ),
      ));
    } else if (controller.autoLockAlwaysOn && !controller.canChangeTime) {
      items.add(const ListTile(
        title: Text('自动关锁'),
        subtitle: Text('当前设备不支持调整关锁时间'),
      ));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          child: Column(mainAxisSize: MainAxisSize.min, children: items),
        ),
      ],
    );
  }

  Widget _modeItem({
    required String title,
    String? subtitle,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: selected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: !enabled || selected ? null : onTap,
    );
  }
}
