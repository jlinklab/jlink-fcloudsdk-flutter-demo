import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/controller/device_record_set_controller.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

class DeviceRecordSetPage extends StatefulWidget {
  const DeviceRecordSetPage(
      {Key? key, required this.deviceId, required this.channel})
      : super(key: key);

  final String deviceId;
  final int channel;

  @override
  State<DeviceRecordSetPage> createState() => _DeviceRecordSetPageState();
}

class _DeviceRecordSetPageState extends State<DeviceRecordSetPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => DeviceRecordSetController(
            context: context, deviceId: widget.deviceId),
        builder: (context, child) {
          return Consumer<DeviceRecordSetController>(
            builder: (context, controller, child) {
              return Scaffold(
                  appBar: AppBar(
                    title: Text(TR.current.recordSetting),
                  ),
                  body: Column(children: [
                    Expanded(
                      child: ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 1) {
                              return Column(
                                children: [
                                  controller.dataSource[index],
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Slider(
                                          min: 5,
                                          max: 120,
                                          activeColor: Colors.blueAccent,
                                          inactiveColor:
                                              const Color(0xFFE4E4E6),
                                          value: controller.recordPartTime
                                              .toDouble(),
                                          onChanged: (pValue) {
                                            setState(() {
                                              controller.recordPartTime =
                                                  pValue.toInt();
                                            });
                                          },
                                          onChangeStart: (pValue) {
                                            // ///先保存原始的，避免设置不成功后，无法复位
                                            // controller.volumeOutputTemp = controller.volumeOutput;
                                          },
                                          onChangeEnd: (pValue) {
                                            controller.onSetRecordConfig(
                                                bShowLoading: true);
                                          },
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 30),
                                        margin: const EdgeInsets.only(left: 2),
                                        width: 100,
                                        child: Text(
                                          controller.recordPartTime.toString(),
                                          style: const TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              );
                            } else {
                              return controller.dataSource[index];
                            }
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(
                              color: Colors.blueGrey,
                            );
                          },
                          itemCount: controller.dataSource.length),
                    ),
                    Expanded(
                        child: Visibility(
                      visible: controller.bExistSD == false,
                      child: Text(
                        TR.current.noSDCardTips,
                        style: const TextStyle(fontSize: 15),
                      ),
                    )),
                  ]));
            },
          );
        });
  }

  @override
  void dispose() {
    KToast.dismissInDispose();
    super.dispose();
  }
}
