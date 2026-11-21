import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_parse.dart';
import 'package:fcloudsdk_example/api/device_api.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/common/device_name.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/manager/push_manager.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/door_lock_custom_enum.dart';
import 'package:fcloudsdk_example/pages/door_lock/repository/door_lock_local.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/door_lock_config_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/language/door_lock_language_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/lock_config/language/door_lock_language_util.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/network/door_lock_net_manage_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/network/usecase/door_lock_wifi_config_jumper.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/quick/door_lock_quick_fun_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/save_power_mode/door_lock_save_power_home_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/screen_set/door_lock_screen_set_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/tip_volume/door_lock_tip_volume_set_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';

///设置页门锁控制器：未配网时跳转配网需要门锁控制器上下文
class DoorLockSettingPageController extends DoorLockPageController {
  @override
  final String deviceId;

  DoorLockSettingPageController(
      {required super.context, required this.deviceId});
}

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

  ///是否支持省电模式
  bool _supportPowerSavingMode = false;

  ///当前省电模式显示文案
  String _powerSaveModeText = '';

  ///是否支持网络管理
  bool _supportNetManager = false;

  ///猫眼能力集
  DoorLockCatEyeFunction? _catEyeFunction;

  late final DoorLockSettingPageController _pageController;

  ///当前设备名称，取设备列表中的昵称，取不到时兜底显示序列号
  String get _deviceName =>
      DeviceManager.instance.getDeviceName(deviceId: widget.deviceId) ??
      widget.deviceId;

  ///被分享的设备不允许修改名称
  bool get _isSharedDevice =>
      DeviceManager.instance.getDevice(deviceId: widget.deviceId)?.fromShare ??
      false;

  ///有设置权限或电子钥匙分享的设备才显示快捷功能
  bool get _showQuickFunEntry {
    final device = DeviceManager.instance.getDevice(deviceId: widget.deviceId);
    if (device == null) {
      return false;
    }
    return device.hasPermission(permission: DevicePermission.DP_Settings) ||
        device.hasPermission(permission: DevicePermission.DP_DoorLockEleKey);
  }

  ///支持省电模式、已配网且有设置/电子钥匙权限的设备才显示省电模式入口
  bool get _showPowerSaveEntry {
    final device = DeviceManager.instance.getDevice(deviceId: widget.deviceId);
    if (device == null || !_supportPowerSavingMode) {
      return false;
    }
    return device.doorlockIsConfigNet &&
        (device.hasPermission(permission: DevicePermission.DP_Settings) ||
            device.hasPermission(
                permission: DevicePermission.DP_DoorLockEleKey));
  }

  ///支持网络管理的设备才显示网络设置入口
  bool get _showNetManageEntry => _supportNetManager;

  ///能力集内任一项支持且具备设置/电子钥匙权限的设备才显示屏幕设置入口
  bool get _showScreenSetEntry {
    final device = DeviceManager.instance.getDevice(deviceId: widget.deviceId);
    if (device == null || _catEyeFunction == null) {
      return false;
    }
    var function = _catEyeFunction!;
    var supportItem = function.camsRotate.isNotEmpty ||
        function.screenShutDown ||
        function.screenInvert ||
        function.showTimeTitle ||
        function.showExWidgets ||
        function.videoUsbSpeedMode ||
        function.doorbellScreenWakeon;
    if (!supportItem) {
      return false;
    }
    return device.hasPermission(permission: DevicePermission.DP_Settings) ||
        device.hasPermission(permission: DevicePermission.DP_DoorLockEleKey);
  }

  ///影子服务能力支持且具备设置/电子钥匙权限的设备才显示提示音入口
  bool get _showTipVolumeEntry {
    if (!DoorLockHelper.supportTipVolumeBell(deviceId: widget.deviceId)) {
      return false;
    }
    final device = DeviceManager.instance.getDevice(deviceId: widget.deviceId);
    if (device == null) {
      return false;
    }
    return device.hasPermission(permission: DevicePermission.DP_Settings) ||
        device.hasPermission(permission: DevicePermission.DP_DoorLockEleKey);
  }

  ///设备是否已配网
  bool get _isConfigNet =>
      DeviceManager.instance
          .getDevice(deviceId: widget.deviceId)
          ?.doorlockIsConfigNet ??
      false;

  ///联网锁且锁板能力支持语言设置、具备设置/电子钥匙权限的设备才显示语言设置入口
  bool get _showLanguageEntry {
    final device = DeviceManager.instance.getDevice(deviceId: widget.deviceId);
    if (device == null || !DoorLockHelper.isIotDoorLock(widget.deviceId)) {
      return false;
    }
    if (device.doorLockBleAbility?.byte2.supportLanguage != true) {
      return false;
    }
    return device.hasPermission(permission: DevicePermission.DP_Settings) ||
        device.hasPermission(permission: DevicePermission.DP_DoorLockEleKey);
  }

  ///入口副标题显示当前门锁语言，未取到锁具配置时为空
  String get _languageText =>
      _setConfig?.lan == null ? '' : doorLockLanguageName(_setConfig!.lan);

  @override
  void initState() {
    super.initState();
    _pageController = DoorLockSettingPageController(
        context: context, deviceId: widget.deviceId);
    final cachedRaw =
        DoorLockLocalCache.doorlockOnlineConfig(deviceId: widget.deviceId);
    if (cachedRaw.isNotEmpty) {
      _setConfig = parseRawToSetConfig(cachedRaw);
    }
    _queryConfig();
    _queryPowerSaving();
    _queryNetManager();
    _queryCatEyeFunction();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _queryConfig() async {
    final rawList =
        await DoorLockHelper.instance.queryOnlineCongfig(widget.deviceId);
    if (!mounted || rawList == null || rawList.isEmpty) return;
    _setConfig = parseRawToSetConfig(rawList);
    setState(() {});
  }

  ///查询是否支持省电模式，并从影子服务读取当前模式用于入口展示
  Future<void> _queryPowerSaving() async {
    final device = DeviceManager.instance.getDevice(deviceId: widget.deviceId);
    _supportPowerSavingMode = (device?.props ?? []).contains('powerSavingMode');
    if (!_supportPowerSavingMode) {
      if (mounted) setState(() {});
      return;
    }
    try {
      final map = await JFApi.xcDevice.xcDevGetConfigFromShadowServer(
          deviceId: widget.deviceId, configs: ['System.Sleep']);
      final sleep = map['System.Sleep'];
      if (sleep is Map) {
        final model = DookLockSystemLightSleep.from(
            Map<String, dynamic>.from(sleep['LightSleep'] as Map));
        var currentMode = DoorLockSavePowerModeType.from(model.mode);
        if (currentMode == DoorLockSavePowerModeType.monitorMode &&
            model.supportMods.contains(4)) {
          currentMode = DoorLockSavePowerModeType.monitorCustomMode;
        }
        _powerSaveModeText = currentMode.toStr();
      }
    } catch (e) {
      //
    }
    if (mounted) setState(() {});
  }

  ///查询是否支持网络管理
  void _queryNetManager() {
    _supportNetManager =
        DoorLockHelper.instance.supportNetManager(widget.deviceId);
    if (mounted) setState(() {});
  }

  ///查询猫眼能力集：仅设备指令可走wifi时才需要拉取
  Future<void> _queryCatEyeFunction() async {
    final device = DeviceManager.instance.getDevice(deviceId: widget.deviceId);
    if (device == null ||
        (device.doolockCmdStatus != DoolockCmdStatus.onlyWifi &&
            device.doolockCmdStatus != DoolockCmdStatus.wifiAndBlue)) {
      return;
    }
    try {
      final result = await DoorLockNetIp.getDoorLockCatEyeFunction(
          deviceId: widget.deviceId);
      if (!mounted || result.item1 == null) {
        return;
      }
      _catEyeFunction = result.item1;
      setState(() {});
    } catch (e) {
      debugPrint('queryCatEyeFunction error: ${kErrorMsg(e)}');
    }
  }

  ///网络设置：未配网直接进配网，已配网进网络设置首页
  void _jumpNetSetting() {
    final device = DeviceManager.instance.getDevice(deviceId: widget.deviceId);
    if (device != null && device.doorlockIsConfigNet) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DoorLockNetManagePage(deviceId: widget.deviceId),
        ),
      );
    } else {
      DoorLockWifiConfigJumper.jumpBlueConfig(_pageController);
    }
  }

  ///提示音：设备休眠或离线时不进入
  void _jumpTipVolume() {
    final device = DeviceManager.instance.getDevice(deviceId: widget.deviceId);
    if (device == null) {
      return;
    }
    if (device.sleepState == DeviceSleepState.deepSleep) {
      KToast.show(status: '设备处于深度休眠，无法唤醒');
      return;
    }
    if (device.sleepState == DeviceSleepState.sleeping ||
        device.sleepState == DeviceSleepState.preSleep) {
      KToast.show(status: '设备正在休眠，请唤醒后重试');
      return;
    }
    if (device.doolockCmdStatus == DoolockCmdStatus.offline) {
      KToast.show(status: '设备离线，请稍后重试');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoorLockTipVolumeSetPage(deviceId: widget.deviceId),
      ),
    );
  }

  ///语言设置：无锁具配置时先拉一次在线配置，仍取不到则提示后不进入
  Future<void> _jumpLanguageSet() async {
    var setConfig = _setConfig;
    if (setConfig == null) {
      final rawList =
          await DoorLockHelper.instance.queryOnlineCongfig(widget.deviceId);
      if (rawList != null && rawList.isNotEmpty) {
        setConfig = parseRawToSetConfig(rawList);
        _setConfig = setConfig;
      }
    }
    if (!mounted) return;
    if (setConfig == null) {
      KToast.show(status: '数据获取失败，请稍后重试');
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoorLockLanguagePage(
          deviceId: widget.deviceId,
          initSetConfig: setConfig!,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
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
              if (_showQuickFunEntry)
                ListTile(
                  leading: const Icon(Icons.bolt_outlined),
                  title: const Text('快捷功能'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DoorLockQuickFunPage(deviceId: widget.deviceId),
                      ),
                    );
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
              if (_showLanguageEntry)
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: const Text('语言设置'),
                  subtitle: _languageText.isEmpty ? null : Text(_languageText),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _jumpLanguageSet,
                ),
              if (_showNetManageEntry)
                ListTile(
                  leading: const Icon(Icons.wifi),
                  title: Text(TR.current.TR_Setting_Network_Set),
                  subtitle: Text(
                    _isConfigNet
                        ? TR.current.TR_DoorLock_Net_Manage_Connected_Wifi
                        : TR.current.TR_DoorLock_Net_Manage_Not_Connect_Wifi,
                    style: _isConfigNet
                        ? null
                        : const TextStyle(fontSize: 13, color: Colors.red),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _jumpNetSetting,
                ),
              if (_showPowerSaveEntry)
                ListTile(
                  leading: const Icon(Icons.battery_saver_outlined),
                  title: const Text('省电模式'),
                  subtitle: _powerSaveModeText.isEmpty
                      ? null
                      : Text(_powerSaveModeText),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DoorLockSavePowerModeHomePage(
                          deviceId: widget.deviceId,
                        ),
                      ),
                    );
                    _queryPowerSaving();
                  },
                ),
              if (_showScreenSetEntry)
                ListTile(
                  leading: const Icon(Icons.monitor_outlined),
                  title: Text(TR.current.TR_Device_Lock_Screen_Setting_Title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DoorLockScreenSetPage(
                          deviceId: widget.deviceId,
                          catEyeFunction: _catEyeFunction,
                        ),
                      ),
                    );
                  },
                ),
              if (_showTipVolumeEntry)
                ListTile(
                  leading: const Icon(Icons.volume_up_outlined),
                  title: Text(TR.current.TR_Settings_Open_Voice),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _jumpTipVolume,
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

      ///异步同步报警订阅中的设备名称，不阻塞保存提示
      _syncSubscribeDeviceName(textController.text);
      KToast.show(status: '保存成功');
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
      textController.text = _deviceName;
      KToast.show(status: kErrorMsg(error));
    });
  }

  ///仅在服务端已订阅时重新订阅以更新推送中的设备名称，
  ///避免把用户主动关闭的推送重新打开
  Future<void> _syncSubscribeDeviceName(String deviceName) async {
    if (_isSharedDevice) return;
    if (await PushManager.instance.isSubscribed(widget.deviceId)) {
      try {
        await PushManager.instance
            .subscribe(widget.deviceId, deviceName: deviceName);
      } catch (e) {
        debugPrint('更新订阅名称失败: $e');
      }
    }
  }
}
