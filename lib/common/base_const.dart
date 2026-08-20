//################  scale 尺寸
//********* 以屏幕宽度为适配基准
import 'dart:math';
import 'dart:ui';

import 'package:fcloudsdk_example/common/scale.dart';

//###############   scale 尺寸
double kScale(double px) => KScale.px(px);
final double kScreenWidth = KScale.screenW();
final double kScreenHeight = KScale.screenH();
final double kScaleOnePx = KScale.onepx();//一个像素

//###############   font 字体
double kFont(double px) => KScale.px(px);
//###############   color 颜色
/// 随机色
Color kColorRandom() => Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1.0);



