import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/media/controller/media_controller.dart';

class BitsWidget extends StatelessWidget {
  const BitsWidget({
    super.key,
    required this.mediaController,
    this.w = 1,
    this.sp = 1,
  });

  final MediaController mediaController;
  final double w;
  final double sp;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 5,
        left: 0,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            '${(mediaController.bits / 1024).toStringAsFixed(2)}KB/S',
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ));
  }
}
