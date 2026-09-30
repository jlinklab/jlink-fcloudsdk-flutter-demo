import 'package:fcloudsdk/ble_by_sdk/ble_device.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../pages/door_lock/usecase/door_lock_helper.dart';
import 'controller/main_ble_active_controller.dart';
import 'controller/main_ble_pair_config_controller.dart';

///门锁蓝牙激活页
///流程：连接 → 下发激活(0010) → 激活响应(拿 authKey/token/newSn) → 服务器校验
///→ 获取能力集(0003) → 通知设备校验结果(0011) → 握手协商密钥 → 成功
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
          return Scaffold(
            appBar: AppBar(
              title: const Text('门锁蓝牙配对'),
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
                        ///携带配网参数进入配网流程
                        onPressed: () {
                          Navigator.of(context).pop(BlePairConfigArgs(
                            model: controller.model,
                            ///改写广播包状态后的设备（一体化=2/非一体化=4）
                            bleDevice: controller.bleDevice,
                            isNetip: DoorLockHelper.isSuppportBleNetip(
                                deviceId: controller.model.deviceId,
                                activeResponse: controller.activeResponse),
                            ability: controller.doorLockBleAbility,
                            exInfo: controller.doorLockExInfo,
                            pwdLengthRange: controller.pwdLengthRange,
                            navVersion: controller.doorFunction?.navVersion,
                          ));
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
                          Navigator.of(context).pop();
                        },
                        child: const Text('返回'),
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }
}
