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
  final String name;
  final String path;
  final String type;
  bool checked = false;

  DevicePermissionUI(
      {required this.name,
      required this.path,
      required this.type,
      this.checked = false});
}

enum DeviceShareType {
  qrCode, //二维码分享
  account, //账号分享
  password // 口令分享
}
