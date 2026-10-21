import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/api/door_lock_api.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/door_user.dart';
import 'package:flutter/material.dart';

///门锁用户详情页
class DoorLockUserDetailPage extends StatefulWidget {
  final DoorUser user;
  final String deviceId;

  const DoorLockUserDetailPage({
    super.key,
    required this.user,
    required this.deviceId,
  });

  @override
  State<DoorLockUserDetailPage> createState() => _DoorLockUserDetailPageState();
}

class _DoorLockUserDetailPageState extends State<DoorLockUserDetailPage> {
  ///当前展示的昵称（编辑成功后更新）
  late String _nickname = widget.user.userNickName?.trim() ?? '';

  ///保存进行中（防重复提交）
  bool _saving = false;

  ///开锁方式类型（由用户数据推导，未知时回退密码）
  JvssOperateType get _type =>
      JvssOperateType.from(widget.user.type) == JvssOperateType.unknown
          ? JvssOperateType.password
          : JvssOperateType.from(widget.user.type);

  ///用户类型展示文案
  String get _typeText {
    switch (_type) {
      case JvssOperateType.skin:
        return '指纹';
      case JvssOperateType.card:
        return '卡片';
      case JvssOperateType.face:
        return '人脸';
      case JvssOperateType.palmprint:
        return '掌纹';
      case JvssOperateType.fingervein:
        return '指静脉';
      case JvssOperateType.palmVein:
        return '掌静脉';
      case JvssOperateType.password:
      default:
        return '密码';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(title: const Text('详情')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.5, vertical: 15),
        child: Column(
          children: [
            _buildCard([
              _buildEditableItem(
                title: '昵称',
                value: _nickname.isEmpty ? '未设置' : _nickname,
                showArrow: true,
                onTap: _saving ? null : _onEditNickname,
              ),
            ]),
            const SizedBox(height: 10),
            _buildCard([
              _buildInfoItem(title: '用户类型', value: _typeText),
              _buildInfoItem(
                title: '用户编号',
                value: widget.user.id.toString().padLeft(4, '0'),
              ),
              if ((widget.user.creatorName ?? '').isNotEmpty)
                _buildInfoItem(title: '创建人', value: widget.user.creatorName!),
            ]),
          ],
        ),
      ),
    );
  }

  ///卡片容器（圆角白底），内部项之间自动加分隔线
  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, indent: 14, endIndent: 14),
          ],
        ],
      ),
    );
  }

  ///只读信息项（左标题 + 右值）
  Widget _buildInfoItem({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1E1E1E))),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 15, color: Color(0xFF999999)),
            ),
          ),
        ],
      ),
    );
  }

  ///可编辑项（左标题 + 右值 + 箭头，可点击）
  Widget _buildEditableItem({
    required String title,
    required String value,
    required bool showArrow,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Text(title,
                style: const TextStyle(fontSize: 15, color: Color(0xFF1E1E1E))),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, color: Color(0xFF999999)),
              ),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right,
                  size: 20, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  // ==================== 昵称编辑 ====================

  ///点击昵称：弹原生对话框输入，校验长度后保存
  Future<void> _onEditNickname() async {
    final controller = TextEditingController(text: _nickname);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改昵称'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 10,
          decoration: const InputDecoration(
            hintText: '请输入昵称（2-10个字符）',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (newName == null) return;

    ///长度校验（2-10 个字符）
    if (newName.isEmpty || newName.length < 2 || newName.length > 10) {
      _showSnack('昵称长度需为 2-10 个字符');
      return;
    }
    if (newName == _nickname) return;
    await _saveNickname(newName);
  }

  ///保存昵称到服务器
  Future<void> _saveNickname(String newName) async {
    setState(() => _saving = true);
    try {
      await doorlockAPI.modifyAlarmMessageNickName(
        deviceSn: widget.deviceId,
        userType: _type.toJvssString(),
        userId: widget.user.id.toString(),
        userNickname: newName,

        ///回传原头像值，避免清空服务器已有头像
        headPortrait: widget.user.userHeadPortrait ?? '',
      );
      if (!mounted) return;
      setState(() => _nickname = newName);

      ///直接更新传入的 DoorUser 对象，列表页返回后 setState 即显示新昵称，无需重新拉取
      widget.user.userNickName = newName;
      _showSnack('昵称修改成功');
    } catch (e) {
      LogUtils.doorLock.log('修改昵称失败: $e');
      if (!mounted) return;
      _showSnack('修改失败: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }
}
