import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../common/base_const.dart';

class KToast {
  Widget? _w;
  OverlayEntry? overlayEntry;
  Widget? get w => _w;
  Timer? _timer;

  late Duration defaultDismissDuration; //is 2300毫秒

  //单例
  factory KToast() => _instance;
  static final KToast _instance = KToast._internal();
  KToast._internal() {
    defaultDismissDuration = const Duration(milliseconds: 2300);
  }

  static KToast get instance => _instance;
  //是否正在显示
  static bool get isShow => _instance.w != null;

  /// init KToast
  static TransitionBuilder init({
    TransitionBuilder? builder,
  }) {
    return (BuildContext context, Widget? child) {
      if (builder != null) {
        return builder(context, KToastView(child: child));
      } else {
        return KToastView(child: child);
      }
    };
  }

  static show({
    String? status,
    Duration? duration,
  }) {
    if (status != null && status.isNotEmpty) {
      //文本提示
      _instance._showStatus(
          status: status,
          duration: duration ?? KToast.instance.defaultDismissDuration);
    } else {
      //loading加载
      _instance._showLoading();
    }
  }

  ///一般情况用这个
  static void dismiss() {
    if (KToast.isShow) {
      KToast.instance._dissmiss();
    }
  }

  ///只有在dispose方法中调用这个
  static void dismissInDispose() {
    Future.delayed(Duration.zero).then((e) {
        KToast.dismiss();
    });
  }

  void _dissmiss() {
    _w = null;
    _cancelTimer();
    _updateWhenSafe();
  }

  //仅文案
  void _showStatus(
      {required String status, Duration? duration}) {
    Widget pW = IgnorePointer(
      child: Center(
        child: Container(
          padding: EdgeInsets.only(
              left: kScale(12),
              right: kScale(12),
              top: kScale(8),
              bottom: kScale(8)),
          constraints: BoxConstraints(
              minWidth: kScale(104),
              minHeight: kScale(40),
              maxWidth: kScale(221)),
          decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 0, 0, 0.7),
              borderRadius: BorderRadius.all(Radius.circular(kScale(4)))),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: kFont(14),
              fontWeight: FontWeight.w400,
            ),

          ),
        ),
      ),
    );
    _show(w: pW, duration: duration);
  }

  //仅圆角loading
  void _showLoading() {
    Widget pW = const IgnorePointer(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
    _show(w: pW);
  }

  void _show({
    required Widget w,
    Duration? duration,
  }) {
    assert(
    _instance.overlayEntry != null,
    'You should call KToast.init() in your MaterialApp',
    );

    _w = w;
    _updateWhenSafe();

    //延时关闭
    if (duration != null) {
      _cancelTimer();
      _timer = Timer(duration, () {
        _dissmiss();
      });
    }
  }

  //取消定时器
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  //强制刷新显示
  void _update() {
    overlayEntry?.markNeedsBuild();
  }

  ///在安全时机刷新：
  ///若在帧构建阶段（build/layout/paint）调用 markNeedsBuild 会触发断言失败，
  ///统一延迟到当前帧结束后刷新，调用方无需关心调用时机。
  void _updateWhenSafe() {
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (w != null) {
          _update();
        }
      });
    } else {
      _update();
    }
  }
}

class KToastView extends StatefulWidget {
  final Widget? child;

  const KToastView({
    Key? key,
    required this.child,
  })  : assert(child != null),
        super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _KToastViewState createState() => _KToastViewState();
}

class _KToastViewState extends State<KToastView> {
  late OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        // print('overlayEntry builder');
        return KToast.instance.w ?? Container();
      },
    );
    KToast.instance.overlayEntry = _overlayEntry;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (BuildContext context) {
              if (widget.child != null) {
                return widget.child!;
              } else {
                return Container();
              }
            },
          ),
          _overlayEntry,
        ],
      ),
    );
  }
}