import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/api/alarm_message/model.dart';
import 'package:fcloudsdk/manager/device_config_manager.dart';
import 'package:fcloudsdk/utils/date_util.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/manager/device_property_manager.dart';
import 'package:fcloudsdk_example/manager/idr_property_manager.dart';
import 'package:fcloudsdk_example/pages/device_ability/device_ability_manager.dart';
import 'package:fcloudsdk_example/pages/device_setting/model/model.dart';
import 'package:fcloudsdk_example/utils/map_utils.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///电池管理控制器
class DeviceBatteryManageController extends ChangeNotifier {
  final String deviceId;
  final BuildContext context;

  Device? device;

  Map<String, dynamic>? lowElectrMode;

  Map<String, dynamic>? aovAbility;

  bool supportLowPowerWorkTime = false;

  int currentPower = 0; //当前电量
  int powerThreshold = 0; //低电量报警阈值
  int lowElectrMin = 0; //低电量报警阈值范围
  int lowElectrMax = 0; //低电量报警阈值范围

  int todayPreview = 0; //当天预览时长(s)
  int todayWakeup = 0; //当天唤醒时长(s)
  int todayAlarm = 0; //当天报警次数
  int weekPreview = 0; //一周预览时长(s)
  int weekWakeup = 0; //一周唤醒时长(s)
  int weekAlarm = 0; //一周报警次数

  List<String> xTitleSevenDays = [];

  String get showPreview =>
      isToday ? _convertTimeStr(todayPreview) : _convertTimeStr(weekPreview);

  String get showWakeup =>
      isToday ? _convertTimeStr(todayWakeup) : _convertTimeStr(weekWakeup);

  String get showAlarmCount =>
      isToday ? todayAlarm.toString() : weekAlarm.toString();

  String selectedSegmentKey = 'today';

  bool get isToday => selectedSegmentKey == 'today';

  ///切换统计周期（今天/最近一周）
  void switchSegment(String key) {
    if (selectedSegmentKey == key) {
      return;
    }
    selectedSegmentKey = key;
    notifyListeners();
  }

  bool get isAov => DevicePropertyManager.instance.isAOV(deviceId: deviceId);

  ///电量上报句柄
  int _uploadHandle = -1;

  StreamSubscription? _batterySubscription;

  ///图表显示点位数据
  List<FlSpot> todayBlSpots = [];
  List<FlSpot> weakBlSpots = [];

  List<FlSpot> get showBlSpots => isToday ? todayBlSpots : weakBlSpots;

  List<FlSpot> today4GSpots = [];
  List<FlSpot> weak4GSpots = [];

  List<FlSpot> get show4GSpots => isToday ? today4GSpots : weak4GSpots;

  ///滑块临时值，拖动中不落盘
  double sliderValue = 0;

  DeviceBatteryManageController(
      {required this.deviceId, required this.context}) {
    device = DeviceManager.instance.getDevice(deviceId: deviceId);

    xTitleSevenDays = _getPastSevenDays();

    _init();
  }

