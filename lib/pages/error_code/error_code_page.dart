import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';

class ErrorCodePage extends StatefulWidget {
  const ErrorCodePage({Key? key}) : super(key: key);

  @override
  State<ErrorCodePage> createState() => _ErrorCodePageState();
}

class _ErrorCodePageState extends State<ErrorCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.errorCode),
      ),
      body: const Center(
        child: Text('错误码'),
      ),
    );
  }
}
