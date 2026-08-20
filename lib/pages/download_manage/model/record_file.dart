import 'dart:convert';

import 'package:fcloudsdk/media/download/meida_download_controller.dart';
import 'package:fcloudsdk/utils/date_util.dart';
import 'package:fcloudsdk/utils/num_util.dart';
import 'package:fcloudsdk_example/utils/extentions.dart';

class RecordFile {
  DateTime? beginTime;
  DateTime? endTime;
  int? fileLength;
  int? channel;

  ///正在播放
  bool playing;

  ///缩略图
  String? thumbnail;

  ///是否已经下载
  bool download = false;

  ///是否正在下载
  bool downloading = false;

  ///下载状态
  DownloadProgressState downloadProgress =
      DownloadProgressState(state: DownloadState.none);

  ///下载文件保存地址
  String saveFilePath = '';

  ///是否选中
  bool select = false;

  ///选中删除下载
  bool downloadDelete = false;

  String get key => '';

  RecordFile({
    this.beginTime,
    this.endTime,
    this.fileLength,
    this.playing = false,
    this.select = false,
    this.thumbnail,
    this.channel,
  });

  String durationString() {
    Duration d = duration();
    if (d.inSeconds == 0) {
      return '0’';
    }
    return '${d.inMinutes.toStringAsPreFixed()}’${(d.inSeconds % 60).toStringAsPreFixed()}”';
  }

  Duration duration() {
    if (beginTime == null || endTime == null) {
      return const Duration(seconds: 0);
    }
    return endTime!.difference(beginTime!);
  }

  String beginTimeString() {
    if (beginTime == null) {
      return '';
    }
    return '${beginTime!.hour.toStringAsPreFixed()}:${beginTime!.minute.toStringAsPreFixed()}:${beginTime!.second.toStringAsPreFixed()}';
  }

  String timeInfoString() {
    var map = {
      "BeginTime": (beginTime?.millisecondsSinceEpoch ?? 0) ~/ 1000,
      "EndTime": (endTime?.millisecondsSinceEpoch ?? 0) ~/ 1000,
    };
    if (channel != null && channel != 0) {
      map.addAll({"DownloadStreamIndex": channel!});
    }
    return jsonEncode(map);
  }
}

class CardRecord extends RecordFile {
  int? diskNo;
  String? fileName;
  int? serialNo;

  CardRecord({
    super.beginTime,
    this.diskNo = 0,
    super.endTime,
    super.fileLength = 0,
    this.fileName = '',
    this.serialNo = 0,
    super.thumbnail,
    super.playing = false,
    super.channel,
  });

  CardRecord.fromJson(Map<String, dynamic> json) {
    beginTime = DateUtil.fromDateString(json['BeginTime']);
    diskNo = json['DiskNo'] ?? 0;
    endTime = DateUtil.fromDateString(json['EndTime']);
    fileLength = NumUtil.hexToInt(json['FileLength']);
    fileName = json['FileName'] ?? '';
    serialNo = json['SerialNo'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Channel'] = channel ?? 0;
    data['SaveFileLen'] = fileLength;
    data['StreamType'] = 0;
    data['BeginTime'] = DateUtil.formatDateTime(beginTime!);
    data['EndTime'] = DateUtil.formatDateTime(endTime!);
    data['FileName'] = fileName;
    return data;
  }

  CardRecord copyWith({
    DateTime? beginTime,
    int? diskNo,
    DateTime? endTime,
    int? fileLength,
    String? fileName,
    int? serialNo,
    String? thumbnail,
    bool? playing,
    int? channel,
  }) {
    return CardRecord(
      beginTime: beginTime ?? this.beginTime,
      diskNo: diskNo ?? this.diskNo,
      endTime: endTime ?? this.endTime,
      fileLength: fileLength ?? this.fileLength,
      fileName: fileName ?? this.fileName,
      serialNo: serialNo ?? this.serialNo,
      thumbnail: thumbnail ?? this.thumbnail,
      playing: playing ?? this.playing,
      channel: channel ?? this.channel,
    );
  }

  ///卡回放可以走时间下载，所以时间也是key
  @override
  String get key =>
      "${beginTime.toString()}_${endTime.toString()}_${fileName ?? ''}_${channel ?? 0}";
}
