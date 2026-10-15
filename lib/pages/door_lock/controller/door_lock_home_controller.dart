import 'dart:async';

import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_key_value.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/common/event.dart';
import 'package:fcloudsdk_example/event/event.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/add_device_permission_manager.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/global_ble_search_manager.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/user_manager_ui.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_action.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/utils/permission_utils.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';

///门锁首页控制器

class DoorLockHomeController extends DoorLockPageController
    with DoorLockActionMixin {
  @override
  final String deviceId;

  ///前置数据请求是否完成
  bool isReady = false;

  ///用户管理入口列表（对齐 jlink userManagerUIList）
  List<UserManagerUI> userManagerUIList = [];

  StreamSubscription<BlueOnlineEvent>? _blueOnlineEvent;

  DoorLockHomeController({required super.context, required this.deviceId}) {
    init();
  }

  Future<void> init() async {
    isReady = false;

    ///用户管理，先使用缓存渲染一次
    _getUserManagerList();

    ///前置必要数据请求，如果仅做数据获取，可以提前到这些步骤之前做
    await DoorLockKeyValueManager.instance.requestService(deviceId);
    await DoorLockHelper.refreshDoorLockStatus(deviceId, queryNet: true);
    await DoorLockHelper.getFuncFromShadowIfNeed(deviceId, queryNew: true);

    ///开始蓝牙操作
    startReadyBle();

    isReady = true;

    ///用户管理，影子服务拉取完成后刷新
    _getUserManagerList();

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

  // ==================== 用户管理入口聚合 ====================

  ///聚合首页“用户管理”列表（对齐 jlink _getUserManagerList）
  ///
  ///范围精简说明（与 jlink 差异）：
  ///- 不含电子钥匙：demo Device 无 devExtPidPropList
  ///- 不含人形侦测：demo Device 无 props 字段（showPirConfigToHumanDetection）
  ///- 不含配件：demo 无 AppType / CountryProvider（needShowLowPowerTips）
  ///- “设置”项在 demo 也暂未实现，但作为入口保留（对齐 jlink 总是显示）
  void _getUserManagerList() {
    userManagerUIList.clear();

    ///分享权限（非分享设备 hasPermission 默认返回 true）
    bool sharePassword =
        device.hasPermission(permission: DevicePermission.DP_DoorLockPsw);
    bool shareSkin = device
        .hasPermission(permission: DevicePermission.DP_DoorLockFingerprint);
    bool shareFace =
        device.hasPermission(permission: DevicePermission.DP_DoorLockFace);
    bool sharePalmprint = device
        .hasPermission(permission: DevicePermission.DP_DoorLockPalmprint);
    bool shareFingervein = device
        .hasPermission(permission: DevicePermission.DP_DoorLockFingerVein);
    bool shareCard =
        device.hasPermission(permission: DevicePermission.DP_DoorLockCard);
    bool sharePalmVein = device
        .hasPermission(permission: DevicePermission.DP_DoorLockPalmVein);
    bool shareOperateRecord = device
        .hasPermission(permission: DevicePermission.DP_DoorLockOperateRecord);

    ///海外锁：写死密码/指纹/卡片/操作记录，只看分享权限
    bool isOversea = DoorLockHelper.isOverSeaDoorLock(deviceId);

    ///设备能力
    bool supportPassword =
        isOversea || DoorLockHelper.showUserManagerPwd(deviceId: deviceId);
    bool supportSkin =
        isOversea || device.doorUserAbility?.byte1.supportSkin == true;
    bool supportFace = device.doorUserAbility?.byte1.supportFace == true;
    bool supportPalmprint =
        device.doorUserAbility?.byte1.supportPalmprint == true;
    bool supportFingervein =
        device.doorUserAbility?.byte1.supportFingervein == true;
    bool supportCard =
        isOversea || device.doorUserAbility?.byte1.supportCard == true;
    bool supportPalmVein =
        device.doorUserAbility?.byte1.supportPalmVein == true;
    bool supportOperateRecord = isOversea;
    bool supportTmpPwd = DoorLockHelper.showTempPwd(deviceId: deviceId);

    ///用户管理项
    if (supportPassword && sharePassword) {
      userManagerUIList.add(UserManagerUI(type: JvssOperateType.password));
    }
    if (supportSkin && shareSkin) {
      userManagerUIList.add(UserManagerUI(type: JvssOperateType.skin));
    }
    if (supportFace && shareFace) {
      userManagerUIList.add(UserManagerUI(type: JvssOperateType.face));
    }
    if (supportPalmprint && sharePalmprint) {
      userManagerUIList.add(UserManagerUI(type: JvssOperateType.palmprint));
    }
    if (supportFingervein && shareFingervein) {
      userManagerUIList.add(UserManagerUI(type: JvssOperateType.fingervein));
    }
    if (supportCard && shareCard) {
      userManagerUIList.add(UserManagerUI(type: JvssOperateType.card));
    }
    if (supportPalmVein && sharePalmVein) {
      userManagerUIList.add(UserManagerUI(type: JvssOperateType.palmVein));
    }
    if (supportTmpPwd) {
      userManagerUIList.add(UserManagerUI(type: JvssOperateType.tmpPassword));
    }
    if (supportOperateRecord && shareOperateRecord) {
      userManagerUIList
          .add(UserManagerUI(type: JvssOperateType.operateRecord));
    }

    ///设置（总是显示，对齐 jlink）
    userManagerUIList.add(UserManagerUI(type: JvssOperateType.settings));

    notifyListeners();
  }

  ///点击用户管理入口（demo 具体子页面未实现，统一弹框提示）
  void checkUserManager(UserManagerUI item) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.name),
        content: const Text('该功能在 demo 中暂未实现'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
