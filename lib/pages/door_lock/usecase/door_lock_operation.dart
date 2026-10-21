import 'dart:async';

import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/door_lock/ble_upgrade.dart';
import 'package:fcloudsdk/door_lock/door_lock_ble_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_ble_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_date.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_key_value.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_model.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/common/event.dart';
import 'package:fcloudsdk_example/event/event.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/manager/low_power_dev_helper.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/global_ble_search_manager.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/door_user.dart';
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

/// 删除开锁方式结果
class DoorLockDeleteResult {
  ///锁端删除是否成功
  final bool success;

  ///netip 通道返回的错误码（BLE 通道为 null），供调用方识别 needSync 等
  final DoorLockNetIpOperaterResult? err;

  ///netip 通道 catch 到的原始异常（BLE 通道为 null）
  final dynamic rawError;

  const DoorLockDeleteResult(this.success, this.err, this.rawError);
}

/// 添加开锁方式结果
class DoorLockAddResult {
  ///锁端添加是否成功
  final bool success;

  ///添加成功后的锁端 hardwareId（失败为 -1）
  final int hardwareId;

  ///netip 通道返回的错误码（BLE 通道为 null），供调用方识别 needSync 等
  final DoorLockNetIpOperaterResult? err;

  ///netip 通道 catch 到的原始异常（BLE 通道为 null）
  final dynamic rawError;

  const DoorLockAddResult(
      this.success, this.hardwareId, this.err, this.rawError);
}

///远程开关锁结果推送等待句柄
class RemoteLockPushWait {
  ///推送到达时完成并返回 true；超时/作废返回 false
  final Future<bool> future;

  ///命令受理成功后启动兜底超时（超时未收到推送则按结果未知收场）
  final void Function() startFallbackTimer;

  ///命令未受理/发送失败时作废等待
  final void Function() cancel;

  RemoteLockPushWait({
    required this.future,
    required this.startFallbackTimer,
    required this.cancel,
  });
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

  // ==================== 远程开关锁结果等待 ====================

  ///远程开关锁结果推送等待序号，新一轮开关锁使旧等待作废
  int _remoteLockWaitSeq = 0;

