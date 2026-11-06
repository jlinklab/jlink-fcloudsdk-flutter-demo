import 'dart:async';
import 'dart:convert';

import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/door_lock/ble_upgrade.dart';
import 'package:fcloudsdk/door_lock/door_lock_ble_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_ble_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_date.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_key_value.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_model.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/api/door_lock_api.dart';
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
import 'package:fcloudsdk_example/utils/permission_utils.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:tuple/tuple.dart';
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
  ///[showAnotherOperatingTip]为false时Err=10不弹窗，由调用方按兜底数据自行决定提示
  ///最近一次 beforeNetIp 保活失败的原始异常（成功时清空），供录入链路带回页面
  dynamic lastNetIpSyncError;

  Future<bool> beforeNetIp(
      {bool showLoading = true,
      bool ignoreAddUserAdminNotskip = true,
      bool needKeepAlive = true,
      bool showErrorTip = true,
      bool showAnotherOperatingTip = true}) async {
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
      ///Start 超时(-99991)兜底：锁端可能瞬时不可达（如配网后重启中），
      ///清缓存后强制真实同步重试一次
      if (result.item1 == false &&
          result.item3 is XCloudAPIException &&
          (result.item3 as XCloudAPIException).code == -99991) {
        LogUtils.doorLock.log('beforeNetIp sync timeout(-99991)，clear keepAlive then retry once');
        DoorLockNetIp.clearKeepAliveState(deviceId);
        result = await DoorLockNetIp.syncDoorStatus(deviceId,
            ignoreKeepAlive: true);
      }
      showLoading ? KToast.dismiss() : null;

      ///记录同步失败原因，供调用方带回页面展示（成功时清空）
      lastNetIpSyncError = result.item1 ? null : result.item3;

      ///其他用户正在操作(Err=10)
      if (result.item1 == false &&
          result.item2?.err == DoorLockNetIpOperaterResult.anotherOperating) {
        if (showAnotherOperatingTip) {
          KToast.show(status: '其他用户正在操作，请稍后再试');
        }
        return false;
      }

      ///正常情况下addUserAdminNotskip也视为成功，除非特殊场景如验证管理员、用户管理等
      if (!ignoreAddUserAdminNotskip &&
          result.item2?.err ==
              DoorLockNetIpOperaterResult.addUserAdminNotskip) {
        if (showErrorTip) {
          ///锁端要求先添加或修改管理员密码（不可跳过）
          KToast.show(status: '请先添加管理员密码');
        }
        return false;
      }

      if (result.item1 == false) {
        if (result.item3 is XCloudAPIException &&
            (result.item3 as XCloudAPIException).code == -70102) {
          ///版本不支持，则忽略，不提示, 视为成功
          return true;
        }

        ///锁端深度休眠(-99968)：不受 loading 开关影响，避免调用方关掉
        ///loading 后错误被吞掉，界面只剩“添加失败/未知错误”
        if (showErrorTip &&
            result.item3 is XCloudAPIException &&
            (result.item3 as XCloudAPIException).code == -99968) {
          KToast.show(status: '设备深度休眠，请稍后重试');
          return false;
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

  ///系统蓝牙开关是否打开
  ///
  ///指令通道状态(doolockCmdStatus)依赖扫描结果刷新，关闭系统蓝牙后
  ///会存在状态仍为 wifiAndBlue 的窗口，此时走蓝牙会一直等到超时(99991)；
  ///用系统开关状态前置判断，关闭时直接改走 WiFi。查询异常按打开处理
  Future<bool> get isBlueSwitchOn async {
    try {
      return await PermissionUtils.checkPermission(
          permission: XPermission.blueSwitch, onlyStatus: true);
    } catch (e) {
      LogUtils.doorLock.log('check blue switch error: $e');
      return true;
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
  ///离线密码锁端删除需携带密码内容，用于删除未激活的离线密码
  Future<DoorLockDeleteResult> doorLockDeleteType(
    int id,
    JvssOperateType type,
    bool isAdmin, {
    String? pwd,
  }) async {
    ///蓝牙通道：直连锁端删除
    Future<DoorLockDeleteResult> sendByBlue() async {
      if (await beforeBlue() == false) {
        ///蓝牙 API 未创建成功（蓝牙已断开/未在线/uuid 缺失），
        ///直接带回文案，避免页面只弹“未知错误”
        return const DoorLockDeleteResult(false, null, '蓝牙连接已断开，请检查蓝牙开关');
      }
      bool ok = false;
      try {
        ok = await doorLockBleApi
                ?.deleteDoorOpenType(DoorLockDeleteBleOpenTypeRequest(
              deleteType: 0x01,
              type: BleOperateType.from(type.toBleType()),
              hardwareId: id,
              memberId: isAdmin ? 2 : 1,
              pwdContent: pwd,
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
        ///锁端深度休眠：带回明确文案，避免页面直接展示异常对象
        if (sync.item3 is XCloudAPIException &&
            (sync.item3 as XCloudAPIException).code == -99968) {
          return const DoorLockDeleteResult(false, null, '设备深度休眠，请稍后重试');
        }
        return DoorLockDeleteResult(false, sync.item2?.err, sync.item3);
      }

      ///离线密码走wifi半透传删除：用户ID固定0xFFFF并携带密码内容，
      ///可删除未激活/未使用的离线密码
      if (type == JvssOperateType.offLinePwd) {
        var trans = await deleteOfflinePwdWifiTrans(pwd: pwd ?? '');
        LogUtils.doorLock
            .log('deleteOfflinePwdWifiTrans result=${trans.item2}');
        return DoorLockDeleteResult(
            trans.item1, null, trans.item1 ? null : trans.item2);
      }
      var result = await DoorLockNetIp.deleteDoorOpenType(
          deviceId: deviceId, type: type, id: id);
      return DoorLockDeleteResult(
          result.item1, result.item2?.err, result.item3);
    }

    ///蓝牙通道
    ///增加权限判断 兜底极限情况
    Future<DoorLockDeleteResult> sendByBlueWithSwitchCheck() async {
      ///系统蓝牙已关闭但通道状态未重算时，直接走 WiFi
      if (!await isBlueSwitchOn) {
        LogUtils.doorLock
            .log('doorLockDeleteType blue switch off, fallback sendByNetIp');
        return sendByNetIp();
      }

      return sendByBlue();
    }

    ///离线密码删除的wifi半透传从V2开始才支持，能力集不支持时只能用蓝牙
    bool onlyBlue = type == JvssOperateType.offLinePwd &&
        !supportUserManagerWifiTransV2(
            action: DoorLockUserManagerAction.deleteUser);

    if (onlyBlue) {
      if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue ||
          device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
        return sendByBlue();
      }

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

    if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi) {
      LogUtils.doorLock.log('doorLockDeleteType DoolockCmdStatus.onlyWifi');
      return sendByNetIp();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue) {
      return sendByBlueWithSwitchCheck();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
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
      ///添加管理员密码时需忽略'未添加管理员'错误（本次添加正是要设置管理员密码），
      ///普通用户密码不忽略，锁端未添加管理员时直接提示终止
      if (await beforeNetIp(
              showLoading: false, ignoreAddUserAdminNotskip: isAdmin) ==
          false) {
        return const DoorLockAddResult(false, -1, null, null);
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
      LogUtils.doorLock
          .log('doorLockAddPasswordType DoolockCmdStatus.onlyWifi');
      return sendByNetIp();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue) {
      ///系统蓝牙已关闭但通道状态未重算时，直接走 WiFi
      if (!await isBlueSwitchOn) {
        LogUtils.doorLock
            .log('doorLockAddPasswordType blue switch off, sendByNetIp');
        return sendByNetIp();
      }
      return sendByBlue();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
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

  ///删除离线密码-wifi透传方式
  ///用户ID固定传0xFFFF并携带密码内容，可删除未激活/未使用的离线密码
  ///cmd: [0x03=删除用户, 0x02=V2版本, 用户ID(2字节)=0xFFFF, 0x07, 密码长度, ...密码字节]
  ///0x07是几维V2用户管理协议的离线密码类型（jwCode表），
  ///与JvssOperateType.offLinePwd（8）不同表，勿改成0x08
  Future<Tuple2<bool, DoorLockUserManagerWifiTransResult>>
      deleteOfflinePwdWifiTrans({
    required String pwd,
    int? timeout,
  }) async {
    try {
      var pwdBytes = pwdToByte(pwd);
      var cmd = [0x03, 0x02, 0xFF, 0xFF, 0x07, pwdBytes.length, ...pwdBytes];
      final rawData =
          DoorLockNetIpWifiTransExtUserManager.getUserManagerRawData(cmd);
      var result =
          await DoorLockNetIpWifiTransExtUserManager.sendUserManagerWifiCmd(
              deviceId: deviceId, rawData: rawData, timeout: timeout);
      if (result.item1 == true) {
        var rawStr = result.item2?.data['RawData'];
        if (rawStr != null) {
          var bytes = base64Decode(rawStr).toList();
          if (bytes.length > 4) {
            var actionResult =
                DoorLockUserManagerWifiTransResult.from(bytes[4]);
            return Tuple2(
                actionResult == DoorLockUserManagerWifiTransResult.success,
                actionResult);
          }
        }
        return const Tuple2(false, DoorLockUserManagerWifiTransResult.unknown);
      }
      return const Tuple2(false, DoorLockUserManagerWifiTransResult.unknown);
    } catch (e) {
      LogUtils.doorLock.log('deleteOfflinePwdWifiTrans error: $e');
      return const Tuple2(false, DoorLockUserManagerWifiTransResult.unknown);
    }
  }

  ///支持用户管理Wifi透传v2协议，[action]指定查询的动作，默认为添加用户
  bool supportUserManagerWifiTransV2(
      {DoorLockUserManagerAction action = DoorLockUserManagerAction.addUser}) {
    return (device.doorLockActionVerList ?? [])
        .any((e) => e.action == action.value && e.version == 2);
  }

  ///支持用户管理Wifi透传v3协议（含限时/循环/归属）
  bool supportUserManagerWifiTransV3() {
    return (device.doorLockActionVerList ?? []).any((e) =>
        e.action == DoorLockUserManagerAction.addUser.value && e.version == 3);
  }

  ///添加用户是否走Wifi透传流式通道
  ///
  ///指纹为多次按压录入类，仅 v2/v3 透传协议或支持指纹录入次数返回的设备可走；
  ///其他类型仅 v3 协议支持
  bool canAddUserByWifiTrans(JvssOperateType type) {
    final v3 = supportUserManagerWifiTransV3();
    if (type == JvssOperateType.skin) {
      final v2 = supportUserManagerWifiTransV2();
      final supportSkinCountReturn =
          device.doorLockExInfo?.byte2.supportFingerprintCountReturn ?? false;
      return v3 || v2 || supportSkinCountReturn;
    }
    return v3;
  }

  ///生成添加用户wifi透传请求
  DoorLockAddWifiTransOpenTypeRequest generateAddUserWifiTransRequest({
    required JvssOperateType type,
    required bool isAdmin,
    DoorLockTimelinessType? timelinessType,
    DateTime? startTime,
    DateTime? endTime,
    List<int>? weeks, //周日为 0
    int? startMin,
    int? endMin,
  }) {
    int version = 0x02;
    if (supportUserManagerWifiTransV3()) {
      version = 0x03;
    }

    final authority = isAdmin
        ? DoorLockUserManagerAuthority.admin
        : DoorLockUserManagerAuthority.fromTimelinessType(
            timelinessType ?? DoorLockTimelinessType.permanent);

    final limit = creatWifiTransLimit(
      authority: authority,
      startTime: startTime,
      endTime: endTime,
      weeks: weeks,
      startMin: startMin,
      endMin: endMin,
    );

    return DoorLockAddWifiTransOpenTypeRequest(
      version: version,
      type: type,
      authority: authority,
      limit: limit,
    );
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
    Function(dynamic)? listen,
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

    ///netip 通道：先保活（syncDoorStatus）刷新同步状态，再添加，避免 needSync；
    ///锁端未添加管理员密码时（0x10）不忽略，直接提示'请先添加管理员密码'终止
    Future<DoorLockAddResult> sendByNetIp() async {
      if (await beforeNetIp(
              showLoading: false, ignoreAddUserAdminNotskip: false) ==
          false) {
        ///带回保活失败原因（如 -99991 超时），供页面提示而非笼统的“录入失败”
        return DoorLockAddResult(false, -1, null, lastNetIpSyncError);
      }
      final completer = Completer<DoorLockAddResult>();
      if (canAddUserByWifiTrans(type)) {
        ///wifi透传流式添加：指纹多次按压，start 携带总录入次数，
        ///process 携带当前序号，done 且 success 才完成并取 userId
        final request = generateAddUserWifiTransRequest(
          type: type,
          isAdmin: isAdmin,
          timelinessType: timelinessType,
          startTime: startTime,
          endTime: endTime,
          weeks: weeks,
          startMin: startMin,
          endMin: endMin,
        );
        var stream =
            await DoorLockNetIpWifiTransExtUserManager.addDoorWifiTransOpenType(
                deviceId: deviceId, request: request);
        StreamSubscription<DoorLockAddWifiTransOpenTypeResponse>? sub;
        sub = stream?.listen((DoorLockAddWifiTransOpenTypeResponse response) {
          listen?.call(response);

          ///异常情况
          if (response.result != DoorLockUserManagerWifiTransResult.success &&
              response.result !=
                  DoorLockUserManagerWifiTransResult.skinIncomplete) {
            if (response.result ==
                DoorLockUserManagerWifiTransResult.remoteFaceCat) {
              ///远程人脸录入结果，给猫眼用的，app忽略
              return;
            }
            sub?.cancel();

            ///会话失效（needSync）：透传错误码供页面提示"同步状态过期"
            if (response.err == DoorLockNetIpOperaterResult.needSync.value) {
              if (!completer.isCompleted) {
                completer.complete(const DoorLockAddResult(
                    false, -1, DoorLockNetIpOperaterResult.needSync, null));
              }
              return;
            }
            if (!completer.isCompleted) {
              completer
                  .complete(const DoorLockAddResult(false, -1, null, null));
            }
            return;
          }
          switch (response.stage) {
            case WifiInputStage.start:
            case WifiInputStage.process:
              break;
            case WifiInputStage.done:
              if (response.result ==
                  DoorLockUserManagerWifiTransResult.success) {
                sub?.cancel();
                if (!completer.isCompleted) {
                  completer.complete(
                      DoorLockAddResult(true, response.userId, null, null));
                }
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
        if (sub == null) {
          return const DoorLockAddResult(false, -1, null, null);
        }
        final kSub = sub;

        ///兜底超时：指纹录入需多次按压耗时较长
        return completer.future.timeout(const Duration(seconds: 120),
            onTimeout: () {
          kSub.cancel();
          return const DoorLockAddResult(false, -1, null, null);
        });
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

    ///限时/循环优先走 wifi透传 v3（明文 netip AddUser 不携带时效），
    ///v3 不支持时仅能走蓝牙通道
    bool onlyBlue = false;
    if (timelinessType == DoorLockTimelinessType.limit ||
        timelinessType == DoorLockTimelinessType.loop) {
      if (!supportUserManagerWifiTransV3()) {
        onlyBlue = true;
      }
    }

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
      LogUtils.doorLock.log('doorLockAddOpenType DoolockCmdStatus.onlyWifi');
      return sendByNetIp();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue) {
      ///系统蓝牙已关闭但通道状态未重算时，直接走 WiFi
      if (!await isBlueSwitchOn) {
        LogUtils.doorLock
            .log('doorLockAddOpenType blue switch off, sendByNetIp');
        return sendByNetIp();
      }
      return sendByBlue();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
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
      ///系统蓝牙已关闭时取消也走 netip，保持与添加实际通道一致
      bool useBlue = false;
      if (device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
        useBlue = true;
      } else if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue) {
        useBlue = await isBlueSwitchOn;
      }

      if (useBlue) {
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
      } else if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi ||
          device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue) {
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
  ///[showAnotherOperatingTip]为false时Err=10不弹窗，由调用方按兜底数据自行决定提示
  ///[offlineSink]传入后，BLE 全量查询时把锁端离线密码条目分流进来，
  ///供上层覆盖上报 unlockInfo（避免为补报再单独查一次锁端）
  Future<List<DoorUser>> getLockEndUnlockingList(
      {JvssOperateType? type,
      bool showAnotherOperatingTip = false,
      List<DoorLockUnlockModel>? offlineSink}) async {
    ///蓝牙通道：直连锁端读取
    Future<List<DoorUser>> sendByBlue() async {
      if (await beforeBlue() == false) return [];
      var bleType = type != null ? BleOperateType.from(type.toBleType()) : null;
      try {
        var result = await doorLockBleApi?.getDoorOpenType(type: bleType) ?? [];

        ///全量查询时顺带收集锁端离线密码
        if (bleType == null && offlineSink != null) {
          offlineSink.addAll(result.where(
              (e) => e.hardwareType == DoorLockBleHardwareType.offLinePwd));
        }
        return result.map((e) => DoorUser.fromLockModel(e)).toList();
      } catch (e) {
        LogUtils.doorLock.log('getLockEndUnlockingList sendByBlue error: $e');
        return [];
      }
    }

    ///netip 通道：先保活（syncDoorStatus）再拉取，返回归一化 DoorUser
    Future<List<DoorUser>> sendByNetIp() async {
      if (await beforeNetIp(
              showLoading: false,
              showErrorTip: false,
              showAnotherOperatingTip: showAnotherOperatingTip) ==
          false) {
        LogUtils.doorLock
            .log('getLockEndUnlockingList 保活失败: anotherOperating 或其他错误');
        return [];
      }

      ///单类型拉取一次：失败返回 null（区别于“该类型无用户”的空列表）
      ///拉取报 needSync 时说明 App 侧保活会话与锁端已失联（锁端判定过期），
      ///清保活缓存强制真实同步后重试一次，仍失败才返回 null
      Future<List<DoorUser>?> queryOnce(JvssOperateType queryType) async {
        var result = await DoorLockNetIp.getDoorOpenType(
            deviceId: deviceId, type: queryType);
        if (result.item1 && result.item2?.parse is List) {
          return (result.item2!.parse as List)
              .whereType<DookLockOpenTypeUser>()
              .map((e) => DoorUser.fromOpenTypeUser(e))
              .toList();
        }
        if (result.item2?.err == DoorLockNetIpOperaterResult.needSync) {
          LogUtils.doorLock.log(
              'getLockEndUnlockingList netip 拉取 needSync type=${queryType.value}，清保活缓存后重新同步重试');
          DoorLockNetIp.clearKeepAliveState(deviceId);
          var syncResult = await DoorLockNetIp.syncDoorStatus(deviceId,
              ignoreKeepAlive: true);
          if (syncResult.item1) {
            var retry = await DoorLockNetIp.getDoorOpenType(
                deviceId: deviceId, type: queryType);
            if (retry.item1 && retry.item2?.parse is List) {
              return (retry.item2!.parse as List)
                  .whereType<DookLockOpenTypeUser>()
                  .map((e) => DoorUser.fromOpenTypeUser(e))
                  .toList();
            }
            LogUtils.doorLock.log(
                'getLockEndUnlockingList netip 重试仍失败 type=${queryType.value}: ${retry.item2?.err}');
            return null;
          }
          LogUtils.doorLock.log(
              'getLockEndUnlockingList 重新同步失败 err=${syncResult.item2?.err}，跳过重试');
          return null;
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
      LogUtils.doorLock.log(
          'getLockEndUnlockingList 全量拉取类型: $types（能力位 doorUserAbility=${ability != null}）');
      if (types.isEmpty) return [];
      var all = <DoorUser>[];
      for (var t in types) {
        var list = await queryOnce(t);
        if (list == null) {
          LogUtils.doorLock.log('getLockEndUnlockingList 全量拉取中断: type=$t 拉取失败');
          break;
        }
        LogUtils.doorLock
            .log('getLockEndUnlockingList 全量拉取 type=$t 拉到 ${list.length} 条');
        all.addAll(list);
      }
      return all;
    }

    if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi) {
      return sendByNetIp();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue) {
      ///系统蓝牙已关闭但通道状态未重算时，直接走 WiFi
      if (!await isBlueSwitchOn) {
        LogUtils.doorLock
            .log('getLockEndUnlockingList blue switch off, sendByNetIp');
        return sendByNetIp();
      }
      return sendByBlue();
    } else if (device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
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

  ///锁端同步补报离线密码开锁方式
  ///
  ///锁端同步除 doorLockUser 全量上报外，还会把锁端离线密码（含已使用
  ///后失效的单次密码）全量上报 /unlockInfo/syncUnlockInfo（覆盖式语义）
  ///
  ///[models] 为全量查询里已分出的离线密码条目：传入后不再重复查锁端；
  ///传空列表表示锁端无离线密码记录，直接跳过
  Future<void> syncOfflinePwdUnlockInfo(
      {List<DoorLockUnlockModel>? models}) async {
    if (device.doorLockExInfo?.byte1.supportLockEndOffLinePwd == false) {
      LogUtils.doorLock.log('syncOfflinePwdUnlockInfo: 锁端不支持离线密码，跳过');
      return;
    }

    ///未从全量结果中分到离线密码时无需补报，也不重复查询锁端
    if (models != null && models.isEmpty) return;

    if (await beforeBlue() == false || doorLockBleApi == null) {
      LogUtils.doorLock.log('syncOfflinePwdUnlockInfo: 蓝牙不可达，跳过');
      return;
    }
    try {
      final lockModels = models ??
          await doorLockBleApi!
              .getDoorOpenType(type: BleOperateType.offlinePwd)
              .timeout(const Duration(seconds: 30));
      final infos = <Map<String, dynamic>>[
        for (final m in lockModels)
          if (m.hardwareType == DoorLockBleHardwareType.offLinePwd)
            {
              'name': m.pwd ?? '',
              'deviceSn': deviceId,
              'unlockMode': '0x${bytesToHex([m.hardwareTypeOri])}',
              'validTime': m.timeliness,
              'validType': bytesToHex([m.timelinessTypeOri]),
              'hardwareId': m.hardwareId,
              'memberId': m.memberId,
              'createTime': DateTime.now().millisecondsSinceEpoch ~/ 1000,
              'password': m.pwd ?? '',
            }
      ];
      LogUtils.doorLock
          .log('syncOfflinePwdUnlockInfo: 锁端离线密码 ${infos.length} 条');

      ///锁端无离线密码记录时不上报
      if (infos.isEmpty) return;

      await doorlockAPI.syncUnlockInfo(
        deviceSn: deviceId,
        syncTime: DateTime.now().millisecondsSinceEpoch,
        infoDTOS: infos,
      );
      LogUtils.doorLock.log('syncOfflinePwdUnlockInfo: 覆盖上报成功');
    } catch (e) {
      LogUtils.doorLock.log('syncOfflinePwdUnlockInfo 异常: $e');
    }
  }
}
