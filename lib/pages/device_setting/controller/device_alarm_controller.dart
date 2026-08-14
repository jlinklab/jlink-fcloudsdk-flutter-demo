import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/api/mobile_systeminfo/MobileSystemInfo_api.dart';
import 'package:xcloudsdk_flutter/manager/device_config_manager.dart';
import 'package:xcloudsdk_flutter/xcloud.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/manager/device_manager.dart';
import 'package:xcloudsdk_flutter_example/manager/push_manager.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/device_alarm_custom_voice_page.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/model/model.dart';
import 'package:xcloudsdk_flutter_example/views/x_single_selector.dart';

import '../../../models/user_instance.dart';
import '../../../views/toast/toast.dart';
import '../../device_ability/device_ability_manager.dart';
import 'package:go_router/go_router.dart';

class DeviceAlarmController extends ChangeNotifier {
  final BuildContext context;
  final String deviceId;
  int channel = 0;

  List<AlarmSettingSection> dataSource = [];

  ///是否-报警订阅
  bool isAlarmSubscribe = false;

  ///是否-移动侦测总开关
  bool isMoveMotion = false;

  ///是否-移动侦测-录像
  bool isMoveMotionRecord = false;

  ///是否-移动侦测-抓图
  bool isMoveMotionSnap = false;

  ///是否-移动侦测-消息上报
  bool isMoveMotionMessage = false;

  ///是否支持设备警铃
  bool supportAlarmBeep = false;

  ///是否-设备警铃
  bool isAlarmBeep = false;

  ///存储移动侦测配置数据
  late Map<String, dynamic> motionDataSource;

  String moveMotionName = '';

  DeviceAlarmController({
    required this.context,
    required this.deviceId,
  }) {
    _init();
  }

