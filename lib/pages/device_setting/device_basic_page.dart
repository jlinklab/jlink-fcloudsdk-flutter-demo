import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/controller/device_basic_controller.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

class DeviceBasicPage extends StatefulWidget {
  const DeviceBasicPage(
      {Key? key, required this.deviceId, required this.channel})
      : super(key: key);

  final String deviceId;
  final int channel;

  @override
  State<DeviceBasicPage> createState() => _DeviceBasicPageState();
}

class _DeviceBasicPageState extends State<DeviceBasicPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) =>
            DeviceBasicController(context: context, deviceId: widget.deviceId),
        builder: (context, child) {
          return Consumer<DeviceBasicController>(
            builder: (context, controller, child) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(TR.current.basicSetting),
                ),
                body: ListView(
                  children: [
                    // 通用配置分组
                    if (controller.commonConfigItems.isNotEmpty) ...[
                      _buildSectionHeader(TR.current.commonConfig),
                      ...controller.commonConfigItems,
                    ],
                    const Divider(height: 32),
                    // 图像配置分组
                    if (controller.imageConfigItems.isNotEmpty) ...[
                      _buildSectionHeader(TR.current.imageConfig),
                      ...controller.imageConfigItems,
                    ],
                  ],
                ),
              );
            },
          );
        });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  void dispose() {
    KToast.dismissInDispose();
    super.dispose();
  }
}
