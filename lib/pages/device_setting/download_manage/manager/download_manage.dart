import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:xcloudsdk_flutter/media/download/meida_download_controller.dart';
import 'package:xcloudsdk_flutter/utils/extensions.dart';
import 'package:xcloudsdk_flutter_example/pages/record/model/model.dart';

import '../../../download_manage/model/record_file.dart';

///缓存下载记录
class DownloadManage extends ChangeNotifier {
  static final DownloadManage instance = DownloadManage();

  // 录像下载历史
  Map<String, List<RecordFile>> historyMap = {};

  ///当前的下载控制器
  DownloadController? _downloadController;

  List<RecordFile> addToHistory(String deviceId, List<RecordFile> files) {
    List<RecordFile> history = historyMap[deviceId] ?? [];
    for (var file in files) {
      RecordFile? existFile =
          history.firstWhereOrNull((e) => e.key == file.key);
      if (existFile == null) {
        history.add(file);
      }
    }
    history.sort((a, b) =>
        a.beginTime!.millisecondsSinceEpoch -
        b.beginTime!.millisecondsSinceEpoch);

    for (var record in history) {
      record.download = File(record.saveFilePath).existsSync();
      if (record.download) {
        record.downloadProgress =
            DownloadProgressState(state: DownloadState.done);
      }
    }
    historyMap[deviceId] = history;
    _findToDownload(deviceId);
    return historyMap[deviceId] ?? [];
  }

  ///查找第一个可以下载的文件进行下载
  void _findToDownload(String deviceId) async {
    List<RecordFile>? records = historyMap[deviceId];
    if (records == null || records.isEmpty) {
      return;
    }
    int index = records.indexWhere((e) => e.download == false);
    if (index < 0) {
      return;
    }
    RecordFile recordFile = records[index];
    startDownloadFile(deviceId, recordFile);
  }

  void checkStartDownload(String deviceId, RecordFile record) async {
    List<RecordFile> history = historyMap[deviceId] ?? [];
    RecordFile? downloadingRecord =
        history.firstWhereOrNull((e) => e.downloading);
    if (downloadingRecord == null) {
      startDownloadFile(deviceId, record);
      return;
    } else {
      //先取消之前的下载
      downloadingRecord.downloading = false;
      downloadingRecord.download = false;
      if (_downloadController != null) {
        await _downloadController!.cancelDownload();
        await Future.delayed(const Duration(seconds: 1));
      }
      startDownloadFile(deviceId, record);
      notifyListeners();
    }
  }

  /// 取消下载
  void cancelDownload(String deviceId, RecordFile record) async {
    record.downloading = false;
    record.download = false;
    if (_downloadController != null) {
      await _downloadController!.cancelDownload();
      await Future.delayed(const Duration(seconds: 1));
    }
    notifyListeners();
  }

  /// 开始下载
  void startDownloadFile(String deviceId, RecordFile recordFile) async {
    if (recordFile is CloudRecord) {
    } else if (recordFile is CardRecord) {
      Map<String, dynamic> downloadParams = recordFile.toJson();
      downloadParams['SaveFileName'] = recordFile.saveFilePath;
      _downloadController = CardVideoDownloadController(
          deviceId: deviceId, downloadParams: downloadParams);
    }

    if (_downloadController == null) {
      return;
    }
    await _downloadController!.startDownload();

    _downloadController!.setDownloadProgressListener((event) {
      recordFile.downloadProgress = event;
      if (event.state == DownloadState.done) {
        recordFile.download = true;
      }
      notifyListeners();
    });
  }

  void disposeDownload() {
    if (_downloadController != null) {
      _downloadController!.dispose();
    }
  }
}
