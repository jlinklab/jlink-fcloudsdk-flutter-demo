import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/api/cloud_service/cloud_service.dart';
import 'package:xcloudsdk_flutter/utils/extensions.dart';
import 'package:xcloudsdk_flutter_example/pages/cloud/model/device_cloud.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/model/model.dart';

///更新了云服务状态事件，上层可监听进行刷新
///收到这个事件之后，可以使用缓存获取到最新的值，不需要再次异步获取刷新
class RefreshCloudStatusEvent {
  ///当值为''时代表全部更新，否则为单个设备刷新
  final String deviceId;

  ///刷新某个通道的状态
  final int? channel;

  RefreshCloudStatusEvent({required this.deviceId, this.channel});
}

///云服务 流量 状态管理类，将服务器云服务字段解析为[DeviceCloudService]进行缓存
///1.全量更新云服务
///2.单个更新云服务
///3.从缓存中获取云服务状态
class DeviceCloudServiceManager {
  static DeviceCloudServiceManager instance = DeviceCloudServiceManager._();

  DeviceCloudServiceManager._();

  final List<DeviceCloudService> _cloudServerList = [];

  ///获取全部设备的能力集，获取成功之后更新本地缓存
  ///发送一个更新所有云服务能力的事件，上层可监听，进行列表刷新
  Future<void> refreshCloudServicesStatus(
      {required List<Device> devices}) async {
    List<String> deviceIdList = devices.map((e) => e.uuid).toList();
    if (deviceIdList.isEmpty) {
      return;
    }
    try {
      List<Map<String, dynamic>> serviceList =
          await _queryCloudStatus(deviceIdList);
      if (serviceList.isNotEmpty) {
        //更新缓存
        _cloudServerList.clear();
        _cloudServerList
            .addAll(serviceList.map((e) => _parseCloudService(e)).toList());
      }
    } catch (e, trace) {
      //
    }
  }

  ///异步获取云服务状态，更新缓存并返回，发送更新云服务状态的事件
  ///如果获取更新失败则返回 null
  ///[deviceId] 设备序列号
  ///[channel] 获取某个通道的云服务状态,只有NVR设备多通道才能传非null值
  Future<DeviceCloudService?> getCloudServiceAsync(
      {required String deviceId, int? channel}) async {
    List<Map<String, dynamic>> serviceList =
        await _queryCloudStatus([deviceId]);
    if (serviceList.isEmpty) {
      return null;
    }
    DeviceCloudService deviceCloudService =
        _parseCloudService(serviceList.first);
    _cloudServerList.removeWhere((e) => e.deviceId == deviceId);
    _cloudServerList.add(deviceCloudService);
    if (channel != null) {
      return deviceCloudService.channelCloud[channel];
    }
    return deviceCloudService;
  }

  ///从本地同步获取云服务状态，如果本地没有缓存，则返回 null
  ///[deviceId] 设备序列号
  ///[channel] 获取某个通道的云服务状态,只有NVR设备多通道才能传非null值
  DeviceCloudService? getCloudService(
      {required String deviceId, int? channel}) {
    DeviceCloudService? deviceCloudService =
        _cloudServerList.firstWhereOrNull((e) => e.deviceId == deviceId);
    if (channel != null) {
      return deviceCloudService?.channelCloud[channel];
    }
    return deviceCloudService;
  }

  ///从本地同步获取云服务状态，如果本地有缓存，则直接放回；否则请求状态，并缓存，再返回，发送更新事件
  ///[deviceId] 设备序列号
  ///[channel] 获取某个通道的云服务状态,只有NVR设备多通道才能传非null值
  Future<DeviceCloudService?> getCloudServiceAsyncIfNeed(
      {required String deviceId, int? channel}) async {
    DeviceCloudService? deviceCloudService =
        getCloudService(deviceId: deviceId, channel: channel);
    if (deviceCloudService == null) {
      return getCloudServiceAsync(deviceId: deviceId, channel: channel);
    }
    return deviceCloudService;
  }

