import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///电机堵转时间设置控制器
class DoorLockMotorTimeSetController extends DoorLockPageController {
  @override
  final String deviceId;

  late final List<int> motorTimeOptions;

  int? currentMotorTime;
  int? selectMotorTime;
  bool working = false;
  bool _disposed = false;

  DoorLockMotorTimeSetController({
    required super.context,
    required this.deviceId,
  }) {
    motorTimeOptions = DoorLockHelper.getLockedRotorTimes(deviceId: deviceId);
    createDoorLockAPI();
    Future.microtask(loadMotorTime);
  }

  Future<void> loadMotorTime() async {
    if (working || _disposed) return;
    working = true;
    _notify();
    KToast.show();
    try {
      final result = await DoorLockNetIp.getMotorTime(deviceId: deviceId);
      KToast.dismiss();
      if (_disposed) return;
      if (result.item1 != null) {
        currentMotorTime = result.item1;
        selectMotorTime = result.item1;
      } else {
        KToast.show(
          status: result.item2 != null ? kErrorMsg(result.item2) : '读取堵转时间失败',
        );
      }
    } catch (e) {
      KToast.dismiss();
      if (!_disposed) KToast.show(status: kErrorMsg(e));
    } finally {
      working = false;
      _notify();
    }
  }

  Future<bool> changeMotorTime(int value) async {
    if (working ||
        value == currentMotorTime ||
        !motorTimeOptions.contains(value)) {
      return false;
    }
    working = true;
    selectMotorTime = value;
    _notify();
    KToast.show();

    Object? error;
    var success = false;
    try {
      final result = await DoorLockNetIp.setMotorTime(
        deviceId: deviceId,
        motorTime: value,
      );
      success = result.item1 == true;
      if (!success) error = result.item2;
    } catch (e) {
      error = e;
    }
    KToast.dismiss();

    if (success) {
      currentMotorTime = value;
      if (!_disposed) KToast.show(status: '保存成功');
    } else {
      selectMotorTime = currentMotorTime;
      if (!_disposed) {
        KToast.show(status: error != null ? kErrorMsg(error) : '保存失败');
      }
    }
    working = false;
    _notify();
    return success;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (working) KToast.dismissInDispose();
    super.dispose();
  }
}
