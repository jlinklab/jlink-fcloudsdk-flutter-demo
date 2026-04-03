// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:xcloudsdk_flutter/device/wifi_config_controller.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/add_device/add_device_fill_device_name_page.dart';
import 'package:xcloudsdk_flutter_example/pages/add_device/manager/add_device_permission_manager.dart';
import 'package:xcloudsdk_flutter_example/pages/add_device/models/add_device_center.dart';
import 'package:xcloudsdk_flutter_example/pages/add_device/reset_device_random_loginName_password_page.dart';
import 'package:xcloudsdk_flutter_example/views/animations/ripples.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

class WIFIConfigPage extends StatefulWidget {
  const WIFIConfigPage({Key? key}) : super(key: key);

  @override
  State<WIFIConfigPage> createState() => _WIFIConfigPageState();
}

class _WIFIConfigPageState extends State<WIFIConfigPage>
    with TickerProviderStateMixin {
  final TextEditingController textEditingController = TextEditingController();
  final WifiConfigController wifiConfigController = WifiConfigController();
  late final AnimationController animationController;

  String wifiName = '';
  final List<String> log = [];

  bool onTap = false;
  double size = 60.0;
  Color color = Colors.red;

  FocusNode node = FocusNode();

  @override
  void initState() {
    checkPermission();
    wifiConfigController.addListener(() {
      //log.add(wifiConfigController.value.toString());

      if (wifiConfigController.value.gettingWifiInfo) {
        log.add('正在获取WIFI信息--> ssid:${wifiConfigController.value.ssid} '
            'dhcp:${wifiConfigController.value.dhcpInfo} scan: ${wifiConfigController.value.scanResult} ');
      }

      if (wifiConfigController.value.configuring) {
        KToast.show(status: '开始配网中');
        log.add('开始配网中');
        log.add('正在配网...');
      }

      if (wifiConfigController.value.isSuccess) {
        log.add('配网成功${wifiConfigController.value.configResult}');
        KToast.show(status: '配网成功 ${wifiConfigController.value.configResult}');
        String deviceJsonData = wifiConfigController.value.configResult!;
        log.add(deviceJsonData);

        ///配网结束，开始添加设备
        _startAddDevice(deviceJsonData);
        // Future.delayed(const Duration(seconds: 1), () {
        //   Navigator.pop(context, [sn]);
        // });
      }
      if (wifiConfigController.value.errorCode != null) {
        print(wifiConfigController.value.errorCode);
        KToast.show(status: KErrorMsg(wifiConfigController.value.errorCode!));
        log.add(KErrorMsg(wifiConfigController.value.errorCode!) ?? '');
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
      setState(() {});
    });
    wifiConfigController.getSSID().then((value) {
      setState(() {
        wifiName = value;
      });
      if (value.toUpperCase().contains('5G')) {
        KToast.show(status: '5G wifi配网失败率会很高，建议切换为普通2.4G的wifi');
      }
    });

    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    // textEditingController.addListener(() {
    //   wifiConfigController.setWifiPwd(textEditingController.text);
    // });
    super.initState();
  }

  checkPermission() async {
    ///新的权限类
    await AddDevicePermissionUsecase.instance.checkOnlyWifi(onlyStatus: false);
    wifiName = await wifiConfigController.getSSID();
    setState(() {});
  }

  _startAddDevice(String deviceJsonData) {
    //{"randomUser":"","hostName":"IPC","type":24,"pid":"A908007CF000000H","deviceSn":"44b9dc1867ef3bea","randomPwd":"","resume":""}
    DeviceAddModel model = DeviceAddModel.genFromWifiDevice(deviceJsonData);

    ///添加设备-配置随机用户名密码
    ///检查设备是否支持自动修改随机用户名和密码
    KToast.show();
    DeviceAddCenter.instance
        .addDeviceWithConfigRandomDeviceLoginNameAndPasswordProgress(
            model: model,
            onComplete: (DeviceAddModel deviceAddModel) {
              KToast.dismiss();
              if (deviceAddModel.isNeedRestart) {
                KToast.show(status: '请重启设备再连接');
                log.add('请重启设备再连接');
                return;
              }

              if (deviceAddModel.isSupportRandom &&
                  deviceAddModel.isSupportAutoChangeRandom == false &&
                  deviceAddModel.isSupportToken == false) {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return ResetDeviceRandomLoginNameAndPasswordPage(
                      model: deviceAddModel);
                }));
                return;
              }
              //配置绑定关系
              _addDeviceWithConfigBind(deviceAddModel);
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
            return AddDeviceFillDeviceNamePage(
              model: pModel,
            );
          }));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.wifi),
        actions: [
          ElevatedButton(
              onPressed: () {
                // Map pMap = {"randomUser":"","hostName":"IPC","type":24,"pid":"A908007CF000000H","deviceSn":"44b9dc1867ef3bea","randomPwd":"","resume":""};

                Map pMap = {
                  "randomUser": "",
                  "hostName": "IPC",
                  "type": 7,
                  "pid": "",
                  "deviceSn": "7afe19cceeae6cdc",
                  "randomPwd": "",
                  "resume": ""
                };
                _startAddDevice(jsonEncode(pMap));
              },
              child: const Text('测试')),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Text('WIFI_NAME: $wifiName'),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(hintText: TR.current.wifiPwdHint),
              focusNode: node,
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                if (Platform.isAndroid) {
                  print('Checking Android permissions');
                  var status = await Permission.location.status;
                  // Blocked?
                  if (status.isDenied || status.isRestricted) {
                    // Ask the user to unblock
                    if (await Permission.location.request().isGranted) {
                      // Either the permission was already granted before or the user just granted it.
                      print('Location permission granted');
                    } else {
                      print('Location permission not granted');
                    }
                  } else {
                    print('Permission already granted (previous execution?)');
                  }
                }

                onTap = true;
                node.unfocus();
                wifiConfigController.setWifiPwd(textEditingController.text);
                await wifiConfigController.startWifiConfig(timeout: 120000);
              },
              child: Text(TR.current.startAdd)),
          Visibility(
            visible: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: CustomPaint(
                  painter: CirclePainter(animationController, color: color),
                  child: SizedBox(
                    width: size * 4.125,
                    height: size * 4.125,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(size),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              gradient: RadialGradient(colors: [
                            color,
                            Color.lerp(color, Colors.black, .05)!
                          ])),
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                              CurvedAnimation(
                                  parent: animationController,
                                  curve: const PulsateCurve()),
                            ),
                            child: const Icon(
                              Icons.speaker_phone,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Text(log[index]);
              },
              itemCount: log.length,
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    wifiConfigController.dispose();
    animationController.dispose();
    super.dispose();
  }
}
