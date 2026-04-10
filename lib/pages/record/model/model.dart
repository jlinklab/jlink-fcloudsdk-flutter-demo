import 'package:xcloudsdk_flutter/utils/date_util.dart';

import '../../download_manage/model/record_file.dart';

class CloudRecordResult {
  String? msg;
  String? code;
  List<CloudRecord>? records;

  CloudRecordResult(this.msg, this.code, this.records);

  CloudRecordResult.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    code = json['code'];
    if (json['vidlist'] != null) {
      records = json['vidlist']
          .map<CloudRecord>((e) => CloudRecord.fromJson(e))
          .toList();
    }
  }
}

class CloudRecord extends RecordFile {
  String? url;
  String indexFile = '';

  CloudRecord({
    super.beginTime,
    super.endTime,
    super.fileLength,
    super.playing = false,
    super.thumbnail,
    super.channel,
    this.indexFile = '',
    this.url,
  });

  CloudRecord.fromJson(Map<String, dynamic> json) {
    beginTime = DateUtil.fromDateString(json['st']);
    endTime = DateUtil.fromDateString(json['et']);
    fileLength = json['vidsz'];
    url = json['vidUrl'];
    thumbnail = json['picUrl'];
    indexFile = json['indx'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    return data;
  }

  @override
  String get key => "${indexFile}_${channel ?? 0}";
}

class CloudTimelineResult {
  String? msg;
  String? code;
  String? dt;
  List<TimeAxis>? timeAxis;

  CloudTimelineResult(this.msg, this.code, this.dt, this.timeAxis);

  CloudTimelineResult.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    code = json['code'];
    dt = json['dt'];
    if (json['tmaix'] != null && json['tmaix'].isNotEmpty) {
      timeAxis =
          json['tmaix'].map<TimeAxis>((e) => TimeAxis.fromJson(e)).toList();
    }
  }
}

class TimeAxis {
  DateTime? startTime;
  DateTime? endTime;
  int? type;

  TimeAxis(this.startTime, this.endTime, this.type);

  TimeAxis.fromJson(Map<String, dynamic> json) {
    startTime = DateUtil.fromDateString(json['st']);
    endTime = DateUtil.fromDateString(json['et']);
    type = json['tp'];
  }
}
