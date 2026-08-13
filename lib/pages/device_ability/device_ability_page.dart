import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';

/// 参考 SystemFunctionBean.java 定义所有能力项
/// 每个分类包含所有已知字段，API 返回中缺失的字段默认为 false
const Map<String, List<String>> _allAbilityFields = {
  'AlarmFunction': [
    'AlarmConfig', // 报警配置
    'BlindDetect', // 遮挡
    'LossDetect', // 丢失侦测
    'MotionDetect', // 移动侦测
    'NetAbort', // 网络终止
    'NetAlarm', // 网络报警
    'NetIpConflict', // ip冲突
    'StorageFailure', // 存储失败
    'StorageLowSpace', // 存储空间不足
    'StorageNotExist', // 硬盘不存在
    'Consumer433Alarm',
    'ConsumerRemote',
    'IPCalarm', // ipc报警
    'SensorAlarmCenter',
    'NetAbortExtend', // 网络异常扩展
    'SerialAlarm',
    'VideoAnalyze', // 视频分析
    'NewVideoAnalyze', // 新智能分析
    'PEAInHumanPed', // 支持周界拌线功能的人形检测功能 只针对IPC设备 NVR设备用通道能力集
    'ManuIntellAlertAlarm', // 手动警戒
    'IntellAlertAlarm', // 智能警戒 单品设备
    'MotionHumanDection', // 是否支持同时打开移动追踪和人形报警功能
  ],
  'EncodeFunction': [
    'DoubleStream', // 双码流
    'SnapStream', // 抓图
    'WaterMark', // 水印
    'CombineStream',
    'SmartH264', // 图像增强
    'SmartH264V2', // 图像增强
    'CustomChnDAMode', // 自定义数模切换功能
    'MultiChannel', // 多通道预览编码
  ],
  'NetServerFunction': [
    'Net3G',
    'NetARSP',
    'NetAlarmCenter',
    'NetDDNS',
    'NetDHCP',
    'NetDNS',
    'NetEmail',
    'NetFTP',
    'NetIPFilter',
    'NetMobile',
    'NetMutlicast',
    'NetNTP',
    'NetPPPoE',
    'NetWifi',
    'Net4GSignalLevel',
    'WifiRouteSignalLevel', // 支持设备WiFi信号强度获取
    'Net4GDualSim', // 是否支持4g双卡网络切换
  ],
  'OtherFunction': [
    'DownLoadPause', // 录像下载暂停
    'USBsupportRecord', // usb支持录像
    'SDsupportRecord', // SD支持录像
    'SupportOnvifClient', // 是否支持ONVIF客户端
    'SupportNetLocalSearch', // 是否支持远程搜索
    'SupportMaxPlayback', // 是否支持最大回放通道数显示
    'SupportNVR', // 是否是专业NVR
    'SupportC7Platform',
    'SupportMailTest',
    'HideDigital', // 通道模式屏蔽
    'NotSupportAH', // 水平锐度
    'NotSupportAV', // 垂直锐度
    'SupportBT', // 宽动态
    'NotSupportTalk', // 对讲
    'AlterDigitalName', // 数字通道名称修改
    'SupportShowConnectStatus', // 支持显示wifi 3G 主动注册等的连接状态
    'SupportPlayBackExactSeek', // 支持回放精准定位
    'TitleAndStateUpload', // 通道标题和数字通道状态上传能力集
    'MusicFilePlay',
    'SupportSetDigIP', // 设置前端ip
    'SupportShowProductType',
    'SupportCamareStyle', // 支持摄像机图像风格
    'Supportonviftitle',
    'ShowFalseCheckTime',
    'SupportStatusLed', // 是否支持状态灯控制
    'SupportLowLuxMode',
    'SupportSlowMotion',
    'SupportTimeZone',
    'SupportImpRecord', // 标示使能
    'XMModeSwitch', // 模式切换使能
    'SupportSetPTZPresetAttribute', // 支持设置预置点
    'SupportConsSensorAlarmLink', // 支持智联报警联动
    'SupportPTZTour', // 支持巡航
    'SupportSetSnapFormat', // 支持设置拍照画质
    'SupportCapturePriority', // 支持设置拍照优先
    'SupportWifiSmartWakeup', // 支持设置wifi唤醒
    'SupportPushLowBatteryMsg', // 支持低电量提醒（门铃）
    'SupportDoorLock', // 支持门锁
    'SupportReserveWakeUp', // 支持门铃来电预约
    'SupportNoDisturbing', // 支持免打扰功能
    'SupportElectronicPTZ', // 支持电子云台能力集
    'SupportAlarmVoiceTips', // 提示音
    'SupportAlarmVoiceTipsType', // 自定义语音提示音
    'SupportNetWorkMode', // 支持网络模式切换
    'SupportCameraWhiteLight', // 支持基础白光灯
    'SupportDoubleLightBulb', // 支持双光灯
    'SupportDoubleLightBoxCamera', // 支持双光枪机
    'SupportMusicLightBulb', // 支持音乐灯
    'WifiModeSwitch', // 支持AP和路由模式的切换
    'SupportSuspiciousDetection', // 支持可疑检测
    'SmartH264', // 支持图像增强能力集
    'SupportDNChangeByImage', // 日夜切换灵敏度能力集
    'SupportNotifyLight', // 支持呼吸灯
    'SupportPirAlarm', // 支持PIR人体感应 为了规避双向门铃没有这个字段
    'SupportIntervalWakeUp', // 间隔录像能力集
    'SupportKeySwitchManager', // 按鍵管理能力集
    'SupportDetectTrack', // 人形跟随
    'SupportDevRingControl', // 外机按铃声音控制
    'SupportForceShutDownControl', // 永久不关机
    'SupportPirTimeSection', // PIR徘徊检测时间段
    'SupportPIRMicrowaveAlarm', // 支持报警组合（PIR报警）
    'Support433Ring', // 433响铃
    'SupportSetVolume', // 可控制设备的喇叭和mic的音量
    'SupportAppBindFlag',
    'SupportGetMcuVersion', // 获取单片机版本号
    'SupportBallTelescopic', // 是否支持电子放大（变倍变焦）
    'SupportCorridorMode', // 是否支持走廊模式，就是90度旋转
    'SupportSoftPhotosensitive', // 软光敏功能
    'SupportSetDetectTrackWatchPoint', // 是否支持守望功能
    'SupportOneKeyMaskVideo', // 一键遮蔽
    'SupportTimingSleep', // 自动休眠
    'SupportChargeNoShutdown', // 充电时休眠
    'SupportAlarmRemoteCall', // 一键呼叫
    'SupportQuickReply', // 是否支持快速回复
    'SupportPTZDirectionControl', // 支持云台功能（新的设备上才有）
    'SupportForceDismantleSwitch', // 防强拆
    'SupportLPWorkModeSwitch', // 工作模式选择
    'SupportAPPDeleteDigitalChannel', // 是否支持通道删除
    'SupportAPPCtrlWifiNVRPairIPC', // 是否支持无线对码
    'SupportWifiHotSpot', // 是否支持信道管理
    'AlarmOutUsedAsLed', // 人形报警联动的红蓝指示灯
    'LP4GSupportDoubleLightSwitch', // 低功耗设备灯光能力
    'SupportLowPowerDoubleLightToLightingSwitch', // 照明开关能力集
    'SupprotBaseStationModeChange', // 中继模式切换
    'NotSupportAutoAndIntelligent', // 白光灯不支持自动和智能
    'SupportPTZDirectionHorizontalControl',
    'SupportPTZDirectionVerticalControl',
    'MultiLensTwoSensor', // 支持双目
    'MultiLensThreeSensor', // 支持三目
    'SupportScaleTwoLens', // 支持双目 设备端缩放
    'SupportScaleThreeLens', // 支持三目 设备端缩放
    'SupportFishLensDisplayFlat', // 支持鱼眼镜头默认平铺
    'NotSupportMonitor', // 不支持监控预览
    'SupportLocalTipSwitch', // 报警声光配置能力集
    'SupportPirSensitive', // PIR灵敏度能力集
    'SupportTwoWayVoiceTalk', // 双向对讲能力集
    'SupportIOTCustomAudio', // IOT服务器自定义语音能力集
    'SupportIOTOperateWithServer', // IOT服务器获取厂商能力集
    'SupportCustomLocalAlarmAudio', // 是否支持本地自定义报警声
    'SupportHidePirCheckTime', // 是否要隐藏PIR检测时间选项
    'SupportTraditionalPtzNormalDirect', // 是否为传统设备PTZ正常方向
    'SupportConsumerPtzMirrorDirect', // 是否为消费类设备PTZ镜像翻转
    'SupportLowPowerSetBrightness', // 照明亮度能力集
    'SupportLowPowerSetAlarmLed', // 红蓝报警灯能力集
    'SupportMultiLensLinkageSplitScreen', // 是否支持双目上下屏
    'SupportMultiLensSplicingWfsRecordStream', // 是否支持双目录像拼接缩放
    'SupportAlarmVoiceTipInterval', // 是否支持警铃间隔时间设置
    'SupportGunBallTwoSensorPtzLocate', // 是否支持多目枪球云台定位
    'SupportEpitomeRecord', // 是否支持缩影录像
    'SupportPtzAutoAdjust', // 是否支持云台校正
    'SupportDeleteAppointRecord', // 是否支持SD卡录像删除
    'SupportBoxCameraBulb', // 支持庭院双光灯
    'AovMode', // AOV设备
    'SupportListCameraDayLightModes', // 支持灯光列表能力集
    'SupportLPWorkModeSwitchV2', // 是否支持低功耗2.0工作模式配置
    'ConsumerLightMode', // 是否支持消费类灯光模式
    'SupportSetBrightness', // 是否支持调节白光灯亮度
    'SoftLedThr', // 白光灯自动开关灯判断阈值
    'MicroFillLight', // 支持AOV设备白光灯微补光功能
    'AovAlarmHold', // AOV报警唤醒频率抑制功能
    'BatteryManager', // 电池信息展示
    'SupportVideoTalkV2', // 是否支持视频通话(IPC)
    'SupportVideoTalk', // 是否支持视频通话（门锁）
    'SupportCloseVoiceTip', // 是否支持设备提示音
    'SupportSetInVolume', // 设备麦克风音量
    'SupportGunBallTwoSensorCamera', // 双目枪球
    'MultiChnSplitWindows', // 多通道枪球
    'SupportLowPowerLongAlarmRecord', // 是否支持低功耗长时间报警录像
    'MusicPlay', // 是否支持音乐播放器
    'SetAdditionalDNS', // 是否支持设置DNS
    'HumidityDetect', // 是否支持湿度检测
    'TemperatureDetect', // 是否支持温度检测
  ],
  'PreviewFunction': [
    'Talk',
    'Tour',
    'StorageSpaceUsePercent', // 存储信息是否显示成百分比
  ],
};

