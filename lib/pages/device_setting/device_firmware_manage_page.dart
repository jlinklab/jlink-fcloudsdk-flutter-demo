import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/api/device_upgrade/model.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/common/firmware_upgrade_service.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

/// 固件管理页面
/// 扫描 App 内固件目录（本地接收目录 upgrade_receive_files + App 下载目录
/// upgrade_download_files）中的 .bin/.img 固件包，列表展示文件名与大小，
/// 选中后点击确认通过 xcDeviceUpgradeByFile 发送给设备升级，
/// 同时监听 deviceUpgradeStream 展示升级进度
class DeviceFirmwareManagePage extends StatefulWidget {
  const DeviceFirmwareManagePage({Key? key, required this.deviceId})
      : super(key: key);

  final String deviceId;

  @override
  State<DeviceFirmwareManagePage> createState() =>
      _DeviceFirmwareManagePageState();
}

class _DeviceFirmwareManagePageState extends State<DeviceFirmwareManagePage> {
  /// 页面状态
  _ManageStatus _status = _ManageStatus.normal;

  /// 固件文件列表
  List<FirmWareContent> _fileList = [];

  /// 选中的固件索引
  int? _selectedIndex;

  /// 设备网络模式，2 为转发/穿透模式（P2P）
  int _netType = -1;

  /// 升级进度 (0-100)
  int _progress = 0;

  /// 当前升级步骤描述
  String _stepText = '';

  /// 错误信息
  String? _errorMsg;

  /// 升级进度流订阅
  StreamSubscription<DeviceUpgradeProgressResponse>? _upgradeSubscription;

  /// p2p模式（转发和穿透）不支持本地固件上传
  bool get _supportUpgradeByLocalOrApp => _netType != 2;

  @override
  void initState() {
    super.initState();
    _queryNetType();
    _scanFiles();
  }

  @override
  void dispose() {
    _upgradeSubscription?.cancel();
    KToast.dismissInDispose();
    super.dispose();
  }

  /// 查询设备当前网络模式
  Future<void> _queryNetType() async {
    try {
      _netType =
          await JFApi.xcDevice.xcDevGetCurNetType(deviceId: widget.deviceId);
    } catch (_) {
      _netType = -1;
    }
  }

  /// 扫描固件文件列表（本地接收目录 + App 下载目录）
  Future<void> _scanFiles() async {
    final List<FirmWareContent> list =
        await FirmwareUpgradeService.scanFirmwareManageFiles();
    if (!mounted) {
      return;
    }
    setState(() {
      _fileList = list;
    });
  }

  /// p2p模式（转发和穿透）不支持固件上传
  bool _p2pProxyCheck() {
    if (!_supportUpgradeByLocalOrApp) {
      KToast.show(status: TR.current.firmwareP2PNotSupportTip);
      return false;
    }
    return true;
  }

