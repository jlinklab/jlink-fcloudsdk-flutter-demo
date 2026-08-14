import 'dart:math';

import 'package:flutter/material.dart';

import '../controller/device_alarm_line_or_area_controller.dart';

/// 警戒区域 ========================================
class AlarmAreaWidget extends StatefulWidget {
  final double containerWidth;
  final double containerHeight;
  final AreaStep areaStep;
  final Function(AreaStep areaStep) onRealTimeUpdate;
  final Function(String stepStr) onSaveAreaStep;

  const AlarmAreaWidget(
      {Key? key,
      required this.containerWidth,
      required this.containerHeight,
      required this.areaStep,
      required this.onRealTimeUpdate,
      required this.onSaveAreaStep})
      : super(key: key);

  @override
  State<AlarmAreaWidget> createState() => _AlarmAreaWidgetState();
}

class _AlarmAreaWidgetState extends State<AlarmAreaWidget> {
  int? selectIndex; // 移动时选中的点的index
  final double touchRadius = 45.0; // 用于检测是否触摸到圆点的范围

  /// 移动整个图形
  void _updateAllShape(Offset delta) {
    for (int i = 0; i < widget.areaStep.pts.length; i++) {
      Offset newPos = widget.areaStep.pts[i] + delta;
      // 边界检查，确保点在Container内
      newPos = Offset(
        newPos.dx.clamp(0.0, widget.containerWidth),
        newPos.dy.clamp(0.0, widget.containerHeight),
      );
      widget.areaStep.pts[i] = newPos;
    }
    widget.onRealTimeUpdate(widget.areaStep);
  }

  /// 移动某个点
  void _updateSinglePoint(Offset delta) {
    Offset newPos = widget.areaStep.pts[selectIndex!] + delta;

    // 边界检查，确保点在Container内
    double minX = 10.0;
    double minY = 10.0;
    double maxX = widget.containerWidth - 10.0;
    double maxY = widget.containerHeight - 10.0;
    // 限制新位置在容器内
    double x = newPos.dx.clamp(minX, maxX);
    double y = newPos.dy.clamp(minY, maxY);

    // 更新单个点的位置
    widget.areaStep.pts[selectIndex!] = Offset(x, y);

    widget.onRealTimeUpdate(widget.areaStep);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        // 检查按下的位置是否接近某个点
        for (int i = 0; i < widget.areaStep.pts.length; i++) {
          Offset tempPoint = widget.areaStep.pts[i];
          if ((tempPoint - details.localPosition).distance < touchRadius) {
            selectIndex = i;
            break;
          }
        }
      },
      onPanUpdate: (details) {
        if (selectIndex != null) {
          _updateSinglePoint(details.delta);
        } else {
          _updateAllShape(details.delta);
        }
      },
      onPanEnd: (details) {
        /// 将选择的点置空
        selectIndex = null;

        /// 保存步骤
        widget.onSaveAreaStep(widget.areaStep.toStr());
      },
      child: SizedBox(
        width: widget.containerWidth,
        height: widget.containerHeight,
        child: CustomPaint(
          painter: ShapePainter(widget.areaStep.pts, widget.areaStep.alarmDirect),
        ),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final List<Offset> points;
  final int alarmDirect;

  ShapePainter(this.points, this.alarmDirect);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintLine = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    Paint paintFill = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1);

    Paint paintCircleFill = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    Paint paintCircleStroke = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    Paint paintArrow = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    Path path = Path()..moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    path.close();

    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintLine);

    // 在第一个点和最后一个点连线的中点画方向箭
    _drawArrow(canvas, paintArrow);

    for (var point in points) {
      canvas.drawCircle(point, 5.0, paintCircleFill);
      canvas.drawCircle(point, 6.0, paintCircleStroke);
    }
  }

  /// 在第一个点与最后一个点连线的中点画方向箭头
  void _drawArrow(Canvas canvas, Paint paint) {
    final point1 = points[0];
    final point2 = points[points.length - 1];

    // 中点
    final midPoint = Offset(
      (point1.dx + point2.dx) / 2,
      (point1.dy + point2.dy) / 2,
    );

    // 首末点方向向量
    final dx = point2.dx - point1.dx;
    final dy = point2.dy - point1.dy;
    final norm = sqrt(dx * dx + dy * dy);
    if (norm == 0) return;

    // 垂直方向（法线）
    final ux = -dy / norm;
    final uy = dx / norm;

    // 垂直线两端（长度15，与警戒线一致）
    const arrowLength = 15.0;
    final midStart = Offset(
      midPoint.dx + ux * arrowLength,
      midPoint.dy + uy * arrowLength,
    );
    final midEnd = Offset(
      midPoint.dx - ux * arrowLength,
      midPoint.dy - uy * arrowLength,
    );

    // 画中间的垂直线
    canvas.drawLine(midStart, midEnd, paint);

    // 计算箭头两翼
    const arrowAngle = pi / 6; // 箭头夹角30°
    final angle1 = atan2(uy, ux) - arrowAngle;
    final angle2 = atan2(uy, ux) + arrowAngle;

    final arrowPoint1Start = Offset(
      midStart.dx - arrowLength * cos(angle1) / 2,
      midStart.dy - arrowLength * sin(angle1) / 2,
    );
    final arrowPoint2Start = Offset(
      midStart.dx - arrowLength * cos(angle2) / 2,
      midStart.dy - arrowLength * sin(angle2) / 2,
    );
    final arrowPoint1End = Offset(
      midEnd.dx + arrowLength * cos(angle1) / 2,
      midEnd.dy + arrowLength * sin(angle1) / 2,
    );
    final arrowPoint2End = Offset(
      midEnd.dx + arrowLength * cos(angle2) / 2,
      midEnd.dy + arrowLength * sin(angle2) / 2,
    );

    // 三角形（3个点）时方向需要反转
    final bool isTriangle = points.length == 3;

    if (alarmDirect == 0) {
      // 正方向
      if (isTriangle) {
        canvas.drawLine(midStart, arrowPoint1Start, paint);
        canvas.drawLine(midStart, arrowPoint2Start, paint);
      } else {
        canvas.drawLine(midEnd, arrowPoint1End, paint);
        canvas.drawLine(midEnd, arrowPoint2End, paint);
      }
    } else if (alarmDirect == 1) {
      // 反方向
      if (isTriangle) {
        canvas.drawLine(midEnd, arrowPoint1End, paint);
        canvas.drawLine(midEnd, arrowPoint2End, paint);
      } else {
        canvas.drawLine(midStart, arrowPoint1Start, paint);
        canvas.drawLine(midStart, arrowPoint2Start, paint);
      }
    } else {
      // 双向
      canvas.drawLine(midStart, arrowPoint1Start, paint);
      canvas.drawLine(midStart, arrowPoint2Start, paint);
      canvas.drawLine(midEnd, arrowPoint1End, paint);
      canvas.drawLine(midEnd, arrowPoint2End, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