/// 设备能力集页面
/// 展示设备 SystemFunction 中所有功能能力项，按分类分组显示
class DeviceAbilityPage extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const DeviceAbilityPage({
    Key? key,
    required this.deviceId,
    required this.deviceName,
  }) : super(key: key);

  @override
  State<DeviceAbilityPage> createState() => _DeviceAbilityPageState();
}

class _DeviceAbilityPageState extends State<DeviceAbilityPage> {
  /// 每项: {category: 分类名, name: 能力名, value: 值}
  final List<Map<String, dynamic>> _abilityList = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadAbility();
  }

  Future<void> _loadAbility() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final resultMap = await JFApi.xcDevice.xcDeviceSystemFunctionAbility(
        deviceId: widget.deviceId,
      );


      debugPrint(jsonEncode(resultMap));

      final systemFunction = resultMap['SystemFunction'];

      // 解析 API 返回的实际数据（可能只包含部分字段）
      final Map<String, Map> apiData = {};
      if (systemFunction is Map) {
        systemFunction.forEach((category, fields) {
          if (fields is Map) {
            apiData[category.toString()] = fields;
          }
        });
      }

      // 遍历预定义的所有能力项，缺失的默认为 false
      final List<Map<String, dynamic>> list = [];
      _allAbilityFields.forEach((category, fields) {
        final Map apiFields = apiData[category] ?? {};
        for (final name in fields) {
          final value = apiFields[name];
          list.add({
            'category': category,
            'name': name,
            'value': value is bool ? value : false,
          });
        }
      });

      // 按能力名称字母排序
      list.sort((a, b) =>
          (a['name'] as String).compareTo(b['name'] as String));

      setState(() {
        _abilityList
          ..clear()
          ..addAll(list);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = kErrorMsg(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.deviceAbility),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMsg!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAbility,
              child: Text(TR.current.retry),
            ),
          ],
        ),
      );
    }
    if (_abilityList.isEmpty) {
      return Center(
        child: Text(TR.current.noAbilityData, style: TextStyle(color: Colors.grey[600])),
      );
    }
    return ListView.builder(
      itemCount: _abilityList.length,
      itemBuilder: (context, index) {
        final item = _abilityList[index];
        final String name = item['name'] as String;
        final String category = item['category'] as String;
        final bool value = item['value'] as bool;

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            category,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          trailing: Text(
            value ? 'true' : 'false',
            style: TextStyle(
              fontSize: 14,
              color: value ? Colors.green : Colors.grey,
            ),
          ),
        );
      },
    );
  }
}
