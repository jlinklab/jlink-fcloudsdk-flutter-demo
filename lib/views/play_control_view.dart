import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fcloudsdk/media/controller/media_controller.dart';

typedef PlaybackCallback = void Function(bool playing);

class MediaPlayControlView extends StatefulWidget {
  const MediaPlayControlView(
      {Key? key,
      required this.orientation,
      required this.mediaController,
      required this.mediaType,
      this.playbackCallback})
      : super(key: key);

  final Orientation orientation;
  final MediaController mediaController;
  final MediaType mediaType;
  final PlaybackCallback? playbackCallback;

  @override
  State<MediaPlayControlView> createState() => _MediaPlayControlViewState();
}

class _MediaPlayControlViewState extends State<MediaPlayControlView> {
  ///是否正在展示
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    widget.mediaController.setOnTapCallback(() {
      if (_isVisible) {
        _hide();
      } else {
        _show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints boxConstraints) {
        return SizedBox(
          width: boxConstraints.maxWidth,
          height: widget.orientation == Orientation.portrait
              ? boxConstraints.maxWidth * 9 / 16
              : MediaQuery.of(context).size.height,
          child: Visibility(
            visible: true,
            child: Stack(
              children: [
                _isLandscape()
                    ? Container(
                        padding: const EdgeInsets.only(left: 16),
                        alignment: Alignment.centerLeft,
                        color: Colors.redAccent.withOpacity(0.3),
                        height: 80,
                        child: InkWell(
                          onTap: () => setScreenOrientation(),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      )
                    : const SizedBox(),
                Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => setScreenOrientation(),
                      child: Icon(
                        _isLandscape()
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    )),
                (!_isPreviewType() && _isPlaying() != null)
                    ? Positioned(
                        child: Center(
                        child: InkWell(
                          onTap: () {
                            widget.playbackCallback?.call(_isPlaying()!);
                          },
                          child: Icon(
                            _isPlaying()!
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ))
                    : const SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }

  Timer? _timer;

  void _show() {
    setState(() {
      _isVisible = true;
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 3), () {
        setState(() {
          _isVisible = false;
        });
      });
    });
  }

  void _hide() async {
    setState(() {
      _isVisible = false;
      _timer?.cancel();
    });
  }

  bool _isLandscape() {
    return widget.orientation == Orientation.landscape;
  }

  bool _isPreviewType() {
    return widget.mediaType == MediaType.preview;
  }

  bool? _isPlaying() {
    if (widget.mediaController.status == MediaStatus.paused) {
      return false;
    } else if (widget.mediaController.status == MediaStatus.playing) {
      return true;
    }
    return null;
  }

  void setScreenOrientation() {
    if (_isLandscape()) {
      //旋转到竖屏
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    } else {
      //旋转到横屏
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom]);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
