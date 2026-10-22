import 'dart:async';

import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/api/door_lock_api.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/door_user.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/temp_password.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/unlock_info.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/user_manager/door_lock_create_password_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/user_manager/door_lock_temp_pwd_detail_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/user_manager/door_lock_unlock_info_detail_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/user_manager/door_lock_user_detail_page.dart';
import 'package:flutter/material.dart';

///门锁密码管理列表页
///
///[type] 为 [JvssOperateType.tmpPassword] 时为临时密码模式：
///仅拉取/展示临时密码（服务器数据，无昵称回填/锁端补全/从锁端拉取）。
class DoorLockPasswordListPage extends StatefulWidget {
  final String deviceId;

  ///列表类型：password 密码混合列表 / tmpPassword 仅临时密码
  final JvssOperateType type;

  const DoorLockPasswordListPage(
      {super.key,
      required this.deviceId,
      this.type = JvssOperateType.password});

  @override
  State<DoorLockPasswordListPage> createState() =>
      _DoorLockPasswordListPageState();
}

class _DoorLockPasswordListPageState extends State<DoorLockPasswordListPage> {
  ///是否临时密码模式（仅展示临时密码）
  bool get _isTmpPwd => widget.type == JvssOperateType.tmpPassword;

  ///密码列表（混合：自定义密码 [DoorUser] + 离线密码 [UnlockInfo]
  List<dynamic> _userList = [];

  ///加载中
  bool _loading = true;

  ///操作进行中（防止重复点击）
  bool _operating = false;

  ///loading 弹框是否显示中
  bool _loadingShown = false;

  ///锁端拉取串行锁：BLE 透传回包无法区分是哪个查询的响应，
  ///两个拉取并发会互相截胡回包导致数据残缺（如全量只拿到后结束那条
  ///单类型查询的数据），须排队串行执行
  Future<void>? _lockEndSyncLock;

  ///错误信息（拉取失败时展示）
  String? _errorMsg;

  Device? get _device =>
      DeviceManager.instance.getDevice(deviceId: widget.deviceId);

  ///门锁操作对象：提供按设备通道（BLE/netip）自动路由的删除能力
  DoorLockOperationObject? _op;
  DoorLockOperationObject get _operation => _op ??=
      DoorLockOperationObject(deviceId: widget.deviceId, keepAlive: true);

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  @override
  void dispose() {
    _op?.dispose();
    super.dispose();
  }

  // ==================== 列表加载 ====================

  ///1. 先从服务器 [doorlockAPI.getAllPwd] 拉取并渲染（快速可见）
  ///2. 昵称拉取与锁端补全并行（纯服务器接口不等锁端长耗时流程，避免昵称延迟回填）
  ///3. 设备在线时，静默从锁端拉全量密码用户 updateAll 上报服务器（补全缺失数据）
  ///4. 上报后再次从服务器刷新列表（列表对象重建，昵称再回填一次）
  Future<void> _loadList() async {
    final ok = await _fetchFromServer();
    if (!ok || !mounted) return;

    ///临时密码为服务器数据，无昵称回填/锁端补全流程
    if (_isTmpPwd) return;

    ///昵称纯服务器接口，立即并行拉取回填，不等待锁端补全
    unawaited(_fetchNicknames());

    ///仅设备在线时做锁端补全（离线拉不到锁端数据）
    final device = _device;
    if (device != null && device.doolockCmdStatus != DoolockCmdStatus.offline) {
      await getLockEndUnlocking();
      if (!mounted) return;
      await _fetchFromServer(showLoading: false);
      if (!mounted) return;

      ///刷新后列表对象为新建（无昵称），需再回填
      await _fetchNicknames();
    }
  }

