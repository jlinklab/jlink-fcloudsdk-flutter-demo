// ignore_for_file: must_be_immutable, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/media/audio_player.dart';
import 'package:xcloudsdk_flutter/media/media_player.dart';
import 'package:xcloudsdk_flutter/model/talk_param.dart';
import 'package:xcloudsdk_flutter/utils/num_util.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/common/common_path.dart';
import 'package:xcloudsdk_flutter_example/common/named_route.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/cloud/device_cloud_service_manager.dart';
import 'package:xcloudsdk_flutter_example/pages/cloud/model/device_cloud.dart';
import 'package:xcloudsdk_flutter_example/pages/device_pwd_setting/device_pwd_find_back_page.dart';
import 'package:xcloudsdk_flutter_example/pages/media_realplay/views/dev_pre_set_view.dart';
import 'package:xcloudsdk_flutter_example/views/play_control_view.dart';
import 'package:xcloudsdk_flutter_example/views/toast/device_pwd_input.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';
import 'package:intl/intl.dart';
import '../../models/user_instance.dart';
import '../record/cloud_record_list_page.dart';

class MediaRealPlayPage extends StatefulWidget {
  const MediaRealPlayPage({Key? key, required this.deviceId}) : super(key: key);

  final String deviceId;

  @override
  State<MediaRealPlayPage> createState() => _MediaRealPlayPageState();
}

class _MediaRealPlayPageState extends State<MediaRealPlayPage> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
        appBar: orientation == Orientation.portrait
            ? AppBar(
                title: Text(TR.current.preview),
                centerTitle: true,
                actions: [
                  IconButton(
                      onPressed: () {
                        context.pushNamed('device_config', pathParameters: {
                          'devId': widget.deviceId,
                          'channel': (-1).toString()
                        });
                        // Navigator.of(context).pushNamed('/device_config',
                        //     arguments: {'deviceId': widget.deviceId, 'channel': -1});
                      },
                      icon: const Icon(Icons.settings)),
                ],
              )
            : null,
        body: JFMediaRealPlayBodyContent(
          deviceId: widget.deviceId,
          orientation: orientation,
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    print("realplayPage dispose");
  }
}

class JFMediaRealPlayBodyContent extends StatefulWidget {
  final String deviceId;
  final Orientation orientation;

  const JFMediaRealPlayBodyContent(
      {super.key, required this.deviceId, required this.orientation});

  @override
  State<StatefulWidget> createState() => JFMediaRealPlayBodyContentState();
}

