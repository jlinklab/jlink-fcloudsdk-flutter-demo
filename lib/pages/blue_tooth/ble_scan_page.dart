// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/add_device/models/scanned_device.dart';
import 'package:fcloudsdk_example/pages/blue_tooth/ble_active_page.dart';
import 'package:fcloudsdk_example/pages/blue_tooth/ble_pair_config_page.dart';
import 'package:fcloudsdk_example/pages/blue_tooth/ble_wifi_info_input_page.dart';
import 'package:fcloudsdk_example/pages/blue_tooth/controller/main_ble_pair_config_controller.dart';
import 'package:fcloudsdk_example/pages/blue_tooth/controller/main_ble_scan_controller.dart';

class BleScanPage extends StatefulWidget {
  const BleScanPage({Key? key}) : super(key: key);

  @override
  State<BleScanPage> createState() => _BleScanPageState();
}

class _BleScanPageState extends State<BleScanPage>
    with SingleTickerProviderStateMixin {
  bool isScanning = true;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MainBleScanController(context: context),
        builder: (context, child) {
          return Consumer<MainBleScanController>(
              builder: (context, controller, child) {
            return Scaffold(
              appBar: AppBar(
                title: Text(TR.current.bluetooth),
              ),
              body: controller.scannedBleDeviceList.isEmpty
                  ? Center(
                      child: controller.isScanning()
                          ? RotationTransition(
                              turns: _animation,
                              child: const SizedBox(
                                width: 100,
                                height: 100,
                                child: Icon(Icons.refresh, color: Colors.blue),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                controller.start();
                              },
                              child: Text(TR.current.restartScan)),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        ScannedDevice device =
                            controller.scannedBleDeviceList[index];
                        return GestureDetector(
                          onTap: () => _onTapDevice(context, device),
                          child: ListTile(
                            title: Text(device.onGetDeviceName()),
                          ),
                        );
                      },
                      itemCount: controller.scannedBleDeviceList.length,
                    ),
            );
          });
        });
  }

  ///点击扫描到的蓝牙设备分流
  ///支持蓝牙配对的门锁设备（version==4/5）走蓝牙配对+配网流程，其余走普通蓝牙配网
  void _onTapDevice(BuildContext context, ScannedDevice device) async {
    if (device.supportBlePair()) {
      _startBlePairFlow(context, device);
      return;
    }

    final result =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return BleWifiInfoInputPage(mac: device.bleDevice!.uuid);
    }));
    if (result != null) {
      Navigator.of(context).pop(result);
    }
  }

  ///门锁蓝牙配对+配网流程入口
  ///激活页（激活+昵称+添加服务器）→ 配网页（门锁初始化/等待锁端重置/真/假配网）
  void _startBlePairFlow(BuildContext context, ScannedDevice device) async {
    final args = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
      return BleActivePage(bleDevice: device.bleDevice!);
    }));
    if (args == null || args is! BlePairConfigArgs) {
      return;
    }

    ///配网完成 pop(true) 回传
    final result =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return BlePairConfigPage(args: args);
    }));
    if (result != null) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
