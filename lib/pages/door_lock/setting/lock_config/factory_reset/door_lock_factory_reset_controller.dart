import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_key_value.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/api/add_device_api.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/common/event.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/manager/push_manager.dart';
import 'package:fcloudsdk_example/pages/door_lock/repository/door_lock_local.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///锁具恢复出厂页面控制器
class DoorLockFactoryResetController extends DoorLockPageController {
  @override
  final String deviceId;

  late final int minLength;
  late final int maxLength;

  String password = '';
  bool working = false;
  bool resetCompleted = false;
  String progressText = '';
  bool _disposed = false;

  DoorLockFactoryResetController({
    required super.context,
    required this.deviceId,
  }) {
    minLength = device.doorLockPwdLengthRange?.min ?? 6;
    maxLength = device.doorLockPwdLengthRange?.max ?? 10;
  }

  @override
  bool get keepBleConnectWhenDispose => false;

  @override
  bool get keepSyncWhenDispose => false;

  void updatePassword(String value) {
    password = value;
    _notify();
  }

  bool validatePassword() {
    if (password.isEmpty) {
      KToast.show(status: '请输入管理员密码');
      return false;
    }
    final valid = RegExp(r'^\d+$').hasMatch(password) &&
        password.length >= minLength &&
        password.length <= maxLength;
    if (!valid) {
      KToast.show(status: '请输入$minLength～$maxLength位数字管理员密码');
      return false;
    }
    return true;
  }

  ///验证管理员并恢复出厂，复位成功后仅重试设备移除
  Future<bool> start() async {
    if (working) return false;
    if (!resetCompleted && !validatePassword()) return false;
    if (!resetCompleted &&
        device.doolockCmdStatus == DoolockCmdStatus.offline) {
      KToast.show(status: '当前设备离线，无法恢复出厂设置');
      return false;
    }

    working = true;
    _notify();
    try {
      if (!resetCompleted) {
        progressText = '正在验证管理员密码...';
        _notify();
        if (!await verifyPwd(password)) return false;

        progressText = '正在恢复出厂设置，请勿断开连接...';
        _notify();
        final success = await reset();
        DoorLockNetIp.endSyncDoorStatus(deviceId);
        if (!success) return false;

        resetCompleted = true;
        KToast.show(status: '锁具恢复出厂设置成功');
      }

      progressText = '正在从当前账号移除设备...';
      _notify();
      try {
        await addDeviceAPI.deleteDevice({
          'deviceNo': deviceId,
          'clearNss': false,
        });
      } catch (e) {
        KToast.show(status: '锁具已恢复出厂，但设备移除失败：${kErrorMsg(e)}');
        return false;
      }

      await _clearDeviceData();
      KToast.show(status: '恢复出厂设置及设备移除成功');
      return true;
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      return false;
    } finally {
      working = false;
      progressText = '';
      _notify();
    }
  }

  Future<void> _clearDeviceData() async {
    await _ignoreCleanupError(
      '取消推送订阅',
      () => PushManager.instance.unsubscribe(deviceId),
    );
    await _ignoreCleanupError(
      '退出设备登录',
      () => JFApi.xcDevice.xcLoginOut(deviceId: deviceId),
    );
    await _ignoreCleanupError(
      '清理设备登录信息',
      () => JFApi.xcDevice.xcSetLocalUserNameAndPwd(
        deviceId: deviceId,
        userName: 'admin',
        pwd: '',
      ),
    );
    await _ignoreCleanupError(
      '清理设备Token',
      () => JFApi.xcDevice.xcSetDeviceToken(deviceId: deviceId, token: ''),
    );
    await _ignoreCleanupError(
      '清理设备信息',
      () => JFApi.xcDevice.xcDeleteDevsInfo(deviceIds: deviceId),
    );

    DoorLockKeyValueLocal.clearCache(deviceId: deviceId);
    DoorLockLocalCache.clearCache(deviceId: deviceId);
    await _ignoreCleanupError(
      '清理门锁在线配置',
      () => DoorLockLocalCache.saveDoorlockOnlineConfig(deviceId, []),
    );

    DeviceManager.instance.removeDevice(deviceId: deviceId, type: 0);
    eventBus.fire(RemoveDeviceUpdateEvent(type: 0));
  }

  Future<void> _ignoreCleanupError(
    String action,
    Future<dynamic> Function() operation,
  ) async {
    try {
      await operation();
    } catch (e) {
      LogUtils.doorLock.log('$action失败: $e');
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
