import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/media/audio_player.dart';
import 'package:xcloudsdk_flutter/media/media_player.dart';
import 'package:xcloudsdk_flutter/model/talk_param.dart';
import 'package:xcloudsdk_flutter/utils/num_util.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/common/common_path.dart';
import 'package:xcloudsdk_flutter_example/common/named_route.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/models/user_instance.dart';
import 'package:xcloudsdk_flutter_example/pages/device_pwd_setting/device_pwd_find_back_page.dart';
import 'package:xcloudsdk_flutter_example/pages/media_realplay/media_realplay_page.dart';
import 'package:xcloudsdk_flutter_example/pages/record/cloud_record_list_page.dart';
import 'package:xcloudsdk_flutter_example/views/toast/device_pwd_input.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

class MediaMultiPlayPage extends StatefulWidget {
  const MediaMultiPlayPage({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<MediaMultiPlayPage> createState() => _MediaMultiPlayPageState();
}

class _MediaMultiPlayPageState extends State<MediaMultiPlayPage> {
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
                      },
                      icon: const Icon(Icons.settings)),
                ],
              )
            : null,
        body: JFMediaMultiPlayBodyContent(
          deviceId: widget.deviceId,
          orientation: orientation,
        ),
      );
    });
  }
}

class JFMediaMultiPlayBodyContent extends StatefulWidget {
  final String deviceId;
  final Orientation orientation;

  const JFMediaMultiPlayBodyContent(
      {super.key, required this.deviceId, required this.orientation});

  @override
  State<JFMediaMultiPlayBodyContent> createState() =>
      _JFMediaRealPlayBodyContentState();
}

class _JFMediaRealPlayBodyContentState
    extends State<JFMediaMultiPlayBodyContent>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  final List<int> channels = [0, 1, 2]; //假设是真三目设备，根据设备实际情况调整

  final List<PreviewMediaController> controllers = [];

  bool isRecording = false;

  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    //监听app生命周期
    WidgetsBinding.instance.addObserver(this);

    initMediaPlay();
    startPlay();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didUpdateWidget(covariant JFMediaMultiPlayBodyContent oldWidget) {
    if (oldWidget.orientation != widget.orientation) {
      setState(() {});
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didPushNext() {
    super.didPushNext();
    stopPlay();
    print("didPushNext");
  }

  @override
  void didPopNext() {
    super.didPopNext();
    restart();
    print("didPopNext");
  }

  @override
  void dispose() {
    super.dispose();
    if (audioHandle != -1) {
      onStopTalk();
    }
    for (var controller in controllers) {
      controller.dispose();
    }

    WidgetsBinding.instance.removeObserver(this);
  }

  void dealErrorCode(int code, PreviewMediaController controller) {
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
    for (int i = 0; i < channels.length; i++) {
      PreviewMediaController controller = PreviewMediaController(
          deviceId: widget.deviceId, channel: channels[i]);
      controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
      controller.addErrorListener((code) {
        dealErrorCode(code, controller);
      });
      controller.snapshoEvent.listen((event) {
        if (event.controllerId != controller.controllerId) {
          return;
        }
        if (event.snapshotKey == 'preset') {
          return;
        }
        if (event.code >= 0) {
          KToast.show(status: '抓图成功');
        } else {
          KToast.show(status: '抓图失败 $event.code');
        }
      });
      controllers.add(controller);
    }
  }

  PreviewMediaController getController(int channel) {
    return controllers.firstWhere((e) => e.channel == channel);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.orientation == Orientation.landscape
            ? landScapeOriginPip()
            : portraitTwoSmallTop(),
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
                  previewController: getController(0),
                  devId: widget.deviceId,
                )),
              ],
      ],
    );
  }

  Widget portraitTwoSmallTop() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: multiEyePlayer(controller: getController(1)),
            ),
            Expanded(
              flex: 1,
              child: multiEyePlayer(controller: getController(2)),
            ),
          ],
        ),
        multiEyePlayer(controller: getController(0)),
      ],
    );
  }

  Widget landScapeOriginPip() {
    var player0 = multiEyePlayer(controller: getController(0));
    var player1 = multiEyePlayer(controller: getController(1));
    var player2 = multiEyePlayer(controller: getController(2));

    List<Widget> players = [
      Expanded(
          flex: 1,
          child: Stack(
            children: [
              player1,
              Positioned(
                left: 8,
                bottom: 8,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width / 2 / 3.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1)),
                    child: player2,
                  ),
                ),
              ),
            ],
          )),
      Expanded(flex: 1, child: player0)
    ];

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
      alignment: Alignment.center,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Row(
              children: players,
            ),
          ],
        ),
      ),
    );
  }

  Widget multiEyePlayer({required PreviewMediaController controller}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MediaPlayerWidget(
          key: ValueKey(controller.playHandle),
          controller: controller,
          autoDispose: false,
        ),
        Visibility(
            visible: controller.status == MediaStatus.buffering,
            child: const Center(
              child: CircularProgressIndicator(),
            )),
      ],
    );
  }

  startPlay() async {
    for (var controller in controllers) {
      controller.startPreview(streamType: streamType);
    }
  }

  stopPlay() async {
    for (var controller in controllers) {
      await controller.stop();
    }
  }

  restart() async {
    for (var controller in controllers) {
      controller.restart();
    }
  }

  onSound(int sound) {
    getController(0).setVolume(sound);
  }

  int audioHandle = -1;
  onTalk() async {
    if (audioHandle != -1) {
      return;
    }
    try {
      int audio = await AudioPlayerPlatform.instance
          .startTalk(widget.deviceId, StartTalk(), 1);
      audioHandle = audio;
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
    await getController(0).snapshot(imagePath);
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
    int code = await getController(0).startRecord(vidoePath);
    KToast.show(status: '开启录像');
    setState(() {
      isRecording = true;
    });
    animationController.reset();
    animationController.repeat(reverse: true);
    print('start record $code');
  }

  void onStopRecord() async {
    int code = await getController(0).stopRecord();
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

  int streamType = 0;
  void onChangeStreamType() async {
    streamType = streamType == 0 ? 1 : 0;
    for (var controller in controllers) {
      controller.changeStreamType(streamType);
    }
  }
}
