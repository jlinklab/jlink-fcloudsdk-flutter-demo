import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/controller/device_storage_manage_controller.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

// ignore: must_be_immutable
class DeviceStoragePage extends StatefulWidget {
  DeviceStoragePage({Key? key, required this.deviceId, required this.channel})
      : super(key: key);

  final String deviceId;
  final int channel;

  Map<String, dynamic>? configMap;

  @override
  State<DeviceStoragePage> createState() => _DeviceStoragePage();
}

class _DeviceStoragePage extends State<DeviceStoragePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => DeviceStorageManageController(
            context: context, deviceId: widget.deviceId),
        builder: (context, child) {
          return Consumer<DeviceStorageManageController>(
            builder: (context, controller, child) {
              return Scaffold(
                  appBar: AppBar(
                    title: Text(TR.current.storageManagement),
                  ),
                  body: Visibility(
                      visible: controller.isLoading == false,
                      child: controller.tfStatus == 2
                          ? Column(children: [
                              Expanded(
                                  child: ListView.separated(
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return controller.dataSource[index];
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return const Divider(
                                          color: Colors.blueGrey,
                                        );
                                      },
                                      itemCount: controller.dataSource.length)),
                              Padding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .padding
                                          .bottom),
                                  child: TextButton(
                                      onPressed: () {
                                        controller.onStorageFormatter();
                                      },
                                      child: const Text(
                                        '格式化',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.red),
                                      )))
                            ])
                          : Container(
                              alignment: Alignment.center,
                              child: Text(
                                tfStatusStr(controller),
                                textAlign: TextAlign.center,
                              ))));
            },
          );
        });
  }

  String tfStatusStr(DeviceStorageManageController controller) {
    if (controller.tfStatus == 0) {
      return TR.current.memoryCardError;
    } else if (controller.tfStatus == 1) {
      return TR.current.deviceNoMemoryCard;
    }
    return ' ';
  }

  @override
  void dispose() {
    KToast.dismissInDispose();
    super.dispose();
  }
}
