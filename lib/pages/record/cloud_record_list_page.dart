// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/media/media_player.dart';

import '../../common/code_prase.dart';
import '../../common/common_path.dart';
import '../../common/named_route.dart';
import '../../generated/l10n.dart';
import '../../models/user_instance.dart';
import '../../views/calendar/rf_calendar.dart';
import '../../views/play_control_view.dart';
import '../../views/toast/toast.dart';
import '../download_manage/cloud_download_manage_page.dart';

import '../download_manage/model/record_file.dart';
import 'controller/clould_record_controller.dart';
import 'model/model.dart';
import 'record_download_manager_page.dart';
import 'record_list_page.dart';

///云回放列表
class CloudRecordListPage extends StatefulWidget {
  final String deviceId;

  const CloudRecordListPage({Key? key, required this.deviceId})
      : super(key: key);

  @override
  State<CloudRecordListPage> createState() => _CloudRecordListPageState();
}

class _CloudRecordListPageState extends State<CloudRecordListPage>
    with WidgetsBindingObserver, RouteAware {
  late BuildContext _context;
  late CloudRecordController _controller;
  int lastIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    initMediaPlay();
  }

  void initMediaPlay() async {
    _controller = CloudRecordController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    //取消监听视图生命周期
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _onResume();
    } else if (state == AppLifecycleState.paused) {
      _onStop();
    }
  }

  @override
  void didPushNext() {
    super.didPushNext();
    _onStop();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _onResume();
  }

  void _onStop() {
    _context.read<CloudRecordController>().onStop();
  }

  void _onResume() {
    _context.read<CloudRecordController>().onResume();
  }

  final ItemScrollController fileScrollController = ItemScrollController();
  bool _scrolling = false;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _controller
        ..initListeners(widget.deviceId)
        ..getCloudRecords()
        ..getRecordTimeline()
        ..addProgressListener((position, start, end, extraInfo) {
          _controller.position = position;
          int index = lastIndex;
          for (int i = _controller.records.length - 1; i >= 0; i--) {
            CloudRecord record = _controller.records[i];

            ///时间晚于录像开始时间，早于录像结束时间说明在当前录像段播放
            if (position.isAfter(record.beginTime ?? DateTime.now()) &&
                position.isBefore(record.endTime ?? DateTime.now())) {
              index = i;
              break;
            }
          }

          if (fileScrollController.isAttached &&
              _scrolling == false &&
              index < _controller.records.length) {
            lastIndex = index;
            //滑动到对应位置
            fileScrollController.scrollTo(
                index: index, duration: const Duration(milliseconds: 50));
          }
        }),
      builder: (context, child) {
        return Consumer<CloudRecordController>(
          builder: (context, controller, child) {
            _context = context;
            return OrientationBuilder(builder: (context, orientation) {
              return Scaffold(
                appBar: orientation == Orientation.portrait
                    ? AppBar(
                        title: Text(TR.current.cloudList),
                        centerTitle: true,
                        actions: [
                          PopupMenuButton<String>(
                            onSelected: (value) =>
                                handleMenuClick(context, controller, value),
                            itemBuilder: (context) => [
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
                              const PopupMenuDivider(),
                              const PopupMenuItem<String>(
                                value: 'download',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.download,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      width: 15.0,
                                    ),
                                    Text('下载')
                                  ],
                                ),
                              ),
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
                          controller: controller.mediaController,
                        ),
                        Visibility(
                            visible: controller.isLoading,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            )),
                        Visibility(
                          visible: _controller.existRecord,
                          child: MediaPlayControlView(
                            orientation: orientation,
                            mediaController: controller.mediaController,
                            mediaType: MediaType.cloud,
                            playbackCallback: (playing) {
                              controller.playOrPause();
                            },
                          ),
                        ),
                      ],
                    ),
                    ...orientation == Orientation.landscape
                        ? [
                            const SizedBox(
                              height: 0,
                            )
                          ]
                        : [
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 50,
                              child: Visibility(
                                visible: _controller.existRecord,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            controller.snapImage(
                                                devId: widget.deviceId);
                                          },
                                          child:
                                              const Icon(Icons.photo_camera)),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            controller.snapRecord(
                                                devId: widget.deviceId);
                                          },
                                          child: Icon(
                                            Icons.photo_camera_front,
                                            color: controller.isRecording
                                                ? Colors.red
                                                : Colors.white,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 200,
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                  if ((notification
                                              is ScrollUpdateNotification &&
                                          notification.dragDetails != null) ||
                                      (notification
                                              is ScrollStartNotification &&
                                          notification.dragDetails != null)) {
                                    //dragDetails不为null,为手动触发
                                    _scrolling = true;
                                    if (_timer != null && _timer!.isActive) {
                                      _timer!.cancel();
                                    }
                                  } else if (notification
                                      is ScrollEndNotification) {
                                    if (_timer != null && _timer!.isActive) {
                                      _timer!.cancel();
                                    }
                                    _timer = Timer(
                                        const Duration(milliseconds: 500), () {
                                      _scrolling = false;
                                    });
                                  }
                                  return false;
                                },
                                child: ScrollablePositionedList.builder(
                                    itemCount: controller.records.length,
                                    itemScrollController: fileScrollController,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      CloudRecord record =
                                          controller.records[index];
                                      return GestureDetector(
                                        onTap: () {
                                          if (index == lastIndex) {
                                            return;
                                          }
                                          lastIndex = index;
                                          controller.mediaController
                                              .startCloudPlayByTime(
                                                  beginTime: record.beginTime);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: record.select
                                                      ? Colors.blueAccent
                                                      : Colors.black),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(16))),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.68,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: ListTile(
                                                    title: Text(
                                                        '${record.beginTime ?? ''} - ${record.endTime ?? ''}'),
                                                    subtitle: Text(
                                                      record.url ?? '',
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0.0,
                                                  right: 0.0,
                                                  height: 45,
                                                  width: 45,
                                                  child: Container(
                                                    color: Colors.black,
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.arrow_downward,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        _onDownload(
                                                            context, record);
                                                      },
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                            SizedBox(
                              height: 80,
                              child: Visibility(
                                visible: _controller.existRecord,
                                child: TimeLineView(
                                  times: controller.timeline,
                                  currentTime: controller.position,
                                  timeChanged: (dateTime) {
                                    controller.timelineChanged(dateTime);
                                  },
                                ),
                              ),
                            )
                          ]
                  ],
                ),
              );
            });
          },
        );
      },
    );
  }

  //下载
  _onDownload(BuildContext context, CloudRecord record) async {
    //var/mobile/Containers/Data/Application/9AE07893-DF4E-44C8-982F-83352518E370/Documents/jf_images/jf_image34234234234234ds23d 2023-05-25 21_16_34 175.jpg
    String deviceId = widget.deviceId;

    ///推出下载管理页面
    final pContext = _context;
    // ignore: use_build_context_synchronously
    Navigator.of(pContext).push(MaterialPageRoute(builder: (context) {
      return RecordDownloadManagerPage(
        deviceId: deviceId,
        records: [
          CloudRecord(
              beginTime: record.beginTime,
              endTime: record.endTime,
              url: record.url,
              channel: record.channel,
              indexFile: record.indexFile,
              thumbnail: record.thumbnail,
              fileLength: record.fileLength)
        ],
        copyToLocal: false,
      );
    })).then((_) => {}); //返回时重新播放
  }

  ///展示日历
  _showCalendar(BuildContext context, CloudRecordController controller) async {
    ///有数据的日期
    Map<DateTime, int> hasDataDateMap = {};
    showRFCalendar(
        context: context,
        beginDatetime: DateTime(2016, 7, 1),
        endDatetime: DateTime.now(),
        hasDataDateMap: hasDataDateMap,
        selectedDate: controller.currentDateTime,
        onSelected: (DateTime selectedDateTime) {
          if (kDebugMode) {
            print(selectedDateTime);
          }
          controller.selectDateTime(selectedDateTime);
        },
        onChangeMonth: (DateTime currentMonth,
            dynamic Function(Map<DateTime, int>) onCallBack) async {
          KToast.show();
          final r = await _onQueryHasDataDateCalendar(currentMonth);
          onCallBack(r);
          KToast.dismiss();
        });
  }

  ///查询某月是否有录像数据
  Future<Map<DateTime, int>> _onQueryHasDataDateCalendar(
      DateTime dateTime) async {
    ///有数据的日期
    Map<DateTime, int> hasDataDateMap = {};
    try {
      final hasDataDateList = await JFApi.xcAlarmMessage.xcAlarmVideoCalendar(
          deviceId: widget.deviceId,
          userId: UserInfo.instance.userId,
          monthDateTime: dateTime);
      for (String dateStr in hasDataDateList) {
        DateTime dateTime = DateTime.parse(dateStr);
        hasDataDateMap[dateTime] = 1;
      }
      return Future.value(hasDataDateMap);
    } catch (error) {
      KToast.show(status: KErrorMsg(error));
    }
    return {};
  }

  void handleMenuClick(
      BuildContext context, CloudRecordController controller, String value) {
    switch (value) {
      case 'Calender':
        {
          _showCalendar(context, controller);
        }
        break;
      case 'download':
        {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return RecordDownloadManagerPage(
              deviceId: controller.devId,
              records: const [],
              copyToLocal: false,
            );
          }));
        }
        break;
    }
  }
}
