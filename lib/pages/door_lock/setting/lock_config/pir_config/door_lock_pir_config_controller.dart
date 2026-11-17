import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_set_config.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///逗留侦测页面控制器
class DoorLockPirConfigController extends DoorLockPageController
    with DoorLockSetConfigMixin {
  @override
  final String deviceId;

  final DoorLockSetConfig initSetConfig;

  bool open = false;
  int value = 10;
  double draftValue = 10;
  int step = 10;
  int min = 10;
  int max = 60;
  bool supportSecond = false;
  bool writing = false;
  bool _disposed = false;

  DoorLockPirConfigController({
    required super.context,
    required this.deviceId,
    required this.initSetConfig,
  }) {
    createDoorLockAPI();
    _initData();
    Future.microtask(_syncLatest);
  }

  bool get useRangeForSwitch => true;

  bool get humanSensorOpen => initSetConfig.humanSensor?.open == 1;

  int get humanSensorValue => initSetConfig.humanSensor?.value ?? 0;

  int get humanSensorSupport => initSetConfig.humanSensor?.support ?? 0;

  int get humanSensorMask => initSetConfig.humanSensor?.mask ?? 0;

  int get sliderDivisions {
    final divisions = (max - min) ~/ step;
    return divisions > 0 ? divisions : 1;
  }

  void _initData() {
    final config = initSetConfig.pirConfig;
    open = config?.open == 1;
    value = (config?.value ?? 0) > 10 ? config!.value! : 10;
    step = config?.step ?? 10;
    if (step == 0 || config?.min == 0 || config?.max == 0) {
      supportSecond = false;
      min = config?.min ?? 0;
      max = config?.max ?? 0;
    } else {
      min = config?.min ?? 10;
      max = config?.max ?? 60;
      supportSecond = step > 0 && min != 0 && max > min;
    }
    if (supportSecond) {
      if (value < min) value = min;
      if (value > max) value = max;
    }
    draftValue = value.toDouble();
  }

  Future<void> _syncLatest() async {
    final latest = await syncLatestSetConfig();
    if (_disposed || writing || latest == null) return;
    if (latest.pirConfig != null) {
      initSetConfig.pirConfig = latest.pirConfig;
    }
    if (latest.humanSensor != null) {
      initSetConfig.humanSensor = latest.humanSensor;
    }
    _initData();
    _notify();
  }

  void updateDraftValue(double newValue) {
    if (writing || !supportSecond) return;
    draftValue = newValue;
    _notify();
  }

  Future<bool> changeSwitch() async {
    if (writing) return false;
    final targetOpen = !open;
    final targetValue = supportSecond || !useRangeForSwitch
        ? value
        : targetOpen
            ? max
            : min;
    writing = true;
    _notify();
    try {
      final result = await setPirConfig(
        enable: targetOpen,
        value: targetValue,
      );
      if (!result) return false;
      open = targetOpen;
      value = targetValue;
      draftValue = targetValue.toDouble();
      _updatePirConfig();
      await _savePirConfig();
      KToast.show(status: '保存成功');
      return true;
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      return false;
    } finally {
      writing = false;
      _notify();
    }
  }

  Future<bool> changeValue(int newValue) async {
    if (writing || !open || !supportSecond) return false;
    if (newValue < min || newValue > max || (newValue - min) % step != 0) {
      draftValue = value.toDouble();
      _notify();
      return false;
    }
    writing = true;
    _notify();
    try {
      final result = await setPirConfig(enable: open, value: newValue);
      if (!result) {
        draftValue = value.toDouble();
        return false;
      }
      value = newValue;
      draftValue = newValue.toDouble();
      _updatePirConfig();
      await _savePirConfig();
      KToast.show(status: '保存成功');
      return true;
    } catch (e) {
      draftValue = value.toDouble();
      KToast.show(status: kErrorMsg(e));
      return false;
    } finally {
      writing = false;
      _notify();
    }
  }

  Future<bool> openHumanSensor() {
    return updateHumanSensor(enable: true, value: humanSensorValue);
  }

  Future<bool> updateHumanSensor({
    required bool enable,
    required int value,
  }) async {
    if (writing) return false;
    writing = true;
    _notify();
    try {
      final result = await setHumanSensor(enable: enable, value: value);
      if (!result) return false;
      initSetConfig.humanSensor = DoorLockHumanSensorConfig(
        6,
        0x0A,
        enable ? 1 : 0,
        value,
        humanSensorSupport,
        humanSensorMask,
      );
      await _saveHumanSensorConfig();
      return true;
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      return false;
    } finally {
      writing = false;
      _notify();
    }
  }

  void _updatePirConfig() {
    initSetConfig.pirConfig = DoorLockPirConfig(
      7,
      0x01,
      open ? 1 : 0,
      value,
      step,
      min,
      max,
    );
  }

  Future<void> _savePirConfig() async {
    await DoorLockHelper.instance.saveOnlineConfig(
      deviceId,
      [
        bytesToHex([7, 0x01, open ? 1 : 0, value, step, min, max])
      ],
    );
  }

  Future<void> _saveHumanSensorConfig() async {
    final config = initSetConfig.humanSensor;
    if (config == null) return;
    await DoorLockHelper.instance.saveOnlineConfig(
      deviceId,
      [
        bytesToHex([
          6,
          0x0A,
          config.open ?? 0,
          config.value ?? 0,
          config.support ?? 0,
          config.mask ?? 0,
        ])
      ],
    );
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
