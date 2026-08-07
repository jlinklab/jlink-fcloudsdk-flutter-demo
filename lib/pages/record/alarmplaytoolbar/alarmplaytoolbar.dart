import 'dart:math';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AlarmPlayToolBar extends StatefulWidget {
  AlarmPlayToolBar({
    Key? key,
    required this.videoLength,
    this.currentTime = 0,
    this.needShowVideoLength = true,
    this.onDragStart,
    this.onDragEnd,
  }) : super(key: key);

  ///视频总的长度
  double videoLength;

  ///当前时间
  double currentTime;

  bool needShowVideoLength;

  final VoidCallback? onDragStart;
  final ValueChanged<double>? onDragEnd;

  @override
  State<AlarmPlayToolBar> createState() => _AlarmPlayToolBarState();
}

class _AlarmPlayToolBarState extends State<AlarmPlayToolBar> {
  ///是否在手动拖拽
  bool dragging = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoLength <= 0) {
      return const SizedBox();
    }
    return Row(
      children: [
        Expanded(
          child: Slider(
            min: 0,
            max: max(widget.videoLength, widget.currentTime),
            value: widget.currentTime,
            onChangeStart: (_) {
              dragging = true;
              widget.onDragStart?.call();
            },
            onChangeEnd: (value) {
              dragging = false;
              widget.onDragEnd?.call(value);
            },
            onChanged: (value) {},
          ),
        ),
        Visibility(
            visible: widget.needShowVideoLength,
            child: Text('${widget.videoLength}s')),
      ],
    );
  }
}
