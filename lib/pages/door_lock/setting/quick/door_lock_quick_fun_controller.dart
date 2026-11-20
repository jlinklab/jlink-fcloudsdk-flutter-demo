import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/models/device_type.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/door_lock_custom_enum.dart';
import 'package:fcloudsdk_example/pages/door_lock/repository/door_lock_local.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:flutter/material.dart';

///快捷功能控制器
class DoorLockQuickFunController extends DoorLockPageController {
  @override
  final String deviceId;

  ///远程开锁密码验证
  bool remoteUnlockVerify = false;

  ///用户管理密码验证
  bool userManagerVerify = false;

  ///远程开锁按钮显示
  bool remoteUnlockShow = true;

  ///是否蓝牙可视门锁
  bool get isBlueToothVideoDoorLock =>
      device.parentPid == DeviceType.PID_BLE_VIDEO_LOCK.pid ||
      device.localUiKey == DeviceLocalUIKeyType.BLUE_TOOTH_DOORLOCK.type ||
      device.localUiKey == DeviceLocalUIKeyType.BK100W_NoVideo.type;

  ///是否为电子钥匙分享的设备
  bool get isElectronicKeyShare =>
      device.isSharedDevice &&
      _sharedPrivilegesContains([DevicePermission.DP_DoorLockEleKey]);

  ///用户管理隐私验证项是否显示
  bool get showUserManagerVerify {
    var isShared = device.isSharedDevice;
    if (isBlueToothVideoDoorLock) {
      if (!isShared) return true;
      return _sharedPrivilegesContains([
        DevicePermission.DP_DoorLockPsw,
        DevicePermission.DP_DoorLockCard,
        DevicePermission.DP_DoorLockFingerprint,
      ]);
    }

    if (isShared &&
        !_sharedPrivilegesContains([
          DevicePermission.DP_DoorLockPsw,
          DevicePermission.DP_DoorLockCard,
          DevicePermission.DP_DoorLockFingerprint,
          DevicePermission.DP_DoorLockFace,
          DevicePermission.DP_DoorLockPalmprint,
          DevicePermission.DP_DoorLockFingerVein,
          DevicePermission.DP_DoorLockPalmVein,
        ])) {
      return false;
    }
    return DoorLockHelper.checkUserManagerShow(deviceId: deviceId);
  }

  ///分享的设备是否带有指定权限中的任一项
  ///按服务端下发的原始权限串逐项精确匹配，all 这类通配权限不算命中
  bool _sharedPrivilegesContains(List<DevicePermission> privileges) {
    final shared = device;
    if (shared is! SharedDevice) return false;
    return shared.permissions.any((e) =>
        e.enable &&
        privileges
            .any((p) => p.value == e.permission || p.name == e.permission));
  }

  ///远程开锁按钮显示项是否显示
  bool get showRemoteUnlockShow =>
      device.localUiKey == DeviceLocalUIKeyType.NEW_DOORLOCK_HOME.type &&
      !isBlueToothVideoDoorLock &&
      device.parentPid != 'HAVLK001T0001002' &&
      !isElectronicKeyShare;

  DoorLockQuickFunController({
    required super.context,
    required this.deviceId,
  }) {
    query();
  }

  ///查询快捷功能配置
  query() {
    remoteUnlockVerify =
        DoorLockLocalCache.isManualUnlockPrivacyOpen(deviceId: deviceId);
    userManagerVerify =
        DoorLockLocalCache.isUserManagerPrivacyOpen(deviceId: deviceId);
    remoteUnlockShow =
        DoorLockLocalCache.isRemoteUnlockShowOpen(deviceId: deviceId);
    notifyListeners();
  }

  ///切换远程开锁密码验证
  changeRemoteUnlockVerify(bool isOn) {
    _changePrivacyVerify(isOn,
        save: DoorLockLocalCache.saveIsManualUnlockPrivacyOpen);
  }

  ///切换用户管理密码验证
  changeUserManagerVerify(bool isOn) {
    _changePrivacyVerify(isOn,
        save: DoorLockLocalCache.saveIsUserManagerPrivacyOpen);
  }

  ///切换隐私验证开关：无论开启还是关闭都需先通过本机验证（指纹/人脸/锁屏密码），
  ///验证失败则开关回退不生效
  _changePrivacyVerify(bool isOn,
      {required Future<void> Function(String deviceId, bool data) save}) async {
    if (await _checkLocalAuth(isOn: isOn)) {
      await save(deviceId, isOn);
      query();
    } else {
      //验证未通过，恢复开关原状态
      notifyListeners();
    }
  }

  ///本机验证前置判断与执行，返回是否允许变更开关。
  ///手机未设置锁屏凭据（密码/指纹/人脸）时：开启被拒绝并提示，关闭直接生效
  Future<bool> _checkLocalAuth({required bool isOn}) async {
    final result = await DoorLockHelper.localAuthVerify();
    if (result == LocalAuthResult.noCredential) {
      if (isOn) {
        _showNotSupportTip();
      }
      return !isOn;
    }
    return result == LocalAuthResult.passed;
  }

  ///手机未设置锁屏凭据提示
  _showNotSupportTip() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('为保障安全，此功能需要您已为手机设置了锁屏密码、指纹或人脸识别。若当前未设置，则开启无效。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  ///切换远程开锁按钮显示
  changeRemoteUnlockShow(bool isOn) async {
    await DoorLockLocalCache.saveIsRemoteUnlockShowOpen(deviceId, isOn);
    remoteUnlockShow = isOn;
    notifyListeners();
  }
}
