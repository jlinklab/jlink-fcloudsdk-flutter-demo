import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_set_config.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///开锁方向设置控制器
class DoorLockUnlockDirectionSetController extends DoorLockPageController
    with DoorLockSetConfigMixin {
  @override
  final String deviceId;

  final DoorLockSetConfig initSetConfig;
  late int unlockDirection;
  bool writing = false;
  bool _disposed = false;

  DoorLockUnlockDirectionSetController({
    required super.context,
    required this.deviceId,
    required this.initSetConfig,
  }) {
    unlockDirection = initSetConfig.unlockDirection ?? 0;
    createDoorLockAPI();
    Future.microtask(_syncLatest);
  }

  Future<void> _syncLatest() async {
    final latest = await syncLatestSetConfig();
    if (_disposed || writing || latest?.unlockDirection == null) return;
    unlockDirection = latest!.unlockDirection!;
    initSetConfig.unlockDirection = unlockDirection;
    _notify();
  }

  Future<bool> changeDirection(int direction) async {
    if (writing ||
        direction == unlockDirection ||
        (direction != 0 && direction != 1)) {
      return false;
    }
    writing = true;
    try {
      final success = await setUnlockDirection(direction: direction);
      if (!success) return false;

      unlockDirection = direction;
      initSetConfig.unlockDirection = direction;
      try {
        await DoorLockHelper.instance.saveOnlineConfig(
          deviceId,
          [
            bytesToHex([3, 0x02, direction])
          ],
        );
      } catch (e) {
        LogUtils.doorLock.log('save unlock direction online config error: $e');
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
