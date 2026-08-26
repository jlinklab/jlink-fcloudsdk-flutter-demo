import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fcloudsdk/media/media_player.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/controller/device_water_mark_controller.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

/// 水印配置页面
/// 参考宽动态（WDR）配置页面：
/// 设备名称编辑 + 提示文案 + 实时预览；修改设备名称并保存后下发水印，
/// 预览画面更新呈现水印效果
class DeviceWaterMarkPage extends StatefulWidget {
  const DeviceWaterMarkPage({
    Key? key,
    required this.deviceId,
    required this.channel,
  }) : super(key: key);

  final String deviceId;
  final int channel;

  @override
  State<DeviceWaterMarkPage> createState() => _DeviceWaterMarkPageState();
}

class _DeviceWaterMarkPageState extends State<DeviceWaterMarkPage> {
  late DeviceWaterMarkController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DeviceWaterMarkController(
      widget.deviceId,
      widget.channel >= 0 ? widget.channel : 0,
    );
    _controller.startPreview();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DeviceWaterMarkController>.value(
      value: _controller,
      child: Consumer<DeviceWaterMarkController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(TR.current.waterMarkConfig),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // 设备名称（水印内容）
                  ListTile(
                    title: Text(TR.current.labelDeviceName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: Text(
                            controller.deviceName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFF9CA9B9)),
                          ),
                        ),
                        const Icon(Icons.edit),
                      ],
                    ),
                    onTap: controller.saving
                        ? null
                        : () => _showEditNameDialog(controller),
                  ),
                  // 提示文案
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        TR.current.waterMarkTips,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 弹出设备名称编辑对话框
  void _showEditNameDialog(DeviceWaterMarkController controller) {
    final textController = TextEditingController(text: controller.deviceName);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(TR.current.setDeviceName),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: TR.current.inputDeviceNameHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(TR.current.cancelBtn),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                controller.setDeviceName(textController.text.trim());
                _onSave();
              },
              child: Text(TR.current.confirmBtn),
            ),
          ],
        );
      },
    );
  }

  /// 保存水印：成功后不退出页面，留在页面观察预览水印效果
  void _onSave() {
    _controller.saveWaterMark();
  }

  @override
  void dispose() {
    _controller.dispose();
    KToast.dismissInDispose();
    super.dispose();
  }
}