  /// 确认升级：弹确认弹窗后执行升级
  void _onConfirm() {
    if (_selectedIndex == null) {
      return;
    }
    if (!_p2pProxyCheck()) {
      return;
    }
    final FirmWareContent firmware = _fileList[_selectedIndex!];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(TR.current.deviceFirmwareUpgrade),
          content: Text(TR.current.firmwareUpgradeConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(TR.current.cancelBtn),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _execUpgrade(firmware);
              },
              child: Text(TR.current.confirmBtn),
            ),
          ],
        );
      },
    );
  }

  /// 执行升级：xcDeviceUpgradeByFile 上传 + deviceUpgradeStream 进度监听
  Future<void> _execUpgrade(FirmWareContent firmware) async {
    setState(() {
      _status = _ManageStatus.upgrading;
      _progress = 0;
      _stepText = TR.current.firmwareSendFile;
      _errorMsg = null;
    });

    // 监听升级进度流
    _startUpgradeProgressListener();

    try {
      await JFApi.xcDeviceUpgrade.xcDeviceUpgradeByFile(
        deviceId: widget.deviceId,
        filePath: firmware.path,
      );
    } catch (e) {
      _onUpgradeFailed(kErrorMsg(e));
    }
  }

  /// 启动升级进度监听
  void _startUpgradeProgressListener() {
    _upgradeSubscription?.cancel();
    _upgradeSubscription =
        JFApi.xcDeviceUpgrade.deviceUpgradeStream.listen((response) {
      _handleUpgradeProgress(response);
    }, onError: (error) {
      _onUpgradeFailed(kErrorMsg(error));
    });
  }

  /// 处理升级进度回调
  void _handleUpgradeProgress(DeviceUpgradeProgressResponse response) {
    // 如果 error < 0，表示升级失败
    if (response.error < 0) {
      _onUpgradeFailed(
          '${TR.current.firmwareUpgradeFailed} (code: ${response.error})');
      return;
    }

    String stepText = '';
    switch (response.state) {
      case UpgradeState.updateCheck:
        stepText = TR.current.firmwareChecking;
        break;
      case UpgradeState.downloadCloudFile:
        stepText = TR.current.firmwareDownloadFile;
        break;
      case UpgradeState.sendFileToDevice:
      case UpgradeState.sendFileToDeviceComplete:
        stepText = TR.current.firmwareSendFile;
        break;
      case UpgradeState.upgrading:
      case UpgradeState.upgradeComplete:
        stepText = TR.current.firmwareUpgrading;
        break;
      case UpgradeState.over:
        if (response.progress == 100) {
          // 设备重启成功，升级完成
          _onUpgradeSuccess();
          return;
        } else if (response.progress == 1) {
          // 升级结束，等待设备重启
          stepText = TR.current.firmwareUpgradeWaitReboot;
        } else {
          // 小于0表示失败，已在上面处理
          return;
        }
        break;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _progress = response.progress;
      _stepText = stepText;
    });
  }

  /// 升级失败处理
  void _onUpgradeFailed(String? msg) {
    _upgradeSubscription?.cancel();
    if (!mounted) {
      return;
    }
    setState(() {
      _status = _ManageStatus.error;
      _errorMsg = msg;
    });
  }

  /// 升级成功处理
  void _onUpgradeSuccess() {
    _upgradeSubscription?.cancel();
    if (!mounted) {
      return;
    }
    setState(() {
      _status = _ManageStatus.success;
      _progress = 100;
    });
    KToast.show(status: TR.current.firmwareUpgradeSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.firmwareManageTitle),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case _ManageStatus.normal:
        return _buildListView();
      case _ManageStatus.upgrading:
        return _buildUpgradingView();
      case _ManageStatus.success:
        return _buildSuccessView();
      case _ManageStatus.error:
        return _buildErrorView();
    }
  }

  /// 固件列表视图
  Widget _buildListView() {
    if (_fileList.isEmpty) {
      return _buildEmptyView();
    }
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              final FirmWareContent firmware = _fileList[index];
              final bool selected = _selectedIndex == index;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          firmware.fileName,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xFFFF7F38)
                                : Colors.black,
                            fontSize: 15,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formatFirmwareSize(firmware),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.check,
                        size: 24,
                        color: selected
                            ? const Color(0xFFFF7F38)
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(height: 1, color: Colors.grey.shade200);
            },
            itemCount: _fileList.length,
          ),
        ),
        // 底部确认按钮
        Padding(
          padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 20),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7F38),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              onPressed: _selectedIndex != null ? _onConfirm : null,
              child: Text(TR.current.confirmBtn),
            ),
          ),
        ),
      ],
    );
  }

  /// 空列表视图
  Widget _buildEmptyView() {
    return FutureBuilder<Directory>(
      future: FirmwareUpgradeService.getFirmwareReceiveDir(),
      builder: (context, snapshot) {
        final String dirPath = snapshot.data?.path ?? '';
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  TR.current.firmwareEmptyTip,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                if (dirPath.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    TR.current.firmwareFirmwareDirTip(dirPath),
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// 升级中视图
  Widget _buildUpgradingView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.system_update, size: 64, color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            '${TR.current.firmwareUpgrading}...',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          if (_stepText.isNotEmpty)
            Text(
              _stepText,
              style: const TextStyle(color: Colors.grey),
            ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: _progress / 100.0,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(height: 8),
          Text('$_progress%'),
          const SizedBox(height: 24),
          Text(
            TR.current.firmwareUpgradeTip,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.orange, fontSize: 13),
          ),
        ],
      ),
    );
  }

  /// 升级成功视图
  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            TR.current.firmwareUpgradeSuccess,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(TR.current.confirmBtn),
          ),
        ],
      ),
    );
  }

  /// 错误视图
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMsg != null && _errorMsg!.isNotEmpty
                  ? _errorMsg!
                  : TR.current.firmwareUpgradeFailed,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _status = _ManageStatus.normal;
                      _selectedIndex = null;
                    });
                    _scanFiles();
                  },
                  child: Text(TR.current.firmwareCheckUpdate),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(TR.current.back),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化固件文件大小
  String _formatFirmwareSize(FirmWareContent firmware) {
    try {
      return FirmwareUpgradeService
          .formatFileSize(File(firmware.path).lengthSync());
    } catch (_) {
      return '';
    }
  }
}

/// 页面状态枚举
enum _ManageStatus {
  /// 正常（显示固件列表）
  normal,
  /// 升级中
  upgrading,
  /// 升级成功
  success,
  /// 错误
  error,
}
