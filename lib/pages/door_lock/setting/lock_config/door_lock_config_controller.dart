import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_parse.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk_example/common/production_testing_config.dart';
import 'package:fcloudsdk_example/pages/door_lock/repository/door_lock_local.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/language/door_lock_language_util.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_set_config.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///锁具配置页面控制器
class DoorLockConfigController extends DoorLockPageController
    with DoorLockSetConfigMixin {
  @override
  final String deviceId;

  DoorLockSetConfig? setConfig;
  bool loading = false;
  bool writing = false;
  String? loadError;
  bool _disposed = false;
  bool _hadInstallVerification = false;
  int _lastNonZeroVolume = 1;

  DoorLockConfigController({
    required super.context,
    required this.deviceId,
    DoorLockSetConfig? initSetConfig,
  }) {
    setConfig = initSetConfig;
    if (setConfig == null) {
      final cachedRaw =
          DoorLockLocalCache.doorlockOnlineConfig(deviceId: deviceId);
      if (cachedRaw.isNotEmpty) {
        setConfig = parseRawToSetConfig(cachedRaw);
      }
    }
    _updateLastNonZeroVolume(setConfig);
    loading = setConfig == null;
    queryConfig(showLoading: loading);
  }

  @override
  bool get keepBleConnectWhenDispose => false;

  @override
  bool get keepSyncWhenDispose => false;

  bool get isIot => DoorLockHelper.isIotDoorLock(deviceId);

  bool get showPirConfig =>
      device.doorLockBleAbility?.byte1.supportPirConfig == true;

  bool get showHumanDetection =>
      DoorLockHelper.showPirConfigToHumanDetection(deviceId);

  String get pirConfigTitle => showHumanDetection ? '人形侦测' : '逗留侦测';

  String get pirConfigText => setConfig?.pirConfig?.open == 1 ? '已开启' : '已关闭';

  bool get showHumanSensor =>
      isIot && device.doorLockBleAbility?.byte2.supportHumanSensor == true;

  String get humanSensorText =>
      setConfig?.humanSensor?.open == 1 ? '已开启' : '已关闭';

  bool get showAutoLock =>
      device.doorLockBleAbility?.byte1.supportAutoLock == true;

  bool get showNormalOpen =>
      device.doorLockBleAbility?.byte3.supportBleNormalOpenMode == true;

  bool get showVolume =>
      device.doorLockBleAbility?.byte1.supportVolumeControl == true;

  bool get showLanguage =>
      !isIot &&
      device.doorLockBleAbility?.byte2.supportLanguage == true &&
      (setConfig?.supportLans?.isNotEmpty ?? false);

  String get languageText => doorLockLanguageName(
        setConfig?.lan ?? DoorLockLanguage.zh_CN,
      );

  bool get showFaceAlarmTone =>
      isIot && device.doorLockBleAbility?.byte1.supportFaceAlarmTone == true;

  bool get showUnlockMode =>
      isIot && device.doorLockBleAbility?.byte1.supportUnlockMode == true;

  bool get showDeployDefense =>
      isIot && device.doorLockBleAbility?.byte2.supportDeployDefense == true;

  bool get showSupportReverseLock =>
      DoorLockHelper.supportReverseLockState(deviceId);

  bool get showResetButton =>
      isIot &&
      device.doorLockBleAbility?.byte5.supportDisableReset == true &&
      !device.isSharedDevice;

  bool get showFactoryReset =>
      isIot &&
      device.doorLockBleAbility?.byte3.supportDoorlockReset == true &&
      device.isAdmin;

  bool get showOpeningDirectionSelfCheck =>
      device.doorLockBleAbility?.byte3.supportOpeningDirectionSelfCheck == true;

  bool get showMotorTime =>
      ProductionTestingConfig.isOn &&
      DoorLockHelper.getLockedRotorTimes(deviceId: deviceId).isNotEmpty;

  bool get showInstallSettings =>
      isIot &&
      !device.isSharedDevice &&
      (device.doorLockBleAbility?.byte1.supportUnlockDirection == true ||
          device.doorLockBleAbility?.byte2.supportMotorTorque == true ||
          showMotorTime);

  bool get hadInstallVerification => _hadInstallVerification;

  void markInstallSettingsVerified() {
    _hadInstallVerification = true;
  }

  ///需要方向自检或安装前管理员验证的设备不在此直接修改方向
  bool get showUnlockDirection =>
      !isIot &&
      device.doorLockBleAbility?.byte1.supportUnlockDirection == true &&
      !showOpeningDirectionSelfCheck;

  bool get hasAnyConfig =>
      showPirConfig ||
      showHumanSensor ||
      showAutoLock ||
      showNormalOpen ||
      showVolume ||
      showLanguage ||
      showFaceAlarmTone ||
      showUnlockMode ||
      showDeployDefense ||
      showSupportReverseLock ||
      showResetButton ||
      showOpeningDirectionSelfCheck ||
      showUnlockDirection ||
      showInstallSettings ||
      showFactoryReset;

  String get autoLockText {
    final value = setConfig?.autoLock?.value;
    if (value == null) return '未知';
    return value > 0 ? '$value 秒' : '手动关锁';
  }

  String get normalOpenText {
    final normal = setConfig?.bleOpenMode;
    final temporary = setConfig?.bleTempOpenMode;
    if (normal == null && temporary == null) return '未知';
    return (normal ?? 0) > 0 || (temporary ?? 0) > 0 ? '已开启' : '已关闭';
  }

  String get resetButtonText {
    switch (setConfig?.resetButton) {
      case 0:
        return '启用';
      case 1:
        return '禁用';
      default:
        return '未知';
    }
  }

  String get volumeText {
    switch (setConfig?.volumeControl) {
      case 0:
        return '静音';
      case 1:
        return '低';
      case 2:
        return '中';
      case 3:
        return '高';
      default:
        return '未知';
    }
  }

  String get unlockModeText {
    switch (setConfig?.unlockMode) {
      case 0:
        return '单独开锁';
      case 1:
        return '组合开锁';
      default:
        return '未知';
    }
  }

  String get unlockDirectionText {
    switch (setConfig?.unlockDirection) {
      case 0:
        return '左开';
      case 1:
        return '右开';
      default:
        return '未知';
    }
  }

  void updateSetConfig(DoorLockSetConfig value) {
    setConfig = value;
    _notify();
  }

  Future<void> queryConfig({bool showLoading = false}) async {
    if (_disposed) return;
    if (showLoading || setConfig == null) loading = true;
    loadError = null;
    _notify();
    final latest = await syncLatestSetConfig();
    if (_disposed) return;
    if (latest != null) {
      setConfig = latest;
      _updateLastNonZeroVolume(latest);
    }
    loadError = latest == null && setConfig == null ? '暂未读取到锁具配置，请重试' : null;
    loading = false;
    _notify();
  }

  void _updateLastNonZeroVolume(DoorLockSetConfig? config) {
    final volume = config?.volumeControl;
    if (volume != null && volume > 0) {
      _lastNonZeroVolume = volume;
    }
  }

  Future<bool> updateVolumeEnabled(bool open) {
    return updateVolume(open ? _lastNonZeroVolume : 0);
  }

  Future<bool> updateVolume(int level) {
    if (level < 0 || level > 3) return Future.value(false);
    return _applyConfig(
      write: () => setVolumeControl(level: level),
      update: () {
        if (level > 0) _lastNonZeroVolume = level;
        setConfig?.volumeControl = level;
      },
      raw: () => [
        bytesToHex([0x03, 0x05, level])
      ],
    );
  }

  Future<bool> updateFaceAlarmTone(bool open) {
    final value = open ? 1 : 0;
    return _applyConfig(
      write: () => setFaceAlarmTone(isOpen: value),
      update: () => setConfig?.faceAlarmTone = value,
      raw: () => [
        bytesToHex([0x03, 0x06, value])
      ],
    );
  }

  Future<bool> updateUnlockMode(int mode) {
    if (mode != 0 && mode != 1) return Future.value(false);
    return _applyConfig(
      write: () => setUnlockMode(mode: mode),
      update: () => setConfig?.unlockMode = mode,
      raw: () => [
        bytesToHex([0x03, 0x04, mode])
      ],
    );
  }

  Future<bool> updateDeployDefense(bool open) {
    final value = open ? 1 : 0;
    return _applyConfig(
      write: () => setDeployDefense(isOpen: value),
      update: () => setConfig?.deployDefense = value,
      raw: () => [
        bytesToHex([0x03, 0x09, value])
      ],
    );
  }

  Future<bool> updateSupportReverseLock(bool open) {
    final value = open ? 1 : 0;
    return _applyConfig(
      write: () => setSupportReverseLock(isOpen: value),
      update: () => setConfig?.supportDeadBol = value,
      raw: () => [
        bytesToHex([0x03, 0x10, value])
      ],
    );
  }

  Future<bool> updateUnlockDirection(int direction) {
    if (direction != 0 && direction != 1) return Future.value(false);
    return _applyConfig(
      write: () => setUnlockDirection(direction: direction),
      update: () => setConfig?.unlockDirection = direction,
      raw: () => [
        bytesToHex([0x03, 0x02, direction])
      ],
    );
  }

  Future<bool> _applyConfig({
    required Future<bool> Function() write,
    required void Function() update,
    required List<String> Function() raw,
  }) async {
    if (writing || _disposed || setConfig == null) return false;
    writing = true;
    _notify();
    final success = await write();
    if (success) {
      update();
      final rawList = raw();
      if (rawList.isNotEmpty) {
        await DoorLockHelper.instance.saveOnlineConfig(deviceId, rawList);
      }
      KToast.show(status: '设置成功');
    }
    writing = false;
    _notify();
    return success;
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
