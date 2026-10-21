import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/door_user.dart';
import 'package:fcloudsdk_example/pages/door_lock/user_manager/add_door_lock_user_guide_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

///添加门锁用户时效选择页（普通用户添加指纹等开锁方式的前置页）
///
///- Tab：永久 / 限时 / 循环（永久 Tab 按设备能力显隐）
///- 昵称输入（2-10 字符，录入成功后随 add 上报服务器）
///- 时效配置：限时（生效/失效时间精确到分）；循环（星期 + 全天/时段 + 生效/失效日期）
///- 下一步：校验后携带 [DoorUser]（vaildTimeData）跳录入引导页
class AddDoorLockVaildTimeSelPage extends StatefulWidget {
  final String deviceId;

  ///1普通用户 0管理员（时效页仅普通用户使用）
  final int addType;

  ///开锁方式类型（指纹）
  final JvssOperateType type;

  const AddDoorLockVaildTimeSelPage({
    super.key,
    required this.deviceId,
    required this.addType,
    required this.type,
  });

  @override
  State<AddDoorLockVaildTimeSelPage> createState() =>
      _AddDoorLockVaildTimeSelPageState();
}

class _AddDoorLockVaildTimeSelPageState
    extends State<AddDoorLockVaildTimeSelPage> {
  ///时效选择数据（昵称/时效在此对象上编辑，录入页接收后下发锁端并上报）
  late final DoorUser _vaildTimeData = DoorUser(
    id: -1,
    type: widget.type.value,
    auth: widget.addType == 0 ? 0 : 1,
    sn: widget.deviceId,
  );

  ///当前时效 Tab
  late DoorLockTimelinessType _timelinessType;

  ///循环-全天开关
  bool _isAllDay = false;

  ///昵称输入控制器
  final TextEditingController _nickController = TextEditingController();

  Device? get _device =>
      DeviceManager.instance.getDevice(deviceId: widget.deviceId);

  @override
  void initState() {
    super.initState();
    if (_showForever()) {
      _timelinessType = DoorLockTimelinessType.permanent;
    } else {
      _timelinessType = DoorLockTimelinessType.limit;
      _vaildTimeData.timelinessType = _timelinessType;
    }
    _resetTimeData();
  }

  @override
  void dispose() {
    _nickController.dispose();
    super.dispose();
  }

  ///永久 Tab 显隐（设备支持密码开锁方式才提供永久用户）
  bool _showForever() {
    return _device?.doorUserAbility?.byte1.supportPassword ?? false;
  }

  ///切换 Tab / 初始化时填充默认时效
  ///
  ///- 限时：now ~ now+1 月（非密码对齐 jlink getVaildStartAndEnd 通用分支）
  ///- 循环：now ~ now+1 月+1 小时（pswType=4 加一小时），日期归零点到天，
  ///  星星期默认全不选（非密码类型），时段默认当前时刻 ~ +1 小时
  void _resetTimeData() {
    _vaildTimeData.timelinessType = _timelinessType;
    var now = DateTime.now();
    var endTime = DateTime(now.year, now.month + 1, now.day, now.hour,
        now.minute, now.second);

    if (_timelinessType == DoorLockTimelinessType.limit) {
      _vaildTimeData.parseValidTime = _vaildTimeData.copyParseValidTime(
        startTime: now,
        endTime: endTime,
      );
    } else if (_timelinessType == DoorLockTimelinessType.loop) {
      var loopEnd = endTime.add(const Duration(hours: 1));
      _vaildTimeData.parseValidTime = _vaildTimeData.copyParseValidTime(
        startTime: DateTime(now.year, now.month, now.day),
        endTime: DateTime(loopEnd.year, loopEnd.month, loopEnd.day),
        weeks: [],
        startMin: now.hour * 60 + now.minute,
        endMin: loopEnd.hour * 60 + loopEnd.minute,
      );
      _isAllDay = false;
    } else {
      _vaildTimeData.parseValidTime = null;
    }
  }

  ///下一步按钮是否可用
  bool _isEnable() {
    final nick = _nickController.text.trim();
    if (nick.length < 2) return false;
    if (_timelinessType == DoorLockTimelinessType.permanent) {
      return true;
    }
    if (_timelinessType == DoorLockTimelinessType.limit) {
      return _vaildTimeData.parseValidTime?.startTime != null &&
          _vaildTimeData.parseValidTime?.endTime != null;
    }
    if (_timelinessType == DoorLockTimelinessType.loop) {
      final weeks = _vaildTimeData.parseValidTime?.weeks;
      return _vaildTimeData.parseValidTime?.startTime != null &&
          _vaildTimeData.parseValidTime?.endTime != null &&
          _vaildTimeData.parseValidTime?.startMin != null &&
          _vaildTimeData.parseValidTime?.endMin != null &&
          weeks != null && weeks.isNotEmpty;
    }
    return false;
  }

  ///下一步：校验后跳录入引导页
  Future<void> _onNext() async {
    final nick = _nickController.text.trim();

    ///昵称校验（2-10 个字符）
    if (nick.length < 2 || nick.length > 10) {
      _showSnack('昵称长度需为 2-10 个字符');
      return;
    }
    _vaildTimeData.userNickName = nick;

    final parse = _vaildTimeData.parseValidTime;

    ///起止时间校验
    if (parse?.startTime != null &&
        parse?.endTime != null &&
        parse!.startTime!.isAfter(parse.endTime!)) {
      _showSnack('结束时间需晚于开始时间');
      return;
    }

    ///循环时段校验
    if (_timelinessType == DoorLockTimelinessType.loop &&
        parse?.startMin != null &&
        parse?.endMin != null &&
        parse!.startMin! >= parse.endMin!) {
      _showSnack('结束时间需晚于开始时间');
      return;
    }

    ///深度休眠锁无法唤醒录入
    final device = _device;
    if (device != null &&
        device.doolockCmdStatus == DoolockCmdStatus.offline &&
        device.sleepState == DeviceSleepState.deepSleep) {
      _showSnack('设备深度休眠，无法唤醒录入');
      return;
    }

    ///时效循环/限时需蓝牙通道，提前提示不在附近
    if (_timelinessType != DoorLockTimelinessType.permanent &&
        device != null &&
        device.doolockCmdStatus != DoolockCmdStatus.wifiAndBlue &&
        device.doolockCmdStatus != DoolockCmdStatus.onlyBlue) {
      _showSnack('限时/循环用户需在蓝牙可达范围内添加');
      return;
    }

    ///时效下发锁端/上报服务器前的准备（反算 validType/validTime）
    _vaildTimeData.getVaildTypeAndTime();

    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddDoorLockUserGuidePage(
          deviceId: widget.deviceId,
          addType: widget.addType,
          type: widget.type,
          vaildTimeData: _vaildTimeData,
        ),
      ),
    );

    ///录入成功结果透传回列表页刷新
    if (added == true && mounted) {
      Navigator.of(context).pop(true);
      return;
    }
    if (mounted) setState(() {});
  }

  // ==================== picker ====================

  ///日期时间选择（限时精确到分；[onlyDay]=true 时只选日期）
  Future<void> _pickDateTime({required bool isStart, bool onlyDay = false}) {
    final parse = _vaildTimeData.parseValidTime;
    final initial = (isStart ? parse?.startTime : parse?.endTime) ??
        DateTime.now();
    return _pickYmdhm(
      initial: initial,
      onlyDay: onlyDay,
      onConfirm: (result) {
        final ori = isStart ? parse?.startTime : parse?.endTime;
        if (ori != null) {
          if (onlyDay) {
            ///循环日期保持原时刻
            result = DateTime(result.year, result.month, result.day,
                ori.hour, ori.minute);
          }
          if (isStart && !result.isBefore(parse?.endTime ?? result)) {
            _showSnack('结束时间需晚于开始时间');
            return;
          }
          if (!isStart && !result.isAfter(parse?.startTime ?? result)) {
            _showSnack('结束时间需晚于开始时间');
            return;
          }
        }
        setState(() {
          _vaildTimeData.parseValidTime = _vaildTimeData.copyParseValidTime(
            startTime: isStart ? result : null,
            endTime: isStart ? null : result,
          );
        });
      },
    );
  }

  ///循环时段选择（仅时分）
  Future<void> _pickHourMinute({required bool isStart}) {
    final parse = _vaildTimeData.parseValidTime;
    final min = (isStart ? parse?.startMin : parse?.endMin) ??
        (DateTime.now().hour * 60 + DateTime.now().minute);
    final initial = DateTime(2026, 1, 1, min ~/ 60, min % 60);
    return _pickYmdhm(
      initial: initial,
      onlyTime: true,
      onConfirm: (result) {
        var resultMin = result.hour * 60 + result.minute;
        if (isStart &&
            parse?.endMin != null &&
            resultMin >= parse!.endMin!) {
          _showSnack('结束时间需晚于开始时间');
          return;
        }
        if (!isStart &&
            parse?.startMin != null &&
            resultMin <= parse!.startMin!) {
          _showSnack('结束时间需晚于开始时间');
          return;
        }
        setState(() {
          _vaildTimeData.parseValidTime = _vaildTimeData.copyParseValidTime(
            startMin: isStart ? resultMin : null,
            endMin: isStart ? null : resultMin,
          );
        });
      },
    );
  }

  ///原生组合 picker：日期（onlyDay）/ 日期+时间 / 仅时间
  Future<void> _pickYmdhm({
    required DateTime initial,
    required Function(DateTime) onConfirm,
    bool onlyDay = false,
    bool onlyTime = false,
  }) async {
    var date = initial;
    if (!onlyTime) {
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2023),
        lastDate: DateTime(2100),
      );
      if (picked == null || !mounted) return;
      date = picked;
    }
    if (onlyDay) {
      onConfirm(date);
      return;
    }
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
    if (pickedTime == null || !mounted) return;
    onConfirm(DateTime(
      date.year,
      date.month,
      date.day,
      pickedTime.hour,
      pickedTime.minute,
    ));
  }

  // ==================== UI ====================

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(title: const Text('添加用户')),
      body: Column(
        children: [
          if (_tabConfigs.length > 1) _buildTabBar(),
          _buildNickNameInput(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 15),
              child: _buildTypeConfig(),
            ),
          ),
          _buildNextButton(),
        ],
      ),
    );
  }

  List<_TabConfig> get _tabConfigs {
    return [
      if (_showForever())
        _TabConfig(
            value: DoorLockTimelinessType.permanent.value, title: '永久'),
      _TabConfig(value: DoorLockTimelinessType.limit.value, title: '限时'),
      _TabConfig(value: DoorLockTimelinessType.loop.value, title: '循环'),
    ];
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.5),
      height: 50,
      color: Colors.white,
      child: Row(
        children: [
          for (var i = 0; i < _tabConfigs.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: _buildTabItem(_tabConfigs[i])),
          ],
        ],
      ),
    );
  }

  Widget _buildTabItem(_TabConfig config) {
    final isSelected = _timelinessType.value == config.value;
    return InkWell(
      onTap: () {
        setState(() {
          _timelinessType = DoorLockTimelinessType.from(config.value);
          _resetTimeData();
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            config.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF00B294)
                  : const Color(0xFF000000),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          isSelected
              ? const DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    color: Color(0xFF00B294),
                  ),
                  child: SizedBox(width: 36, height: 3),
                )
              : const SizedBox(height: 3),
        ],
      ),
    );
  }

  ///昵称输入
  Widget _buildNickNameInput() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 14.5, right: 14.5, top: 20, bottom: 10),
      child: TextField(
        controller: _nickController,
        maxLength: 10,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: '昵称',
          hintText: '请输入用户昵称',
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  ///时效配置区（按当前 Tab 渲染）
  Widget _buildTypeConfig() {
    if (_timelinessType == DoorLockTimelinessType.permanent) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _typeConfigRows(),
        ),
      ),
    );
  }

  List<Widget> _typeConfigRows() {
    if (_timelinessType == DoorLockTimelinessType.limit) {
      return [
        _infoRow('生效时间',
            text: _vaildTimeData.parseValidTime?.startTime == null
                ? '-'
                : DateFormat('yyyy-MM-dd HH:mm')
                    .format(_vaildTimeData.parseValidTime!.startTime!),
            onTap: () => _pickDateTime(isStart: true)),
        _infoRow('失效时间',
            text: _vaildTimeData.parseValidTime?.endTime == null
                ? '-'
                : DateFormat('yyyy-MM-dd HH:mm')
                    .format(_vaildTimeData.parseValidTime!.endTime!),
            onTap: () => _pickDateTime(isStart: false)),
      ];
    }

    ///循环
    return [
      _weeksRow(),
      _infoRow('全天', showSwitch: true),
      if (!_isAllDay) ...[
        _infoRow('生效时刻',
            text: _vaildTimeData.startHour ?? '-',
            onTap: () => _pickHourMinute(isStart: true)),
        _infoRow('失效时刻',
            text: _vaildTimeData.endHour ?? '-',
            onTap: () => _pickHourMinute(isStart: false)),
      ],
      _infoRow('生效日期',
          text: _vaildTimeData.parseValidTime?.startTime == null
              ? '-'
              : DateFormat('yyyy-MM-dd')
                  .format(_vaildTimeData.parseValidTime!.startTime!),
          onTap: () => _pickDateTime(isStart: true, onlyDay: true)),
      _infoRow('失效日期',
          text: _vaildTimeData.parseValidTime?.endTime == null
              ? '-'
              : DateFormat('yyyy-MM-dd')
                  .format(_vaildTimeData.parseValidTime!.endTime!),
          onTap: () => _pickDateTime(isStart: false, onlyDay: true)),
    ];
  }

  ///星期多选（周日为 0）
  Widget _weeksRow() {
    final weeks = _vaildTimeData.parseValidTime?.weeks ?? [];
    const names = ['日', '一', '二', '三', '四', '五', '六'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('重复', style: TextStyle(fontSize: 13, color: Color(0xFF898989))),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        var list = [...weeks];
                        if (list.contains(i)) {
                          list.remove(i);
                        } else {
                          list.add(i);
                        }
                        _vaildTimeData.parseValidTime =
                            _vaildTimeData.copyParseValidTime(weeks: list);
                      });
                    },
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: weeks.contains(i)
                            ? const Color(0xFF00B294)
                            : const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        names[i],
                        style: TextStyle(
                          color: weeks.contains(i)
                              ? Colors.white
                              : const Color(0xFF666666),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  ///信息行（左标题 + 右值/开关 + 箭头）
  Widget _infoRow(String title,
      {String text = '-', VoidCallback? onTap, bool showSwitch = false}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 45,
            child: Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, color: Color(0xFF000000))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      text,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF888888)),
                    ),
                  ),
                ),
                if (showSwitch)
                  Switch(
                    value: _isAllDay,
                    onChanged: _onAllDaySwitch),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      size: 16, color: Color(0xFF888888)),
                ],
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  ///全天开关：开→时段 0:00~23:59，关→当前时刻 ~ +1 小时
  void _onAllDaySwitch(bool isOn) {
    setState(() {
      _isAllDay = isOn;
      if (isOn) {
        _vaildTimeData.parseValidTime =
            _vaildTimeData.copyParseValidTime(startMin: 0);
        _vaildTimeData.parseValidTime =
            _vaildTimeData.copyParseValidTime(endMin: 24 * 60 - 1);
      } else {
        var now = DateTime.now();
        var later = now.add(const Duration(hours: 1));
        _vaildTimeData.parseValidTime = _vaildTimeData
            .copyParseValidTime(startMin: now.hour * 60 + now.minute);
        _vaildTimeData.parseValidTime =
            _vaildTimeData.copyParseValidTime(endMin: later.hour * 60 + later.minute);
      }
    });
  }

  Widget _buildNextButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14.5, 8, 14.5, 15),
        child: SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B294),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFBFBFBF),
            ),
            onPressed: _isEnable() ? _onNext : null,
            child: const Text('下一步'),
          ),
        ),
      ),
    );
  }
}

///标签配置
class _TabConfig {
  final int value;
  final String title;

  const _TabConfig({required this.value, required this.title});
}
