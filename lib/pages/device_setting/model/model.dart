import 'package:xcloudsdk_flutter/utils/extensions.dart';

import '../../cloud/device_cloud_service_manager.dart';
import '../../cloud/model/device_cloud.dart';

///
/// {
// 			"css":	"aaaaaaaa204122295a",
// 			"cts":	"aaaaaaaa41412365b1",
// 			"dss":	"aaaaaaaa104122295a",
// 			"ip":	"0.0.0.0",
// 			"type":	"7",
// 			"mAccount":	true,
// 			"uuid":	"326955eab981d96e",
// 			"p2P":	"aaaaaaaa-84122295a",
// 			"numberOfSharedAccounts":	2,
// 			"password":	"",
// 			"rps":	"aaaaaaaa-14122295a",
// 			"port":	"34567",
// 			"createTime":	1667913633,
// 			"tps":	"aaaaaaaa-2412365b1",
// 			"pms":	"aaaaaaaa-4412365b1",
// 			"nickname":	"3*国科微摇头机",
// 			"productPicture":	"/7",
// 			"supportToken":	false,
// 			"id":	"636a57a160b2a3084c7929e1",
// 			"username":	"admin"
// 		}

class Device {
  late final String uuid;
  String? nickname;
  String? userName;
  String? type;

  ///额外添加
  int state = 0;

  ///设备密码
  String password = '';

  ///设备pid
  String pid = '';

  ///设备类型，可能不准确
  int deviceType = 0;

  ///是否支持token，设备列表数据字段
  bool supportToken = false;

  ///设备token 很关键
  String adminToken = '';

  /// pwd token
  String pwdToken = '';

  ///是否来自分享
  bool fromShare = false;

  ///设备属性列表，可以上层设置Device列表时携带
  ///可空，当没有设置过时为空。
  ///针对使用RS设备列表的情况，在获取设备相关能力时（比如是否是AOV设备），会请求服务器尝试更新
  ///[DevicePropertyManager.instance.isAOVAsync]
  List<Map<String, dynamic>>? propList;

  ///整个云服务状态
  DeviceCloudService? cloudService({int? channel}) =>
      DeviceCloudServiceManager.instance
          .getCloudService(deviceId: uuid, channel: channel);

  ///获取云服务状态
  CloudServerStatus? cloudServerStatus({int? channel}) =>
      DeviceCloudServiceManager.instance
          .getCloudService(deviceId: uuid, channel: channel)
          ?.cloudServerStatus;

  ///主账号id（分享的设备）
  String? get masterId {
    return null;
  }

  Device({
    required this.uuid,
    this.nickname,
    this.userName,
    this.type,
    this.state = 0,
    this.password = '',
    this.pid = '',
    this.deviceType = 0,
    this.supportToken = false,
    this.adminToken = '',
    this.fromShare = false,
    this.propList,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    Device device = Device(uuid: json['uuid']);
    device.nickname = json['nickname'] ?? '';
    device.pid = json['pid'] ?? '';
    int parseDeviceType(dynamic type) {
      if (type is int) {
        return type;
      }
      return int.tryParse(type) ?? 0;
    }

    device.deviceType = parseDeviceType(json['type'] ?? '');
    String parseAdminToken(Map<String, dynamic> json) {
      dynamic token = json['AdminToken'] ?? json['deviceToken'];
      if (token is String) {
        return token;
      }
      if (token is Map) {
        return token['AdminToken'] ?? '';
      }
      return '';
    }

    String parsePwdToken(Map<String, dynamic> json) {
      dynamic token = json['deviceToken'];
      if (token is String) {
        return token;
      }
      if (token is Map) {
        return token['PWDToken'] ?? '';
      }
      return '';
    }

    device.adminToken = parseAdminToken(json);
    device.pwdToken = parsePwdToken(json);
    device.supportToken =
        device.adminToken.isNotEmpty ? true : (json['supportToken'] ?? false);
    device.userName = json['username'] ?? 'admin';
    device.password = json['password'] ?? '';

    return device;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fromShare'] = fromShare;
    data['uuid'] = uuid;
    data['nickname'] = nickname;
    data['pid'] = pid;
    data['type'] = '$deviceType';
    data['AdminToken'] = adminToken;
    data['supportToken'] = adminToken.isNotEmpty ? true : (supportToken);
    data['PWDToken'] = pwdToken;
    data['username'] = userName;
    data['password'] = password;
    return data;
  }

  ///是否有权限，[SharedDevice] 重载此方法判断是否有权限
  ///[permission] 为 [DevicePermission] 枚举类型
  bool hasPermission({required DevicePermission permission}) {
    return true;
  }
}

class Devices {
  List<Device> mine = [];
  List<SharedDevice> share = [];

  Devices({this.mine = const <Device>[], this.share = const <SharedDevice>[]});

