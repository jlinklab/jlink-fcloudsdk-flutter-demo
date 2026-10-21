import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_date.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_model.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:intl/intl.dart';

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

  ///时效性（限时/循环的具体时间描述，BLE 16进制格式）
  String? validTime;

  ///解析后的时效模型（由 validType/validTime 解析，添加时由时效选择页写入）
  BleLimitAndLoopModel? parseValidTime;

  ///时效类型（枚举形态，与 [validType] 同步）
  DoorLockTimelinessType? timelinessType;

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
  }) {
    if (validType != null && validType!.isNotEmpty) {
      var bytes = hexToBytes(validType!);
      timelinessType =
          bytes.isNotEmpty ? DoorLockTimelinessType.from(bytes.first) : null;
    } else {
      timelinessType = DoorLockTimelinessType.permanent;
    }

    if (validTime != null && validTime!.isNotEmpty && timelinessType != null) {
      parseValidTime =
          parseTimelinessBleFormat(type: timelinessType!, format: validTime!);
    }
  }

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

  ///从锁端蓝牙模型转换（含时效）
  factory DoorUser.fromLockModelWithValid(DoorLockUnlockModel model) {
    return DoorUser(
      id: model.hardwareId,
      type: model.hardwareType.toJvssType(),
      auth: model.memberId == 2 ? 0 : 1,
      memberId: model.belongMemberId,
      validType: bytesToHex([model.timelinessType.value]),
      validTime: model.timeliness,
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
    return DoorUser.fromLockModelWithValid(model);
  }

  ///服务器返回的 Id/Type/Auth 可能是 int 或 String，统一健壮解析为 int
  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  ///是否管理员
  bool get isAdmin => auth == 0;

  ///列表主标题：优先昵称，无昵称回退"用户x"；管理员追加后缀
  String get displayTitle {
    final name = userNickName?.trim() ?? '';
    final base = name.isNotEmpty ? name : '用户$id';
    return isAdmin ? '$base（管理员）' : base;
  }

  ///列表副标题：有效期具体文案
  ///
  ///- 限时：`yyyy-MM-dd HH:mm ~ yyyy-MM-dd HH:mm 限时`
  ///- 循环：`yyyy-MM-dd HH:mm ~ yyyy-MM-dd HH:mm 循环`（起止日期 + 每日时段）
  ///- 永久（含时效缺失/解析失败）：`永久`
  String get displayTimeAndVaidType {
    final parse = parseValidTime;
    final start = parse?.startTime;
    final end = parse?.endTime;
    if (start == null || end == null) return '永久';

    if (timelinessType == DoorLockTimelinessType.limit) {
      final fmt = DateFormat('yyyy-MM-dd HH:mm');
      return '${fmt.format(start)} ~ ${fmt.format(end)} 限时';
    }
    if (timelinessType == DoorLockTimelinessType.loop) {
      final dayFmt = DateFormat('yyyy-MM-dd');
      final sMin = parse?.startMin;
      final eMin = parse?.endMin;
      if (sMin != null && eMin != null) {
        String two(int v) => v.toString().padLeft(2, '0');
        final sTime = '${two(sMin ~/ 60)}:${two(sMin % 60)}';
        final eTime = '${two(eMin ~/ 60)}:${two(eMin % 60)}';
        return '${dayFmt.format(start)} $sTime ~ '
            '${dayFmt.format(end)} $eTime 循环';
      }
      return '${dayFmt.format(start)} ~ ${dayFmt.format(end)} 循环';
    }
    return '永久';
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

  // ==================== 时效数据（添加流程使用） ====================

  ///复制并局部替换时效模型
  BleLimitAndLoopModel copyParseValidTime({
    DateTime? startTime,
    DateTime? endTime,
    List<int>? weeks,
    int? startMin,
    int? endMin,
  }) {
    return BleLimitAndLoopModel(
      startTime ?? parseValidTime?.startTime,
      endTime ?? parseValidTime?.endTime,
      weeks ?? parseValidTime?.weeks,
      startMin ?? parseValidTime?.startMin,
      endMin ?? parseValidTime?.endMin,
    );
  }

  ///由时效枚举+解析模型反算 validType/validTime（上报服务器/下发锁端前的准备）
  void getVaildTypeAndTime() {
    if (timelinessType == null || parseValidTime == null) {
      return;
    }
    validType = bytesToHex([timelinessType!.value]);
    validTime = getTimelinessBleFormat(
      type: timelinessType!,
      startTime: parseValidTime!.startTime,
      endTime: parseValidTime!.endTime,
      weeks: parseValidTime!.weeks,
      startMin: parseValidTime!.startMin,
      endMin: parseValidTime!.endMin,
    );
  }

  ///生效时间展示（限时精确到分，循环只到日）
  String? get beginTime {
    final first = parseValidTime?.startTime;
    final second = parseValidTime?.endTime;
    if (first == null || second == null) return null;
    if (timelinessType == DoorLockTimelinessType.limit) {
      return DateFormat('yyyy-MM-dd HH:mm').format(first);
    }
    return DateFormat('yyyy-MM-dd').format(first);
  }

  ///失效时间展示
  String? get endTime {
    final second = parseValidTime?.endTime;
    if (second == null) return null;
    if (timelinessType == DoorLockTimelinessType.limit) {
      return DateFormat('yyyy-MM-dd HH:mm').format(second);
    }
    return DateFormat('yyyy-MM-dd').format(second);
  }

  ///循环生效时刻（HH:mm）
  String? get startHour {
    final min = parseValidTime?.startMin;
    if (min == null) return null;
    return '${(min ~/ 60).toString().padLeft(2, '0')}:${(min % 60).toString().padLeft(2, '0')}';
  }

  ///循环失效时刻（HH:mm）
  String? get endHour {
    final min = parseValidTime?.endMin;
    if (min == null) return null;
    return '${(min ~/ 60).toString().padLeft(2, '0')}:${(min % 60).toString().padLeft(2, '0')}';
  }

  ///循环选中的星期展示（周日为 0）
  String? get displayVaildWeek {
    final weeks = parseValidTime?.weeks;
    if (weeks == null || weeks.isEmpty) return null;
    const names = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weeks.where((e) => e >= 0 && e <= 6).map((e) => names[e]).join('、');
  }

  ///上报服务器的序列化（取 saveDoorLockUser 必需字段）
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Id': id,
      'Type': type,
      'Auth': auth,
      if (sn != null && sn!.isNotEmpty) 'Sn': sn,
      if (userNickName != null && userNickName!.isNotEmpty)
        'userNickName': userNickName,
      if (validType != null && validType!.isNotEmpty) 'validType': validType,
      if (validTime != null && validTime!.isNotEmpty) 'validTime': validTime,
    };
  }
}
