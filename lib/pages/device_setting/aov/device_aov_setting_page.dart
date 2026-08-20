import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/aov/controller/device_aov_setting_controller.dart';

class DeviceAovSettingPage extends StatefulWidget {
  const DeviceAovSettingPage({Key? key, required this.deviceId})
      : super(key: key);

  final String deviceId;

  @override
  State<DeviceAovSettingPage> createState() => _DeviceAovSettingPageState();
}

class _DeviceAovSettingPageState extends State<DeviceAovSettingPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceAovSettingController(
          context: context, deviceId: widget.deviceId),
      builder: (context, child) {
        return Consumer<DeviceAovSettingController>(
          builder: (context, controller, child) {
            return Scaffold(
              appBar: AppBar(
                title: Text(TR.current.TR_Setting_AOV_Device_Config),
                centerTitle: true,
              ),
              body: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  final item = controller.aovConfigList[index];
                  return ListTile(
                    title: Text(item.title),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.extraInfo?.isNotEmpty == true)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              item.extraInfo ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                    onTap: item.onTap,
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(color: Colors.grey);
                },
                itemCount: controller.aovConfigList.length,
              ),
            );
          },
        );
      },
    );
  }
}
