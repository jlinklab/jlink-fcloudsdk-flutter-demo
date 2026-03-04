import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/controller/device_alarm_custom_voice_controller.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/device_alarm_custom_audio_page.dart';

class DeviceAlarmCustomVoicePage extends StatefulWidget {
  final String deviceId;
  const DeviceAlarmCustomVoicePage({Key? key, required this.deviceId})
      : super(key: key);

  @override
  State<DeviceAlarmCustomVoicePage> createState() =>
      _DeviceAlarmCustomVoicePageState();
}

class _DeviceAlarmCustomVoicePageState extends State<DeviceAlarmCustomVoicePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceAlarmCustomVoiceController(
          context: context, deviceId: widget.deviceId),
      builder: (context, child) {
        return Consumer<DeviceAlarmCustomVoiceController>(
          builder: (context, controller, child) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text(TR.current.tr_settings_alarm_bell_customize),
              ),
              body: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: [
                    DeviceAlarmCustomAudioPage(
                        deviceId: widget.deviceId, controller: controller),
                    ValueListenableBuilder(
                        valueListenable: controller.isTTS
                            ? controller.isCanSubmitByTransform
                            : controller.isCanSubmitByRecord,
                        builder: (context, value, child) {
                          return TextButton(
                            onPressed: () async {
                              if (controller.isTTS) {
                                await controller.onGenVoice();
                              }
                              controller.onAudition();
                            },
                            child: Text(TR.current.TR_Audition),
                          );
                        }),
                    const SizedBox(
                      height: 15,
                    ),
                    ValueListenableBuilder(
                        valueListenable: controller.isTTS
                            ? controller.isCanSubmitByTransform
                            : controller.isCanSubmitByRecord,
                        builder: (context, value, child) {
                          return TextButton(
                            onPressed: () {
                              controller.onSubmit();
                            },
                            child: Text(TR.current.TR_Upload_Prompt_Voice),
                          );
                        }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