  _init() async {
    KToast.show();
    try {
      _startListenBattery();
      await _request();
      sliderValue = powerThreshold.toDouble();
      _refresh();
      KToast.dismiss();
    } catch (e) {
      KToast.dismiss();
      KToast.show(status: kErrorMsg(e));
      Future.delayed(const Duration(seconds: 1), () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    IDRPropertyManager.instance
        .makeStopUploadProperty(deviceId: deviceId, handle: _uploadHandle);
    super.dispose();
  }

  Future _request() async {
    await Future.wait([
      _getSysFunctions(),
      _getAovAbility(),
      _getLowElectrMode(),
      _getDeviceLog(onlyToday: false),
      _getDeviceLog(onlyToday: true),
      _getAlarmCount(onlyToday: false),
      _getAlarmCount(onlyToday: true),
    ]);
    if (supportLowPowerWorkTime) {
      await _getLowPowerWorkTime();
    }
  }

  _refresh() {
    if (sliderValue.toInt() != powerThreshold) {
      sliderValue = powerThreshold.toDouble();
    }
    notifyListeners();
  }

  String _convertTimeStr(int seconds) {
    if (seconds > 3600 * 24) {
      return "${(seconds / (3600 * 24)).toStringAsFixed(2)} ${TR.current.days}";
    }
    if (seconds > 3600) {
      return "${(seconds / 3600).toStringAsFixed(2)} ${TR.current.sHour}";
    }
    if (seconds > 60) {
      return "${(seconds / 60).toStringAsFixed(2)} ${TR.current.sMin}";
    }
    return "$seconds ${TR.current.sSec}";
  }

  List<String> _getPastSevenDays() {
    List<String> dateArray = [];
    DateTime endDate =
        DateUtil.startOfDay(DateTime.now().add(const Duration(days: 1)));
    DateFormat dateFormatter = DateFormat('M.d');
    for (int i = 0; i <= 7; i++) {
      DateTime previousDate = endDate.subtract(Duration(days: i));
      String formattedDate = dateFormatter.format(previousDate);
      dateArray.add(formattedDate);
    }
    return dateArray.reversed.toList();
  }

  double _calculateXPercent(String timeUtc, DateTime start, DateTime end) {
    DateTime utcTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss").parseUtc(timeUtc);
    DateTime localTime = utcTime.toLocal();
    int totalDuration =
        end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    int elapsedDuration =
        localTime.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    if (totalDuration <= 0) {
      return 0.0;
    }
    double percentage = elapsedDuration / totalDuration;
    return percentage.clamp(0.0, 1.0);
  }

  ///监听电量上报，复用IDRPropertyManager
  void _startListenBattery() async {
    _batterySubscription =
        IDRPropertyManager.instance.eleStream(deviceId).listen((event) {
      int? level = event?.level;
      if (level != null && level > 0) {
        currentPower = level;
        notifyListeners();
      }
    });
    _uploadHandle = await IDRPropertyManager.instance
        .makeStartUploadProperty(deviceId: deviceId);
  }

  //获取设备能力
  Future _getSysFunctions() async {
    await DeviceAbilityManager.update(deviceId: deviceId);
    supportLowPowerWorkTime = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionLowPowerWorkTime);
  }

  //获取配置 - AovAbility
  Future _getAovAbility() async {
    if (!isAov) {
      return;
    }
    var response = await JFApi.xcDevice.xcDevGetSysConfig(
        deviceId: deviceId, commandName: "Ability.AovAbility");
    if (response.containsKey('Ret') && response['Ret'] == 100) {
      var map = response['Ability.AovAbility'];
      if (map is Map) {
        aovAbility = Map<String, dynamic>.from(map);
        lowElectrMin = MapParser.queryInt(aovAbility, 'LowElectrMin', 0);
        lowElectrMax = MapParser.queryInt(aovAbility, 'LowElectrMax', 0);
      }
    }
  }

  //获取低功耗工作数据
  Future _getLowPowerWorkTime() async {
    var response =
        await DeviceConfigManager.getConfigToObject<Map<String, dynamic>>(
            deviceId: deviceId, commandName: DeviceJsonName.lowPowerWorkTime);
    if (response.isNotEmpty) {
      var viewlist = MapParser.queryList(response, 'RealViewTime', []);
      var wakeuplist = MapParser.queryList(response, 'WakeupTime', []);
      todayPreview = viewlist.isNotEmpty ? viewlist.last : 0;
      todayWakeup = viewlist.isNotEmpty ? wakeuplist.last : 0;
      weekPreview = viewlist.reduce((a, b) => a + b);
      weekWakeup = wakeuplist.reduce((a, b) => a + b);
    }
  }

  //获取报警数量
  Future _getAlarmCount({required bool onlyToday}) async {
    DateTime endTime = DateUtil.endOfDay(DateTime.now());
    DateTime startTime =
        DateUtil.startOfDay(DateTime.now().subtract(const Duration(days: 6)));
    if (onlyToday) {
      endTime = DateUtil.endOfDay(DateTime.now());
      startTime = DateUtil.startOfDay(DateTime.now());
    }
    var rModel = AlarmCountModel(
      snlist: [
        AlarmCountSnModel(
          sn: deviceId,
          lf: 'or',
          fttp: 'or',
        )
      ],
      st: DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime),
      et: DateFormat('yyyy-MM-dd HH:mm:ss').format(endTime),
      type: 'MSG',
    );
    var response = await JFApi.xcAlarmMessage.xcQueryAlarmCount(rModel);
    var dt = MapParser.queryList(response, 'dt', []);
    if (dt.isNotEmpty) {
      var map = dt.first as Map;
      var numList = MapParser.queryList(map, 'numlist', []);
      if (numList.isNotEmpty) {
        var total =
            numList.map((e) => int.parse(e['count'])).reduce((a, b) => a + b);
        if (onlyToday) {
          todayAlarm = total;
        } else {
          weekAlarm = total;
        }
      }
    }
  }

