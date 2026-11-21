import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/language/door_lock_language_util.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_set_config.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///语言设置页面控制器
class DoorLockLanguageController extends DoorLockPageController
    with DoorLockSetConfigMixin {
  @override
  final String deviceId;

  final DoorLockSetConfig initSetConfig;

  DoorLockLanguage currentLanguage = DoorLockLanguage.zh_CN;
  List<DoorLockLanguage> supportedLanguages = [];
  bool writing = false;
  bool _disposed = false;

  DoorLockLanguageController({
    required super.context,
    required this.deviceId,
    required this.initSetConfig,
  }) {
    createDoorLockAPI();
    _initData();
    Future.microtask(_syncLatest);
  }

  String get currentLanguageText => doorLockLanguageName(currentLanguage);

  void _initData() {
    currentLanguage = initSetConfig.lan ?? DoorLockLanguage.zh_CN;
    supportedLanguages = parseDoorLockLanguages(initSetConfig.supportLans);
  }

  ///同步锁端配置刷新页面；force 为 true 时忽略写入中状态（保存完成后需要回读锁端实际生效值）
  Future<void> _syncLatest({bool force = false}) async {
    final latest = await syncLatestSetConfig();
    if (_disposed || (!force && writing) || latest == null) return;
    if (latest.lan != null) initSetConfig.lan = latest.lan;
    if (latest.supportLans != null) {
      initSetConfig.supportLans = latest.supportLans;
    }
    _initData();
    _notify();
  }

  Future<bool> changeLanguage(DoorLockLanguage target) async {
    if (writing ||
        target == currentLanguage ||
        !supportedLanguages.contains(target)) {
      return false;
    }
    writing = true;
    _notify();
    try {
      final result = await setLanguage(language: target);
      if (!result) return false;
      currentLanguage = target;
      initSetConfig.lan = target;
      await _saveLanguageConfig();
      KToast.show(status: '保存成功');
      await _syncLatest(force: true);
      return true;
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      return false;
    } finally {
      writing = false;
      _notify();
    }
  }

  Future<void> _saveLanguageConfig() async {
    await DoorLockHelper.instance.saveOnlineConfig(
      deviceId,
      [
        bytesToHex([3, 0x0B, currentLanguage.value])
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