  Devices.fromJson(Map<String, dynamic> json) {
    if (json['mine'] != null && json['mine'].isNotEmpty) {
      mine = json['mine'].map<Device>((e) => Device.fromJson(e)).toList();
    }
    if (json['share'] != null && json['share'].isNotEmpty) {
      share = json['share']
          .map<SharedDevice>((e) => SharedDevice.fromJson(e))
          .toList();
    }
  }
}

///分享的设备，有特殊字段
class SharedDevice extends Device {
  @override
  bool get fromShare => true;

  ///分享ID
  String shareId = '';

  ///是否接受了
  int ret = 0;

  ///分享的权限
  List<SharedDevicePermission> permissions = [];

  ///分享人昵称
  String shareNickname = '';

  ///分享时间
  int shareTime = 0;

  ///接受时间
  int acceptTime = 0;

  ///设备过期时间
  int expireTime = 0;

  ///分享设备信息,加密后的信息,同意时解密同步给SDK
  String powers = '';

  ///分享的设备的主userID，只有被分享设备才有：即被fromShare == true时
  String deviceOwnerId = '';

  @override
  String? get masterId => deviceOwnerId;

  SharedDevice({
    required super.uuid,
    super.nickname = '',
    super.pid = '',
    super.deviceType = 0,
    super.state = -1,
    super.fromShare = true,
    super.supportToken = false,
    super.adminToken = '',
    super.userName = 'admin',
    super.password = '',
    super.propList,
    this.shareId = '',
    this.ret = 0,
    this.permissions = const <SharedDevicePermission>[],
    this.shareNickname = '',
    this.shareTime = 0,
    this.acceptTime = 0,
    this.expireTime = 0,
    this.powers = '',
    this.deviceOwnerId = '',
  });

  factory SharedDevice.fromJson(Map<String, dynamic> json) {
    SharedDevice sharedDevice = SharedDevice(uuid: json['uuid']);
    sharedDevice.nickname = json['nickname'] ?? '';
    sharedDevice.pid = json['pid'] ?? '';
    sharedDevice.deviceType = int.tryParse(json['type'] ?? '') ?? 0;
    sharedDevice.supportToken = json['supportToken'] ?? false;
    String parseAdminToken(Map<String, dynamic> json) {
      dynamic token = json['AdminToken'] ?? json['deviceToken'];
      if (token is String) {
        return token;
      }
      if (token is Map) {
        return token['AdminToken'] ?? '';
      }
      return '';
      // dynamic token = json['deviceToken'];
      // if (token is String) {
      //   return token;
      // }
      // if (token is Map) {
      //   return token['AdminToken'] ?? '';
      // }
      // return '';
    }

    String parsePwdToken(Map<String, dynamic> json) {
      dynamic token = json['deviceToken'];
      if (token is String) {
        return token;
      }
      if (token is Map) {
        return token['PWDToken'] ?? '';
      }
      return '';
    }

    sharedDevice.adminToken = parseAdminToken(json);
    sharedDevice.pwdToken = parsePwdToken(json);
    sharedDevice.userName = json['username'] ?? 'admin';
    sharedDevice.password = json['password'] ?? '';

    sharedDevice.shareId = json['id'] ?? '';
    sharedDevice.ret = json['ret'] ?? 0;
    sharedDevice.shareNickname = json['account'] ?? '';
    sharedDevice.shareTime = json['shareTime'] ?? 0;
    sharedDevice.acceptTime = json['acceptTime'] ?? 0;
    sharedDevice.expireTime = json['expireTime'] ?? 0;
    sharedDevice.powers = json['powers'] ?? '';
    sharedDevice.deviceOwnerId = json['deviceOwnerId'] ?? '';
    sharedDevice.permissions = json['permissions'] == null
        ? []
        : json['permissions']
            .map<SharedDevicePermission>(
                (e) => SharedDevicePermission.fromJson(e))
            .toList();
    return sharedDevice;
  }

  @override
  bool hasPermission({required DevicePermission permission}) {
    SharedDevicePermission? devicePermission =
        permissions.firstWhereOrNull((e) => e.permission == permission.name);
    if (devicePermission == null) {
      return false;
    }
    return devicePermission.enable;
  }
}

///分享设备的权限
class SharedDevicePermission {
  String permission = '';
  bool enable = false;

  SharedDevicePermission.fromJson(Map<String, dynamic> json) {
    permission = json['label'] ?? '';
    enable = json['enabled'] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {'label': permission, 'enabled': enable};
  }
}

enum DevicePermission {
  ///支持报警推送
  DP_AlarmPush,

  ///云服务
  DP_CloudServer,

  ///删除报警信息
  DP_DeleteAlarmInfo,

  ///删除云视频
  DP_DeleteCloudVideo,

  ///对讲
  DP_Intercom,

  ///卡回放
  DP_LocalStorage,

  ///修改设备配置
  DP_ModifyConfig,

  ///修改设备密码
  DP_ModifyPwd,

  ///云台
  DP_PTZ,

  ///视频对讲
  DP_VideoCall,

  ///查看云视频
  DP_ViewCloudVideo,

  // 修改云服务配置
  DP_CLoudConfig
}
