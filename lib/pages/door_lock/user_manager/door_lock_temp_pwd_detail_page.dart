import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/api/door_lock_api.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/temp_password.dart';
import 'package:flutter/material.dart';

///临时（自定义）密码详情页
class DoorLockTempPwdDetailPage extends StatefulWidget {
  final TempPassword info;

  const DoorLockTempPwdDetailPage({super.key, required this.info});

  @override
  State<DoorLockTempPwdDetailPage> createState() =>
      _DoorLockTempPwdDetailPageState();
}

class _DoorLockTempPwdDetailPageState extends State<DoorLockTempPwdDetailPage> {
  ///保存进行中（防重复提交）
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(title: const Text('详情')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.5, vertical: 15),
        child: Column(
          children: [
            _buildPasswordCard(),
            const SizedBox(height: 10),
            _buildCard([
              _buildEditableItem(
                title: '昵称',
                value: widget.info.name.trim().isEmpty
                    ? '未设置'
                    : widget.info.name.trim(),
                showArrow: true,
                onTap: _saving ? null : _onEditName,
              ),
              if (widget.info.uTypeDescription.isNotEmpty)
                _buildInfoItem(
                    title: '用户类型', value: widget.info.uTypeDescription),
              if ((widget.info.creatorName ?? '').isNotEmpty)
                _buildInfoItem(title: '创建人', value: widget.info.creatorName!),
            ]),
          ],
        ),
      ),
    );
  }

  // ==================== 顶部密码串卡片 ====================

  ///顶部密码展示区（密码串 35pt 绿色 + "有效期" 标签 + 起止时间；
  ///有重复星期时在时段下方追加小字）
  Widget _buildPasswordCard() {
    final validText = widget.info.validTimeText;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.5),
      ),
      child: Column(
        children: [
          Text(
            widget.info.password,
            style: const TextStyle(
              fontSize: 35,
              color: Color(0xFF00B294),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (validText.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Text(
              '有效期',
              style: TextStyle(color: Color(0xFF989898), fontSize: 13),
            ),
            const SizedBox(height: 12.5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                validText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Color(0xFF1E1E1E)),
              ),
            ),
            if (widget.info.weeksText.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.info.weeksText,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF989898)),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ==================== 底部信息卡片 ====================

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
  Future<void> _onEditName() async {
    final controller = TextEditingController(text: widget.info.name);
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
    if (newName == widget.info.name.trim()) return;
    await _saveName(newName);
  }

  ///保存昵称到服务器（updateTempPwd 为全量更新，其余字段原样回传）
  Future<void> _saveName(String newName) async {
    setState(() => _saving = true);
    try {
      await doorlockAPI.updateTempPwd(
        id: widget.info.id,
        deviceSn: widget.info.deviceSn,
        password: widget.info.password,
        rpt: widget.info.rpt,
        name: newName,
        startTime: widget.info.startTime,
        endTime: widget.info.endTime,
        startTimeStamp: widget.info.startTimeStamp,
        endTimeStamp: widget.info.endTimeStamp,
        uType: widget.info.uType,
      );
      if (!mounted) return;

      ///直接改写传入的 TempPassword 对象，列表页返回后 setState 即显示新昵称
      widget.info.name = newName;
      setState(() {});
      _showSnack('昵称修改成功');
    } catch (e) {
      LogUtils.doorLock.log('修改临时密码昵称失败: $e');
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
