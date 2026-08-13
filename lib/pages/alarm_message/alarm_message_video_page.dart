import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/media/media_download.dart';
import 'package:xcloudsdk_flutter/media/media_player.dart';
import 'package:xcloudsdk_flutter/model/dev_record.dart';
import 'package:xcloudsdk_flutter/utils/date_util.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/common/common_path.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/models/user_instance.dart';
import 'package:xcloudsdk_flutter_example/pages/alarm_message/model/model.dart';
import 'package:xcloudsdk_flutter_example/pages/album/album_page.dart';
import 'package:xcloudsdk_flutter_example/pages/record/alarmplaytoolbar/alarmplaytoolbar.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

import '../../views/play_control_view.dart';
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
  bool _isDownloading = false;
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
                actions: [
                  if (_record != null)
                    IconButton(
                      icon: _isDownloading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download),
                      onPressed: _isDownloading ? null : _downloadVideo,
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
      if (mounted) {
        setState(() {
          if (kDebugMode) {
            print(status);
          }
          isLoading = status == MediaStatus.buffering;
        });
      }
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

  ///【needUserCheck】
  ///是否校验userid 例如在A账号下产生的报警消息，又把此设备添加到了B账号下，在B账号下也产生了新的回放/告警。
  ///A只能查到设备被B重新添加前的回放/告警，B只能查看到设备被B添加后的回放和告警
  void _getDataSource({bool needUserCheck = false}) async {
    DateTime datetime = DateUtil.fromDateString(widget.msg.tm!);
    int point = datetime.millisecondsSinceEpoch;

    DateTime startDateTime = DateTime.fromMillisecondsSinceEpoch(point - 5000);
    DateTime endDateTime = DateTime.fromMillisecondsSinceEpoch(point + 10000);

    if (mounted) {
      String userid = context.read<UserInfo>().userId;

      CloudRecordByTime model = CloudRecordByTime(
          msg: needUserCheck ? 'short_video_query_user' : 'short_video_query',
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

        controller.startCloudPlayByTime(
          playType: CloudVideoPlayType.short_video_play,
          channel: 0,
          beginTime: startTime,
          endTime: endTime,
        );
      }).catchError((error) {
        KToast.show(status: kErrorMsg(error));
      });
    }
  }

  /// 下载视频并保存到系统相册 + app相册
  Future<void> _downloadVideo() async {
    if (_isDownloading || _record?.url == null) return;
    setState(() => _isDownloading = true);
    CloudVideoDownloadController? downloadController;
    try {
      KToast.show(status: '开始下载...');
      final tempDir = await getTemporaryDirectory();
      final tempPath =
          '${tempDir.path}/alarm_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      downloadController = CloudVideoDownloadController(
        url: _record!.url!,
        fileName: tempPath,
      );
      final completer = Completer<bool>();
      downloadController.setDownloadProgressListener((state) {
        if (state.state == DownloadState.done) {
          if (!completer.isCompleted) completer.complete(true);
        } else if (state.state == DownloadState.error) {
          if (!completer.isCompleted) completer.complete(false);
        }
      });
      await downloadController.startDownload();
      final success = await completer.future;
      if (!success) {
        KToast.show(status: TR.current.saveFailed);
        return;
      }
      // 保存到系统相册
      final result = await ImageGallerySaver.saveFile(tempPath);
      // 同步保存到app相册
      await _saveToAppAlbum(tempPath);
      if (result is Map && result['isSuccess'] == true) {
        KToast.show(status: TR.current.saveSuccess);
      } else {
        KToast.show(status: TR.current.saveFailed);
      }
      // 清理临时文件
      try {
        await File(tempPath).delete();
      } catch (_) {}
    } catch (e) {
      KToast.show(status: TR.current.saveFailed);
    } finally {
      downloadController?.dispose();
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  /// 保存到app相册（jf_videos目录）
  Future<void> _saveToAppAlbum(String tempPath) async {
    try {
      final directoryPath = await kDirectoryPathVideos();
      final timeStr =
          DateFormat('yyyy-MM-dd HH_mm_ss SSS').format(DateTime.now());
      final channel = 'channel${widget.msg.ch ?? '0'}';
      final savePath =
          '/$directoryPath/$kPrefixVideo${widget.deviceId} $timeStr $channel.mp4';
      final appFile = File(savePath);
      if (!await appFile.parent.exists()) {
        await appFile.parent.create(recursive: true);
      }
      await File(tempPath).copy(savePath);
      // 刷新相册页
      AlbumPage.update();
    } catch (e) {
      debugPrint('保存到app相册失败: $e');
    }
  }
}
