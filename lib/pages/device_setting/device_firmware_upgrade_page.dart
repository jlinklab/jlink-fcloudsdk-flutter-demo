import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/api/device_upgrade/model.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

/// 设备固件升级页面
/// 支持两种升级方式：
/// 1. 在线升级：调用 xcDeviceUpgradeBySelf，设备自行从云端下载固件并升级
/// 2. 本地文件升级：先调用 xcDeviceDownloadFile 下载固件到本地，
///    再调用 xcDeviceUpgradeByFile 将本地固件发送给设备升级
class DeviceFirmwareUpgradePage extends StatefulWidget {
  const DeviceFirmwareUpgradePage(
      {Key? key, required this.deviceId, required this.pid})
      : super(key: key);

  final String deviceId;
  final String pid;

  @override
  State<DeviceFirmwareUpgradePage> createState() =>
      _DeviceFirmwareUpgradePageState();
}

class _DeviceFirmwareUpgradePageState extends State<DeviceFirmwareUpgradePage> {
  /// 升级状态
  _UpgradeStatus _status = _UpgradeStatus.idle;

  /// 当前软件版本（从设备 SystemInfo 获取）
  String _currentVersion = '';

  /// 版本检测结果
  DeviceVersionCheckResponse? _checkResponse;

  /// 升级进度 (0-100)
  int _progress = 0;

  /// 当前升级步骤描述
  String _stepText = '';

  /// 错误信息
  String? _errorMsg;

  /// 当前升级模式
  _UpgradeMode _upgradeMode = _UpgradeMode.online;

  /// 本地下载的固件文件路径
  String? _localFilePath;

  /// 升级进度流订阅
  StreamSubscription<DeviceUpgradeProgressResponse>? _upgradeSubscription;

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  @override
  void dispose() {
    _upgradeSubscription?.cancel();
    KToast.dismissInDispose();
    super.dispose();
  }

  /// 检查设备版本
  /// 1. 获取设备 SystemInfo
  /// 2. 使用 DeviceVersionCheck.forCommon 发起版本检测
  Future<void> _checkVersion() async {
    if (mounted) {
      setState(() {
        _status = _UpgradeStatus.checking;
        _errorMsg = null;
      });
    }

    try {
      // 获取设备系统信息
      final result = await JFApi.xcDevice.xcDevGetSysConfig(
        deviceId: widget.deviceId,
        commandName: 'SystemInfo',
        command: 1020,
      );
      if (result['Ret'] != null && result['Ret'] == 100) {
        Map<String, dynamic>? infoMap = result['SystemInfo'];
        Map? systemInfoMap = infoMap;
        if (systemInfoMap == null) {
          setState(() {
            _status = _UpgradeStatus.error;
            _errorMsg = TR.current.firmwareVersionCheckFailed;
          });
          return;
        }
        // 获取当前软件版本
        _currentVersion = systemInfoMap['SoftWareVersion'] ?? '';
        final pid = systemInfoMap['Pid'] ?? widget.pid;
        // 构造版本检测请求
        final devVerCheck = DeviceVersionCheck.forCommon(
          pid: pid,
          systemInfo: systemInfoMap,
        );

        // 发起版本检测
        final response = await JFApi.xcDeviceUpgrade.xcDeviceVersionCheck(
          deviceId: widget.deviceId,
          devVerCheck: devVerCheck,
        );

        _checkResponse = DeviceVersionCheckResponse(
            code: response.code, versionInfo: response.versionInfo);

        if (response.code < 0) {
          setState(() {
            _status = _UpgradeStatus.error;
            _errorMsg = kErrorMsg(
                XCloudAPIException(code: response.code, commandId: 13400));
          });
          return;
        }

        setState(() {
          if (_checkResponse!.info != null) {
            _status = _UpgradeStatus.upgradeAvailable;
          } else {
            _status = _UpgradeStatus.latest;
          }
        });
      } else {
        setState(() {
          _status = _UpgradeStatus.error;
          _errorMsg = TR.current.firmwareVersionCheckFailed;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = _UpgradeStatus.error;
          _errorMsg = kErrorMsg(e);
        });
      }
    }
  }

