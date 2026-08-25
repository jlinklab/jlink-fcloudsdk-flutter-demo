import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/device_setting/controller/device_image_setting_controller.dart';
import 'package:fcloudsdk_example/pages/device_setting/device_wide_dynamic_page.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

class DeviceImageSettingPage extends StatefulWidget {
  const DeviceImageSettingPage({
    Key? key,
    required this.deviceId,
    required this.channel,
  }) : super(key: key);

  final String deviceId;
  final int channel;

  @override
  State<DeviceImageSettingPage> createState() => _DeviceImageSettingPageState();
}

class _DeviceImageSettingPageState extends State<DeviceImageSettingPage> {
  late DeviceImageSettingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DeviceImageSettingController(
      widget.deviceId,
      widget.channel >= 0 ? widget.channel : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    _controller.updatePageContext(context);
    return ChangeNotifierProvider<DeviceImageSettingController>.value(
      value: _controller,
      child: Consumer<DeviceImageSettingController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(TR.current.imageSetting),
              actions: [
                GestureDetector(
                  onTap: () {
                    _onSave.call();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 15),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: Colors.white),
                    child: Icon(
                      color: Theme.of(context).primaryColor,
                      Icons.save,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                //清晰度-AE灵敏度
                ListTile(
                  title: Text(TR.current.sharpness),
                  trailing: Text(controller.aeSensitivityName),
                  onTap: () => controller
                      .showAeSensitivityDialog(controller.pageContextSafe),
                ),
                // 2. 图像上下翻转
                Visibility(
                    visible: controller.supportVerticalPictureFlip,
                    child: ListTile(
                      title: Text(TR.current.imageFlipUpDown),
                      trailing: CupertinoSwitch(
                        value: controller.pictureFlip,
                        onChanged: (value) {
                          controller.setPictureFlip(value);
                        },
                      ),
                    )),
                // 3. 图像左右翻转
                Visibility(
                    visible: controller.supportHorizontalPictureFlip,
                    child: ListTile(
                      title: Text(TR.current.imageFlipLeftRight),
                      trailing: CupertinoSwitch(
                        value: controller.pictureMirror,
                        onChanged: (value) {
                          controller.setPictureMirror(value);
                        },
                      ),
                    )),
                // 4. 背光补偿
                ListTile(
                  title: Text(TR.current.backlightCompensation),
                  trailing: CupertinoSwitch(
                    value: controller.blcMode,
                    onChanged: (value) {
                      controller.setBlcMode(value);
                    },
                  ),
                ),
                // 5. 日夜模式
                ListTile(
                  title: Text(TR.current.dayNightMode),
                  trailing: Text(controller.dayNightColorName),
                  onTap: () => controller
                      .showDayNightColorDialog(controller.pageContextSafe),
                ),
                // 6. 宽动态WDR（仅supportBT时显示，点击进入宽动态配置页面）
                Visibility(
                    visible: controller.supportBT,
                    child: ListTile(
                      title: Text(TR.current.wdrSwitch),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _openWideDynamicPage,
                    )),
              ],
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

  /// 统一保存：参考Android DevCameraSetActivity的tryToSaveConfig交互，
  /// 请求成功后返回上一页面
  Future<void> _onSave() async {
    final success = await _controller.tryToSaveConfig();
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  /// 跳转宽动态配置页面
  void _openWideDynamicPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return DeviceWideDynamicPage(
        deviceId: widget.deviceId,
        channel: widget.channel,
      );
    }));
  }
}
