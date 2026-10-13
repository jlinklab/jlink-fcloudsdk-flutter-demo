

import 'package:fcloudsdk/utils/sp_utils.dart';

class DoorLockLocalCache {
  ///配网状态
  static const String _doorlockIsConfigNet = 'doorlockIsConfigNet';

  ///假配网状态
  static const String _doorlockIsFakeConfigNet = 'doorlockIsFakeConfigNet';

  ///声音偏好
  static const String _doorlockPreferVoiceType = 'doorlockPreferVoiceType';

  ///在线配置
  static const String _doorlockOnlineConfig = 'doorlockOnlineConfig';

  ///数据保护（手动开锁需要安全验证）
  static const String _isManualUnlockPrivacyOpen = 'isManualUnlockPrivacyOpen';

  ///用户管理密码验证
  static const String _isUserManagerPrivacyOpen = 'isUserManagerPrivacyOpen';

  ///远程开锁按钮显示（默认显示）
  static const String _isRemoteUnlockShowOpen = 'isRemoteUnlockShowOpen';

  ///门锁多目切换能力集（镜头切换按钮缓存兜底）
  static const String _doorlockSupportSwitchType = 'doorlockSupportSwitchType';

  ///获取缓存的Key
  static String _spKey(String key, String deviceId, {int? channel}) =>
      '${key}_${deviceId}_${channel ?? 0}';

  ///清除本地缓存
  static clearCache({required String deviceId}) {
    SPUtils.preferences.remove(_spKey(_doorlockIsConfigNet, deviceId));
    SPUtils.preferences.remove(_spKey(_doorlockPreferVoiceType, deviceId));
    SPUtils.preferences.remove(_spKey(_isManualUnlockPrivacyOpen, deviceId));
    SPUtils.preferences.remove(_spKey(_isUserManagerPrivacyOpen, deviceId));
    SPUtils.preferences.remove(_spKey(_isRemoteUnlockShowOpen, deviceId));
    SPUtils.preferences.remove(_spKey(_doorlockSupportSwitchType, deviceId));
  }

  static bool doorlockIsConfigNet({required String deviceId}) {
    return SPUtils.preferences
            .getBool(_spKey(_doorlockIsConfigNet, deviceId)) ??
        false;
  }

  static Future<void> saveDoorlockIsConfigNet(
      String deviceId, bool data) async {
    await SPUtils.preferences
        .setBool(_spKey(_doorlockIsConfigNet, deviceId), data);
  }

  static bool hadSaveDoorlockIsConfigNet({required String deviceId}) {
    return SPUtils.preferences
        .containsKey(_spKey(_doorlockIsConfigNet, deviceId));
  }

  static bool doorlockIsFakeConfigNet({required String deviceId}) {
    return SPUtils.preferences
            .getBool(_spKey(_doorlockIsFakeConfigNet, deviceId)) ??
        false;
  }

  static Future<void> saveDoorlockIsFakeConfigNet(
      String deviceId, bool data) async {
    await SPUtils.preferences
        .setBool(_spKey(_doorlockIsFakeConfigNet, deviceId), data);
  }

  static List<String> doorlockOnlineConfig({required String deviceId}) {
    var result = SPUtils.preferences
            .getStringList(_spKey(_doorlockOnlineConfig, deviceId)) ??
        [];
    return result;
  }

  static Future<void> saveDoorlockOnlineConfig(
      String deviceId, List<String> data) async {
    await SPUtils.preferences
        .setStringList(_spKey(_doorlockOnlineConfig, deviceId), data);
  }

  static bool isManualUnlockPrivacyOpen({required String deviceId}) {
    return SPUtils.preferences
            .getBool(_spKey(_isManualUnlockPrivacyOpen, deviceId)) ??
        false;
  }

  static Future<void> saveIsManualUnlockPrivacyOpen(
      String deviceId, bool data) async {
    await SPUtils.preferences
        .setBool(_spKey(_isManualUnlockPrivacyOpen, deviceId), data);
  }

  static bool isUserManagerPrivacyOpen({required String deviceId}) {
    return SPUtils.preferences
            .getBool(_spKey(_isUserManagerPrivacyOpen, deviceId)) ??
        false;
  }

  static Future<void> saveIsUserManagerPrivacyOpen(
      String deviceId, bool data) async {
    await SPUtils.preferences
        .setBool(_spKey(_isUserManagerPrivacyOpen, deviceId), data);
  }

  static List<String> doorlockSupportSwitchType({required String deviceId}) {
    return SPUtils.preferences
            .getStringList(_spKey(_doorlockSupportSwitchType, deviceId)) ??
        [];
  }

  static Future<void> saveDoorlockSupportSwitchType(
      String deviceId, List<String> data) async {
    await SPUtils.preferences
        .setStringList(_spKey(_doorlockSupportSwitchType, deviceId), data);
  }

  static bool isRemoteUnlockShowOpen({required String deviceId}) {
    return SPUtils.preferences
            .getBool(_spKey(_isRemoteUnlockShowOpen, deviceId)) ??
        true;
  }

  static Future<void> saveIsRemoteUnlockShowOpen(
      String deviceId, bool data) async {
    await SPUtils.preferences
        .setBool(_spKey(_isRemoteUnlockShowOpen, deviceId), data);
  }
}
