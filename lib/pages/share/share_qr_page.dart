import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/model/model.dart';
import 'package:fcloudsdk_example/pages/share/model/model.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

import '../../models/user_instance.dart';

/// 二维码分享页面
/// 生成设备分享二维码，其他人扫码即可接受分享
class ShareQRPage extends StatefulWidget {
  final Device device;
  final List<DevicePermissionUI> permissions;

  const ShareQRPage({
    Key? key,
    required this.device,
    required this.permissions,
  }) : super(key: key);

  @override
  State<ShareQRPage> createState() => _ShareQRPageState();
}

class _ShareQRPageState extends State<ShareQRPage> {
  String _qrData = '';
  bool _isLoading = true;
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _generateQRCode();
  }

  /// 生成二维码数据
  Future<void> _generateQRCode() async {
    try {
      final String permissionsStr = widget.permissions
          .where((e) => e.checked)
          .map((e) => e.permission.name)
          .join(',');

      final String devUsername = await DeviceAPI.instance
          .xcDevGetLocalUserName(deviceId: widget.device.uuid);
      final String devPwd = await DeviceAPI.instance
          .xcDevGetLocalPassword(deviceId: widget.device.uuid);
      final String deviceToken = await DeviceAPI.instance
          .xcGetDeviceToken(deviceId: widget.device.uuid);

      Map<String, dynamic> info = {
        'userId': UserInfo.instance.userId,
        'devId': widget.device.uuid,
        'devType': widget.device.deviceType,
        'devName': widget.device.nickname ?? '',
        'loginName': devUsername,
        'pwd': devPwd,
        'permissions': permissionsStr,
        'shareTimes': 0,
        'dt': deviceToken,
        'username': UserInfo.instance.userName,
        'expireTime': 0, // 使用保存的时间戳，如果为 null 则传 0（表示永久）
      };

      debugPrint('加密前二维码数据 ==> ${jsonEncode(info)}');
      String encodeInfo =
          await UtilAPI.instance.xcEncryptDevInfo(jsonEncode(info));
      debugPrint('加密后二维码数据 ==> $encodeInfo');
      info = await AccountAPI.instance.xcEncodeInfo(encodeStr: encodeInfo);
      if (mounted) {
        setState(() {
          _qrData = 'https://d.xmeye.net/fcloudsdkdemo?shareKey=${info['key']}';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('生成二维码失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        KToast.show(status: '生成二维码失败: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.qrCodeShare),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 设备名称
                    Text(
                      widget.device.nickname ?? widget.device.uuid,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.device.uuid,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),

                    /// 二维码
                    RepaintBoundary(
                      key: _qrKey,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 220,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// 权限列表
                    Text(
                      TR.current.sharePermission,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.permissions
                          .where((e) => e.checked)
                          .map((p) => Chip(
                                label: Text(_getPermissionName(p.nameKey)),
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 32),

                    /// 分享按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _shareQRCode,
                        icon: const Icon(Icons.share),
                        label: Text(TR.current.shareQRCode),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
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

  /// 分享二维码
  Future<void> _shareQRCode() async {
    try {
      final RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath =
            '${tempDir.path}/${UserInfo.instance.userId}_${widget.device.uuid}_share.png';
        final File file =
            await File(filePath).writeAsBytes(byteData.buffer.asUint8List());
        ShareResult result = await Share.shareXFiles([XFile(file.path)]);
        if (result.status == ShareResultStatus.success) {
          KToast.show(status: '成功');
        }
        file.deleteSync();
      }
    } catch (e) {
      KToast.show(status: '分享失败: $e');
    }
  }
}
