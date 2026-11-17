import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_set_config.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///人体感应页面控制器
class DoorLockHumanSensorController extends DoorLockPageController
    with DoorLockSetConfigMixin {
  @override
  final String deviceId;

  final DoorLockSetConfig initSetConfig;

  bool open = false;
  int value = 0;
  int support = 0;
  int mask = 0;
  bool writing = false;
  bool _disposed = false;

  DoorLockHumanSensorController({
    required super.context,
    required this.deviceId,
    required this.initSetConfig,
  }) {
    createDoorLockAPI();
    _initData();
    Future.microtask(_syncLatest);
  }

  bool get pirOpen => initSetConfig.pirConfig?.open == 1;

  List<int> get distanceValues {
    if (support == 0) return const [0, 1, 2];
    if (support == 1) {
      return [
        if (getBit(mask, 0)) 0,
        if (getBit(mask, 1)) 1,
        if (getBit(mask, 2)) 2,
      ];
    }
    return const [];
  }

  void _initData() {
    final config = initSetConfig.humanSensor;
    open = config?.open == 1;
    value = config?.value ?? 0;
    support = config?.support ?? 0;
    mask = config?.mask ?? 0;
  }

  Future<void> _syncLatest() async {
    final latest = await syncLatestSetConfig();
    if (_disposed || writing || latest == null) return;
    if (latest.humanSensor != null) {
      initSetConfig.humanSensor = latest.humanSensor;
    }
    if (latest.pirConfig != null) {
      initSetConfig.pirConfig = latest.pirConfig;
    }
    _initData();
    _notify();
  }

  Future<bool> changeSwitch() {
    return _writeHumanSensor(open: !open, value: value);
  }

  Future<bool> changeValue(int newValue) {
    if (!open || !distanceValues.contains(newValue)) {
      return Future.value(false);
    }
    return _writeHumanSensor(open: open, value: newValue);
  }

  Future<bool> closePirConfig() async {
    if (writing) return false;
    final config = initSetConfig.pirConfig;
    final pirValue = config?.value ?? 10;
    final pirStep = config?.step ?? 10;
    final pirMin = config?.min ?? 10;
    final pirMax = config?.max ?? 60;
    writing = true;
    _notify();
    try {
      final result = await setPirConfig(enable: false, value: pirValue);
      if (!result) return false;
      initSetConfig.pirConfig = DoorLockPirConfig(
        7,
        0x01,
        0,
        pirValue,
        pirStep,
        pirMin,
        pirMax,
      );
      await DoorLockHelper.instance.saveOnlineConfig(
        deviceId,
        [
          bytesToHex([7, 0x01, 0, pirValue, pirStep, pirMin, pirMax])
        ],
      );
      return true;
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      return false;
    } finally {
      writing = false;
      _notify();
    }
  }

  Future<bool> _writeHumanSensor({
    required bool open,
    required int value,
  }) async {
    if (writing) return false;
    writing = true;
    _notify();
    try {
      final result = await setHumanSensor(enable: open, value: value);
      if (!result) return false;
      this.open = open;
      this.value = value;
      _updateHumanSensorConfig();
      await _saveHumanSensorConfig();
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

  void _updateHumanSensorConfig() {
    initSetConfig.humanSensor = DoorLockHumanSensorConfig(
      6,
      0x0A,
      open ? 1 : 0,
      value,
      support,
      mask,
    );
  }

  Future<void> _saveHumanSensorConfig() async {
    await DoorLockHelper.instance.saveOnlineConfig(
      deviceId,
      [
        bytesToHex([6, 0x0A, open ? 1 : 0, value, support, mask])
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
