import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/ble_by_sdk/ble_device.dart';
import 'package:fcloudsdk/door_lock/door_lock_key_value.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/models/device_type.dart';
import 'package:flutter/foundation.dart';

import '../../../api/door_lock_api.dart';
import '../../add_device/models/scanned_device.dart';

///门锁辅助类
///差异说明：
///1. demo 无 DeviceListCenter（设备未入库），涉及设备对象查询的部分改用 DoorLockKeyValueLocal 等价判断；
///2. demo 无 DoorLockLocalCache，配网状态仅上报服务器；
///3. Log.d 日志改为 debugPrint。
class DoorLockHelper {
  static final DoorLockHelper instance = DoorLockHelper._();

  DoorLockHelper._();

  ///是否门锁
  static isDoorLock(String deviceId) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);

    return (device?.localUiKey ?? "")
            .contains(DeviceLocalUIKeyType.IOT_DOORLOCK.type) ||
        isIotDoorLock(deviceId) ||
        isBleDoorLock(deviceId);
  }

  ///是否是iot门锁(乐鑫门锁和新的XM650门锁)
  static isIotDoorLock(String deviceId) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);

    bool pidMatch = device?.parentPid == 'HAVLS0011000100A' ||
        device?.parentPid == 'HAVLS0012000100B' ||
        device?.parentPid == 'HAVLS0016000100E' ||
        device?.parentPid == 'HAVLS0017000100F' ||
        device?.parentPid == 'HAVLS0021000100B' ||
        device?.parentPid == 'HAVLS001D0001004' ||
        device?.parentPid == 'HAVLS001E000100P' ||
        device?.parentPid == 'HAVLS001P0001001' ||
        device?.parentPid == 'HAVLS001Q000100Y' ||
        device?.parentPid == 'HAVLS001H0001003' ||
        device?.parentPid == 'HAVLS001K000100U' ||
        device?.parentPid == 'HAVLS00180001007' ||
        device?.parentPid == 'HAVLS0013000100C' ||
        device?.parentPid == 'HAVLS001C000100O';

    bool matchLocalUiKey =
        device?.localUiKey == DeviceLocalUIKeyType.IOT_DOORLOCK.type ||
            device?.localUiKey == DeviceLocalUIKeyType.NEW_DOORLOCK_HOME.type;

    return pidMatch || matchLocalUiKey;
  }

  ///是否蓝牙锁
  static isBleDoorLock(String deviceId) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);

    bool propMatch = (device?.propList ?? []).contains('bleLockPair');

    bool isOverSeaMatch = isOverSeaDoorLock(deviceId);

    bool matchAbility = isLowPowerBle(deviceId);

    return propMatch || isOverSeaMatch || matchAbility;
  }

  ///是否海外锁
  static isOverSeaDoorLock(String deviceId, {String? parentPid}) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);

    bool pidMatch = isOverSeaDoorLockByParentPid(device?.parentPid);

    bool matchLocalUiKey =
        device?.localUiKey == DeviceLocalUIKeyType.BLUE_TOOTH_DOORLOCK.type ||
            device?.localUiKey ==
                DeviceLocalUIKeyType.BLUE_TOOTH_DOORLOCK_HOME.type ||
            device?.localUiKey == DeviceLocalUIKeyType.BK100W_NoVideo.type;

    return pidMatch || matchLocalUiKey;
  }

  ///是否低功耗蓝牙锁
  ///原逻辑：device?.doorLockExInfo?.byte1.supportBluetoothOnLockPlate == true || DoorLockKeyValueLocal.supportLowPowerBle
  ///demo 无设备对象，使用 DoorLockKeyValueLocal（SDK 激活时已 saveAndUpload 存储本地）
  static isLowPowerBle(String deviceId) {
    return DoorLockKeyValueLocal.supportLowPowerBle(deviceId: deviceId);
  }

  ///是否海外锁pid
  static isOverSeaDoorLockByParentPid(String? parentPid) {
    return parentPid == 'HABLK0012000100H' ||
        parentPid == 'HABLK0013000100I' ||
        parentPid == 'HABLK00140001006' ||
        parentPid == 'HAVLK0002000100V' ||
        parentPid == 'HAVLK001X0001001' ||
        parentPid == 'HAVLK0020000100V';
  }

  ///设置服务器门锁配网状态
  static setDeviceNetProvision(bool isConfig, String deviceId,
      {bool isFake = false}) async {
    try {
      var connectNetType = isFake
          ? "FAKE_CONNECT_NET"
          : (isConfig ? "CONNECTED_NET" : "NOT_CONNECT_NET");
      var netProvision = isFake ? 0 : (isConfig ? 1 : 0);
      await doorlockAPI.setDeviceNetProvision(
          deviceSn: deviceId,
          connectNetType: connectNetType,
          netProvision: netProvision);
      debugPrint(
          'setDeviceNetProvision: {deviceId: $deviceId, connect: $isConfig, isFake:$isFake}');
    } catch (e) {
      debugPrint(
          'setDeviceNetProvision fail: {deviceId: $deviceId, connect: $isConfig, isFake:$isFake}');
    }
  }

  ///获取服务器门锁配网状态
  ///获取不到则视为普通wifi锁，默认true
  static Future<bool> getDeviceNetProvision(String deviceId) async {
    var isConfigNet = true;
    try {
      var result =
          await doorlockAPI.getDeviceNetProvision(deviceSn: [deviceId]);
      if (result is List && result.isNotEmpty) {
        var map = result.first;
        if (map is Map) {
          var netProvision = map['netProvision'];
          if (netProvision != null) {
            isConfigNet = netProvision == true || netProvision == 1;
          }
        }
      }
      return isConfigNet;
    } catch (e) {
      ///
    }
    return isConfigNet;
  }

  //设备是否支持蓝牙netip协议（国内锁）
  //激活过程中直接传BleActiveResponse
  ///原逻辑：device?.devFormatType == 1 || activeResponse?.protocolFormatType == 1
  ///demo 无设备对象，devFormatType 与 DoorLockKeyValueLocal.protocolFormatType 同源（SDK 激活时存储）
  static bool isSuppportBleNetip(
      {required String deviceId, BleActiveResponse? activeResponse}) {
    return DoorLockKeyValueLocal.protocolFormatType(deviceId: deviceId) == 1 ||
        activeResponse?.protocolFormatType == 1;
  }

  ///当前手机是否连接wifi
  static Future<bool> hadConnectedWifi() async {
    List<ConnectivityResult> result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }

  ///是否支持蓝牙握手加密登录
  static bool isNeedSetAuthKey({required String deviceId}) {
    var protocolFormatType =
        DoorLockKeyValueLocal.protocolFormatType(deviceId: deviceId);
    var extendedFunction =
        DoorLockKeyValueLocal.extendedFunction(deviceId: deviceId);
    var authKey = DoorLockKeyValueLocal.authKey(deviceId: deviceId);

    if (protocolFormatType == 0 && extendedFunction == 0) {
      return authKey.isNotEmpty;
    }

    var model =
        BleActiveExtendedFunction.fromByte(intToBytes(extendedFunction).first);

    ///是否需要协商加密
    var needHandleShake = protocolFormatType == 1
        ? model.supportLoginForNetIp
        : model.supportLogin;

    return needHandleShake && authKey.isNotEmpty;
  }

  ///开启蓝牙netip
  static openBlueNetIp({
    required String sn,
    required String mac,
    required String adminToken,
  }) async {
    if (sn.isEmpty || mac.isEmpty || adminToken.isEmpty) {
      debugPrint(
          'open BlueNetIp fail,args is empty! deivceId:$sn mac:$mac adminToken:$adminToken');
      return;
    }
    if (isNeedSetAuthKey(deviceId: sn)) {
      await JFApi.xcDevice.bleSetAuthKey(
          deviceId: sn, authKey: DoorLockKeyValueLocal.authKey(deviceId: sn));
    }
    await JFApi.xcDevice.bleBindMacAndSn(deviceId: sn, mac: mac);
    await JFApi.xcDevice.switchBlueNetIp(deviceId: sn, open: 1);
    await JFApi.xcDevice.xcSetDeviceToken(deviceId: sn, token: adminToken);
    debugPrint('open BlueNetIp deivceId:$sn mac:$mac adminToken:$adminToken');
  }

  ///关闭蓝牙netip
  static closeBlueNetIp({required String sn}) async {
    await JFApi.xcDevice.switchBlueNetIp(deviceId: sn, open: 0);
    debugPrint('close BlueNetIp deivceId:$sn');
  }

  ///蓝牙锁激活类型
  ///0x00: 弱激活, 0x01 强激活, 0x02: 先和APP解绑再弱激活（兼容设备新老版本）0x03: 先和APP解绑再强激活（兼容设备新老版本）
  ///isLastTime：是否最后一次，是的话尝试弱激活，适用于多次激活重试，目前sdk未实现重试，暂且无视
  static blueActiveType(
      {required BleSearchDeviceBySDK? device, bool isLastTime = false}) {
    if (device == null) {
      return 00;
    }
    if (isOverSeaDoorLockByParentPid(device.pid)) {
      return isLastTime ? 00 : 01;
    }
    if (ScannedDevice(bleDevice: device).isBlueActive()) {
      return isLastTime ? 02 : 03;
    }
    return 00;
  }
}
