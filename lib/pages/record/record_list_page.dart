// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/media/media_player.dart';
import 'package:xcloudsdk_flutter/model/dev_record.dart';
import 'package:xcloudsdk_flutter/utils/date_util.dart';
import 'package:time/time.dart';
import 'package:xcloudsdk_flutter/utils/logger.dart';
import 'package:xcloudsdk_flutter/utils/num_util.dart';
import 'package:xcloudsdk_flutter/widgets/images_jf.dart';
import 'package:xcloudsdk_flutter_example/common/named_route.dart';
import 'package:xcloudsdk_flutter_example/common/common_path.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/download_manage/download_manage_page.dart';
import 'package:xcloudsdk_flutter_example/pages/download_manage/model/record_file.dart';
import 'package:xcloudsdk_flutter_example/pages/record/record_file_pic_page.dart';
import 'package:xcloudsdk_flutter_example/views/calendar/rf_calendar.dart';
import 'package:intl/intl.dart' as intl;
import 'package:xcloudsdk_flutter_example/views/play_control_view.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

import '../../common/code_prase.dart';

///{
///         "BeginTime": "2023-04-27 04:00:00",
///         "DiskNo": 0,
///         "EndTime": "2023-04-27 05:00:00",
///         "FileLength": "0x00112C9F",
///         "FileName": "/idea0/2023-04-27/001/04.00.00-05.00.00[R][@1c4][0].h264",
///         "SerialNo": 0
///     }
class DevFileRecord {
  DateTime? beginTime;
  int? diskNo;
  DateTime? endTime;
  int? fileLength;
  String? fileName;
  int? serialNo;
  String? recordThumbnailLocalPath;

  DevFileRecord(
      {this.beginTime,
      this.diskNo = 0,
      this.endTime,
      this.fileLength = 0,
      this.fileName = '',
      this.serialNo = 0,
      this.recordThumbnailLocalPath});

  DevFileRecord.fromJson(Map<String, dynamic> json) {
    beginTime = DateUtil.fromDateString(json['BeginTime']);
    diskNo = json['DiskNo'] ?? 0;
    endTime = DateUtil.fromDateString(json['EndTime']);
    fileLength = NumUtil.hexToInt(json['FileLength']);
    fileName = json['FileName'] ?? '';
    serialNo = json['SerialNo'] ?? 0;
  }
}

class RecordListPage extends StatefulWidget {
  final String deviceId;

