import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/manager/device_config_manager.dart';

import '../../../common/code_prase.dart';
import '../../../generated/l10n.dart';
import '../../../views/toast/toast.dart';
import '../../device_ability/device_ability_manager.dart';

class DeviceAlarmSmartRuleController extends ChangeNotifier {
  DeviceAlarmSmartRuleController({
    required this.context,
    required this.deviceId,
  }) {
    _init();
  }

  final BuildContext context;
  final String deviceId;
  int channel = 0;

  /// 0: 警戒线 1： 警戒区域
  int alarmType = 0;
  List<SmartRuleItemModel> dataSource = [];

  void _init() {
    _configDeviceSetItemMoleList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queryData();
    });
  }

  bool bStatusSmartRule = false;
  bool bSupportLine = false;
  bool bSupportArea = false;

  Map? _mapHumanDetect;
  Map? _mapHumanRuleLimit;

  void _configDeviceSetItemMoleList() {
    dataSource.clear();

    ///智能警戒总开关
    dataSource.add(SmartRuleItemModel(
      title: TR.current.TR_Rule_Setting,
      type: SmartRuleItemType.switchType,
      switchValue: bStatusSmartRule,
      onSwitchChanged: (value) {
        bStatusSmartRule = value;
        _configDeviceSetItemMoleList();
        final tempMap = Map.from(_mapHumanDetect ?? {});
        final List? pedRuleList =
            tempMap['${DeviceJsonName.humanDetection}.[$channel]']?['PedRule'];
        if (pedRuleList != null && pedRuleList.isNotEmpty) {
          pedRuleList[0]['Enable'] = bStatusSmartRule;
          _onSetConfigMoveDetect(requestMap: tempMap, bShowLoading: true);
        }
      },
    ));

    if (bStatusSmartRule && bSupportLine) {
      dataSource.add(SmartRuleItemModel(
        title: TR.current.type_alert_line,
        type: SmartRuleItemType.arrow,
        selected: alarmType == 0,
        onTap: () {
          context.pushNamed('deviceAlarmLineOrArea', queryParameters: {
            'deviceId': deviceId,
            'alarmType': '0',
          }).then((value) async {
            if (value == true) {
              _queryConfigHumanDetect(bShowLoading: true);
            }
          });
        },
      ));
    }
    if (bStatusSmartRule && bSupportArea) {
      dataSource.add(SmartRuleItemModel(
        title: TR.current.type_alert_area,
        type: SmartRuleItemType.arrow,
        selected: alarmType == 1,
        onTap: () {
          context.pushNamed('deviceAlarmLineOrArea', queryParameters: {
            'deviceId': deviceId,
            'alarmType': '1',
          }).then((value) async {
            if (value == true) {
              _queryConfigHumanDetect(bShowLoading: true);
            }
          });
        },
      ));
    }
    if (context.mounted) {
      notifyListeners();
    }
  }

  _queryData() async {
    KToast.show();
    await _queryConfigHumanDetect();
    await _queryConfigHumanRuleLimit();
    _configDeviceSetItemMoleList();
    KToast.dismiss();
  }

  Future _queryConfigHumanDetect({bool bShowLoading = false}) async {
    final bAlarmFunctionPEAInHumanPed = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bAlarmFunctionPEAInHumanPed);
    if (bAlarmFunctionPEAInHumanPed == false) {
      return;
    }
    if (bShowLoading) {
      KToast.show();
    }
    try {
      final resultMap = await JFApi.xcDevice.xcDevGetChnConfig(
          deviceId: deviceId,
          commandName: DeviceJsonName.humanDetection,
          channelNo: channel,
          command: 1042,
          timeout: 15000);
      if (bShowLoading) {
        KToast.dismiss();
      }
      if (resultMap['Ret'] == 100 &&
          resultMap['${DeviceJsonName.humanDetection}.[$channel]'] != null) {
        _mapHumanDetect = resultMap;
        Map? humanDectionConfig =
            resultMap['${DeviceJsonName.humanDetection}.[$channel]'];
        final List? pedRuleList = humanDectionConfig?['PedRule'];
        if (pedRuleList != null && pedRuleList.isNotEmpty) {
          Map pedRule0 = pedRuleList[0];
          bStatusSmartRule = pedRule0['Enable'] as bool? ?? false;
          alarmType = pedRule0['RuleType'] as int? ?? 0;
        }

        /// 刷新页面
        _configDeviceSetItemMoleList();
      }
      if (bShowLoading) {
        _configDeviceSetItemMoleList();
      }
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      if (bShowLoading == false && context.mounted) {
        context.pop();
      }
    }
    return;
  }

  Future _queryConfigHumanRuleLimit({bool bShowLoading = false}) async {
    final bAlarmFunctionPEAInHumanPed = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bAlarmFunctionPEAInHumanPed);
    if (bAlarmFunctionPEAInHumanPed == false) {
      return;
    }
    if (bShowLoading) {
      KToast.show();
    }
    try {
      final resultMap = await JFApi.xcDevice.xcDevGetSysConfig(
          deviceId: deviceId,
          commandName: DeviceJsonName.humanRuleLimit,
          command: 1360,
          timeout: 20000);
      if (bShowLoading) {
        KToast.dismiss();
      }
      if (resultMap['Ret'] == 100 && resultMap['HumanRuleLimit'] != null) {
        _mapHumanRuleLimit = resultMap['HumanRuleLimit'];
        bSupportLine = _mapHumanRuleLimit!['SupportLine'] as bool? ?? false;
        bSupportArea = _mapHumanRuleLimit!['SupportArea'] as bool? ?? false;
      }
      if (bShowLoading) {
        _configDeviceSetItemMoleList();
      }
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      if (bShowLoading == false && context.mounted) {
        context.pop();
      }
    }
    return;
  }

  Future _onSetConfigMoveDetect(
      {required Map requestMap, bool bShowLoading = false}) async {
    if (bShowLoading) {
      KToast.show();
    }
    try {
      final jsStr = jsonEncode(requestMap);
      final result = await JFApi.xcDevice.xcDevSetChnConfig(
          deviceId: deviceId,
          channelNo: channel,
          commandName: DeviceJsonName.humanDetection,
          config: jsStr,
          configLen: 0,
          command: 1040,
          timeout: 15000);
      if (bShowLoading) {
        KToast.dismiss();
      }
      if (result >= 0) {
        /// 设置成功
        _queryConfigHumanDetect(bShowLoading: true);
      }
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      if (bShowLoading == false && context.mounted) {
        context.pop();
      }
    }
    return;
  }
}

enum SmartRuleItemType { switchType, arrow }

class SmartRuleItemModel {
  final String title;
  final SmartRuleItemType type;
  final bool switchValue;
  final bool selected;
  final Function(bool)? onSwitchChanged;
  final VoidCallback? onTap;

  SmartRuleItemModel({
    required this.title,
    required this.type,
    this.switchValue = false,
    this.selected = false,
    this.onSwitchChanged,
    this.onTap,
  });
}
