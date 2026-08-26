import 'dart:math';

import 'package:flutter/material.dart';

import '../controller/device_alarm_line_or_area_controller.dart';

class AlarmLineWidget extends StatefulWidget {
  final double containerWidth;
  final double containerHeight;
  final LineStep lineStep;
  final Function(LineStep lineStep) onRealTimeUpdate;
  final Function(String stepStr) onSaveLineStep;

  const AlarmLineWidget({
    Key? key,
    required this.containerWidth,
    required this.containerHeight,
    required this.lineStep,
    required this.onRealTimeUpdate,
    required this.onSaveLineStep,
  }) : super(key: key);

  @override
  State<AlarmLineWidget> createState() => _AlarmLineWidgetState();
}

class _AlarmLineWidgetState extends State<AlarmLineWidget> {
  bool isStartTouched = false;
  bool isEndTouched = false;
  final double touchRadius = 45.0; // 用于检测是否触摸到圆点的范围

  /// 只移动一端
  void _updateOneEnd(Offset delta) {
    if (isStartTouched) {
      final newStart = widget.lineStep.offsetStart + delta;
      if (isWithinBounds(newStart)) {
        LineStep lineStep = LineStep(
            alarmDirect: widget.lineStep.alarmDirect,
            offsetStart: newStart,
            offsetEnd: widget.lineStep.offsetEnd);
        widget.onRealTimeUpdate(lineStep);
      }
    } else if (isEndTouched) {
      final newEnd = widget.lineStep.offsetEnd + delta;
      if (isWithinBounds(newEnd)) {
        LineStep lineStep = LineStep(
            alarmDirect: widget.lineStep.alarmDirect,
            offsetStart: widget.lineStep.offsetStart,
            offsetEnd: newEnd);
        widget.onRealTimeUpdate(lineStep);
      }
    }
  }

  /// 整个条线一起移动
  void _updateOffsets(Offset delta) {
    final newStart = widget.lineStep.offsetStart + delta;
    final newEnd = widget.lineStep.offsetEnd + delta;

    // 如果两个端点都在容器内部，则更新端点的位置
    if (isWithinBounds(newStart) && isWithinBounds(newEnd)) {
      LineStep lineStep = LineStep(
          alarmDirect: widget.lineStep.alarmDirect,
          offsetStart: newStart,
          offsetEnd: newEnd);
      widget.onRealTimeUpdate(lineStep);
    }
  }

  /// 检查两个端点是否在容器内部,超出缩短
  bool isWithinBounds(Offset offset) {
    return offset.dx >= 0 &&
        offset.dx <= widget.containerWidth &&
        offset.dy >= 0 &&
        offset.dy <= widget.containerHeight;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        // 检查按下的位置是否接近线的某一端
        if ((details.localPosition - widget.lineStep.offsetStart).distance <
            touchRadius) {
          isStartTouched = true;
        } else if ((details.localPosition - widget.lineStep.offsetEnd)
                .distance <
            touchRadius) {
          isEndTouched = true;
        }
      },
      onPanEnd: (details) {
        // 重置触摸标志
        isStartTouched = false;
        isEndTouched = false;

        /// 保存这一步
        widget.onSaveLineStep(widget.lineStep.toStr());
      },
      onPanUpdate: (details) {
        if (isStartTouched || isEndTouched) {
          _updateOneEnd(details.delta);
        } else {
          _updateOffsets(details.delta);
        }
      },
      child: SizedBox(
        width: widget.containerWidth,
        height: widget.containerHeight,
        child: CustomPaint(
          painter: AlarmLineWidgetPainter(widget.lineStep.offsetStart,
              widget.lineStep.offsetEnd, widget.lineStep.alarmDirect),
        ),
      ),
    );
  }
}

/// 警戒线的Painter
class AlarmLineWidgetPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final int alarmDirect;

  AlarmLineWidgetPainter(this.start, this.end, this.alarmDirect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.0;

    // 画线
    canvas.drawLine(start, end, paint);

    if (alarmDirect != 2) {
      // 画起点时双向的起点也为红色
      paint.color = Colors.greenAccent;
    }
    // 在线的两端画圆
    canvas.drawCircle(start, 4.0, paint);
    canvas.drawCircle(end, 4.0, paint..color = Colors.red);

    // 在线的中间画箭头
    final midPoint = Offset(
      // 计算中间的垂直线的两个点
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );

    const arrowLength = 15.0; // 中间垂直线的长度
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final norm = sqrt(dx * dx + dy * dy); // 勾股定理
    final ux = -dy / norm;
    final uy = dx / norm;

    final midStart =
        Offset(midPoint.dx + ux * arrowLength, midPoint.dy + uy * arrowLength);
    final midEnd =
        Offset(midPoint.dx - ux * arrowLength, midPoint.dy - uy * arrowLength);

    // 画中间的垂直线
    canvas.drawLine(midStart, midEnd, paint);

    // 画箭头
    const arrowAngle = pi / 6; // 箭头角度
    final angle1 = atan2(uy, ux) - arrowAngle;
    final angle2 = atan2(uy, ux) + arrowAngle;

    final arrowPoint1Start = Offset(midStart.dx - arrowLength * cos(angle1) / 2,
        midStart.dy - arrowLength * sin(angle1) / 2);
    final arrowPoint2Start = Offset(midStart.dx - arrowLength * cos(angle2) / 2,
        midStart.dy - arrowLength * sin(angle2) / 2);

    final arrowPoint1End = Offset(midEnd.dx + arrowLength * cos(angle1) / 2,
        midEnd.dy + arrowLength * sin(angle1) / 2);
    final arrowPoint2End = Offset(midEnd.dx + arrowLength * cos(angle2) / 2,
        midEnd.dy + arrowLength * sin(angle2) / 2);
    if (alarmDirect == 0) {
      // 向下箭头 正方向
      canvas.drawLine(midEnd, arrowPoint1End, paint);
      canvas.drawLine(midEnd, arrowPoint2End, paint);
    } else if (alarmDirect == 1) {
      // 向上箭头 反方向
      canvas.drawLine(midStart, arrowPoint1Start, paint);
      canvas.drawLine(midStart, arrowPoint2Start, paint);
    } else if (alarmDirect == 2) {
      // 向上箭头
      canvas.drawLine(midStart, arrowPoint1Start, paint);
      canvas.drawLine(midStart, arrowPoint2Start, paint);
      // 向下箭头
      canvas.drawLine(midEnd, arrowPoint1End, paint);
      canvas.drawLine(midEnd, arrowPoint2End, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