  const RecordListPage({Key? key, required this.deviceId}) : super(key: key);

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage>
    with WidgetsBindingObserver, RouteAware {
  final GlobalKey _key = GlobalKey();
  late final CardMediaController controller;
  DateTime _currentDateTime = DateTime.now(); //可以自定义，外界传进来 DateTime(2023,05,07)
  bool _isLoading = true;
  double progress = 0;
  final int _curChannel = 0;
  final int _curStreamType = 0;
  List<DevFileRecord> records = [];
  DevFileRecord? _record;
  List<int> recordsOfTime = [];
  DateTime? currentTime;
  bool _isMute = true;
  final bool _isRecording = false;
  final ItemScrollController fileScrollController = ItemScrollController();
  bool _scrolling = false;
  Timer? _timer;
  bool _isShowToolBar = false;

  ///查询当天文件是否存在录像.不存在的话 播放器重置, 时间轴不展示.
  bool _existRecord = false;

  @override
  void initState() {
    super.initState();

    //添加监听app生命周期
    WidgetsBinding.instance.addObserver(this);

    initMediaPlay();

    getRecordToPlay();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //添加监听视图生命周期
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    //取消添加监听app生命周期
    WidgetsBinding.instance.removeObserver(this);
    //取消监听视图生命周期
    routeObserver.unsubscribe(this);

    //取消下载视频录像段搜略图
    JFApi.xcMediaDownload.xcDevCancelDownloadRecordThumbnail();
    super.dispose();
  }

  void refreshRecord() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void initMediaPlay() async {
    controller = CardMediaController(deviceId: widget.deviceId);
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    controller.addStatusListener((status) {
      if (mounted) {
        setState(() {
          _isLoading = status == MediaStatus.buffering;
        });
      }
    });
    controller.addErrorListener((code) {
      KToast.show(status: kErrorMsg(code));
    });

    controller.addProgressListener((position, start, end, extraInfo) {
      setState(() {
        currentTime = position;
        int index = 0;
        for (int i = 0; i < records.length; i++) {
          bool contain = position.millisecondsSinceEpoch >=
                  records[i].beginTime!.millisecondsSinceEpoch &&
              position.millisecondsSinceEpoch <=
                  records[i].endTime!.millisecondsSinceEpoch;
          if (contain) {
            _record = records[i];
            index = i;
            break;
          }
        }

        if (fileScrollController.isAttached && _scrolling == false) {
          //滑动到对应位置
          fileScrollController.scrollTo(
              index: index, duration: const Duration(milliseconds: 500));
        }
        //更新时间滑块
        int minutes =
            position.difference(DateUtil.startOfDay(position)).inMinutes;
        progress = minutes.toDouble();
      });
    });
  }

  ///按文件查找录像段-用于实现一个个录像块
  void getRecordToPlay() async {
    try {
      final dataSource = await JFApi.xcDevice.xcFindAllRecordFile(
          deviceId: widget.deviceId,
          param: DevRecordParam(
              channel: _curChannel,
              streamType: _curStreamType,
              beginTime: DateUtil.startOfDay(_currentDateTime),
              endTime: DateUtil.endOfDay(_currentDateTime)));

      String localPath = await kDirectoryPathSDCardRecordThumbnail();

      records = dataSource.map((e) {
        DevFileRecord record = DevFileRecord.fromJson(e);
        List<String> fileNameList = record.fileName!.split('/');
        String dateString =
            DateUtil.formatDateTimeline(record.beginTime!, true);

        ///获取本地用于存储图片的文件夹(由序列号和开始时间组成)
        String localAlarmPicsPath =
            '/$localPath/${widget.deviceId}_${fileNameList[3]}_$dateString.jpg';
        record.recordThumbnailLocalPath = localAlarmPicsPath;
        return record;
      }).toList();

      if (records.isNotEmpty) {
        _existRecord = true;
        controller.startCardPlayByTime(
            beginTime: DateUtil.startOfDay(_currentDateTime));
        //继续请求时间段数据
        getRecordByTime();
      } else {
        _existRecord = false;
      }
    } catch (error) {
      KToast.show(status: kErrorMsg(error));
      _isLoading = false;
      records = [];
      _existRecord = false;
      //置为空
      recordsOfTime = [];
      _isShowToolBar = false;
    }

    refreshRecord();
  }

  ///按时间查找录像段-用于画时间轴
  void getRecordByTime() async {
    try {
      final dataSource = await JFApi.xcDevice.xcFindRecordFileByTime(
          deviceId: widget.deviceId,
          param: DevRecordByTimeParam(
              beginTime: DateUtil.startOfDay(_currentDateTime),
              endTime: DateUtil.endOfDay(_currentDateTime)));

      for (var element in dataSource) {
        recordsOfTime.add(element >> 4);
        recordsOfTime.add(element & 15);
      }
      _isShowToolBar = true;
    } catch (error) {
      ///错误 两个数据源都置为空
      records = [];
      recordsOfTime = [];
      _isShowToolBar = false;
    }

    refreshRecord();
  }

  void _onDownload(BuildContext context, DevFileRecord record) async {
    //先停止播放
    // await controller.onStop(); //要加await, 等停下来再下一步

    CardRecord model = CardRecord();
    model.channel = _curChannel;
    model.beginTime = record.beginTime;
    model.endTime = record.endTime;
    model.fileName = record
        .fileName; //   /idea0/2023-06-02/001/10.59.13-11.00.00[R][@3b][0].h264
    model.fileLength = record.fileLength;

    //拼装timeStr字段
    final time = model.fileName!
        .split('[')[0]; // /idea0/2023-06-02/001/10.59.13-11.00.00
    final times = time.split('/');
    final date = times[2];
    final timeDetail = times[4].split('.').join('_').split('-').join(' '); //
    String timeStr = '$date $timeDetail';

    ///获取本地存储路径
    String directoryPath = await kDirectoryPathVideos();
    String deviceId = widget.deviceId;
    String channel = 'channel$_curChannel'; //预留通道位置
    String vidoePath =
        '/$directoryPath/$kPrefixVideo$deviceId $timeStr $channel.mp4';
    model.saveFilePath = vidoePath;

    if (kDebugMode) {
      print('录像下载模型放入下载中心，开始下载');
    }
    // JFApi.xcMediaDownloadController.xcDownload(model);

    ///推出下载管理页面
    final pContext = _key.currentContext;
    // ignore: use_build_context_synchronously
    Navigator.of(pContext!).push(MaterialPageRoute(builder: (context) {
      return DownloadManagerPage(
        deviceId: deviceId,
        records: [model],
      );
    }));
    // .then((value) => getRecordToPlay()); //返回时重新播放
  }

  ///查询某月是否有录像数据
  Future<Map<DateTime, int>> _onQueryHasDataDateCalendar(
      DateTime dateTime) async {
    ///有数据的日期
    Map<DateTime, int> hasDataDateMap = {};
    final hasDataDateList = await JFApi.xcDevice.xcDeviceSDCalendar(
        deviceId: widget.deviceId,
        monthDateTime: dateTime,
        fileType: 'h264',
        eventType: '*');
    for (String dateStr in hasDataDateList) {
      DateTime dateTime = DateTime.parse(dateStr);
      hasDataDateMap[dateTime] = 1;
    }
    return Future.value(hasDataDateMap);
  }

  void _onPopMenuItemTap(String value) {
    switch (value) {
      case 'Download':
        {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return DownloadManagerPage(
              deviceId: widget.deviceId,
            );
          }));
        }
        break;
      case 'Calender':
        {
          ///有数据的日期
          Map<DateTime, int> hasDataDateMap = {};
          showRFCalendar(
              context: context,
              beginDatetime: DateTime(2016, 7, 1),
              endDatetime: DateTime.now(),
              hasDataDateMap: hasDataDateMap,
              selectedDate: _currentDateTime,
              onSelected: (DateTime selectedDateTime) {
                _onChangeDate(selectedDateTime);
              },
              onChangeMonth: (DateTime currentMonth,
                  dynamic Function(Map<DateTime, int>) onCallBack) async {
                KToast.show();
                final r = await _onQueryHasDataDateCalendar(currentMonth);
                onCallBack(r);
                KToast.dismiss();
              });
        }
        break;
      case 'RecordFile':
        {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return RecordFilePicturePage(
              deviceId: widget.deviceId,
            );
          }));
        }
        break;
    }
  }

  ///切换日期
  _onChangeDate(DateTime dateTime) async {
    ///日期相同不做变化
    if (_currentDateTime == dateTime) {
      return;
    }
    _currentDateTime = dateTime;

    ///先将页面置为空
    records = [];
    recordsOfTime = [];
    refreshRecord();

    ///停止播放
    controller.stop();

    ///再请求数据
    getRecordToPlay();
  }

  ///抓图
  _onSnap() async {
    //获取本地存图片的文件夹路径
    String directoryPath = await kDirectoryPathImages();
    String timeStr =
        intl.DateFormat('yyyy-MM-dd HH_mm_ss SSS').format(DateTime.now());
    String deviceId = widget.deviceId;
    String channel = 'channel0'; //预留通道位置
    String imagePath =
        '/$directoryPath/$kPrefixImage$deviceId $timeStr $channel.jpg';
    KToast.show();
    int code = await controller.snapshot(imagePath);
    if (code >= 0) {
      KToast.show(status: '抓图成功');
    } else {
      KToast.show(status: '抓图失败 $code');
    }
  }

  ///播放/静音
  _onMute() {
    if (_isMute) {
      controller.setVolume(100);
    } else {
      controller.setVolume(0);
    }
    setState(() {
      _isMute = !_isMute;
    });
  }

  String _playbackSpeedText(PlaybackSpeed speed) {
    if (speed == PlaybackSpeed.x4_) return '-4X';
    if (speed == PlaybackSpeed.x2_) return '-2X';
    if (speed == PlaybackSpeed.x2) return '2X';
    if (speed == PlaybackSpeed.x4) return '4X';
    return '1X';
  }

  void _showPlaybackSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择播放倍速'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: PlaybackSpeed.values.reversed.map((speed) {
                return ListTile(
                  title: Text(_playbackSpeedText(speed)),
                  onTap: () {
                    controller.setPlaybackSpeed(speed: speed);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  ///录像
  _onRecord() async {
    if (_isRecording == false) {
      //录像
      //获取本地存图片的文件夹路径
      String directoryPath = await kDirectoryPathVideos();
      String timeStr =
          intl.DateFormat('yyyy-MM-dd HH_mm_ss SSS').format(DateTime.now());
      String deviceId = widget.deviceId;
      String channel = 'channel$_curChannel'; //预留通道位置
      String vidoePath =
          '/$directoryPath/$kPrefixVideo$deviceId $timeStr $channel.mp4';
      await controller.startRecord(vidoePath);
      KToast.show(status: "开始录像");
    } else {
      //结束录像
      await controller.stopRecord();
      KToast.show(status: "录像成功");
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
        key: _key,
        appBar: orientation == Orientation.portrait
            ? AppBar(
                title: Text(TR.current.recordList(widget.deviceId)),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: _onPopMenuItemTap,
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'Download',
                        child: Row(
                          children: [
                            Icon(
                              Icons.download,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Text('Download')
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'Calender',
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Text('Calender')
                          ],
                        ),
                      ),
                      // const PopupMenuDivider(),
                      // const PopupMenuItem<String>(
                      //   value: 'RecordFile',
                      //   child: Row(
                      //     children: [
                      //       Icon(
                      //         Icons.picture_as_pdf,
                      //         color: Colors.black,
                      //       ),
                      //       SizedBox(
                      //         width: 15.0,
                      //       ),
                      //       Text('RecordFile')
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ],
              )
            : null,
        body: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                MediaPlayerWidget(
                  controller: controller,
                ),
                Visibility(
                    visible: _isLoading,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    )),
                Visibility(
                    visible: _existRecord,
                    child: MediaPlayControlView(
                      orientation: orientation,
                      mediaController: controller,
                      mediaType: MediaType.card,
                      playbackCallback: (playing) {
                        if (playing) {
                          controller.pause();
                        } else {
                          controller.playback();
                        }
                      },
                    )),
              ],
            ),
            ...orientation == Orientation.landscape
                ? [const SizedBox()]
                : [
                    Offstage(
                      offstage: !_isShowToolBar,
                      child: Slider(
                        value: progress,
                        min: 0,
                        max: 1440,
                        divisions: 1440,
                        label: getSliderLabel(progress),
                        onChanged: (double value) {
                          setState(() {
                            progress = value;
                          });
                        },
                        onChangeEnd: (value) async {
                          controller.seekTo(
                              DateUtil.startOfDay(null) + value.minutes);
                        },
                      ),
                    ),
                    Visibility(
                      visible: _isShowToolBar && _isLoading == false,
                      maintainAnimation: true,
                      maintainSize: true,
                      maintainState: true,
                      child: SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    _onSnap();
                                  },
                                  child: const Icon(Icons.photo_camera)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    _onMute();
                                  },
                                  child: _isMute
                                      ? const Icon(Icons.volume_off)
                                      : const Icon(Icons.volume_up)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    _onRecord();
                                  },
                                  child: Icon(
                                    Icons.photo_camera_front,
                                    color: _isRecording
                                        ? Colors.red
                                        : Colors.white,
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    _showPlaybackSpeedDialog();
                                  },
                                  child: Text(_playbackSpeedText(
                                      controller.playbackSpeed))),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if ((notification is ScrollUpdateNotification &&
                                  notification.dragDetails != null) ||
                              (notification is ScrollStartNotification &&
                                  notification.dragDetails != null)) {
                            //dragDetails不为null,为手动触发
                            _scrolling = true;
                            if (_timer != null && _timer!.isActive) {
                              _timer!.cancel();
                            }
                          } else if (notification is ScrollEndNotification) {
                            if (_timer != null && _timer!.isActive) {
                              _timer!.cancel();
                            }
                            _timer =
                                Timer(const Duration(milliseconds: 500), () {
                              _scrolling = false;
                            });
                          }
                          return false;
                        },
                        child: ScrollablePositionedList.builder(
                            itemCount: records.length,
                            itemScrollController: fileScrollController,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              DevFileRecord record = records[index];
                              return GestureDetector(
                                onTap: () async {
                                  if (_record == record) {
                                    return;
                                  }
                                  //如果正在录像，那就先停止
                                  if (_isRecording) {
                                    await _onRecord();
                                  }
                                  toRecordPlay(record, index);
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(16)),
                                      border: Border.all(
                                          color: _record == record
                                              ? Colors.blueAccent
                                              : Colors.grey)),
                                  width: 200,
                                  height: 100,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                              child: Text(
                                            record.fileName ?? '',
                                            overflow: TextOverflow.fade,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          )),
                                          Container(
                                            width: 50.0,
                                            height: 42.0,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(16)),
                                            ),
                                            child: TextButton(
                                              onPressed: () async {
                                                _onDownload(context, record);
                                              },
                                              child: const Text(
                                                '下载',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Expanded(
                                          child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(16)),
                                        child: JFImage.thumbnailSDCard(
                                            szDevId: widget.deviceId,
                                            assetName: 'images/monitor_bg.png',
                                            localPath: record
                                                .recordThumbnailLocalPath!,
                                            beginTime: record.beginTime,
                                            endTime: record.endTime),
                                      ))
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                    SizedBox(
                      child: Visibility(
                        visible: _existRecord,
                        child: TimeLineView(
                          times: recordsOfTime,
                          currentTime: currentTime,
                          timeChanged: (_) {
                            timelineSeekTo(_);
                          },
                        ),
                      ),
                      // child: TimeLineView(times: times, timeChanged: timeChanged),
                    )
                  ],
          ],
        ),
      );
    });
  }

  void timelineSeekTo(DateTime dateTime) {
    //判断当前时间是否有录像,若是存在录像,直接seek
    DevFileRecord record = records.firstWhere(
        (element) =>
            dateTime.millisecondsSinceEpoch <=
                element.endTime!.millisecondsSinceEpoch &&
            dateTime.millisecondsSinceEpoch >=
                element.beginTime!.millisecondsSinceEpoch,
        orElse: () => DevFileRecord());
    if (record.beginTime != null) {
      controller.seekTo(dateTime);
    } else {
      //若不存在,则 seek 到和这个时间最近的 文件的 开始时间.
      int lastDt = -1;
      int minIndex = 0;
      for (int i = 0; i < records.length; i++) {
        DevFileRecord record = records[i];
        int dt = (dateTime.millisecondsSinceEpoch -
                record.beginTime!.millisecondsSinceEpoch)
            .abs();
        if (dt < lastDt) {
          minIndex = i;
        }
        lastDt = dt;
      }
      controller.seekTo(records[minIndex].beginTime!);
    }
  }

  void toRecordPlay(DevFileRecord devFileRecord, int index) {
    setState(() {
      _record = records[index];
      _isLoading = true;
    });
    controller.seekTo(devFileRecord.beginTime!);
  }

  String getSliderLabel(double value) {
    DateTime startOfDay = DateUtil.startOfDay(null);
    DateTime currentTime = startOfDay + value.minutes;
    return '${currentTime.year}-${currentTime.month}-${currentTime.day} ${currentTime.hour}:${currentTime.minute}';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        print('app进入前台');
      }
      controller.playback();
    } else if (state == AppLifecycleState.paused) {
      if (kDebugMode) {
        print('app进入后台');
      }
      controller.pause();
    } else if (state == AppLifecycleState.inactive) {
      if (kDebugMode) {
        print('app处于非活跃状态');
      }
    }
  }

  @override
  void didPushNext() {
    super.didPushNext();
    controller.pause();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    controller.playback();
  }
}

