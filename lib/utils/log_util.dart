import 'package:flutter/foundation.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';

class LogModule {
  final String tag;
  bool enable = true;
  LogModule({required this.tag, this.enable = true});
  List<String> unSendLogs = [];
  bool _isFlushing = false;
  void log(String message, {List<dynamic>? arguments}) async {
    if (!enable) {
      return;
    }
    try {
      await flushLogs();
      JFApi.xcUtil.log('$tag $message');
      debugPrint('$tag $message');
    } catch (e) {
      //
    }
  }

  Future flushLogs() async {
    if (unSendLogs.isEmpty) {
      return;
    }
    // 防止多个 flushLogs 并发执行
    if (_isFlushing) return;
    _isFlushing = true;
    try {
      if (unSendLogs.isNotEmpty) {
        // 先复制快照并立即清空原列表，避免并发修改异常
        final logsToSend = List<String>.from(unSendLogs);
        unSendLogs.clear();
        for (var log in logsToSend) {
          JFApi.xcUtil.log(log);
        }
      }
    } finally {
      _isFlushing = false;
    }
  }
}

class LogUtils {
  static LogModule app = LogModule(tag: '[APP]');
  static LogModule account = LogModule(tag: '[ACCOUNT]');
  static LogModule device = LogModule(tag: '[DEVICE]');
  static LogModule addDevice = LogModule(tag: '[ADD_DEVICE]');
  static LogModule openAPI = LogModule(tag: '[OPEN_API]');
  static LogModule push = LogModule(tag: '[PUSH]');
  static LogModule pmsDownload = LogModule(tag: '[PMS_DOWNLOAD]');
  static LogModule deviceConfig = LogModule(tag: '[DEVICE_CONFIG]');
  static LogModule cloudServer = LogModule(tag: '[CLOUD_SERVER]');
  static LogModule deviceList = LogModule(tag: '[DEVICE_LIST]');
  static LogModule deviceProperty = LogModule(tag: '[DEVICE_PROPERTY]');
  static LogModule mediaPlay = LogModule(tag: '[MEDIA_PLAY]');
  static LogModule idr = LogModule(tag: '[IDR]');
  static LogModule mediaDownload = LogModule(tag: '[MEDIA_DOWNLOAD]');
  static LogModule mqtt = LogModule(tag: '[MQTT]');
  static LogModule upgradeServer = LogModule(tag: '[UPGRADE_SERVER]');
  static LogModule dio = LogModule(tag: '[DIO]');
  static LogModule h5 = LogModule(tag: '[H5]');
  static LogModule ad = LogModule(tag: '[AD]');
  static LogModule xCloudSDK = LogModule(tag: 'xCloudSDK');
  static LogModule reset = LogModule(tag: 'RESET_BLE'); //蓝牙软复位
  static LogModule ble = LogModule(tag: 'BLE'); //蓝牙交互
  static LogModule nativeSync = LogModule(tag: '[NATIVE_SYNC]');
  static LogModule appDataDB = LogModule(tag: '[APP_DATA_DB]'); // db
  /// 埋点
  static LogModule track = LogModule(tag: '[TRACK]');

  /// 反馈
  static LogModule feedback = LogModule(tag: '[FEEDBACK]');

  /// H5 离线包
  static LogModule h5Bundle = LogModule(tag: '[H5_BUNDLE]');

  /// 诊断
  static LogModule diagnosis = LogModule(tag: '[DIAGNOSIS]');

  /// 三方广告log
  static LogModule topon = LogModule(tag: '[TOPON]');

  ///有关调用PMS接口
  static LogModule pmsV2 = LogModule(tag: '[PMS_V2]');
}