  /// 显示升级确认弹窗
  void _showUpgradeConfirmDialog(_UpgradeMode mode) {
    _upgradeMode = mode;
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
                if (mode == _UpgradeMode.online) {
                  _startOnlineUpgrade();
                } else {
                  _startLocalUpgrade();
                }
              },
              child: Text(TR.current.confirmBtn),
            ),
          ],
        );
      },
    );
  }

  /// 在线升级
  /// 通过 xcDeviceUpgradeBySelf 让设备自行下载固件并升级
  /// 同时监听 deviceUpgradeStream 获取升级进度
  Future<void> _startOnlineUpgrade() async {
    setState(() {
      _status = _UpgradeStatus.upgrading;
      _progress = 0;
      _stepText = TR.current.firmwareUpgrading;
      _errorMsg = null;
    });

    // 监听升级进度流
    _startUpgradeProgressListener();

    try {
      // 构造升级请求体
      final bodyJson = jsonEncode(_checkResponse!.info!);

      await JFApi.xcDeviceUpgrade.xcDeviceUpgradeBySelf(
        deviceId: widget.deviceId,
        timeout: 300000,
        bodyJson: bodyJson,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = _UpgradeStatus.error;
          _errorMsg = kErrorMsg(e);
        });
      }
      _upgradeSubscription?.cancel();
    }
  }

  /// 本地文件升级
  /// 1. 调用 xcDeviceDownloadFile 下载固件到本地目录
  /// 2. 调用 xcDeviceUpgradeByFile 将本地固件文件发送给设备
  /// 3. 监听 deviceUpgradeStream 获取升级进度
  Future<void> _startLocalUpgrade() async {
    setState(() {
      _status = _UpgradeStatus.downloading;
      _progress = 0;
      _stepText = TR.current.firmwareDownloadingToFirmware;
      _errorMsg = null;
    });

    try {
      // 获取本地存储目录
      final directory = await _getLocalDirectory();
      final dirPath = directory.path;

      // 下载固件到本地
      final downloadResult =
          await JFApi.xcDeviceUpgrade.xcDeviceDownloadFile(
        commandBody: _checkResponse!.versionInfo!,
        fileSavePath: dirPath,
      );

      if (downloadResult.code < 0) {
        setState(() {
          _status = _UpgradeStatus.error;
          _errorMsg = '${TR.current.firmwareDownloadFailed} (code: ${downloadResult.code})';
        });
        return;
      }

      _localFilePath = downloadResult.filePath;
      KToast.show(status: TR.current.firmwareDownloadSuccess);

      // 开始发送固件到设备
      setState(() {
        _status = _UpgradeStatus.upgrading;
        _stepText = TR.current.firmwareSendFile;
      });

      // 监听升级进度流
      _startUpgradeProgressListener();

      // 调用 xcDeviceUpgradeByFile 发送本地固件到设备
      final code = await JFApi.xcDeviceUpgrade.xcDeviceUpgradeByFile(
        deviceId: widget.deviceId,
        filePath: _localFilePath!,
      );

      if (code < 0) {
        setState(() {
          _status = _UpgradeStatus.error;
          _errorMsg = kErrorMsg(
              XCloudAPIException(code: code, commandId: 1306));
        });
        _upgradeSubscription?.cancel();
        _deleteLocalFile();
      }
    } catch (e) {
      setState(() {
        _status = _UpgradeStatus.error;
        _errorMsg = kErrorMsg(e);
      });
      _upgradeSubscription?.cancel();
      _deleteLocalFile();
    }
  }

  /// 启动升级进度监听
  void _startUpgradeProgressListener() {
    _upgradeSubscription?.cancel();
    _upgradeSubscription =
        JFApi.xcDeviceUpgrade.deviceUpgradeStream.listen((response) {
      _handleUpgradeProgress(response);
    }, onError: (error) {
      setState(() {
        _status = _UpgradeStatus.error;
        _errorMsg = kErrorMsg(error);
      });
      _upgradeSubscription?.cancel();
      _deleteLocalFile();
    });
  }

  /// 处理升级进度回调
  void _handleUpgradeProgress(DeviceUpgradeProgressResponse response) {
    // 如果 error < 0，表示升级失败
    if (response.error < 0) {
      setState(() {
        _status = _UpgradeStatus.error;
        _errorMsg =
            '${TR.current.firmwareUpgradeFailed} (code: ${response.error})';
      });
      _upgradeSubscription?.cancel();
      _deleteLocalFile();
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
        stepText = TR.current.firmwareSendFile;
        break;
      case UpgradeState.sendFileToDeviceComplete:
        stepText = TR.current.firmwareSendFile;
        break;
      case UpgradeState.upgrading:
        stepText = TR.current.firmwareUpgrading;
        break;
      case UpgradeState.upgradeComplete:
        stepText = TR.current.firmwareUpgrading;
        break;
      case UpgradeState.over:
        if (response.progress == 100) {
          // 设备重启成功
          setState(() {
            _status = _UpgradeStatus.success;
            _progress = 100;
          });
          _upgradeSubscription?.cancel();
          _deleteLocalFile();
          KToast.show(status: TR.current.firmwareUpgradeSuccess);
          return;
        } else if (response.progress == 1) {
          // 升级结束，等待设备重启
          stepText = TR.current.firmwareUpgrading;
        } else {
          // 小于0表示失败，已在上面处理
          return;
        }
        break;
    }

    setState(() {
      _progress = response.progress;
      _stepText = stepText;
    });
  }

  /// 获取本地存储目录
  Future<Directory> _getLocalDirectory() async {
    if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else if (Platform.isAndroid) {
      return await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    } else {
      // OHOS 等
      return await getApplicationDocumentsDirectory();
    }
  }

  /// 删除本地下载的固件文件
  void _deleteLocalFile() {
    if (_localFilePath != null) {
      try {
        final file = File(_localFilePath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.deviceFirmwareUpgrade),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case _UpgradeStatus.idle:
      case _UpgradeStatus.checking:
        return _buildCheckingView();
      case _UpgradeStatus.latest:
        return _buildLatestView();
      case _UpgradeStatus.upgradeAvailable:
        return _buildUpgradeAvailableView();
      case _UpgradeStatus.downloading:
        return _buildDownloadingView();
      case _UpgradeStatus.upgrading:
        return _buildUpgradingView();
      case _UpgradeStatus.success:
        return _buildSuccessView();
      case _UpgradeStatus.error:
        return _buildErrorView();
    }
  }

  /// 检查中视图
  Widget _buildCheckingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(TR.current.firmwareChecking),
        ],
      ),
    );
  }

  /// 已是最新版本视图
  Widget _buildLatestView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            TR.current.firmwareLatest,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            '${TR.current.firmwareCurrentVersion}: $_currentVersion',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 发现新版本视图 - 提供在线升级和本地升级两种方式
  Widget _buildUpgradeAvailableView() {
    final info = _checkResponse?.info;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(Icons.system_update, size: 64, color: Colors.blue.shade300),
          const SizedBox(height: 16),
          Text(
            TR.current.firmwareUpgradeAvailable,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(TR.current.firmwareCurrentVersion, _currentVersion),
          const SizedBox(height: 12),
          _buildInfoRow(
            TR.current.firmwareNewVersion,
            info?.upgradeVersion?.toString() ?? '',
          ),
          if (info?.date != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Date', info!.date!),
          ],
          if (info?.changeLog != null &&
              info!.changeLog!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow('ChangeLog', info.changeLog!),
          ],
          const SizedBox(height: 32),
          Text(
            TR.current.firmwareUpgradeTip,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.orange, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // 在线升级按钮
          ElevatedButton(
            onPressed: () => _showUpgradeConfirmDialog(_UpgradeMode.online),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(TR.current.firmwareOnlineUpgrade),
          ),
          const SizedBox(height: 12),
          // 本地文件升级按钮
          OutlinedButton(
            onPressed: () => _showUpgradeConfirmDialog(_UpgradeMode.local),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(TR.current.firmwareLocalUpgrade),
          ),
        ],
      ),
    );
  }

  /// 下载固件到本地视图（本地升级第一步）
  Widget _buildDownloadingView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.download, size: 64, color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            TR.current.firmwareDownloadingToFirmware,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
        ],
      ),
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
          Text(
            _upgradeMode == _UpgradeMode.online
                ? TR.current.firmwareOnlineUpgrade
                : TR.current.firmwareLocalUpgrade,
            style: TextStyle(color: Colors.blue.shade300, fontSize: 13),
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
            ElevatedButton(
              onPressed: _checkVersion,
              child: Text(TR.current.firmwareCheckUpdate),
            ),
          ],
        ),
      ),
    );
  }

  /// 信息行组件
  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

/// 升级状态枚举
enum _UpgradeStatus {
  /// 空闲
  idle,
  /// 检查版本中
  checking,
  /// 已是最新版本
  latest,
  /// 发现新版本
  upgradeAvailable,
  /// 正在下载固件到本地（本地升级专用）
  downloading,
  /// 升级中
  upgrading,
  /// 升级成功
  success,
  /// 错误
  error,
}

/// 升级模式
enum _UpgradeMode {
  /// 在线升级（设备自行下载固件）
  online,
  /// 本地文件升级（先下载固件到本地，再发送给设备）
  local,
}
