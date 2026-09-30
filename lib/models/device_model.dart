import 'package:fcloudsdk/utils/extensions.dart';

import '../pages/cloud/device_cloud_service_manager.dart';
import '../pages/cloud/model/device_cloud.dart';

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

  String? parentPid;

  String? localUiKey;

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

  /// 是否为低功耗类型
  bool get isLowPowerType => (deviceType == 21 || deviceType == 285409282);

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
    this.parentPid,
    this.localUiKey,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    ///JVSS接口返回deviceNo，SDK接口返回uuid
    String uuid = json['deviceNo'] ?? json['uuid'] ?? '';
    Device device = Device(uuid: uuid);

    ///JVSS接口返回deviceName，SDK接口返回nickname
    device.nickname = json['deviceName'] ?? json['nickname'] ?? '';
    device.pid = json['pid'] ?? '';
    int parseDeviceType(dynamic type) {
      if (type is int) {
        return type;
      }
      return int.tryParse(type) ?? 0;
    }

    device.deviceType = parseDeviceType(json['type'] ?? '');
    String parseAdminToken(Map<String, dynamic> json) {
      ///JVSS接口返回adminToken（小写），SDK接口返回AdminToken
      dynamic token =
          json['adminToken'] ?? json['AdminToken'] ?? json['deviceToken'];
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

    ///JVSS接口返回devUserName/devPassWord，SDK接口返回username/password
    device.userName = json['devUserName'] ?? json['username'] ?? 'admin';
    device.password = json['devPassWord'] ?? json['password'] ?? '';
    device.parentPid = json['parentPid'];
    device.localUiKey = json['localUiKey'];
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
    data['parentPid'] = parentPid;
    data['localUiKey'] = localUiKey;
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
    ///JVSS接口返回data数组（所有设备混合），SDK接口返回mine/share两个数组
    if (json['data'] != null && json['data'].isNotEmpty) {
      ///JVSS接口：根据sharedVO字段判断是否为分享设备
      for (var item in json['data']) {
        var sharedVO = item['sharedVO'];
        if (sharedVO != null && sharedVO is Map && sharedVO.isNotEmpty) {
          ///分享设备：有sharedVO字段
          share.add(SharedDevice.fromJson(item));
        } else {
          ///我的设备：没有sharedVO字段
          mine.add(Device.fromJson(item));
        }
      }
    } else {
      ///SDK接口格式
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
    ///JVSS接口返回deviceNo，SDK接口返回uuid
    String uuid = json['deviceNo'] ?? json['uuid'] ?? '';
    SharedDevice sharedDevice = SharedDevice(uuid: uuid);

    ///JVSS接口返回deviceName，SDK接口返回nickname
    sharedDevice.nickname = json['deviceName'] ?? json['nickname'] ?? '';
    sharedDevice.pid = json['pid'] ?? '';
    sharedDevice.deviceType = int.tryParse(json['type'] ?? '') ?? 0;
    sharedDevice.supportToken = json['supportToken'] ?? false;
    String parseAdminToken(Map<String, dynamic> json) {
      ///JVSS接口返回adminToken（小写），SDK接口返回AdminToken
      dynamic token =
          json['adminToken'] ?? json['AdminToken'] ?? json['deviceToken'];
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

    sharedDevice.adminToken = parseAdminToken(json);
    sharedDevice.pwdToken = parsePwdToken(json);

    ///JVSS接口返回devUserName/devPassWord，SDK接口返回username/password
    sharedDevice.userName = json['devUserName'] ?? json['username'] ?? 'admin';
    sharedDevice.password = json['devPassWord'] ?? json['password'] ?? '';

    ///JVSS接口分享信息在sharedVO对象内，SDK接口在顶层
    var sharedVO = json['sharedVO'];
    if (sharedVO != null && sharedVO is Map && sharedVO.isNotEmpty) {
      ///JVSS接口格式：分享信息在sharedVO内
      sharedDevice.shareId = sharedVO['id'] ?? '';

      ///activateStatus 分享状态：1=未生效 2=已过期 3=正常
      ///映射到ret值：1=已接受 4=已过期/已拒绝 0=待接受
      int activateStatus = sharedVO['activateStatus'] ?? 0;
      if (activateStatus == 3) {
        sharedDevice.ret = 1; // 正常=已接受
      } else if (activateStatus == 2) {
        sharedDevice.ret = 4; // 已过期
      } else {
        sharedDevice.ret = 0; // 未生效=待接受
      }
      sharedDevice.shareNickname = sharedVO['nickName'] ?? '';
      sharedDevice.deviceOwnerId = sharedVO['creatorId'] ?? '';

      ///JVSS的privileges是字符串数组如["all"]，转换为powers字符串
      var privileges = sharedVO['privileges'];
      if (privileges != null && privileges is List) {
        sharedDevice.powers = privileges.join(',');
      }

      ///JVSS的privileges转换为SharedDevicePermission列表
      sharedDevice.permissions = [];
      if (privileges != null && privileges is List) {
        for (var priv in privileges) {
          if (priv is String) {
            sharedDevice.permissions.add(SharedDevicePermission(
              permission: priv,
              enable: true,
            ));
          }
        }
      }
    } else {
      ///SDK接口格式：分享信息在顶层
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
    }
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

  SharedDevicePermission({this.permission = '', this.enable = false});

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

/// 前端设备状态（NVR 通道状态）
enum FrontDeviceStatus {
  unKnown(-1, 'UnKnown'),
  none(0, 'None'),
  noConfig(1, 'NoConfig'),
  noLogin(2, 'NoLogin'),
  noConnect(3, 'NoConnect'),
  connected(4, 'Connected'),
  loginFailed(5, 'LoginFailed'),
  offline(6, 'Offline'),
  iplimit(7, 'IpLimit'),
  sleep(8, 'Sleep');

  final int value;
  final String des;

  const FrontDeviceStatus(this.value, this.des);

  /// 通过 value 获取枚举值
  static FrontDeviceStatus fromValue(int value) {
    return FrontDeviceStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FrontDeviceStatus.unKnown,
    );
  }

  /// 通过描述字符串获取枚举值
  static FrontDeviceStatus fromDes(String des) {
    return FrontDeviceStatus.values.firstWhere(
      (e) => e.des == des,
      orElse: () => FrontDeviceStatus.unKnown,
    );
  }

  /// 是否在线（可预览）
  bool get isOnline => this == FrontDeviceStatus.connected;
}