  ///单个设备的云服务状态解析为对象
  ///如果是多通道的，则赋值[DeviceCloudService]的 channelCloud 列表
  DeviceCloudService _parseCloudService(Map<String, dynamic> service) {
    DeviceCloudService deviceCloudService =
        DeviceCloudService(deviceId: service['sn']);
    deviceCloudService.allowed = service['caps']?['allowed'] ?? true;
    deviceCloudService.oemId = service['mfrsOemId'];
    deviceCloudService.lastWanIp = service['lastWanIp'];
    deviceCloudService.pid = service['pid'];
    //解析下4G流量状态
    _parseCloudFlowStatus(deviceCloudService, service);
    //云服务状态
    bool supportCloudServer = service['caps']?['xmc.service.support'] ?? false;
    bool supportCloudStorage = service['caps']?['xmc.css.vid.support'] ?? false;

    supportCloudServer =
        supportCloudServer == true || supportCloudStorage == true;
    if (supportCloudServer == false) {
      deviceCloudService.cloudServerStatus = CloudServerStatus.notSupported;
      return deviceCloudService;
    }

    int? xmcCssMaxChannel = service['caps']?['xmc.css.maxchannel'];
    if (xmcCssMaxChannel != null) {
      //属于多通道
      deviceCloudService.channelCloud = _parseChannelCloudServer(
          service['sn'],
          service['caps']?['xmc.css.vid.enable.channels'],
          service['caps']?['xmc.css.pic.expirationtime.channels']);
    } else {
      bool vidEnable = service['caps']?['xmc.css.vid.enable'] ?? false;
      if (vidEnable == false) {
        deviceCloudService.cloudServerStatus = CloudServerStatus.notPurchased;
      } else {
        //判断是否过期
        int? expire = service['caps']?['xmc.css.vid.expirationtime'];
        if (expire == null) {
          deviceCloudService.cloudServerStatus = CloudServerStatus.active;
        } else {
          DateTime expirationTime =
              DateTime.fromMillisecondsSinceEpoch(expire * 1000);
          bool after = expirationTime.isAfter(DateTime.now());
          deviceCloudService.cloudExpiredTime =
              expirationTime.millisecondsSinceEpoch;
          if (after) {
            deviceCloudService.cloudServerStatus = CloudServerStatus.active;
          } else {
            deviceCloudService.cloudServerStatus = CloudServerStatus.expired;
          }
        }
      }
    }
    return deviceCloudService;
  }

  ///解析流量状态
  void _parseCloudFlowStatus(
      DeviceCloudService cloudService, Map<String, dynamic> service) {
    CloudFlowStatus flowStatus = CloudFlowStatus.notSupported;

    bool supportG4 = service['caps']?['net.cellular.support'] ?? false;
    bool enableG4 = service['caps']?['net.cellular.enable'] ?? false;

    cloudService.iccid1 = service['caps']?['net.cellular.iccid'] ?? '';
    cloudService.iccid2 = service['caps']?['net.cellular.2ndiccid'] ?? '';
    cloudService.provider1 = service['caps']?['net.cellular.provider'] ?? 0;
    cloudService.provider2 = service['caps']?['net.cellular.2ndprovider'] ?? 0;

    if (supportG4 == false) {
      flowStatus = CloudFlowStatus.notSupported;
    } else if (enableG4 == false) {
      flowStatus = CloudFlowStatus.notPurchased;
    } else {
      int expiredTime = service['caps']?['net.cellular.expirationtime'] ?? 0;
      if (expiredTime == 0) {
        //如果过期时间为0，其实是正常的。
        flowStatus = CloudFlowStatus.active;
      }
      cloudService.flowExpiredTime = expiredTime;
      cloudService.flowFullSpace = double.tryParse(
              service['caps']?['net.cellular.storagespace'] ?? '') ??
          0;
      cloudService.flowUsedSpace =
          double.tryParse(service['caps']?['net.cellular.used'] ?? '') ?? 0;
      //判断是否到期, 提示到期续费,只能点击去购买 拦截
      if (DateTime.fromMillisecondsSinceEpoch(expiredTime * 1000)
          .isBefore(DateTime.now())) {
        flowStatus = CloudFlowStatus.expired;
      } else {
        flowStatus = CloudFlowStatus.active;
      }
    }
    cloudService.cloudFlowStatus = flowStatus;
  }

