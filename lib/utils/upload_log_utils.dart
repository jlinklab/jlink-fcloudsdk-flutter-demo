import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:xcloudsdk_flutter_example/utils/common_path.dart';

///上传日志文件工具类
///日志文件合并成zip
///上传
///删除zip文件
class UploadLogUtil {
  static void uploadLog(String obs, {Function(int code)? callback}) async {
    //日志存在的文件夹
    String sourcePath = await kDirectoryPath();
    String targetPath = '$sourcePath/log_XCloudSDK.log.zip';
    String zipFilePath = await createZipFile(sourcePath, targetPath);
    if (zipFilePath.isEmpty) {
      return;
    }
    var headers = {'Content-Type': 'application/x-zip-compressed'};
    var request = http.Request('PUT', Uri.parse(obs));
    request.bodyBytes =
        File('$sourcePath/log_XCloudSDK.log.zip').readAsBytesSync();

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    callback?.call(response.statusCode);
    //删除zip缓存
    File(zipFilePath).deleteSync();
  }

  static Future<String> createZipFile(String sourcePath, String targetPath,
      {bool includeLogDir = false}) async {
    final archive = Archive();

    File logFile = File('$sourcePath/log_XCloudSDK.log');
    if (logFile.existsSync()) {
      final fileContent = await logFile.readAsBytes();
      archive.addFile(
          ArchiveFile('log_XCloudSDK.log', fileContent.length, fileContent));
    }

    final logsDir = Directory('$sourcePath/log');

    if (logsDir.existsSync()) {
      // 遍历 log 文件夹中的所有文件
      final logFiles = logsDir.listSync(recursive: true).whereType<File>();

      for (final file in logFiles) {
        try {
          // 读取文件内容
          final fileContent = await file.readAsBytes();
          // 添加文件到归档
          archive.addFile(ArchiveFile(
            file.uri.pathSegments.last,
            fileContent.length,
            fileContent,
          ));
        } catch (e) {
          debugPrint('Error reading file: ${file.path}, error: $e');
        }
      }
    }

    if (includeLogDir) {
      final logDir = Directory('$sourcePath/Log');

      if (logDir.existsSync()) {
        // 遍历 logs 文件夹中的所有文件
        final logFiles = logDir.listSync(recursive: true).whereType<File>();

        for (final file in logFiles) {
          try {
            // 读取文件内容
            final fileContent = await file.readAsBytes();
            // 添加文件到归档
            archive.addFile(ArchiveFile(
              file.path.replaceFirst('$sourcePath/', ''), // 保持相对路径
              fileContent.length,
              fileContent,
            ));
          } catch (e) {
            debugPrint('Error reading file: ${file.path}, error: $e');
          }
        }
      }
    }

    final zipFile = File(targetPath);
    final zipData = ZipEncoder().encode(archive);

    await zipFile.writeAsBytes(zipData);

    debugPrint("ZIP file created at $targetPath");
    return targetPath;
  }
}
