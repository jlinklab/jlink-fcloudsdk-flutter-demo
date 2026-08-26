import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';

typedef InputCallBack = void Function(int index);

class CommonItemListWidget extends StatefulWidget {
  final InputCallBack callBack;

  final List<String> dataList;

  const CommonItemListWidget(
      {Key? key, required this.dataList, required this.callBack})
      : super(key: key);

  @override
  State<CommonItemListWidget> createState() => _InputInfoWidgetState();
}

class _InputInfoWidgetState extends State<CommonItemListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(TR.current.recordQuality),
        ),
        body: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(widget.dataList[index]),
              onTap: () {
                widget.callBack(index);
                context.pop();
              },
            );
          },
          itemCount: widget.dataList.length,
        ));
  }
}