  ///从昵称服务拉取用户昵称并按 UserId 匹配回填密码用户
  ///
  ///昵称不在 getAllPwd（doorLockUserInfoVOS）返回内，写入端为录入上报与
  ///详情页修改（insertOrUpdate）；返回 Map 以开锁方式类型字符串为 key
  ///（如 PassWdManger），值为 [{UserId, NickName, HeadPortrait}] 列表。
  Future<void> _fetchNicknames() async {
    try {
      final res = await doorlockAPI.queryAlarmMessageNickName(
        deviceSn: widget.deviceId,
      );
      if (!mounted || res is! Map) return;
      final list = res[JvssOperateType.password.toJvssString()];
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
        if (user is! DoorUser) continue;
        final record = nickMap[user.id];
        if (record == null) continue;
        final name = record['NickName']?.toString() ?? '';
        final head = record['HeadPortrait']?.toString() ?? '';

        ///昵称服务存在写读延迟，空记录不覆盖本地非空昵称
        if (name.isEmpty && (user.userNickName ?? '').isNotEmpty) continue;

        if (user.userNickName != name || user.userHeadPortrait != head) {
          user.userNickName = name;
          user.userHeadPortrait = head;
          changed = true;
        }
      }
      if (changed) setState(() {});
    } catch (e) {
      ///昵称拉取失败不影响列表展示，仅日志
      LogUtils.doorLock.log('密码用户昵称拉取异常: $e');
    }
  }

  ///从服务器拉取密码列表并渲染，返回是否成功
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
      final List<dynamic> list = [];

      ///① 自定义密码（临时密码模式下不拉取）
      if (!_isTmpPwd && res is Map && res['doorLockUserInfoVOS'] is List) {
        for (final e in (res['doorLockUserInfoVOS'] as List)) {
          if (e is Map<String, dynamic>) {
            final user = DoorUser.fromJson(e);

            if (user.type == JvssOperateType.password.value) {
              list.add(user);
            }
          }
        }
      }

      ///② 临时密码
      ///（临时密码模式下不限定低功耗锁；密码模式下维持原低功耗限定）
      if (res is Map &&
          (_isTmpPwd || DoorLockHelper.isLowPowerBle(widget.deviceId)) &&
          res['jsonObject'] is Map &&
          (res['jsonObject'] as Map)['tpswd'] is Map &&
          ((res['jsonObject'] as Map)['tpswd'] as Map)['list'] is List) {
        for (final e in ((((res['jsonObject'] as Map)['tpswd'] as Map)['list'])
            as List)) {
          if (e is Map<String, dynamic>) {
            list.add(TempPassword.fromJson(e));
          }
        }
      }

      ///③ 离线密码（临时密码模式下不拉取）
      if (!_isTmpPwd &&
          res is Map &&
          res['unlockInfoList'] is Map &&
          (res['unlockInfoList'] as Map)['data'] is List) {
        for (final e in ((res['unlockInfoList'] as Map)['data'] as List)) {
          if (e is Map<String, dynamic>) {
            list.add(UnlockInfo.fromJson(e));
          }
        }
      }

      ///按类型 + Id 去重：服务器在 add/updateAll 写入后的读延迟期间，
      ///同一密码可能返回新旧两条记录，直接渲染会短暂出现重复 item
      final seenIds = <String>{};
      list.retainWhere((e) {
        String key;
        if (e is DoorUser) {
          key = 'pwd_${e.id}';
        } else if (e is TempPassword) {
          key = 'tmp_${e.id}';
        } else if (e is UnlockInfo) {
          key = 'offline_${e.id}';
        } else {
          return true;
        }
        if (seenIds.contains(key)) return false;
        seenIds.add(key);
        return true;
      });
      ///按 id 迁移旧列表的昵称/头像：刷新会重建 DoorUser 对象
      ///（昵称不在 getAllPwd 返回内），不迁移会闪回"用户xx"占位
      final oldUsers = <int, DoorUser>{};
      for (final e in _userList) {
        if (e is DoorUser) oldUsers[e.id] = e;
      }
      for (final e in list) {
        if (e is! DoorUser) continue;
        final old = oldUsers[e.id];
        if (old == null) continue;
        if ((old.userNickName ?? '').isNotEmpty) {
          e.userNickName = old.userNickName;
          e.userHeadPortrait = old.userHeadPortrait;
        }
      }

      setState(() {
        _userList = list;
        _loading = false;
        _errorMsg = null;
      });
      return true;
    } catch (e) {
      LogUtils.doorLock.log('密码列表拉取异常: $e');
      if (!mounted) return false;
      setState(() {
        _errorMsg = '拉取失败: $e';
        _loading = false;
      });
      return false;
    }
  }

  // ==================== 从锁端拉数据 ====================

  ///从锁端拉取开锁方式并 updateAll 上报服务器
  ///
  ///进页面静默补全（[isAll]=false，只拉密码）与右上角“从锁端拉数据”
  ///（[isAll]=true，按能力集全量拉）共用此入口：先等上一次拉取结束
  ///再发起，避免并发回包串扰。按设备通道路由（BLE 直连 / netip）
  ///读取，60s 超时保护，失败/超时返回空列表不阻塞
  Future<List<DoorUser>> getLockEndUnlocking({bool isAll = false}) {
    final prev = _lockEndSyncLock;
    final task = prev == null
        ? _doGetLockEndUnlocking(isAll: isAll)
        : prev.then((_) => _doGetLockEndUnlocking(isAll: isAll));
    _lockEndSyncLock = task.then((_) {}, onError: (_) {});
    return task;
  }

  Future<List<DoorUser>> _doGetLockEndUnlocking({bool isAll = false}) async {
    try {
      final lockUsers = await _operation
          .getLockEndUnlockingList(
              type: isAll ? null : JvssOperateType.password)
          .timeout(const Duration(seconds: 60));
      if (lockUsers.isEmpty) {
        LogUtils.doorLock.log('从锁端拉数据: 锁端无用户，跳过上报(isAll=$isAll)');
        return [];
      }
      await doorlockAPI.saveDoorLockUser(
        sn: widget.deviceId,
        users: lockUsers.map((e) => e.toMap()).toList(),
        operationStr: JvssOperationAction.updateAll.value,
        userTypes: isAll ? null : [JvssOperateType.password.value],
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

  ///右上角“从锁端拉数据”：确认后全量拉锁端开锁方式 + updateAll 上报 + 刷新列表
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
    final list = await getLockEndUnlocking(isAll: true);
    _hideLoading();
    if (!mounted) return;

    ///拉取失败/超时（空列表）不动现有列表，避免误清空
    if (list.isEmpty) {
      setState(() => _operating = false);
      _showSnack('锁端无数据或拉取失败');
      return;
    }

    ///不回读服务器，直接用锁端结果更新列表的自定义密码(DoorUser)部分：
    ///移除旧 DoorUser 后头部插入密码类型用户；临时密码/离线密码来自服务器，
    ///锁端拉取不涉及，保留不动。
    final pwdUsers =
        list.where((e) => e.type == JvssOperateType.password.value).toList();

    ///锁端对象无昵称（昵称在独立服务器），先把旧列表内已回填的昵称/头像
    ///按 id 迁移到新对象，避免替换瞬间回退成“用户x”
    final oldNickMap = <int, DoorUser>{};
    for (final e in _userList) {
      if (e is DoorUser) {
        oldNickMap[e.id] = e;
      }
    }
    for (final user in pwdUsers) {
      final old = oldNickMap[user.id];
      if (old == null) continue;
      if (old.userNickName != null && old.userNickName!.isNotEmpty) {
        user.userNickName = old.userNickName;
        user.userHeadPortrait = old.userHeadPortrait;
      }
    }

    setState(() {
      _operating = false;
      _userList.removeWhere((e) => e is DoorUser);
      _userList.insertAll(0, pwdUsers);
    });

    ///锁端拉取期间用户可能已在详情页改过昵称，再异步拉一次昵称服务兜底
    unawaited(_fetchNicknames());
  }

  // ==================== 生成密码 ====================

  ///点击“生成密码”：跳转生成密码页（永久/自定义/限时/单次/循环；
  ///临时密码模式仅自定义 Tab），成功后刷新列表
  Future<void> _onCreatePassword() async {
    if (_operating) return;
    if (_device == null) {
      _showSnack('设备不存在');
      return;
    }
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DoorLockCreatePasswordPage(
          deviceId: widget.deviceId,
          type: widget.type,
        ),
      ),
    );
    if (created == true && mounted) {
      await _loadList();
    }
  }

  // ==================== 删除密码 ====================

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
        title: const Text('删除密码'),
        content: Text('确定删除“${user.displayTitle}”的密码吗？'
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
        JvssOperateType.password,
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
      LogUtils.doorLock.log('删除密码异常: $e');
      _showSnack('删除异常: $e');
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }

  // ==================== 离线密码删除 ====================

  ///删除离线密码
  ///
  ///流程：确认框 → doorLockDeleteType(offLinePwd, hardwareId) 按通道删锁端
  ///→ 服务器 deleteUnlockInfo(id) → 刷新。锁端删除用 hardwareId，服务器删除用记录 id。
  Future<void> _onDeleteUnlockInfo(UnlockInfo info) async {
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
        title: const Text('删除离线密码'),
        content: Text('确定删除“${info.displayTitle}”的离线密码吗？'),
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
      ///锁端删除（按通道路由 BLE/netip；type=offLinePwd，id=hardwareId）
      var result = await _operation.doorLockDeleteType(
        info.hardwareIdInt,
        JvssOperateType.offLinePwd,
        info.isAdmin,
      );
      if (result.success) {
        ///服务器删除（失败不阻塞，锁端已删）
        try {
          await doorlockAPI.deleteUnlockInfo(id: info.id);
        } catch (e) {
          LogUtils.doorLock.log('离线密码服务器删除失败: $e');
        }
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
      LogUtils.doorLock.log('删除离线密码异常: $e');
      _showSnack('删除异常: $e');
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }

  ///离线密码列表项 UI
  Widget _buildUnlockInfoTile(UnlockInfo info) {
    final status = info.isValidDescription;
    final sub = info.displaySubTitle;
    return ListTile(
      title: Text(info.displayTitle),

      ///副标题为空（如永久类型）时不显示
      subtitle: sub.isNotEmpty ? Text(sub) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status.isNotEmpty)
            Text(status,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: '删除',
            onPressed: _operating ? null : () => _onDeleteUnlockInfo(info),
          ),
          const Icon(Icons.chevron_right, size: 20, color: Color(0xFFCCCCCC)),
        ],
      ),

      ///点击进入离线密码详情页
      onTap: _operating ? null : () => _onUnlockInfoTap(info),
    );
  }

  // ==================== 临时密码 ====================

  ///临时密码列表项 UI（昵称 + 有效期副标题 + 同步状态 + 删除）
  Widget _buildTempPwdTile(TempPassword tp) {
    final status = tp.statusDescription;
    return ListTile(
      title: Text(tp.displayTitle),
      subtitle: Text(tp.validTimeText),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status.isNotEmpty)
            Text(status,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: '删除',
            onPressed: _operating ? null : () => _onDeleteTempPwd(tp),
          ),
          const Icon(Icons.chevron_right, size: 20, color: Color(0xFFCCCCCC)),
        ],
      ),

      ///点击查看临时密码详情（密码串 + 有效期 + 重复 + 用户类型）
      onTap: _operating ? null : () => _onTempPwdTap(tp),
    );
  }

  ///点击临时密码项：跳转详情页
  ///（临时密码为服务器计算密码，需明文展示给用户分享）
  ///详情页保存昵称时会直接改写传入的 TempPassword 对象，
  ///返回后 setState 触发 rebuild 即可看到新昵称，无需重新拉取服务器。
  Future<void> _onTempPwdTap(TempPassword tp) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoorLockTempPwdDetailPage(info: tp),
      ),
    );
    if (mounted) setState(() {});
  }

  ///删除临时密码
  ///
  ///临时密码为服务器计算密码，仅需删服务器记录（deleteTmpPassword），
  ///无需锁端交互/保活（区别于自定义密码 [DoorUser] 和离线密码 [UnlockInfo]）。
  Future<void> _onDeleteTempPwd(TempPassword tp) async {
    if (_operating) return;
    if (_device == null) {
      _showSnack('设备不存在');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除临时密码'),
        content: Text('确定删除“${tp.displayTitle}”的临时密码吗？'),
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
      await doorlockAPI.deleteTmpPassword(
        id: tp.id,
        deviceSn: widget.deviceId,
      );
      _hideLoading();
      _showSnack('删除成功');
      await _loadList();
    } catch (e) {
      _hideLoading();
      LogUtils.doorLock.log('删除临时密码异常: $e');
      _showSnack('删除失败: $e');
    } finally {
      if (mounted) setState(() => _operating = false);
    }
  }

  // ==================== 用户详情跳转 ====================

  ///点击密码用户项进入详情页
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

  ///点击离线密码项进入详情页
  ///
  ///详情页保存昵称时会直接修改传入的 [UnlockInfo.name]，
  ///因此返回后仅需 setState 触发 rebuild 即可看到新昵称，无需重新拉取服务器。
  Future<void> _onUnlockInfoTap(UnlockInfo info) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoorLockUnlockInfoDetailPage(
          info: info,
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
        userTypes: [JvssOperateType.password.value],
      );
    } catch (e) {
      ///上报失败不阻塞主流程，仅日志
      LogUtils.doorLock.log('密码用户上报服务器失败 action=${action.value}: $e');
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
        content: const Text('同步状态过期，请返回后重新进入密码管理页。'),
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
        title: Text(_isTmpPwd ? '临时密码管理' : '密码管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dialpad),
            tooltip: '生成密码',
            onPressed: _operating ? null : _onCreatePassword,
          ),

          ///临时密码为服务器数据，无锁端拉取入口
          if (!_isTmpPwd)
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: '从锁端拉数据',
              onPressed: _operating ? null : _onSyncFromLockEnd,
            ),
        ],
      ),
      body: _buildBody(),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_isTmpPwd ? Icons.timelapse : Icons.lock_open,
                size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_isTmpPwd ? '暂无临时密码，点击右上角"生成密码"添加' : '暂无密码，点击右上角"生成密码"添加',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: _userList.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _userList[index];

        ///离线密码走独立渲染分支
        if (item is UnlockInfo) {
          return _buildUnlockInfoTile(item);
        }

        ///临时密码走独立渲染分支
        if (item is TempPassword) {
          return _buildTempPwdTile(item);
        }
        final user = item as DoorUser;
        return ListTile(
          ///主标题：昵称（管理员时追加后缀）；副标题：有效期具体文案（含循环时段）
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
          ///详情页保存昵称时会直接修改传入的 DoorUser 对象，返回后 setState 即可刷新
          onTap: _operating ? null : () => _onUserTap(user),
        );
      },
    );
  }
}
