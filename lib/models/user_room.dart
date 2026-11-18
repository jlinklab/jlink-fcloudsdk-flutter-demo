///兼容服务端 isDefault 等字段既可能下发 bool 也可能下发 0/1 或 '0'/'1'
bool? _readBool(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  return value.toString() == '1' || value.toString() == 'true';
}

class UserRoomResponse {
  int total = 0;
  List<UserRoom> rooms = [];

  UserRoomResponse.fromJson(Map<String, dynamic> json) {
    total = json['total'] ?? 0;
    if (json['data'] != null) {
      rooms = (json['data'] as List)
          .map<UserRoom>((e) => UserRoom.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }
}

///房间
class UserRoom {
  String? id;
  String? roomName;
  String? userGroupId;
  bool? isDefault;
  bool? isSelected;
  bool? isRecommend;
  int? deviceCount;

  UserRoom({
    this.id,
    this.roomName,
    this.userGroupId,
    this.isDefault,
    this.isSelected,
    this.isRecommend,
    this.deviceCount,
  });

  UserRoom.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roomName = json['roomName'];
    userGroupId = json['userGroupId'];
    isDefault = _readBool(json['isDefault']);
    isSelected = _readBool(json['isSelected']);
    isRecommend = _readBool(json['isRecommend']);
    deviceCount = json['deviceCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['roomName'] = roomName;
    data['userGroupId'] = userGroupId;
    data['isDefault'] = isDefault;
    data['isSelected'] = isSelected;
    data['isRecommend'] = isRecommend;
    data['deviceCount'] = deviceCount;
    return data;
  }
}
