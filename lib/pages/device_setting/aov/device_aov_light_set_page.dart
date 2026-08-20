import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/aov/controller/device_aov_light_set_controller.dart';

/// AOV灯光设置页面
class DeviceAovLightSetPage extends StatefulWidget {
  final String deviceId;

  const DeviceAovLightSetPage({Key? key, required this.deviceId})
      : super(key: key);

  @override
  State<DeviceAovLightSetPage> createState() => _DeviceAovLightSetPageState();
}

class _DeviceAovLightSetPageState extends State<DeviceAovLightSetPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceAovLightSetController(
          deviceId: widget.deviceId, context: context),
      child: Consumer<DeviceAovLightSetController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(TR.current.TR_Light_Settings),
              centerTitle: true,
            ),
            backgroundColor: const Color(0xFFF1F4F9),
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: _buildContent(controller),
                  ),
          );
        },
      ),
    );
  }

  List<Widget> _buildContent(DeviceAovLightSetController controller) {
    final widgets = <Widget>[];

    if (controller.supportDoubleLightBoxCamera) {
      // 双光设备：三种夜视模式
      if (controller.cameraDayLightModes.contains(5)) {
        widgets.add(_buildRadioItem(
          title: TR.current.General_Night_Vision,
          selected: controller.isGeneralNight,
          onTap: controller.setGeneralNightVision,
        ));
      }
      if (controller.cameraDayLightModes.contains(4)) {
        widgets.add(_buildRadioItem(
          title: TR.current.Full_Color_Vision,
          selected: controller.isFullColor,
          onTap: controller.setFullColorVision,
        ));
      }
      if (controller.cameraDayLightModes.contains(3)) {
        widgets.add(_buildRadioItem(
          title: TR.current.Double_Light_Vision,
          selected: controller.isDoubleLight,
          onTap: controller.setDoubleLightVision,
        ));
      }
    } else {
      // 普通设备：白光灯开关 + 亮度
      widgets.add(_buildSection(TR.current.TR_White_Light_Switch,
          trailing: CupertinoSwitch(
            value: controller.isWhiteLightOn,
            onChanged: (_) => controller.toggleWhiteLight(),
          )));

      if (controller.isWhiteLightOn && controller.supportSetBrightness) {
        widgets.add(_buildBrightnessSlider(controller));
      }

      // 自动灯光
      if (controller.isWhiteLightOn) {
        widgets.add(_buildRadioItem(
          title: TR.current.TR_AutoLight,
          subTitle: TR.current.TR_AutoLightDetail,
          selected: controller.isAutoLight,
          onTap: controller.setAutoLight,
        ));
      }

      // 灵敏度
      if (controller.isWhiteLightOn &&
          controller.isAutoLight &&
          controller.supportSoftLedThr) {
        widgets.add(_buildSensitivitySlider(controller));
      }

      // 定时灯光
      if (controller.isWhiteLightOn) {
        widgets.add(_buildRadioItem(
          title: TR.current.TR_TimingLight,
          subTitle: TR.current.TR_TimingLightDetail,
          selected: controller.isTimingLight,
          onTap: controller.setTimingLight,
        ));
      }

      // 定时时间段
      if (controller.isWhiteLightOn && controller.isTimingLight) {
        widgets.add(_buildTimeItem(
          title: '${TR.current.start_time}: ${controller.startTimeText}',
          onTap: () => _showTimePicker(
            initialHour: int.tryParse(controller.startTimeText.split(':')[0]) ?? 0,
            initialMinute: int.tryParse(controller.startTimeText.split(':')[1]) ?? 0,
            onSelect: (h, m) => controller.setStartTime(h, m),
          ),
        ));
        widgets.add(_buildTimeItem(
          title: '${TR.current.set_finish}: ${controller.endTimeText}',
          onTap: () => _showTimePicker(
            initialHour: int.tryParse(controller.endTimeText.split(':')[0]) ?? 0,
            initialMinute: int.tryParse(controller.endTimeText.split(':')[1]) ?? 0,
            onSelect: (h, m) => controller.setEndTime(h, m),
          ),
        ));
      }
    }

    // 设备指示灯
    if (controller.supportStatusLed) {
      widgets.add(const Divider());
      widgets.add(_buildSection(TR.current.TR_Setting_Device_Indicator_Light,
          trailing: CupertinoSwitch(
            value: controller.ledStatus,
            onChanged: (_) => controller.toggleStatusLed(),
          )));
    }

    // 微光控制
    if (controller.supportMicroFillLight) {
      widgets.add(const Divider());
      widgets.add(_buildSection(
        TR.current.TR_Low_Light_Control,
        subTitle: TR.current.TR_Low_Light_Control_Tip,
        trailing: CupertinoSwitch(
          value: controller.microFillLightStatus,
          onChanged: (_) => controller.toggleMicroFillLight(),
        ),
      ));
    }

    return widgets;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, color: Color(0xFF848484)),
      ),
    );
  }

  Widget _buildSection(String title,
      {String? subTitle, Widget? trailing}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        title: Text(title),
        subtitle: subTitle != null ? Text(subTitle) : null,
        trailing: trailing,
      ),
    );
  }

  Widget _buildRadioItem({
    required String title,
    String? subTitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        title: Text(title),
        subtitle: subTitle != null ? Text(subTitle) : null,
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? Theme.of(context).primaryColor : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTimeItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        title: Text(title),
        contentPadding: const EdgeInsets.only(left: 32),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBrightnessSlider(DeviceAovLightSetController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${TR.current.Bright} (${controller.brightness}%)',
            style: const TextStyle(fontSize: 16),
          ),
          Slider(
            min: 1,
            max: 100,
            value: controller.brightness.toDouble().clamp(1, 100),
            onChanged: (value) {
              controller.setBrightness(value.toInt());
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1%', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('100%', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensitivitySlider(DeviceAovLightSetController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${TR.current.Intelligent_sensitivity} (${controller.softLedThrDisplay(controller.softLedThr)})',
            style: const TextStyle(fontSize: 16),
          ),
          Slider(
            min: 1,
            max: 5,
            divisions: 4,
            value: controller.softLedThr.toDouble().clamp(1, 5),
            onChanged: (value) {
              controller.setSoftLedThr(value.toInt());
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(controller.softLedThrDisplay(1),
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(controller.softLedThrDisplay(5),
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  void _showTimePicker({
    required int initialHour,
    required int initialMinute,
    required void Function(int hour, int minute) onSelect,
  }) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    ).then((selectedTime) {
      if (selectedTime != null) {
        onSelect(selectedTime.hour, selectedTime.minute);
      }
    });
  }
}
