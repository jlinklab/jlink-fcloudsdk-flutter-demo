import 'package:fcloudsdk/utils/bit_util.dart';

///离线密码模型（服务器 getAllPwd 的 unlockInfoList.data 返回）
///
///- 展示：name 昵称 + validType 时效类型 + isValid 生效状态
///- 删除：id（服务器删除用）+ hardwareId（锁端 deleteDoorOpenType 用）+ isAdmin
///
///与自定义密码 [DoorUser] 是不同数据源：DoorUser 走 doorLockUserInfoVOS，
///UnlockInfo 走 unlockInfoList.data，二者在密码列表页合并展示。
class UnlockInfo {
  ///服务器记录ID（deleteUnlockInfo 用）
  final String id;

  ///锁端硬件ID（deleteDoorOpenType 的 id 参数用）
  final String hardwareId;

  ///设备序列号
  final String deviceSn;

  ///显示的昵称（详情页改昵称后直接改写，避免列表页重新拉取）
  String name;

  ///密码串
  final String password;

  ///是否管理员
  final bool isAdmin;

  ///是否生效，0正常，1未生效，2已失效(过期)，3无效(被删除)
  final int isValid;

  ///时效类型（取原始值最后一位）：0永久，1单次，2限时，3循环，4清除
  final String validType;

  ///时效性描述（限时/循环的具体时间）
  final String validTime;

  ///创建人
  final String? creatorName;

  ///创建时间（秒级时间戳）
  final int createTime;

  ///是否已使用
  final int isUsed;

  ///加密方式
  final int encryption;

  ///开锁方式
  final String unlockMode;

  ///成员ID
  final int? memberId;

  UnlockInfo({
    required this.id,
    required this.hardwareId,
    required this.deviceSn,
    required this.name,
    required this.password,
    required this.isAdmin,
    required this.isValid,
    required this.validType,
    required this.validTime,
    this.creatorName,
    this.createTime = 0,
    this.isUsed = 0,
    this.encryption = 0,
    this.unlockMode = '',
    this.memberId,
  });

