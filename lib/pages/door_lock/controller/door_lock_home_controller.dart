import 'dart:async';

import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_key_value.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/common/event.dart';
import 'package:fcloudsdk_example/event/event.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/add_device_permission_manager.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/global_ble_search_manager.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_action.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/utils/permission_utils.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///门锁首页控制器

class DoorLockHomeController extends DoorLockPageController
    with DoorLockActionMixin {
  @override
  final String deviceId;

  ///前置数据请求是否完成
  bool isReady = false;

  StreamSubscription<BlueOnlineEvent>? _blueOnlineEvent;

  DoorLockHomeController({required super.context, required this.deviceId}) {
    init();
  }

  Future<void> init() async {
    isReady = false;

    ///前置必要数据请求，如果仅做数据获取，可以提前到这些步骤之前做
    await DoorLockKeyValueManager.instance.requestService(deviceId);
    await DoorLockHelper.refreshDoorLockStatus(deviceId, queryNet: true);
    await DoorLockHelper.getFuncFromShadowIfNeed(deviceId, queryNew: true);

    ///开始蓝牙操作
    startReadyBle();

    isReady = true;
    notifyListeners();
  }

  Future<bool> _checkPermission() async {
    if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi) {
      return true;
    }

    await GlobalBleSearchManager.instance.checkPermission();

    bool isBleOpen = await PermissionUtils.checkPermission(
        permission: XPermission.blueSwitch, onlyStatus: true);
    if (!isBleOpen) {
      KToast.show(status: TR.current.doorlock_bluetooth_disconnect_tip);
      await Future.delayed(const Duration(seconds: 1));
    }

    bool isBleService = await PermissionUtils.checkPermission(
        permission: XPermission.blueService, onlyStatus: true);
    if (!isBleService) {
      ///todo 提示蓝牙权限
    }

    LogUtils.doorLock
        .log('蓝牙权限：isPermissionBleService=$isBleService, isBleOpen=$isBleOpen');

    return AddDevicePermissionUsecase.instance.isCanBleSearch();
  }

  /// 开始蓝牙操作
  startReadyBle() async {
    if (!context.mounted) {
      return;
    }

    var oldSn = DoorLockKeyValueLocal.oldDeviceNo(deviceId: deviceId);
    _blueOnlineEvent = eventBus.on<BlueOnlineEvent>().listen((event) async {
      if (oldSn == event.deviceId && event.isChanged) {
        await DoorLockHelper.refreshDoorLockStatus(deviceId);
        if (event.online) {
          createDoorLockAPI();
        }
        notifyListeners();
      }
    });

    ///开始低频搜索
    if (DoorLockHelper.showBlueOnlineState(deviceId: deviceId)) {
      await _checkPermission();
      GlobalBleSearchManager.instance
          .startScanByDebounce(pageContext: context, lowFrequency: true);
    }

    createDoorLockAPI();
  }

  @override
  void dispose() {
    GlobalBleSearchManager.instance.stopScan();
    _blueOnlineEvent?.cancel();

    if (device.isBlueNetIpEnable) {
      DoorLockHelper.closeBlueNetIp(sn: deviceId);
    }
    super.dispose();
  }
}
