import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///管理员密码验证控制器
class DoorLockVerifyManagerPwdController extends DoorLockPageController {
  @override
  final String deviceId;

  late final int minLength;
  late final int maxLength;

  String password = '';
  bool verifying = false;
  bool _disposed = false;

  DoorLockVerifyManagerPwdController({
    required super.context,
    required this.deviceId,
  }) {
    minLength = device.doorLockPwdLengthRange?.min ?? 6;
    maxLength = device.doorLockPwdLengthRange?.max ?? 10;
    createDoorLockAPI();
  }

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

  Future<bool> verify() async {
    if (verifying || !validatePassword()) return false;
    verifying = true;
    _notify();
    try {
      return await verifyPwd(password);
    } finally {
      verifying = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (verifying) KToast.dismissInDispose();
    super.dispose();
  }
}
