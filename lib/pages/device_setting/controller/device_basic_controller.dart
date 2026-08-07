import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/manager/device_config_manager.dart';
import 'package:xcloudsdk_flutter/utils/extensions.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/manager/device_manager.dart';
import 'package:xcloudsdk_flutter_example/manager/device_property_manager.dart';
import 'package:xcloudsdk_flutter_example/manager/push_manager.dart';
import 'package:xcloudsdk_flutter_example/pages/device_ability/device_ability_manager.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/model/model.dart';
import 'package:xcloudsdk_flutter_example/utils/jpeg_chn_title_helper.dart';
import 'package:xcloudsdk_flutter_example/utils/log_util.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';
import 'package:xcloudsdk_flutter_example/widgets/sensitivity_slider.dart';

class _DeviceLanguage {
  final String type;
  final String name;
  _DeviceLanguage(this.type, this.name);
}

class DeviceBasicController extends ChangeNotifier {
  final BuildContext context;
  final String deviceId;
  int channel = 0;

  /// 通用配置列表
  List<Widget> commonConfigItems = [];

  /// 图像配置列表
  List<Widget> imageConfigItems = [];

  DeviceBasicController({
    required this.context,
    required this.deviceId,
  }) {
    _init();
  }

  void _init() {
    _queryAllConfig();
  }

  // ==================== 状态灯 & 提示音 ====================

  bool _bSupportStatusLight = false;
  bool _lightStatus = false;
  bool _bSupportCloseVoiceTip = false;
  bool _voiceTipStatus = false;
  Map _mapExtraStateCtrl = {};

