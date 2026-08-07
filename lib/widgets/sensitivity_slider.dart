import 'package:flutter/material.dart';

/// 通用灵敏度滑杆组件（独立 StatefulWidget，避免拖动时触发 ListView 重建导致手势中断）
///
/// 参数：
/// - [initialValue] 初始值（0~max）
/// - [label] 标题文本
/// - [min] 最小值，默认 0
/// - [max] 最大值，默认 10
/// - [divisions] 分段数，默认 10
/// - [onCompleted] 松手回调，返回当前整数值
class SensitivitySlider extends StatefulWidget {
  final double initialValue;
  final String label;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<int> onCompleted;

  const SensitivitySlider({
    Key? key,
    required this.initialValue,
    required this.label,
    this.min = 0,
    this.max = 10,
    this.divisions = 10,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<SensitivitySlider> createState() => _SensitivitySliderState();
}

class _SensitivitySliderState extends State<SensitivitySlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.label}  (${_value.toInt()})'),
          Slider(
            value: _value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: '${_value.toInt()}',
            onChanged: (val) {
              setState(() => _value = val);
            },
            onChangeEnd: (val) {
              widget.onCompleted(val.toInt());
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${widget.min.toInt()}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text('${widget.max.toInt()}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