class JFMediaRealPlayBodyContentState extends State<JFMediaRealPlayBodyContent>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  late final PreviewMediaController controller;

  ///当前页面是否可见
  bool _isVisible = true;

  bool isLoading = true;
  bool isRecording = false;

  late final AnimationController animationController;

  StreamSubscription? _snapshotSub;

  @override
  void initState() {
    super.initState();
    //监听app生命周期
    WidgetsBinding.instance.addObserver(this);
    animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    initMediaPlay();
    startPlay();
  }

  void startPlay() async {
    controller.startPreview();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _snapshotSub?.cancel();

    if (audioHandle != -1) {
      onStopTalk();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPushNext() {
    super.didPushNext();
    _isVisible = false;
    controller.stop();
    print("didPushNext");
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _isVisible = true;
    controller.restart();
    print("didPopNext");
  }

  void dealErrorCode(int code) {
    if (code == -70106 || code == -70163 || code == -70203 || code == -70205) {
      //设备密码错误 需要重新输入
      showDialog(
          context: context,
          builder: (context) {
            return Material(
              color: Colors.black26,
              child: Center(
                child: DevicePwdInput(
                  deviceId: widget.deviceId,
                  completion: (name, password) async {
                    Navigator.of(context).pop();
                    UserInfo.instance
                        .saveDeviceInfo(widget.deviceId, name, password);
                    await JFApi.xcDevice.xcSetLocalUserNameAndPwd(
                        deviceId: widget.deviceId,
                        userName: name,
                        pwd: password);
                    controller.restart();
                  },
                  onFindPwd: () {
                    ///找回密码
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return DevicePwdFindBackPage(
                        deviceId: widget.deviceId,
                      );
                    }));
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            );
          });
    } else {
      //其他的直接显示错误码
      KToast.show(status: KErrorMsg(code));
    }
  }

  void initMediaPlay() async {
    controller = PreviewMediaController(deviceId: widget.deviceId);
    controller.addStatusListener((status) {
      if (mounted) {
        setState(() {
          print(status);
          isLoading = status == MediaStatus.buffering;
        });
      }
    });
    controller.addListener(() {});
    controller.addErrorListener((code) {
      dealErrorCode(code);
    });
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    controller.snapshoEvent.listen((event) {
      if (event.controllerId != controller.controllerId) {
        return;
      }
      if (event.snapshotKey == 'preset') {
        return;
      }
      _handleSnapshotEvent(event);
    });
  }

  void onPlay() async {}

  int audioHandle = -1;

  void onTalk() async {
    if (audioHandle != -1) {
      return;
    }
    try {
      //
      int audio = await AudioPlayerPlatform.instance
          .startTalk(widget.deviceId, StartTalk(), 1);
      audioHandle = audio;
      await AudioPlayerPlatform.instance.setVolume(audio, 100);
    } catch (error) {
      print(error);
    }
  }

  void onStopTalk() async {
    int audio = await AudioPlayerPlatform.instance
        .stopTalkPlay(audioHandle, mediaType: 1);
    audioHandle = audio;
  }

  void onSnap() async {
    //获取本地存图片的文件夹路径
    String directoryPath = await kDirectoryPathImages();
    String timeStr =
        DateFormat('yyyy-MM-dd HH_mm_ss SSS').format(DateTime.now());
    String deviceId = widget.deviceId;
    String channel = 'channel0'; //预留通道位置
    String imagePath =
        '/$directoryPath/$kPrefixImage$deviceId $timeStr $channel.jpg';

    KToast.show();
    await controller.snapshot(imagePath);
  }

  void _handleSnapshotEvent(SnapshotCallback event) {
    if (event.code >= 0) {
      KToast.show(status: '抓图成功');
    } else {
      KToast.show(status: '抓图失败 $event.code');
    }
  }

  void onStartRecord() async {
    //获取本地存图片的文件夹路径
    String directoryPath = await kDirectoryPathVideos();
    String timeStr =
        DateFormat('yyyy-MM-dd HH_mm_ss SSS').format(DateTime.now());
    String deviceId = widget.deviceId;
    String channel = 'channel0'; //预留通道位置
    String vidoePath =
        '/$directoryPath/$kPrefixVideo$deviceId $timeStr $channel.mp4';
    int code = await controller.startRecord(vidoePath);
    KToast.show(status: '开启录像');
    setState(() {
      isRecording = true;
    });
    animationController.reset();
    animationController.repeat(reverse: true);
    print('start record $code');
  }

  void onStopRecord() async {
    int code = await controller.stopRecord();
    KToast.show(status: '录像保存成功');
    setState(() {
      isRecording = false;
    });
    print('stop record $code');
  }

  void onPTZControl(int bStop, String direction) {
    JFApi.xcDevice.xcPtzControl(
        deviceId: widget.deviceId,
        channelIndex: 0,
        szPTZCommand: direction,
        bStop: bStop,
        nSpeed: 1);
    print('云台移动了');
  }

  void onPlayback() {
    context.pushNamed('card_record', pathParameters: {
      'devId': widget.deviceId,
    });
  }

  void onCloudPlayback() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return CloudRecordListPage(deviceId: widget.deviceId);
    }));
  }

  void onPictureFlip() async {
    Map<String, dynamic> json11 = await JFApi.xcDevice.xcDevGetChnConfig(
        deviceId: widget.deviceId,
        channelNo: 0,
        commandName: "Camera.Param",
        command: 1042,
        timeout: 15000);
    String name = json11["Name"];
    Map<String, dynamic> value = json11[name];
    String pictureFlip = value["PictureFlip"];
    int intValue = NumUtil.hexToInt(pictureFlip);

    int changeValue = intValue == 0 ? 1 : 0;

    value["PictureFlip"] = NumUtil.toHexString(changeValue);
    json11[name] = value;
    String dataSource = json.encode(json11);

    await JFApi.xcDevice.xcDevSetChnConfig(
        deviceId: widget.deviceId,
        channelNo: 0,
        commandName: "Camera.Param",
        config: dataSource,
        configLen: dataSource.length + 1,
        command: 1040,
        timeout: 15000);
  }

  void onSound(int sound) {
    controller.setVolume(sound);
  }

  int streamType = 0;

  void onChangeStreamType() async {
    await controller.stop();
    // await Future.delayed(Duration(seconds: 1));
    streamType = streamType == 0 ? 1 : 0;
    controller.startPreview(streamType: streamType);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _playWidget(widget.orientation),
      ...widget.orientation == Orientation.landscape
          ? [const SizedBox()]
          : [
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: MediaRealPlayToolView(
                onSound: onSound,
                onTalk: onTalk,
                onStopTalk: onStopTalk,
                onSnap: onSnap,
                onStarRecord: onStartRecord,
                onStopRecord: onStopRecord,
                onPTZControl: onPTZControl,
                onPictureFlip: onPictureFlip,
                onPlayback: onPlayback,
                onCloudPlayback: onCloudPlayback,
                onChangeStreamType: onChangeStreamType,
                previewController: controller,
                devId: widget.deviceId,
              )),
            ],
    ]);
  }

  Widget _playWidget(Orientation orientation) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          ignoring: true,
          child: MediaPlayerWidget(
            controller: controller,
          ),
        ),
        Visibility(
            visible: isLoading,
            child: const Center(
              child: CircularProgressIndicator(),
            )),
        Positioned(
            left: 10,
            top: 10,
            child: Visibility(
              visible: isRecording,
              child: FadeTransition(
                opacity: animationController,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
              ),
            )),
        MediaPlayControlView(
            orientation: orientation,
            mediaController: controller,
            mediaType: MediaType.preview),
      ],
    );
  }
}

