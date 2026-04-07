import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:xcloudsdk_flutter_example/generated/l10n.dart';

typedef ScanCallBack = void Function(String deviceSn);

class ScanQrPage extends StatefulWidget {
  final ScanCallBack callBack;
  const ScanQrPage({Key? key, required this.callBack}) : super(key: key);

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> with TickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? _qrController;

  late Animation<double> _animation;
  late AnimationController _controller;

  //起始之间的线性插值器 从 0.05 到 0.95 百分比。
  final Tween<double> _rotationTween = Tween(begin: 0.05, end: 0.95);

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this, //实现 TickerProviderStateMixin
      duration: const Duration(seconds: 3), //动画时间 3s
    );

    _animation = _rotationTween.animate(_controller)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.repeat();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    _controller.repeat();
    super.initState();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid || Platform.operatingSystem == 'ohos') {
      _qrController!.pauseCamera();
    } else if (Platform.isIOS) {
      _qrController!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    _qrController = controller;
    controller.scannedDataStream.listen((Barcode scanData) {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        controller.dispose();
        Navigator.of(context).pop();
        widget.callBack(scanData.code!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(TR.current.qrScan),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              );
            }),
          ),
          Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.blue, width: 1.0)),
                  child: CustomPaint(
                    painter: _LinePainter(lineMoveValue: _animation.value),
                    child: Container(),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _qrController?.dispose();
    _controller.dispose();
    super.dispose();
  }
}

class _LinePainter extends CustomPainter {
  // 百分比值，0 ~ 1，然后计算Y坐标
  final double lineMoveValue;
  _LinePainter({required this.lineMoveValue});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.blue;
    // size是widget的尺寸，即CustomPaint的尺寸
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, 1), paint);

    //修改画笔线条宽度
    paint.strokeWidth = 2;
    // 扫描线的移动值
    var lineY = size.height * lineMoveValue;
    // 10 为线条与方框之间的间距，绘制扫描线
    canvas.drawLine(
      Offset(10.0, lineY),
      Offset(size.width - 10.0, lineY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