typedef TimeChanged = Function(DateTime dateTime);

class TimeLineView extends StatefulWidget {
  const TimeLineView(
      {Key? key,
      required this.times,
      required this.timeChanged,
      this.currentTime,
      this.height = 80,
      this.tickShortHeight = 12,
      this.tickLongHeight = 20,
      this.tickWidth = 1,
      this.tickHeight = 2,
      this.normalColor = Colors.redAccent,
      this.alertColor = Colors.blue,
      this.lineColor = Colors.black,
      this.unit = 20,
      this.unitWidth = 10})
      : super(key: key);

  ///View 高度
  final double height;

  ///刻度线 短 高度
  final double tickShortHeight;

  ///刻度线 长 高度
  final double tickLongHeight;

  ///刻度线 宽度
  final double tickWidth;

  ///中间刻度线 高度
  final double tickHeight;

  ///普通视频颜色
  final Color normalColor;

  ///报警视频颜色
  final Color alertColor;

  ///刻度尺颜色
  final Color lineColor;

  ///间隔 20 分钟或 1分钟
  final int unit;

  ///间隔宽度
  final int unitWidth;

  ///滑动时间轴回调
  final TimeChanged timeChanged;

  ///按时间查询的 时间数据 长度 1440
  final List<int> times;

  ///当前时间轴的开始时间.在播放过程中,通过视频回调不断更新
  final DateTime? currentTime;

