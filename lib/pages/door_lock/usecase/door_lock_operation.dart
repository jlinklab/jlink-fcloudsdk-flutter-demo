import 'dart:async';

import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/door_lock/ble_upgrade.dart';
import 'package:fcloudsdk/door_lock/door_lock_ble_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_key_value.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/common/event.dart';
import 'package:fcloudsdk_example/event/event.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/manager/low_power_dev_helper.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/global_ble_search_manager.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';

///门锁控制器基类
abstract class DoorLockPageController extends ChangeNotifier
    with DoorLockOperationMixin {
  final BuildContext context;

  DoorLockPageController({required this.context});

  @override
  BuildContext? get pageContext => context;
}

///有些门锁操作没有具体可挂载混入的页面，这里单独一个对象出来，方便操作
class DoorLockOperationObject extends ChangeNotifier
    with DoorLockOperationMixin {
  @override
  final String deviceId;

  @override
  BuildContext? get pageContext => null;

  bool? keepAlive;

  @override
  bool get keepBleConnectWhenDispose => keepAlive ?? false;
  @override
  bool get keepSyncWhenDispose => keepAlive ?? false;
  @override
  bool get keepLoginWhenDispose => keepAlive ?? false;

  DoorLockOperationObject({required this.deviceId, bool keepAlive = false}) {
    createDoorLockAPI();
    LogUtils.doorLock.log('DoorLockOperationObject create: $deviceId');
  }

  @override
  dispose() {
    super.dispose();
    LogUtils.doorLock.log('DoorLockOperationObject dispose：$deviceId');
  }
}

/// 修改开锁方式结果
class DoorLockModifyOpenTypeResult {
  final bool success;

  ///具体失败原因文案，null时使用通用失败文案
  final String? errorMsg;

  const DoorLockModifyOpenTypeResult(this.success, this.errorMsg);
}

