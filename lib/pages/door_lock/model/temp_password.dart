import 'package:fcloudsdk/utils/bit_util.dart';

class TempPassword {
  ///服务器记录ID（deleteTmpPassword 用）
  final String id;

  ///设备序列号
  final String deviceSn;

  ///显示的昵称（详情页改昵称后直接改写，避免列表页重新拉取）
  String name;

  ///密码串
  final String password;

  ///生效时间（yyyy-MM-dd HH:mm）
  final String startTime;

  ///失效时间（yyyy-MM-dd HH:mm）
  final String endTime;

  ///生效时间戳（秒）
  final int startTimeStamp;

  ///失效时间戳（秒）
  final int endTimeStamp;

  ///星期位图字符串（'week 0x..'）
  final String rpt;

  ///用户类型：管理员(0)/普通用户(1)/临时用户(2)/胁迫用户(3)
  final int uType;

  ///密码状态：0已同步、1新增、2修改、3已删除（未同步）
  final int status;

  ///创建人
  final String? creatorName;

  ///成员ID
  final int? memberId;

  TempPassword({
    required this.id,
    required this.deviceSn,
    required this.name,
    required this.password,
    required this.startTime,
    required this.endTime,
    this.startTimeStamp = 0,
    this.endTimeStamp = 0,
    this.rpt = '',
    this.uType = 1,
    this.status = 0,
    this.creatorName,
    this.memberId,
  });

  factory TempPassword.fromJson(Map<String, dynamic> json) {
    return TempPassword(
      id: _parseString(json['id']),
      deviceSn: _parseString(json['deviceSn']),
      name: _parseString(json['name']),
      password: _parseString(json['password']),
      startTime: _parseString(json['startTime']),
      endTime: _parseString(json['endTime']),
      startTimeStamp: _parseInt(json['startTimeStamp']),
      endTimeStamp: _parseInt(json['endTimeStamp']),
      rpt: _parseString(json['rpt']),
      uType: _parseInt(json['uType']),
      status: _parseInt(json['status']),
      creatorName: json['creatorName']?.toString(),
      memberId: json['memberId'] == null ? null : _parseInt(json['memberId']),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  static String _parseString(dynamic v) => v?.toString() ?? '';

  ///列表主标题：优先昵称，无昵称回退“临时密码”
  String get displayTitle {
    final n = name.trim();
    if (n.isNotEmpty) return n;
    return '临时密码';
  }

  ///有效期文案（起 ~ 止）
  String get validTimeText {
    if (startTime.isEmpty && endTime.isEmpty) return '';
    return '$startTime ~ $endTime';
  }

  ///同步状态文案（0已同步/1新增未同步/2修改未同步/3已删除未同步）
  String get statusDescription {
    switch (status) {
      case 0:
        return '已同步';
      case 1:
      case 2:
        return '未同步';
      case 3:
        return '未同步(已删除)';
      default:
        return '';
    }
  }

  ///用户类型文案（0管理员/1普通用户/3胁迫用户，临时用户(2)不展示）
  String get uTypeDescription {
    switch (uType) {
      case 0:
        return '管理员';
      case 1:
        return '普通用户';
      case 3:
        return '胁迫用户';
      default:
        return '';
    }
  }

  ///是否已删除（未同步），已删除项不可再操作
  bool get isDeleted => status == 3;

  ///重复星期文案（解析 rpt 位图：'week 0x..' → 每天/周一、周三..）
  ///
  ///解析失败或无 rpt 时返回空串，列表/详情按需隐藏。
  String get weeksText {
    try {
      if (!rpt.contains('0x')) return '';
      final hexPart = rpt.split('0x')[1];
      final bytes = hexToBytes(hexPart);
      if (bytes.isEmpty) return '';
      final weeks = byteToWeeks(bytes.first);
      if (weeks.isEmpty) return '';
      if (weeks.length >= 7) return '每天';
      const names = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      final sorted = [...weeks]..sort();
      return sorted
          .where((w) => w >= 0 && w < 7)
          .map((w) => names[w])
          .join('、');
    } catch (_) {
      return '';
    }
  }
}
