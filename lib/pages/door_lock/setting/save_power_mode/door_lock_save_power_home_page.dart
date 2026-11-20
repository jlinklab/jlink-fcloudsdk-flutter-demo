import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/door_lock_custom_enum.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/save_power_mode/controller/door_lock_save_power_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

///省电模式主页
class DoorLockSavePowerModeHomePage extends StatefulWidget {
  final String deviceId;

  ///门锁首页直进时无上级页面收口End，退出时自己结束保活
  final bool fromHomePage;

  const DoorLockSavePowerModeHomePage(
      {super.key, required this.deviceId, this.fromHomePage = false});

  @override
  State<DoorLockSavePowerModeHomePage> createState() =>
      _DoorLockSavePowerModeHomePageState();
}

class _DoorLockSavePowerModeHomePageState
    extends State<DoorLockSavePowerModeHomePage> {
  late DoorLockSavePowerController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockSavePowerController(
          context: context,
          deviceId: widget.deviceId,
          fromHomePage: widget.fromHomePage),
      builder: (context, child) {
        return Consumer<DoorLockSavePowerController>(
            builder: (context, kcontroller, _) {
          controller = kcontroller;
          return Scaffold(
            backgroundColor: const Color(0xFFF6F8FA),
            appBar: AppBar(
              title: Text(TR.current.TR_Setting_Power_Saving_Mode),
            ),
            body: controller.currentMode == DoorLockSavePowerModeType.unknown
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                header(),
                                const SizedBox(height: 8),
                                items(),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                              width: double.infinity, child: saveBtn()),
                        ),
                      ],
                    ),
                  ),
          );
        });
      },
    );
  }

  Widget header() {
    tip() {
      var text = '';
      if (controller.currentMode == DoorLockSavePowerModeType.triggerMode) {
        text = TR.current.TR_PowerSave_Trigger_Tip;
      } else if (controller.currentMode ==
              DoorLockSavePowerModeType.monitorMode ||
          controller.currentMode ==
              DoorLockSavePowerModeType.monitorCustomMode) {
        text = TR.current.TR_PowerSave_Monitor_Tip;
      } else if (controller.currentMode ==
          DoorLockSavePowerModeType.imageTransMode) {
        text = TR.current.TR_PowerSave_Photo_Tip;
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 14, color: Color(0xFF666666), height: 1.4),
        ),
      );
    }

    warning() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(7),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2, right: 4),
              child: Icon(Icons.error_outline, size: 16, color: Colors.red),
            ),
            Expanded(
              child: Text(
                TR.current.TR_PowerSave_Monitor_Important_Tip,
                maxLines: 2,
                style: const TextStyle(fontSize: 13, color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tip(),
        if (controller.currentMode == DoorLockSavePowerModeType.monitorMode ||
            controller.currentMode ==
                DoorLockSavePowerModeType.monitorCustomMode)
          warning(),
      ],
    );
  }

  Widget items() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ///触发模式
          if (controller.enableTriggerMode) ...[
            _modeItem(
              title: TR.current.TR_Setting_Trigger_Mode,
              selected: controller.currentMode ==
                  DoorLockSavePowerModeType.triggerMode,
              onTap: () => controller
                  .changeCurrentMode(DoorLockSavePowerModeType.triggerMode),
            ),
            if (controller.currentMode == DoorLockSavePowerModeType.triggerMode)
              _subItem(
                title: TR.current.TR_Common_Time,
                content: triggerModeMin(),
                onTap: () => controller.selectTriggerModeMin(),
              ),
            const Divider(height: 1),
          ],

          ///监控模式
          if (controller.enableMonitorMode ||
              controller.enableMonitorModeSelTime) ...[
            _modeItem(
              title: TR.current.TR_Setting_Monitor_Mode,
              selected: controller.currentMode ==
                      DoorLockSavePowerModeType.monitorMode ||
                  controller.currentMode ==
                      DoorLockSavePowerModeType.monitorCustomMode,
              onTap: () {
                if (controller.enableMonitorModeSelTime) {
                  controller.changeCurrentMode(
                      DoorLockSavePowerModeType.monitorCustomMode);
                } else {
                  controller
                      .changeCurrentMode(DoorLockSavePowerModeType.monitorMode);
                }
              },
            ),
            if (controller.currentMode ==
                DoorLockSavePowerModeType.monitorCustomMode)
              _subItem(
                title: TR.current.TR_PowerSave_Period,
                content: monitorSelTimeContent(),
                onTap: () => controller.selectMonitorModeDuration(),
              ),
            const Divider(height: 1),
          ],

          ///图传模式
          if (controller.enableImageTransMode) ...[
            _modeItem(
              title: TR.current.TR_Setting_Image_Transmission_Mode,
              selected: controller.currentMode ==
                  DoorLockSavePowerModeType.imageTransMode,
              onTap: () => controller
                  .changeCurrentMode(DoorLockSavePowerModeType.imageTransMode),
            ),
          ],
        ],
      ),
    );
  }

  ///模式选择项
  Widget _modeItem({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: Icon(
        selected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: selected ? Theme.of(context).primaryColor : Colors.grey,
      ),
    );
  }

  ///模式子项（时间 / 时段）
  Widget _subItem({
    required String title,
    required String content,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      title: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Text(title, style: const TextStyle(fontSize: 14)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(content,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9CA9B9))),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA9B9)),
        ],
      ),
    );
  }

  String triggerModeMin() {
    return TR.current.TR_PowerSave_ShowTimeUnit(
        (controller.delay ~/ 60).toString().padLeft(2, '0'),
        (controller.delay % 60).toString().padLeft(2, '0'));
  }

  String monitorSelTimeContent() {
    if (controller.monitorisAllDay) {
      return TR.current.TR_Common_AllDay;
    }
    var start = DateFormat('HH:mm').format(controller.monitorModeStart);
    var end = DateFormat('HH:mm').format(controller.monitorModeEnd);
    var content = "$start - $end";
    if (start.compareTo(end) > 0) {
      content += TR.current.TR_Common_NextDay;
    }
    return content;
  }

  Widget saveBtn() {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        side: const BorderSide(color: Color(0xFFDDDDDD)),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: () => controller.save(),
      child: Text(TR.current.save, style: const TextStyle(fontSize: 15)),
    );
  }
}
