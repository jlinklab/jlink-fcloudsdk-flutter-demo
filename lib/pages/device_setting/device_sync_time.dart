import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:fcloudsdk/api/api_center.dart';

class DeviceSyncTime {
  ///同步设备时间
  ///配网添加设备需要有同步设备时间的机制
  ///如果同步失败，会再试一次，
  ///不管是否同步成功 都会返回不再同步了
  static Future<bool> syncTimeToDevice({required String deviceId}) async {
    ///同步时间的方法
    Future<bool> syncTime({required String deviceId}) async {
      ///先同步时区
      final now = DateTime.now();
      // 在Dart中，我们使用DateTime对象来获取本地时间和UTC时间之间的差异
      // final isDaylightSavingTime = now.isAfter(DateTime(now.year, 1, 1).add(now.timeZoneOffset));
      final isDaylightSavingTime = DayLightTime.isDaylightSavingTime(now);
      // 获取与UTC时间的差异（以分钟为单位），然后转换为小时
      double value = now.timeZoneOffset.inHours.toDouble();
      if (isDaylightSavingTime) {
        value--;
      }
      value = -value;
      int myTime = (value * 60).toInt();
      final Map<String, dynamic> dic = {
        'timeMin': myTime,
        'FirstUserTimeZone': 0
      };
      final Map<String, dynamic> dicTimeZone = {
        'SessionID': '0x1234',
        'Name': 'System.TimeZone',
        'System.TimeZone': dic
      };
      final String jsStrTimeZone = jsonEncode(dicTimeZone);
      try {
        final result = await JFApi.xcDevice.xcDevSetSysConfig(
            deviceId: deviceId,
            commandName: 'System.TimeZone',
            config: jsStrTimeZone,
            configLen: 0,
            command: 1040,
            timeout: 5000);
        if (result < 0) {
          return Future.value(false);
        }
      } catch (e) {
        rethrow;
      }

      ///再同步时间
      String timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      final Map<String, dynamic> mapTime = {
        'SessionID': '0x1234',
        'Name': 'OPTimeSetting',
        'OPTimeSetting': timeStr
      };
      final String jsStr = jsonEncode(mapTime);
      try {
        final result = await JFApi.xcDevice.xcDevSetSysConfig(
            deviceId: deviceId,
            commandName: 'System.TimeZone',
            config: jsStr,
            configLen: 0,
            command: 1450,
            timeout: 5000);
        if (result >= 0) {
          return Future.value(true);
        } else {
          return Future.value(false);
        }
      } catch (e) {
        rethrow;
      }
    }

    return await syncTime(deviceId: deviceId);
  }
}

///夏令时
class DayLightTime {
  static bool isDaylightSavingTime(DateTime date) {
    final standardTimeOffset = DateTime(date.year, 1, 1).timeZoneOffset;
    final currentTimeOffset = date.timeZoneOffset;
    return standardTimeOffset != currentTimeOffset;
  }

  static List<int> getDayLightSavingBeginTime() {
    // Dart 的 DateFormat 类包含了时间和日期的格式化，同时也可以进行解析
    final formatterYMD = DateFormat('yyyy-MM-dd');
    final DateTime currentDate = DateTime.now();
    final formatterYear = DateFormat('yyyy');
    final String strYear = formatterYear.format(currentDate);

    int bYear = 0, bMonth = 0, bDay = 0;

    String ymdEnd = '$strYear-12-31';
    String ymdBegin = '$strYear-01-01';
    DateTime dEnd = formatterYMD.parse(ymdEnd);
    DateTime dBegin = formatterYMD.parse(ymdBegin);

    if (isDaylightSavingTime(dEnd) && isDaylightSavingTime(dBegin)) {
      int eYear = 0, eMonth = 0, eDay = 0;
      for (int m = 12; m > 1; m--) {
        for (int d = 31; d > 1; d--) {
          String ymd =
              '$strYear-${m >= 10 ? '' : '0'}$m-${d >= 10 ? '' : '0'}$d';
          DateTime dateBegin = formatterYMD.parse(ymd);
          if (isDaylightSavingTime(dateBegin)) {
            eYear = int.parse(strYear);
            eMonth = m;
            eDay = d;
          } else {
            return [eYear, eMonth, eDay];
          }
        }
      }
    } else {
      for (int m = 1; m < 12; m++) {
        for (int d = 1; d < 31; d++) {
          String ymd =
              '$strYear-${m >= 10 ? '' : '0'}$m-${d >= 10 ? '' : '0'}$d';
          DateTime dateBegin = formatterYMD.parse(ymd);
          if (isDaylightSavingTime(dateBegin)) {
            bYear = int.parse(strYear);
            bMonth = m;
            bDay = d;
            return [bYear, bMonth, bDay];
          }
        }
      }
    }

    return [0, 0, 0];
  }

  static List<int> getDayLightSavingEndTime() {
    final formatterYMD = DateFormat('yyyy-MM-dd');
    final DateTime currentDate = DateTime.now();
    final formatterYear = DateFormat('yyyy');
    final String strYear = formatterYear.format(currentDate);

    int eYear = 0, eMonth = 0, eDay = 0;

    String ymdEnd = '$strYear-12-31';
    String ymdBegin = '$strYear-01-01';
    DateTime dEnd = formatterYMD.parse(ymdEnd);
    DateTime dBegin = formatterYMD.parse(ymdBegin);

    if (isDaylightSavingTime(dEnd) && isDaylightSavingTime(dBegin)) {
      int nextYear = int.parse(strYear) + 1;
      int bYear = 0, bMonth = 0, bDay = 0;

      for (int m = 1; m < 12; m++) {
        for (int d = 1; d < 31; d++) {
          String ymd =
              '$nextYear-${m >= 10 ? '' : '0'}$m-${d >= 10 ? '' : '0'}$d';
          DateTime dateBegin = formatterYMD.parse(ymd);

          if (isDaylightSavingTime(dateBegin)) {
            bYear = nextYear;
            bMonth = m;
            bDay = d;
          } else {
            return [bYear, bMonth, bDay];
          }
        }
      }
    } else {
      for (int m = 12; m > 1; m--) {
        for (int d = 31; d > 1; d--) {
          String ymd =
              '$strYear-${m >= 10 ? '' : '0'}$m-${d >= 10 ? '' : '0'}$d';
          DateTime dateBegin = formatterYMD.parse(ymd);

          if (isDaylightSavingTime(dateBegin)) {
            eYear = int.parse(strYear);
            eMonth = m;
            eDay = d;
            return [eYear, eMonth, eDay];
          }
        }
      }
    }

    return [eYear, eMonth, eDay];
  }
}
