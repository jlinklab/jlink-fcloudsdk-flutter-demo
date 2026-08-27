import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fcloudsdk_example/common/event.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/device_firmware_manage_page.dart';
import 'package:fcloudsdk_example/utils/common_path.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

/// 固件管理页路由名（用于判断当前是否已在固件管理页，避免重复入栈）
const String kFirmwareManageRouteName = 'device_firmware_manage';

/// 全局导航 key，供接收文件回调在无页面 context 时跳转固件管理页
final GlobalKey<NavigatorState> receiveFileNavigatorKey =
    GlobalKey<NavigatorState>();

/// 冷启动分享文件时 App 尚未完成首帧构建，延迟重试次数上限
int _retryCount = 0;

/// 监听三端原生文件拦截通道：
/// 1. MethodChannel 'xcloud.sdk/distribute_openUrlChannel'：iOS 打开方式兜底
///    复制（当前 iOS 原生已在 AppDelegate 中复制完成，此分支保留兜底）
/// 2. EventChannel 'app/receive_file_channel'：Android/iOS/鸿蒙原生拦截到
///    分享文件后的处理结果码
kChannelConfig() {
  // 监听原生方法通道
  const MethodChannel('xcloud.sdk/distribute_openUrlChannel')
      .setMethodCallHandler((MethodCall call) async {
    if (call.method == 'openUrl') {
      print(call.arguments['url']);
      String urlStr = call.arguments['url'];
      if (Platform.isIOS) {
        if (urlStr.startsWith('file:///private')) {
          urlStr = urlStr.replaceAll('file://', '');
          // 源文件
          File sourceFile = File(urlStr);

          final String basePath = await kDirectoryPath();
          String upgradeFileDir = '$basePath/upgrade_receive_files';
          String fileName = urlStr.split('/').last;
          String targetFilePath = '$upgradeFileDir/$fileName';
          try {
            Directory(upgradeFileDir).createSync(recursive: true);
            // 如果目标文件已存在，则覆盖
            if (await File(targetFilePath).exists()) {
              await File(targetFilePath).delete();
            }
            // 复制文件
            await sourceFile.copy(targetFilePath);
            print('文件已成功复制到沙盒目录：$targetFilePath');
            _handleReceiveFile(0);
          } catch (e) {
            print('文件复制失败：$e');
          }
        }
      }
    }
  });

  // 监听三端原生拦截分享文件的结果码
  const EventChannel('app/receive_file_channel')
      .receiveBroadcastStream()
      .listen((event) {
    final int code = event as int;
    _handleReceiveFile(code);
  });
}

/// 处理原生文件拦截结果码：
/// 0 成功，-1 不支持，-2 解析/复制失败，-3 权限拒绝，-4 文件类型不合法
void _handleReceiveFile(int code) {
  final NavigatorState? nav = receiveFileNavigatorKey.currentState;
  if (nav == null) {
    // App 冷启动（分享文件拉起 App）时首帧尚未构建完成，延迟重试
    _retryCount++;
    if (_retryCount > 20) {
      _retryCount = 0;
      return;
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      _handleReceiveFile(code);
    });
    return;
  }
  _retryCount = 0;

  if (code == 0) {
    KToast.show(status: TR.current.receiveFileSuccessTip);
    // 通知固件管理页刷新文件列表
    eventBus.fire(ReceiveFileEvent(code));
    // 当前不在固件管理页时跳转
    bool onManagePage = false;
    nav.popUntil((route) {
      onManagePage = route.settings.name == kFirmwareManageRouteName;
      return true; // 仅用于检查栈顶路由，不实际弹出页面
    });
    if (!onManagePage) {
      nav.push(MaterialPageRoute(
        settings: const RouteSettings(name: kFirmwareManageRouteName),
        builder: (BuildContext context) =>
            const DeviceFirmwareManagePage(deviceId: ''),
      ));
    }
  } else if (code == -1 || code == -4) {
    KToast.show(status: TR.current.receiveFileNotSupportTip);
  } else if (code == -2) {
    KToast.show(status: TR.current.receiveFileFailedTip);
  } else if (code == -3) {
    KToast.show(status: TR.current.receiveFileNoPermissionTip);
  }
}
