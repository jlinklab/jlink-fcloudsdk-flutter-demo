import 'dart:io';

import 'package:fcloudsdk_example/utils/common_path.dart';

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

/// 固件升级共享服务
/// 供设备固件升级页与固件管理页共用的目录扫描、大小格式化等纯逻辑
class FirmwareUpgradeService {
  /// 本地固件接收目录（App 内部，Android/iOS/鸿蒙三端统一）
  static Future<Directory> getFirmwareReceiveDir() async {
    final String basePath = await kDirectoryPath();
    return Directory('$basePath/upgrade_receive_files');
  }

  /// App 下载固件目录（App 代理升级下载固件的临时存放目录）
  static Future<Directory> getFirmwareDownloadDir() async {
    final String basePath = await kDirectoryPath();
    return Directory('$basePath/upgrade_download_files');
  }

  /// 扫描指定目录中的 .bin/.img 固件包
  static Future<List<FirmWareContent>> scanFirmwareFiles(
      String dirPath) async {
    final List<FirmWareContent> list = [];
    final Directory dir = Directory(dirPath);
    if (!dir.existsSync()) {
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

  /// 扫描固件管理页固件列表
  /// 合并本地接收目录与 App 下载目录，两个目录不会存在同名文件，无需去重
  static Future<List<FirmWareContent>> scanFirmwareManageFiles() async {
    final List<FirmWareContent> list = [];
    for (Directory dir in await Future.wait(
        [getFirmwareReceiveDir(), getFirmwareDownloadDir()])) {
      list.addAll(await scanFirmwareFiles(dir.path));
    }
    return list;
  }

  /// 清空目录中的所有文件（App 代理升级前调用）
  static Future<void> clearDirectory(Directory dir) async {
    try {
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

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      double kilobytes = bytes / 1024;
      return '${kilobytes.toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      double megabytes = bytes / (1024 * 1024);
      return '${megabytes.toStringAsFixed(2)} MB';
    } else {
      double gigabytes = bytes / (1024 * 1024 * 1024);
      return '${gigabytes.toStringAsFixed(2)} GB';
    }
  }
}
