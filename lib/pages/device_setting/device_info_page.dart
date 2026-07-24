import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/models/user_instance.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/device_sync_time.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage(
      {Key? key, required this.deviceId, required this.channel})
      : super(key: key);

  final String deviceId;
  final int channel;

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  List<Map<String, dynamic>> dataSource = [];

  ///是否显示设备时间
  bool bShowDeviceTime = false;
  String deviceTimeStr = ''; //2023-09-13 16:19:36

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.dev),
        centerTitle: true,
      ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            Map<String, dynamic> map = dataSource[index];
            String title = map.keys.first;
            String value = map.values.first;

            if (title == '二维码') {
              return SizedBox(
                height: 200.0,
                child: Center(
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: QrImageView(
                      data: value,
                      version: QrVersions.auto,
                      size: 160.0,
                    ),
                  ),
                ),
              );
            } else {
              return GestureDetector(
                child: ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(title),
                  subtitle: Text(value),
                ),
                onTap: () async {
                  if (title == '序列号') {
                    Clipboard.setData(ClipboardData(text: value));
                    KToast.show(
                        status: '拷贝成功', duration: const Duration(seconds: 1));
                  } else if (title == '设备时间') {
                    KToast.show();
                    await DeviceSyncTime.syncTimeToDevice(
                        deviceId: widget.deviceId);
                    queryDeviceTime(widget.deviceId);
                    KToast.dismiss();
                    setState(() {});
                  }
                },
              );
            }
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              color: Colors.grey,
            );
          },
          itemCount: dataSource.length),
    );
  }

  @override
  void initState() {
    super.initState();
    getDataSource(widget.deviceId);
  }

  // '设备登录名','','发布时间','设备时区','设备时间','网络模式','产地归属码'};
  void getDataSource(String deviceId) async {
    final result = await JFApi.xcDevice.xcDevGetSysConfig(
        deviceId: deviceId, commandName: 'SystemInfo', command: 1020);

    final resultMap = await JFApi.xcDevice.xcDevGetSysConfig(
        deviceId: deviceId, commandName: 'OPTimeQuery', command: 1452);
    if (resultMap['Ret'] == 100 && resultMap['OPTimeQuery'] != null) {
      deviceTimeStr = resultMap['OPTimeQuery']!;
      if (deviceTimeStr.isNotEmpty) {
        bShowDeviceTime = true;
      }
    }
    String? name = result['Name'];
    Map systemInfoMap = result[name];

    final codeStr = await _getQrCodeInfo(systemInfoMap);

    ///二维码
    dataSource.add({'二维码': codeStr});

    ///序列号
    dataSource.add({'序列号': systemInfoMap['SerialNo']});

    ///设备登录名
    String userName =
        await JFApi.xcDevice.xcDevGetLocalUserName(deviceId: widget.deviceId);
    userName = userName.isNotEmpty ? userName : 'admin';
    dataSource.add({'设备用户名': userName});

    ///设备版本
    String? deviceVersion = systemInfoMap['HardWare'];
    if (systemInfoMap.keys.contains("DeviceModel")) {
      String deviceModel = systemInfoMap['DeviceModel'];
      if (deviceModel.isNotEmpty) {
        deviceVersion = deviceModel;
      }
    }
    dataSource.add({'设备版本': deviceVersion});

    ///软件版本
    dataSource.add({'软件版本': systemInfoMap['SoftWareVersion']});

    ///发布时间
    dataSource.add({'发布时间': systemInfoMap['BuildTime']});

    ///网络模式
    int netType =
        await JFApi.xcDevice.xcDevGetCurNetType(deviceId: widget.deviceId);
    if (netType == 0) {
      dataSource.add({'网络模式': 'IP'});
    } else if (netType == 2) {
      dataSource.add({'网络模式': 'P2P'});
    } else if (netType == 3) {
      dataSource.add({'网络模式': 'RPS'});
    } else if (netType == 4) {
      ///预留
    }

    if (bShowDeviceTime) {
      dataSource.add({'设备时间': deviceTimeStr});
    }

    setState(() {});
  }

  Future<String> _getQrCodeInfo(Map systemInfoMap) async {
    Map map = <String, dynamic>{};
    map['devId'] = systemInfoMap['SerialNo'];
    map['devType'] = 0;

    ///先给个0
    String loginName =
        await JFApi.xcDevice.xcDevGetLocalUserName(deviceId: widget.deviceId);
    map['loginName'] = loginName;
    String pwd =
        await JFApi.xcDevice.xcDevGetLocalPassword(deviceId: widget.deviceId);
    map['pwd'] = pwd;

    DateTime now = DateTime.now();
    int timestampInSeconds = now.microsecondsSinceEpoch ~/ 1000000;
    map['shareTimes'] = timestampInSeconds;

    map['permissions'] = '';
    map['userId'] = UserInfo.instance.userName;
    map['dt'] = ''; //token
    String jsonString = json.encode(map);

    final encodeStrMap =
        await JFApi.xcAccount.xcEncodeInfo(encodeStr: jsonString);
    return Future.value(encodeStrMap['key']);
    // return JFApi.xcDevice.xcDecodeDeviceInfo(jsonString);
  }

  Timer? _timer;

  Future queryDeviceTime(String deviceId) async {
    ///设备时间
    try {
      final resultMap = await JFApi.xcDevice.xcDevGetSysConfig(
          deviceId: deviceId, commandName: 'OPTimeQuery', command: 1452);
      if (resultMap['Ret'] == 100 && resultMap['OPTimeQuery'] != null) {
        deviceTimeStr = resultMap['OPTimeQuery']!;
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          DateTime date = DateTime.parse(deviceTimeStr);
          int time = (date.millisecondsSinceEpoch + 1000) ~/ 1000;
          String timeStr =
              DateTime.fromMillisecondsSinceEpoch(time * 1000).toString();

          /// 去掉时间后面的.000 --- 把时间精度从毫秒改成秒
          deviceTimeStr = timeStr.substring(0, timeStr.length - 4);
        });
      }
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }

    return Future.value();
  }
}