mixin DoorLockOperationMixin on ChangeNotifier {
  String get deviceId;

  BuildContext? get pageContext;

  ///dispose时保留蓝牙连接，需要断开时复写为false
  bool get keepBleConnectWhenDispose => true;

  ///dispose时继续保活会话，需要发End时复写为false
  bool get keepSyncWhenDispose => true;

  ///dispose时保持登录不休眠，需要休眠时复写为false
  bool get keepLoginWhenDispose => true;

  late Device device = DeviceManager.instance.getDevice(deviceId: deviceId) ??
      Device(uuid: deviceId);

  ///蓝牙透传对象
  DoorLockBleApi? doorLockBleApi;

  ///蓝牙升级对象
  BleUpgrade? bleUpgrade;

  @override
  dispose() {
    if (!keepBleConnectWhenDispose) {
      LogUtils.doorLock.log('stopBleConnect when dispose：$deviceId');
      doorLockBleApi?.bleObject.stopConnect();
    }

    if (device.sleepState == DeviceSleepState.wakeUp ||
        device.sleepState == DeviceSleepState.unknown) {
      ///退出登录可以覆盖结束保活
      if (!keepLoginWhenDispose) {
        LogUtils.doorLock.log('sleepDeviceIfNeed when dispose：$deviceId');
        LPDHelper.me.sleepDeviceIfNeed(deviceId);
      } else {
        if (!keepSyncWhenDispose) {
          LogUtils.doorLock.log('endSyncDoorStatus when dispose：$deviceId');
          DoorLockNetIp.endSyncDoorStatus(deviceId);
        }
      }
    }

    DoorLockNetIpWifiTransExtUserManager.stopListen();

    super.dispose();
  }

  /// 等待蓝牙搜索结果，变为蓝牙在线，超时返回false
  Future<bool> waitBleOnline({int timeoutSeconds = 15}) async {
    if (device.blueOnline) return true;
    LogUtils.doorLock
        .log('waitBleOnline begin search timeout: $timeoutSeconds s');
    GlobalBleSearchManager.instance.startScanByDebounce();

    Completer<bool> completer = Completer();
    StreamSubscription? sub;
    Timer? timer;

    var oldSn = DoorLockKeyValueLocal.oldDeviceNo(deviceId: deviceId);
    sub = eventBus.on<BlueOnlineEvent>().listen((event) {
      if ((event.deviceId == deviceId || event.deviceId == oldSn) &&
          event.online) {
        if (!completer.isCompleted) {
          completer.complete(true);
          LogUtils.doorLock.log('waitBleOnline search target, become online');
        }
      }
    });
    timer = Timer(Duration(seconds: timeoutSeconds), () {
      if (!completer.isCompleted) {
        completer.complete(false);
        LogUtils.doorLock.log('waitBleOnline search end, still offline');
      }
    });
    bool result = await completer.future;
    sub.cancel();
    timer.cancel();
    return result;
  }

  ///[showErrorTip]为false时失败不弹toast，供页面用重试弹窗兜底的调用方使用
  Future<bool> beforeNetIp(
      {bool showLoading = true,
      bool ignoreAddUserAdminNotskip = true,
      bool needKeepAlive = true,
      bool showErrorTip = true}) async {
    try {
      ///先唤醒, 门锁唤醒由sdk内部处理，这里不调了
      //showLoading ? EasyLoadingUtils.showInContext(pageContext, dismissOnTap: true) : null;
      //await LPDHelper.me.wakeupDeviceIfNeed(deviceId, showLoading: false);

      LPDHelper.me.resetSleepTimer(deviceId);

      if (!needKeepAlive) {
        return true;
      }

      ///再保活
      showLoading ? KToast.show() : null;
      var result = await DoorLockNetIp.syncDoorStatus(deviceId);
      showLoading ? KToast.dismiss() : null;

      ///正常情况下addUserAdminNotskip也视为成功，除非特殊场景如验证管理员、用户管理等
      if (!ignoreAddUserAdminNotskip &&
          result.item2?.err ==
              DoorLockNetIpOperaterResult.addUserAdminNotskip) {
        if (showErrorTip) {
          KToast.show(status: result.item2?.err.name);
        }
        return false;
      }

      if (result.item1 == false) {
        if (result.item3 is XCloudAPIException &&
            (result.item3 as XCloudAPIException).code == -70102) {
          ///版本不支持，则忽略，不提示, 视为成功
          return true;
        }
        if (showLoading && showErrorTip) {
          KToast.show(status: kErrorMsg(result.item3));
        }
      }
      return result.item1;
    } catch (e) {
      showLoading ? KToast.dismiss() : null;
      return false;
    }
  }

  Future<bool> beforeBlue() async {
    try {
      if (doorLockBleApi == null) {
        createDoorLockAPI();
      }
      return doorLockBleApi != null;
    } catch (e) {
      return false;
    }
  }

  void createDoorLockAPI() {
    if (keepBleConnectWhenDispose ||
        keepLoginWhenDispose ||
        keepSyncWhenDispose) {
      LPDHelper.me.resetSleepTimer(deviceId);
    }

    if (doorLockBleApi == null) {
      if (device.blueOnline == false) {
        LogUtils.doorLock.log('blue Online is false, createDoorLockAPI fail');
        return;
      }
      if (DoorLockHelper.getBlueUUID(deviceId) == null) {
        LogUtils.doorLock.log('get blue uuid is null, createDoorLockAPI fail');
        return;
      }
      if (device.isBlueNetIpEnable) {
        DoorLockHelper.openBlueNetIp(
            sn: deviceId,
            mac: DoorLockHelper.getBlueUUID(deviceId) ?? "",
            adminToken: device.adminToken);
        return;
      }

      doorLockBleApi = DoorLockBleApi(
          uuid: DoorLockHelper.getBlueUUID(deviceId)!, activeSn: device.uuid);

      bleUpgrade = BleUpgrade(
          uuid: DoorLockHelper.getBlueUUID(deviceId)!, activeSn: device.uuid);

      LogUtils.doorLock.log('createDoorLockAPI done');
    }
  }

  ///关锁
  Future<bool> lock({bool showLoading = true}) async {
    // 重试计数：BLE→WiFi→BLE 或 WiFi→BLE→WiFi，最多重试2次
    int retryCount = 0;

    late Future<bool> Function() sendByBlue;
    late Future<bool> Function() sendByNetIp;

    sendByBlue = () async {
      if (await beforeBlue() == false) return false;
      showLoading ? KToast.show() : null;
      bool result = false;
      try {
        result = await doorLockBleApi?.lockDoor(
                DoorLockBlueOpenCloseType.remote, device.memberId ?? 1) ??
            false;
      } catch (e) {
        LogUtils.doorLock.log('lock sendByBlue error: ${e.toString()}');
        result = false;
      }
      if (result) {
        KToast.show(
          status: TR.current.tr_player_lock_succeed,
        );
        return result;
      } else {
        // BLE失败，已达最大重试次数则停止
        if (retryCount >= 2) {
          KToast.show(status: TR.current.tr_player_lock_failed);
          return result;
        }
        //走蓝牙失败尝试走wifi
        if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi ||
            device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue) {
          retryCount++;
          LogUtils.doorLock.log('lock sendByBlue error, retry sendByNetIp');
          return sendByNetIp();
        } else {
          KToast.show(status: TR.current.tr_player_lock_failed);
          return result;
        }
      }
    };

    sendByNetIp = () async {
      showLoading ? KToast.show() : null;
      if (await beforeNetIp(needKeepAlive: false) == false) return false;
      var result = await DoorLockNetIp.lockDoor(deviceId, device.memberId ?? 1);
      if (result) {
        KToast.show(
          status: TR.current.tr_player_lock_succeed,
        );
      } else {
        // WiFi失败，已达最大重试次数则停止
        if (retryCount >= 2) {
          KToast.show(status: TR.current.tr_player_lock_failed);
          return result;
        }
        // WiFi失败，重试蓝牙
        if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue ||
            device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
          retryCount++;
          LogUtils.doorLock.log('lock sendByNetIp error, retry sendByBlue');
          return sendByBlue();
        }
        KToast.show(status: TR.current.tr_player_lock_failed);
      }
      return result;
    };

    if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue ||
        device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
      return sendByBlue();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi) {
      return sendByNetIp();
    } else {
      if (DoorLockHelper.isLowPowerBle(deviceId) ||
          DoorLockHelper.isOverSeaDoorLock(deviceId)) {
        // 蓝牙离线，先搜索等到在线后继续执行蓝牙操作
        KToast.show();
        bool online = await waitBleOnline();
        if (online) {
          return sendByBlue();
        }
        KToast.show(status: TR.current.tr_player_lock_failed);
        return false;
      }
    }
    return false;
  }

  ///开锁
  Future<bool> unlock({bool showLoading = true}) async {
    // 重试计数：BLE→WiFi→BLE 或 WiFi→BLE→WiFi，最多重试2次
    int retryCount = 0;

    late Future<bool> Function() sendByBlue;
    late Future<bool> Function() sendByNetIp;

    sendByBlue = () async {
      if (await beforeBlue() == false) return false;
      showLoading ? KToast.show() : null;
      //0x00成功 0x01失败 0x02门已反锁 -1蓝牙发送失败
      int status = -1;
      try {
        status = await doorLockBleApi?.unlockDoorWithStatus(
                DoorLockBlueOpenCloseType.remote, device.memberId ?? 1) ??
            -1;
      } catch (e) {
        LogUtils.doorLock.log('unlock sendByBlue error: ${e.toString()}');
        status = -1;
      }
      if (status == 0x02) {
        //门已反锁，重试WiFi也无法开锁，直接提示失败
        LogUtils.doorLock
            .log('unlock sendByBlue status 0x02, door is deadbolted');
        KToast.show(
          status: TR.current.tr_doorlock_open_failed_with_deadbolt,
        );
        return false;
      }
      bool result = status == 0;
      if (result) {
        KToast.show(
          status: TR.current.tr_player_unlock_succeed,
        );
        return result;
      } else {
        // BLE失败，已达最大重试次数则停止
        if (retryCount >= 2) {
          KToast.show(status: TR.current.tr_player_unlock_failed);
          return result;
        }
        //走蓝牙失败尝试走wifi，否则直接报错
        if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi ||
            device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue) {
          retryCount++;
          LogUtils.doorLock.log('unlock sendByBlue error, retry sendByNetIp');
          return sendByNetIp();
        } else {
          KToast.show(status: TR.current.tr_player_unlock_failed);
          return result;
        }
      }
    };

    sendByNetIp = () async {
      showLoading ? KToast.show() : null;
      if (await beforeNetIp(needKeepAlive: false) == false) return false;

      var result =
          await DoorLockNetIp.unlockDoor(deviceId, device.memberId ?? 1);
      if (result) {
        KToast.dismiss();
        return true;
      } else {
        // WiFi失败，已达最大重试次数则停止
        if (retryCount >= 2) {
          KToast.show(status: TR.current.tr_player_unlock_failed);
          return result;
        }
        // WiFi失败，重试蓝牙
        if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue ||
            device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
          retryCount++;
          LogUtils.doorLock.log('unlock sendByNetIp error, retry sendByBlue');
          return sendByBlue();
        }
        KToast.show(status: TR.current.tr_player_unlock_failed);
      }
      return result;
    };

    if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue ||
        device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
      return sendByBlue();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi) {
      return sendByNetIp();
    } else {
      if (DoorLockHelper.isLowPowerBle(deviceId) ||
          DoorLockHelper.isOverSeaDoorLock(deviceId)) {
        // 蓝牙离线，先搜索等到在线后继续执行蓝牙操作
        KToast.show();
        bool online = await waitBleOnline();
        if (online) {
          return sendByBlue();
        }
        KToast.show(status: TR.current.tr_player_unlock_failed);
        return false;
      }
    }
    return false;
  }
}