  factory UnlockInfo.fromJson(Map<String, dynamic> json) {
    ///服务上的 validType 是设备端原始数据，app 这里只取低 4 位的类型
    var validType = _parseString(json['validType']);
    if (validType.length > 1) {
      validType = validType[validType.length - 1];
    }
    return UnlockInfo(
      id: _parseString(json['id']),
      hardwareId: _parseString(json['hardwareId']),
      deviceSn: _parseString(json['deviceSn']),
      name: _parseString(json['name']),
      password: _parseString(json['password']),
      isAdmin: json['isAdmin'] == true || _parseInt(json['isAdmin']) == 1,
      isValid: _parseInt(json['isValid']),
      validType: validType,
      validTime: _parseString(json['validTime']),
      creatorName: json['creatorName']?.toString(),
      createTime: _parseInt(json['createTime']),
      isUsed: _parseInt(json['isUsed']),
      encryption: _parseInt(json['encryption']),
      unlockMode: _parseString(json['unlockMode']),
      memberId: json['memberId'] == null ? null : _parseInt(json['memberId']),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  static String _parseString(dynamic v) => v?.toString() ?? '';

  ///列表主标题：优先昵称，无昵称回退“离线密码”
  String get displayTitle {
    final n = name.trim();
    if (n.isNotEmpty) return n;
    return '离线密码';
  }

  ///时效类型文案（0永久/1单次/2限时/3循环/4清除）
  String get validTypeDescription {
    switch (validType) {
      case '0':
        return '永久';
      case '1':
        return '单次';
      case '2':
        return '限时';
      case '3':
        return '循环';
      case '4':
        return '单次';
      default:
        return '';
    }
  }

  ///生效状态文案（1未生效/2失效，正常为空）
  ///
  ///循环密码额外本地兜底：服务器 isValid 可能仍为 0（正常），
  ///但起始生效日落在未来时应显示“未生效”，故先判 _loopNotEffective。
  String get isValidDescription {
    if (_loopNotEffective) return '未生效';
    switch (isValid) {
      case 1:
        return '未生效';
      case 2:
        return '已失效';
      case 3:
        return '无效';
      default:
        return '';
    }
  }

  ///副标题（各时效类型的时间解析）
  ///
  ///各时效类型时间来源不同：
  ///- 永久(0)：无时间，留空
  ///- 单次(1/17)：取 createTime 创建时间（精确到小时），非 validTime
  ///- 限时(2/18)/清空(4)：validTime[0:8]hex、[8:16]hex 各 ×60 + 2023基准时间戳 → 起止时间
  ///- 循环(3/19)：validTime[10:13]hex、[13:16]hex 为每天起止时刻(分钟数) → HH:mm ~ HH:mm
  String get displaySubTitle {
    switch (validType) {
      case '0': //永久：副标题为空
        return '';
      case '1': //单次
      case '17': //单次失效
        if (createTime <= 0) return validTypeDescription;
        final dt =
            DateTime.fromMillisecondsSinceEpoch(createTime * 1000).toLocal();
        return '${_fmt(dt, minute: false)} $validTypeDescription';
      case '2': //限时
      case '18': //限时失效
      case '4': //清空（归到限时同款解析）
        final vt = validTime.trim();
        if (vt.length < 16) return validTypeDescription;
        final begin = int.tryParse(vt.substring(0, 8), radix: 16);
        final end = int.tryParse(vt.substring(8, 16), radix: 16);
        if (begin == null || end == null) return validTypeDescription;
        final base = _year2023Base();
        final beginDt = DateTime.fromMillisecondsSinceEpoch(
                (begin * 60 + base) * 1000)
            .toLocal();
        final endDt =
            DateTime.fromMillisecondsSinceEpoch((end * 60 + base) * 1000)
                .toLocal();
        return '${_fmt(beginDt)} ~ ${_fmt(endDt)} $validTypeDescription';
      case '3': //循环
      case '19': //循环失效
        final range = _loopDayRangeText;
        return range.isEmpty
            ? validTypeDescription
            : '$range $validTypeDescription';
      default:
        return validTypeDescription;
    }
  }

  ///2023-01-01 00:00 的秒级时间戳（含时区偏移）
  static int _year2023Base() {
    final offset = DateTime.now().timeZoneOffset.inSeconds;
    final date = DateTime(2023, 1, 1, 0, 0);
    return (date.millisecondsSinceEpoch ~/ 1000) + offset;
  }

  ///循环(3)每天生效时段文案：HH:mm ~ HH:mm，解析失败返回空串
  ///
  ///validTime(16 hex) 布局：[0:4]起始日 [4:8]结束日 [8:10]星期位图
  ///[10:13]每日起时(分钟) [13:16]每日止时(分钟)。循环密码按整点生成，
  ///止时 endHour=24 时为 1440 分 → 24:00。
  String get _loopDayRangeText {
    final vt = validTime.trim();
    if (vt.length < 16) return '';
    final startMin = int.tryParse(vt.substring(10, 13), radix: 16);
    final endMin = int.tryParse(vt.substring(13, 16), radix: 16);
    if (startMin == null || endMin == null) return '';
    return '${_fmtMinuteOfDay(startMin)} ~ ${_fmtMinuteOfDay(endMin)}';
  }

  ///循环(3)重复星期文案：解析 validTime[8:10] 星期位图 → 每天/周一、周三..
  ///
  ///位图 bit0=周日…bit6=周六（byteToWeeks）；非循环或解析失败返回空串，详情页按需隐藏。
  String get weeksText {
    if (validType != '3') return '';
    final vt = validTime.trim();
    if (vt.length < 16) return '';
    final byte = int.tryParse(vt.substring(8, 10), radix: 16);
    if (byte == null) return '';
    final weeks = byteToWeeks(byte);
    if (weeks.isEmpty) return '';
    if (weeks.length >= 7) return '每天';
    const names = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    final sorted = [...weeks]..sort();
    return sorted.where((w) => w >= 0 && w < 7).map((w) => names[w]).join('、');
  }

  ///循环(3)密码是否“未生效”：起始生效日在当前时间之后
  ///
  ///服务器 isValid 对循环密码常返回 0（正常），但起始日若落在未来
  ///（勾选星期不含今天），锁端要到下个生效日才接受该密码，故本地兜底判未生效。
  ///循环密码长期重复、无过期概念，只判未生效不判已失效（与离线密码口径一致）。
  bool get _loopNotEffective {
    if (validType != '3') return false;
    final begin = _loopBeginDateTime;
    if (begin == null) return false;
    return begin.isAfter(DateTime.now());
  }

  ///循环(3)起始生效本地时间：validTime[0:4]起始日天偏移(基准2023-01-01) + [10:13]每日起时(分钟)
  ///
  ///用本地日期运算而非时间戳，避开时区偏移叠加；解析失败返回 null。
  DateTime? get _loopBeginDateTime {
    final vt = validTime.trim();
    if (vt.length < 16) return null;
    final startDay = int.tryParse(vt.substring(0, 4), radix: 16);
    final startMin = int.tryParse(vt.substring(10, 13), radix: 16);
    if (startDay == null || startMin == null) return null;
    final datePart = DateTime(2023, 1, 1).add(Duration(days: startDay));
    return DateTime(datePart.year, datePart.month, datePart.day,
        startMin ~/ 60, startMin % 60);
  }

  ///一天内的分钟数 → HH:mm（1440 → 24:00）
  static String _fmtMinuteOfDay(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  ///详情页顶部有效期展示
  ///
  ///与 [displaySubTitle]（列表副标题）的关键差异：
  ///- 单次(1/17)：副标题只显 beginDate 单个时间点，本 getter 显 beginDate ~ endDate（+6 小时）
  ///- 永久(0)：副标题返空串，本 getter 返 "永久"
  ///- 限时(2/18)/清空(4)：两者一致（beginTime ~ endTime）
  ///- 循环(3/19)：每天起止时段 HH:mm ~ HH:mm（不含日期；星期由 weeksText 单独解析）
  String get detailValidTime {
    switch (validType) {
      case '0': //永久
        return '永久';
      case '1': //单次
      case '17': //单次失效
        if (createTime <= 0) return validTypeDescription;
        final dt =
            DateTime.fromMillisecondsSinceEpoch(createTime * 1000).toLocal();
        ///格式化到小时精度后 +6 小时得 endDate
        final begin = DateTime(dt.year, dt.month, dt.day, dt.hour);
        final end = begin.add(const Duration(hours: 6));
        return '${_fmt(begin, minute: false)} ~ ${_fmt(end, minute: false)}';
      case '2': //限时
      case '18': //限时失效
      case '4': //清空
        final vt = validTime.trim();
        if (vt.length < 16) return validTypeDescription;
        final b = int.tryParse(vt.substring(0, 8), radix: 16);
        final e = int.tryParse(vt.substring(8, 16), radix: 16);
        if (b == null || e == null) return validTypeDescription;
        final base = _year2023Base();
        final beginDt =
            DateTime.fromMillisecondsSinceEpoch((b * 60 + base) * 1000)
                .toLocal();
        final endDt =
            DateTime.fromMillisecondsSinceEpoch((e * 60 + base) * 1000)
                .toLocal();
        return '${_fmt(beginDt)} ~ ${_fmt(endDt)}';
      case '3': //循环
      case '19': //循环失效
        final range = _loopDayRangeText;
        return range.isEmpty ? validTypeDescription : range;
      default:
        return validTypeDescription;
    }
  }

  ///格式化时间：minute=true → yyyy-MM-dd HH:mm；false → yyyy-MM-dd HH:00
  static String _fmt(DateTime d, {bool minute = true}) {
    final yyyy = d.year.toString().padLeft(4, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return minute ? '$yyyy-$mm-$dd $hh:$mi' : '$yyyy-$mm-$dd $hh:00';
  }

  ///锁端删除用的硬件ID（int）
  int get hardwareIdInt => int.tryParse(hardwareId) ?? 0;

  ///创建时间字符串（yyyy-MM-dd HH:mm:ss，详情页展示用）
  ///createTime=0 时返回空串
  String get createDateTimeString {
    if (createTime <= 0) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(createTime * 1000).toLocal();
    final yyyy = d.year.toString().padLeft(4, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    final ss = d.second.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd $hh:$mi:$ss';
  }
}
