import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/api/mobile_systeminfo/MobileSystemInfo_api.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/device_alarm_custom_voice_page.dart';
import 'package:xcloudsdk_flutter_example/views/x_single_selector.dart';

import '../../../models/user_instance.dart';
import '../../../views/toast/toast.dart';
import '../../device_ability/device_ability_manager.dart';
import 'package:go_router/go_router.dart';

class DeviceAlarmController extends ChangeNotifier {
  final BuildContext context;
  final String deviceId;
  int channel = 0;

  List<ListTile> dataSource = [];

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
    _queryData();
    _configDeviceSetItemMoleList();
  }

  _queryData() async {
    await _queryMoveMotionConfig();
    await _queryAlarmSubscribe();
    await _queryConfigHumanDetect();
    await _queryConfigAlarmBeep();
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
      KToast.show(status: KErrorMsg(e));
    }
  }

  _queryAlarmSubscribe() async {
    //获取订阅状态
    Map<String, dynamic> response =
        await JFApi.xcAlarmMessage.xcGetPhoneToken();
    List<String> tokenList = [];
    tokenList.add(response['token']);
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
      }
    } catch (e) {
      debugPrint('debug  human 获取失败${e.toString()}');
      KToast.dismiss();
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

  _onSetAlarmSubscribe({bool bShowLoading = false}) async {
    if (bShowLoading) {
      KToast.show();
    }
    try {
      //获取订阅状态
      Map<String, dynamic> response =
          await JFApi.xcAlarmMessage.xcGetPhoneToken();
      String token = response['token'];
      if (!isAlarmSubscribe) {
        AlarmSubscribebaseBody body = AlarmSubscribebaseBody(sn: deviceId);
        List<AlarmSubscribebaseBody> bodyList = [];
        bodyList.add(body);
        TokenListbaseElement element = TokenListbaseElement(token: token);
        List<TokenListbaseElement> tokenList = [];
        tokenList.add(element);
        AlarmUnsubscribe model =
            AlarmUnsubscribe(snlist: bodyList, tklist: tokenList);
        await JFApi.xcAlarmMessage.xcUnsubscribeDevicesAlarmMessages(model);
      } else {
        AlarmSubscribeBody body = AlarmSubscribeBody(sn: deviceId);
        List<AlarmSubscribeBody> bodyList = [];
        bodyList.add(body);

        final package = await PackageInfo.fromPlatform();
        String bundleId = package.packageName;

        TokenListElement element = TokenListElement(
            token: token, tokenType: response['tokenType'], bundleId: bundleId);
        List<TokenListElement> tokenList = [];
        tokenList.add(element);
        AlarmSubscribe model = AlarmSubscribe(
            snlist: bodyList,
            tklist: tokenList,
            userId: UserInfo.instance.userId);

        await JFApi.xcAlarmMessage.xcSubscribeDeviceAlarmMessages(model);
      }
      if (bShowLoading) {
        KToast.dismiss();
      }
      _configDeviceSetItemMoleList();
    } catch (e) {
      KToast.show(status: KErrorMsg(e));
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
      KToast.show(status: KErrorMsg(e));
    }
  }

  _configDeviceSetItemMoleList() {
    dataSource.clear();

    dataSource.add(ListTile(
        title: Text(TR.current.on),
        trailing: CupertinoSwitch(
            value: isMoveMotion,
            onChanged: (value) {
              isMoveMotion = value;
              Map tempMap = Map.from(motionDataSource);
              tempMap[moveMotionName]['Enable'] = isMoveMotion;
              _onSetMoveMotion(tempMap, bShowLoading: true);
            })));
    if (!isMoveMotion) {
      notifyListeners();
      return;
    }

    dataSource.add(ListTile(
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

    dataSource.add(ListTile(
        title: Text(TR.current.alarmSubscription),
        trailing: CupertinoSwitch(
            value: isAlarmSubscribe,
            onChanged: (value) {
              isAlarmSubscribe = value;
              _onSetAlarmSubscribe(bShowLoading: true);
            })));

    dataSource.add(ListTile(
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

    dataSource.add(ListTile(
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

    dataSource.add(ListTile(
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
      dataSource.add(ListTile(
        title: Text(TR.current.tr_settings_alarm_bell_select),
        onTap: () {
          onChooseBeepVoice();
        },
      ));
    }
    dataSource.add(ListTile(
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
      KToast.show(status: KErrorMsg(e));
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
      KToast.show(status: KErrorMsg(e));
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
