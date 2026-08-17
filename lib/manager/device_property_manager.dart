import 'dart:async';

import 'package:xcloudsdk_flutter/manager/device_config_manager.dart';
import 'package:xcloudsdk_flutter/utils/extensions.dart';
import 'package:xcloudsdk_flutter_example/api/add_device_api.dart';
import 'package:xcloudsdk_flutter_example/manager/device_manager.dart';
import 'package:xcloudsdk_flutter_example/pages/device_ability/device_ability_manager.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/model/model.dart';
import 'package:xcloudsdk_flutter_example/utils/sp_utils.dart';

///多目类别, 根据[streamCount]路码流[lensesCount]个展示窗口判别类别
enum MultiCategory {
  ///默认 1路流 1个画面
  oneStreamOneLenses(1, 1, 1, 1),

  ///双目上下拼接 两个镜头  1路流 2个窗口, 属于分割 , 根据信息帧 0x0e 判断
  oneStreamTowLensesWithTBSplit(1, 2, 2, 2),

  ///双目上下拼接演变而来  两个镜头  1路流 3个窗口, 属于分割 , 根据信息帧 0x0e 判断是双目拼接
  ///再根据PID属性配置是否展示三个窗口 propList -> threeScreen
  ///原先的双目拼接设备，把一个枪机画面裁剪成2个枪机画面的的方式，再加上球机画面，实现三目的效果
  oneStreamThreeLensesWithTowCamera(1, 2, 3, 2),

  ///双目左右拼接 两个镜头  1路流 2个窗口, 属于分割 , 根据信息帧 0x0c 判断
  oneStreamTowLensesWithLRSplit(1, 2, 2, 2),

  ///双目变焦  2路流 一路主 一路辅 2个窗口, 信息帧 0x0A ,根据特殊的设备配置 判断
  ///设备预览只有一路画面，可以播放其中一个镜头的画面。高倍数下可以同时打开主辅码流
  twoStreamTwoLensesWithSecondaryStream(1, 2, 2, 2),

  ///三目变焦 双目变焦设备 增加一个镜头而来
  ///开始展示2的画面,可以变为3个画面
  ///双目上下分割 展示2个画面. 双目变焦属性支持启用辅码流展示第3个画面
  twoStreamThreeLensesWithSecondaryStream(1, 3, 3, 2),

  ///双目 2路流  2个窗口, 暂时没有这种设备
  twoStreamTwoLenses(2, 2, 2, 1),

  ///三目 1路码流 3个窗口, 属于分割 ,根据信息帧 0x10 判断
  oneStreamThreeLenses(1, 3, 3, 3),

  ///三目 3路流 3个窗口
  threeStreamThreeLenses(3, 3, 3, 1);

  ///有几个视频流通道(不是码流类型)
  final int streamCount;

  ///相机数量,用于区分是否是真多目
  final int cameraCount;

  ///需要展示几个窗口画面
  final int lensesCount;

  ///1路码流展示1个窗口时,分割的比例
  final int splitCount;

  const MultiCategory(
    this.streamCount,
    this.cameraCount,
    this.lensesCount,
    this.splitCount,
  );
}

class PtzAbility {
  final int direction;
  final int ptzChannel;

  PtzAbility({
    required this.direction,
    required this.ptzChannel,
  });

  factory PtzAbility.fromJson(Map<String, dynamic> json) => PtzAbility(
        direction: json["Direction"],
        ptzChannel: json["PtzChannel"],
      );

  Map<String, dynamic> toJson() => {
        "Direction": direction,
        "PtzChannel": ptzChannel,
      };
}

///多目设备属性
///在首次进入预览或者设置时，通过属性判断赋值属性值并进行缓存
///第二次进入预览时，先使用缓存的属性，之后再更新属性

///真多目和假多目的定义
///真多目: 摄像头个数和预览的画面个数相同
///假多目: 摄像头个数和预览的画面个数不同; 比如 设备有两个摄像头,但是要展示三个画面
///多目的定义:
///设备有几个摄像头就是几木; 比如,设备有两个摄像头但是展示3个窗口画面,属于双目,也属于假多目
class MultiEyesProperty {
  String deviceId = '';

