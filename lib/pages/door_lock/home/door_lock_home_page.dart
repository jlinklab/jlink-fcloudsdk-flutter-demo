import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/door_lock/controller/door_lock_home_controller.dart';
import 'package:fcloudsdk_example/pages/door_lock/repository/door_lock_local.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///门锁首页
/// 门锁休眠状态可能不准确，还未接入mqtt
class DoorLockHomePage extends StatefulWidget {
  final String deviceId;

  const DoorLockHomePage({super.key, required this.deviceId});

  @override
  State<DoorLockHomePage> createState() => _DoorLockHomePageState();
}

class _DoorLockHomePageState extends State<DoorLockHomePage> {
  late DoorLockHomeController controller;

  ///设备对象
  Device? get _device =>
      DeviceManager.instance.getDevice(deviceId: widget.deviceId);

  ///门锁是否已配网
  bool get _doorlockIsConfigNet =>
      DoorLockLocalCache.doorlockIsConfigNet(deviceId: _device?.uuid ?? "");

  ///设备是否在线
  bool get _online => (_device?.state ?? 0) > 0;

  ///休眠状态
  DeviceSleepState? get _sleepState => _device?.sleepState;

  bool get _wifiOnline => _doorlockIsConfigNet && _online;

  bool get _wifiOffline => _doorlockIsConfigNet && !_online;

  ///远程操作是否可用
  bool get _enableOperation =>
      controller.device.doolockCmdStatus != DoolockCmdStatus.offline;

  Color get _primaryColor => Theme.of(context).primaryColor;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => controller = DoorLockHomeController(
              context: context,
              deviceId: widget.deviceId,
            ),
        child: Consumer<DoorLockHomeController>(
            builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F7F9),
            appBar: AppBar(
              title: Text(_device?.nickname ?? widget.deviceId),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    //缩略图区
                    Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: [
                        const SizedBox(width: double.infinity),
                        thumbnail(),
                      ],
                    ),
                    const SizedBox(height: 22),
                    //远程开关锁操作条
                    lockActions(),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        }));
  }

  Widget thumbnail() {
    var width = (MediaQuery.of(context).size.width * 0.38).ceil().toDouble();
    if (width > 150) width = 150;
    var height = (width / (3 / 5)).ceil().toDouble();

    // wifi 在线
    if (_wifiOnline) {
      Color borderColors = _primaryColor;
      if (_sleepState == DeviceSleepState.lightSleep) {
        borderColors = Colors.orange.shade300;
      } else if (_sleepState == DeviceSleepState.preSleep) {
        borderColors = Colors.purple.shade400;
      } else if (_sleepState == DeviceSleepState.deepSleep) {
        borderColors = Colors.indigo.shade200;
      }

      return GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(color: borderColors, width: 5),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
              width: width,
              height: height,
              color: Colors.transparent,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _buildDefaultThumb(width: width, height: height),
                  ),
                  _sleepState == DeviceSleepState.deepSleep
                      ? const Icon(Icons.bedtime,
                          size: 60, color: Colors.white70)
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // wifi 离线
    if (_wifiOffline) {
      return GestureDetector(
        onTap: () {
          //低功耗蓝牙锁 || 国内锁 → 离线弹窗；否则 → 设备状态提示
          if (DoorLockHelper.isLowPowerBle(widget.deviceId) ||
              !DoorLockHelper.isOverSeaDoorLock(widget.deviceId)) {
            _showOfflineTipsDialog();
          } else {
            _showDeviceStateTipDialog();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(color: Colors.grey, width: 5),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
              width: width,
              height: height,
              color: Colors.transparent,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      children: [
                        _buildDefaultThumb(width: width, height: height),
                        Container(
                          width: width,
                          height: height,
                          color: const Color(0xFF3A4C51).withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 60, color: Colors.white),
                      Text(
                        TR.current.deviceOffline,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 默认
    return Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(top: 40, bottom: 10),
        width: width,
        height: height,
        child: Image.asset(
          'images/monitor_bg.png',
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: width,
            height: height,
            color: const Color(0xFFE5E5EA),
          ),
        ));
  }

  ///远程关锁 / 远程开锁
  Widget lockActions() {
    final List<Widget> actions = [];

    int actionCount = 0;
    if (_showRemoteLock()) actionCount++;
    if (_showRemoteUnlock()) actionCount++;
    if (actionCount == 0) return const SizedBox.shrink();

    final maxWidth = (MediaQuery.of(context).size.width - 20) / actionCount;

    if (_showRemoteLock()) {
      actions.add(
        GestureDetector(
          onTap: () {
            controller.lockDoorInHome(needSleep: false);
          },
          onDoubleTap: () {},
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 24, color: Colors.white),
                  SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      '远程关锁',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_showRemoteUnlock()) {
      actions.add(
        GestureDetector(
          onTap: () {
            controller.unlockDoorInHome(needSleep: false);
          },
          onDoubleTap: () {},
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.lock_open, size: 24, color: Colors.white),
                  SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      '远程开锁',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(22)),
      child: Container(
        color: _enableOperation ? _primaryColor : Colors.grey,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _join(
              actions,
              Container(
                color: Colors.white,
                width: 1,
                height: 16,
              )),
        ),
      ),
    );
  }

  // ==================== 显示条件（demo 兜底：默认全部显示）====================

  ///远程关锁入口显示条件
  bool _showRemoteLock() =>
      DoorLockHelper.showRemoteLock(deviceId: widget.deviceId);

  ///远程开锁入口显示条件
  bool _showRemoteUnlock() => true;

  ///点击离线缩略图 → 离线提示弹窗
  void _showOfflineTipsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(TR.current.deviceOffline),
        content: const Text('设备当前离线，请检查网络或稍后重试'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(TR.current.confirmBtn),
          ),
        ],
      ),
    );
  }

  ///点击离线缩略图 → 海外锁 IoT 设备状态提示
  void _showDeviceStateTipDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(TR.current.deviceOffline),
        content: const Text('设备当前不可用，请稍后重试'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(TR.current.confirmBtn),
          ),
        ],
      ),
    );
  }

  List<Widget> _join(List<Widget> items, Widget separator) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) result.add(separator);
      result.add(items[i]);
    }
    return result;
  }

  ///默认缩略图占位
  Widget _buildDefaultThumb({required double width, required double height}) {
    return Image.asset(
      'images/monitor_bg.png',
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: const Color(0xFFE5E5EA),
      ),
    );
  }
}
