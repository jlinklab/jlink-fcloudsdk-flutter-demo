import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/common/event.dart';
import 'package:fcloudsdk_example/event/event.dart';

import 'permission_utils.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String _channelId = 'push_notification';
const String _channelName = '推送通知';

/// 初始化推送通知服务
Future<void> initPushNotification() async {
  //先请求通知权限
  if (!Platform.isIOS) {
    //ios在生命周期里请求了
    await PermissionUtils.checkPermission(
        permission: XPermission.notification, onlyStatus: false);
  }
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const OhosInitializationSettings initializationSettingsOhos =
      OhosInitializationSettings('ic_notify_logo');

  late final InitializationSettings settings;

  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  settings = const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      ohos: initializationSettingsOhos);

  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (details) {
      //点击杰峰推送
    },
  );

  // Android 创建通知渠道
  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(_channelId, _channelName,
        importance: Importance.high),
  );
}

/// 显示推送通知
Future<void> showPushNotification({
  required String id,
  required String title,
  required String content,
  String? payload,
}) async {
  flutterLocalNotificationsPlugin.show(
    id.hashCode,
    title,
    content,
    payload: payload,
    const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
        ),
        iOS: DarwinNotificationDetails(),
        ohos: OhosNotificationDetails(
            OhosNotificationSlotType.SOCIAL_COMMUNICATION)),
  );
}

/// 从推送 JSON 字符串中提取标题和内容
void showNotificationFromJson(String jsonString) {
  try {
    final Map<String, dynamic> data = jsonDecode(jsonString);

    // AllPushInfo 包含主要展示字段
    final Map<String, dynamic>? allPushInfo =
        data['AllPushInfo'] is Map<String, dynamic>
            ? data['AllPushInfo']
            : null;

    final String title =
        allPushInfo?['Title']?.toString() ?? data['Title']?.toString() ?? '新消息';
    final String content = allPushInfo?['Content']?.toString() ??
        data['Content']?.toString() ??
        '';
    final String id = allPushInfo?['AlarmID']?.toString() ??
        data['ID']?.toString() ??
        data['AlarmID']?.toString() ??
        DateTime.now().toString();
    LogUtils.push.log('推送 $id-$title-$content-$jsonString');
    _parseRemoteLockResult(data);
    showPushNotification(
      id: id,
      title: title,
      content: content,
      payload: jsonString,
    );
  } catch (e) {
    print('解析推送数据失败: $e');
  }
}

///解析远程开关锁结果推送并广播事件
///
///远程开关锁命令受理成功不代表锁已动作，锁真实执行后服务器会推送
/// DoorLockOpen/DoorLockClose：开锁回执 MsgType 为 Remote/ManualUnlock，
///关锁回执 MsgType 为 HasBeenClose（门已关闭，远程关锁动作的回执载体）
void _parseRemoteLockResult(Map<String, dynamic> data) {
  try {
    final Map<String, dynamic>? alarmInfo =
        data['AlarmInfo'] is Map<String, dynamic> ? data['AlarmInfo'] : null;
    if (alarmInfo == null) return;

    final Map<String, dynamic>? extInfo =
        alarmInfo['ExtInfo'] is Map<String, dynamic> ? alarmInfo['ExtInfo'] : null;
    final String msgType = extInfo?['MsgType']?.toString() ?? '';

    final String? event = alarmInfo['Event']?.toString();
    final bool isUnlock;
    if (event == 'DoorLockOpen') {
      if (msgType != 'Remote' && msgType != 'ManualUnlock') return;
      isUnlock = true;
    } else if (event == 'DoorLockClose') {
      if (msgType != 'Remote' && msgType != 'HasBeenClose') return;
      isUnlock = false;
    } else {
      return;
    }

    final Map<String, dynamic>? allPushInfo =
        data['AllPushInfo'] is Map<String, dynamic> ? data['AllPushInfo'] : null;
    final String deviceId = allPushInfo?['SerialNumber']?.toString() ?? '';
    if (deviceId.isEmpty) return;

    LogUtils.push.log('远程开关锁回执 deviceId=$deviceId isUnlock=$isUnlock');
    eventBus.fire(
        RemoteLockActionResultEvent(deviceId: deviceId, isUnlock: isUnlock));
  } catch (e) {
    LogUtils.push.log('解析远程开关锁推送失败: $e');
  }
}
