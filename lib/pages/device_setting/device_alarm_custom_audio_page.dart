import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/controller/device_audio_upload_base_controller.dart';

class DeviceAlarmCustomAudioPage extends StatefulWidget {
  final String deviceId;

  final DeviceAudioUploadBaseController controller;

  const DeviceAlarmCustomAudioPage(
      {Key? key, required this.deviceId, required this.controller})
      : super(key: key);

  @override
  State<DeviceAlarmCustomAudioPage> createState() =>
      _DeviceSetAlarmCustomAudioPageState();
}

class _DeviceSetAlarmCustomAudioPageState
    extends State<DeviceAlarmCustomAudioPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.controller,
      builder: (context, child) {
        return Consumer<DeviceAudioUploadBaseController>(
            builder: (context, controller, child) {
          return Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 52),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(
                    height: 25,
                  ),

                  ///文字/录音
                  _VoiceFromTypeWidget(
                    controller: controller,
                  ),
                  contentWidget(controller),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget contentWidget(DeviceAudioUploadBaseController controller) {
    if (!controller.isTTS) {
      return Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Text(
            controller.isRecording
                ? TR.current.tr_pet_function_recording_state
                : '',
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            controller.onConvertRecordTimeStr(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 5,
          ),
          GestureDetector(
              onTap: () async {
                !controller.isRecording
                    ? await controller.onStartRecord()
                    : await controller.onEndRecord();
              },
              child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    extraInfo(controller),
                    style: const TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ))),
          Text(
            recordTimeLengthExplain(controller),
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              onChanged: (value) {
                controller.ttsVoiceText.value = value;
              },
              controller:
                  TextEditingController(text: controller.ttsVoiceText.value),
              maxLines: null,
              //支持多行显示
              minLines: 10,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                child: Stack(children: [
                  Row(children: [
                    Container(
                      alignment: Alignment.center,
                      width: 150,
                      height: 50,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: Row(
                            children: [
                              Text(
                                TR.current.TR_Sex_Male,
                                style: TextStyle(
                                    color: controller.sexType == 0
                                        ? Colors.blue
                                        : Colors.black,
                                    fontSize: 15,
                                    fontWeight: controller.sexType == 0
                                        ? FontWeight.w600
                                        : null),
                                softWrap: true,
                                // 允许自动换行
                                maxLines: 99,
                                // 设置最大行数为2
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              )
                            ],
                          )),
                    )
                  ]),
                ]),
                onTap: () {
                  controller.setSexType = 0;
                },
              ),
              GestureDetector(
                child: Stack(children: [
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: 150,
                        height: 50,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Row(
                              children: [
                                Text(
                                  TR.current.TR_Sex_Female,
                                  style: TextStyle(
                                      color: controller.sexType == 1
                                          ? Colors.blue
                                          : Colors.black,
                                      fontSize: 15,
                                      fontWeight: controller.sexType == 1
                                          ? FontWeight.w600
                                          : null),
                                  softWrap: true,
                                  // 允许自动换行
                                  maxLines: 99,
                                  // 设置最大行数为2
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                )
                              ],
                            )),
                      )
                    ],
                  ),
                ]),
                onTap: () {
                  controller.setSexType = 1;
                },
              ),
            ],
          ),
        ],
      );
    }
  }

  String extraInfo(DeviceAudioUploadBaseController controller) {
    return controller.isRecording
        ? TR.current.TR_Press_To_End_Record
        : TR.current.TR_Press_To_Record;
  }

  String recordTimeLengthExplain(DeviceAudioUploadBaseController controller) {
    return '';
  }
}

///语音类型选择
class _VoiceFromTypeWidget extends StatefulWidget {
  final DeviceAudioUploadBaseController controller;

  const _VoiceFromTypeWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  State<_VoiceFromTypeWidget> createState() => _VoiceFromTypeWidgetState();
}

class _VoiceFromTypeWidgetState extends State<_VoiceFromTypeWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.controller,
      builder: (context, child) {
        return Consumer<DeviceAudioUploadBaseController>(
            builder: (context, controller, child) {
          return widgetContent(context, controller);
        });
      },
    );
  }

  Widget widgetContent(
      BuildContext context, DeviceAudioUploadBaseController controller) {
    if (controller.isShowTTs) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.setIsTTS = false;
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TR.current.TR_Record_Prompt,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                  softWrap: true,
                  // 允许自动换行
                  maxLines: 99,
                  // 设置最大行数为2
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.setIsTTS = true;
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TR.current.TR_Text_To_Voice,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                  softWrap: true,
                  // 允许自动换行
                  maxLines: 99,
                  // 设置最大行数为2
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 25,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                )
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TR.current.tr_pet_setting_sound_record_function,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                  softWrap: true,
                  // 允许自动换行
                  maxLines: 99,
                  // 设置最大行数为2
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(
                  height: 2,
                ),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, // 设定为圆形
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }
  }
}
