import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/ble_by_sdk/ble_device.dart';
import 'package:fcloudsdk/door_lock/door_lock_ble_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_key_value.dart';
import 'package:fcloudsdk/door_lock/door_lock_parse.dart';
import 'package:fcloudsdk/door_lock/door_lock_shadow.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk/utils/extensions.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/models/device_type.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/global_ble_search_manager.dart';
import 'package:fcloudsdk_example/pages/door_lock/repository/door_lock_local.dart';
import 'package:fcloudsdk_example/utils/map_utils.dart';
import 'package:flutter/foundation.dart';

import '../../../api/door_lock_api.dart';
import '../../add_device/models/scanned_device.dart';

///门锁辅助类
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

  ///是否展示蓝牙在线状态
  ///蓝牙锁或未配网的锁需要展示蓝牙在线状态；设备尚未拉取到列表中时默认 true（如配网刚结束）
  static bool showBlueOnlineState({required String deviceId}) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device == null) {
      return true;
    }
    if (isBleDoorLock(deviceId)) {
      return true;
    }
    return !device.doorlockIsConfigNet;
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

  ///是否BK海外锁
  static isBKOverseaDoorLock(String deviceId) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);
    return device?.parentPid == 'HAVLK001X0001001' ||
        device?.parentPid == 'HAVLK0020000100V' &&
            device?.localUiKey == DeviceLocalUIKeyType.BK100W_NoVideo.type;
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
      DoorLockLocalCache.saveDoorlockIsConfigNet(deviceId, isConfig);
      DoorLockLocalCache.saveDoorlockIsFakeConfigNet(deviceId, isFake);
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
          var netProvision = MapParser.readBool(map, 'netProvision');
          if (netProvision != null) {
            isConfigNet = netProvision;

            if (isConfigNet == false) {
              var connectNetType = MapParser.readString(map, 'connectNetType');
              DoorLockLocalCache.saveDoorlockIsFakeConfigNet(
                  deviceId, connectNetType == 'FAKE_CONNECT_NET');
            }
          }
        }
      }
      DoorLockLocalCache.saveDoorlockIsConfigNet(deviceId, isConfigNet);
      return isConfigNet;
    } catch (e) {
      ///
    }
    return isConfigNet;
  }

  //设备是否支持蓝牙netip协议（国内锁）
  //激活过程中直接传BleActiveResponse
  ///原逻辑：device?.devFormatType == 1 || activeResponse?.protocolFormatType == 1
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

  ///上报门锁在线配置
  ///rawList: 十六进制字符串数组（几维协议格式）
  saveOnlineConfig(String deviceId, List<String> rawList) async {
    ///海外锁走JVSS接口（insertOrUpdateDoorLockInfo）
    if (isOverSeaDoorLock(deviceId)) {
      return saveOnlineConfigToJvss(deviceId, rawList);
    }
    try {
      var datas = rawList.map((e) => base64Encode(hexToBytes(e))).toList();
      var cmd = {
        "OPDoorLockProCmd": {
          "DoorConfig": {
            "RawData": datas,
          }
        }
      };
      await doorlockAPI.saveOnline(sn: deviceId, data: cmd);
      debugPrint('door lock saveOnlineConfig: $cmd');
    } catch (e) {
      debugPrint('door lock saveOnlineConfig error: $e');
    }
  }

  ///上报海外锁在线配置（通过insertOrUpdateDoorLockInfo接口）
  ///rawList: 几维协议格式的十六进制字符串数组
  saveOnlineConfigToJvss(String deviceId, List<String> rawList) async {
    try {
      var fields = rawListToJvssFields(rawList);
      await uploadJvssConfig(deviceId, fields);
      debugPrint('saveOnlineConfigToJvss success');
    } catch (e) {
      debugPrint('saveOnlineConfigToJvss error: $e');
    }
  }

  ///通过字段Map调用insertOrUpdateDoorLockInfo
  Future<void> uploadJvssConfig(
    String deviceId,
    Map<String, String> fields, {
    bool? yearSyncState,
    bool? keySyncState,
  }) async {
    await doorlockAPI.insertOrUpdateDoorLockInfo(
      deviceSn: deviceId,
      pirDetection: fields['pirDetection'],
      humanSensor: fields['humanSensor'],
      autoLock: fields['autoLock'],
      volume: fields['volume'],
      openModeTime: fields['openModeTime'],
      supportDeadbolt: fields['supportDeadbolt'],
      doorOpenDirection: fields['doorOpenDirection'],
      doorUnlockMode: fields['doorUnlockMode'],
      doorFaceAlarmTone: fields['doorFaceAlarmTone'],
      doorLockAntiPryAlarm: fields['doorLockAntiPryAlarm'],
      devLanList: fields['devLanList'],
      deviceLanguage: fields['deviceLanguage'],
      yearSyncState: yearSyncState,
      keySyncState: keySyncState,
    );
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

  ///刷新门锁状态
  static refreshDoorLockStatus(String deviceId, {bool queryNet = false}) async {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device != null) {
      ///配网状态
      queryNet ? await getDeviceNetProvision(deviceId) : null;

      ///门锁指令状态
      device.doolockCmdStatus = getCmdStatus(deviceId);
    }
  }

  ///门锁指令状态
  static DoolockCmdStatus getCmdStatus(String deviceId) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device == null) {
      return DoolockCmdStatus.offline;
    }

    var wifiOnline = device.state > 0 && device.doorlockIsConfigNet;

    ///支持蓝牙netip协议的锁
    if (DoorLockHelper.isSuppportBleNetip(deviceId: deviceId)) {
      if (device.blueOnline) {
        return DoolockCmdStatus.onlyWifi;
      } else {
        if (wifiOnline) {
          if (device.sleepState == DeviceSleepState.deepSleep) {
            return DoolockCmdStatus.offline;
          }
          return DoolockCmdStatus.onlyWifi;
        }
      }
      return DoolockCmdStatus.offline;
    }

    ///其他协议的蓝牙锁
    if (wifiOnline && device.blueOnline) {
      if (device.sleepState == DeviceSleepState.deepSleep) {
        return DoolockCmdStatus.onlyBlue;
      }
      return DoolockCmdStatus.wifiAndBlue;
    }
    if (wifiOnline && !device.blueOnline) {
      if (device.sleepState == DeviceSleepState.deepSleep) {
        return DoolockCmdStatus.offline;
      }
      return DoolockCmdStatus.onlyWifi;
    }
    if (!wifiOnline && device.blueOnline) {
      return DoolockCmdStatus.onlyBlue;
    }
    return DoolockCmdStatus.offline;
  }

  //是否显示远程关锁
  static bool showRemoteLock({required String deviceId}) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device?.doorLockBleAbility == null) {
      return false;
    }
    if (isOverSeaDoorLock(deviceId) == false) {
      ///国内只判断一个能力
      return device!.doorLockBleAbility!.byte3.supportRemoteLock;
    }
    if (device!.doorlockIsConfigNet) {
      if (device.doorLockBleAbility!.byte3.supportRemoteLock ||
          device.doorLockBleAbility!.byte4.supportBlueToothLock) {
        return true;
      }
      return false;
    } else {
      if (device.doorLockBleAbility!.byte4.supportBlueToothLock) {
        return true;
      }
      return false;
    }
  }

  ///门锁能力集-影子服务
  static getFuncFromShadowIfNeed(String deviceId,
      {bool queryNew = false}) async {
    await DoorLockShadow.getShadowIfNeed(deviceId, queryNew: queryNew);
    var result = parseDoorFunction(deviceId);
    if (!result) {
      parseDlctrl(deviceId);
      return;
    }
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device?.doorLockBleAbility == null) {
      parseDlctrl(deviceId);
    }
  }

  ///解析本地影子服务门锁能力集
  static bool parseDoorFunction(String deviceId) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId) ??
        Device(uuid: deviceId);
    var result = DoorLockShadow.parseDoorFunction(deviceId);
    if (result == null) {
      return false;
    }
    device.doorFunction = result;
    device.doorLockBleAbility = result.doorLockBleAbility;
    device.doorLockExInfo = result.doorLockExInfo;
    device.doorManagerAbility = result.doorManagerAbility;
    device.doorUserAbility = result.doorUserAbility;
    device.doorLockPwdLengthRange = result.doorLockPwdLengthRange;
    device.doorLockActionVerList = result.userManagerActionVersionList;
    device.opTrans = result.opTrans;
    device.qsPid = result.qsPid;
    device.navVersion = result.navVersion;
    device.supportRtFace = result.supportRtFace;
    return true;
  }

  ///解析旧版本地影子服务门锁能力集
  static bool parseDlctrl(String deviceId) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId) ??
        Device(uuid: deviceId);
    var dlctrl = DoorLockShadow.parseDlctrl(deviceId);
    if (dlctrl == null) {
      return false;
    }
    device.dlctrl = dlctrl;

    if (dlctrl.doorFunction != null) {
      var result = dlctrl.doorFunction!;
      device.doorFunction = result;
      device.doorLockBleAbility = result.doorLockBleAbility;
      device.doorLockExInfo = result.doorLockExInfo;
      device.doorManagerAbility = result.doorManagerAbility;
      device.doorUserAbility = result.doorUserAbility;
      device.doorLockPwdLengthRange = result.doorLockPwdLengthRange;
      device.doorLockActionVerList = result.userManagerActionVersionList;
      device.opTrans = result.opTrans;
      device.qsPid = result.qsPid;
      device.navVersion = result.navVersion;
      device.supportRtFace = result.supportRtFace;
    } else {
      device.doorUserAbility = dlctrl.doorUserAbility;
      device.supportRtFace = dlctrl.supportRtFace;
      device.doorLockPwdLengthRange =
          DoorLockPwdLengthRange.fromList(dlctrl.pwdLenRangeArray);
      device.doorLockBleAbility = DoorLockBleAbility(
          [],
          DoorLockBleAbilityByte1(
            supportUserManager: false,
            supportUpgrade: dlctrl.supportUpgrade ?? false,
            supportPirConfig: dlctrl.supportPirConfig ?? false,
            supportUnlockDirection: dlctrl.supportUnlockDirection ?? false,
            supportAutoLock: dlctrl.supportAutoLock ?? false,
            supportUnlockMode: dlctrl.supportUnlockMode ?? false,
            supportVolumeControl: dlctrl.supportVolumeControl ?? false,
            supportFaceAlarmTone: dlctrl.supportFaceAlarmTone ?? false,
          ),
          DoorLockBleAbilityByte2(
            supportMotorTorque: dlctrl.supportMotorTorque ?? false,
            supportNormalOpenMode: dlctrl.supportNormalOpenMode ?? false,
            supportDeployDefense: dlctrl.supportDeployDefense ?? false,
            supportHumanSensor: dlctrl.supportHumanSensor ?? false,
            supportLanguage: dlctrl.supportLanguage ?? false,
            supportOneKeyDeployDefense: false,
            supportLockBody: false,
            supportLockBackTime: false,
          ),
          DoorLockBleAbilityByte3(
            supportReverseTime: false,
            supportDoorlockReset: dlctrl.supportDoorlockReset ?? false,
            supportWakeupGetInfo: false,
            supportRemoteLock: dlctrl.supportRemoteLock ?? false,
            supportTmpPasswd: dlctrl.supportTmpPasswd ?? false,
            supportOpeningDirectionSelfCheck: false,
            supportLockInside: false,
            supportBleNormalOpenMode: false,
          ),
          DoorLockBleAbilityByte4.fromByte(0),
          DoorLockBleAbilityByte5.fromByte(0));
    }
    return true;
  }

  /// 获取蓝牙uuid
  static String? getBlueUUID(String deviceId) {
    var oldDeviceNo = DoorLockKeyValueLocal.oldDeviceNo(deviceId: deviceId);
    if (oldDeviceNo.isNotEmpty) {
      var searchBle = GlobalBleSearchManager.instance.allDeviceMap.entries
          .firstWhereOrNull((e) => e.value.sn == oldDeviceNo);
      if (searchBle != null) {
        return searchBle.key;
      }
      var device = DeviceManager.instance.getDevice(deviceId: deviceId);
      if (device?.blueUUid != null) {
        return device?.blueUUid;
      }
    }
    return null;
  }

  ///是否需要提示设备不在附近
  static bool checkNeedTipsDeviceIsNotNearby(String deviceId) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device == null) return false;
    if (device.blueOnline) {
      return false;
    }
    if (!device.doorlockIsConfigNet) {
      return true;
    }
    if (isLowPowerBle(deviceId) || isOverSeaDoorLock(deviceId)) {
      return device.doolockCmdStatus == DoolockCmdStatus.offline;
    }
    return false;
  }

  /// 是否支持反锁状态显示
  static bool supportReverseLockState(String deviceId) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device?.doorLockBleAbility == null) {
      return false;
    }
    return device!.doorLockBleAbility!.byte3.supportLockInside;
  }

  ///是否显示用户管理-密码入口（对齐 jlink showUserManagerPwd）
  static bool showUserManagerPwd({required String deviceId}) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device == null) return false;

    var userAbility = device.doorUserAbility?.byte1.supportPassword == true;
    var offlineAbility =
        device.doorLockExInfo?.byte1.supportLockEndOffLinePwd ?? false;

    if (isLowPowerBle(deviceId)) {
      var supportTemp = supportTempPwd(deviceId: deviceId);
      return userAbility || offlineAbility || supportTemp;
    }
    return userAbility || offlineAbility;
  }

  ///是否支持临时密码 / 自定义密码（对齐 jlink supportTempPwd）
  static bool supportTempPwd({required String deviceId}) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device == null) return false;

    var tempAbility =
        device.doorLockBleAbility?.byte3.supportTmpPasswd ?? false;
    var func = DoorLockShadow.doorFunction(deviceId: deviceId);
    var tmpProp = MapParser.queryBool(func, 'TmpPasswd', false);
    var tempAbilityOld = device.dlctrl?.supportTmpPasswd == true;

    return device.doorlockIsConfigNet &&
        (tempAbility || tmpProp || tempAbilityOld);
  }

  ///是否显示用户管理-临时密码（对齐 jlink showTempPwd，demo 不含电子钥匙分享判断）
  static bool showTempPwd({required String deviceId}) {
    var supportTemp = supportTempPwd(deviceId: deviceId);
    return supportTemp && !isLowPowerBle(deviceId);
  }

  ///用户管理入口是否显示（对齐 jlink checkUserManagerShow）
  ///首页“用户管理”区域是否渲染：任一能力+对应分享权限命中则显示
  static bool checkUserManagerShow({required String deviceId}) {
    var device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device == null) return false;

    var sharePassword =
        device.hasPermission(permission: DevicePermission.DP_DoorLockPsw);
    var shareSkin = device
        .hasPermission(permission: DevicePermission.DP_DoorLockFingerprint);
    var shareFace =
        device.hasPermission(permission: DevicePermission.DP_DoorLockFace);
    var sharePalmprint = device
        .hasPermission(permission: DevicePermission.DP_DoorLockPalmprint);
    var shareCard =
        device.hasPermission(permission: DevicePermission.DP_DoorLockCard);
    var shareFingerVein = device
        .hasPermission(permission: DevicePermission.DP_DoorLockFingerVein);
    var sharePalmVein = device
        .hasPermission(permission: DevicePermission.DP_DoorLockPalmVein);

    return (showUserManagerPwd(deviceId: deviceId) && sharePassword) ||
        (device.doorUserAbility?.byte1.supportSkin == true && shareSkin) ||
        (device.doorUserAbility?.byte1.supportFace == true && shareFace) ||
        (device.doorUserAbility?.byte1.supportPalmprint == true &&
            sharePalmprint) ||
        (device.doorUserAbility?.byte1.supportCard == true && shareCard) ||
        (device.doorUserAbility?.byte1.supportFingervein == true &&
            shareFingerVein) ||
        (device.doorUserAbility?.byte1.supportPalmVein == true && sharePalmVein);
  }
}
