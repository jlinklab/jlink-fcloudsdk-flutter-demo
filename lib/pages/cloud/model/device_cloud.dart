///云服务购买状态
enum CloudServerStatus {
  ///不支持购买
  notSupported,

  /// 未购买
  notPurchased,

  /// 已购买，正常使用中
  active,

  /// 已购买，套餐已过期
  expired,
}

///4G流量购买状态
enum CloudFlowStatus {
  ///不支持购买
  notSupported,

  /// 未购买
  notPurchased,

  /// 已购买，正常使用中
  active,

  /// 已购买，套餐已过期
  expired,
}

///设备的云服务相关
///4G流量，云存储 状态
class DeviceCloudService {
  ///设备序列号
  final String deviceId;

  ///pid
  String? pid;

  ///是否在黑名单
  bool allowed = true;

  ///厂商
  String? oemId;

  ///通道
  ///当channel不为 null 时，代表是某个通道的云服务状态
  ///当 channel为null时，代表这个设备的云服务状态
  int? channel;

  ///云存储状态
  CloudServerStatus cloudServerStatus = CloudServerStatus.notSupported;

  ///4G流量状态
  CloudFlowStatus cloudFlowStatus = CloudFlowStatus.notSupported;

  ///云存过期时间
  ///不支持和未购买时为 0，其他情况为服务器返回时间
  int cloudExpiredTime = 0;

  ///流量过期时间
  ///不支持和未购买时为 0，其他情况为服务器返回时间
  int flowExpiredTime = 0;

  ///4G流量总值
  double flowFullSpace = 0.0;

  ///4G流量已使用值
  double flowUsedSpace = 0.0;

  ///4G流量卡1
  String iccid1 = '';

  ///4G流量卡2
  String iccid2 = '';

  ///4G流量卡1 状态 11 12 13 注销状态
  int provider1 = 0;

  ///4G流量卡2 状态 11 12 13 注销状态
  int provider2 = 0;

  ///[deviceId]设备的所有通道云服务状态列表
  ///缓存时，时按照设备进行缓存
  List<DeviceCloudService> channelCloud = [];

  String? lastWanIp;

  DeviceCloudService({
    required this.deviceId,
    this.pid,
    this.allowed = true,
    this.oemId,
    this.channel,
    this.cloudServerStatus = CloudServerStatus.notSupported,
    this.cloudFlowStatus = CloudFlowStatus.notSupported,
    this.cloudExpiredTime = 0,
    this.flowExpiredTime = 0,
    this.flowFullSpace = 0.0,
    this.flowUsedSpace = 0.0,
    this.iccid1 = '',
    this.iccid2 = '',
    this.provider1 = 0,
    this.provider2 = 0,
    this.channelCloud = const <DeviceCloudService>[],
    this.lastWanIp,
  });

  factory DeviceCloudService.fromJson(Map<String, dynamic> json) {
    return DeviceCloudService(
        deviceId: json['deviceId'],
        pid: json['pid'],
        allowed: json['allowed'],
        oemId: json['oemId'],
        channel: json['channel'],
        cloudServerStatus: CloudServerStatus.values[json['cloudServerStatus']],
        cloudFlowStatus: CloudFlowStatus.values[json['cloudFlowStatus']],
        cloudExpiredTime: json['cloudExpiredTime'],
        flowExpiredTime: json['flowExpiredTime'],
        flowFullSpace: json['flowFullSpace'] ?? 0,
        flowUsedSpace: json['flowUsedSpace'] ?? 0,
        iccid1: json['iccid1'] ?? '',
        iccid2: json['iccid2'] ?? '',
        provider1: json['provider1'] ?? 0,
        provider2: json['provider2'] ?? 0,
        channelCloud: json['channelCloud']
            .map<DeviceCloudService>((e) => DeviceCloudService.fromJson(e))
            .toList(),
        lastWanIp: json['lastWanIp'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'pid': pid,
      'allowed': allowed,
      'oemId': oemId,
      'channel': channel,
      'cloudServerStatus': cloudServerStatus.index,
      'cloudFlowStatus': cloudFlowStatus.index,
      'cloudExpiredTime': cloudExpiredTime,
      'flowExpiredTime': flowExpiredTime,
      'flowFullSpace': flowFullSpace,
      'flowUsedSpace': flowUsedSpace,
      'iccid1': iccid1,
      'iccid2': iccid2,
      'provider1': provider1,
      'provider2': provider2,
      'channelCloud': channelCloud.map((e) => e.toJson()).toList(),
      'lastWanIp': lastWanIp
    };
  }
}
