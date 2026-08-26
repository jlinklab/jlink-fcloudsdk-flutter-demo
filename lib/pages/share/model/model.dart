import 'package:fcloudsdk_example/pages/device_setting/model/model.dart';

class SharedUser {
  String? id;
  String? account;

  SharedUser({this.id, this.account});

  SharedUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    account = json['account'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['account'] = account;
    return data;
  }
}

class DevicePermissionUI {
  final String nameKey;
  final DevicePermission permission;
  bool checked = false;

  DevicePermissionUI(
      {required this.nameKey,
      required this.permission,
      this.checked = false});
}

enum DeviceShareType {
  qrCode, //二维码分享
  account, //账号分享
  password // 口令分享
}