  @override
  State<TimeLineView> createState() => _TimeLineViewState();
}

class _TimeLineViewState extends State<TimeLineView> {
  final ScrollController scrollController = ScrollController();

  bool _scrolling = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if ((notification is ScrollUpdateNotification &&
                      notification.dragDetails != null) ||
                  (notification is ScrollStartNotification &&
                      notification.dragDetails != null)) {
                //dragDetails不为null,为手动触发
                _scrolling = true;
              }
              if (notification is ScrollEndNotification &&
                  notification.dragDetails != null) {
                onScrollEnd(notification);
              }
              return false;
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                  CustomPaint(
                    size: getSize(),
                    painter: TimeLineCustomPainter(widget),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                ],
              ),
            )),
        Container(
          alignment: Alignment.center,
          child: Container(
            width: 2,
            height: widget.height,
            color: Colors.redAccent,
          ),
        )
      ],
    );
  }

  @override
  void didUpdateWidget(covariant TimeLineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentTime == null) {
      return;
    }
    if (_scrolling) {
      return;
    }
    if (widget.currentTime != oldWidget.currentTime) {
      //滑动到对应位置, 滑动距离计算
      int minutes = widget.currentTime!
          .difference(DateUtil.startOfDay(widget.currentTime))
          .inMinutes;
      double distance = widget.unitWidth * minutes / widget.unit;
      scrollController.animateTo(distance,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Timer? _timer;

  ///处理在连续滑动过程中,防止过快触发回调
  void onScrollEnd(ScrollEndNotification notification) {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    _timer = Timer(const Duration(milliseconds: 500), () {
      int minutes =
          (widget.unit / widget.unitWidth * notification.metrics.pixels)
              .toInt();
      DateTime startOfDay = DateUtil.startOfDay(widget.currentTime);
      DateTime toTime = startOfDay + minutes.minutes;
      if (widget.currentTime?.millisecondsSinceEpoch ==
          toTime.millisecondsSinceEpoch) {
        _scrolling = false;
        return;
      }
      widget.timeChanged(startOfDay + minutes.minutes);
      Logger.log('Timeline timeChang to ${startOfDay + minutes.minutes}');
      _scrolling = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  double dx = 0;

  ///获取可绘制区域的宽高
  Size getSize() {
    //1440像素值 转化为 dp
    return Size(1440 / widget.unit * widget.unitWidth, widget.height);
  }
}

class TimeLineCustomPainter extends CustomPainter {
  final TimeLineView widget;

  ///需要画刻度的数量
  int tickCount = 0;

  List<int> timeDots = [];

  TimeLineCustomPainter(this.widget) {
    tickCount = 1440 ~/ widget.unit;
    timeDots = widget.times;
  }

  double getTop(Size size, double height) {
    return size.height / 2 - height / 2;
  }

  double getBottom(Size size, double height) {
    return size.height / 2 + height / 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    canvas.drawRect(
        Rect.fromLTRB(
            0, 0, tickCount * widget.unitWidth.toDouble(), size.height),
        Paint()..color = Colors.blueGrey);
    //画背景数据
    for (int i = 0; i < timeDots.length; i++) {
      //一分钟
      int dot = timeDots[i];
      if (dot > 0) {
        canvas.drawLine(
            Offset(i.toDouble() * 0.5, 0),
            Offset(i.toDouble() * 0.5, size.height),
            Paint()
              ..color = widget.alertColor
              ..strokeWidth = 0.6);
      }
    }
    //画刻度
    for (int i = 0; i <= tickCount; i++) {
      if (i == 0 || i == tickCount) {
        continue;
      }
      if (i % 3 == 0) {
        canvas.drawLine(
            Offset(i * widget.unitWidth.toDouble(),
                getTop(size, widget.tickLongHeight)),
            Offset(i * widget.unitWidth.toDouble(),
                getBottom(size, widget.tickLongHeight)),
            Paint()
              ..color = widget.lineColor
              ..strokeWidth = widget.tickWidth);
        drawText(i, canvas, size);
      } else {
        canvas.drawLine(
            Offset(i * widget.unitWidth.toDouble(),
                getTop(size, widget.tickShortHeight)),
            Offset(i * widget.unitWidth.toDouble(),
                getBottom(size, widget.tickShortHeight)),
            Paint()
              ..color = widget.lineColor
              ..strokeWidth = widget.tickWidth);
      }
      //画水平线
      canvas.drawLine(
          Offset(0, size.height / 2),
          Offset(tickCount * widget.unitWidth.toDouble(), size.height / 2),
          Paint()
            ..color = widget.lineColor
            ..strokeWidth = widget.tickWidth);
    }
  }

  void drawText(int i, Canvas canvas, Size size) {
    var textPainter = TextPainter(
        text: TextSpan(
            text: "${i ~/ 3}",
            style: const TextStyle(fontSize: 10, color: Colors.black)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left);
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(i * widget.unitWidth - 3,
            getBottom(size, widget.tickLongHeight) + 5));
  }

  @override
  bool shouldRepaint(covariant TimeLineCustomPainter oldDelegate) {
    return true;
  }
}
