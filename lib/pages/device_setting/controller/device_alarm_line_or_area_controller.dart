import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/manager/device_config_manager.dart';
import 'package:fcloudsdk/media/media_player.dart';

import '../../../common/code_prase.dart';
import '../../../generated/l10n.dart';
import '../../../views/toast/toast.dart';
import '../../device_ability/device_ability_manager.dart';

/// 画线画点的比例尺
const _kDrawScale = 8192.0;

class DeviceAlarmLineOrAreaController extends ChangeNotifier {
  final int pedRuleIndex;
  final BuildContext context;

  DeviceAlarmLineOrAreaController({
    required this.deviceId,
    required this.alarmType,
    required this.pedRuleIndex,
    required this.context,
    this.ruleLimitName = DeviceJsonName.humanRuleLimit,
    this.detectName = DeviceJsonName.humanDetection,
    this.requirePeaAbility = true,
  }) {
    _init();
  }

  /// 0:警戒线 1：警戒区域
  final String alarmType;
  final String ruleLimitName;
  final String detectName;
  final bool requirePeaAbility;

  final String deviceId;
  int channel = 0;

  // 画布宽高
  double? canvasWidth;
  double? canvasHeight;
  int curType = 0;
  List<AlarmLineOrShapeModel> dataList = [];

  late final PreviewMediaController mediaController;

  final Map<int, AlarmLineOrShapeModel> _mapShapeType = {
    2: AlarmLineOrShapeModel(
        title: TR.current.smart_analyze_shape_triangle,
        icon: Icons.change_history,
        type: 2),
    3: AlarmLineOrShapeModel(
        title: TR.current.smart_analyze_shape_rectangle,
        icon: Icons.rectangle_outlined,
        type: 3),
    4: AlarmLineOrShapeModel(
        title: TR.current.smart_analyze_shape_pentagram,
        icon: Icons.star,
        type: 4),
    5: AlarmLineOrShapeModel(
        title: TR.current.smart_analyze_shape_l_sel,
        icon: Icons.square_foot,
        type: 5),
    6: AlarmLineOrShapeModel(
        title: TR.current.smart_analyze_shape_concave,
        icon: Icons.square_outlined,
        type: 6),
  };

  final List<AlarmLineOrShapeModel> _mapLineType = [
    AlarmLineOrShapeModel(
      title: TR.current.smart_analyze_line_left,
      icon: Icons.arrow_downward,
      type: 0,
    ),
    AlarmLineOrShapeModel(
        title: TR.current.smart_analyze_line_right,
        icon: Icons.arrow_upward,
        type: 1),
    AlarmLineOrShapeModel(
        title: TR.current.smart_analyze_line_middle,
        icon: Icons.swap_vert,
        type: 2),
  ];

  /// 操作步骤
  List<String> operationHistory = [];
  String? lastTimeOpStr;
  String? firstTimeStr;

  /// 警戒线
  LineStep? currentLineStep;

  /// 警戒区
  AreaStep? currentAreaStep;

  void _init() {
    mediaController = PreviewMediaController(
      deviceId: deviceId,
      channel: channel,
      streamType: StreamType.hd,
    );
    mediaController.addStatusListener((status) {
      if (mounted) {
        notifyListeners();
      }
    });
    mediaController.addErrorListener((code) {
      KToast.show(status: kErrorMsg(code));
    });
    if (alarmType == '0') {
      dataList = [];
    } else {
      dataList = [];
    }
  }

  bool get mounted => context.mounted;

  void startPreview() {
    mediaController.startPreview();
  }

