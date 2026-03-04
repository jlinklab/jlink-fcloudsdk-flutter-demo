import 'package:flutter/material.dart';

class XSingleSelector extends StatefulWidget {
  static show({
    required BuildContext context,
    required String title,
    required List<String> dataList,
    required Function(int index) onSelect,
    int? curIndex,
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
          );
        });
  }

  final String title;
  final List<String> dataList;
  final Function(int index) onSelect;
  int? curIndex;

  XSingleSelector(
      {Key? key,
      required this.title,
      required this.dataList,
      required this.onSelect,
      this.curIndex})
      : super(key: key);

  @override
  State<XSingleSelector> createState() => _XSingleSelectorState();
}

class _XSingleSelectorState extends State<XSingleSelector> {
  int _currentIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
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
      height: 200 + MediaQuery.of(context).padding.bottom,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
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
                          minHeight: 40,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(widget.dataList[index],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  softWrap: true, // 允许自动换行
                                  maxLines: 99, // 设置最大行数为2
                                  overflow: TextOverflow.ellipsis),
                            ),
                            SizedBox(
                              width: 30,
                              child: Visibility(
                                  visible: index == _currentIndex,
                                  child: const Icon(
                                    Icons.check,
                                    size: 30,
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
                return const SizedBox();
              },
              itemCount: widget.dataList.length,
            ),
          ),
          // SizedBox(
          //   height: MediaQuery.of(context).padding.bottom,
          // )
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
    // TODO: implement dispose
    super.dispose();
  }
}
