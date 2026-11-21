import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/tip_volume/door_lock_tip_volume_set_controller.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///提示音设置
class DoorLockTipVolumeSetPage extends StatelessWidget {
  final String deviceId;

  const DoorLockTipVolumeSetPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          DoorLockTipVolumeSetController(context: context, deviceId: deviceId),
      child: Consumer<DoorLockTipVolumeSetController>(
        builder: (context, controller, _) {
          return PopScope(
            onPopInvokedWithResult: (didPop, result) {
              KToast.dismiss();
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F9),
              appBar: AppBar(
                title: Text(TR.current.TR_Settings_Open_Voice),
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
                children: [
                  _group(
                    title: TR.current.TR_Device_Volume_In_Room,
                    children: _optionTiles(
                      context,
                      options: controller.bellOptions,
                      selected: controller.bellSelected,
                      onTap: controller.changeBellVolume,
                    ),
                  ),
                  if (controller.isSupportLockVolume)
                    _group(
                      title: TR.current.TR_Device_Volume_Doorlock,
                      tip: TR.current.TR_Device_Volume_Doorlock_Tip,
                      children: _optionTiles(
                        context,
                        options: controller.lockOptions,
                        selected: controller.lockSelected,
                        onTap: controller.changeLockVolume,
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

  ///一组音量档位：选中显示对勾
  List<Widget> _optionTiles(
    BuildContext context, {
    required List<DoorLockVolumeOption> options,
    required bool Function(int position) selected,
    required void Function(int position) onTap,
  }) {
    var children = <Widget>[];
    for (var i = 0; i < options.length; i++) {
      if (i > 0) {
        children.add(const Divider(height: 1, indent: 16, endIndent: 16));
      }
      var option = options[i];
      children.add(
        ListTile(
          title: Text(option.title),
          trailing: selected(option.position)
              ? Icon(Icons.check, color: Theme.of(context).primaryColor)
              : null,
          onTap: () => onTap(option.position),
        ),
      );
    }
    return children;
  }

  ///分组卡片：标题 + 可选说明 + 条目
  Widget _group({
    required String title,
    String? tip,
    required List<Widget> children,
  }) {
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
          if (tip != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                tip,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA9B9)),
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
