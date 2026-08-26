import 'package:flutter/material.dart';
import 'package:fcloudsdk_example/api/share_api.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/model/model.dart';
import 'package:fcloudsdk_example/pages/share/share_permission_page.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

/// 设备分享管理页
/// 显示设备信息、分享入口、已分享账号列表
class DeviceSharePage extends StatefulWidget {
  final Device device;

  const DeviceSharePage({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceSharePage> createState() => _DeviceSharePageState();
}

class _DeviceSharePageState extends State<DeviceSharePage> {
  List<SharedDevice> _sharedList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSharedList();
  }

  /// 加载已分享账号列表
  Future<void> _loadSharedList() async {
    try {
      final list = await shareAPI.mySharedList(widget.device.uuid);
      if (mounted) {
        setState(() {
          _sharedList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('加载分享列表失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.deviceShare),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// 设备信息 + 分享按钮
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    title: Text(widget.device.nickname ?? widget.device.uuid),
                    subtitle: Text(widget.device.uuid),
                    leading: const Icon(Icons.videocam,
                        color: Colors.blue, size: 32),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return SharePermissionPage(device: widget.device);
                            })).then((_) => _loadSharedList());
                          },
                          icon: const Icon(Icons.person_add),
                          label: Text(TR.current.shareDevice),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// 已分享账号列表标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TR.current.sharedAccounts,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${_sharedList.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          /// 列表内容
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sharedList.isEmpty
                    ? Center(child: Text(TR.current.noSharedAccount))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _sharedList.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _sharedList[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text((item.shareNickname.isNotEmpty
                                      ? item.shareNickname[0]
                                      : '?')
                                  .toUpperCase()),
                            ),
                            title: Text(item.shareNickname.isNotEmpty
                                ? item.shareNickname
                                : item.uuid),
                            subtitle: Text(_getShareStatus(item)),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _cancelShare(item),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  /// 获取分享状态文本
  /// ret: 0分享初始化, 1接受分享, 2拒绝分享, 3未接受分享, 4分享过期
  String _getShareStatus(SharedDevice device) {
    switch (device.ret) {
      case 1:
        return TR.current.shareAccepted;
      case 2:
        return TR.current.shareRejected;
      case 4:
        return TR.current.shareExpired;
      case 0:
      case 3:
      default:
        return TR.current.sharePending;
    }
  }

  /// 取消分享
  Future<void> _cancelShare(SharedDevice device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TR.current.cancelShare),
        content: Text(TR.current.cancelShareContent(
            device.shareNickname.isNotEmpty
                ? device.shareNickname
                : device.uuid)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(TR.current.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(TR.current.check),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await shareAPI.cancelShare(device.shareId);
      KToast.show(status: TR.current.cancelShareSuccess);
      _loadSharedList();
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }
}
