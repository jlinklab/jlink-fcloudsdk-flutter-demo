// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/foundation.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/model/dev_record.dart';
import 'package:xcloudsdk_flutter/utils/date_util.dart';
import 'package:xcloudsdk_flutter/utils/extensions.dart';
import 'package:xcloudsdk_flutter_example/common/common_path.dart';
import 'package:xcloudsdk_flutter_example/models/user_instance.dart';
import 'package:xcloudsdk_flutter_example/pages/record/model/model.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';
import 'package:intl/intl.dart' as intl;
import 'package:time/time.dart';
import 'package:xcloudsdk_flutter/media/media_player.dart';
import '../../../common/code_prase.dart';

class CloudRecordController extends ChangeNotifier {
  late final CloudMediaController mediaController;

  ///回放文件列表
  List<CloudRecord> records = [];

  ///时间轴
  List<int> timeline = [];

  ///是否正在缓冲
  bool get isLoading => _status == MediaStatus.buffering;

  ///是否展示播放暂停按钮
  bool isShowPlay = false;

  ///当前是否正在播放
  bool get isPlaying => _status == MediaStatus.playing;

  ///媒体状态
  MediaStatus _status = MediaStatus.none;

  MediaStatus get mediaStatus => _status;

  ///当前进度
  DateTime _position = DateUtil.startOfDay(DateTime.now());

  DateTime get position => _position;

