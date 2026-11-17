import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/pir_config/door_lock_pir_config_controller.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///海外锁人形侦测页面控制器
class DoorLockStayDetectiveController extends DoorLockPirConfigController {
  DoorLockStayDetectiveController({
    required super.context,
    required super.deviceId,
    required super.initSetConfig,
  });

  @override
  bool get useRangeForSwitch => false;

  bool get supportPirReuseHsDistance =>
      device
          .doorLockBleAbility?.byte4.supportPirReuseHumanBodySensingDistance ??
      false;

  bool get hasSingleOptionStayAlarm =>
      device.props?.any(
        (prop) => prop.toLowerCase() == 'singleoptionstayalarm',
      ) ??
      false;

  bool get showSensorDistance =>
      supportPirReuseHsDistance && !hasSingleOptionStayAlarm;

  bool get showPowerTip => device.doorlockIsConfigNet || open;

  List<int> get distanceValues {
    if (!showSensorDistance || humanSensorSupport == 2) {
      return const [];
    }
    if (humanSensorSupport == 1) {
      return [
        if (getBit(humanSensorMask, 0)) 0,
        if (getBit(humanSensorMask, 1)) 1,
        if (getBit(humanSensorMask, 2)) 2,
      ];
    }
    return const [0, 1, 2];
  }

  @override
  Future<bool> changeSwitch() async {
    final result = await super.changeSwitch();
    if (result && open && hasSingleOptionStayAlarm && !humanSensorOpen) {
      await openHumanSensor();
    }
    return result;
  }

  Future<bool> changeDistance(int value) async {
    if (!open || !distanceValues.contains(value)) return false;
    final result = await updateHumanSensor(enable: open, value: value);
    if (result) KToast.show(status: '保存成功');
    return result;
  }
}
