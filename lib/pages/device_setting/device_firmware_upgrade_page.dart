import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/api/device_upgrade/model.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/utils/common_path.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:fcloudsdk_example/views/x_single_selector.dart';

/// 本地固件文件信息
class FirmWareContent {
  /// 文件路径
  final String path;

  /// 文件大小（MB）
  final double fileLength;

  /// 文件名称
  String get fileName => path.split('/').last;

  FirmWareContent({required this.path, required this.fileLength});
}

/// 设备固件升级页面
/// 支持两种升级方式：
/// 1. 在线升级：进入页面自动检测新版本，检测到新版本后红点标记，
///    点击"最新版本"行触发升级。根据检测结果 CheckFrom 自动判定升级通道：
///    - device：调用 xcDeviceUpgradeBySelf，设备自行从云端下载固件并升级
///    - application（CheckFrom == 'App'）：先调用 xcDeviceDownloadFile 下载固件到本地，
///      再复用本地升级通道 xcDeviceUpgradeByFile 发送给设备升级
/// 2. 本地升级：点击右上角"本地升级"入口，扫描 App 固件接收目录
///    （upgrade_receive_files）中的 .bin/.img 固件包，选择后调用
///    xcDeviceUpgradeByFile 发送给设备升级
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
  /// 页面状态
  _UpgradeStatus _status = _UpgradeStatus.checking;

  /// 当前软件版本（从设备 SystemInfo 获取）
  String _currentVersion = '';

  /// 版本检测结果
  DeviceVersionCheckResponse? _checkResponse;

  /// 是否检测到新版本（可在线升级）
  bool _upgradeAvailable = false;

  /// 升级进度 (0-100)
  int _progress = 0;

  /// 当前升级步骤描述
  String _stepText = '';

  /// 错误信息
  String? _errorMsg;

  /// 当前升级模式
  _UpgradeMode _upgradeMode = _UpgradeMode.online;

  /// 设备网络模式，2 为转发/穿透模式（P2P）
  int _netType = -1;

  /// App 下载到本地的固件文件路径（App 代理升级模式使用）
  String? _localFilePath;

  /// 升级进度流订阅
  StreamSubscription<DeviceUpgradeProgressResponse>? _upgradeSubscription;

  @override
  void initState() {
    super.initState();
    _queryNetType();
    _checkVersion();
  }

  @override
  void dispose() {
    _upgradeSubscription?.cancel();
    KToast.dismissInDispose();
    super.dispose();
  }

  /// p2p模式（转发和穿透）不支持本地升级和 App 代理升级（固件上传链路不可用）
  bool get _supportUpgradeByLocalOrApp => _netType != 2;

  /// 查询设备当前网络模式
  Future<void> _queryNetType() async {
    try {
      _netType =
          await JFApi.xcDevice.xcDevGetCurNetType(deviceId: widget.deviceId);
    } catch (_) {
      _netType = -1;
    }
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
          _showCheckFailed(TR.current.firmwareVersionCheckFailed);
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
          _showCheckFailed(
              kErrorMsg(XCloudAPIException(code: response.code, commandId: 13400)));
          return;
        }

        // code == 0 且有 versionInfo 视为可升级，红点标记
        _upgradeAvailable = _checkResponse!.info != null;
        if (mounted) {
          setState(() {
            _status = _UpgradeStatus.normal;
          });
        }
      } else {
        _showCheckFailed(TR.current.firmwareVersionCheckFailed);
      }
    } catch (e) {
      _showCheckFailed(kErrorMsg(e));
    }
  }

  /// 版本检测失败处理
  void _showCheckFailed(String? msg) {
    if (!mounted) {
      return;
    }
    setState(() {
      _status = _UpgradeStatus.error;
      _errorMsg = msg;
    });
  }

  /// 本地升级入口
  /// 扫描 App 固件接收目录中的 .bin/.img 固件包，弹列表选择后执行升级
  Future<void> _onLocalUpgradeTap() async {
    // p2p转发/穿透模式不支持本地固件上传
    if (!_p2pProxyCheck()) {
      return;
    }

    final List<FirmWareContent> firmWareList = await _scanFirmwareFiles();
    if (!mounted) {
      return;
    }
    if (firmWareList.isEmpty) {
      // 提示固件存放目录，引导用户将固件包放入 App 固件接收目录
      final Directory receiveDir = await _getFirmwareReceiveDir();
      KToast.show(
          status: TR.current.firmwareFirmwareDirTip(receiveDir.path),
          duration: const Duration(seconds: 4));
      return;
    }

    XSingleSelector.show(
      context: context,
      title: TR.current.firmwareSelectLocalFile,
      dataList: firmWareList.map((e) => e.fileName).toList(),
      onSelect: (index) async {
        await Future.delayed(const Duration(microseconds: 100));
        if (!mounted) {
          return;
        }
        _showUpgradeConfirmDialog(_UpgradeMode.local,
            filePath: firmWareList[index].path);
      },
    );
  }

  /// 在线升级入口
  /// 检测到新版本（红点标记）时点击触发在线升级
  void _onOnlineUpgradeTap() {
    if (!_upgradeAvailable) {
      return;
    }
    _showUpgradeConfirmDialog(_UpgradeMode.online);
  }

  /// p2p模式（转发和穿透）不支持固件上传
  bool _p2pProxyCheck() {
    if (!_supportUpgradeByLocalOrApp) {
      KToast.show(status: TR.current.firmwareP2PNotSupportTip);
      return false;
    }
    return true;
  }

  /// 显示升级确认弹窗
  void _showUpgradeConfirmDialog(_UpgradeMode mode, {String? filePath}) {
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
                _execUpgrade(mode, filePath: filePath);
              },
              child: Text(TR.current.confirmBtn),
            ),
          ],
        );
      },
    );
  }

  /// 执行升级
  /// 在线升级根据检测结果 CheckFrom 自动判定升级通道：
  /// App 表示 App 代理下载升级，否则设备自升级
  Future<void> _execUpgrade(_UpgradeMode mode, {String? filePath}) async {
    if (mode == _UpgradeMode.local) {
      _startLocalUpgrade(filePath!);
      return;
    }

    if (_checkResponse?.info?.checkFrom == 'App') {
      // App 代理下载升级需要走本地上传通道，p2p模式不可用
      if (!_p2pProxyCheck()) {
        return;
      }
      _startAppDownloadUpgrade();
    } else {
      _startOnlineUpgrade();
    }
  }

  /// 在线升级（设备自升级）
  /// 通过 xcDeviceUpgradeBySelf 让设备自行从云端下载固件并升级
  /// 同时监听 deviceUpgradeStream 获取升级进度
  Future<void> _startOnlineUpgrade() async {
    setState(() {
      _status = _UpgradeStatus.upgrading;
      _progress = 0;
      _stepText = TR.current.firmwareUpgrading;
      _errorMsg = null;
      _upgradeMode = _UpgradeMode.online;
    });

    // 监听升级进度流
    _startUpgradeProgressListener();

    try {
      // 构造升级请求体
      final bodyJson = jsonEncode(_checkResponse!.info!);

      await JFApi.xcDeviceUpgrade.xcDeviceUpgradeBySelf(
        deviceId: widget.deviceId,
        timeout: 40000,
        bodyJson: bodyJson,
      );
    } catch (e) {
      _onUpgradeFailed(kErrorMsg(e));
    }
  }

  /// App 代理下载升级
  /// 1. 清空固件下载目录
  /// 2. 调用 xcDeviceDownloadFile 下载固件到本地下载目录
  /// 3. 复用本地升级通道 xcDeviceUpgradeByFile 上传给设备
  /// 4. 升级结束后删除本地下载的固件
  Future<void> _startAppDownloadUpgrade() async {
    // 升级前清空下载目录
    await _clearDownloadDirectory();

    setState(() {
      _status = _UpgradeStatus.downloading;
      _progress = 0;
      _stepText = TR.current.firmwareDownloadingToFirmware;
      _errorMsg = null;
      _upgradeMode = _UpgradeMode.online;
    });

    try {
      final dir = await _getFirmwareDownloadDir();

      // 下载固件到本地
      final downloadResult = await JFApi.xcDeviceUpgrade.xcDeviceDownloadFile(
        commandBody: _checkResponse!.versionInfo!,
        fileSavePath: dir.path,
      );

      if (downloadResult.code < 0) {
        _onUpgradeFailed(
            '${TR.current.firmwareDownloadFailed} (code: ${downloadResult.code})');
        return;
      }

      _localFilePath = downloadResult.filePath;

      // 开始发送固件到设备
      setState(() {
        _status = _UpgradeStatus.upgrading;
        _stepText = TR.current.firmwareSendFile;
      });

      // 监听升级进度流
      _startUpgradeProgressListener();

      // 调用 xcDeviceUpgradeByFile 发送本地固件到设备
      await JFApi.xcDeviceUpgrade.xcDeviceUpgradeByFile(
        deviceId: widget.deviceId,
        filePath: _localFilePath!,
      );
    } catch (e) {
      _onUpgradeFailed(kErrorMsg(e));
    }
  }

  /// 本地升级
  /// 将用户选择的本地固件包通过 xcDeviceUpgradeByFile 发送给设备升级
  Future<void> _startLocalUpgrade(String filePath) async {
    setState(() {
      _status = _UpgradeStatus.upgrading;
      _progress = 0;
      _stepText = TR.current.firmwareSendFile;
      _errorMsg = null;
      _upgradeMode = _UpgradeMode.local;
    });

    // 监听升级进度流
    _startUpgradeProgressListener();

    try {
      await JFApi.xcDeviceUpgrade.xcDeviceUpgradeByFile(
        deviceId: widget.deviceId,
        filePath: filePath,
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
    _deleteDownloadedFile();
    if (!mounted) {
      return;
    }
    setState(() {
      _status = _UpgradeStatus.error;
      _errorMsg = msg;
    });
  }

  /// 升级成功处理
  void _onUpgradeSuccess() {
    _upgradeSubscription?.cancel();
    _deleteDownloadedFile();
    if (!mounted) {
      return;
    }
    setState(() {
      _status = _UpgradeStatus.success;
      _progress = 100;
    });
    KToast.show(status: TR.current.firmwareUpgradeSuccess);
  }

  /// 扫描本地固件接收目录，仅保留 .bin/.img 固件包
  Future<List<FirmWareContent>> _scanFirmwareFiles() async {
    final List<FirmWareContent> list = [];
    final Directory dir = await _getFirmwareReceiveDir();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
      return list;
    }
    for (FileSystemEntity entity in dir.listSync()) {
      if (entity is! File) {
        continue;
      }
      if (entity.path.endsWith('.bin') || entity.path.endsWith('.img')) {
        final int fileLength = await entity.length();
        list.add(FirmWareContent(
            path: entity.path, fileLength: fileLength / (1024 * 1024)));
      }
    }
    return list;
  }

  /// 本地固件接收目录（App 内部，Android/iOS/鸿蒙三端统一）
  Future<Directory> _getFirmwareReceiveDir() async {
    final String basePath = await kDirectoryPath();
    return Directory('$basePath/upgrade_receive_files');
  }

  /// App 下载固件目录
  Future<Directory> _getFirmwareDownloadDir() async {
    final String basePath = await kDirectoryPath();
    return Directory('$basePath/upgrade_download_files');
  }

  /// 清空固件下载目录（App 代理升级前调用）
  Future<void> _clearDownloadDirectory() async {
    try {
      final Directory dir = await _getFirmwareDownloadDir();
      if (!dir.existsSync()) {
        return;
      }
      for (FileSystemEntity entity in dir.listSync()) {
        if (entity is File) {
          entity.deleteSync();
        }
      }
    } catch (_) {}
  }

  /// 删除 App 下载的固件文件（App 代理升级结束后调用）
  void _deleteDownloadedFile() {
    if (_localFilePath == null) {
      return;
    }
    try {
      final file = File(_localFilePath!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
    _localFilePath = null;
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
      case _UpgradeStatus.checking:
        return _buildCheckingView();
      case _UpgradeStatus.normal:
        return _buildContentView();
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

  /// 版本信息视图
  /// 显示当前版本、最新版本检测结果（红点标记可升级），
  /// 右上角提供本地升级入口
  Widget _buildContentView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 主模块标题 + 本地升级入口
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 14, right: 16),
                    child: Row(
                      children: [
                        Text(
                          TR.current.firmwareMainModule,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _onLocalUpgradeTap,
                          child: Text(
                            TR.current.firmwareLocalUpgrade,
                            style: const TextStyle(
                              color: Color(0xFFFF7F38),
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFFFF7F38),
                              decorationThickness: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 当前版本
                  _buildConfigItem(
                    title: TR.current.firmwareCurrentVersion,
                    subTitle: _currentVersion,
                  ),
                  // 新版本：可升级时红点标记，点击触发在线升级
                  _buildConfigItem(
                    title: TR.current.firmwareNewVersion,
                    subTitle: _upgradeAvailable
                        ? TR.current.firmwareNewVersionUpgradable
                        : TR.current.firmwareLatest,
                    showRedDot: _upgradeAvailable,
                    onTap: _onOnlineUpgradeTap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              TR.current.firmwareUpgradeTip,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// 配置行组件（粗体标题 + 红点 + 灰色等宽副标题，右对齐可多行）
  Widget _buildConfigItem({
    required String title,
    required String subTitle,
    bool showRedDot = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (showRedDot)
              Container(
                margin: const EdgeInsets.only(right: 5),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            Flexible(
              child: Text(
                subTitle,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  // 数字等宽，版本号对齐显示
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 下载固件到本地视图（App 代理升级第一步）
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _checkVersion,
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
}

/// 页面状态枚举
enum _UpgradeStatus {
  /// 检查版本中
  checking,
  /// 正常（显示版本信息）
  normal,
  /// 正在下载固件到本地（App 代理升级专用）
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
  /// 在线升级（设备自升级 / App 代理下载）
  online,
  /// 本地固件升级（选择手机本地固件包上传）
  local,
}
