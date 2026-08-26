import 'package:flutter/material.dart';
import 'package:fcloudsdk/api/util/util_api.dart';
import 'package:fcloudsdk/ble_by_sdk/ble_device.dart';
import 'package:fcloudsdk/ble_by_sdk/ble_distribute.dart';
import 'package:fcloudsdk/wifi/wifi_config.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/add_device/add_device_fill_device_name_page.dart';
import 'package:fcloudsdk_example/pages/add_device/models/add_device_center.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

class MainBleDistributeController extends ChangeNotifier {
  final BuildContext context;

  late BleDistribute bleDistribute;

  final List<String> logs = [];

  final String ssid;
  final String password;
  final String mac;

  MainBleDistributeController(
      {required this.context,
      required this.mac,
      required this.ssid,
      required this.password}) {
    bleDistribute = BleDistribute(
      uuid: mac,
      wifiConfig: WifiConfig(
        ssid: ssid,
        wifiPwd: password,
      ),
    );

    addBleListener();

    bleDistribute.start();
  }

  addBleListener() {
    //连接状态监听
    bleDistribute.addConnectStatusListener((status, errorCode) {
      if (status == BleDistributeStatus.connected) {
        logs.addAll([
          TR.current.deviceAddConnectBleTip1,
          TR.current.deviceAddConnectBleTip2
        ]);
      } else if (status == BleDistributeStatus.distributing) {
        logs.addAll([
          TR.current.deviceAddConnectBleTip3,
          TR.current.deviceAddConnectBleTip4,
        ]);
      } else if (status == BleDistributeStatus.connectFail) {
        logs.add(TR.current.deviceBluetoothCantConnect);
      } else if (status == BleDistributeStatus.breaked) {
        logs.add(TR.current.deviceAddConnectBledDisconnected);
      }
      _updateView();
    });

    //配网状态监听
    bleDistribute.addDistributeResultListener((status, device, errorCode) {
      if (status == BleDistributeStatus.distributeSuccess) {
        logs.add(TR.current.deviceAddConnectBleTip5);
        _success(device);
      } else if (status == BleDistributeStatus.error) {
        stop();
        logs.add("${TR.current.addConnectDevFailed}:$errorCode");
      }
      _updateView();
    });
  }

  _success(BleDistributeDeviceBySDK? device) async {
    if (device == null) {
      return;
    }

    DeviceAddModel model =
        DeviceAddModel.parseFromDistributeBle(device.toJson());

    if (device.ip.isNotEmpty) {
      UtilAPI.instance
          .xcCacheBluetoothInfo(deviceId: model.deviceId, deviceIp: model.ip);
    }

    DeviceAddCenter.instance.clearRandomUserNameAndPwd(model.deviceId);
    await DeviceAddCenter.instance
        .setDeviceLocalToken(deviceId: model.deviceId, token: model.adminToken);
    DeviceAddCenter.instance.tryDeviceLogin(model);

    /// 配置绑定关系
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

  stop() {
    bleDistribute.stop();
  }

  _updateView() {
    if (hasListeners) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    bleDistribute.stop();
    bleDistribute.cleanListeners();
  }
}
