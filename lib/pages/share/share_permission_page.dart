import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/api/core/dio_config.dart';
import 'package:xcloudsdk_flutter_example/api/share_api.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/model/model.dart';
import 'package:xcloudsdk_flutter_example/pages/share/model/model.dart';
import 'package:xcloudsdk_flutter_example/pages/share/share_qr_page.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

import '../../models/user_instance.dart';

/// 分享权限选择页面
/// 选择分享权限后，通过账号搜索分享给其他用户
class SharePermissionPage extends StatefulWidget {
  final Device device;

  const SharePermissionPage({Key? key, required this.device}) : super(key: key);

  @override
  State<SharePermissionPage> createState() => _SharePermissionPageState();
}

class _SharePermissionPageState extends State<SharePermissionPage> {
  /// 可选权限列表（这里只列举了几个，具体可看DevicePermission类
  final List<DevicePermissionUI> _permissions = [
    DevicePermissionUI(
        nameKey: 'permIntercom',
        permission: DevicePermission.DP_Intercom,
        checked: true),
    DevicePermissionUI(
        nameKey: 'permSdRecord',
        permission: DevicePermission.DP_LocalStorage,
        checked: true),
    DevicePermissionUI(
        nameKey: 'permDeviceConfig',
        permission: DevicePermission.DP_ModifyConfig,
        checked: true),
    DevicePermissionUI(
        nameKey: 'permAlarmPush',
        permission: DevicePermission.DP_AlarmPush,
        checked: true),
  ];

  /// 搜索账号输入
  final TextEditingController _searchController = TextEditingController();

  /// 搜索结果
  List<SharedUser> _searchResult = [];
  String _errorText = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getPermissionName(String key) {
    switch (key) {
      case 'permIntercom':
        return TR.current.permIntercom;
      case 'permSdRecord':
        return TR.current.permSdRecord;
      case 'permDeviceConfig':
        return TR.current.permDeviceConfig;
      case 'permAlarmPush':
        return TR.current.permAlarmPush;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.share),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 设备信息
            Card(
              child: ListTile(
                title: Text(widget.device.nickname ?? widget.device.uuid),
                subtitle: Text(widget.device.uuid),
                leading: const Icon(Icons.videocam, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),

            /// 权限选择
            Text(
              TR.current.sharePermission,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._permissions.map((p) => CheckboxListTile(
                  title: Text(_getPermissionName(p.nameKey)),
                  value: p.checked,
                  onChanged: (value) {
                    setState(() {
                      p.checked = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                  dense: true,
                )),
            const Divider(height: 32),

            /// 二维码分享入口
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return ShareQRPage(
                      device: widget.device,
                      permissions: _permissions,
                    );
                  }));
                },
                icon: const Icon(Icons.qr_code),
                label: Text(TR.current.qrCodeShare),
              ),
            ),
            const SizedBox(height: 16),

            /// 账号搜索
            Text(
              TR.current.shareTo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: TR.current.inputAccountHint,
                      isDense: true,
                      border: const OutlineInputBorder(),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    onSubmitted: (value) {
                      _searchUser();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchUser,
                  child: Text(TR.current.search),
                ),
              ],
            ),

            /// 错误提示
            if (_errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorText,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            /// 搜索结果
            if (_searchResult.isNotEmpty) ...[
              const SizedBox(height: 16),
              ListTile(
                tileColor: Colors.blue.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                title: Text(_searchResult.first.account ?? ''),
                subtitle: Text(TR.current.clickToShare),
                trailing: const Icon(Icons.share, color: Colors.blue),
                onTap: _confirmShare,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 搜索用户
  void _searchUser() async {
    final input = _searchController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorText = '';
      _searchResult = [];
    });

    try {
      final String account = UserInfo.instance.userName;
      final String pwd = UserInfo.instance.userPwd;
      final String accountAES =
          await UtilAPI.instance.xcEncryptDevInfo(account);
      final String pswAES = await UtilAPI.instance.xcEncryptDevInfo(pwd);

      final result = await shareAPI.searchUser(accountAES, pswAES, input);

      setState(() {
        _isSearching = false;
        if (result.isEmpty) {
          _errorText = TR.current.userNotFound;
        } else {
          _searchResult = result;
        }
      });
    } catch (e) {
      if (e is BusinessError) {
        setState(() {
          _isSearching = false;
          _errorText = '${TR.current.searchFailed}: ${e.errorMessage}';
        });
      }
    }
  }

  /// 确认分享
  void _confirmShare() async {
    if (_searchResult.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TR.current.confirmShare),
        content: Text(
            TR.current.confirmShareContent(_searchResult.first.account ?? '')),
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
      final String devUsername = await DeviceAPI.instance
          .xcDevGetLocalUserName(deviceId: widget.device.uuid);
      final String devPwd = await DeviceAPI.instance
          .xcDevGetLocalPassword(deviceId: widget.device.uuid);
      final String devInfo =
          '${widget.device.uuid},$devUsername,$devPwd,0,${DateTime.now().millisecondsSinceEpoch}';

      final String permissionsStr = _permissions
          .where((e) => e.checked)
          .map((e) => e.permission.name)
          .join(',');

      await shareAPI.shareToAccount(
        widget.device.uuid,
        _searchResult.first.id!,
        jsonEncode(
            {'devInfo': await UtilAPI.instance.xcEncryptDevInfo(devInfo)}),
        permissionsStr,
        null,
        widget.device.nickname ?? '',
        null,
      );

      KToast.show(status: TR.current.shareSuccess);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      KToast.show(status: '${TR.current.shareFailed}: $e');
    }
  }
}
