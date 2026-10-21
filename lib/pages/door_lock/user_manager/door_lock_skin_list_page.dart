import 'dart:async';

import 'package:fcloudsdk/door_lock/door_lock_ble_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_key_value.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/api/door_lock_api.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/door_user.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/user_manager/add_door_lock_user_guide_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/user_manager/add_door_lock_vaild_time_sel_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/user_manager/door_lock_user_detail_page.dart';
import 'package:flutter/material.dart';

///门锁指纹管理列表页
///
///- 列表：服务器 getAllPwd 过滤指纹用户，在线时静默从锁端拉指纹用户 updateAll 补全
///- 删除：按通道路由（BLE/netip）删锁端 → 服务器 del 上报
///- 添加：底部按钮进录入引导页（普通/管理员）
///- 详情：复用用户详情页（昵称编辑走 FingerManger）
class DoorLockSkinListPage extends StatefulWidget {
  final String deviceId;

  const DoorLockSkinListPage({super.key, required this.deviceId});

  @override
  State<DoorLockSkinListPage> createState() => _DoorLockSkinListPageState();
}

class _DoorLockSkinListPageState extends State<DoorLockSkinListPage> {
  static const JvssOperateType _type = JvssOperateType.skin;

  ///指纹用户列表
  List<DoorUser> _userList = [];

  ///加载中
  bool _loading = true;

  ///操作进行中（防止重复点击）
  bool _operating = false;

  ///loading 弹框是否显示中
  bool _loadingShown = false;

  ///错误信息（拉取失败时展示）
  String? _errorMsg;

  Device? get _device =>
      DeviceManager.instance.getDevice(deviceId: widget.deviceId);

  ///门锁操作对象：提供按设备通道（BLE/netip）自动路由的删除能力
  DoorLockOperationObject? _op;
  DoorLockOperationObject get _operation => _op ??=
      DoorLockOperationObject(deviceId: widget.deviceId, keepAlive: true);

