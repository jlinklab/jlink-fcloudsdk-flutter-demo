import 'package:fcloudsdk/ble_by_sdk/ble_device.dart';
import 'package:fcloudsdk/door_lock/door_lock_ble_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_key_value.dart';
import 'package:fcloudsdk/door_lock/door_lock_shadow.dart';
import 'package:fcloudsdk/utils/extensions.dart';
import 'package:fcloudsdk_example/pages/door_lock/repository/door_lock_local.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';

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

  /// 休眠状态 0 未知 1 唤醒 2 睡眠 3 不能被唤醒的休眠 4正在准备休眠
  DeviceSleepState? sleepState;

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

  ///设备能力标识列表（如 bleLockPair / wifiFeeder / sleepState），随设备列表 JSON 的 props 字段同步下发
  ///区别于 [propList]：props 是字符串数组、拉列表即有；propList 是按 pid 异步拉取的属性详情
  List<String>? props;

  String? parentPid;

  String? localUiKey;

  ///门锁指令状态
  DoolockCmdStatus doolockCmdStatus = DoolockCmdStatus.offline;

  ///锁板能力集集合
  DoorFunction? doorFunction;

  ///锁板能力集(EB)
  DoorLockBleAbility? doorLockBleAbility;

  ///锁板额外产品信息
  DoorLockExInfo? doorLockExInfo;

  ///管理员系统能力集
  DoorManagerAbility? doorManagerAbility;

  ///用户系统能力
  DoorManagerAbility? doorUserAbility;

  ///锁板用户密码长度区间
  DoorLockPwdLengthRange? doorLockPwdLengthRange;

  ///控制门锁透传动作、版本对应关系
  List<UserManagerActionVersion>? doorLockActionVerList;

  ///蓝牙是否在线
  bool blueOnline = false;

  ///蓝牙uuid（iOS外设peripheralIdentifier）
  String? blueUUid;

  ///支持锁板串口升级能力
  bool? opTrans;

  ///锁板额外pid
  String? qsPid;

  ///导向版本，无此字段时默认v1.0， v1.2版本需要引导添加管理员 v9999不使用该功能
  String? navVersion;

  /// 支持远程人脸录入
  bool? supportRtFace;

  ///旧版锁能力集
  Dlctrl? dlctrl;

  int? memberId;

  ///锁开合状态 （true 表示锁闭合，false 表示锁打开）
  bool? lockState;

  ///锁反锁状态 （true 表示反锁，false 表示未反锁）
  bool? reverseLockState;

  ///密钥同步状态
  bool keySyncState = false;

  ///基准年同步状态
  bool yearSyncState = false;

  ///电量
  int? level;

  ///蓝牙搜索包
  BleSearchDeviceBySDK? searchResult;

  String? devMac;

  String? peripheralIdentifier;

  ///整个云服务状态
  DeviceCloudService? cloudService({int? channel}) =>
      DeviceCloudServiceManager.instance
          .getCloudService(deviceId: uuid, channel: channel);

  ///获取云服务状态
  CloudServerStatus? cloudServerStatus({int? channel}) =>
      DeviceCloudServiceManager.instance
          .getCloudService(deviceId: uuid, channel: channel)
          ?.cloudServerStatus;

  ///门锁是否配网
  bool get doorlockIsConfigNet =>
      DoorLockLocalCache.doorlockIsConfigNet(deviceId: uuid);

  ///是否处于蓝牙netip可用状态
  bool get isBlueNetIpEnable =>
      DoorLockHelper.isSuppportBleNetip(deviceId: uuid) &&
      !doorlockIsConfigNet &&
      blueOnline;

  ///主账号id（分享的设备）
  String? get masterId {
    return null;
  }

  /// 是否为低功耗类型
  bool get isLowPowerType => (deviceType == 21 || deviceType == 285409282);

  ///是否管理员（非分享设备即为管理员）
  bool get isAdmin => !fromShare;

  ///是否分享设备
  bool get isSharedDevice => fromShare;

  ///激活前的sn
  String get oldDeviceId => DoorLockKeyValueLocal.oldDeviceNo(deviceId: uuid);

  Device({
    required this.uuid,
    this.nickname,
    this.userName,
    this.type,
    this.state = 0,
    this.sleepState,
    this.password = '',
    this.pid = '',
    this.deviceType = 0,
    this.supportToken = false,
    this.adminToken = '',
    this.fromShare = false,
    this.propList,
    this.parentPid,
    this.localUiKey,
    this.memberId,
    this.devMac,
    this.peripheralIdentifier,
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
    device.memberId = json['memberId'];
    device.devMac = json['devMac'];
    device.peripheralIdentifier = json['peripheralIdentifier'];
    device.props = json['props']?.cast<String>();
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
    data['memberId'] = memberId;
    data['devMac'] = devMac;
    data['peripheralIdentifier'] = peripheralIdentifier;
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
    super.sleepState,
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
    sharedDevice.props = json['props']?.cast<String>();
    return sharedDevice;
  }

  @override
  bool hasPermission({required DevicePermission permission}) {
    SharedDevicePermission? devicePermission = permissions.firstWhereOrNull(
        (e) => e.permission == permission.value || e.permission == permission.name);
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
  DP_AlarmPush('DP_AlarmPush'),

  ///云服务
  DP_CloudServer('DP_CloudServer'),

  ///删除报警信息
  DP_DeleteAlarmInfo('DP_DeleteAlarmInfo'),

  ///删除云视频
  DP_DeleteCloudVideo('DP_DeleteCloudVideo'),

  ///对讲
  DP_Intercom('DP_Intercom'),

  ///卡回放
  DP_LocalStorage('DP_LocalStorage'),

  ///修改设备配置
  DP_ModifyConfig('DP_ModifyConfig'),

  ///修改设备密码
  DP_ModifyPwd('DP_ModifyPwd'),

  ///云台
  DP_PTZ('DP_PTZ'),

  ///视频对讲
  DP_VideoCall('DP_VideoCall'),

  ///查看云视频
  DP_ViewCloudVideo('DP_ViewCloudVideo'),

  ///修改云服务配置
  DP_CLoudConfig('DP_CLoudConfig'),

  ///门锁密码权限
  DP_DoorLockPsw('doorLockPwd'),

  ///门锁指纹权限
  DP_DoorLockFingerprint('doorLockFingerPrint'),

  ///门锁掌纹权限
  DP_DoorLockPalmprint('userManagerFriction'),

  ///门锁人脸权限
  DP_DoorLockFace('face'),

  ///门锁电子钥匙权限
  DP_DoorLockEleKey('electronicKey_doorLock'),

  ///门锁卡权限
  DP_DoorLockCard('doorLockCard'),

  ///门锁指静脉权限
  DP_DoorLockFingerVein('userManagerFingerVein'),

  ///门锁掌静脉权限
  DP_DoorLockPalmVein('userManagerPalmVein'),

  ///门锁操作记录权限
  DP_DoorLockOperateRecord('operationLog'),

  ///门锁设置权限
  DP_Settings('settings');

  ///服务端下发的权限 key
  final String value;

  const DevicePermission(this.value);
}

/// 低功耗设备休眠状态
///
/// -3~3 直接对齐 SDK 接口 [JFApi.xcDevice.xcGetDeviceState] (stateType: 8) 返回值：
///   -3 没权限 / -2 不支持 / -1 离线 / 0 未知 / 1 唤醒 / 2 睡眠(可唤醒) / 3 不能被唤醒的休眠
/// 10/11/12 为 app 内部逻辑状态
///
enum DeviceSleepState {
  ///没权限
  noPermission(-3),

  ///不支持
  unSupport(-2),

  ///离线
  offline(-1),

  ///未知
  unknown(0),

  ///唤醒
  wakeUp(1),

  ///睡眠（浅休眠，可唤醒）
  lightSleep(2),

  ///不能被唤醒的休眠（深度休眠）
  deepSleep(3),

  /// 即将休眠
  preSleep(10), //【内部逻辑定义的状态】

  /// 即将唤醒
  waking(11), //【内部逻辑定义的状态】

  /// 休眠中
  sleeping(12); //【内部逻辑定义的状态】

  final int value;

  const DeviceSleepState(this.value);

  static DeviceSleepState from(int index) {
    if (index <= -1 || index > 4) {
      return DeviceSleepState.unknown;
    }
    return DeviceSleepState.values
        .firstWhere((element) => element.value == index);
  }
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
