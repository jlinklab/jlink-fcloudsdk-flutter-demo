import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';

import '../models/user_instance.dart';
import '../pages/device_setting/model/model.dart';
import 'device_manager.dart';

class PushManager {
  static final PushManager instance = PushManager._();

  PushManager._();

  ///获取杰峰推送token
  Future<String> getJfPushToken() async {
    String userId = UserInfo.instance.userId;
    if (userId.isEmpty) {
      debugPrint(
          '获取杰峰推送时，userId为空，可能会导致杰峰推送token串台, 所以这里杰峰推送token返回空，等后面拿到userid,再次订阅');
      return '';
    }
    final preference = await SharedPreferences.getInstance();
    String cachedToken = preference.getString('jfPushToken') ?? '';
    if (cachedToken.isEmpty || !cachedToken.contains(userId)) {
      String pushToken = '$userId-${const Uuid().v4()}';
      debugPrint('userId=$userId--pushToken2=$pushToken');
      await preference.setString('jfPushToken', pushToken);
      return pushToken;
    } else {
      return cachedToken;
    }
  }

  ///单个订阅设备（只支持杰峰推送）
  Future<void> subscribe(String deviceId, {String? deviceName}) async {
    String jfPushToken = await getJfPushToken();
    Device? device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device == null) return;
    AlarmSubscribeBody body =
        AlarmSubscribeBody(sn: deviceId, devName: device.nickname ?? deviceId);
    List<AlarmSubscribeBody> bodyList = [];
    bodyList.add(body);

    TokenListElement element = TokenListElement(
        token: jfPushToken, tokenType: 'Android', bundleId: '');
    List<TokenListElement> tokenList = [];
    tokenList.add(element);
    AlarmSubscribe model = AlarmSubscribe(
        snlist: bodyList, tklist: tokenList, userId: UserInfo.instance.userId);

    await JFApi.xcAlarmMessage.xcSubscribeDeviceAlarmMessages(model);
  }

  ///单个取消订阅设备
  Future<void> unsubscribe(String deviceId) async {
    String jfPushToken = await getJfPushToken();
    AlarmSubscribebaseBody body = AlarmSubscribebaseBody(sn: deviceId);
    List<AlarmSubscribebaseBody> bodyList = [];
    bodyList.add(body);
    TokenListbaseElement element = TokenListbaseElement(token: jfPushToken);
    List<TokenListbaseElement> tokenList = [];
    tokenList.add(element);
    AlarmUnsubscribe model =
        AlarmUnsubscribe(snlist: bodyList, tklist: tokenList);
    await JFApi.xcAlarmMessage.xcUnsubscribeDevicesAlarmMessages(model);
  }

  ///批量订阅
  Future subscribeBatch({required List<String> deviceIdList}) async {
    if (deviceIdList.isEmpty) {
      return;
    }
    var bodyList = deviceIdList
        .map((e) => AlarmSubscribeBody(
            sn: e, devName: DeviceManager.instance.getDeviceName(deviceId: e)))
        .toList();

    List<TokenListElement> tokenList = [];

    String jfPushToken = await getJfPushToken();
    if (jfPushToken.isNotEmpty) {
      var elementJf = TokenListElement(
          token: jfPushToken, tokenType: 'Android', bundleId: '');
      tokenList.add(elementJf);
    }
    try {
      var alarmSubscribe = AlarmSubscribe(
          snlist: bodyList,
          tklist: tokenList,
          userId: UserInfo.instance.userId,
          language: 'zh');

      await JFApi.xcAlarmMessage.xcSubscribeDeviceAlarmMessages(alarmSubscribe);
    } catch (e) {
      //
    }
  }

  ///批量取消订阅
  Future unsubscribeBatch({required List<String> deviceIdList}) async {
    try {
      if (deviceIdList.isEmpty) {
        return;
      }
      List<TokenListbaseElement> tokenList = [];

      String jfPushToken = await getJfPushToken();
      if (jfPushToken.isNotEmpty) {
        var elementJf = TokenListbaseElement(token: jfPushToken);
        tokenList.add(elementJf);
      }

      var request = AlarmUnsubscribe(
          snlist:
              deviceIdList.map((e) => AlarmSubscribebaseBody(sn: e)).toList(),
          tklist: tokenList);

      await JFApi.xcAlarmMessage.xcUnsubscribeDevicesAlarmMessages(request);
    } catch (e) {
      //
      rethrow;
    }
  }
}
