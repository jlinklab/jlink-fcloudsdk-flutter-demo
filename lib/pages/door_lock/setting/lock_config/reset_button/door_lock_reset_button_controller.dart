import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_set_config.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///重置键页面控制器
class DoorLockResetButtonController extends DoorLockPageController
    with DoorLockSetConfigMixin {
  @override
  final String deviceId;

  final DoorLockSetConfig initSetConfig;
  late int resetButton;
  bool writing = false;
  bool _disposed = false;

  DoorLockResetButtonController({
    required super.context,
    required this.deviceId,
    required this.initSetConfig,
  }) {
    resetButton = initSetConfig.resetButton ?? 0;
  }

  Future<bool> changeSwitch(int value) async {
    if (writing || (value != 0 && value != 1)) return false;
    writing = true;
    _notify();
    try {
      final result = await setResetButton(isOpen: value);
      if (!result) return false;

      resetButton = value;
      initSetConfig.resetButton = value;
      await DoorLockHelper.instance.saveOnlineConfig(
        deviceId,
        [
          bytesToHex([3, 0x1A, value])
        ],
      );
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