  ///订阅远程开关锁结果推送
  ///
  ///命令发送成功不代表锁已动作（如门已反锁设备会拒绝执行），
  ///真实结果由服务器推送 DoorLockOpen/DoorLockClose 下发；
  ///推送可能先于命令结果到达，须在发送命令前先订阅
  RemoteLockPushWait _subscribeRemoteLockPush({required bool isUnlock}) {
    final seq = ++_remoteLockWaitSeq;
    final completer = Completer<bool>();
    StreamSubscription<RemoteLockActionResultEvent>? sub;
    Timer? timer;

    void finish(bool pushed) {
      if (completer.isCompleted) return;
      timer?.cancel();
      sub?.cancel();
      completer.complete(pushed);
    }

    sub = eventBus.on<RemoteLockActionResultEvent>().listen((event) {
      if (event.deviceId != deviceId || event.isUnlock != isUnlock) return;
      if (seq != _remoteLockWaitSeq) return;
      LogUtils.doorLock
          .log('remote lock push result isUnlock=$isUnlock, seq: $seq');
      finish(true);
    });

    return RemoteLockPushWait(
      future: completer.future,
      //兜底超时不立即启动，等命令受理后才起算，
      //避免命令未被受理（如设备睡眠超时）时定时器先到误收转圈
      startFallbackTimer: () {
        timer = Timer(const Duration(seconds: 12), () {
          //超时未收到结果推送，真实结果未知，静默收起不提示
          LogUtils.doorLock
              .log('remote lock push timeout, seq: $seq, as unknown');
          finish(false);
        });
      },
      cancel: () {
        //命令未受理/发送失败，作废本次等待
        LogUtils.doorLock.log('remote lock push cancel, seq: $seq');
        finish(false);
      },
    );
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
      //配对门锁经蓝牙 netip 隧道发送，锁端直接回执，保持原样；
      //纯远程 wifi 通道（非配对）命令受理≠锁已动作，发送前先订阅结果推送
      final pushWait = device.isBlueNetIpEnable
          ? null
          : _subscribeRemoteLockPush(isUnlock: false);
      if (await beforeNetIp(needKeepAlive: false) == false) {
        pushWait?.cancel();
        return false;
      }
      var result = await DoorLockNetIp.lockDoor(deviceId, device.memberId ?? 1);
      if (result) {
        if (pushWait != null) {
          //命令已受理，等推送真实结果期间保持转圈，超时结果未知静默收起
          pushWait.startFallbackTimer();
          final pushed = await pushWait.future;
          if (pushed) {
            KToast.show(
              status: TR.current.tr_player_lock_succeed,
            );
          } else {
            KToast.dismiss();
          }
        } else {
          KToast.show(
            status: TR.current.tr_player_lock_succeed,
          );
        }
      } else {
        pushWait?.cancel();
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
      //配对门锁经蓝牙 netip 隧道发送，锁端直接回执，保持原样；
      //纯远程 wifi 通道（非配对）命令受理≠锁已动作，发送前先订阅结果推送
      final pushWait = device.isBlueNetIpEnable
          ? null
          : _subscribeRemoteLockPush(isUnlock: true);
      if (await beforeNetIp(needKeepAlive: false) == false) {
        pushWait?.cancel();
        return false;
      }

      var result =
          await DoorLockNetIp.unlockDoor(deviceId, device.memberId ?? 1);
      if (result) {
        if (pushWait != null) {
          //命令已受理，等推送真实结果期间保持转圈，超时结果未知静默收起
          pushWait.startFallbackTimer();
          final pushed = await pushWait.future;
          if (pushed) {
            KToast.show(status: TR.current.tr_player_unlock_succeed);
          } else {
            KToast.dismiss();
          }
        } else {
          KToast.dismiss();
        }
        return true;
      } else {
        pushWait?.cancel();
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

  ///删除开锁方式
  Future<DoorLockDeleteResult> doorLockDeleteType(
    int id,
    JvssOperateType type,
    bool isAdmin,
  ) async {
    ///蓝牙通道：直连锁端删除
    Future<DoorLockDeleteResult> sendByBlue() async {
      if (await beforeBlue() == false) {
        return const DoorLockDeleteResult(false, null, null);
      }
      bool ok = false;
      try {
        ok = await doorLockBleApi
                ?.deleteDoorOpenType(DoorLockDeleteBleOpenTypeRequest(
              deleteType: 0x01,
              type: BleOperateType.from(type.toBleType()),
              hardwareId: id,
              memberId: isAdmin ? 2 : 1,
            )) ??
            false;
      } catch (e) {
        LogUtils.doorLock.log('doorLockDeleteType sendByBlue error: $e');
        ok = false;
      }
      return DoorLockDeleteResult(ok, null, null);
    }

    ///netip 通道
    Future<DoorLockDeleteResult> sendByNetIp() async {
      var sync = await DoorLockNetIp.syncDoorStatus(deviceId);
      if (!sync.item1) {
        return DoorLockDeleteResult(false, sync.item2?.err, sync.item3);
      }
      var result = await DoorLockNetIp.deleteDoorOpenType(
          deviceId: deviceId, type: type, id: id);
      return DoorLockDeleteResult(
          result.item1, result.item2?.err, result.item3);
    }

    if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi) {
      return sendByNetIp();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue ||
        device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
      return sendByBlue();
    } else {
      ///离线：低功耗/海外锁先搜蓝牙，等到在线后走 BLE 删除
      if (DoorLockHelper.isLowPowerBle(deviceId) ||
          DoorLockHelper.isOverSeaDoorLock(deviceId)) {
        bool online = await waitBleOnline();
        if (online) {
          return sendByBlue();
        }
      }
      return const DoorLockDeleteResult(false, null, null);
    }
  }

  ///添加永久密码
  Future<DoorLockAddResult> doorLockAddPasswordType({
    required String pwd,
    required bool isAdmin,
  }) async {
    ///蓝牙通道：pwd 透传，流式监听录入结果，done 时取 hardwareId
    Future<DoorLockAddResult> sendByBlue() async {
      if (await beforeBlue() == false) {
        return const DoorLockAddResult(false, -1, null, null);
      }
      final completer = Completer<DoorLockAddResult>();
      StreamSubscription<DoorLockAddBleOpenTypeResponse>? sub;
      try {
        sub = doorLockBleApi
            ?.addDoorOpenType(DoorLockAddBleOpenTypeRequest(
          type: BleOperateType.from(JvssOperateType.password.toBleType()),
          stage: BleInputStage.start,
          memberId: isAdmin ? 2 : 1,
          timelinessType: DoorLockTimelinessType.permanent,
          pwdContent: pwd,
        ))
            ?.listen((response) {
          switch (response.stage) {
            case BleInputStage.start:
            case BleInputStage.process:
              break;
            case BleInputStage.done:
              sub?.cancel();
              if (!completer.isCompleted) {
                completer.complete(
                    DoorLockAddResult(true, response.hardwareId, null, null));
              }
              break;
            default:
              sub?.cancel();
              if (!completer.isCompleted) {
                completer
                    .complete(const DoorLockAddResult(false, -1, null, null));
              }
              break;
          }
        });
      } catch (e) {
        LogUtils.doorLock.log('doorLockAddPasswordType sendByBlue error: $e');
        return const DoorLockAddResult(false, -1, null, null);
      }
      if (sub == null) {
        return const DoorLockAddResult(false, -1, null, null);
      }

      ///兜底超时，避免锁端无响应时流式监听长期挂起
      return completer.future.timeout(const Duration(seconds: 40),
          onTimeout: () {
        sub?.cancel();
        return const DoorLockAddResult(false, -1, null, null);
      });
    }

    ///netip 通道：先保活（syncDoorStatus）刷新同步状态，再添加，避免 needSync
    Future<DoorLockAddResult> sendByNetIp() async {
      var sync = await DoorLockNetIp.syncDoorStatus(deviceId);
      if (!sync.item1) {
        return DoorLockAddResult(false, -1, sync.item2?.err, sync.item3);
      }
      var result = await DoorLockNetIp.addDoorOpenType(
        deviceId: deviceId,
        type: JvssOperateType.password,
        isAdmin: isAdmin,
        pwd: pwd,
      );
      if (result.item1 && result.item2?.parse is DookLockOpenTypeUser) {
        final id = (result.item2!.parse as DookLockOpenTypeUser).id;
        return DoorLockAddResult(true, id, null, null);
      }
      return DoorLockAddResult(false, -1, result.item2?.err, result.item3);
    }

    if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi) {
      return sendByNetIp();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue ||
        device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
      return sendByBlue();
    } else {
      ///离线：低功耗/海外锁先搜蓝牙，等到在线后走 BLE 添加
      if (DoorLockHelper.isLowPowerBle(deviceId) ||
          DoorLockHelper.isOverSeaDoorLock(deviceId)) {
        bool online = await waitBleOnline();
        if (online) {
          return sendByBlue();
        }
      }
      return const DoorLockAddResult(false, -1, null, null);
    }
  }

  ///添加开锁方式（锁端录入类：指纹/卡片等，无 pwd）
  ///
  ///与 [doorLockAddPasswordType] 的差异：BLE 通道流式回调 [listen]
  ///（指纹需多次按压，start 携带总录入次数，process 携带当前序号）。
  ///时效为限时/循环时仅支持蓝牙通道（netip 明文 AddUser 不携带时效），
  ///按 [DoorLockTimelinessType] + 时效字段生成 8 字节 timeliness hex 下发。
  Future<DoorLockAddResult> doorLockAddOpenType({
    required JvssOperateType type,
    required bool isAdmin,
    DoorLockTimelinessType? timelinessType,
    DateTime? startTime,
    DateTime? endTime,
    List<int>? weeks, //周日为 0
    int? startMin,
    int? endMin,
    Function(DoorLockAddBleOpenTypeResponse)? listen,
  }) async {
    ///时效 hex（永久为空，限时/循环 8 字节）
    var timeliness = timelinessType == null
        ? null
        : getTimelinessBleFormat(
            type: timelinessType,
            startTime: startTime,
            endTime: endTime,
            weeks: weeks,
            startMin: startMin,
            endMin: endMin,
          );
    var bleTimelinessType = timelinessType ?? DoorLockTimelinessType.permanent;

    ///蓝牙通道：流式监听录入结果，done 时取 hardwareId
    Future<DoorLockAddResult> sendByBlue() async {
      if (await beforeBlue() == false) {
        return const DoorLockAddResult(false, -1, null, null);
      }
      final completer = Completer<DoorLockAddResult>();
      StreamSubscription<DoorLockAddBleOpenTypeResponse>? sub;
      try {
        sub = doorLockBleApi
            ?.addDoorOpenType(DoorLockAddBleOpenTypeRequest(
          type: BleOperateType.from(type.toBleType()),
          stage: BleInputStage.start,
          memberId: isAdmin ? 2 : 1,
          timelinessType: bleTimelinessType,
          timeliness: timeliness,
        ))
            ?.listen((response) {
          listen?.call(response);
          switch (response.stage) {
            case BleInputStage.start:
            case BleInputStage.process:
              break;
            case BleInputStage.done:
              sub?.cancel();
              if (!completer.isCompleted) {
                completer.complete(
                    DoorLockAddResult(true, response.hardwareId, null, null));
              }
              break;
            case BleInputStage.fail:
            case BleInputStage.appCancel:
            default:
              sub?.cancel();
              if (!completer.isCompleted) {
                completer
                    .complete(const DoorLockAddResult(false, -1, null, null));
              }
              break;
          }
        });
      } catch (e) {
        LogUtils.doorLock.log('doorLockAddOpenType sendByBlue error: $e');
        return const DoorLockAddResult(false, -1, null, null);
      }
      if (sub == null) {
        return const DoorLockAddResult(false, -1, null, null);
      }

      ///兜底超时：指纹录入需多次按压耗时较长，取消/失败回包也会走 fail/appCancel 分支收尾
      return completer.future.timeout(const Duration(seconds: 120),
          onTimeout: () {
        sub?.cancel();
        return const DoorLockAddResult(false, -1, null, null);
      });
    }

    ///netip 通道：先保活（syncDoorStatus）刷新同步状态，再添加，避免 needSync
    Future<DoorLockAddResult> sendByNetIp() async {
      var sync = await DoorLockNetIp.syncDoorStatus(deviceId);
      if (!sync.item1) {
        return DoorLockAddResult(false, -1, sync.item2?.err, sync.item3);
      }
      var result = await DoorLockNetIp.addDoorOpenType(
        deviceId: deviceId,
        type: type,
        isAdmin: isAdmin,
      );
      if (result.item1 && result.item2?.parse is DookLockOpenTypeUser) {
        final id = (result.item2!.parse as DookLockOpenTypeUser).id;
        return DoorLockAddResult(true, id, null, null);
      }
      return DoorLockAddResult(false, -1, result.item2?.err, result.item3);
    }

    ///限时/循环仅支持蓝牙通道（netip 明文 AddUser 不携带时效）
    bool onlyBlue = timelinessType == DoorLockTimelinessType.limit ||
        timelinessType == DoorLockTimelinessType.loop;

    if (onlyBlue) {
      if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue ||
          device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
        return sendByBlue();
      }

      ///离线：低功耗/海外锁先搜蓝牙，等到在线后走 BLE 添加
      if (DoorLockHelper.isLowPowerBle(deviceId) ||
          DoorLockHelper.isOverSeaDoorLock(deviceId)) {
        bool online = await waitBleOnline();
        if (online) {
          return sendByBlue();
        }
      }
      return const DoorLockAddResult(false, -1, null, null);
    }

    if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi) {
      return sendByNetIp();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue ||
        device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
      return sendByBlue();
    } else {
      ///离线：低功耗/海外锁先搜蓝牙，等到在线后走 BLE 添加
      if (DoorLockHelper.isLowPowerBle(deviceId) ||
          DoorLockHelper.isOverSeaDoorLock(deviceId)) {
        bool online = await waitBleOnline();
        if (online) {
          return sendByBlue();
        }
      }
      return const DoorLockAddResult(false, -1, null, null);
    }
  }

  ///取消添加开锁方式（录入页用户主动退出时调）
  ///
  ///BLE 通道发送 stage=appCancel，锁端回包会同时让原 [doorLockAddOpenType]
  ///的流式监听以 appCancel 收场；netip 通道直接发 CancelAdd 指令。
  ///取消本身不看重结果，失败仅日志。
  Future<void> cancelDoorLockAddOpenType({
    required JvssOperateType type,
    required bool isAdmin,
  }) async {
    try {
      if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue ||
          device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
        if (doorLockBleApi == null) return;
        await doorLockBleApi
            ?.addDoorOpenType(DoorLockAddBleOpenTypeRequest(
              type: BleOperateType.from(type.toBleType()),
              stage: BleInputStage.appCancel,
              memberId: isAdmin ? 2 : 1,
              timelinessType: DoorLockTimelinessType.permanent,
            ))
            ?.drain()
            .timeout(const Duration(seconds: 5));
      } else if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi) {
        await DoorLockNetIp.addDoorOpenType(
                deviceId: deviceId,
                type: type,
                isAdmin: isAdmin,
                isCancel: true)
            .timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      LogUtils.doorLock.log('cancelDoorLockAddOpenType error: $e');
    }
  }

  ///获取锁端开锁方式（按设备通道自动路由 BLE / netip）
  Future<List<DoorUser>> getLockEndUnlockingList(
      {JvssOperateType? type}) async {
    ///蓝牙通道：直连锁端读取
    Future<List<DoorUser>> sendByBlue() async {
      if (await beforeBlue() == false) return [];
      var bleType = type != null ? BleOperateType.from(type.toBleType()) : null;
      try {
        var result = await doorLockBleApi?.getDoorOpenType(type: bleType) ?? [];
        return result.map((e) => DoorUser.fromLockModel(e)).toList();
      } catch (e) {
        LogUtils.doorLock.log('getLockEndUnlockingList sendByBlue error: $e');
        return [];
      }
    }

    ///netip 通道：先保活（syncDoorStatus）再拉取，返回归一化 DoorUser
    Future<List<DoorUser>> sendByNetIp() async {
      var sync = await DoorLockNetIp.syncDoorStatus(deviceId);
      if (!sync.item1) {
        LogUtils.doorLock
            .log('getLockEndUnlockingList 保活失败: ${sync.item2?.err}');
        return [];
      }

      ///单类型拉取一次：失败返回 null（区别于“该类型无用户”的空列表）
      Future<List<DoorUser>?> queryOnce(JvssOperateType queryType) async {
        var result = await DoorLockNetIp.getDoorOpenType(
            deviceId: deviceId, type: queryType);
        if (result.item1 && result.item2?.parse is List) {
          return (result.item2!.parse as List)
              .whereType<DookLockOpenTypeUser>()
              .map((e) => DoorUser.fromOpenTypeUser(e))
              .toList();
        }
        LogUtils.doorLock.log(
            'getLockEndUnlockingList netip 拉取失败 type=${queryType.value}: ${result.item2?.err}');
        return null;
      }

      ///指定单类型：只拉该类型
      if (type != null) {
        return await queryOnce(type) ?? [];
      }

      ///全量：按能力集逐类型串行拉取，某类型失败即中断（避免半量上报）
      var ability = device.doorUserAbility?.byte1;
      var types = <JvssOperateType>[
        if (ability?.supportPassword == true) JvssOperateType.password,
        if (ability?.supportSkin == true) JvssOperateType.skin,
        if (ability?.supportFace == true) JvssOperateType.face,
        if (ability?.supportPalmprint == true) JvssOperateType.palmprint,
        if (ability?.supportFingervein == true) JvssOperateType.fingervein,
        if (ability?.supportCard == true) JvssOperateType.card,
        if (ability?.supportPalmVein == true) JvssOperateType.palmVein,
      ];
      if (types.isEmpty) return [];
      var all = <DoorUser>[];
      for (var t in types) {
        var list = await queryOnce(t);
        if (list == null) break;
        all.addAll(list);
      }
      return all;
    }

    if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi) {
      return sendByNetIp();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue ||
        device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
      return sendByBlue();
    } else {
      ///离线：低功耗/海外锁先搜蓝牙，等到在线后走 BLE 读取
      if (DoorLockHelper.isLowPowerBle(deviceId) ||
          DoorLockHelper.isOverSeaDoorLock(deviceId)) {
        bool online = await waitBleOnline();
        if (online) {
          return sendByBlue();
        }
      }
      return [];
    }
  }
}
