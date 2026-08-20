import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/add_device/add_device_fill_device_name_page.dart';
import 'package:fcloudsdk_example/pages/add_device/models/add_device_center.dart';
import 'package:fcloudsdk_example/pages/add_device/reset_device_random_loginName_password_page.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

class DeviceScanQrPage extends StatefulWidget {
  final Function(String deviceId, int deviceType) onCompletion;
  const DeviceScanQrPage({Key? key, required this.onCompletion})
      : super(key: key);

  @override
  State<DeviceScanQrPage> createState() => _DeviceScanQrPageState();
}

class _DeviceScanQrPageState extends State<DeviceScanQrPage>
    with TickerProviderStateMixin {
  final TextEditingController _wifiNameTextEditingController =
      TextEditingController();
  final TextEditingController _wifiPwdTextEditingController =
      TextEditingController();

  bool _isShowQrCode = false;
  String _qrCodeStr = '';
  String _bRandomCodeStr = '';
  Timer? _timer;
  bool _isGotData = false;

  @override
  void initState() {
    super.initState();

    JFApi.xcNet.xcWifiGetSSID().then((value) {
      setState(() {
        _wifiNameTextEditingController.text = value;
      });
    });
  }

  _onGenQrCode() async {
    if (_wifiPwdTextEditingController.text.isEmpty ||
        _wifiNameTextEditingController.text.isEmpty) {
      KToast.show(status: '请填写wifi信息');
      return;
    }
    final ssid = _wifiNameTextEditingController.text;
    final pwd = _wifiPwdTextEditingController.text;
    const mac = '020000000000';
    String ip = await JFApi.xcNet.xcGetPhoneIp();
    if (ip.isEmpty) {
      ip = '0.0.0.0';
    }
    final lastIpC = ip.split('.').last;

    ///生成长度为10的随机码
    _bRandomCodeStr = _onGenRandomCode(length: 10);
    final codeStr =
        'S:$ssid\nP:$pwd\nE:1\nM:$mac\nI:$lastIpC\nB:$_bRandomCodeStr\n';
    setState(() {
      _isShowQrCode = true;
      _qrCodeStr = codeStr;
    });
    if (kDebugMode) {
      print('codeStr:$codeStr');
    }

    ///开时循环检测是否配网完成
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      _checkTheDeviceIsConnect();
    });
  }

  ///生成自定义长度的随机吗
  String _onGenRandomCode({required int length}) {
    String characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    List<String> codeList = List.generate(
        length, (index) => characters[random.nextInt(characters.length)]);
    return codeList.join('');
  }

  ///检查是否配置完成
  _checkTheDeviceIsConnect() async {
    if (_isShowQrCode == false) {
      return;
    }
    if (_isGotData) {
      return;
    }
    int timeSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    String url =
        'https://pairing.xmcsrv.net/api/query?B=$_bRandomCodeStr&T=$timeSeconds';
    if (Platform.isIOS) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appVersion = packageInfo.version;
      url += '&os=iOS&v=$appVersion';
    }
    // 进行转译
    String encodedUrl = Uri.encodeFull(url);
    // 发送GET请求
    http.Response response = await http.get(Uri.parse(encodedUrl));
    //这里也要加上判断，不然会进来多次
    if (_isGotData) {
      return;
    }
    // 处理响应
    if (response.statusCode == 200) {
      // 请求成功
      String responseBody = response.body;
      if (kDebugMode) {
        print('response:$responseBody');
      }
      Map<String, dynamic> map = jsonDecode(responseBody);
      if (map.containsKey('msg')) {
        String? msg = map['msg'];
        if (msg != null && msg == 'Success') {
          if (kDebugMode) {
            print('数据返回成功');
          }
          String serialNumber = map['serialNumber'];
          _isGotData = true;
          if (_timer != null) {
            _timer!.cancel();
          }
          // Navigator.of(context!).pop();
          // widget.onCompletion(serialNumber,deviceType);
          _addDeviceWithConfigRandomDeviceLoginNameAndPassword(serialNumber);
        }
      }
    } else {
      // 请求失败
      if (kDebugMode) {
        print('请求失败，错误码：${response.statusCode}');
      }
    }
  }

  ///添加设备-配置随机用户名密码
  ///检查设备是否支持自动修改随机用户名和密码
  _addDeviceWithConfigRandomDeviceLoginNameAndPassword(String deviceId) async {
    KToast.show();
    DeviceAddModel model = DeviceAddModel();
    model.deviceId = deviceId;
    model.addDeviceType = AddDeviceType.deviceScanCode;
    DeviceAddCenter.instance
        .addDeviceWithConfigRandomDeviceLoginNameAndPasswordProgress(
            model: model,
            onComplete: (DeviceAddModel deviceAddModel) {
              KToast.dismiss();
              if (deviceAddModel.isNeedRestart) {
                KToast.show(status: '请重启设备再连接');
                return;
              }

              if (deviceAddModel.isSupportRandom &&
                  deviceAddModel.isSupportAutoChangeRandom == false &&
                  deviceAddModel.isSupportToken == false) {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return ResetDeviceRandomLoginNameAndPasswordPage(
                      model: model);
                }));
                return;
              }
              //配置绑定关系
              _addDeviceWithConfigBind(model);
            });
  }

  ///添加设备-配置绑定关系
  _addDeviceWithConfigBind(DeviceAddModel model) {
    KToast.show();
    DeviceAddCenter.instance.addDeviceWithConfigDeviceBindProgress(
        model: model,
        onComplete: (DeviceAddModel pModel) {
          KToast.dismiss();

          ///去设备设备名称
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            DeviceAddModel model = DeviceAddModel();
            return AddDeviceFillDeviceNamePage(
              model: model,
            );
          }));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('二维码配网'),
        actions: [
          ElevatedButton(
              onPressed: () async {
                _addDeviceWithConfigRandomDeviceLoginNameAndPassword(
                    '0e84af23427f9c7c');
              },
              child: const Icon(Icons.dangerous)),
        ],
      ),
      body: _isShowQrCode
          ? Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                if (_qrCodeStr.isNotEmpty)
                  //QR_Byte_Mode格式的二维码
                  QrImageView(
                    data: _qrCodeStr,
                    version: QrVersions.auto,
                    size: MediaQuery.of(context).size.width - 30,
                  ),
                const Text(
                    '①请将二维码朝向设备镜头\n②保持25-35公分的距离,等待扫描;\n③听到正在配置Wi-Fi提示音后移开手机;\n④听到配置成功提示音表示设备Wi-Fi配置已完成'),
                const Spacer(),
                InkWell(
                  onTap: () {
                    setState(() {
                      _qrCodeStr = '';
                      _isShowQrCode = false;
                      _isGotData = false;
                      if (_timer != null) {
                        _timer!.cancel();
                      }
                    });
                  },
                  child: Container(
                    height: 42.0,
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Text(
                      '取消',
                      style: TextStyle(color: Colors.white, fontSize: 22.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom
                      : 20,
                )
              ],
            )
          : Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: TextField(
                    enabled: false,
                    controller: _wifiNameTextEditingController,
                    decoration: InputDecoration(
                        prefix: const Text(
                          'wifi name: ',
                          style: TextStyle(color: Colors.blue, fontSize: 20),
                        ),
                        hintText: TR.current.wifiPwdHint),
                    focusNode: FocusNode(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: TextField(
                    controller: _wifiPwdTextEditingController,
                    decoration: InputDecoration(
                        prefix: const Text(
                          'wifi pwd: ',
                          style: TextStyle(color: Colors.blue, fontSize: 20),
                        ),
                        hintText: TR.current.wifiPwdHint),
                    focusNode: FocusNode(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    _onGenQrCode();
                  },
                  child: Container(
                    height: 42.0,
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Text(
                      '生成二维码',
                      style: TextStyle(color: Colors.white, fontSize: 22.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom
                      : 20,
                )
              ],
            ),
    );
  }

  @override
  void dispose() {
    _wifiNameTextEditingController.dispose();
    _wifiPwdTextEditingController.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }
}
