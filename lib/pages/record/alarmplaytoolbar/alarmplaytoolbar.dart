import 'dart:math';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AlarmPlayToolBar extends StatefulWidget {
  AlarmPlayToolBar({Key? key, required this.videoLength, this.currentTime = 0})
      : super(key: key);

  ///视频总的长度
  double videoLength;

  ///当前时间
  double currentTime;

  @override
  State<AlarmPlayToolBar> createState() => _AlarmPlayToolBarState();
}

class _AlarmPlayToolBarState extends State<AlarmPlayToolBar> {
  @override
  void initState() {
    super.initState();

    if (widget.videoLength <= 0) {
      widget.videoLength = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            min: 0,
            max: max(widget.videoLength, widget.currentTime),
            value: widget.currentTime,
            onChanged: (value) {},
          ),
        ),
        Text('${widget.videoLength}s'),
      ],
    );
  }
}
