import 'package:fcloudsdk/door_lock/door_lock_ble_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/api/door_lock_api.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/door_user.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:flutter/material.dart';

///添加门锁用户引导/录入页（指纹等锁端录入类开锁方式）
///
///[vaildTimeData] 来自时效选择页（普通用户限时/循环），携带昵称与时效数据：
///下发锁端时转为 timeliness hex，录入成功后随 add 一并上报服务器。
class AddDoorLockUserGuidePage extends StatefulWidget {
  final String deviceId;

  ///1普通用户 0管理员
  final int addType;

  ///开锁方式类型（指纹）
  final JvssOperateType type;

  ///时效数据（时效选择页传入；null 表示永久）
  final DoorUser? vaildTimeData;

  const AddDoorLockUserGuidePage({
    super.key,
    required this.deviceId,
    required this.addType,
    required this.type,
    this.vaildTimeData,
  });

  @override
  State<AddDoorLockUserGuidePage> createState() =>
      _AddDoorLockUserGuidePageState();
}

class _AddDoorLockUserGuidePageState extends State<AddDoorLockUserGuidePage> {
  ///门锁操作对象：录入期间保活（蓝牙连接/同步状态/登录）
  DoorLockOperationObject? _op;
  DoorLockOperationObject get _operation => _op ??=
      DoorLockOperationObject(deviceId: widget.deviceId, keepAlive: true);

  ///录入指令是否进行中（含 BLE 流式等待期间）
  bool _isAdding = false;

  ///指纹总录入次数（锁端 start 回包下发）
  int _inputAll = 0;

  ///当前已录入序号
  int _inputCurNo = 0;

  ///是否展示录入进度（录入中且总次数 >= 2）
  bool get _showInputNo => _isAdding && _inputAll >= 2;

  @override
  void initState() {
    super.initState();
    Future.microtask(_onAdd);
  }

  @override
  void dispose() {
    _op?.dispose();
    super.dispose();
  }