  void _init() {
    _configDeviceSetItemMoleList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queryData();
    });
  }

  _queryData() async {
    KToast.show();
    await _queryMoveMotionConfig();
    await _queryAlarmSubscribe();
    await _queryConfigHumanDetect();
    await _queryConfigHumanRuleLimit();
    await _queryConfigAlarmBeep();
    KToast.dismiss();
    _configDeviceSetItemMoleList();
  }

  _queryMoveMotionConfig() async {
    try {
      //获取移动侦测相关配置
      Map<String, dynamic> respond = await JFApi.xcDevice.xcDevGetChnConfig(
          deviceId: deviceId,
          channelNo: 0,
          commandName: "Detect.MotionDetect",
          command: 1042,
          timeout: 15000);
      motionDataSource = respond;
      moveMotionName = motionDataSource['Name'];
      Map<String, dynamic> jsonMap = motionDataSource[moveMotionName];
      isMoveMotion = jsonMap['Enable'];
      isMoveMotionRecord = jsonMap['EventHandler']['RecordEnable'];
      isMoveMotionSnap = jsonMap['EventHandler']['SnapEnable'];
      isMoveMotionMessage = jsonMap['EventHandler']['MessageEnable'];

      ///设备警铃
      supportAlarmBeep = await DeviceAbilityManager.queryAbility(
          deviceId: deviceId,
          type: DeviceAbilityType.bOtherFunctionSupportAlarmVoiceTipsType);
      if (supportAlarmBeep) {
        isAlarmBeep = jsonMap['EventHandler']['VoiceEnable'];
        beepVoiceEnum = jsonMap['EventHandler']['VoiceType'];
      }
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  _queryAlarmSubscribe() async {
    //获取订阅状态
    String jfPushToken = await PushManager.instance.getJfPushToken();
    if (jfPushToken.isEmpty) return;
    List<String> tokenList = [];
    tokenList.add(jfPushToken);
    AlarmSubscribebaseBody sn = AlarmSubscribebaseBody(sn: deviceId);
    List<AlarmSubscribebaseBody> snList = [];
    snList.add(sn);
    Querysubscribe messageBody = Querysubscribe(tks: tokenList, snlist: snList);
    isAlarmSubscribe =
        await JFApi.xcAlarmMessage.xcAlarmQuerySubscribeStatus(messageBody);
  }

  ///人形检测 ##########################
  Map? mapHumanDetect;

  ///是否显示人形检测
  bool bShowsHumanDetect = false;

  ///人形检测开关
  bool bStatusHumanDetect = false;

  ///是否支持警戒线
  bool bSupportLine = false;

  ///是否支持警戒区域
  bool bSupportArea = false;

  ///智能踪迹开关
  bool bStatusShowTrack = false;

  ///是否支持智能踪迹
  bool bShowTrack = false;

  ///智能警戒规则限制配置
  Map? mapHumanRuleLimit;

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
          channelNo: 0,
          commandName: 'Detect.HumanDetection',
          command: 1042,
          timeout: 10000);

      if (bShowLoading) {
        KToast.dismiss();
      }
      if (resultMap['Ret'] == 100 &&
          resultMap['Detect.HumanDetection.[0]'] != null) {
        mapHumanDetect = resultMap;
        bShowsHumanDetect = true;

        Map? humanDectionConfig = resultMap['Detect.HumanDetection.[0]'];

        bStatusHumanDetect = humanDectionConfig?['Enable'] as bool;

        ///读取智能踪迹开关
        if (humanDectionConfig?['ShowTrack'] != null) {
          if (humanDectionConfig?['ShowTrack'].runtimeType == int) {
            bStatusShowTrack = humanDectionConfig?['ShowTrack'] == 1;
          } else {
            bStatusShowTrack = humanDectionConfig?['ShowTrack'] as bool;
          }
        }
      }
    } catch (e) {
      debugPrint('debug  human 获取失败${e.toString()}');
      KToast.dismiss();
    }
    return;
  }

  Future _queryConfigHumanRuleLimit({bool bShowLoading = false}) async {
    if (bSupportLine || bSupportArea) {
      //已经查询过能力，不再重复查询
    }
    final bAlarmFunctionPEAInHumanPed = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bAlarmFunctionPEAInHumanPed);
    if (bAlarmFunctionPEAInHumanPed == false) {
      return;
    }
    try {
      final resultMap = await JFApi.xcDevice.xcDevGetSysConfig(
          deviceId: deviceId,
          commandName: DeviceJsonName.humanRuleLimit,
          command: 1360,
          timeout: 20000);
      if (resultMap['Ret'] == 100 && resultMap['HumanRuleLimit'] != null) {
        mapHumanRuleLimit = resultMap['HumanRuleLimit'];
        bSupportLine = mapHumanRuleLimit!['SupportLine'] as bool? ?? false;
        bSupportArea = mapHumanRuleLimit!['SupportArea'] as bool? ?? false;
        bShowTrack = mapHumanRuleLimit!['ShowTrack'] as bool? ?? false;
      }
    } catch (e) {
      debugPrint('debug  humanRuleLimit 获取失败${e.toString()}');
    }
    return;
  }

  Future _onSetHumanDetect(
      {required Map requestMap, bool bShowLoading = false}) async {
    if (bShowLoading) {
      KToast.show();
    }
    try {
      final jsStr = jsonEncode(requestMap);

      final result = await JFApi.xcDevice.xcDevSetChnConfig(
          deviceId: deviceId,
          channelNo: 0,
          commandName: "Detect.HumanDetection",
          config: jsStr,
          configLen: 0,
          command: 1040,
          timeout: 15000);
      if (bShowLoading) {
        KToast.dismiss();
      }
      if (result >= 0) {
        ///设置成功
        _configDeviceSetItemMoleList();
      }
    } catch (e) {
      KToast.dismiss();
    }
    return;
  }

  ///demo只支持杰峰推送，不支持厂商推送
  _onSetAlarmSubscribe({bool bShowLoading = false}) async {
    if (bShowLoading) {
      KToast.show();
    }
    try {
      if (!isAlarmSubscribe) {
        await PushManager.instance.unsubscribe(deviceId);
      } else {
        await PushManager.instance.subscribe(deviceId);
      }
      if (bShowLoading) {
        KToast.dismiss();
      }
      _configDeviceSetItemMoleList();
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  _onSetMoveMotion(Map jsonMap, {bool bShowLoading = false}) async {
    if (bShowLoading) {
      KToast.show();
    }
    try {
      String jsonString = json.encode(jsonMap);
      await JFApi.xcDevice.xcDevSetChnConfig(
          deviceId: deviceId,
          channelNo: 0,
          commandName: "Detect.MotionDetect",
          config: jsonString,
          configLen: jsonString.length + 1,
          command: 1040,
          timeout: 15000);
      _configDeviceSetItemMoleList();
      if (bShowLoading) {
        KToast.dismiss();
      }
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  _configDeviceSetItemMoleList() {
    dataSource.clear();

    List<ListTile> alarmSectionItems = [];
    List<ListTile> pushSectionItems = [];
    List<ListTile> advancedSectionItems = [];

    alarmSectionItems.add(ListTile(
        title: Text(TR.current.on),
        trailing: CupertinoSwitch(
            value: isMoveMotion,
            onChanged: (value) {
              isMoveMotion = value;
              Map tempMap = Map.from(motionDataSource);
              tempMap[moveMotionName]['Enable'] = isMoveMotion;
              _onSetMoveMotion(tempMap, bShowLoading: true);
            })));

    if (isMoveMotion) {
      alarmSectionItems.add(ListTile(
          title: Text(TR.current.baseStationHumanDetectionSwitch),
          trailing: CupertinoSwitch(
              value: bStatusHumanDetect,
              onChanged: (value) {
                bStatusHumanDetect = value;
                Map tempMap = Map.from(mapHumanDetect ?? {});
                tempMap['Detect.HumanDetection.[0]']['Enable'] =
                    bStatusHumanDetect;
                _onSetHumanDetect(requestMap: tempMap, bShowLoading: true);
              })));

      if (bStatusHumanDetect && bShowTrack) {
        advancedSectionItems.add(ListTile(
          title: Text(TR.current.Show_traces),
          subtitle: Text(TR.current.TR_Show_Traces_Tip),
          trailing: CupertinoSwitch(
            value: bStatusShowTrack,
            onChanged: (value) {
              bStatusShowTrack = value;
              final tempMap = Map.from(mapHumanDetect ?? {});
              final humanDetectConfig = tempMap['Detect.HumanDetection.[0]'];
              if (humanDetectConfig != null) {
                humanDetectConfig['ShowTrack'] = bStatusShowTrack;
                _onSetHumanDetect(requestMap: tempMap, bShowLoading: true);
              }
            },
          ),
        ));
      }

      if (bStatusHumanDetect && (bSupportLine || bSupportArea)) {
        advancedSectionItems.add(ListTile(
          title: Text(TR.current.TR_Rule_Setting),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.pushNamed('deviceAlarmSmartRule', queryParameters: {
              'deviceId': deviceId,
            }).then((_) {
              _queryConfigHumanDetect();
              _queryConfigHumanRuleLimit();
              _configDeviceSetItemMoleList();
            });
          },
        ));
      }

      pushSectionItems.add(ListTile(
          title: Text(TR.current.alarmSubscription),
          trailing: CupertinoSwitch(
              value: isAlarmSubscribe,
              onChanged: (value) {
                isAlarmSubscribe = value;
                _onSetAlarmSubscribe(bShowLoading: true);
              })));

      advancedSectionItems.add(ListTile(
          title: Text(TR.current.alarmRecording),
          trailing: CupertinoSwitch(
              value: isMoveMotionRecord,
              onChanged: (value) {
                isMoveMotionRecord = value;
                Map tempMap = Map.from(motionDataSource);
                tempMap[moveMotionName]['EventHandler']['RecordEnable'] =
                    isMoveMotionRecord;
                _onSetMoveMotion(tempMap, bShowLoading: true);
              })));

      advancedSectionItems.add(ListTile(
          title: Text(TR.current.alarmScreenshot),
          trailing: CupertinoSwitch(
              value: isMoveMotionSnap,
              onChanged: (value) {
                isMoveMotionSnap = value;
                Map tempMap = Map.from(motionDataSource);
                tempMap[moveMotionName]['EventHandler']['SnapEnable'] =
                    isMoveMotionSnap;
                _onSetMoveMotion(tempMap, bShowLoading: true);
              })));

      advancedSectionItems.add(ListTile(
          title: Text(TR.current.tr_settings_alarm_beep),
          trailing: CupertinoSwitch(
              value: isAlarmBeep,
              onChanged: (value) {
                isAlarmBeep = value;
                _configDeviceSetItemMoleList();
                Map tempMap = Map.from(motionDataSource);
                tempMap[moveMotionName]['EventHandler']['VoiceEnable'] =
                    isAlarmBeep;
                _onSetMoveMotion(tempMap, bShowLoading: true);
              })));
      if (isAlarmBeep) {
        advancedSectionItems.add(ListTile(
          title: Text(TR.current.tr_settings_alarm_bell_select),
          onTap: () {
            onChooseBeepVoice();
          },
        ));
      }

      alarmSectionItems.add(ListTile(
          title: Text(TR.current.messageReporting),
          trailing: CupertinoSwitch(
              value: isMoveMotionMessage,
              onChanged: (value) {
                isMoveMotionMessage = value;
                Map tempMap = Map.from(motionDataSource);
                tempMap[moveMotionName]['EventHandler']['MessageEnable'] =
                    isMoveMotionMessage;
                _onSetMoveMotion(tempMap, bShowLoading: true);
              })));
    }

    dataSource.add(AlarmSettingSection(
      title: TR.current.dynamic_alarm,
      items: alarmSectionItems,
    ));

    if (pushSectionItems.isNotEmpty) {
      dataSource.add(AlarmSettingSection(
        title: TR.current.push_setting,
        items: pushSectionItems,
      ));
    }

    if (advancedSectionItems.isNotEmpty) {
      dataSource.add(AlarmSettingSection(
        title: TR.current.advanced_set,
        items: advancedSectionItems,
      ));
    }

    notifyListeners();
  }

  ///beepStr
  Map? mapAlarmVoice;
  List beepVoiceList = [];
  int beepVoiceEnum = 0;
  String beepStr = '';

  Future _queryConfigAlarmBeep({bool bShowLoading = false}) async {
    if (supportAlarmBeep == false) {
      return;
    }
    if (bShowLoading) {
      KToast.show();
    }
    try {
      /// 需要先设置设备语言
      String deviceLanguage =
          await MobileSystemAPI.instance.xcLocalePreferredLanguage();
      int language =
          deviceLanguage.toLowerCase().startsWith('zh') ? 1 : 0; //1：中文 0：英文
      Map tempMap = {
        'BrowserLanguageType': language,
      };
      final String jsStr = jsonEncode(tempMap);
      final resultLanguage = await JFApi.xcDevice.xcDevSetSysConfig(
          deviceId: deviceId,
          commandName: 'BrowserLanguage',
          config: jsStr,
          configLen: 0,
          command: 1040,
          timeout: 10000);
      if (bShowLoading) {
        KToast.dismiss();
      }
      if (resultLanguage >= 0) {
        debugPrint('设备语言设置成功: ${TR.current.local}');
      }
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      if (bShowLoading == false && context.mounted) {
        context.pop();
      }
    }

    ///再获取beepVoiceList
    if (bShowLoading) {
      KToast.show();
    }
    try {
      final resultMap = await JFApi.xcDevice.xcDevGetSysConfig(
          deviceId: deviceId,
          commandName: 'Ability.VoiceTipType',
          timeout: 20000);
      if (bShowLoading) {
        KToast.dismiss();
      }
      if (resultMap['Ret'] == 100 &&
          resultMap['Ability.VoiceTipType'] != null) {
        if (resultMap['Ability.VoiceTipType']!.runtimeType == List) {
          List list = resultMap['Ability.VoiceTipType']! as List;
          if (list.isNotEmpty) {
            mapAlarmVoice = list[0];
          }
        } else {
          mapAlarmVoice = resultMap['Ability.VoiceTipType']!;
          List tempVoiceList = mapAlarmVoice!['VoiceTip'];

          for (Map voice in tempVoiceList) {
            beepVoiceList.add(voice);
          }
        }
        if (bShowLoading) {
          _configDeviceSetItemMoleList();
        }
      }
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      if (bShowLoading == false && context.mounted) {
        context.pop();
      }
    }
    return;
  }

  onChooseBeepVoice() {
    final List<String> dataList =
        beepVoiceList.map((e) => e['VoiceText'] as String).toList();
    int? index;
    for (int i = 0; i < beepVoiceList.length; i++) {
      Map voice = beepVoiceList[i];
      if (voice['VoiceEnum'] == beepVoiceEnum) {
        index = i;
      }
    }
    XSingleSelector.show(
        context: context,
        title: '',
        dataList: dataList,
        onSelect: (int index) {
          final Map voice = beepVoiceList[index];
          int selectBeepVoiceEnum = voice['VoiceEnum'];
          String selectBeepStr = voice['VoiceText'];
          _onSetAlarmBell(selectBeepVoiceEnum, selectBeepStr, true);
        },
        curIndex: index);
  }

  _onSetAlarmBell(
      int selectBeepVoiceEnum, String selectBeepStr, bool isHandle550) {
    beepVoiceEnum = selectBeepVoiceEnum;
    if (beepVoiceEnum == 550 && isHandle550) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return DeviceAlarmCustomVoicePage(deviceId: deviceId);
      })).then((isConfigCustomSuccess) {
        ///配置自定义语音成功
        if (isConfigCustomSuccess == true) {
          _onSetAlarmBell(selectBeepVoiceEnum, selectBeepStr, false);
        }
      });

      return;
    }
    beepStr = selectBeepStr;
    _configDeviceSetItemMoleList();
    Map tempMap = Map.from(motionDataSource);
    tempMap[moveMotionName]['EventHandler']['VoiceType'] = beepVoiceEnum;
    _onSetMoveMotion(tempMap, bShowLoading: true);
  }
}

class AlarmSettingSection {
  final String? title;
  final List<ListTile> items;

  AlarmSettingSection({
    this.title,
    required this.items,
  });
}
