import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

///电量/信号曲线图组件
// ignore: must_be_immutable
class CustomChart extends StatefulWidget {
  final double maxX;
  final double maxY;
  final double xInterval;
  final double yInterval;

  final List<FlSpot> spots;

  int? initalShowSpotIndex;

  final bool canTouch;
  final bool showDot;
  final bool showGradient;
  final Color lineColor;

  String Function(double value, TitleMeta meta)? xTitleBuilder;
  String Function(double value, TitleMeta meta)? yTitleBuilder;

  CustomChart({
    super.key,
    required this.maxX,
    required this.maxY,
    required this.xInterval,
    required this.yInterval,
    required this.spots,
    this.initalShowSpotIndex,
    this.canTouch = true,
    this.showDot = true,
    this.showGradient = true,
    this.lineColor = Colors.green,
    this.xTitleBuilder,
    this.yTitleBuilder,
  });

  @override
  State<CustomChart> createState() => _CustomChartState();
}

class _CustomChartState extends State<CustomChart> {
  double get disPlayMaxY => widget.maxY + widget.yInterval * 0.1;

  @override
  Widget build(BuildContext context) {
    //fl_chart 0.69.0 在 spots 无有效点时，内部 late 字段
    //（mostLeftSpot 等）不会初始化，绘制时会抛 LateInitializationError，
    //因此无数据时不渲染图表
    final bool hasValidSpots =
        widget.spots.any((spot) => spot != FlSpot.nullSpot);
    if (!hasValidSpots) {
      return const SizedBox.shrink();
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: LineChart(lineChartData()),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var text = value.toString();
    if (widget.xTitleBuilder != null) {
      text = widget.xTitleBuilder!(value, meta);
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 10,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    var text = value.toString();
    if (value == disPlayMaxY) {
      text = '';
    } else if (widget.yTitleBuilder != null) {
      text = widget.yTitleBuilder!(value, meta);
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 10,
          color: Colors.black54,
        ),
      ),
    );
  }

  LineTouchData lineTouchData() {
    return LineTouchData(
      handleBuiltInTouches: false,
      touchSpotThreshold: 20,
      touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
        if (response == null || response.lineBarSpots == null) {
          return;
        }
        if (event is FlTapUpEvent) {
          final spotIndex = response.lineBarSpots!.first.spotIndex;
          setState(() {
            widget.initalShowSpotIndex = spotIndex;
          });
        }
      },
      mouseCursorResolver: (FlTouchEvent event, LineTouchResponse? response) {
        if (response == null || response.lineBarSpots == null) {
          return SystemMouseCursors.basic;
        }
        if (event is FlPanUpdateEvent) {
          final spotIndex = response.lineBarSpots!.first.spotIndex;
          setState(() {
            widget.initalShowSpotIndex = spotIndex;
          });
        }
        return SystemMouseCursors.move;
      },
      getTouchedSpotIndicator:
          (LineChartBarData barData, List<int> spotIndexes) {
        return spotIndexes.map((index) {
          return TouchedSpotIndicatorData(
            const FlLine(
              color: Color(0xFFFF0000),
              strokeWidth: 0.5,
            ),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 3,
                color: const Color(0xFFFF0000),
                strokeWidth: 0,
              ),
            ),
          );
        }).toList();
      },
      touchTooltipData: LineTouchTooltipData(
        tooltipRoundedRadius: 7,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
          return lineBarsSpot.map((lineBarSpot) {
            return LineTooltipItem(
              '${lineBarSpot.y.toInt()}',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 10,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  LineChartBarData lineChartBarData() {
    return LineChartBarData(
      showingIndicators: widget.initalShowSpotIndex != null
          ? [widget.initalShowSpotIndex!]
          : [],
      isCurved: true,
      curveSmoothness: 0.05,
      color: widget.lineColor,
      preventCurveOverShooting: true,
      barWidth: 1,
      dotData: FlDotData(
        show: widget.showDot,
        getDotPainter: (p0, p1, p2, p3) {
          return FlDotCirclePainter(color: widget.lineColor, radius: 2);
        },
        checkToShowDot: (spot, barData) {
          return spot.y > 0;
        },
      ),
      belowBarData: BarAreaData(
          show: widget.showGradient,
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.lineColor.withOpacity(0.2),
                Colors.transparent
              ])),
      spots: widget.spots,
    );
  }

  LineChartData lineChartData() {
    return LineChartData(
      lineTouchData: widget.canTouch
          ? lineTouchData()
          : const LineTouchData(enabled: false),
      showingTooltipIndicators: [
        ShowingTooltipIndicators(widget.initalShowSpotIndex != null
            ? [
                LineBarSpot(lineChartBarData(), 0,
                    widget.spots[widget.initalShowSpotIndex!])
              ]
            : [])
      ],
      gridData: FlGridData(
        show: true,
        horizontalInterval: widget.yInterval,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
              dashArray: [2, 2], strokeWidth: 0.5, color: Colors.black54);
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            getTitlesWidget: leftTitleWidgets,
            showTitles: true,
            interval: widget.yInterval,
            reservedSize: 36,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: widget.xInterval,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade600, width: 0.5),
          left: BorderSide(color: Colors.grey.shade600, width: 0.5),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      ),
      lineBarsData: [
        lineChartBarData(),
      ],
      minX: 0,
      minY: 0,
      maxX: widget.maxX,
      maxY: disPlayMaxY,
    );
  }
}
