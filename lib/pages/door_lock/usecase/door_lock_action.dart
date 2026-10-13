import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/api/door_lock_api.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/global_ble_search_manager.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/utils/map_utils.dart';
import 'package:fcloudsdk_example/utils/permission_utils.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';

/// 门锁常用操作
mixin DoorLockActionMixin on ChangeNotifier, DoorLockOperationMixin {
  @override
  BuildContext get context;

  // ==================== 开关锁 ====================

  bool needTipOpenOrCloseLock = true; // 是否需要提示打开/关闭锁

  ///开锁
  unlockDoorSample({
    bool showLoading = true,
    bool needSleep = true,
  }) async {
    if (await _checkNeedTipOpenOrCloseLock(isUnlock: true)) return;

    _executeAction(true, showLoading: showLoading, needSleep: needSleep);
  }

  ///关锁
  lockDoorSample({
    bool showLoading = true,
    bool needSleep = true,
  }) async {
    if (await _checkNeedTipOpenOrCloseLock(isUnlock: false)) return;

    _executeAction(false, showLoading: showLoading, needSleep: needSleep);
  }

  /// 门锁首页开锁
  unlockDoorInHome({
    bool showLoading = true,
    bool needSleep = true,
  }) async {
    needTipOpenOrCloseLock = true;

    if (checkDeviceStateNeedDialog()) return;

    if (await checkDeviceIsNotNearby()) return;

    if (await checkBlePermissionIfNeed()) return;

    if (checkFakeNetIfNeed()) return;

    unlockDoorSample(showLoading: showLoading, needSleep: needSleep);
  }

  /// 门锁首页关锁
  lockDoorInHome({
    bool showLoading = true,
    bool needSleep = true,
  }) async {
    needTipOpenOrCloseLock = true;

    if (checkDeviceStateNeedDialog()) return;

    if (await checkDeviceIsNotNearby()) return;

    if (await checkBlePermissionIfNeed()) return;

    if (checkFakeNetIfNeed()) return;

    lockDoorSample(showLoading: showLoading, needSleep: needSleep);
  }

  // ==================== 设备状态检查 ====================

  /// 检查设备状态是否弹窗中断，返回 true，表示中断
  bool checkDeviceStateNeedDialog() {
    final state = _deviceTipState;
    if (state == null) return false;

    if (state == DeviceSleepState.offline &&
        (DoorLockHelper.isLowPowerBle(deviceId) ||
            !DoorLockHelper.isOverSeaDoorLock(deviceId))) {
      KToast.show(status: TR.current.channelOffline);
      return true;
    } else if (state == DeviceSleepState.deepSleep &&
        (device.propList ?? []).contains('powerSavingMode')) {
      KToast.show(status: TR.current.tr_error_code_1020);
    } else {
      KToast.show(status: state.toString());
    }

    needTipOpenOrCloseLock = false;
    return true;
  }

  /// 需要弹窗提示的设备状态（null 表示无需提示）
  DeviceSleepState? get _deviceTipState {
    if (DoorLockHelper.isLowPowerBle(deviceId) ||
        DoorLockHelper.isOverSeaDoorLock(deviceId)) {
      ///低功耗蓝牙锁&海外锁，可以强行去连接蓝牙，所以放过去，除了BK100W
      if (DoorLockHelper.isBKOverseaDoorLock(deviceId)) {
        if (device.sleepState == DeviceSleepState.offline ||
            device.sleepState == DeviceSleepState.deepSleep ||
            device.sleepState == DeviceSleepState.preSleep) {
          return device.sleepState;
        }
        if (device.doorlockIsConfigNet && device.state <= 0) {
          return DeviceSleepState.offline;
        }
      }
    } else {
      ///比亚迪锁
      if (device.sleepState == DeviceSleepState.offline ||
          device.sleepState == DeviceSleepState.deepSleep) {
        return device.sleepState;
      }
      if (device.doorlockIsConfigNet && device.state <= 0) {
        return DeviceSleepState.offline;
      }
    }

    return null;
  }

  // ==================== 不在附近检测 ====================

  /// 检查设备是否在附近，返回 true 表示中断
  Future<bool> checkDeviceIsNotNearby() async {
    if (DoorLockHelper.checkNeedTipsDeviceIsNotNearby(deviceId)) {
      needTipOpenOrCloseLock = false;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('提示'),
          content: Text(TR.current.tr_ble_doorlock_connect_fail_confirm_tips),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确认'),
            ),
          ],
        ),
      );
      // 取消 → 中断
      if (confirmed != true) {
        return true;
      }
      return false;
    }
    return false;
  }

  // ==================== 提示开关锁检测 ====================

  /// 提示开关锁检测, 返回 true 表示中断
  Future<bool> _checkNeedTipOpenOrCloseLock({required bool isUnlock}) async {
    if (needTipOpenOrCloseLock) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('提示'),
          content: Text(isUnlock ? '确认要远程开锁吗？' : '确认要远程关锁吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确认'),
            ),
          ],
        ),
      );
      // 取消 → 中断
      if (confirmed != true) {
        return true;
      }
      return false;
    }
    return false;
  }

  // ==================== 执行 ====================

  /// 执行开锁/关锁
  _executeAction(bool isUnlock,
      {bool showLoading = true, bool needSleep = true}) async {
    try {
      var result = false;
      if (isUnlock) {
        result = await unlock(showLoading: showLoading);
      } else {
        result = await lock(showLoading: showLoading);
      }
      if (result) {
        await syncUnlockStatus();
      }
      if (needSleep) {
        await JFApi.xcDevice.xcLoginOut(deviceId: deviceId);
      }
    } catch (e) {
      LogUtils.doorLock.log('${isUnlock ? "开锁" : "关锁"}失败---$e');
    }
  }

  // ==================== 蓝牙权限 ====================

  /// 蓝牙权限检查，返回 true 表示中断
  Future<bool> checkBlePermissionIfNeed() async {
    if (!DoorLockHelper.checkNeedTipsDeviceIsNotNearby(deviceId)) {
      return false;
    }
    // 检查并请求蓝牙权限
    await GlobalBleSearchManager.instance.checkPermission();
    bool isBleOpen = await PermissionUtils.checkPermission(
        permission: XPermission.blueSwitch, onlyStatus: true);
    if (!isBleOpen) {
      KToast.show(status: TR.current.doorlock_bluetooth_disconnect_tip);
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
    bool isBleService = await PermissionUtils.checkPermission(
        permission: XPermission.blueService, onlyStatus: true);
    if (!isBleService) {
      KToast.show(status: TR.current.doorlock_bluetooth_disconnect_tip);
      return true;
    }
    return false;
  }

  // ==================== 假配网 ====================

  /// 假配网检查（需要时弹窗）
  bool checkFakeNetIfNeed() {
    if (DoorLockHelper.isLowPowerBle(deviceId) ||
        DoorLockHelper.isOverSeaDoorLock(deviceId)) {
      return false;
    }
    Device? device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if ((device?.searchResult?.extra == 4 ||
        device?.searchResult?.extra == 5)) {
      KToast.show(
          status: TR.current.tr_doorlock_uninit_can_not_operation_tips_ios);
      return true;
    }
    return false;
  }

  // ==================== 获取锁状态 ====================

  ///获取门锁开关状态等信息
  getDoorLockInfoFromJvss() async {
    await doorlockAPI.getDoorLockInfo(deviceSn: deviceId).then((map) {
      LogUtils.doorLock.log('getDoorLockInfo=$map');

      if (map is Map) {
        //开门状态
        if (map.containsKey('lockState')) {
          device.lockState = map['lockState'] ?? false;
        }
        //反锁状态
        if (map.containsKey('reverseLockState')) {
          device.reverseLockState = map['reverseLockState'] ?? false;
        }
        //电量
        if (map.containsKey('batteryPower')) {
          device.level = MapParser.readInt(map, 'batteryPower');
        }
        //密钥同步状态
        if (map.containsKey('keySyncState')) {
          device.keySyncState = MapParser.queryBool(map, 'keySyncState', false);
        }
        //基准年同步状态
        if (map.containsKey('yearSyncState')) {
          device.yearSyncState =
              MapParser.queryBool(map, 'yearSyncState', false);
        }
        notifyListeners();
      }
    });
  }

  ///同步锁状态（蓝牙获取后上报服务器）
  syncUnlockStatus() async {
    if (doorLockBleApi != null && doorLockBleApi!.bleObject.isReady) {
      try {
        var unlockingStatus =
            (await doorLockBleApi?.getUnlockingStatus())?.item2;
        LogUtils.doorLock
            .log('syncInfoByBlue unlockingStatus:$unlockingStatus');
        device.lockState = unlockingStatus == 0;
        notifyListeners();

        await doorlockAPI.insertOrUpdateDoorLockInfo(
            deviceSn: deviceId, lockState: device.lockState);
        notifyListeners();
      } catch (e) {
        LogUtils.doorLock
            .log('syncInfoByBlue unlockingStatus error:${kErrorMsg(e)}');
      }
    }

    if (doorLockBleApi != null &&
        doorLockBleApi!.bleObject.isReady &&
        DoorLockHelper.supportReverseLockState(deviceId)) {
      try {
        var antiLockStatus = (await doorLockBleApi?.getAntiLockStatus())?.item2;
        LogUtils.doorLock.log('syncInfoByBlue antiLockStatus:$antiLockStatus');
        device.reverseLockState = antiLockStatus == 1;
        notifyListeners();

        await doorlockAPI.insertOrUpdateDoorLockInfo(
            deviceSn: deviceId, reverseLockState: device.reverseLockState);
        notifyListeners();
      } catch (e) {
        LogUtils.doorLock
            .log('syncInfoByBlue antiLockStatus error:${kErrorMsg(e)}');
      }
    }

    ///获取门锁状态
    getDoorLockInfoFromJvss();
  }
}
