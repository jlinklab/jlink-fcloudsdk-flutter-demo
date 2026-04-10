import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:open_file/open_file.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/media/media_download.dart';
import 'package:xcloudsdk_flutter/utils/date_util.dart';

// ignore: depend_on_referenced_packages
import 'package:date_format/date_format.dart';
import 'package:xcloudsdk_flutter/utils/extensions.dart';
import 'package:xcloudsdk_flutter_example/common/common_path.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';

import '../download_manage/model/record_file.dart';
import 'model/model.dart';

class DownloadNextEvent {
  final RecordFile recordFile;

  DownloadNextEvent({required this.recordFile});
}

class CancelDownloadEvent {
  final RecordFile recordFile;

  CancelDownloadEvent({required this.recordFile});
}

///缓存下载记录
class DownloadHistory extends ChangeNotifier {
  static final DownloadHistory instance = DownloadHistory();

  Map<String, List<RecordFile>> historyMap = {};

  Map<RecordFile, DownloadController> downloadMap = {};

  bool _downloading = false;

  String videoRecordPath = '';

  Future<void> getVideoRecordPath() async {
    videoRecordPath = await kDirectoryVideoRecordPath();
  }

  String getSaveFilePath(String deviceId, DateTime beginTime, DateTime endTime,
      {bool create = false, int channel = 0}) {
    String dayTime = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
    String dir = '$videoRecordPath/$deviceId/$dayTime';
    if (create) {
      Directory directory = Directory(dir);
      if (!directory.existsSync()) {
        directory.createSync();
      }
    }
    return '$dir/${DateUtil.formatDateTime(beginTime)}_${DateUtil.formatDateTime(endTime)}_$channel.mp4';
  }

  ///添加到记录,并返回一个
  List<RecordFile> addToHistory(String deviceId, List<RecordFile> files) {
    _downloading = true;
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
      String savePath = getSaveFilePath(
        deviceId,
        record.beginTime!,
        record.endTime!,
        channel: record.channel ?? 0,
      );
      record.saveFilePath = savePath;
      record.download = File(savePath).existsSync();
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

  void startDownloadFile(String deviceId, RecordFile recordFile) async {
    DownloadController? downloadController;
    if (recordFile is CloudRecord) {
      downloadController = CloudVideoDownloadController(
        url: recordFile.url!,
        fileName: recordFile.saveFilePath,
        extraInfo: recordFile.timeInfoString(),
      );
    } else if (recordFile is CardRecord) {
      Map<String, dynamic> downloadParams = recordFile.toJson();
      downloadParams['SaveFileName'] = recordFile.saveFilePath;
      downloadController = CardVideoDownloadController(
          deviceId: deviceId, downloadParams: downloadParams);
    }
    if (downloadController == null) {
      return;
    }
    downloadController.setDownloadProgressListener((event) {
      recordFile.downloadProgress = event;
      if (event.state == DownloadState.done) {
        hasDownload(deviceId, recordFile);
      } else {
        if (event.state == DownloadState.downloading ||
            event.state == DownloadState.loading ||
            event.state == DownloadState.changing) {
          recordFile.downloading = true;
        } else {
          recordFile.downloading = false;
        }
      }
      if (hasListeners) {
        notifyListeners();
      }
    });
    await downloadController.startDownload();
    downloadMap[recordFile] = downloadController;
  }

  List<RecordFile> downloadList(String deviceId) {
    return historyMap[deviceId] ?? [];
  }

  Future<void> hasDownload(String deviceId, RecordFile recordFile) async {
    List<RecordFile> history = historyMap[deviceId] ?? [];
    recordFile.download = true;
    recordFile.downloading = false;
    recordFile.downloadProgress =
        DownloadProgressState(state: DownloadState.done);

    RecordFile? next = history.firstWhereOrNull((e) => e.download == false);
    if (next != null && _downloading) {
      startDownloadFile(deviceId, next);
    }
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
      if (downloadMap[downloadingRecord] != null &&
          //下载失败的不需取消下载
          downloadingRecord.downloadProgress.state != DownloadState.error) {
        await downloadMap[downloadingRecord]!.cancelDownload();
        await Future.delayed(const Duration(milliseconds: 500));
      }
      startDownloadFile(deviceId, record);
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  void cancelDownload(String deviceId, RecordFile record) async {
    record.downloading = false;
    record.download = false;
    record.downloadProgress =
        DownloadProgressState(state: DownloadState.canceled);
    if (downloadMap[record] != null) {
      await downloadMap[record]!.cancelDownload();
      await Future.delayed(const Duration(milliseconds: 500));
    }
    if (hasListeners) {
      notifyListeners();
    }
  }

  void disposeDownload() {
    _downloading = true;
    for (var value in downloadMap.keys) {
      downloadMap[value]?.dispose();
    }
    downloadMap.clear();
  }
}

class RecordDownloadManagerPage extends StatefulWidget {
  const RecordDownloadManagerPage(
      {Key? key,
      required this.deviceId,
      required this.records,
      required this.copyToLocal})
      : super(key: key);

  final String deviceId;

  ///需要下载的文件
  final List<RecordFile> records;

  ///是否需要保存一份到本地相册
  final bool copyToLocal;

  @override
  // ignore: library_private_types_in_public_api
  _RecordDownloadManagerPageState createState() =>
      _RecordDownloadManagerPageState();
}

class _RecordDownloadManagerPageState extends State<RecordDownloadManagerPage> {
  List<RecordFile> _records = [];

  late VoidCallback downloadHistoryListen;

  @override
  void initState() {
    downloadHistoryListen = () {
      setState(() {});
    };
    DownloadHistory.instance.getVideoRecordPath();
    DownloadHistory.instance.addListener(downloadHistoryListen);
    _records = DownloadHistory.instance
        .addToHistory(widget.deviceId, List.from(widget.records));
    super.initState();
  }

  @override
  void dispose() {
    DownloadHistory.instance.removeListener(downloadHistoryListen);
    DownloadHistory.instance.disposeDownload();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.tr_common_download_management),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
                child: _records.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '空',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ))
                    : ListView.separated(
                        separatorBuilder: (context, index) {
                          return const SizedBox(); // 返回空的 SizedBox，表示没有分隔线
                        },
                        itemBuilder: (context, index) {
                          return DownloadTaskItemWidget(
                            record: _records[index],
                            deviceId: widget.deviceId,
                          );
                        },
                        itemCount: _records.length,
                      )),
          ],
        ),
      ),
    );
  }

  bool _selectAll = false;

  void _changeSelectAll() {
    _selectAll = !_selectAll;
    for (var record in _records) {
      record.downloadDelete = _selectAll;
    }
    setState(() {});
  }

  void _cancelSelectAll() {
    for (var record in _records) {
      record.downloadDelete = false;
    }
  }

  void _deleteRecord() {
    List<RecordFile> records =
        _records.where((e) => e.downloadDelete == true).toList();
    if (records.isEmpty) {
      return;
    }

    for (var record in records) {
      //取消下载 这里需要调用取消下载了,Item dispose时会主动取消
      File file = File(record.saveFilePath);
      if (file.existsSync()) {
        file.deleteSync();
        record.downloadProgress =
            DownloadProgressState(state: DownloadState.none);
      }
    }
    _records.removeWhere((e) => e.downloadDelete);
  }
}

