import 'package:fcloudsdk/door_lock/door_lock_netip_model.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/screen_set/door_lock_screen_set_controller.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///屏幕设置
class DoorLockScreenSetPage extends StatelessWidget {
  final String deviceId;

  ///猫眼能力集
  final DoorLockCatEyeFunction? catEyeFunction;

  const DoorLockScreenSetPage({
    super.key,
    required this.deviceId,
    required this.catEyeFunction,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoorLockScreenSetPageSetController(
        context: context,
        deviceId: deviceId,
        catEyeFunction: catEyeFunction,
      ),
      child: Consumer<DoorLockScreenSetPageSetController>(
        builder: (context, controller, _) {
          return PopScope(
            onPopInvokedWithResult: (didPop, result) {
              KToast.dismiss();
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(
                title: Text(TR.current.TR_Device_Lock_Screen_Setting_Title),
              ),
              body: controller.isReady
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
                      children: [
                        if (controller.supportScreenShutDown)
                          _shutdownGroup(context, controller),
                        if (controller.hasAdvancedGroup)
                          _group(
                            title: TR.current.TR_Settings_Advanced_Set,
                            children: [
                              if (controller.supportShowTimeTitle)
                                SwitchListTile(
                                  title: Text(TR.current
                                      .TR_DoorLock_Screen_Show_Time_Title),
                                  value: controller.showTimeTitleOn,
                                  onChanged: (_) => controller.changeShowTime(),
                                ),
                              if (controller.supportShowExWidgets)
                                SwitchListTile(
                                  title: Text(TR.current
                                      .TR_DoorLock_Screen_Show_Extra_Info),
                                  value: controller.showExWidgetsOn,
                                  onChanged: (_) =>
                                      controller.changeShowExWidgets(),
                                ),
                              if (controller.supportDoorbellScreenWakeOn)
                                SwitchListTile(
                                  title: Text(TR.current
                                      .TR_DoorLock_Screen_Wake_Up_By_Doorbell),
                                  value: controller.wakeOn,
                                  onChanged: (_) => controller.changeWakeOn(),
                                ),
                            ],
                          ),
                        if (controller.hasFactoryGroup)
                          _group(
                            title: TR.current.TR_DoorLock_Factory_Setting_Title,
                            children: [
                              if (controller.supportScreenInvert)
                                SwitchListTile(
                                  title: Text(
                                      TR.current.TR_DoorLock_Screen_Invert),
                                  subtitle: Text(TR.current
                                      .TR_DoorLock_Screen_Invert_Introduce),
                                  value: controller.screenInvertOn,
                                  onChanged: (_) =>
                                      controller.changeScreenInvert(),
                                ),
                              for (var item in controller.cameraItems)
                                SwitchListTile(
                                  title: Text(item.title),
                                  value:
                                      controller.cameraInvertOn(item.camera.id),
                                  onChanged: (_) =>
                                      controller.changeCameraInvert(
                                          cameraId: item.camera.id),
                                ),
                              if (controller.supportVideoUsbSpeedMode)
                                SwitchListTile(
                                  title: const Text('USB 1.1'),
                                  subtitle: Text(TR.current
                                      .TR_DoorLock_Screen_Usb_Introduce),
                                  value: controller.usbSpeedMode11,
                                  onChanged: (_) => controller.changeUSB(),
                                ),
                            ],
                          ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }

  ///息屏设置分组：说明 + 时长单选
  Widget _shutdownGroup(
      BuildContext context, DoorLockScreenSetPageSetController controller) {
    return _group(
      title: TR.current.TR_DoorLock_Screen_Shutdown_Setting,
      children: [
        ListTile(
          title: Text(TR.current.TR_DoorLock_Screen_Shutdown_Time),
          subtitle: Text(TR.current.TR_DoorLock_Screen_Shutdown_Time_Introduce),
        ),
        _optionTile(context, controller, 15),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _optionTile(context, controller, 30),
      ],
    );
  }

  ///息屏时长选项：选中显示对勾
  Widget _optionTile(BuildContext context,
      DoorLockScreenSetPageSetController controller, int value) {
    return ListTile(
      title: Text(controller.shutDownOptionText(value)),
      trailing: controller.shutDownSelected(value)
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: () => controller.changeShutDown(value),
    );
  }

  ///分组卡片：标题 + 条目
  Widget _group({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, color: Color(0xFF9CA9B9)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
