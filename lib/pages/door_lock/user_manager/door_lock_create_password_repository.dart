import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk/utils/dst_helper.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/api/door_lock_api.dart';
import 'package:intl/intl.dart';

///生成密码失败异常
class CreatePwdException implements Exception {
  final String message;

  CreatePwdException(this.message);

  @override
  String toString() => message;
}

int _sec(DateTime dt) => dt.millisecondsSinceEpoch ~/ 1000;

///是否纯数字
bool _isNumeric(String s) => RegExp(r'^[0-9]*$').hasMatch(s);

///是否符合新国标：非连续（123456）、非全同（111111）
bool _complyNationalStandard(String pwd) {
  if (_simpleContinuous(pwd)) return false;
  if (_sameNumber(pwd)) return false;
  return true;
}

bool _simpleContinuous(String password) {
  if (password.length < 2 || !_isNumeric(password)) return false;
  if (password.length == 2) {
    final diff = int.parse(password[1]) - int.parse(password[0]);
    return diff == 1 || diff == -1;
  }
  final first = int.parse(password[0]);
  final second = int.parse(password[1]);
  final diff = second - first;
  if (diff != 1 && diff != -1) return false;
  final expected =
      List.generate(password.length, (i) => (first + i * diff).toString());
  for (int i = 0; i < password.length; i++) {
    if (password[i] != expected[i]) return false;
  }
  return true;
}

bool _sameNumber(String password) {
  if (password.isEmpty || !_isNumeric(password)) return false;
  return RegExp(r'^(\d)\1*$').hasMatch(password);
}

///昵称校验：2-10 字符（对齐详情页昵称编辑约定）
void _checkName(String name) {
  final t = name.trim();
  if (t.length < 2 || t.length > 10) {
    throw CreatePwdException('昵称长度需为 2-10 个字符');
  }
}

///从 generateOfflineUnlockPwd 返回体提取密码串
String _extractPwd(dynamic result) {
  if (result is Map && result['data'] is String) {
    return result['data'] as String;
  }
  throw CreatePwdException('生成失败：服务器未返回密码');
}

// ==================== 永久密码 ====================

///永久密码校验（App 端输入密码规则）：纯数字、6-10 位、昵称 2-10、非连续/重复
void validateForeverPassword({
  required String pwdName,
  required String pwd,
}) {
  if (!_isNumeric(pwd)) throw CreatePwdException('密码只能为数字');
  if (pwd.length < 6 || pwd.length > 10) {
    throw CreatePwdException('密码长度需为 6-10 位');
  }
  _checkName(pwdName);
  if (!_complyNationalStandard(pwd)) {
    throw CreatePwdException('密码过于简单，不能使用连续或重复数字');
  }
}

///永久密码锁端录入成功后保存到服务器
///
///[hardwareId] 为锁端添加返回的硬件 ID（由 operation 层 doorLockAddPasswordType
///走设备通道录入得到）。返回密码串。
Future<String> saveForeverPasswordToServer({
  required String deviceId,
  required String pwdName,
  required String pwd,
  required bool isAdmin,
  required int hardwareId,
}) async {
  await doorlockAPI.saveDoorLockUser(
    sn: deviceId,
    users: [
      {
        'Id': hardwareId,
        'Type': JvssOperateType.password.value,
        'Auth': isAdmin ? 0 : 1,
        'userNickName': pwdName,
        'password': pwd,
      }
    ],
    operationStr: JvssOperationAction.add.value,
    userTypes: [JvssOperateType.password.value],
  );
  return pwd;
}

// ==================== 自定义（临时）密码 ====================

///生成自定义/临时密码
///
///[weeks] 选中的周（0-6，0=周日）；[isRb] 是否胁迫用户（uType=3）。
///[pwdLength] 临时密码位数（默认 7）。
Future<String> createCustomPassword({
  required String deviceId,
  required String pwdName,
  required String pwd,
  required DateTime start,
  required DateTime end,
  required List<int> weeks,
  required bool isRb,
  int pwdLength = 7,
}) async {
  _checkName(pwdName);
  if (!_isNumeric(pwd)) throw CreatePwdException('密码只能为数字');
  if (pwd.length != pwdLength) {
    throw CreatePwdException('密码需为 $pwdLength 位数字');
  }
  if (!_complyNationalStandard(pwd)) {
    throw CreatePwdException('密码过于简单，不能使用连续或重复数字');
  }
  if (weeks.isEmpty) throw CreatePwdException('请至少选择一天');
  if (!start.isBefore(end)) throw CreatePwdException('开始时间需早于结束时间');
  if (end.isBefore(DateTime.now())) throw CreatePwdException('结束时间需晚于当前时间');

  ///rpt：星期位图转 hex（'week 0x..'）
  final rpt = 'week 0x${bytesToHex([weeksToByte(weeks)])}';
  await doorlockAPI.addTempPwd(
    deviceSn: deviceId,
    password: pwd,
    name: pwdName,
    rpt: rpt,
    startTime: DateFormat('yyyy-MM-dd HH:mm').format(start),
    endTime: DateFormat('yyyy-MM-dd HH:mm').format(end),
    startTimeStamp: _sec(start),
    endTimeStamp: _sec(end),
    uType: isRb ? 3 : 1,
  );
  return pwd;
}