class DownloadTaskItemWidget extends StatefulWidget {
  const DownloadTaskItemWidget({
    super.key,
    required this.record,
    required this.deviceId,
  });

  final RecordFile record;
  final String deviceId;

  @override
  State<DownloadTaskItemWidget> createState() => _DownloadTaskItemWidgetState();
}

class _DownloadTaskItemWidgetState extends State<DownloadTaskItemWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getDayTime(DateTime beginTime) {
    return formatDate(beginTime, ['yyyy', '-', 'mm', '-', 'dd']);
  }

  String _getDuration(DateTime beginTime, DateTime endTime) {
    List<String> format = ['HH', ':', 'nn', ':', 'ss'];
    return '${formatDate(beginTime, format)} - ${formatDate(endTime, format)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.record.download) {
          if (Platform.isAndroid) {
            OpenFile.open(widget.record.saveFilePath);
          } else if (Platform.isIOS) {
            JFApi.xcVideoPlay.xcPlayNormalVideo(widget.record.saveFilePath);
          } else {
            JFApi.xcVideoPlay
                .xcPlayLocalVideoOnOhos(widget.record.saveFilePath);
          }
        }
      },
      child: Container(
        height: 62,
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        child: Row(
          children: [
            GestureDetector(
                onTap: () {
                  if (widget.record.download) {
                    if (Platform.isAndroid) {
                      OpenFile.open(widget.record.saveFilePath);
                    } else if (Platform.isIOS) {
                      JFApi.xcVideoPlay
                          .xcPlayNormalVideo(widget.record.saveFilePath);
                    } else {
                      JFApi.xcVideoPlay
                          .xcPlayLocalVideoOnOhos(widget.record.saveFilePath);
                    }
                    return;
                  }

                  if (widget.record.downloading ||
                      widget.record.downloadProgress.state ==
                          DownloadState.loading ||
                      widget.record.downloadProgress.state ==
                          DownloadState.changing) {
                    DownloadHistory.instance
                        .cancelDownload(widget.deviceId, widget.record);
                  } else {
                    //这里应该去检查是否可以直接下载
                    //直接下载[当前没有正在下载的任务,否则需要取消正在下载的任务],核心原因是不支持并行下载
                    DownloadHistory.instance
                        .checkStartDownload(widget.deviceId, widget.record);
                  }
                },
                child: Row(children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getDayTime(widget.record.beginTime!),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                              _getDuration(widget.record.beginTime!,
                                  widget.record.endTime!),
                              style: const TextStyle(
                                fontSize: 11,
                                overflow: TextOverflow.ellipsis,
                              )),
                          const SizedBox(width: 8),
                          widget.record is CardRecord
                              ? Text(
                                  _getFileSize((widget.record as CardRecord)
                                          .fileLength ??
                                      0),
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ))
                              : const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 100),
                  Text(widget.record.downloadProgress.state ==
                          DownloadState.error
                      ? '失败'
                      : (widget.record.downloadProgress.state ==
                              DownloadState.done
                          ? '完成'
                          : widget.record.downloadProgress.progress.toString()))
                ])),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  String _getFileSize(int sizeInKB) {
    if (sizeInKB < 1024) {
      return '${sizeInKB}KB';
    } else {
      double sizeInMB = sizeInKB / 1024;
      return '${sizeInMB.toInt().toString()}M';
    }
  }
}
