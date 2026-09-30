import 'dart:convert';

import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/utils/dst_helper.dart';
import 'package:flutter/foundation.dart';

///同步设备时间（netip通道）
///（海外/低功耗锁在蓝牙通道用 doorLockBleApi.syncDst/syncTime）
class DeviceSyncTime {
  ///同步设备时间：夏令时 → 时区 → 时间
  static Future syncTimeToDevice({required String deviceId}) async {
    try {
      final now = DateTime.now();

      var helper = DSTHelper();
      var dstInfo = await helper.getDstInfo();
      final isDaylightSavingTime = helper.inDst(now); //是否在夏令时

      ///同步夏令时
      await _syncDST(deviceId: deviceId, dstInfo: dstInfo);

      ///先同步时区
      //获取与UTC时间的差异（以分钟为单位）
      int min = now.timeZoneOffset.inMinutes;
      if (isDaylightSavingTime) {
        //夏令时：时钟回拨一小时
        min = min - 60;
      }
      min = -min;
      debugPrint(
          'syncTimeToDevice DST isDst=$isDaylightSavingTime , offset=${now.timeZoneOffset.inMinutes} , final min=$min');
      final Map<String, dynamic> dic = {'timeMin': min, 'FirstUserTimeZone': 0};
      final Map<String, dynamic> dicTimeZone = {
        'SessionID': '0x1234',
        'Name': 'System.TimeZone',
        'System.TimeZone': dic
      };
      await JFApi.xcDevice.xcDevSetSysConfig(
          deviceId: deviceId,
          commandName: '',
          config: jsonEncode(dicTimeZone),
          configLen: 0,
          command: 1040,
          timeout: 5000);

      ///再同步时间
      String two(int n) => n.toString().padLeft(2, '0');
      String timeStr =
          '${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
      final Map<String, dynamic> mapTime = {
        'SessionID': '0x1234',
        'Name': 'OPTimeSetting',
        'OPTimeSetting': timeStr
      };
      await JFApi.xcDevice.xcDevSetSysConfig(
          deviceId: deviceId,
          commandName: '',
          config: jsonEncode(mapTime),
          configLen: 0,
          command: 1040,
          timeout: 5000);
    } catch (e) {
      debugPrint('syncTimeToDevice error: $e');
    }
  }

  ///同步夏令时规则到设备
  static Future _syncDST({required String deviceId, required DstInfo dstInfo}) async {
    final Map<String, dynamic> map = {};

    if (!dstInfo.supportsDst) {
      //不支持夏令时，不需要开启规则
      map['DSTRule'] = 'Off';
    } else {
      try {
        if (dstInfo.supportsDst &&
            null != dstInfo.startDate &&
            null != dstInfo.endDate) {
          //按周计算
          Map<String, dynamic> start = {
            'Year': dstInfo.startDate!.year,
            'Month': dstInfo.startDate!.month,
            'Week': dstInfo.startWeekOfMonth, //几月的第几个星期
            'Day': dstInfo.startDate!.weekday %
                7, //按周计算时表示星期几，0为星期天
            'Hour': 0,
            'Minute': 0,
          };
          Map<String, dynamic> end = {
            'Year': dstInfo.endDate!.year,
            'Month': dstInfo.endDate!.month,
            'Week': dstInfo.endWeekOfMonth,
            'Day': dstInfo.endDate!.weekday % 7,
            'Hour': 0,
            'Minute': 0,
          };

          map['DSTRule'] = 'On';
          map['DSTStart'] = start;
          map['DSTEnd'] = end;
        } else {
          map['DSTRule'] = 'Off';
        }
      } catch (e) {
        debugPrint('syncDST error: $e');
      }
    }

    if (map.isEmpty) {
      return;
    }

    try {
      await JFApi.xcDevice.xcDevSetSysConfig(
          deviceId: deviceId,
          commandName: 'General.Location',
          config: jsonEncode(map),
          configLen: 0,
          command: 1040,
          timeout: 5000);
    } catch (e) {
      debugPrint('syncDST set error: $e');
    }
  }
}