// ==================== 单次离线密码 ====================

///生成单次离线密码
Future<String> createOfflineSingle({
  required String deviceId,
  required String pwdName,
}) async {
  _checkName(pwdName);
  final now = DateTime.now();
  final startTime = DateTime(now.year, now.month, now.day, now.hour);
  final result = await doorlockAPI.generateOfflineUnlockPwd(
    deviceSn: deviceId,
    pwdName: pwdName,
    createTime: _sec(now),
    validType: 'once',
    startTime: _sec(startTime),
  );
  return _extractPwd(result);
}

// ==================== 限时离线密码 ====================

///生成限时离线密码
///
///时间精确到小时；生效时间不能早于当前小时；有效期不超过一年（除非周年对齐）。
Future<String> createOfflineLimit({
  required String deviceId,
  required String pwdName,
  required DateTime start,
  required DateTime end,
}) async {
  _checkName(pwdName);

  ///精确到小时
  final startTime = DateTime(start.year, start.month, start.day, start.hour);
  final endTime = DateTime(end.year, end.month, end.day, end.hour);
  if (!startTime.isBefore(endTime)) throw CreatePwdException('开始时间需早于结束时间');

  final now = DateTime.now();
  if (endTime.isBefore(now)) throw CreatePwdException('结束时间需晚于当前时间');

  ///生效时间不能早于当前小时
  if (_sec(startTime) ~/ 3600 < _sec(now) ~/ 3600) {
    throw CreatePwdException('生效时间不能早于当前时间');
  }

  ///跨年判断：超过下年同日则要求周年对齐（月/日/时一致）
  bool overOneYear = false;
  final nextDate = DateTime(startTime.year + 1, startTime.month, startTime.day);
  if (endTime.isAfter(nextDate)) {
    if (startTime.day != endTime.day || startTime.hour != endTime.hour) {
      throw CreatePwdException('限时密码有效期不能超过一年');
    }
    overOneYear = true;
  }

  final result = await doorlockAPI.generateOfflineUnlockPwd(
    deviceSn: deviceId,
    pwdName: pwdName,
    createTime: _sec(now),
    validType: 'limit',
    year: now.year,
    overOneYear: overOneYear ? 1 : 0,
    startTime: _sec(startTime),
    endTime: _sec(endTime),
    pwdLengthRange: [10, 10],
  );
  return _extractPwd(result);
}

// ==================== 循环离线密码 ====================

///生成循环离线密码
///
///[startHour]/[endHour] 每天生效时段（endHour=0 视为 24）；[weeks] 选中周（0=周日）。
///计算最近生效日期并做夏令时偏移。
Future<String> createOfflineLoop({
  required String deviceId,
  required String pwdName,
  required int startHour,
  required int endHour,
  required List<int> weeks,
}) async {
  _checkName(pwdName);
  if (weeks.isEmpty) throw CreatePwdException('请至少选择一天');
  if (startHour >= endHour) throw CreatePwdException('开始时间需早于结束时间');

  final now = DateTime.now();
  final week = weeks.join(',');

  ///在选定周期内找到最近生效日期
  var effectDays = 0;
  var currentWeekDay = now.weekday % 7; //0=周日
  while (!weeks.contains(currentWeekDay)) {
    currentWeekDay = (currentWeekDay + 1) % 7;
    effectDays++;
  }
  final effectBase =
      DateTime(now.year, now.month, now.day).add(Duration(days: effectDays));
  var effectTime =
      DateTime(effectBase.year, effectBase.month, effectBase.day, startHour);

  ///夏令时偏移（DSTHelper 需先 getDstInfo 初始化；失败按非夏令时处理）
  bool isDst = false;
  try {
    final dst = DSTHelper();
    await dst.getDstInfo();
    isDst = dst.inDst(effectTime);
  } catch (e) {
    LogUtils.doorLock.log('循环密码夏令时判断失败，按非夏令时处理: $e');
  }
  if (isDst) effectTime = effectTime.add(const Duration(seconds: 3600));

  final result = await doorlockAPI.generateOfflineUnlockPwd(
    deviceSn: deviceId,
    pwdName: pwdName,
    createTime: _sec(now),
    validType: 'cycle',
    year: now.year,
    startHour: startHour,
    endHour: endHour == 0 ? 24 : endHour,
    time: DateFormat('yyyy-MM-dd').format(effectTime.toUtc()),
    startTime: _sec(effectTime),
    week: week,
  );
  return _extractPwd(result);
}