  ///发起录入：按设备通道路由（限时/循环仅 BLE；永久 BLE 流式 / netip 一次性）
  Future<void> _onAdd() async {
    setState(() => _isAdding = true);
    final valid = widget.vaildTimeData;
    final result = await _operation.doorLockAddOpenType(
      type: widget.type,
      isAdmin: widget.addType == 0,
      timelinessType: valid?.timelinessType,
      startTime: valid?.parseValidTime?.startTime,
      endTime: valid?.parseValidTime?.endTime,
      weeks: valid?.parseValidTime?.weeks,
      startMin: valid?.parseValidTime?.startMin,
      endMin: valid?.parseValidTime?.endMin,
      listen: _dealInputNumber,
    );
    if (!mounted) return;
    setState(() => _isAdding = false);

    if (result.success) {
      ///上报服务器（失败不阻塞退出流程）
      await _saveUserToServer(result.hardwareId);
      if (!mounted) return;
      _showSnack('录入成功');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      _showSnack('录入失败${_errSuffix(result.err, result.rawError)}');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  ///处理指纹录入进度回包
  ///
  ///- start：锁端下发总录入次数
  ///- process：error==0x00 表示本次按压成功，inputCount 为当前序号
  ///- done：录入完成，序号补齐到总数
  void _dealInputNumber(DoorLockAddBleOpenTypeResponse response) {
    switch (response.stage) {
      case BleInputStage.start:
        LogUtils.doorLock.log('收到指纹总录入次数：${response.inputCount}');
        _inputAll = response.inputCount;
        break;
      case BleInputStage.process:
        if (response.error.value == 0x00) {
          LogUtils.doorLock.log('本次指纹录入成功，当前序号：${response.inputCount}');
          _inputCurNo = response.inputCount;
        } else {
          LogUtils.doorLock.log(
              '本次指纹录入失败，当前序号：${response.inputCount}，失败原因：${response.error.value}');
        }
        break;
      case BleInputStage.done:
        LogUtils.doorLock.log('指纹录入完成');
        _inputCurNo = _inputAll;
        break;
      default:
        break;
    }
    if (mounted) setState(() {});
  }

  ///录入成功后上报服务器（带时效选择页的昵称与时效）
  Future<void> _saveUserToServer(int hardwareId) async {
    final valid = widget.vaildTimeData;
    try {
      await doorlockAPI.saveDoorLockUser(
        sn: widget.deviceId,
        users: [
          {
            'Id': hardwareId,
            'Type': widget.type.value,
            'Auth': widget.addType,
            if (valid?.userNickName != null && valid!.userNickName!.isNotEmpty)
              'userNickName': valid.userNickName,
            if (valid?.validType != null && valid!.validType!.isNotEmpty)
              'validType': valid.validType,
            if (valid?.validTime != null && valid!.validTime!.isNotEmpty)
              'validTime': valid.validTime,
          }
        ],
        operationStr: JvssOperationAction.add.value,
        userTypes: [widget.type.value],
      );
    } catch (e) {
      ///上报失败不阻塞主流程，仅日志
      LogUtils.doorLock.log('指纹用户上报服务器失败: $e');
    }
  }

  ///返回确认：录入中需先向锁端发取消指令
  Future<void> _showCancelDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('提示'),
        content: const Text('确定取消本次录入吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('继续录入'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确定取消'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    if (_isAdding) {
      await _operation.cancelDoorLockAddOpenType(
        type: widget.type,
        isAdmin: widget.addType == 0,
      );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // ==================== UI ====================

  String _errSuffix(DoorLockNetIpOperaterResult? err, dynamic raw) {
    if (raw != null) return ': $raw';
    if (err != null && err != DoorLockNetIpOperaterResult.unknowError) {
      return ': ${err.name}';
    }
    return '';
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showCancelDialog();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F9),
        appBar: AppBar(
          title: Text(widget.addType == 1 ? '添加普通用户' : '添加管理员用户'),
        ),
        body: SizedBox(
          width: double.infinity,
          child: _showInputNo ? _inputProgressContent() : _guideContent(),
        ),
      ),
    );
  }

  ///引导图标（按开锁方式类型）
  IconData get _guideIcon {
    switch (widget.type) {
      case JvssOperateType.skin:
        return Icons.fingerprint;
      case JvssOperateType.card:
        return Icons.credit_card;
      case JvssOperateType.face:
        return Icons.face;
      case JvssOperateType.palmprint:
        return Icons.pan_tool;
      default:
        return Icons.touch_app;
    }
  }

  ///录入前引导视图
  Widget _guideContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          _guideIcon,
          size: 96,
          color: const Color(0xFF00B294),
        ),
        const SizedBox(height: 35),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            '请在门锁上按提示录入，录入期间请保持手机与门锁连接正常，勿离开此页面',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Color(0xFF464646)),
          ),
        ),
      ],
    );
  }

  ///录入进度视图
  Widget _inputProgressContent() {
    return Stack(
      fit: StackFit.expand,
      alignment: AlignmentDirectional.center,
      children: [
        ///顶部提示条
        Positioned(
          top: 28,
          child: Container(
            width: MediaQuery.of(context).size.width - 16 * 2,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8D42).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 16, color: Color(0xFFFF8D42)),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '录入时请用指腹覆盖采集区域，轻微调整角度多次按压',
                    maxLines: 2,
                    style: TextStyle(color: Color(0xFFFF8D42), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '指纹录入进度',
              style: TextStyle(color: Color(0xFF000000), fontSize: 14),
            ),
            const SizedBox(height: 15),
            Text(
              '($_inputCurNo/$_inputAll)',
              style: const TextStyle(
                  color: Color(0xFFFF8D42),
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 55),
            const Icon(Icons.fingerprint, size: 126, color: Color(0xFF00B294)),
            const SizedBox(height: 55),
            SizedBox(
              width: 210,
              child: Text(
                '请在门锁上按提示按压指纹，共需按压 $_inputAll 次',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF000000), fontSize: 14),
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ],
    );
  }
}