  ///多目类别
  ///在进入预览之前,会根据设备的配置确定一下类型,但是大多数不能确定
  ///之后进入预览起流之后,根据视频流的信息帧确认类型,进而刷新窗口布局
  MultiCategory category = MultiCategory.oneStreamOneLenses;

  ///设备摄像头个数 == 视频通道个数
  bool get isTrueMultiEyes => category.cameraCount == category.lensesCount;

  ///设备支持的窗口分割模式
  ///竖屏 横屏 两种样式
  Map<String, dynamic> multiChannelSplitWindows = {};

  ///视频通道个数(媒体控制器中的channel)
  int? channelCount;

  ///多目通道数组, 默认有一个
  ///不需要分割,不需要切换主副码流的设备,真实的视频码流通道
  List<int> trueEyesChannels = [0];

  ///是否支持app变倍
  bool? supportAppZoom;

  ///APP端变倍的最大实际倍数
  double? appZoomMaxNum;

  ///APP端变倍的最大显示倍数
  double? appZoomMaxDisplayNum;

  ///是否支持设备变倍
  bool? supportDeviceZoom;

  ///设备当前缩放倍数
  double? deviceZoomNum;

  ///设备最大支持缩放倍数
  double? deviceZoomMaxNum;

  ///是否支持设备端变倍 V2 协议
  bool? supportDeviceZoomV2;

  ///设备端变倍 V2 的逐镜头能力
  List<Map<String, dynamic>> deviceScaleAbilities = [];

  ///设备端变倍 V2 的逐镜头配置
  List<Map<String, dynamic>> deviceScaleConfigs = [];

  ///设备支持云台配置
  ///如果设备不支持这个属性,那么就需要根据画面写死,统一格式
  List<PtzAbility>? ptzAbilities;

  ///高清抓图可变分辨率
  String? captureBetterValue;

  bool? globalCaptureBetter;

  ///是否假多目
  bool get isMultiFake {
    return category == MultiCategory.oneStreamThreeLensesWithTowCamera;
  }

  ///是否多目
  bool get isMultiEyes => category != MultiCategory.oneStreamOneLenses;

  MultiEyesProperty({this.deviceId = ''});