typedef PTZControlCallback = Function(int a, String b);

class MediaRealPlayToolView extends StatelessWidget {
  MediaRealPlayToolView({
    super.key,
    required this.onSound,
    required this.onTalk,
    required this.onStopTalk,
    required this.onSnap,
    required this.onStarRecord,
    required this.onStopRecord,
    required this.onPTZControl,
    required this.onPictureFlip,
    required this.onPlayback,
    required this.onCloudPlayback,
    required this.previewController,
    required this.devId,
    required this.onChangeStreamType,
  });

  final PreviewMediaController previewController;
  final String devId;
  ValueChanged<int> onSound;
  PTZControlCallback onPTZControl;

  final VoidCallback onTalk;
  final VoidCallback onStopTalk;
  final VoidCallback onSnap;
  final VoidCallback onStarRecord;
  final VoidCallback onStopRecord;
  final VoidCallback onPictureFlip;
  final VoidCallback onPlayback;
  final VoidCallback onCloudPlayback;
  final VoidCallback onChangeStreamType;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      //默认主轴竖直
      crossAxisCount: 4,
      //交叉轴显示矿建个数
      crossAxisSpacing: 16,
      //交叉轴间距
      mainAxisSpacing: 16,
      //主轴间距
      // scrollDirection: Axis.horizontal,//水平滚动
      padding: const EdgeInsets.all(16),
      children: [
        GestureDetector(
          onTapDown: (tapDown) {
            print("按下 ");
            onPTZControl(0, 'DirectionUp');
          },
          onTapUp: (tapUp) {
            print("抬起 ");
            onPTZControl(1, 'DirectionUp');
          },
          child: Container(
            alignment: const Alignment(0, 0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              color: Theme.of(context).colorScheme.tertiary,
            ),
            child: const Text(
              "云台向上",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        GestureDetector(
          onTapDown: (tapDown) {
            print("按下 ");
            onPTZControl(0, 'DirectionDown');
          },
          onTapUp: (tapUp) {
            print("抬起 ");
            onPTZControl(1, 'DirectionDown');
          },
          child: Container(
            alignment: const Alignment(0, 0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              color: Theme.of(context).colorScheme.tertiary,
            ),
            child: const Text(
              "云台向下",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        GestureDetector(
          onTapDown: (tapDown) {
            print("按下 ");
            onPTZControl(0, 'DirectionLeft');
          },
          onTapUp: (tapUp) {
            print("抬起 ");
            onPTZControl(1, 'DirectionLeft');
          },
          child: Container(
            alignment: const Alignment(0, 0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              color: Theme.of(context).colorScheme.tertiary,
            ),
            child: const Text(
              "云台向左",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        GestureDetector(
          onTapDown: (tapDown) {
            print("按下 ");
            onPTZControl(0, 'DirectionRight');
          },
          onTapUp: (tapUp) {
            print("抬起 ");
            onPTZControl(1, 'DirectionRight');
          },
          child: Container(
            alignment: const Alignment(0, 0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              color: Theme.of(context).colorScheme.tertiary,
            ),
            child: const Text(
              "云台向右",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        TextButton(
            onPressed: () => onSound(100),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.inversePrimary),
            ),
            child: const Text("播放声音")),
        TextButton(
            onPressed: () => onSound(0),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.inversePrimary),
            ),
            child: const Text("静音")),
        TextButton(
            onPressed: onTalk,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.inversePrimary),
            ),
            child: const Text("对讲")),
        TextButton(
            onPressed: onStopTalk,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.inversePrimary),
            ),
            child: const Text("关闭对讲")),
        TextButton(
            onPressed: onSnap,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.inversePrimary),
            ),
            child: const Text("抓图")),
        TextButton(
            onPressed: onStarRecord,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.inversePrimary),
            ),
            child: const Text("开始录像")),
        TextButton(
            onPressed: onStopRecord,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.inversePrimary),
            ),
            child: const Text("结束录像")),
        TextButton(
            onPressed: () => onPictureFlip(),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.inversePrimary),
            ),
            child: const Text("图像上下翻转")),
        TextButton(
            onPressed: () {
              onPlayback();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.inversePrimary),
            ),
            child: const Text("回放")),
        TextButton(
            onPressed: () {
              //判断是否支持云服务再进入云回放页
              // DeviceCloudService? cloudService = DeviceCloudServiceManager
              //     .instance
              //     .getCloudService(deviceId: devId);
              // if (cloudService?.cloudServerStatus == CloudServerStatus.active) {
              onCloudPlayback();
              // } else {
              //   KToast.show(status: '云服务过期或未购买');
              // }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.inversePrimary),
            ),
            child: const Text("云回放")),
        TextButton(
            onPressed: () {
              showBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return DevPresetView(
                      previewController: previewController,
                      devId: devId,
                    );
                  });
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.inversePrimary),
            ),
            child: const Text('预置点')),
        TextButton(
            onPressed: () {
              onChangeStreamType();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.inversePrimary),
            ),
            child: const Text('高标清')),
      ],
    );
  }
}