  //获取设备日志，拿电量和信号数据
  Future _getDeviceLog({required bool onlyToday}) async {
    DateTime endTime = DateUtil.endOfDay(DateTime.now());
    DateTime startTime =
        DateUtil.startOfDay(DateTime.now().subtract(const Duration(days: 6)));
    double maxX = 7;
    if (onlyToday) {
      endTime = DateUtil.endOfDay(DateTime.now());
      startTime = DateUtil.startOfDay(DateTime.now());
      maxX = 24;
    }

    today4GSpots.clear();
    weak4GSpots.clear();
    todayBlSpots.clear();
    weakBlSpots.clear();

    var allGet = false;
    var page = 1;
    var pageSize = 5000;
    var logs = [];
    var utcFormat = "yyyy-MM-dd'T'HH:mm:ss";

    while (allGet == false) {
      var config = {
        "startTime": DateFormat('yyyy-MM-dd 00:00:00.000').format(startTime),
        "endTime": DateFormat('yyyy-MM-dd 23:59:59.999').format(endTime),
        "id": deviceId,
        "page": page,
        "size": pageSize,
        "timezoneMin": DateTime.now().timeZoneOffset.inMinutes,
        "isAddLastList": 1,
        "type": "devicelog",
      };
      String req = jsonEncode(config);
      var result = await JFApi.xcDevice.xcDevGetConfigFromGateWay(
          url: '/shadow/api/v1/device/log', jsonConfigs: req);
      var resultMap = MapParser.queryMap(result, 'data', {});
      var list = MapParser.queryList(resultMap, 'list', []);
      logs.addAll(list);
      if (list.length >= 5000) {
        allGet = false;
        page++;
      } else {
        allGet = true;
        var lastList = MapParser.queryList(resultMap, 'lastList', []);
        if (lastList.isNotEmpty) {
          lastList.first?['utcTime'] =
              DateFormat(utcFormat).format(startTime.toUtc());
          logs.addAll(lastList);
        }
      }
    }

    logs.sort((a, b) => DateFormat(utcFormat)
        .parse(a['utcTime'])
        .compareTo(DateFormat(utcFormat).parse(b['utcTime'])));

    for (var map in logs) {
      try {
        var utcTime = MapParser.readString(map, "utcTime");
        var logInfoStr = MapParser.queryString(map, 'logInfo', '');
        var logInfo = jsonDecode(logInfoStr);
        if (logInfo.containsKey('bl') || logInfo.containsKey('ss4g')) {
          var bl = MapParser.readInt(logInfo, "bl");
          var ss4g = MapParser.readInt(logInfo, "ss4g");

          var spotsBl = onlyToday ? todayBlSpots : weakBlSpots;
          var spots4G = onlyToday ? today4GSpots : weak4GSpots;
          if (utcTime != null && bl != null) {
            spotsBl.add(
              FlSpot(_calculateXPercent(utcTime, startTime, endTime) * maxX,
                  min(bl.toDouble(), 100).toDouble()),
            );
          }
          if (utcTime != null && ss4g != null) {
            spots4G.add(
              FlSpot(_calculateXPercent(utcTime, startTime, endTime) * maxX,
                  min(ss4g.toDouble(), 3) / 3 * 100),
            );
          }
        }
      } catch (e) {
        debugPrint('battery manager 循环解析电量信息报错 error=$e');
      }
    }
  }

  //获取配置 - LowElectrMode
  Future _getLowElectrMode() async {
    if (!isAov) {
      return;
    }
    var response = await JFApi.xcDevice.xcDevGetSysConfig(
        deviceId: deviceId, commandName: "Dev.LowElectrMode");
    if (response.containsKey('Ret') && response['Ret'] == 100) {
      var map = response['Dev.LowElectrMode'];
      if (map is Map) {
        lowElectrMode = Map<String, dynamic>.from(map);
        powerThreshold = MapParser.queryInt(map, 'PowerThreshold', 0);
      }
    }
  }

  //保存配置 - LowElectrMode
  Future _saveLowElectrMode() async {
    var jsonStr = jsonEncode(lowElectrMode);
    await JFApi.xcDevice.xcDevSetSysConfig(
        deviceId: deviceId,
        commandName: 'Dev.LowElectrMode',
        config: jsonStr,
        configLen: jsonStr.length,
        command: 1040,
        timeout: 5000);
  }

  ///滑块拖动
  void onSliderChanged(double value) {
    sliderValue = value;
    notifyListeners();
  }

  ///滑块拖动结束，保存低电量阈值
  void onSliderChangeEnd(double value) async {
    powerThreshold = value.toInt();
    lowElectrMode?['PowerThreshold'] = value.toInt();
    try {
      KToast.show();
      await _saveLowElectrMode();
      KToast.dismiss();
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      await _getLowElectrMode();
    } finally {
      _refresh();
    }
  }
}
