import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_set_config.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///电机扭矩设置控制器
class DoorLockMotorTorqueSetController extends DoorLockPageController
    with DoorLockSetConfigMixin {
  @override
  final String deviceId;

  final DoorLockSetConfig initSetConfig;
  late int motorTorque;
  bool writing = false;
  bool _disposed = false;

  DoorLockMotorTorqueSetController({
    required super.context,
    required this.deviceId,
    required this.initSetConfig,
  }) {
    motorTorque = initSetConfig.motorTorque ?? 0;
    createDoorLockAPI();
    Future.microtask(_syncLatest);
  }

  Future<void> _syncLatest() async {
    final latest = await syncLatestSetConfig();
    if (_disposed || writing || latest?.motorTorque == null) return;
    motorTorque = latest!.motorTorque!;
    initSetConfig.motorTorque = motorTorque;
    _notify();
  }

  Future<bool> changeMotorTorque(int value) async {
    if (writing || value == motorTorque || value < 0 || value > 2) {
      return false;
    }
    writing = true;
    try {
      final success = await setMotorTorque(motorTorque: value);
      if (!success) return false;

      motorTorque = value;
      initSetConfig.motorTorque = value;
      try {
        await DoorLockHelper.instance.saveOnlineConfig(
          deviceId,
          [
            bytesToHex([3, 0x07, value])
          ],
        );
      } catch (e) {
        LogUtils.doorLock.log('save motor torque online config error: $e');
      }
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

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
