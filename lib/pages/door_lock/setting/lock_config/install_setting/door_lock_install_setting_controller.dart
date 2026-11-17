import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk_example/common/production_testing_config.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_set_config.dart';

///安装设置页面控制器
class DoorLockInstallSettingController extends DoorLockPageController
    with DoorLockSetConfigMixin {
  @override
  final String deviceId;

  final DoorLockSetConfig initSetConfig;
  late final List<int> motorTimeOptions;

  int? motorTime;
  bool _disposed = false;
  bool _refreshing = false;

  DoorLockInstallSettingController({
    required super.context,
    required this.deviceId,
    required this.initSetConfig,
  }) {
    motorTimeOptions = DoorLockHelper.getLockedRotorTimes(deviceId: deviceId);
    createDoorLockAPI();
    Future.microtask(refresh);
  }

  bool get showUnlockDirection =>
      device.doorLockBleAbility?.byte1.supportUnlockDirection == true;

  bool get showMotorTorque =>
      device.doorLockBleAbility?.byte2.supportMotorTorque == true;

  bool get showMotorTime =>
      ProductionTestingConfig.isOn && motorTimeOptions.isNotEmpty;

  String get unlockDirectionText {
    switch (initSetConfig.unlockDirection) {
      case 0:
        return '左开';
      case 1:
        return '右开';
      default:
        return '';
    }
  }

  String get motorTorqueText {
    switch (initSetConfig.motorTorque) {
      case 0:
        return '小';
      case 1:
        return '中';
      case 2:
        return '大';
      default:
        return '';
    }
  }

  String get motorTimeText {
    final value = motorTime;
    if (value == null) return '';
    return value == 0 ? '默认' : '$value ms';
  }

  void refreshValues() => _notify();

  Future<void> refresh() async {
    if (_disposed || _refreshing) return;
    _refreshing = true;
    try {
      final latest = await syncLatestSetConfig();
      if (_disposed) return;
      if (latest?.unlockDirection != null) {
        initSetConfig.unlockDirection = latest!.unlockDirection;
      }
      if (latest?.motorTorque != null) {
        initSetConfig.motorTorque = latest!.motorTorque;
      }
      if (showMotorTime) await _loadMotorTime();
    } finally {
      _refreshing = false;
      _notify();
    }
  }

  Future<void> refreshMotorTime() async {
    if (_disposed || !showMotorTime) return;
    await _loadMotorTime();
    _notify();
  }

  void updateMotorTime(int value) {
    motorTime = value;
    _notify();
  }

  Future<void> _loadMotorTime() async {
    final result = await DoorLockNetIp.getMotorTime(deviceId: deviceId);
    if (!_disposed && result.item1 != null) {
      motorTime = result.item1;
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