  Future<void> _queryStatusLightAndVoiceTip() async {
    _bSupportStatusLight = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportStatusLed);
    _bSupportCloseVoiceTip = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportCloseVoiceTip);

    if (!_bSupportStatusLight && !_bSupportCloseVoiceTip) return;

    try {
      final resultMap = await JFApi.xcDevice.xcDevGetSysConfig(
        deviceId: deviceId,
        commandName: 'FbExtraStateCtrl',
      );
      if (resultMap['FbExtraStateCtrl'] != null) {
        _mapExtraStateCtrl =
            Map<String, dynamic>.from(resultMap['FbExtraStateCtrl']);
        if (_bSupportStatusLight) {
          _lightStatus = _mapExtraStateCtrl['ison'] == 1;
        }
        if (_bSupportCloseVoiceTip) {
          _voiceTipStatus = _mapExtraStateCtrl['PlayVoiceTip'] == 1;
        }
      }
    } catch (e) {
      debugPrint('查询状态灯/提示音失败: ${kErrorMsg(e)}');
    }
  }

  void _setStatusLight(bool value) async {
    _lightStatus = value;
    _mapExtraStateCtrl['ison'] = value ? 1 : 0;
    await _setExtraStateCtrl();
  }

  void _setVoiceTip(bool value) async {
    _voiceTipStatus = value;
    _mapExtraStateCtrl['PlayVoiceTip'] = value ? 1 : 0;
    await _setExtraStateCtrl();
  }

  Future<void> _setExtraStateCtrl() async {
    KToast.show();
    try {
      final config = jsonEncode(_mapExtraStateCtrl);
      await JFApi.xcDevice.xcDevSetSysConfig(
        deviceId: deviceId,
        commandName: 'FbExtraStateCtrl',
        config: config,
        configLen: config.length,
        command: 1040,
        timeout: 15000,
      );
      KToast.show(status: TR.current.saveSuccess);
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  // ==================== 设备名称 ====================

  String _deviceName = '';

  String get deviceName => _deviceName;

  void _queryDeviceName() {
    final device = DeviceManager.instance.getDevice(deviceId: deviceId);
    _deviceName = device?.nickname ?? device?.uuid ?? '';
  }

  void showEditDeviceNameDialog() {
    final controller = TextEditingController(text: _deviceName);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(TR.current.setDeviceName),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: TR.current.inputDeviceNameHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(TR.current.cancelBtn),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _saveDeviceName(controller.text.trim());
              },
              child: Text(TR.current.confirmBtn),
            ),
          ],
        );
      },
    );
  }

  void _saveDeviceName(String newName) async {
    if (newName.isEmpty) return;
    KToast.show();
    try {
      final device = DeviceManager.instance.getDevice(deviceId: deviceId);
      if (device != null && device.fromShare) {
        // 分享设备修改昵称
        if ((device as SharedDevice).shareId.isNotEmpty) {
          await JFApi.xcAccount.xcEditDeviceInfo(
            deviceId: deviceId,
            userName: '',
            nickName: newName,
          );
        }
      } else {
        final userName =
            await JFApi.xcDevice.xcDevGetLocalUserName(deviceId: deviceId);
        await JFApi.xcAccount.xcEditDeviceInfo(
          deviceId: deviceId,
          userName: userName,
          nickName: newName,
        );
        // 同步更新报警订阅中的设备名称（仅当已订阅时）
        await _updateSubscribeNameIfSubscribed(newName);
        //修改通道水印
        await changeDeviceWaterMark(newName);
      }
      _deviceName = newName;
      device?.nickname = newName;
      KToast.show(status: TR.current.saveSuccess);
      _buildUI();
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  /// 查询订阅状态，若已订阅则更新设备名称
  Future<void> _updateSubscribeNameIfSubscribed(String newName) async {
    try {
      String jfPushToken = await PushManager.instance.getJfPushToken();
      if (jfPushToken.isEmpty) return;

      AlarmSubscribebaseBody sn = AlarmSubscribebaseBody(sn: deviceId);
      Querysubscribe messageBody = Querysubscribe(
        tks: [jfPushToken],
        snlist: [sn],
      );
      bool isSubscribed =
          await JFApi.xcAlarmMessage.xcAlarmQuerySubscribeStatus(messageBody);
      if (isSubscribed) {
        await PushManager.instance.subscribe(deviceId, deviceName: newName);
      }
    } catch (e) {
      debugPrint('更新订阅名称失败: $e');
    }
  }

  ///修改通道水印
  Future<void> changeDeviceWaterMark(String editName) async {
    try {
      var videoWidget = await DeviceConfigManager.getConfigToObject<
              List<Map<String, dynamic>>>(
          deviceId: deviceId, commandName: DeviceJsonName.aVEncVideoWidget);
      Map<String, dynamic>? chanelTitle =
          videoWidget.firstWhereOrNull((e) => e.containsKey('ChannelTitle'));
      if (chanelTitle != null) {
        chanelTitle['ChannelTitle']['Name'] = editName;
      }
      Map<String, dynamic>? chanelTitleAttr = videoWidget
          .firstWhereOrNull((e) => e.containsKey('ChannelTitleAttribute'));
      if (chanelTitleAttr != null) {
        chanelTitleAttr['ChannelTitleAttribute']['EncodeBlend'] = true;
        chanelTitleAttr['ChannelTitleAttribute']['PreviewBlend'] = true;
      }
      int result = await DeviceConfigManager.setConfig(
          deviceId: deviceId,
          commandName: DeviceJsonName.aVEncVideoWidget,
          config: jsonEncode(videoWidget));

      if (result >= 0) {
        final waterMarkMark = await JpegChnTitleHelper.instance
            .buildLegacyWatermarkMark(deviceId: deviceId, editName: editName);
        await JFApi.xcDevice
            .devSetWaterMark(deviceId: deviceId, mark: waterMarkMark);
      } else {}
    } catch (e) {
      LogUtils.deviceConfig.log('设置水印失败: $e');
    } finally {}
  }
  // ==================== 设备语言 ====================

  bool _bSupportMultiLanguage = false;
  final List<_DeviceLanguage> _multiLanguages = [];
  _DeviceLanguage? _preferenceLanguage;

  static const Map<String, String> _languageNameMap = {
    'Arabic': 'العربية',
    'Brazilian': 'Português (Brasil)',
    'English': 'English',
    'French': 'Français',
    'German': 'Deutsch',
    'Greek': 'Ελληνικά',
    'Hebrew': 'עברית',
    'Hungarian': 'Magyar',
    'Italian': 'Italiano',
    'Japanese': '日本語',
    'Poland': 'Polski',
    'Portugal': 'Português',
    'Romanian': 'Română',
    'Russian': 'Русский',
    'SimpChinese': '简体中文',
    'Spanish': 'Español',
    'Finnish': 'Suomi',
    'Thai': 'ไทย',
    'TradChinese': '繁體中文',
    'Turkey': 'Türkçe',
    'Bulgarian': 'Български',
    'Korean': '한국어',
    'Czech': 'Čeština',
    'Dutch': 'Nederlands',
    'Farsi': 'فارسی',
    'Indonesian': 'Bahasa Indonesia',
    'Slovakia': 'Slovenčina',
    'Swedish': 'Svenska',
    'Vietnamese': 'Tiếng Việt',
    'ChineseEnglish': '中文English',
  };

  Future<void> _queryDeviceLanguages() async {
    _multiLanguages.clear();
    try {
      final resultMap = await DeviceConfigManager.getConfigToObject<List>(
        deviceId: deviceId,
        commandName: DeviceJsonName.multiLanguage,
        command: 1360,
      );
      for (var i in resultMap) {
        String type = i.toString();
        String name = _languageNameMap[type] ?? type;
        _multiLanguages.add(_DeviceLanguage(type, name));
      }
      _bSupportMultiLanguage = _multiLanguages.isNotEmpty;
      if (_bSupportMultiLanguage) {
        await _queryDevicePreferenceLanguage();
      }
    } catch (e) {
      debugPrint('查询设备语言失败: $e');
    }
  }

  Future<void> _queryDevicePreferenceLanguage() async {
    try {
      final type = await DeviceConfigManager.getConfigToObject<String>(
        deviceId: deviceId,
        commandName: DeviceJsonName.locationLanguage,
      );
      String name = _languageNameMap[type] ?? type;
      _preferenceLanguage = _DeviceLanguage(type, name);
    } catch (e) {
      debugPrint('查询设备当前语言失败: $e');
    }
  }

  void _setPreferenceLanguage(_DeviceLanguage language) async {
    if (!_bSupportMultiLanguage) return;
    KToast.show();
    try {
      await DeviceConfigManager.setConfig(
        deviceId: deviceId,
        commandName: DeviceJsonName.locationLanguage,
        config: jsonEncode(language.type),
      );
      KToast.show(status: TR.current.saveSuccess);
      await _queryDevicePreferenceLanguage();
      _buildUI();
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  void _showLanguageSelector() {
    int curIndex = 0;
    for (int i = 0; i < _multiLanguages.length; i++) {
      if (_preferenceLanguage?.type == _multiLanguages[i].type) {
        curIndex = i;
        break;
      }
    }
    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(TR.current.deviceLanguage),
          children: _multiLanguages.map((lang) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _setPreferenceLanguage(lang);
              },
              child: Row(
                children: [
                  Text(lang.name),
                  const Spacer(),
                  if (_preferenceLanguage?.type == lang.type)
                    const Icon(Icons.check, color: Colors.blue),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ==================== 图像翻转 ====================

  bool isFlipImageLeftRight = false;
  bool isFlipImageTopBottom = false;
  Map<String, dynamic> mapCameraParam = {};

  Future<void> _queryCameraInfo() async {
    final bSupportHidePictureFlip = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportHidePictureFlip);
    final bSupportHidePictureMirror = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportHidePictureMirror);
    if (bSupportHidePictureFlip && bSupportHidePictureMirror) return;

    try {
      const command = 'Camera.Param';
      final resultMap = await JFApi.xcDevice.xcDevGetChnConfig(
          deviceId: deviceId,
          channelNo: channel,
          commandName: command,
          command: 1042,
          timeout: 15000);
      if (resultMap['Ret'] != null && resultMap['Ret'] == 100) {
        mapCameraParam = resultMap['$command.[$channel]'];
        isFlipImageLeftRight = mapCameraParam['PictureMirror'] == '0x1';
        isFlipImageTopBottom = mapCameraParam['PictureFlip'] == '0x1';
      }
    } catch (e) {
      debugPrint('查询相机参数失败: ${kErrorMsg(e)}');
    }
  }

  void _setCameraInfo(Map<String, dynamic> requestMap) {
    String jsonStr = jsonEncode(requestMap);
    KToast.show();
    JFApi.xcDevice
        .xcDevSetChnConfig(
            deviceId: deviceId,
            channelNo: channel,
            commandName: 'Camera.Param',
            config: jsonStr,
            configLen: jsonStr.length + 1,
            command: 1040,
            timeout: 15000)
        .then((resultMap) {
      KToast.dismiss();
      _queryCameraInfo().then((_) {
        _buildUI();
      });
    }).catchError((e) {
      KToast.show(status: kErrorMsg(e));
    });
  }

  // ==================== 日夜切换灵敏度 ====================

  bool _bSupportDNChangeByImage = false;
  double _dnSliderValue = 0.0;

  Future<void> _queryDNChangeAbility() async {
    _bSupportDNChangeByImage = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportDNChangeByImage);
    if (!_bSupportDNChangeByImage) return;
    // 从 Camera.Param 的 DncThr 计算滑杆初始值
    final dncThr = mapCameraParam['DncThr'] ?? 50;
    _dnSliderValue =
        ((50 - (dncThr is int ? dncThr : int.tryParse('$dncThr') ?? 50)) / 4)
            .clamp(0, 10)
            .toDouble();
  }

  /// 设置灵敏度
  void _setSensibilityLevel(int level) {
    final tempMap = Map<String, dynamic>.from(mapCameraParam);
    tempMap['DncThr'] = 50 - (level * 4);
    final jsStr = jsonEncode([tempMap]);
    KToast.show();
    DeviceConfigManager.setConfig(
      deviceId: deviceId,
      commandName: DeviceJsonName.cameraParam,
      config: jsStr,
    ).then((resultMap) async {
      KToast.show(status: TR.current.saveSuccess);
    }).catchError((e) async {
      KToast.show(status: kErrorMsg(e));
    });
  }

  /// 构建日夜切换灵敏度内联区域
  Widget _buildDayNightSection() {
    return SensitivitySlider(
      initialValue: _dnSliderValue,
      label: TR.current.dayNightSensitivity,
      onCompleted: _setSensibilityLevel,
    );
  }

  // ==================== 全双工对讲 ====================

  bool _bSupportFullDuplexTalk = false;
  bool _isDuplexTalk = true;

  Future<void> _queryFullDuplexTalk() async {
    _bSupportFullDuplexTalk = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportTwoWayVoiceTalk);
    if (!_bSupportFullDuplexTalk) return;
    _isDuplexTalk =
        DevicePropertyManager.instance.getIdrTalkMode(deviceId: deviceId);
  }

  void _setFullDuplexTalk(bool value) async {
    try {
      _isDuplexTalk = value;
      DevicePropertyManager.instance.saveIdrTalkMode(deviceId, _isDuplexTalk);
      KToast.show(status: TR.current.saveSuccess);
      _buildUI();
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  // ==================== 喇叭音量 ====================

  bool _bSupportSpeakerVolume = false;
  int _speakerVolume = 1;
  Map _mapVolumeOutput = {};

  Future<void> _querySpeakerVolume() async {
    try {
      final result = await DeviceConfigManager.getConfigToObject<Map<String, dynamic>>(
        deviceId: deviceId,
        commandName: DeviceJsonName.alarmVolume,
      );
      if (result['LeftVolume'] != null) {
        _bSupportSpeakerVolume = true;
        _mapVolumeOutput = result;
        _speakerVolume = (result['LeftVolume'] as int? ?? 1).clamp(1, 100);
      }
    } catch (e) {
      _bSupportSpeakerVolume = false;
    }
  }

  void _setSpeakerVolume(int volume) {
    final tempMap = Map<String, dynamic>.from(_mapVolumeOutput);
    tempMap['LeftVolume'] = volume;
    tempMap['RightVolume'] = volume;
    final jsStr = jsonEncode([tempMap]);
    KToast.show();
    DeviceConfigManager.setConfig(
      deviceId: deviceId,
      commandName: DeviceJsonName.alarmVolume,
      config: jsStr,
    ).then((resultMap) {
      KToast.show(status: TR.current.saveSuccess);
    }).catchError((e) {
      KToast.show(status: kErrorMsg(e));
    });
  }

  // ==================== 麦克风音量 ====================

  bool _bSupportMicVolume = false;
  int _micVolume = 1;
  Map _mapVolumeInput = {};

  Future<void> _queryMicVolume() async {
    try {
      final result = await DeviceConfigManager.getConfigToObject<Map<String, dynamic>>(
        deviceId: deviceId,
        commandName: DeviceJsonName.alarmVolumeIn,
      );
      if (result['LeftVolume'] != null) {
        _bSupportMicVolume = true;
        _mapVolumeInput = result;
        _micVolume = (result['LeftVolume'] as int? ?? 1).clamp(0, 100);
      }
    } catch (e) {
      _bSupportMicVolume = false;
    }
  }

  void _setMicVolume(int volume) {
    final tempMap = Map<String, dynamic>.from(_mapVolumeInput);
    tempMap['LeftVolume'] = volume;
    tempMap['RightVolume'] = volume;
    final jsStr = jsonEncode([tempMap]);
    KToast.show();
    DeviceConfigManager.setConfig(
      deviceId: deviceId,
      commandName: DeviceJsonName.alarmVolumeIn,
      config: jsStr,
    ).then((resultMap) {
      KToast.show(status: TR.current.saveSuccess);
    }).catchError((e) {
      KToast.show(status: kErrorMsg(e));
    });
  }

  // ==================== 构建 UI ====================

  void _queryAllConfig() async {
    _queryDeviceName();
    await _queryStatusLightAndVoiceTip();
    await _queryDeviceLanguages();
    await _queryCameraInfo();
    await _queryDNChangeAbility();
    await _queryFullDuplexTalk();
    await _querySpeakerVolume();
    await _queryMicVolume();
    _buildUI();
  }

  void _buildUI() {
    // 通用配置
    commonConfigItems.clear();

    // 设备名称
    commonConfigItems.add(ListTile(
      title: Text(TR.current.labelDeviceName),
      subtitle: Text(_deviceName),
      trailing: const Icon(Icons.edit),
      onTap: showEditDeviceNameDialog,
    ));

    // 提示音开关
    if (_bSupportCloseVoiceTip) {
      commonConfigItems.add(ListTile(
        title: Text(TR.current.voiceTipSwitch),
        trailing: CupertinoSwitch(
          value: _voiceTipStatus,
          onChanged: (value) {
            _setVoiceTip(value);
          },
        ),
      ));
    }

    // 指示灯开关
    if (_bSupportStatusLight) {
      commonConfigItems.add(ListTile(
        title: Text(TR.current.statusLightSwitch),
        trailing: CupertinoSwitch(
          value: _lightStatus,
          onChanged: (value) {
            _setStatusLight(value);
          },
        ),
      ));
    }

    // 设备语言
    if (_bSupportMultiLanguage) {
      commonConfigItems.add(ListTile(
        title: Text(TR.current.deviceLanguage),
        subtitle: Text(_preferenceLanguage?.name ?? ''),
        trailing: const Icon(Icons.chevron_right),
        onTap: _showLanguageSelector,
      ));
    }

    // 日夜切换
    if (_bSupportDNChangeByImage) {
      commonConfigItems.add(_buildDayNightSection());
    }

    // 全双工对讲
    if (_bSupportFullDuplexTalk) {
      commonConfigItems.add(ListTile(
        title: Text(TR.current.fullDuplexIntercom),
        trailing: CupertinoSwitch(
          value: _isDuplexTalk,
          onChanged: (value) {
            _setFullDuplexTalk(value);
          },
        ),
      ));
    }

    // 喇叭音量
    if (_bSupportSpeakerVolume) {
      commonConfigItems.add(SensitivitySlider(
        initialValue: _speakerVolume.toDouble(),
        label: TR.current.speakerVolume,
        min: 1,
        max: 100,
        divisions: 99,
        onCompleted: _setSpeakerVolume,
      ));
    }

    // 麦克风音量
    if (_bSupportMicVolume) {
      commonConfigItems.add(SensitivitySlider(
        initialValue: _micVolume.toDouble(),
        label: TR.current.micVolume,
        min: 0,
        max: 100,
        divisions: 100,
        onCompleted: _setMicVolume,
      ));
    }

    // 图像配置
    imageConfigItems.clear();

    imageConfigItems.add(ListTile(
      title: Text(TR.current.imageFlipLeftRight),
      trailing: CupertinoSwitch(
          value: isFlipImageLeftRight,
          onChanged: (value) {
            isFlipImageLeftRight = value;
            Map<String, dynamic> requestMap = Map.from(mapCameraParam);
            requestMap['PictureMirror'] = !isFlipImageLeftRight ? '0x0' : '0x1';
            _setCameraInfo(requestMap);
          }),
    ));

    imageConfigItems.add(ListTile(
      title: Text(TR.current.imageFlipUpDown),
      trailing: CupertinoSwitch(
          value: isFlipImageTopBottom,
          onChanged: (value) {
            isFlipImageTopBottom = value;
            Map<String, dynamic> requestMap = Map.from(mapCameraParam);
            requestMap['PictureFlip'] = !isFlipImageTopBottom ? '0x0' : '0x1';
            _setCameraInfo(requestMap);
          }),
    ));

    notifyListeners();
  }
}
