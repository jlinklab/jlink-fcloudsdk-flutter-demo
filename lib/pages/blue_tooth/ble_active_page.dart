import 'package:fcloudsdk/ble_by_sdk/ble_device.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../pages/door_lock/usecase/door_lock_helper.dart';
import 'controller/main_ble_active_controller.dart';
import 'controller/main_ble_pair_config_controller.dart';
import 'ble_pair_config_page.dart';

///门锁蓝牙激活页
class BleActivePage extends StatefulWidget {
  const BleActivePage({Key? key, required this.bleDevice}) : super(key: key);

  ///蓝牙扫描到的设备
  final BleSearchDeviceBySDK bleDevice;

  @override
  State<BleActivePage> createState() => _BleActivePageState();
}

class _BleActivePageState extends State<BleActivePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          MainBleActiveController(context: context, bleDevice: widget.bleDevice)
            ..start(),
      builder: (context, child) {
        return Consumer<MainBleActiveController>(builder: (context, controller, child) {
          ///配对结束（成功或失败）后才允许退出，退出直接回设备列表页
          var canExit = controller.isSuccess || controller.isFail;
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                return;
              }
              if (canExit) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else {
                KToast.show(status: '配对中，请稍候');
              }
            },
            child: Scaffold(
            appBar: AppBar(
              title: const Text('门锁蓝牙配对'),
              automaticallyImplyLeading: canExit,
            ),
            body: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    controller.isSuccess
                        ? '蓝牙配对成功'
                        : (controller.isFail ? '蓝牙配对失败' : '蓝牙配对中...'),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'sn: ${controller.model.deviceId}\n'
                    'mac: ${controller.model.devMac}\n'
                    '添加服务器: ${controller.hadAddService ? (controller.isAddServiceSuccess ? '成功' : '失败') : '未开始'}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        controller.logs[index],
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                  itemCount: controller.logs.length,
                )),
                if (controller.isSuccess &&
                    controller.hadAddService &&
                    controller.isAddServiceSuccess)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                            return BlePairConfigPage(
                              args: BlePairConfigArgs(
                                model: controller.model,
                                bleDevice: controller.bleDevice,
                                isNetip: DoorLockHelper.isSuppportBleNetip(
                                    deviceId: controller.model.deviceId,
                                    activeResponse: controller.activeResponse),
                                ability: controller.doorLockBleAbility,
                                exInfo: controller.doorLockExInfo,
                                pwdLengthRange: controller.pwdLengthRange,
                                navVersion: controller.doorFunction?.navVersion,
                                syncDoorStatus: controller.syncDoorStatus,
                              ),
                            );
                          }));
                        },
                        child: const Text('去配网'),
                      ),
                    ),
                  ),
                if (controller.isFail)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('返回'),
                      ),
                    ),
                  ),
              ],
            ),
            ),
          );
        });
      },
    );
  }
}
