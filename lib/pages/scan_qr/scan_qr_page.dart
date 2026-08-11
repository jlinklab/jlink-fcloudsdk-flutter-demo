import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan/scan.dart';

import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

import '../../utils/permission_utils.dart';

typedef ScanCallBack = void Function(String deviceSn);

class ScanQrPage extends StatefulWidget {
  final ScanCallBack callBack;
  const ScanQrPage({Key? key, required this.callBack}) : super(key: key);

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> with TickerProviderStateMixin {
  final MobileScannerController _qrController = MobileScannerController();
  bool _isHandled = false;

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

  /// 扫描结果处理，防止重复触发
  void _handleScanResult(String code) {
    if (_isHandled) return;
    _isHandled = true;
    _qrController.stop();
    Navigator.of(context).pop();
    widget.callBack(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(TR.current.qrScan),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              bool hasPermission = await PermissionUtils.checkPermission(
                  permission: XPermission.storage);
              if (hasPermission) {
                String? qrCode = await scanFromImage();
                if (qrCode == 'INVALID_QR') {
                  // 选了图片但没有二维码
                  KToast.show(status: 'INVALID_QR');
                  return;
                }
                Navigator.of(context).pop();
                widget.callBack(qrCode ?? '');
              }
            },
            child: Text(
              TR.current.album,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
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
                child: MobileScanner(
                  controller: _qrController,
                  onDetect: (BarcodeCapture capture) {
                    final String? code = capture.barcodes.firstOrNull?.rawValue;
                    if (code != null && code.isNotEmpty) {
                      _handleScanResult(code);
                    }
                  },
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

  Future<String?> scanFromImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // 用户选了图片
        String? result = await Scan.parse(pickedFile.path);
        HapticFeedback.vibrate();
        // result 有值 → 返回二维码内容
        // result 为 null → 图片里没有二维码，返回特殊标识
        return result ?? 'INVALID_QR';
      }
      // 用户取消 → 返回 null
    } catch (e) {
      //
    }
    return null;
  }

  @override
  void dispose() {
    _qrController.dispose();
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
