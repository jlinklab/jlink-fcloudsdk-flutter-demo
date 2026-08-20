import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/models/user_instance.dart';

///设备配置接口
class DevConfigPage extends StatefulWidget {
  const DevConfigPage({Key? key, required this.devId, required this.devName})
      : super(key: key);

  final String devId;
  final String devName;

  @override
  State<DevConfigPage> createState() => _DevConfigPageState();
}

class _DevConfigPageState extends State<DevConfigPage> {
  final _controller = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设备 ${widget.devName} 配置详情'),
      ),
      body: PageView(
        controller: _controller,
        children: [
          ConfigPage(
              devId: widget.devId,
              channelNo: -1,
              function: 'SystemFunction',
              functionCode: 1360),
          ConfigPage(
              devId: widget.devId,
              channelNo: -1,
              function: 'SystemInfo',
              functionCode: 1020),
          ConfigPage(
              devId: widget.devId,
              channelNo: 1,
              function: 'SystemFunction',
              functionCode: 1360),
          ConfigPage(
              devId: widget.devId,
              channelNo: 0,
              function: 'SystemInfo',
              functionCode: 1020),
        ],
      ),
    );
  }
}

class ConfigPage extends StatefulWidget {
  const ConfigPage(
      {Key? key,
      required this.devId,
      required this.channelNo,
      required this.function,
      required this.functionCode})
      : super(key: key);

  final String devId;
  final int channelNo;
  final String function;
  final int functionCode;

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage>
    with AutomaticKeepAliveClientMixin {
  Future<String> getDevSysConfig() async {
    Map<String, dynamic> devInfo =
        UserInfo.instance.getDeviceNameAndPwd(widget.devId);

    await JFApi.xcDevice.xcSetLocalUserNameAndPwd(
        deviceId: widget.devId, userName: devInfo['name'], pwd: devInfo['pwd']);
    final result = JFApi.xcDevice.xcDevGetSysConfig(
        deviceId: widget.devId,
        commandName: widget.function,
        command: widget.functionCode);
    return json.encode(result);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: Text(
              '${widget.channelNo} ${widget.function} ${widget.functionCode}'),
        ),
        Expanded(
            child: FutureBuilder<String>(
          future: getDevSysConfig(),
          builder: (context, data) {
            if (data.hasError) {
              return Center(
                child: Text((data.error as FlutterError).message),
              );
            }
            if (!data.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(data.requireData),
              ),
            );
          },
        ))
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
