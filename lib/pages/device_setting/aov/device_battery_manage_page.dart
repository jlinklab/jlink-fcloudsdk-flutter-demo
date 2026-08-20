import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/aov/controller/device_battery_manage_controller.dart';
import 'package:fcloudsdk_example/pages/device_setting/aov/widget/custom_chart.dart';

///电池管理页面
class DeviceBatteryManagePage extends StatefulWidget {
  final String deviceId;

  const DeviceBatteryManagePage({super.key, required this.deviceId});

  @override
  State<DeviceBatteryManagePage> createState() =>
      _DeviceBatteryManagePageState();
}

class _DeviceBatteryManagePageState extends State<DeviceBatteryManagePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceBatteryManageController(
          deviceId: widget.deviceId, context: context),
      child: Consumer<DeviceBatteryManageController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(TR.current.TR_Setting_Battery_Management),
              centerTitle: true,
            ),
            backgroundColor: const Color(0xFFF1F4F9),
            body: SingleChildScrollView(
              // 为列表末尾预留系统导航栏安全距离，避免底部统计内容被遮挡。
              padding: EdgeInsets.only(
                left: 14.5,
                right: 14.5,
                top: 10,
                bottom: 16 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _settingSection(controller),
                  const SizedBox(height: 10),
                  _statisticSection(controller),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ///设置项区
  Widget _settingSection(DeviceBatteryManageController controller) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(7)),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(TR.current.TR_Setting_Power_Supply_Mode),
            trailing: Text(
              TR.current.TR_Setting_Battery,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(TR.current.TR_Setting_Current_Battery_Level),
            trailing: Text(
              '${controller.currentPower}%',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          if (controller.isAov) ...[
            const Divider(height: 1),
            _lowPowerModeItem(controller),
          ],
        ],
      ),
    );
  }

  ///低电量模式slider
  Widget _lowPowerModeItem(DeviceBatteryManageController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${TR.current.TR_Setting_Low_Power_Mode} (${controller.sliderValue.toInt()}%)',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            TR.current.TR_Setting_Low_Power_Mode_Description,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Slider(
            min: controller.lowElectrMin.toDouble(),
            max: controller.lowElectrMax.toDouble(),
            value: controller.sliderValue
                .clamp(controller.lowElectrMin.toDouble(),
                    controller.lowElectrMax.toDouble())
                .toDouble(),
            onChanged: controller.onSliderChanged,
            onChangeEnd: controller.onSliderChangeEnd,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${controller.lowElectrMin}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text('${controller.lowElectrMax}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  ///统计区
  Widget _statisticSection(DeviceBatteryManageController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            TR.current.TR_Setting_Battery_Statistic,
            style: const TextStyle(color: Color(0xFF848484), fontSize: 12),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
          child: Column(
            children: [
              _segmentedControl(controller),
              const SizedBox(height: 16),
              _chartView(
                controller: controller,
                title: TR.current.TR_Setting_Power_Level,
                spots: controller.showBlSpots,
                lineColor: Colors.teal,
              ),
              const SizedBox(height: 16),
              _chartView(
                controller: controller,
                title: TR.current.TR_Setting_Signal,
                spots: controller.show4GSpots,
                lineColor: Colors.blue,
              ),
              if (controller.supportLowPowerWorkTime) ...[
                _statisticCard(
                  title: TR.current.TR_Setting_Preview_Time,
                  value: controller.showPreview,
                  colors: const [Color(0xff53dce5), Color(0xff59cad2)],
                  icon: Icons.play_circle_outline,
                ),
                const SizedBox(height: 10),
                _statisticCard(
                  title: TR.current.TR_Setting_Wake_Up_Time,
                  value: controller.showWakeup,
                  colors: const [Color(0xFF69CAFF), Color(0xFF65A2FC)],
                  icon: Icons.notifications_active_outlined,
                ),
                const SizedBox(height: 10),
              ],
              _statisticCard(
                title: TR.current.TR_Setting_Number_Of_Alarms,
                value: controller.showAlarmCount,
                colors: const [Color(0xFFACABFF), Color(0xFF8B8BFD)],
                icon: Icons.warning_amber_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  ///今天/最近一周切换
  Widget _segmentedControl(DeviceBatteryManageController controller) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        return CupertinoSegmentedControl<String>(
          padding: EdgeInsets.zero,
          selectedColor: Colors.teal,
          unselectedColor: const Color(0xFFF1F4F9),
          borderColor: const Color(0xFFF1F4F9),
          children: {
            'today': Container(
              width: constraints.maxWidth / 2,
              alignment: Alignment.center,
              child: Text(
                TR.current.TR_Today,
                style: TextStyle(
                    color: controller.selectedSegmentKey == 'today'
                        ? Colors.white
                        : const Color(0xFF9B9B9B),
                    fontSize: 16),
              ),
            ),
            'weak': Container(
              width: constraints.maxWidth / 2,
              alignment: Alignment.center,
              child: Text(
                TR.current.TR_Setting_Last_Week,
                style: TextStyle(
                    color: controller.selectedSegmentKey == 'weak'
                        ? Colors.white
                        : const Color(0xFF9B9B9B),
                    fontSize: 16),
              ),
            ),
          },
          groupValue: controller.selectedSegmentKey,
          onValueChanged: (String? value) {
            controller.switchSegment(value!);
          },
        );
      }),
    );
  }

  ///曲线图
  Widget _chartView({
    required DeviceBatteryManageController controller,
    required String title,
    required List<FlSpot> spots,
    required Color lineColor,
  }) {
    return Column(
      children: [
        Row(children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xFFA5A8AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: CustomChart(
              spots: spots,
              showDot: false,
              canTouch: false,
              lineColor: lineColor,
              maxX: controller.isToday ? 24 : 7,
              maxY: 100,
              xInterval: controller.isToday ? 4 : 1,
              yInterval: 20,
              xTitleBuilder: (value, meta) {
                if (!controller.isToday) {
                  return controller.xTitleSevenDays[value.toInt()];
                }
                return '${value.toInt()}';
              },
              yTitleBuilder: (value, meta) {
                return '${value.toInt()}%';
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25, left: 15),
            child: Text(
                controller.isToday ? TR.current.sHour : TR.current.days,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 10,
                  color: Colors.black54,
                )),
          )
        ]),
      ],
    );
  }

  ///统计卡片（预览时间/唤醒时间/报警次数）
  Widget _statisticCard({
    required String title,
    required String value,
    required List<Color> colors,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 13, left: 15, bottom: 6),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Icon(icon, size: 30, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