  ///获取所有通道的云服务状态对象
  List<DeviceCloudService> _parseChannelCloudServer(String deviceId,
      String? vidEnableChannelsString, String? vidExpireChannelsString) {
    List<DeviceCloudService> channelCloudList = [];

    List<String> channels = [];
    if (vidEnableChannelsString != null) {
      channels = vidEnableChannelsString.split('_');
    }
    if (channels.isEmpty) {
      return channelCloudList;
    }
    List<String> channelExpire = [];
    if (vidExpireChannelsString != null) {
      channelExpire = vidExpireChannelsString.split('_');
    }

    for (int i = 0; i < channels.length; i++) {
      DeviceCloudService deviceCloudService =
          DeviceCloudService(deviceId: deviceId);
      deviceCloudService.channel = i;
      bool vidEnable = channels[i] == 'true';
      if (vidEnable == false) {
        //未购买
        deviceCloudService.cloudServerStatus = CloudServerStatus.notPurchased;
      } else {
        //已购买，判断是否过期
        if (channelExpire.isNotEmpty) {
          int? expire = int.tryParse(channelExpire[i]);
          if (expire == null) {
            //过期解析为空 正常
            deviceCloudService.cloudServerStatus = CloudServerStatus.active;
          } else {
            DateTime expirationTime =
                DateTime.fromMillisecondsSinceEpoch(expire * 1000);
            deviceCloudService.cloudExpiredTime =
                expirationTime.millisecondsSinceEpoch;
            bool after = expirationTime.isAfter(DateTime.now());
            if (after) {
              //没有过期
              deviceCloudService.cloudServerStatus = CloudServerStatus.active;
            } else {
              //过期
              deviceCloudService.cloudServerStatus = CloudServerStatus.expired;
            }
          }
        } else {
          //过期列表为空 默认正常
          deviceCloudService.cloudServerStatus = CloudServerStatus.active;
        }
      }
      channelCloudList.add(deviceCloudService);
    }
    return channelCloudList;
  }

  ///实时请求云服务能力，SDK接口，无其他额外操作
  Future<List<Map<String, dynamic>>> _queryCloudStatus(
      List<String> deviceIdList) async {
    ///当前包名需要支持云服务，不然默认返回不支持
    final package = await PackageInfo.fromPlatform();
    String bundleId = package.packageName;

    List<XAPiModelDevsGetCapAbilitySn> snList = deviceIdList
        .map((e) => XAPiModelDevsGetCapAbilitySn(sn: e, tp: 0))
        .toList();

    XAPiModelDevsGetCapAbility apiModel = XAPiModelDevsGetCapAbility(
      ver: 2,
      appType: bundleId,
      caps: ['xmc.service'],
      snList: snList,
    );

    try {
      final Map response =
          await JFApi.xcCloudService.xcDevsGetCapAbility(apiModel);
      if (response['ret'] == 200 && response['capsList'] is List) {
        List<dynamic> capsList = response['capsList'];
        return capsList.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      //
    }
    return [];
  }

  ///获取云服务状态颜色
  Color getCloudIconColor(CloudServerStatus? cloudStatus) {
    if (cloudStatus == null) {
      return Colors.transparent;
    }
    if (cloudStatus == CloudServerStatus.active) {
      return const Color(0xFF12B5B0);
    }
    if (cloudStatus == CloudServerStatus.notPurchased) {
      return const Color(0xFFF27900);
    }
    if (cloudStatus == CloudServerStatus.expired) {
      return const Color(0xFFEF5756);
    }
    return const Color(0xFFC2C2C2);
  }

  ///获取云服务状态颜色
  Color getFlowIconColor(CloudFlowStatus? status) {
    if (status == null) {
      return Colors.transparent;
    }
    if (status == CloudFlowStatus.active) {
      return const Color(0xFF12B5B0);
    }
    if (status == CloudFlowStatus.notPurchased) {
      return const Color(0xFFF27900);
    }
    if (status == CloudFlowStatus.expired) {
      return const Color(0xFFEF5756);
    }
    return const Color(0xFFC2C2C2);
  }
}
