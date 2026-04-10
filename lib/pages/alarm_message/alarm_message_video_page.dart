import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/media/media_player.dart';
import 'package:xcloudsdk_flutter/model/dev_record.dart';
import 'package:xcloudsdk_flutter/utils/date_util.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/models/user_instance.dart';
import 'package:xcloudsdk_flutter_example/pages/alarm_message/model/model.dart';
import 'package:xcloudsdk_flutter_example/pages/record/alarmplaytoolbar/alarmplaytoolbar.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

import '../../views/play_control_view.dart';
import '../download_manage/model/record_file.dart';
import '../record/model/model.dart';

// ignore: must_be_immutable
class AlarmMsgVideo extends StatefulWidget {
  AlarmMsgVideo({Key? key, required this.msg, required this.deviceId})
      : super(key: key);

  String deviceId;

  AlarmMessage msg;

  @override
  State<AlarmMsgVideo> createState() => _AlarmMsgVideoState();
}

class _AlarmMsgVideoState extends State<AlarmMsgVideo>
    with WidgetsBindingObserver {
  late CloudMediaController controller;
  bool isLoading = true;
  double currentTime = 0;
  double videoLength = 0;
  CloudRecord? _record;

  ///记录查询短视频开始时间和真实码流数据开始的时间
  double timeError = 0;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
        appBar: orientation == Orientation.portrait
            ? AppBar(
                title: Text(TR.current.cloudVideo),
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
                  visible: isLoading,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                MediaPlayControlView(
                  orientation: orientation,
                  mediaController: controller,
                  mediaType: MediaType.cloud,
                  playbackCallback: (playing) {
                    if (playing) {
                      controller.pause();
                    } else {
                      controller.playback();
                    }
                  },
                )
              ],
            ),
            ...orientation == Orientation.landscape
                ? [const SizedBox()]
                : [
                    AlarmPlayToolBar(
                      videoLength: videoLength,
                      currentTime: currentTime,
                    ),
                  ]
          ],
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();

    //添加监听app生命周期
    WidgetsBinding.instance.addObserver(this);

    controller = CloudMediaController(deviceId: widget.deviceId);
    controller.addStatusListener((status) {
      setState(() {
        if (kDebugMode) {
          print(status);
        }
        isLoading = status == MediaStatus.buffering;
      });
    });

    controller.addProgressListener((position, start, end, extraInfo) {
      if (kDebugMode) {
        print('rate:$position');
      }
      DateTime startTime = _record!.beginTime!;
      currentTime = position.difference(startTime).inSeconds.toDouble();
      setState(() {
        if (currentTime <= 0 && timeError == 0) {
          timeError = currentTime;
          currentTime = 0;
        } else {
          currentTime = currentTime - timeError;
        }
      });
    });

    _getDataSource();
  }

  @override
  void dispose() {
    super.dispose();
    //取消添加监听app生命周期
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      controller.playback();
    } else if (state == AppLifecycleState.paused) {
      if (kDebugMode) {
        print('app进入后台');
      }
      controller.pause();
    }
  }

  void _getDataSource() async {
    DateTime datetime = DateUtil.fromDateString(widget.msg.tm!);
    int point = datetime.millisecondsSinceEpoch;

    DateTime startDateTime = DateTime.fromMillisecondsSinceEpoch(point - 5000);
    DateTime endDateTime = DateTime.fromMillisecondsSinceEpoch(point + 10000);

    if (mounted) {
      String userid = context.read<UserInfo>().userId;

      CloudRecordByTime model = CloudRecordByTime(
          msg: 'short_video_query_user',
          userId: userid,
          sn: widget.deviceId,
          startTime: startDateTime,
          endTime: endDateTime);

      List<CloudRecord> records = [];

      await JFApi.xcDevice.xcFindAllCloudRecordFile(param: model).then((value) {
        List<Map<String, dynamic>> list = value;
        CloudRecordResult result = CloudRecordResult.fromJson(list.first);
        records.addAll(result.records ?? []);
        _record = records.first;
        DateTime startTime = _record!.beginTime!;
        DateTime endTime = _record!.endTime!;

        videoLength = endTime.difference(startTime).inSeconds.toDouble();

        controller.startCloudPlayByUrl(url: _record!.url!);
      }).catchError((error) {
        KToast.show(status: KErrorMsg(error));
      });
    }
  }
}