  MultiEyesProperty.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    if (json['category'] != null) {
      category =
          MultiCategory.values.firstWhere((e) => e.name == json['category']);
    }
    trueEyesChannels = List.from(json['trueEyesChannels']);
    supportAppZoom = json['supportAppZoom'];
    appZoomMaxNum = json['appZoomMaxNum'];
    appZoomMaxDisplayNum = json['appZoomMaxDisplayNum'];
    supportDeviceZoom = json['supportDeviceZoom'];
    deviceZoomNum = json['deviceZoomNum'];
    deviceZoomMaxNum = json['deviceZoomMaxNum'];
    supportDeviceZoomV2 = json['supportDeviceZoomV2'];
    if (json['deviceScaleAbilities'] is List) {
      deviceScaleAbilities = (json['deviceScaleAbilities'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (json['deviceScaleConfigs'] is List) {
      deviceScaleConfigs = (json['deviceScaleConfigs'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    channelCount = json['channelCount'];
    if (json['ptzAbilities'] != null) {
      ptzAbilities = json['ptzAbilities']
          .map<PtzAbility>((e) => PtzAbility.fromJson(e))
          .toList();
    }
    if (json['captureBetterValue'] != null) {
      captureBetterValue = json['captureBetterValue'];
    }
    if (json['globalCaptureBetter'] != null) {
      globalCaptureBetter = json['globalCaptureBetter'];
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['deviceId'] = deviceId;
    map['category'] = category.name;
    map['trueEyesChannels'] = trueEyesChannels;
    if (supportAppZoom != null) {
      map['supportAppZoom'] = supportAppZoom;
    }
    if (appZoomMaxNum != null) {
      map['appZoomMaxNum'] = appZoomMaxNum;
    }
    if (appZoomMaxDisplayNum != null) {
      map['appZoomMaxDisplayNum'] = appZoomMaxDisplayNum;
    }
    if (supportDeviceZoom != null) {
      map['supportDeviceZoom'] = supportDeviceZoom;
    }
    if (deviceZoomNum != null) {
      map['deviceZoomNum'] = deviceZoomNum;
    }
    if (deviceZoomMaxNum != null) {
      map['deviceZoomMaxNum'] = deviceZoomMaxNum;
    }
    if (supportDeviceZoomV2 != null) {
      map['supportDeviceZoomV2'] = supportDeviceZoomV2;
    }
    if (deviceScaleAbilities.isNotEmpty) {
      map['deviceScaleAbilities'] = deviceScaleAbilities;
    }
    if (deviceScaleConfigs.isNotEmpty) {
      map['deviceScaleConfigs'] = deviceScaleConfigs;
    }
    if (channelCount != null) {
      map['channelCount'] = channelCount;
    }
    if (ptzAbilities != null) {
      map['ptzAbilities'] = ptzAbilities!.map((e) => e.toJson()).toList();
    }
    if (captureBetterValue != null) {
      map['captureBetterValue'] = captureBetterValue;
    }
    if (globalCaptureBetter != null) {
      map['globalCaptureBetter'] = globalCaptureBetter;
    }
    return map;
  }
}

///刷新云台配置,可能更新,刷新下播放器Widget
class UpdatePtzAbilityEvent {
  final String deviceId;
  final List<PtzAbility> ptzAbilities;

  UpdatePtzAbilityEvent({required this.deviceId, required this.ptzAbilities});
}

///SystemInfo的解析和缓存
///设备类型的 获取和 缓存 ，比如是否是 NVR，是否是多目，可能从多个渠道获取
///{"isXX":0,"channelCount":3}
///同步 get
///变化时更新
class DevicePropertyManager {
  static final DevicePropertyManager instance = DevicePropertyManager._();

  DevicePropertyManager._();

  ///缓存的设备媒体宽度
  static const String _videoWidthKey = 'video_width';

  ///缓存的设备媒体高度
  static const String _videoHeightKey = 'video_height';

  ///缓存的设备媒体是否自适应
  static const String _videoAutoKey = 'video_auto';

  ///多目设备属性
  static const String _multiEyesPropertyKey = 'multiEyesProperty';

  ///缓存的多目窗口布局
  static const String _multiLayoutKey = 'multiFakeLayoutKey';

  static const String _idrTalkMode = 'idrTalkMode';

  ///是否时AOV设备
  static const String _avo = 'aov';

  ///是否是低功耗设备
  static const String _lowPower = 'lowPower';

  ///获取缓存的Key
  String _spKey(String key, String deviceId, {int? channel}) =>
      '${key}_${deviceId}_${channel ?? 0}';

  ///根据PID从服务器获取设备属性列表
  Future<List<Map<String, dynamic>>?> getDeviceTypePropListByPid(
      {required String pid}) async {
    try {
      if (pid.isEmpty) {
        return null;
      }
      var response = await addDeviceAPI.getDevicePropList(pid: pid);
      if (response is Map && response['data'] is List) {
        return (response['data'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      //
    }
    return null;
  }

  bool isLowPower({required String deviceId}) {
    String key = _spKey(_lowPower, deviceId);
    Device? device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device != null) {
      return device.isLowPowerType;
    }
    return false;
  }

  ///是否是低功耗设备
  Future<bool> isLowPowerAsync({required String deviceId}) async {
    String key = _spKey(_lowPower, deviceId);
    if (SPUtils.preferences.containsKey(key)) {
      return SPUtils.preferences.getBool(key)!;
    }
    bool lowPower = false;
    Device? device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device == null) {
      lowPower = false;
    } else {
      lowPower = device.deviceType == 21 || device.deviceType == 285409282;
      await SPUtils.preferences.setBool(key, lowPower);
    }

    return lowPower;
  }

  // ==================== NVR 设备判断 ====================

  static const String _nvr = 'is_nvr';
  static const String _nvrChannelCount = 'nvr_channel_count';

  /// 根据设备类型判断是否是NVR（同步方法）
  bool isNVRByDeviceType(int devType) {
    // 无线基站设备
    const int eeDevWBS = 305201153;
    if (devType == eeDevWBS) {
      return true;
    }

    // 高4位为 0x02 或 0x03 表示NVR
    const int mask = 0x0F000000;
    int masked = devType & mask;
    if (masked == 0x02000000 || masked == 0x03000000) {
      return true;
    }
    return false;
  }

  /// IPC 通过 Pid 判断
  bool isIPCCheckedByPid(String pid) {
    return pid.startsWith('A9');
  }

  /// 同步读取缓存判断是否是NVR
  bool isNVR({required String deviceId}) {
    String key = _spKey(_nvr, deviceId);
    return SPUtils.preferences.getBool(key) ?? false;
  }

  /// 异步判断是否是NVR设备（三层判断：缓存 → 设备配置 → 云服务）
  Future<bool> isNVRAsync({required String deviceId}) async {
    Device? device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device == null) {
      return false;
    }
    String key = _spKey(_nvr, deviceId);
    String countKey = _spKey(_nvrChannelCount, deviceId);
    bool nvr = false;

    // 第一步：缓存命中直接返回
    if (SPUtils.preferences.containsKey(key)) {
      nvr = SPUtils.preferences.getBool(key) ?? false;
      return nvr;
    }

    // 第二步：通过设备配置获取通道列表判断
    try {
      if (!isIPCCheckedByPid(device.pid) &&
          (isNVRByDeviceType(device.deviceType) ||
              device.deviceType == 0 ||
              device.deviceType == 1 ||
              device.deviceType == 2 ||
              device.deviceType == 4 ||
              device.deviceType == 8)) {
        var response = await DeviceConfigManager.getConfigToObject<List<String>>(
          deviceId: deviceId,
          command: 1048,
          commandName: DeviceJsonName.channelTitle,
        );
        if (response.isNotEmpty) {
          nvr = response.length > 1;
          await SPUtils.preferences.setInt(countKey, response.length);
        }
      }
    } catch (e) {
      // ignore
    }

    // 通过设备配置确认是NVR，缓存之后直接返回
    if (nvr) {
      await SPUtils.preferences.setBool(key, nvr);
      return nvr;
    }

    // 第三步：通过云服务字段判断
    try {
      final cloudService = device.cloudService();
      if (cloudService != null && cloudService.channelCloud.isNotEmpty) {
        nvr = true;
        await SPUtils.preferences.setBool(key, nvr);
        await SPUtils.preferences.setInt(countKey, cloudService.channelCloud.length);
      }
    } catch (e) {
      // ignore
    }

    return nvr;
  }

  /// 同步读取缓存获取NVR通道数
  int getNvrChannelCount({required String deviceId}) {
    String key = _spKey(_nvrChannelCount, deviceId);
    return SPUtils.preferences.getInt(key) ?? 1;
  }

  /// 异步获取NVR通道数
  Future<int> getNvrChannelCountAsync({required String deviceId}) async {
    String key = _spKey(_nvrChannelCount, deviceId);
    if (SPUtils.preferences.containsKey(key)) {
      return SPUtils.preferences.getInt(key)!;
    }
    int channelCount = 1;

    // 方式1：通过设备配置获取通道列表
    try {
      var response = await DeviceConfigManager.getConfigToObject<List<String>>(
        deviceId: deviceId,
        command: 1048,
        commandName: DeviceJsonName.channelTitle,
      );
      if (response.isNotEmpty) {
        channelCount = response.length;
        await SPUtils.preferences.setInt(key, channelCount);
        return channelCount;
      }
    } catch (e) {
      // ignore
    }

    // 方式2：通过 AVEnc.VideoWidget 获取
    if (channelCount == 1) {
      try {
        var response = await DeviceConfigManager.getConfigToObject<
            List<Map<String, dynamic>>>(
          deviceId: deviceId,
          commandName: DeviceJsonName.aVEncVideoWidget,
        );
        if (response.isNotEmpty) {
          channelCount = response.length;
          await SPUtils.preferences.setInt(key, channelCount);
          return channelCount;
        }
      } catch (e) {
        // ignore
      }
    }

    return channelCount;
  }

  // ==================== NVR 通道状态获取 ====================

  /// 获取 NVR 设备各通道的状态列表
  /// 通过 NetWork.ChnStatus 设备配置获取
  Future<List<FrontDeviceStatus>> getChannelStates({
    required String deviceId,
    required int channelCount,
  }) async {
    List<FrontDeviceStatus> statusList = [];

    try {
      // 通过 NetWork.ChnStatus 获取通道状态
      var response = await DeviceConfigManager.getConfigToObject<
          List<Map<String, dynamic>>>(
        deviceId: deviceId,
        commandName: DeviceJsonName.netWorkChnStatus,
      );

      if (response.isNotEmpty) {
        for (int i = 0; i < channelCount && i < response.length; i++) {
          Map<String, dynamic> channelStatusMap = response[i];
          String status = channelStatusMap['Status'] ?? '';
          FrontDeviceStatus deviceStatus = FrontDeviceStatus.values.firstWhere(
            (e) => e.des == (status.isEmpty ? 'None' : status),
            orElse: () => FrontDeviceStatus.unKnown,
          );
          statusList.add(deviceStatus);
        }
      }
    } catch (e) {
      // ignore
    }

    // 如果获取失败，填充默认状态
    while (statusList.length < channelCount) {
      statusList.add(FrontDeviceStatus.none);
    }

    return statusList;
  }

  ///缓存获取是否是AOV设备
  ///当缓存不存在时，尝试从属性列表判断
  bool isAOV({required String deviceId}) {
    String key = _spKey(_avo, deviceId);
    bool aov = SPUtils.preferences.getBool(key) ?? false;
    if (aov == false) {
      Device? device = DeviceManager.instance.getDevice(deviceId: deviceId);
      if (device != null && device.propList != null) {
        aov = device.propList!
                .firstWhereOrNull((e) => e['propCode'] == "aovFunc") !=
            null;
      }
    }
    return aov;
  }

  // 数据解析
  int parseValue(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      int tempValue = int.tryParse(value) ?? 0;
      return tempValue;
    }
    return 0;
  }

  ///判断是否是AOV设备
  ///1.从[SystemFunction.aovMode]获取是否支持
  ///2.从服务器获取
  Future<bool> isAOVAsync(
      {required String deviceId, bool refresh = false}) async {
    String key = _spKey(_avo, deviceId);
    if (SPUtils.preferences.containsKey(key) && !refresh) {
      return SPUtils.preferences.getBool(key) ?? false;
    }
    //请求相关能力确认时AOV设备
    //1.从 SystemFunction 获取
    bool aov = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportAovMode);
    if (aov) {
      await SPUtils.preferences.setBool(key, aov);
      return aov;
    }
    //2.从服务器获取
    Device? device = DeviceManager.instance.getDevice(deviceId: deviceId);

    bool enable(List<Map<String, dynamic>> propList) {
      var aovFunc =
          propList.firstWhereOrNull((e) => e['propCode'] == "aovFunc");
      return aovFunc != null;
    }

    if (device != null) {
      if (device.propList != null && !refresh) {
        aov = enable(device.propList!);
      } else if (device.pid.isNotEmpty) {
        var propList = await getDeviceTypePropListByPid(pid: device.pid);
        DeviceManager.instance
            .updateDevice(deviceId: deviceId, propList: propList);
        aov = enable(device.propList ?? []);
      }
    }
    await SPUtils.preferences.setBool(key, aov);
    return aov;
  }

  Future<void> saveIdrTalkMode(String deviceId, bool isFullDuple) async {
    await SPUtils.preferences
        .setBool(_spKey(_idrTalkMode, deviceId), isFullDuple);
  }

  bool getIdrTalkMode({required String deviceId, int? channle}) {
    String key = _spKey(_idrTalkMode, deviceId, channel: channle);
    return SPUtils.preferences.getBool(key) ??
        (DevicePropertyManager.instance.isLowPower(deviceId: deviceId) ||
            DeviceAbilityManager.getLocalAbilityEnable(
                deviceId: deviceId,
                type: DeviceAbilityType.bOtherFunctionSupportTwoWayVoiceTalk));
  }
}
