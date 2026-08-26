import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk/manager/device_config_manager.dart';

import '../../generated/l10n.dart';
import 'controller/device_alarm_line_or_area_controller.dart';
import 'widget/alarm_line_or_area_config_view.dart';

class DeviceAlarmLineOrAreaPage extends StatefulWidget {
  /// 0:警戒线 1：警戒区域
  final String alarmType;
  final String deviceId;

  final int mediaChannel;

  /// 修改的是全部数据中的哪个
  final int pedRuleIndex;
  final String ruleLimitName;
  final String detectName;
  final bool requirePeaAbility;

  const DeviceAlarmLineOrAreaPage({
    Key? key,
    required this.deviceId,
    required this.alarmType,
    this.mediaChannel = 0,
    this.pedRuleIndex = 0,
    this.ruleLimitName = DeviceJsonName.humanRuleLimit,
    this.detectName = DeviceJsonName.humanDetection,
    this.requirePeaAbility = true,
  }) : super(key: key);

  @override
  State<DeviceAlarmLineOrAreaPage> createState() =>
      _DeviceAlarmLineOrAreaPageState();
}

class _DeviceAlarmLineOrAreaPageState extends State<DeviceAlarmLineOrAreaPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceAlarmLineOrAreaController(
          context: context,
          deviceId: widget.deviceId,
          alarmType: widget.alarmType,
          pedRuleIndex: widget.pedRuleIndex,
          ruleLimitName: widget.ruleLimitName,
          detectName: widget.detectName,
          requirePeaAbility: widget.requirePeaAbility),
      builder: (context, child) {
        return Consumer<DeviceAlarmLineOrAreaController>(
          builder: (context, controller, child) {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.alarmType == '0'
                    ? TR.current.type_alert_line
                    : TR.current.type_alert_area),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              body: Column(
                children: [
                  /// 播放视图 警戒线或者警戒区域配置Widget
                  AlarmLineOrAreaConfigWidget(
                    controller: controller,
                    channel: widget.mediaChannel,
                  ),

                  /// 还原、撤销 + 警戒触发方向(+橙色的提示语)或 警戒区域形状
                  _AlarmTypeAndTipsWidget(
                    alarmType: widget.alarmType,
                    controller: controller,
                  ),
                  _AlarmLineOrShapeSelector(
                    controller: controller,
                  ),
                  const Spacer(),

                  /// 底部 完成按钮
                  _OperationToolWidget(
                    controller: controller,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// 警戒触发方向(+橙色的提示语)或 警戒区域形状 ========================
class _AlarmTypeAndTipsWidget extends StatelessWidget {
  final String alarmType;
  final DeviceAlarmLineOrAreaController controller;

  const _AlarmTypeAndTipsWidget(
      {Key? key, required this.alarmType, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(
            minHeight: 45,
          ),
          width: double.infinity,
          color: Colors.white,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 还原
              InkWell(
                onTap: () async {
                  if (controller.operationHistory.isNotEmpty) {
                    controller.onOperationReduction();
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      controller.operationHistory.isNotEmpty
                          ? Icons.restore
                          : Icons.restore_outlined,
                      size: 24,
                      color: controller.operationHistory.isNotEmpty
                          ? Colors.black87
                          : Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(TR.current.smart_analyze_restore,
                        style: TextStyle(
                            color: controller.operationHistory.isNotEmpty
                                ? Colors.black87
                                : Colors.grey,
                            fontSize: 12))
                  ],
                ),
              ),
              const SizedBox(width: 90),

              /// 撤销
              InkWell(
                onTap: () async {
                  if (controller.operationHistory.isNotEmpty) {
                    controller.onOperationRevoke();
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      controller.operationHistory.isNotEmpty
                          ? Icons.undo
                          : Icons.undo_outlined,
                      size: 24,
                      color: controller.operationHistory.isNotEmpty
                          ? Colors.black87
                          : Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(TR.current.smart_analyze_revoke,
                        style: TextStyle(
                            color: controller.operationHistory.isNotEmpty
                                ? Colors.black87
                                : Colors.grey,
                            fontSize: 12))
                  ],
                ),
              )
            ],
          ),
        ),
        Visibility(
          visible: alarmType == '0',
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              TR.current.TR_Alert_Set_Alert_Line_Tip,
              style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.normal),
              softWrap: true,
              // 允许自动换行
              maxLines: 99,
              // 设置最大行数为2
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ],
    );
  }
}
// end ========================

/// 线、形状选择器 ========================
class _AlarmLineOrShapeSelector extends StatelessWidget {
  final DeviceAlarmLineOrAreaController controller;

  const _AlarmLineOrShapeSelector({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.currentLineStep != null ||
            controller.currentAreaStep != null
        ? Padding(
            padding: const EdgeInsets.only(left: 10, top: 15),
            child: SizedBox(
                height: 100,
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    final AlarmLineOrShapeModel model =
                        controller.dataList[index];
                    bool isSelected = false;
                    if (controller.alarmType == '0') {
                      // 警戒线
                      isSelected = model.type ==
                          controller.currentLineStep!.alarmDirect;
                    } else {
                      // 警戒区域
                      int shapeType =
                          controller.currentAreaStep!.shapeType();
                      isSelected = model.type == shapeType;
                    }

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        controller.onSelectType(model.type);
                      },
                      child: Container(
                        width: 79,
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            Icon(
                              model.icon,
                              size: 46,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                            const Spacer(),
                            Text(
                              model.title,
                              style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                  fontSize: 12,
                                  height: 1),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: controller.dataList.length,
                  scrollDirection: Axis.horizontal,
                )))
        : const SizedBox();
  }
}
// end ========================

/// 底部 完成按钮 ========================
class _OperationToolWidget extends StatelessWidget {
  final DeviceAlarmLineOrAreaController controller;

  const _OperationToolWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: ElevatedButton(
        onPressed: () {
          controller.onSave();
        },
        child: Text(TR.current.Done),
      ),
    );
  }
}
// end ========================
