import 'package:fcloudsdk/door_lock/door_lock_ble_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/api/door_lock_api.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/user_manager/door_lock_create_password_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

///生成密码页
///
///按设备能力动态显示 Tab：永久 / 自定义（临时）/ 限时 / 单次 / 循环。
///- 永久：App 端输入密码 → 锁端 addDoorOpenType(pwd) + 服务器保存（需在线）
///- 自定义：addTempPwd API（星期 + 时间段 + 自定密码）
///- 限时/单次/循环：generateOfflineUnlockPwd API（服务器算密码）
class DoorLockCreatePasswordPage extends StatefulWidget {
  final String deviceId;

  ///入口类型：password 密码入口（永久/自定义/离线按能力显示）/
  ///tmpPassword 临时密码入口（仅自定义 Tab）
  final JvssOperateType type;

  const DoorLockCreatePasswordPage(
      {super.key,
      required this.deviceId,
      this.type = JvssOperateType.password});

  @override
  State<DoorLockCreatePasswordPage> createState() =>
      _DoorLockCreatePasswordPageState();
}

class _DoorLockCreatePasswordPageState extends State<DoorLockCreatePasswordPage>
    with SingleTickerProviderStateMixin {
  // ==================== Tab 定义 ====================

  ///Tab 类型：0 永久 / 1 自定义 / 2 限时 / 3 单次 / 4 循环
  static const Map<int, String> _tabTitles = {
    0: '永久',
    1: '自定义',
    2: '限时',
    3: '单次',
    4: '循环',
  };

  ///当前设备可见的 Tab（initState 按能力计算）
  late final List<int> _tabs = _buildTabs();

  late final TabController _controller =
      TabController(length: _tabs.length, vsync: this);

  // ==================== 表单状态 ====================

  final _nameCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  ///永久：是否管理员
  bool _isAdmin = false;

  ///自定义：是否胁迫用户
  bool _isRb = false;

  ///自定义密码位数（默认值 7）
  static const int _tempPwdLength = 7;

  ///选中的周（0-6，0=周日），默认全选
  final List<int> _weeks = [0, 1, 2, 3, 4, 5, 6];

  ///限时/自定义：生效、失效时间
  late DateTime _start;
  late DateTime _end;

  ///循环：每天生效时段（小时）
  int _startHour = 8;
  int _endHour = 18;

  bool _creating = false;
  bool _loadingShown = false;

  Device? get _device =>
      DeviceManager.instance.getDevice(deviceId: widget.deviceId);

  ///门锁操作对象（永久密码走 BLE/netip 通道下发到锁端录入）
  DoorLockOperationObject? _op;
  DoorLockOperationObject get _operation => _op ??=
      DoorLockOperationObject(deviceId: widget.deviceId, keepAlive: true);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, now.day, now.hour);
    _end = DateTime(now.year, now.month, now.day, now.hour)
        .add(const Duration(days: 30));
    _controller.addListener(_onTabChanged);
    // 若首个可见 Tab 即自定义，密码首位初始化为 1
    if (_tabs.isNotEmpty && _tabs.first == 1) {
      _pwdCtrl.text = '1';
    }
  }

  ///切换 Tab：进入自定义密码时保证首位为 1
  ///（永久密码 6-10 位无首位限制，与自定义规则不兼容，非 1 开头则重置）
  void _onTabChanged() {
    if (_controller.indexIsChanging) return;
    if (_currentTab == 1 &&
        (_pwdCtrl.text.isEmpty || _pwdCtrl.text[0] != '1')) {
      _pwdCtrl.text = '1';
      _pwdCtrl.selection = const TextSelection.collapsed(offset: 1);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    _nameCtrl.dispose();
    _pwdCtrl.dispose();
    _op?.dispose();
    super.dispose();
  }

  // ==================== 能力判断 ====================

  ///永久：密码入口看 supportPassword 能力；临时密码入口不显示
  bool _showForever() =>
      widget.type != JvssOperateType.tmpPassword &&
      (_device?.doorUserAbility?.byte1.supportPassword ?? false);

  ///自定义（临时）：临时密码入口看 supportTempPwd；
  ///密码入口仅低功耗蓝牙锁 + supportTempPwd 才显示
  bool _showCustom() {
    var support = DoorLockHelper.supportTempPwd(deviceId: widget.deviceId);
    if (widget.type == JvssOperateType.tmpPassword) {
      return support;
    }
    return support && DoorLockHelper.isLowPowerBle(widget.deviceId);
  }

  ///离线（限时/单次/循环）：看 supportLockEndOffLinePwd 能力；临时密码入口不显示
  bool _showOffline() =>
      widget.type != JvssOperateType.tmpPassword &&
      (_device?.doorLockExInfo?.byte1.supportLockEndOffLinePwd ?? false);

  List<int> _buildTabs() {
    final tabs = <int>[];
    if (_showForever()) tabs.add(0);
    if (_showCustom()) tabs.add(1);
    if (_showOffline()) {
      tabs.addAll([2, 3, 4]);
    }
    return tabs;
  }

  ///当前选中的 Tab 类型
  int get _currentTab => _tabs[_controller.index];

  // ==================== build ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('生成密码'),
        bottom: _tabs.length > 1
            ? TabBar(
                controller: _controller,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                indicatorColor: Colors.transparent,
                tabs: [for (final t in _tabs) Tab(text: _tabTitles[t] ?? '')],
              )
            : null,
      ),
      body: _tabs.isEmpty ? _buildEmpty() : _buildTabView(),
      bottomNavigationBar: _tabs.isEmpty ? null : _buildCreateButton(),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Text('当前设备不支持生成密码', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _controller,
      children: [
        for (final t in _tabs) _buildTabContent(t),
      ],
    );
  }

  Widget _buildTabContent(int tab) {
    switch (tab) {
      case 0:
        return _foreverTab();
      case 1:
        return _customTab();
      case 2:
        return _limitTab();
      case 3:
        return _singleTab();
      case 4:
        return _loopTab();
    }
    return const SizedBox();
  }

  // ==================== 各 Tab 表单 ====================

  ///永久
  Widget _foreverTab() {
    return _formScroll(children: [
      _card(children: [
        _nameField(),
        _divider(),
        _pwdField(hint: '请输入 6-10 位数字密码', maxLength: 10),
        _divider(),
        _radioRow(
          title: '管理员',
          selected: _isAdmin,
          onTap: () => setState(() => _isAdmin = true),
        ),
        _radioRow(
          title: '普通用户',
          selected: !_isAdmin,
          onTap: () => setState(() => _isAdmin = false),
        ),
      ]),
    ]);
  }

  ///自定义（临时）
  Widget _customTab() {
    return _formScroll(children: [
      _card(children: [
        _nameField(),
        _divider(),
        _pwdField(
            hint: '首位固定为 1，共 $_tempPwdLength 位数字',
            maxLength: _tempPwdLength,
            prefixOne: true),
        _divider(),
        _dateTimeTile(
          label: '生效时间',
          value: _start,
          onChanged: (v) => setState(() => _start = v),
        ),
        _dateTimeTile(
          label: '失效时间',
          value: _end,
          onChanged: (v) => setState(() => _end = v),
        ),
      ]),
      _card(children: [
        _sectionLabel('重复'),
        _weekPicker(),
        _divider(),
        _radioRow(
          title: '普通用户',
          selected: !_isRb,
          onTap: () => setState(() => _isRb = false),
        ),
        _radioRow(
          title: '胁迫用户',
          subtitle: '被胁迫时使用该密码开锁会静默报警',
          selected: _isRb,
          onTap: () => setState(() => _isRb = true),
        ),
      ]),
    ]);
  }

  ///限时
  Widget _limitTab() {
    return _formScroll(children: [
      _card(children: [
        _nameField(),
        _divider(),
        _dateTimeTile(
          label: '生效时间',
          value: _start,
          onChanged: (v) => setState(() => _start = v),
        ),
        _dateTimeTile(
          label: '失效时间',
          value: _end,
          onChanged: (v) => setState(() => _end = v),
        ),
      ]),
    ]);
  }

  ///单次
  Widget _singleTab() {
    return _formScroll(children: [
      _card(children: [
        _nameField(),
      ]),
    ]);
  }

  ///循环
  Widget _loopTab() {
    return _formScroll(children: [
      _card(children: [
        _nameField(),
        _divider(),
        _sectionLabel('重复'),
        _weekPicker(),
        _divider(),
        _hourTile(
          label: '开始时间',
          value: _startHour,
          onChanged: (v) => setState(() => _startHour = v),
        ),
        _hourTile(
          label: '结束时间',
          value: _endHour,
          onChanged: (v) => setState(() => _endHour = v),
        ),
      ]),
    ]);
  }

  // ==================== 共享表单组件 ====================

  Widget _formScroll({required List<Widget> children}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE));

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(text,
          style: const TextStyle(color: Color(0xFF898989), fontSize: 13)),
    );
  }

  Widget _nameField() {
    return TextField(
      controller: _nameCtrl,
      maxLength: 10,
      onChanged: (_) => setState(() {}),
      decoration: const InputDecoration(
        labelText: '昵称',
        hintText: '请输入 2-10 个字符',
        counterText: '',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _pwdField(
      {required String hint, required int maxLength, bool prefixOne = false}) {
    return TextField(
      controller: _pwdCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
        if (prefixOne) _PrefixOneFormatter(),
      ],
      maxLength: maxLength,
      obscureText: false,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: '密码',
        hintText: hint,
        counterText: '',
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _radioRow({
    required String title,
    required bool selected,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFF1E1E1E))),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF7F7F7F))),
                  ],
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFF00B294) : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeTile({
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await _pickDateTime(value);
        if (picked != null) onChanged(picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 15)),
            const Spacer(),
            Text(DateFormat('yyyy-MM-dd HH:mm').format(value),
                style: const TextStyle(fontSize: 14, color: Color(0xFF9CA9B9))),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  Widget _hourTile({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await _pickHour(value);
        if (picked != null) onChanged(picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 15)),
            const Spacer(),
            Text('${value.toString().padLeft(2, '0')}:00',
                style: const TextStyle(fontSize: 14, color: Color(0xFF9CA9B9))),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  ///星期选择器
  Widget _weekPicker() {
    const labels = ['日', '一', '二', '三', '四', '五', '六'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int day = 0; day < 7; day++)
            InkWell(
              onTap: () => setState(() {
                if (_weeks.contains(day)) {
                  _weeks.remove(day);
                } else {
                  _weeks.add(day);
                  _weeks.sort();
                }
              }),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _weeks.contains(day)
                      ? const Color(0xFF00B294)
                      : const Color(0xFFF0F0F0),
                ),
                child: Text(
                  labels[day],
                  style: TextStyle(
                    fontSize: 13,
                    color: _weeks.contains(day) ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== 选择器 ====================

  ///日期 + 时间选择（合并为 DateTime）
  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  ///小时选择（0-24）
  Future<int?> _pickHour(int initial) async {
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择时间'),
        content: SizedBox(
          width: 120,
          height: 320,
          child: ListView(
            children: [
              for (int h = 0; h <= 24; h++)
                ListTile(
                  dense: true,
                  title: Text('${h.toString().padLeft(2, '0')}:00'),
                  trailing: h == initial
                      ? const Icon(Icons.check,
                          size: 18, color: Color(0xFF00B294))
                      : null,
                  onTap: () => Navigator.of(ctx).pop(h),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 生成逻辑 ====================

  ///按钮是否可点击
  bool _canCreate() {
    final name = _nameCtrl.text.trim();
    final pwd = _pwdCtrl.text;
    switch (_currentTab) {
      case 0:
        return name.isNotEmpty && pwd.length >= 6 && pwd.length <= 10;
      case 1:
        return name.isNotEmpty &&
            pwd.length == _tempPwdLength &&
            _weeks.isNotEmpty;
      case 4:
        return name.isNotEmpty && _weeks.isNotEmpty && _startHour < _endHour;
      default:
        return name.isNotEmpty;
    }
  }

  Widget _buildCreateButton() {
    final enable = _canCreate() && !_creating;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14.5, 8, 14.5, 12),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: enable ? _onCreate : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B294),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFB2DFD8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('生成密码', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Future<void> _onCreate() async {
    if (_creating) return;
    final device = _device;
    if (device == null) {
      _showSnack('设备不存在');
      return;
    }
    final tab = _currentTab;

    ///永久密码走 BLE/netip 通道下发到锁端，离线设备不支持
    if (tab == 0 && device.doolockCmdStatus == DoolockCmdStatus.offline) {
      _showSnack('设备离线，无法生成永久密码');
      return;
    }

    ///离线密码（限时/单次/循环）依赖锁端基准年/密钥同步状态
    ///未同步时弹窗引导去同步，同步成功后继续生成
    if ((tab == 2 || tab == 3 || tab == 4) &&
        (device.keySyncState == false || device.yearSyncState == false)) {
      final go = await _confirmOfflineSync();
      if (go != true) return;
      if (!await _syncOfflineBase()) return;
    }

    setState(() => _creating = true);
    _showLoading('正在生成...');
    try {
      final name = _nameCtrl.text.trim();
      final pwd = _pwdCtrl.text;
      late String result;
      switch (tab) {
        case 0:
          validateForeverPassword(pwdName: name, pwd: pwd);
          final addRes = await _operation.doorLockAddPasswordType(
              pwd: pwd, isAdmin: _isAdmin);
          if (!addRes.success) {
            throw CreatePwdException(
                addRes.err == DoorLockNetIpOperaterResult.needSync
                    ? '同步状态过期，请返回后重新进入密码管理页'
                    : '锁端添加失败${addRes.err != null ? ': ${addRes.err}' : ''}');
          }
          result = await saveForeverPasswordToServer(
            deviceId: widget.deviceId,
            pwdName: name,
            pwd: pwd,
            isAdmin: _isAdmin,
            hardwareId: addRes.hardwareId,
          );
          break;
        case 1:
          result = await createCustomPassword(
            deviceId: widget.deviceId,
            pwdName: name,
            pwd: pwd,
            start: _start,
            end: _end,
            weeks: List<int>.from(_weeks),
            isRb: _isRb,
            pwdLength: _tempPwdLength,
          );
          break;
        case 2:
          result = await createOfflineLimit(
            deviceId: widget.deviceId,
            pwdName: name,
            start: _start,
            end: _end,
          );
          break;
        case 3:
          result = await createOfflineSingle(
            deviceId: widget.deviceId,
            pwdName: name,
          );
          break;
        case 4:
          result = await createOfflineLoop(
            deviceId: widget.deviceId,
            pwdName: name,
            startHour: _startHour,
            endHour: _endHour,
            weeks: List<int>.from(_weeks),
          );
          break;
      }
      _hideLoading();
      if (!mounted) return;
      await _showResultDialog(result, tab);
      if (mounted) Navigator.of(context).pop(true);
    } on CreatePwdException catch (e) {
      _hideLoading();
      _showSnack(e.message);
    } catch (e) {
      _hideLoading();
      LogUtils.doorLock.log('生成密码失败: $e');
      _showSnack('生成失败: $e');
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  ///离线密码未同步提示（去同步/取消）
  Future<bool?> _confirmOfflineSync() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('提示'),
        content: const Text('设备基准时间/密钥尚未同步完成，'
            '生成的离线密码可能无法正常使用，请先完成设备同步。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('去同步'),
          ),
        ],
      ),
    );
  }

  ///"去同步"：重连蓝牙重新下发离线密钥组并同步JVSS基准年
  ///逻辑与配对流程的门锁初始化一致，成功后写回内存状态并上报服务器
  Future<bool> _syncOfflineBase() async {
    final deviceId = widget.deviceId;
    final device = _device;

    final blueUUID = DoorLockHelper.getBlueUUID(deviceId);
    if (blueUUID == null) {
      _showSnack('未找到设备蓝牙标识，请靠近设备后重试');
      return false;
    }

    _showLoading('正在同步...');
    final api = DoorLockBleApi(uuid: blueUUID, activeSn: deviceId);
    bool keySynced = true;
    bool yearSynced = false;
    try {
      final ready = await api.bleObject.waitReadyIfNeed();
      if (!ready.item1) {
        _hideLoading();
        _showSnack('蓝牙连接失败，请靠近设备后重试');
        return false;
      }

      ///重新下发离线密钥组（锁端明确不支持离线密码时跳过）
      if (device?.doorLockExInfo?.byte1.supportLockEndOffLinePwd != false) {
        keySynced = false;
        try {
          final result = await doorlockAPI.getKeyPair(deviceSn: deviceId);
          if (result is List) {
            final keyPair = result.join().replaceAll(':', '');
            final sendCallBack = await api.sendKeyPair(1, keyPair);
            if (sendCallBack != null) {
              keySynced = sendCallBack.item1;
              if (!sendCallBack.item1 && sendCallBack.item2.first == 2) {
                ///密钥组回退
                try {
                  await doorlockAPI.rollBackKeyPair(deviceSn: deviceId);
                  keySynced = true;
                } catch (e) {
                  LogUtils.doorLock.log('去同步回退密钥组失败: $e');
                }
              }
            }
          } else {
            LogUtils.doorLock.log('去同步获取密钥组返回异常: $result');
          }
        } catch (e) {
          keySynced = false;
          LogUtils.doorLock.log('去同步密钥组异常: $e');
        }
      }

      ///同步JVSS基准年
      try {
        final year = DateTime.now().year;
        await doorlockAPI.addOrUpdateDeviceYear(
            deviceSn: deviceId, activeYear: year, pwdYear: year);
        yearSynced = true;
      } catch (e) {
        LogUtils.doorLock.log('去同步基准年失败: $e');
      }
    } catch (e) {
      LogUtils.doorLock.log('去同步异常: $e');
    } finally {
      _hideLoading();
    }

    ///同步结果写回内存Device并上报服务器
    if (device != null) {
      device.keySyncState = keySynced;
      device.yearSyncState = yearSynced;
    }
    try {
      await DoorLockHelper.instance.uploadJvssConfig(
        deviceId,
        {},
        yearSyncState: yearSynced,
        keySyncState: keySynced,
      );
    } catch (e) {
      LogUtils.doorLock.log('去同步上报同步状态失败: $e');
    }
    if (mounted) setState(() {});

    if (keySynced && yearSynced) {
      _showSnack('同步成功');
      return true;
    }
    _showSnack('同步失败，请靠近设备后重试');
    return false;
  }

  ///生成结果弹窗
  Future<void> _showResultDialog(String pwd, int tab) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('${_tabTitles[tab]}密码生成成功'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(pwd,
                style: const TextStyle(
                    fontSize: 32,
                    color: Color(0xFF00B294),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2)),
            const SizedBox(height: 16),
            Text(_resultSummary(tab),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF7F7F7F))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: pwd));
              _showSnack('密码已复制');
            },
            child: const Text('复制'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  ///结果弹窗的有效期摘要
  String _resultSummary(int tab) {
    final name = _nameCtrl.text.trim();
    switch (tab) {
      case 0:
        return '$name · 永久有效';
      case 1:
        final weekStr = _weekStr();
        return '$name\n${DateFormat('yyyy-MM-dd HH:mm').format(_start)} ~ '
            '${DateFormat('yyyy-MM-dd HH:mm').format(_end)}\n重复：$weekStr';
      case 2:
        return '$name\n${DateFormat('yyyy-MM-dd HH:mm').format(_start)} ~ '
            '${DateFormat('yyyy-MM-dd HH:mm').format(_end)}';
      case 3:
        return '$name · 单次有效\n请在 6 小时内使用';
      case 4:
        return '$name\n${_startHour.toString().padLeft(2, '0')}:00 ~ '
            '${_endHour.toString().padLeft(2, '0')}:00\n重复：${_weekStr()}';
    }
    return name;
  }

  ///星期文案（0=周日）
  String _weekStr() {
    const labels = ['日', '一', '二', '三', '四', '五', '六'];
    if (_weeks.length == 7) return '每天';
    final sorted = List<int>.from(_weeks)..sort();
    return sorted.map((d) => '周${labels[d]}').join('、');
  }

  // ==================== UI 辅助 ====================

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  void _showLoading(String msg) {
    _loadingShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(msg)),
          ],
        ),
      ),
    );
  }

  void _hideLoading() {
    if (_loadingShown && mounted) {
      Navigator.of(context).pop();
      _loadingShown = false;
    }
  }
}

///密码首位固定为 1 的输入格式化器（几维协议临时密码规则）
///空输入回退为 "1"，首位非 1 时强制改回 1，用户无法删除或修改首位。
class _PrefixOneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) {
      return const TextEditingValue(
          text: '1', selection: TextSelection.collapsed(offset: 1));
    }
    if (text[0] != '1') {
      final fixed = '1${text.substring(1)}';
      final offset = newValue.selection.end.clamp(0, fixed.length);
      return TextEditingValue(
          text: fixed, selection: TextSelection.collapsed(offset: offset));
    }
    return newValue;
  }
}
