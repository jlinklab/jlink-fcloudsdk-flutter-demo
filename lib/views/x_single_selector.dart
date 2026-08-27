import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:flutter/material.dart';

import 'rf_divider.dart';

class XSingleSelector extends StatefulWidget {
  static show({
    required BuildContext context,
    required String title,
    required List<String> dataList,
    required Function(int index) onSelect,
    int? curIndex,
    Color? accentColor,
  }) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext pContext) {
          return XSingleSelector(
            title: title,
            dataList: dataList,
            onSelect: onSelect,
            curIndex: curIndex,
            accentColor: accentColor ?? const Color(0xFFFF7F38),
          );
        });
  }

  final String title;
  final List<String> dataList;
  final Function(int index) onSelect;
  final Color accentColor;
  final int? curIndex;

  const XSingleSelector(
      {Key? key,
      required this.title,
      required this.dataList,
      required this.onSelect,
      this.curIndex,
      this.accentColor = const Color(0xFFFF7F38)})
      : super(key: key);

  @override
  State<XSingleSelector> createState() => _XSingleSelectorState();
}

class _XSingleSelectorState extends State<XSingleSelector> {
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.curIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: Colors.white,
      ),
      height: 400 + MediaQuery.of(context).padding.bottom,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          // 顶部标题栏：取消 / 标题 / 确定
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    // 取消：仅关闭弹窗，不触发回调
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    TR.current.cancel,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // 确定：关闭弹窗并回调当前选中项
                    Navigator.of(context).pop();
                    widget.onSelect(_currentIndex);
                  },
                  child: Text(
                    TR.current.check,
                    style: TextStyle(
                      fontSize: 15,
                      color: widget.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (BuildContext context, index) {
                return Material(
                  color: Colors.white,
                  child: InkWell(
                    // behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                      });
                      Future.delayed(const Duration(milliseconds: 100), () {
                        pop();
                      });
                    },
                    child: Ink(
                      child: Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(
                          minHeight: 45,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(widget.dataList[index],
                                  style: const TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  softWrap: true, // 允许自动换行
                                  maxLines: 99, // 设置最大行数为2
                                  overflow: TextOverflow.ellipsis),
                            ),
                            SizedBox(
                              width: 30,
                              child: Visibility(
                                  visible: index == _currentIndex,
                                  child: Icon(
                                    Icons.check,
                                    size: 30,
                                    color: widget.accentColor,
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, index) {
                return const RFDivider(height: 0.5, color: Color(0xFFEFEFF0));
              },
              itemCount: widget.dataList.length,
            ),
          ),
        ],
      ),
    );
  }

  pop() {
    Navigator.of(context).pop();
    widget.onSelect(_currentIndex);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
