import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fcloudsdk/media/media_player.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/controller/device_wide_dynamic_controller.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

/// 宽动态（WDR）配置页面
/// 参考 iCSeeFlutterCode 的 DeviceWideDynamicPage：
/// 开关 + 提示文案 + 实时预览 + 开关状态行
class DeviceWideDynamicPage extends StatefulWidget {
  const DeviceWideDynamicPage({
    Key? key,
    required this.deviceId,
    required this.channel,
  }) : super(key: key);

  final String deviceId;
  final int channel;

  @override
  State<DeviceWideDynamicPage> createState() => _DeviceWideDynamicPageState();
}

class _DeviceWideDynamicPageState extends State<DeviceWideDynamicPage> {
  late DeviceWideDynamicController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DeviceWideDynamicController(
      widget.deviceId,
      widget.channel >= 0 ? widget.channel : 0,
    );
    _controller.startPreview();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DeviceWideDynamicController>.value(
      value: _controller,
      child: Consumer<DeviceWideDynamicController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(title: Text(TR.current.wdrConfig)),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // 宽动态开关
                  ListTile(
                    title: Text(TR.current.wdrSwitch),
                    trailing: CupertinoSwitch(
                      value: controller.wdrStatus,
                      onChanged: controller.saving
                          ? null
                          : (value) {
                              controller.setWideDynamicCfg(value);
                            },
                    ),
                  ),
                  // 提示文案
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        TR.current.wdrConfigTips,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA9B9),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // 实时预览
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            MediaPlayerWidget(
                              controller: controller.mediaController,
                              autoDispose: false,
                              enableScale: false,
                            ),
                            // Loading指示
                            Visibility(
                              visible: controller.mediaController.isLoading,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CupertinoActivityIndicator(
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      TR.current.waiting_buffering,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 17),
                  // 开关状态行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        controller.wdrStatus
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 24,
                        color: controller.wdrStatus
                            ? Theme.of(context).primaryColor
                            : const Color(0xFFEE1817),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        controller.wdrStatus
                            ? TR.current.alreadyOpen
                            : TR.current.notOpen,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF001A41),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    KToast.dismissInDispose();
    super.dispose();
  }
}
