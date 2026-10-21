import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_model.dart';

///门锁用户模型（服务器 getAllPwd 返回）
///id/type/auth 基础字段 + userNickName 昵称 + validType/validTime 有效期。
///相比锁端 [DookLockOpenTypeUser]（仅 id/type/auth），多出昵称与有效期元数据，
///且与 saveDoorLockUser 上报数据源一致（均走服务器）。
class DoorUser {
  ///用户ID
  int id;

  ///用户类型（对应 JvssOperateType.value，password=0）
  int type;

  ///用户权限 0：管理员 1：普通成员
  int auth;

  ///设备序列号
  String? sn;

  ///显示的昵称
  String? userNickName;

  ///创建人
  String? creatorName;

  ///头像 URL
  String? userHeadPortrait;

  ///成员ID
  int? memberId;

  ///时效类型，00-永久，02-限时，03-循环
  String? validType;

  ///时效性（限时/循环的具体时间描述）
  String? validTime;

  DoorUser({
    required this.id,
    required this.type,
    required this.auth,
    this.sn,
    this.userNickName,
    this.creatorName,
    this.userHeadPortrait,
    this.memberId,
    this.validType,
    this.validTime,
  });

  factory DoorUser.fromJson(Map<String, dynamic> json) {
    return DoorUser(
      sn: json['Sn']?.toString(),
      id: _parseInt(json['Id']),
      type: _parseInt(json['Type']),
      auth: _parseInt(json['Auth']),
      userNickName: json['userNickName']?.toString(),
      creatorName: json['creatorName']?.toString(),
      userHeadPortrait: json['userHeadPortrait']?.toString(),
      memberId: json['memberId'] == null ? null : _parseInt(json['memberId']),
      validType: json['validType']?.toString(),
      validTime: json['validTime']?.toString(),
    );
  }

  ///从锁端 netip 模型转换
  factory DoorUser.fromOpenTypeUser(DookLockOpenTypeUser model) {
    return DoorUser(
      id: model.id,
      type: model.type,
      auth: model.auth,
    );
  }

  ///从锁端蓝牙模型转换（BLE getDoorOpenType 返回 DoorLockUnlockModel）
  ///memberId 0x02=管理员→auth 0，其余→普通成员 auth 1；hardwareType 转几维类型
  factory DoorUser.fromLockModel(DoorLockUnlockModel model) {
    return DoorUser(
      id: model.hardwareId,
      type: model.hardwareType.toJvssType(),
      auth: model.memberId == 2 ? 0 : 1,
      memberId: model.belongMemberId,
    );
  }

  ///服务器返回的 Id/Type/Auth 可能是 int 或 String，统一健壮解析为 int
  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  ///是否管理员
  bool get isAdmin => auth == 0;

  ///列表主标题：优先昵称，无昵称回退"用户 ID: x"
  String get displayTitle {
    final name = userNickName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    return '用户 ID: $id';
  }

  ///有效期展示文案（00永久/02限时/03循环）
  String get validText {
    switch (validType) {
      case '02':
        return '限时';
      case '03':
        return '循环';
      case '00':
      default:
        return '永久';
    }
  }

  ///上报服务器的序列化（取 saveDoorLockUser 必需字段）
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Id': id,
      'Type': type,
      'Auth': auth,
      if (sn != null && sn!.isNotEmpty) 'Sn': sn,
    };
  }
}
