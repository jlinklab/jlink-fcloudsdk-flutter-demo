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

  ///整个云服务状态
  DeviceCloudService? cloudService({int? channel}) =>
      DeviceCloudServiceManager.instance
          .getCloudService(deviceId: uuid, channel: channel);

  ///获取云服务状态
  CloudServerStatus? cloudServerStatus({int? channel}) =>
      DeviceCloudServiceManager.instance
          .getCloudService(deviceId: uuid, channel: channel)
          ?.cloudServerStatus;

  Device({
    required this.uuid,
    this.nickname,
    this.userName,
    this.type,
    this.state = 0,
    this.password = '',
  });

  factory Device.formJson(Map<String, dynamic> json) {
    return Device(
        uuid: json['uuid'],
        nickname: json['nickname'] ?? '',
        userName: json['userName'] ?? '',
        type: json['type'] ?? '',
        state: json['state'] ?? 0,
        password: json['password'] ?? '');

    // final uuid = json['uuid'];
    // if (json['nickname'] != null) {
    //   nickname = json['nickname'];
    // }
    // if (json['userName'] != null) {
    //   userName = json['userName'];
    // }
    // if (json['type'] != null) {
    //   type = json['type'];
    // }
    // if (json['state'] != null) {
    //   state = json['state'];
    // }
  }

  // Convert Follow object to JSON String
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['uuid'] = uuid;
    if (nickname != null) {
      map['nickname'] = nickname;
    }
    if (userName != null) {
      map['userName'] = userName;
    }
    if (type != null) {
      map['type'] = type;
    }
    map['state'] = state;
    map['password'] = password;
    return map;
  }

  Device copyWith(
      {required String uuid,
      String? nickname,
      String? userName,
      String? type,
      int? state,
      String? password}) {
    return Device(
        uuid: uuid,
        nickname: nickname ?? this.nickname,
        userName: userName ?? this.userName,
        type: type ?? this.type,
        state: state ?? this.state,
        password: password ?? this.password);
  }
}

class Devices {
  List<Device> mine = [];
  List<Device> share = [];

  Devices({this.mine = const <Device>[], this.share = const <Device>[]});

  Devices.fromJson(Map<String, dynamic> json) {
    if (json['mine'] != null && json['mine'].isNotEmpty) {
      mine = json['mine'].map<Device>((e) => Device.formJson(e)).toList();
    }
    if (json['share'] != null && json['share'].isNotEmpty) {
      share = json['share'].map<Device>((e) => Device.formJson(e)).toList();
    }
  }
}