  ///是否显示"添加管理员用户"按钮（能力集支持且非分享设备）
  bool _supportAddAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadList();
    _getAdminAbility();
  }

  @override
  void dispose() {
    _op?.dispose();
    super.dispose();
  }

  // ==================== 列表加载 ====================

  ///1. 先从服务器拉取指纹用户并渲染（快速可见）
  ///2. 昵称拉取与锁端补全并行（纯服务器接口不等锁端长耗时流程，避免昵称延迟回填）
  ///3. 设备在线时，静默从锁端拉指纹用户 updateAll 上报服务器（补全缺失数据）
  ///4. 上报后再次从服务器刷新列表（列表对象重建，昵称再回填一次）
  Future<void> _loadList() async {
    final ok = await _fetchFromServer();
    if (!ok || !mounted) return;

    ///昵称纯服务器接口，立即并行拉取回填，不等待锁端补全
    unawaited(_fetchNicknames());

    ///仅设备在线时做锁端补全（离线拉不到锁端数据）
    final device = _device;
    if (device != null && device.doolockCmdStatus != DoolockCmdStatus.offline) {
      await _syncLockEndToServer();
      if (!mounted) return;
      await _fetchFromServer(showLoading: false);
      if (!mounted) return;

      ///刷新后列表对象为新建（无昵称），需再回填
      await _fetchNicknames();
    }
  }

  ///从昵称服务拉取用户昵称并按 UserId 匹配回填列表
  ///
  ///昵称不在 getAllPwd（doorLockUserInfoVOS）返回内，写入端为录入上报与
  ///详情页修改（insertOrUpdate）；返回 Map 以开锁方式类型字符串为 key
  ///（如 FingerManger），值为 [{UserId, NickName, HeadPortrait}] 列表。
  Future<void> _fetchNicknames() async {
    try {
      final res = await doorlockAPI.queryAlarmMessageNickName(
        deviceSn: widget.deviceId,
      );
      if (!mounted || res is! Map) return;
      final list = res[_type.toJvssString()];
      if (list is! List) return;

      ///UserId → 昵称记录
      final nickMap = <int, Map<String, dynamic>>{};
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          final id = int.tryParse('${e['UserId'] ?? ''}');
          if (id != null) nickMap[id] = e;
        }
      }

      var changed = false;
      for (final user in _userList) {
        final record = nickMap[user.id];
        if (record == null) continue;
        final name = record['NickName']?.toString() ?? '';
        final head = record['HeadPortrait']?.toString() ?? '';
        if (user.userNickName != name || user.userHeadPortrait != head) {
          user.userNickName = name;
          user.userHeadPortrait = head;
          changed = true;
        }
      }
      if (changed) setState(() {});
    } catch (e) {
      ///昵称拉取失败不影响列表展示，仅日志
      LogUtils.doorLock.log('指纹用户昵称拉取异常: $e');
    }
  }

  ///从服务器拉取指纹用户并渲染，返回是否成功
  Future<bool> _fetchFromServer({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _loading = true;
        _errorMsg = null;
      });
    }
    try {
      final res = await doorlockAPI.getAllPwd(
        sn: {'sn': widget.deviceId},
        deviceSn: {'deviceSn': widget.deviceId},
        unlockInfo: {'deviceSn': widget.deviceId, 'page': 1, 'limit': 50},
      );
      if (!mounted) return false;

      final List<DoorUser> list = [];
      if (res is Map && res['doorLockUserInfoVOS'] is List) {
        for (final e in (res['doorLockUserInfoVOS'] as List)) {
          if (e is Map<String, dynamic>) {
            final user = DoorUser.fromJson(e);

            ///只取指纹类型用户
            if (user.type == _type.value) {
              list.add(user);
            }
          }
        }
      }
      setState(() {
        _userList = list;
        _loading = false;
        _errorMsg = null;
      });
      return true;
    } catch (e) {
      LogUtils.doorLock.log('指纹列表拉取异常: $e');
      if (!mounted) return false;
      setState(() {
        _errorMsg = '拉取失败: $e';
        _loading = false;
      });
      return false;
    }
  }

  // ==================== 从锁端拉数据 ====================

  ///从锁端拉取指纹用户并 updateAll 上报服务器
  ///
  ///进页面静默补全与右上角"从锁端拉数据"（全量按能力集拉）共用。
  ///按设备通道路由（BLE 直连 / netip）读取，60s 超时保护，失败/超时返回空列表不阻塞
  Future<List<DoorUser>> _syncLockEndToServer({bool isAll = false}) async {
    try {
      final lockUsers = await _operation
          .getLockEndUnlockingList(type: isAll ? null : _type)
          .timeout(const Duration(seconds: 60));
      if (lockUsers.isEmpty) {
        LogUtils.doorLock.log('从锁端拉数据: 锁端无用户，跳过上报(isAll=$isAll)');
        return [];
      }
      await doorlockAPI.saveDoorLockUser(
        sn: widget.deviceId,
        users: lockUsers.map((e) => e.toMap()).toList(),
        operationStr: JvssOperationAction.updateAll.value,
        userTypes: isAll ? null : [_type.value],
      );
      LogUtils.doorLock
          .log('从锁端拉数据: 上报 ${lockUsers.length} 条用户到服务器(isAll=$isAll)');
      return lockUsers;
    } on TimeoutException {
      LogUtils.doorLock.log('从锁端拉数据超时（60s），跳过');
      return [];
    } catch (e) {
      LogUtils.doorLock.log('从锁端拉数据异常: $e');
      return [];
    }
  }

  ///右上角"从锁端拉数据"：确认后全量拉锁端开锁方式 + updateAll 上报 + 刷新列表
  Future<void> _onSyncFromLockEnd() async {
    if (_operating) return;
    if (_device == null) {
      _showSnack('设备不存在');
      return;
    }
    if (_device!.doolockCmdStatus == DoolockCmdStatus.offline) {
      _showSnack('设备离线，无法从锁端拉取');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('从锁端拉数据'),
        content: const Text('将从锁端读取全部开锁方式并同步到服务器，可能耗时较长，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _operating = true);
    _showLoading('正在从锁端拉取数据...');
    final list = await _syncLockEndToServer(isAll: true);
    _hideLoading();
    if (!mounted) return;

    ///拉取失败/超时（空列表）不动现有列表，避免误清空
    if (list.isEmpty) {
      setState(() => _operating = false);
      _showSnack('锁端无数据或拉取失败');
      return;
    }

    ///不回读服务器，直接用锁端结果替换列表的指纹用户部分
    final skinUsers = list.where((e) => e.type == _type.value).toList();
    setState(() {
      _operating = false;
      _userList = skinUsers;
    });
  }

  // ==================== 管理员能力集 ====================

  ///在线时从锁端拉取管理员能力集（GetAdminAbility），控制"添加管理员"按钮显隐
  ///
  ///低功耗锁由影子服务获取；离线/已有时跳过。结果同时缓存本地与服务器 key-value。
  Future<void> _getAdminAbility() async {
    if (DoorLockHelper.isLowPowerBle(widget.deviceId)) {
      _refreshSupportAddAdmin();
      return;
    }
    final device = _device;
    if (device == null ||
        device.doolockCmdStatus == DoolockCmdStatus.offline) {
      _refreshSupportAddAdmin();
      return;
    }

    try {
      if (await _operation.beforeNetIp(showLoading: false) == false) {
        _refreshSupportAddAdmin();
        return;
      }
      var result = await DoorLockNetIp.getAdminAbility(deviceId: widget.deviceId);
      if (result.item2 != null) {
        var mask = result.item2!.data['TypeMsk']?.toString() ?? '';
        if (mask.isNotEmpty) {
          DoorLockKeyValueLocal.saveUserManagerAdminAbility(
              widget.deviceId, mask);
          DoorLockKeyValueService.post(
              sn: widget.deviceId,
              key: 'userManagerAdminAbility',
              value: mask);
          if (device.doorManagerAbility == null) {
            var origin = hexToBytes(mask);
            if (origin.isNotEmpty) {
              device.doorManagerAbility =
                  DoorManagerAbility.fromValues(origin.reversed.toList());
            }
          }
        }
      }
    } catch (e) {
      LogUtils.doorLock.log('获取管理员能力集异常: $e');
    } finally {
      _refreshSupportAddAdmin();
    }
  }

  void _refreshSupportAddAdmin() {
    if (!mounted) return;
    setState(() {
      _supportAddAdmin = DoorLockHelper.supportAddAdmin(
          deviceId: widget.deviceId, type: _type);
    });
  }

  // ==================== 添加指纹 ====================

  ///是否支持普通用户限时/循环/归属（doorLockExInfo.byte2 能力位）
  bool _supportTimeLimitAndBelong() {
    return _device?.doorLockExInfo?.byte2.supportLockUserLimitCycleGroup ==
        true;
  }

  ///点击"添加用户/添加管理员"：跳转录入引导页，成功后刷新列表
  ///
  ///- 普通用户且设备支持限时/循环：先进时效选择页（昵称+永久/限时/循环）
  ///- 其余：直接进录入引导页（永久）
  ///深度休眠的锁无法唤醒录入，直接提示。
  Future<void> _onAddPressed(bool isAdmin) async {
    if (_operating) return;
    final device = _device;
    if (device == null) {
      _showSnack('设备不存在');
      return;
    }
    if (device.doolockCmdStatus == DoolockCmdStatus.offline &&
        device.sleepState == DeviceSleepState.deepSleep) {
      _showSnack('设备深度休眠，无法唤醒录入');
      return;
    }

    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => !isAdmin && _supportTimeLimitAndBelong()
            ? AddDoorLockVaildTimeSelPage(
                deviceId: widget.deviceId,
                addType: 1,
                type: _type,
              )
            : AddDoorLockUserGuidePage(
                deviceId: widget.deviceId,
                addType: isAdmin ? 0 : 1,
                type: _type,
              ),
      ),
    );
    if (added == true && mounted) {
      await _loadList();
    }
  }

  // ==================== 删除指纹 ====================

  ///点击删除：先弹确认框
  Future<void> _onDeletePressed(DoorUser user) async {
    if (_operating) return;
    if (_device == null) {
      _showSnack('设备不存在');
      return;
    }
    if (_device!.doolockCmdStatus == DoolockCmdStatus.offline) {
      _showSnack('设备离线，无法删除');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除指纹'),
        content: Text('确定删除"${user.displayTitle}"的指纹吗？'
            '${user.isAdmin ? '\n（该用户为管理员）' : ''}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _operating = true);
    _showLoading('正在删除...');
    try {
      var result = await _operation.doorLockDeleteType(
        user.id,
        _type,
        user.isAdmin,
      );
      if (result.success) {
        ///上报服务器
        await _saveUserToServer(
          action: JvssOperationAction.del,
          users: [
            {'Id': user.id, 'Type': user.type, 'Auth': user.auth}
          ],
        );
        _hideLoading();
        _showSnack('删除成功');
        await _loadList();
      } else {
        _hideLoading();
        if (result.err == DoorLockNetIpOperaterResult.needSync) {
          await _showSyncStatusExpiredDialog();
        } else {
          _showSnack('删除失败: ${_netIpErrMsg(result.err, result.rawError)}');
        }
      }
    } catch (e) {
      _hideLoading();
      LogUtils.doorLock.log('删除指纹异常: $e');
      _showSnack('删除异常: $e');
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }

  // ==================== 用户详情跳转 ====================

  ///点击指纹用户项进入详情页
  ///
  ///详情页保存昵称时会直接修改传入的 DoorUser 对象，返回后 setState 即可刷新
  Future<void> _onUserTap(DoorUser user) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoorLockUserDetailPage(
          user: user,
          deviceId: widget.deviceId,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  // ==================== 服务器上报 ====================

  ///上报门锁用户信息到服务器
  Future<void> _saveUserToServer({
    required JvssOperationAction action,
    required List<Map<String, dynamic>> users,
  }) async {
    try {
      await doorlockAPI.saveDoorLockUser(
        sn: widget.deviceId,
        users: users,
        operationStr: action.value,
        userTypes: [_type.value],
      );
    } catch (e) {
      ///上报失败不阻塞主流程，仅日志
      LogUtils.doorLock.log('指纹用户上报服务器失败 action=${action.value}: $e');
    }
  }

  // ==================== UI 辅助 ====================

  String _netIpErrMsg(DoorLockNetIpOperaterResult? err, dynamic raw) {
    if (raw != null) return raw.toString();
    return err?.toString() ?? '未知错误';
  }

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

  ///同步状态过期提示
  Future<void> _showSyncStatusExpiredDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('提示'),
        content: const Text('同步状态过期，请返回后重新进入指纹管理页。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // ==================== build ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        title: const Text('指纹管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: '从锁端拉数据',
            onPressed: _operating ? null : _onSyncFromLockEnd,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  ///底部操作按钮：添加普通用户（始终显示）+ 添加管理员用户（能力集支持时显示）
  Widget _buildBottomButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 8, 15, 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton(
                onPressed: _operating ? null : () => _onAddPressed(false),
                child: const Text('添加用户'),
              ),
            ),
            if (_supportAddAdmin) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton(
                  onPressed: _operating ? null : () => _onAddPressed(true),
                  child: const Text('添加管理员用户'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadList,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }
    if (_userList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text('暂无指纹，点击下方"添加用户"录入',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      itemCount: _userList.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = _userList[index];
        return ListTile(
          tileColor: Colors.white,

          ///主标题：昵称（管理员时追加后缀）；副标题：有效期具体文案
          title: Text(user.displayTitle),
          subtitle: Text(user.displayTimeAndVaidType),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: '删除',
                onPressed: _operating ? null : () => _onDeletePressed(user),
              ),
              const Icon(Icons.chevron_right,
                  size: 20, color: Color(0xFFCCCCCC)),
            ],
          ),

          ///点击进入用户详情页
          onTap: _operating ? null : () => _onUserTap(user),
        );
      },
    );
  }
}