  set position(DateTime dateTime) {
    _position = dateTime;

    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!hasListeners) {
      return;
    }
    super.notifyListeners();
  }

  ///是否存在录像文件
  bool get existRecord => records.isNotEmpty;

  ///当前日期.用于切换日期
  DateTime currentDateTime = DateTime.now();

  late final String devId;

  ///初始化监听
  void initListeners(String devId) {
    this.devId = devId;
    mediaController = CloudMediaController(deviceId: devId);
    mediaController.addListener(() {
      notifyListeners();
    });
    mediaController.addStatusListener((status) {
      _status = status;
      notifyListeners();
      if (_status == MediaStatus.completed) {
        _playNext();
      }
    });
  }

  void addProgressListener(MediaProgressListener listener) {
    mediaController.addProgressListener(listener);
  }

  ///自动播放下一个
  void _playNext() {
    CloudRecord? currentRecord = records.firstWhereOrNull((e) => e.select);
    if (currentRecord != null) {
      if (records.indexOf(currentRecord) < records.length - 1) {
        // startCloudRecordByUrl(
        //     record: records[records.indexOf(currentRecord) + 1]);
      }
    }
  }

  ///获取文件列表
  void getCloudRecords() async {
    records.clear();

    await JFApi.xcDevice
        .xcFindAllCloudRecordFile(
            param: CloudRecordByTime(
                msg: 'video_query',
                userId: UserInfo.instance.userId,
                sn: devId,
                startTime: DateUtil.startOfDay(currentDateTime),
                endTime: DateUtil.endOfDay(currentDateTime)))
        .then((value) {
      List<Map<String, dynamic>> list = value;

      for (int i = 0; i < list.length; i++) {
        Map<String, dynamic> map = list[i];
        CloudRecordResult result = CloudRecordResult.fromJson(map);
        records.addAll(result.records ?? []);
      }

      notifyListeners();
      if (records.isNotEmpty) {
        // startCloudRecordByUrl(record: records[0]);

        mediaController.startCloudPlayByTime();
      } else {
        KToast.show(status: '暂无录像');
      }
    }).catchError((error) {
      KToast.show(status: KErrorMsg(error));
    });
  }

  ///获取时间轴
  void getRecordTimeline() async {
    final json = await JFApi.xcDevice.xcFindCloudRecordAxis(
        param: CloudRecordAXis(
            sn: devId,
            startTime: DateUtil.startOfDay(currentDateTime),
            endTime: DateUtil.endOfDay(currentDateTime)));
    CloudTimelineResult result = CloudTimelineResult.fromJson(json);

    List<TimeAxis> timeAxisList = result.timeAxis ?? [];
    List<int> times = List.generate(1440, (index) => 0);
    if (timeAxisList.isNotEmpty) {
      for (var timeAxis in timeAxisList) {
        DateTime? startTime = timeAxis.startTime;
        int startMin = -1;
        if (startTime != null) {
          //获取分钟
          startMin = startTime.hour * 60 + startTime.minute;
        }
        DateTime? endTime = timeAxis.endTime;
        int endMin = -1;
        if (endTime != null) {
          //获取分钟
          endMin = endTime.hour * 60 + endTime.minute;
        }
        //处理中间值
        if (startMin > 0 && endMin > 0) {
          for (int i = startMin; i <= endMin; i++) {
            times[i] = timeAxis.type ?? 0;
          }
        }
      }
    }
    timeline.clear();
    timeline.addAll(times);
    notifyListeners();
  }

  // ///开始播放
  // void startCloudRecordByUrl({required CloudRecord record}) async {
  //   int playHandle =
  //       await mediaController.startCloudRecordByUrl(vidUrl: record.url ?? '');
  //   if (playHandle > 0) {
  //     for (var element in records) {
  //       element.select = element.url == record.url;
  //     }
  //     notifyListeners();
  //   }
  // }

  ///播放 or 暂停
  void playOrPause() async {
    if (isPlaying) {
      mediaController.pause();
    } else {
      mediaController.playback();
    }
  }

  Future<void> onStop() async {
    mediaController.pause();
  }

  Future<void> onResume() async {
    mediaController.playback();
  }

  ///展示播放按钮
  void showPlayUI() {
    isShowPlay = !isShowPlay;
    Future.delayed(const Duration(seconds: 3), () {
      isShowPlay = false;
      if (hasListeners) {
        notifyListeners();
      }
    });
    notifyListeners();
  }

  ///抓图
  void snapImage({required String devId}) async {
    //获取本地存图片的文件夹路径
    String directoryPath = await kDirectoryPathImages();
    String timeStr =
        intl.DateFormat('yyyy-MM-dd HH_mm_ss SSS').format(DateTime.now());
    String channel = 'channel0'; //预留通道位置
    String imagePath =
        '/$directoryPath/$kPrefixImage$devId $timeStr $channel.jpg';
    int code = await mediaController.snapshot(imagePath);
    if (code >= 0) {
      KToast.show(status: '抓图成功');
    } else {
      KToast.show(status: '抓图失败');
    }
  }

  bool isRecording = false;

  ///录像
  void snapRecord({required String devId, int currentChannel = 0}) async {
    if (isRecording == false) {
      //录像
      //获取本地存图片的文件夹路径
      String directoryPath = await kDirectoryPathVideos();
      String timeStr =
          intl.DateFormat('yyyy-MM-dd HH_mm_ss SSS').format(DateTime.now());

      String channel = 'channel$currentChannel'; //预留通道位置
      String videoPath =
          '/$directoryPath/$kPrefixVideo$devId $timeStr $channel.mp4';
      int code = await mediaController.startRecord(videoPath);
      KToast.show(status: '开始录像');
    } else {
      //结束录像
      int code = await mediaController.stopRecord();
      KToast.show(status: "录像成功");
    }
  }

  ///切换时间
  void selectDateTime(DateTime dateTime) {
    if (dateTime.isAtSameDayAs(currentDateTime)) {
      return;
    }
    currentDateTime = dateTime;
    getCloudRecords();
    getRecordTimeline();
    notifyListeners();
  }

  ///时间轴切换时间.查找最近文件进行播放
  void timelineChanged(DateTime dateTime) async {
    //判断当前时间是否有录像,若是存在录像,直接seek
    // CloudRecord? record = records.firstWhereOrNull((element) =>
    //     dateTime.millisecondsSinceEpoch <=
    //         element.endTime.millisecondsSinceEpoch &&
    //     dateTime.millisecondsSinceEpoch >=
    //         element.beginTime.millisecondsSinceEpoch);
    // if (record != null) {
    //   startCloudRecordByUrl(record: record);
    // } else {
    //   //若不存在,则 seek 到和这个时间最近的 文件的 开始时间.
    //
    //   int lastDt = -1;
    //   int minIndex = 0;
    //   for (int i = 0; i < records.length; i++) {
    //     CloudRecord record = records[i];
    //     int dt = (dateTime.millisecondsSinceEpoch -
    //             record.beginTime.millisecondsSinceEpoch)
    //         .abs();
    //     if (dt < lastDt) {
    //       minIndex = i;
    //     }
    //     lastDt = dt;
    //   }
    //   startCloudRecordByUrl(record: records[minIndex]);
    // }
    mediaController.seekTo(dateTime);
  }
}
