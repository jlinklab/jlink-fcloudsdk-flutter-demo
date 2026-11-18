import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_parse.dart';
import 'package:fcloudsdk_example/api/device_api.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/common/device_name.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/models/device_type.dart';
import 'package:fcloudsdk_example/pages/door_lock/repository/door_lock_local.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/door_lock_config_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/home/move_device_page.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';

///门锁设置首页
class DoorLockSettingPage extends StatefulWidget {
  final String deviceId;

  const DoorLockSettingPage({super.key, required this.deviceId});

  @override
  State<DoorLockSettingPage> createState() => _DoorLockSettingPageState();
}

class _DoorLockSettingPageState extends State<DoorLockSettingPage> {
  DoorLockSetConfig? _setConfig;
  final TextEditingController _textController = TextEditingController();

  ///当前设备名称，取设备列表中的昵称，取不到时兜底显示序列号
  String get _deviceName =>
      DeviceManager.instance.getDeviceName(deviceId: widget.deviceId) ??
      widget.deviceId;

  ///被分享的设备不允许修改名称
  bool get _isSharedDevice =>
      DeviceManager.instance.getDevice(deviceId: widget.deviceId)?.fromShare ??
      false;

  ///设备当前所在房间名，未设置时为空
  String get _roomName =>
      DeviceManager.instance.getDevice(deviceId: widget.deviceId)?.roomName ??
      '';

  ///分享的设备无权限设置位置，AHD 猫眼锁设置页无设备位置条目
  bool get _showLocationEntry {
    final device = DeviceManager.instance.getDevice(deviceId: widget.deviceId);
    if (device == null || !device.isAdmin) {
      return false;
    }
    return device.parentPid != DeviceType.PID_SMART_DOOR_LOCK_AHD.pid;
  }

  @override
  void initState() {
    super.initState();
    final cachedRaw =
        DoorLockLocalCache.doorlockOnlineConfig(deviceId: widget.deviceId);
    if (cachedRaw.isNotEmpty) {
      _setConfig = parseRawToSetConfig(cachedRaw);
    }
    _queryConfig();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _queryConfig() async {
    final rawList =
        await DoorLockHelper.instance.queryOnlineCongfig(widget.deviceId);
    if (!mounted || rawList == null || rawList.isEmpty) return;
    _setConfig = parseRawToSetConfig(rawList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(title: const Text('设置')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('设备名称'),
                subtitle: Text(_deviceName),
                trailing: _isSharedDevice ? null : const Icon(Icons.edit),
                onTap: _isSharedDevice ? null : _showChangeNameDialog,
              ),
              if (_showLocationEntry)
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('设备位置'),
                  subtitle: Text(_roomName.isEmpty ? '未设置' : _roomName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            MoveDevicePage(deviceNo: widget.deviceId),
                      ),
                    );
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('锁具配置'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DoorLockConfigPage(
                        deviceId: widget.deviceId,
                        initSetConfig: _setConfig,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///弹出输入框修改设备名称
  void _showChangeNameDialog() {
    _textController.text = _deviceName;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('修改设备名称'),
          content: TextField(
            controller: _textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: deviceNameHintText(),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _textController.text = _deviceName;
                Navigator.of(dialogContext).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _changeDeviceName(_textController);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  ///校验并提交设备名称到服务器，成功后回写设备列表中的昵称
  Future<void> _changeDeviceName(TextEditingController textController) async {
    var vaild = await checkDeviceNameVaild(textController.text, context);
    if (!vaild) {
      textController.text = _deviceName;
      return;
    }
    KToast.show();
    await deviceAPI.updateDevice({
      'deviceNo': widget.deviceId,
      'deviceName': textController.text
    }).then((value) {
      DeviceManager.instance.getDevice(deviceId: widget.deviceId)?.nickname =
          textController.text;
      KToast.show(status: '保存成功');
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
      textController.text = _deviceName;
      KToast.show(status: kErrorMsg(error));
    });
  }
}