  void setCanvasSize(double width, double height) {
    if (canvasWidth == null && canvasHeight == null) {
      canvasWidth = width;
      canvasHeight = height;

      /// 拿到画布宽高后再开始请求数据
      /// 延迟到帧完成后执行，避免在 build 阶段调用 KToast 导致静默中断
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        KToast.show();
        await _queryConfigHumanRuleLimit();
        await _queryConfigHumanDetect();
        KToast.dismiss();
      });
    }
  }

  /// 选择不同的方向 或者 形状
  void onSelectType(int type) {
    curType = type;
    if (alarmType == '0') {
      // 警戒线
      if (currentLineStep == null) {
        return;
      }
      LineStep lineStep = LineStep(
          alarmDirect: type,
          offsetStart: Offset(canvasWidth! * 0.8, canvasHeight! * 0.2),
          offsetEnd: Offset(canvasWidth! * 0.2, canvasHeight! * 0.8));
      onUpdateStepLine(lineStep);
      onSaveOperationStep(lineStep.toStr());
    } else if (alarmType == '1') {
      // 警戒区域
      late AreaStep tempAreaStep;
      if (type == 2) {
        // 三角形
        tempAreaStep = AreaStep(
            alarmDirect: currentAreaStep!.alarmDirect,
            pts: _convertOffsets([
              [4096, 2816],
              [2560, 5632],
              [5632, 5632],
            ]));
      } else if (type == 3) {
        // 矩形
        tempAreaStep = AreaStep(
            alarmDirect: currentAreaStep!.alarmDirect,
            pts: _convertOffsets([
              [2816, 3328],
              [5376, 3328],
              [5376, 4864],
              [2816, 4864],
            ]));
      } else if (type == 4) {
        // 5边型
        tempAreaStep = AreaStep(
            alarmDirect: currentAreaStep!.alarmDirect,
            pts: _convertOffsets([
              [2560, 3712],
              [4096, 2560],
              [5632, 3712],
              [5248, 5248],
              [2944, 5248],
            ]));
      } else if (type == 5) {
        // L型
        tempAreaStep = AreaStep(
            alarmDirect: currentAreaStep!.alarmDirect,
            pts: _convertOffsets([
              [2560, 2560],
              [3328, 2560],
              [3328, 4864],
              [5632, 4864],
              [5632, 5632],
              [2560, 5632],
            ]));
      } else if (type == 6) {
        // 凹型
        tempAreaStep = AreaStep(
            alarmDirect: currentAreaStep!.alarmDirect,
            pts: _convertOffsets([
              [2816, 2816],
              [5376, 2816],
              [5376, 3584],
              [4096, 3584],
              [4096, 4608],
              [5376, 4608],
              [5376, 5376],
              [2816, 5376],
            ]));
      }

      onUpdateStepArea(tempAreaStep);
      onSaveOperationStep(tempAreaStep.toStr());
    } else {
      // 未知形状类型，不处理
      return;
    }
    notifyListeners();
  }

  void onUpdateStepLine(LineStep lineStep) {
    currentLineStep = lineStep;
    notifyListeners();
  }

  void onUpdateStepArea(AreaStep areaStep) {
    currentAreaStep = areaStep;
    notifyListeners();
  }

  /// 保存操作步骤
  void onSaveOperationStep(String stepStr) {
    if (lastTimeOpStr != null) {
      operationHistory.add(lastTimeOpStr!);
    } else {
      operationHistory.add(firstTimeStr!);
    }
    lastTimeOpStr = stepStr;
  }

  /// 复原
  void onOperationReduction() {
    if (firstTimeStr == null) return;
    operationHistory.clear();
    lastTimeOpStr = null;
    if (alarmType == '0') {
      onUpdateStepLine(LineStep.from(firstTimeStr!));
    } else if (alarmType == '1') {
      onUpdateStepArea(AreaStep.from(firstTimeStr!));
    }
  }

  /// 撤销
  void onOperationRevoke() {
    if (operationHistory.isEmpty) return;
    String stepStr = operationHistory.removeLast();
    if (operationHistory.isEmpty) {
      lastTimeOpStr = null; // 没有了需要置空
    }
    if (alarmType == '0') {
      onUpdateStepLine(LineStep.from(stepStr));
    } else if (alarmType == '1') {
      onUpdateStepArea(AreaStep.from(stepStr));
    }
  }

  /// 完成==> 保存
  void onSave() {
    if (_mapHumanDetect == null) return;
    if (alarmType == '0' && currentLineStep == null) return;
    if (alarmType == '1' && currentAreaStep == null) return;
    // 警戒线
    Map tempMap = Map.from(_mapHumanDetect!);
    final List pedRuleList = tempMap['PedRule']!;

    Map mapPedRule0 = pedRuleList[pedRuleIndex];
    if (alarmType == '0') {
      mapPedRule0['RuleType'] = 0;
      // 要设置成警戒线
      Map mapPts = mapPedRule0['RuleLine']['Pts'];
      // 方向
      mapPedRule0['RuleLine']['AlarmDirect'] = currentLineStep!.alarmDirect;
      // 位置
      mapPts['StartX'] =
          (currentLineStep!.offsetStart.dx / canvasWidth! * _kDrawScale)
              .toInt();
      mapPts['StartY'] =
          (currentLineStep!.offsetStart.dy / canvasHeight! * _kDrawScale)
              .toInt();
      mapPts['StopX'] =
          (currentLineStep!.offsetEnd.dx / canvasWidth! * _kDrawScale).toInt();
      mapPts['StopY'] =
          (currentLineStep!.offsetEnd.dy / canvasHeight! * _kDrawScale)
              .toInt();
      // 保存
      _onSetConfigMoveDetect(requestMap: tempMap, bShowLoading: true);
    } else if (alarmType == '1') {
      // 警戒区域
      // 判断围成封闭图案的几个点是否有交叉
      if (_isHasCrossing(currentAreaStep!.pts)) {
        KToast.show(
            status: TR.current.tr_settings_alarm_alert_have_intersection);
        return;
      }
      mapPedRule0['RuleType'] = 1;
      mapPedRule0['RuleRegion']['AlarmDirect'] = currentAreaStep!.alarmDirect;
      mapPedRule0['RuleRegion']['PtsNum'] = currentAreaStep!.pts.length;
      mapPedRule0['RuleRegion']['Pts'] = currentAreaStep!.pts
          .map((e) => {
                'X': (e.dx / canvasWidth! * _kDrawScale.toInt()).toInt(),
                'Y': (e.dy / canvasHeight! * _kDrawScale.toInt()).toInt()
              })
          .toList();
      // 保存
      _onSetConfigMoveDetect(requestMap: tempMap, bShowLoading: true);
    }
  }

  /// 是否自交
  bool _isHasCrossing(List<Offset> list) {
    int orientation(Offset p, Offset q, Offset r) {
      double val =
          (q.dy - p.dy) * (r.dx - q.dx) - (q.dx - p.dx) * (r.dy - q.dy);
      if (val == 0) return 0; // colinear
      return (val > 0) ? 1 : 2; // clock or counterclock wise
    }

    bool onSegment(Offset p, Offset q, Offset r) {
      return q.dx <= max(p.dx, r.dx) &&
          q.dx >= min(p.dx, r.dx) &&
          q.dy <= max(p.dy, r.dy) &&
          q.dy >= min(p.dy, r.dy);
    }

    bool isIntersecting(Offset p1, Offset q1, Offset p2, Offset q2) {
      int o1 = orientation(p1, q1, p2);
      int o2 = orientation(p1, q1, q2);
      int o3 = orientation(p2, q2, p1);
      int o4 = orientation(p2, q2, q1);
      if (o1 != o2 && o3 != o4) return true;
      if (o1 == 0 && onSegment(p1, p2, q1)) return true;
      if (o2 == 0 && onSegment(p1, q2, q1)) return true;
      if (o3 == 0 && onSegment(p2, p1, q2)) return true;
      if (o4 == 0 && onSegment(p2, q1, q2)) return true;
      return false;
    }

    int n = list.length;
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        if (j != i + 1 && j != (i + n - 1) % n && i != j) {
          if (isIntersecting(
              list[i], list[(i + 1) % n], list[j], list[(j + 1) % n])) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Map? _mapHumanRuleLimit;

  Future _queryConfigHumanRuleLimit({bool bShowLoading = false}) async {
    if (requirePeaAbility) {
      final bAlarmFunctionPEAInHumanPed =
          await DeviceAbilityManager.queryAbility(
              deviceId: deviceId,
              type: DeviceAbilityType.bAlarmFunctionPEAInHumanPed);
      if (bAlarmFunctionPEAInHumanPed == false) {
        return;
      }
    }
    if (bShowLoading) {
      KToast.show();
    }
    try {
      final resultMap = await JFApi.xcDevice.xcDevGetSysConfig(
          deviceId: deviceId,
          commandName: ruleLimitName,
          command: 1360,
          timeout: 20000);
      if (bShowLoading) {
        KToast.dismiss();
      }
      final ruleLimit = _unwrapNamedMap(resultMap, ruleLimitName);
      if (ruleLimit.isNotEmpty) {
        _mapHumanRuleLimit = ruleLimit;
        /// 区域形状(支持几种形状  i为2就是三边，3就是四边  以此类推)
        String dwAreaLine = _mapHumanRuleLimit!['dwAreaLine'];
        String reverseBinaryShape = _hexToReverseBinary(dwAreaLine);
        if (alarmType == '1') {
          // 进阶区域
          dataList = []; // 先置空
          for (int i = 0; i < reverseBinaryShape.length; i++) {
            // 屏蔽自定义
            if (i == 7) {
              continue;
            }
            if (reverseBinaryShape[i] == '1' && _mapShapeType.containsKey(i)) {
              dataList.add(_mapShapeType[i]!);
            }
          }
        }
        if (alarmType == '0') {
          // ///线性报警方向
          String dwLineDirect = _mapHumanRuleLimit!['dwLineDirect'];
          String reverseBinaryLine = _hexToReverseBinary(dwLineDirect);
          dataList = [];
          for (int i = 0; i < reverseBinaryLine.length; i++) {
            if (reverseBinaryLine[i] == '1' && i < _mapLineType.length) {
              dataList.add(_mapLineType[i]);
            }
          }
        }
      }
      if (bShowLoading && context.mounted) {
        notifyListeners();
      }
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      if (bShowLoading == false && context.mounted) {
        context.pop();
      }
    }
    return;
  }

  Map? _mapHumanDetect;

  Map? _mapPedRule0;

  Future _queryConfigHumanDetect({bool bShowLoading = false}) async {
    if (requirePeaAbility) {
      final bAlarmFunctionPEAInHumanPed =
          await DeviceAbilityManager.queryAbility(
              deviceId: deviceId,
              type: DeviceAbilityType.bAlarmFunctionPEAInHumanPed);
      if (bAlarmFunctionPEAInHumanPed == false) {
        return;
      }
    }
    if (bShowLoading) {
      KToast.show();
    }

    try {
      final resultMap =
          await DeviceConfigManager.getConfigToObject<Map<String, dynamic>>(
        deviceId: deviceId,
        channel: channel,
        commandName: detectName,
      );
      if (bShowLoading) {
        KToast.dismiss();
      }
      if (resultMap.isNotEmpty) {
        _mapHumanDetect = _unwrapDetectConfig(resultMap, detectName);
        final List pedRuleList = _mapHumanDetect?['PedRule'];
        _mapPedRule0 = pedRuleList[pedRuleIndex];
        if (alarmType == '0') {
          // 警戒线
          Map mapPts = _mapPedRule0!['RuleLine']['Pts'];
          int pAlarmDirect = _mapPedRule0!['RuleLine']['AlarmDirect'];
          Offset pLineStartOffset = Offset(
              mapPts['StartX'] / _kDrawScale * canvasWidth!.toInt(),
              mapPts['StartY'] / _kDrawScale * canvasHeight!.toInt());
          Offset pLineEndOffset = Offset(
              mapPts['StopX'] / _kDrawScale * canvasWidth!.toInt(),
              mapPts['StopY'] / _kDrawScale * canvasHeight!.toInt());
          currentLineStep = LineStep(
              alarmDirect: pAlarmDirect,
              offsetStart: pLineStartOffset,
              offsetEnd: pLineEndOffset);
          firstTimeStr = currentLineStep!.toStr();
          operationHistory = [];
        } else if (alarmType == '1') {
          // 警戒区域
          List mapPts = _mapPedRule0!['RuleRegion']['Pts'];
          List<Offset> tempPts = [];
          for (int i = 0; i < _mapPedRule0!['RuleRegion']['PtsNum']; i++) {
            // 这里的mapPts.length和PtsNum并不对应,以PtsNum为准
            Map subPtsMap = mapPts[i];
            tempPts.add(Offset(subPtsMap['X'] / _kDrawScale * canvasWidth!,
                subPtsMap['Y'] / _kDrawScale * canvasHeight!));
          }
          int pAlarmDirect = _mapPedRule0!['RuleRegion']['AlarmDirect'];
          currentAreaStep = AreaStep(alarmDirect: pAlarmDirect, pts: tempPts);
          firstTimeStr = currentAreaStep!.toStr();
          operationHistory = [];
        }

        /// 刷新页面
        notifyListeners();
      }
      if (bShowLoading) {
        // _configDeviceSetItemMoleList();
      }
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      if (bShowLoading == false && context.mounted) {
        context.pop();
      }
    }
    return;
  }

  Future _onSetConfigMoveDetect(
      {required Map requestMap, bool bShowLoading = false}) async {
    if (bShowLoading) {
      KToast.show();
    }
    try {
      final jsStr = jsonEncode(requestMap);

      final result = await DeviceConfigManager.setConfig(
          deviceId: deviceId,
          commandName: detectName,
          config: jsStr,
          channel: channel,
          command: 1040,
          timeout: 15000);
      if (bShowLoading) {
        KToast.dismiss();
      }
      if (result >= 0) {
        /// 返回上一级
        if (context.mounted) {
          context.pop(true);
        }
      }
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      if (bShowLoading == false && context.mounted) {
        context.pop();
      }
    }
    return;
  }

  Map<String, dynamic> _unwrapNamedMap(
      Map<dynamic, dynamic>? response, String name) {
    if (response == null) {
      return {};
    }
    final dynamic namedValue = response[name];
    if (namedValue is Map) {
      return Map<String, dynamic>.from(namedValue);
    }
    if (response['Ret'] == 100) {
      return {};
    }
    return Map<String, dynamic>.from(response);
  }

  Map<String, dynamic> _unwrapDetectConfig(
    Map<String, dynamic> response,
    String name,
  ) {
    final dynamic channelValue = response['$name.[$channel]'];
    if (channelValue is Map) {
      return Map<String, dynamic>.from(channelValue);
    }
    final dynamic listValue = response[name];
    if (listValue is List && listValue.isNotEmpty && listValue.first is Map) {
      return Map<String, dynamic>.from(listValue.first as Map);
    }
    if (listValue is Map) {
      return Map<String, dynamic>.from(listValue);
    }
    return Map<String, dynamic>.from(response);
  }

  _hexToReverseBinary(String hexString) {
    if (hexString.startsWith('0x')) {
      hexString = hexString.substring(2);
    }
    int intValue = int.parse(hexString, radix: 16);
    String p = intValue.toRadixString(2);
    return p.split('').reversed.join('');
  }

  _convertOffsets(List<List<int>> list) {
    List<Offset> offsets = [];
    for (List subList in list) {
      offsets.add(Offset(subList[0] / _kDrawScale * canvasWidth!,
          subList[1] / _kDrawScale * canvasHeight!));
    }
    return offsets;
  }

  @override
  void dispose() {
    mediaController.dispose();
    super.dispose();
  }
}

/// 画线
class LineStep {
  /// 规则线上的箭头方向，以起始点在左，结束点在右 【0: 警戒线下到上】【1: 警戒线上到下】【2: 双向】
  int alarmDirect;
  Offset offsetStart;
  Offset offsetEnd;

  LineStep(
      {required this.alarmDirect,
      required this.offsetStart,
      required this.offsetEnd});

  factory LineStep.from(String str) {
    List<String> list = str.split(' ');
    int alarmDirect = int.parse(list[0]);
    List<String> start = list[1].split('_');
    Offset pOffsetStart =
        Offset(double.parse(start[0]), double.parse(start[1]));
    List<String> end = list[2].split('_');
    Offset pOffsetEnd = Offset(double.parse(end[0]), double.parse(end[1]));
    return LineStep(
        alarmDirect: alarmDirect,
        offsetStart: pOffsetStart,
        offsetEnd: pOffsetEnd);
  }

  String toStr() {
    String ans = '';
    ans += alarmDirect.toString();
    ans += ' ${offsetStart.dx.toString()}_${offsetStart.dy.toString()}';
    ans += ' ${offsetEnd.dx.toString()}_${offsetEnd.dy.toString()}';
    return ans;
  }
}

class AreaStep {
  int alarmDirect;
  List<Offset> pts;

  AreaStep({required this.alarmDirect, required this.pts});

  factory AreaStep.from(String str) {
    List<String> list = str.split(' ');
    int alarmDirect = int.parse(list[0]);
    List<Offset> pts = [];
    for (int i = 1; i < list.length; i++) {
      List points = list[i].split('_');
      pts.add(Offset(double.parse(points[0]), double.parse(points[1])));
    }
    return AreaStep(alarmDirect: alarmDirect, pts: pts);
  }

  String toStr() {
    String ans = '';
    for (int i = 0; i < pts.length; i++) {
      if (i == 0) {
        ans += alarmDirect.toString();
      }
      Offset offset = pts[i];
      ans += ' ${offset.dx.toString()}_${offset.dy.toString()}';
    }
    return ans;
  }

  int shapeType() {
    if (pts.length == 3) {
      return 2;
    } else if (pts.length == 4) {
      return 3;
    } else if (pts.length == 5) {
      return 4;
    } else if (pts.length == 6) {
      return 5;
    } else if (pts.length == 8) {
      return 6;
    }
    return 99;
  }
}

/// 画图形对象
class AlarmLineOrShapeModel {
  String title;
  IconData icon;

  ///【0: 警戒线下到上】【1: 警戒线上到下】【2: 双向】
  int type;

  AlarmLineOrShapeModel({
    required this.title,
    required this.icon,
    required this.type,
  });
}
