import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/aov/controller/device_aov_work_mode_controller.dart';

///AOV工作模式页面
class DeviceAovWorkModePage extends StatefulWidget {
  final String deviceId;

  const DeviceAovWorkModePage({super.key, required this.deviceId});

  @override
  State<DeviceAovWorkModePage> createState() => _DeviceAovWorkModePageState();
}

class _DeviceAovWorkModePageState extends State<DeviceAovWorkModePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          DeviceAovWorkModeController(deviceId: widget.deviceId),
      child: Consumer<DeviceAovWorkModeController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(TR.current.TR_Setting_Mode_Of_Work),
              centerTitle: true,
            ),
            backgroundColor: const Color(0xFFF1F4F9),
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.5, vertical: 16),
                    child: Column(
                      children: [
                        _modeItem(
                          context,
                          controller,
                          mode: DeviceWorkMode.balance,
                          title: TR.current.TR_Setting_Power_Saving_Mode,
                          subTitle: controller
                              .getModeSubTitle(DeviceWorkMode.balance),
                          isSelected:
                              controller.currentMode == DeviceWorkMode.balance,
                        ),
                        const SizedBox(height: 8),
                        _modeItem(
                          context,
                          controller,
                          mode: DeviceWorkMode.performance,
                          title: TR.current.TR_Setting_Performance,
                          subTitle: controller
                              .getModeSubTitle(DeviceWorkMode.performance),
                          isSelected: controller.currentMode ==
                              DeviceWorkMode.performance,
                        ),
                        const SizedBox(height: 8),
                        _modeItem(
                          context,
                          controller,
                          mode: DeviceWorkMode.custom,
                          title: TR.current.mode_customize,
                          subTitle: '',
                          isSelected:
                              controller.currentMode == DeviceWorkMode.custom,
                        ),
                        //自定义模式子项
                        if (controller.currentMode == DeviceWorkMode.custom)
                          _customModeItems(context, controller),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  ///模式选择项
  Widget _modeItem(
    BuildContext context,
    DeviceAovWorkModeController controller, {
    required DeviceWorkMode mode,
    required String title,
    required String subTitle,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.changeWorkMode(mode),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor, width: 1.5)
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF1E1E1E),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (subTitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subTitle,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF7F7F7F)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///自定义模式子项
  Widget _customModeItems(
      BuildContext context, DeviceAovWorkModeController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: [
            //帧率
            _customSubItem(
              title: TR.current.TR_AOV_Fps,
              value: controller.customFpsDisplay,
              onTap: () => _showFpsSelectDialog(context, controller),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            //报警间隔
            _customSubItem(
              title: TR.current.TR_AOV_Alarm_interval,
              value: controller.customAlarmHoldTimeDisplay,
              onTap: () =>
                  _showAlarmHoldTimeSelectDialog(context, controller),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            //录像时长
            _customSubItem(
              title: TR.current.TR_Setting_Aov_RecordLength,
              value: controller.customRecordLengthDisplay,
              onTap: () =>
                  _showRecordLengthSelectDialog(context, controller),
            ),
          ],
        ),
      ),
    );
  }

  ///自定义子项
  Widget _customSubItem({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  ///FPS选择弹窗
  void _showFpsSelectDialog(
      BuildContext context, DeviceAovWorkModeController controller) {
    final options = controller.fpsOptions;
    if (options.isEmpty) return;
    final current = controller.customFpsDisplay;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(TR.current.TR_AOV_Fps),
          children: options.map((fps) {
            final display = '${fps}fps';
            return SimpleDialogOption(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                controller.saveFPS(fps);
              },
              child: Row(
                children: [
                  Icon(
                    current == display
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: current == display
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(display),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  ///报警间隔选择弹窗
  void _showAlarmHoldTimeSelectDialog(
      BuildContext context, DeviceAovWorkModeController controller) {
    final options = controller.alarmHoldTimeOptions;
    if (options.isEmpty) return;
    final current = controller.customAlarmHoldTimeDisplay;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(TR.current.TR_AOV_Alarm_interval),
          children: options.map((value) {
            final display = value == 0 ? 'Real' : '${value}s';
            return SimpleDialogOption(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                controller.saveAlarmHoldTime('$value');
              },
              child: Row(
                children: [
                  Icon(
                    current == display
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: current == display
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(display),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  ///录像时长选择弹窗
  void _showRecordLengthSelectDialog(
      BuildContext context, DeviceAovWorkModeController controller) {
    final options = controller.recordLengthOptions;
    if (options.isEmpty) return;
    final current = controller.customRecordLengthDisplay;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(TR.current.TR_Setting_Aov_RecordLength),
          children: options.map((value) {
            final display = '${value}s';
            return SimpleDialogOption(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                controller.saveRecordLength(value);
              },
              child: Row(
                children: [
                  Icon(
                    current == display
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: current == display
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(display),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
