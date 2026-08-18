import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/media/media_player.dart';

import '../../../generated/l10n.dart';
import '../controller/device_alarm_line_or_area_controller.dart';
import 'alarm_area_widget.dart';
import 'alarm_line_widget.dart';

/// 用于警戒线或者警戒区域的操作Widget
class AlarmLineOrAreaConfigWidget extends StatefulWidget {
  final DeviceAlarmLineOrAreaController controller;

  /// 窗口位置 窗口0 其实在媒体分割中对应 媒体窗口 1
  final int channel;

  const AlarmLineOrAreaConfigWidget(
      {Key? key, required this.controller, required this.channel})
      : super(key: key);

  @override
  State<AlarmLineOrAreaConfigWidget> createState() =>
      _AlarmLineOrAreaConfigWidgetState();
}

class _AlarmLineOrAreaConfigWidgetState
    extends State<AlarmLineOrAreaConfigWidget> {
  @override
  void initState() {
    widget.controller.startPreview();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        /// 播放视图
        AspectRatio(
          aspectRatio: 16 / 9,
          child: MediaPlayerWidget(
            controller: widget.controller.mediaController,
            autoDispose: false,
            key: GlobalObjectKey('alarm_preview_${widget.channel}'),
          ),
        ),

        /// Loading指示
        Visibility(
            visible: widget.controller.mediaController.isLoading,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CupertinoActivityIndicator(
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    TR.current.waiting_buffering,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            )),

        /// 警戒线、区域
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints boxConstraints) {
          final mWidth = boxConstraints.maxWidth;
          final mHeight = boxConstraints.maxWidth * 9 / 16;
          widget.controller.setCanvasSize(mWidth, mHeight);
          return Container(
            width: mWidth,
            height: mHeight,
            color: Colors.transparent,
            child: _alarmWidget(mWidth, mHeight),
          );
        }),
      ],
    );
  }

  _alarmWidget(double mWidth, double mHeight) {
    if (widget.controller.alarmType == '0' &&
        widget.controller.currentLineStep != null &&
        widget.controller.mediaController.isPlaying) {
      return AlarmLineWidget(
          containerWidth: mWidth,
          containerHeight: mHeight,
          lineStep: widget.controller.currentLineStep!,
          onRealTimeUpdate: (LineStep lineStep) {
            widget.controller.onUpdateStepLine(lineStep);
          },
          onSaveLineStep: widget.controller.onSaveOperationStep);
    } else if (widget.controller.alarmType == '1' &&
        widget.controller.currentAreaStep != null &&
        widget.controller.mediaController.isPlaying) {
      return AlarmAreaWidget(
          containerWidth: mWidth,
          containerHeight: mHeight,
          areaStep: widget.controller.currentAreaStep!,
          onRealTimeUpdate: (AreaStep areaStep) {
            widget.controller.onUpdateStepArea(areaStep);
          },
          onSaveAreaStep: widget.controller.onSaveOperationStep);
    }
    return null;
  }
}
