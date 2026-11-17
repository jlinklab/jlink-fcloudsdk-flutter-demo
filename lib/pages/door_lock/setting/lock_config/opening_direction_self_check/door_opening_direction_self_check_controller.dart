import 'dart:async';
import 'dart:convert';

import 'package:fcloudsdk/api/device_serial_port/device_serial_port.dart';
import 'package:fcloudsdk/api/device_serial_port/device_serial_port_api.dart';
import 'package:fcloudsdk/ble_by_sdk/ble_message.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/global_ble_search_manager.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_set_config.dart';
import 'package:fcloudsdk_example/utils/permission_utils.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';

///开锁方向自检页面控制器
class DoorOpeningDirectionSelfCheckController extends DoorLockPageController
    with DoorLockSetConfigMixin {
  @override
  final String deviceId;

  static const _initialTips = '点击开始检测，门锁将进入自动检测状态';
  static const _checkingTips = '门锁正在进行开锁方向检测，请稍后...';
  static const _responseTimeout = Duration(seconds: 20);

  bool checking = false;
  bool selfCheckSuccess = false;
  String tipsText = _initialTips;
  bool _disposed = false;

  StreamSubscription<BleMessage>? _bleSubscription;
  DeviceSerialPort? _wifiSerialPort;
  StreamSubscription<String>? _wifiPortSubscription;

  DoorOpeningDirectionSelfCheckController({
    required super.context,
    required this.deviceId,
  }) {
    createDoorLockAPI();
  }

  String get primaryButtonText => selfCheckSuccess ? '完成' : '开始检测';

  ///执行主按钮操作，自检完成后返回 true 由页面退出
  Future<bool> handlePrimaryAction() async {
    if (checking) return false;
    if (selfCheckSuccess) return true;
    await _startSelfCheck();
    return false;
  }

  Future<void> _startSelfCheck({bool forceBle = false}) async {
    if (checking || _disposed) return;

    if (!forceBle && _needBleConnectGuide) {
      final retry = await _showBleConnectGuideDialog();
      if (retry == true) {
        await _startSelfCheck(forceBle: true);
      }
      return;
    }

    checking = true;
    selfCheckSuccess = false;
    tipsText = _checkingTips;
    _notify();
    KToast.show();

    var resultCode = -1;
    String? failureMessage;
    try {
      if (forceBle) {
        resultCode = await _startBleCheck();
      } else if (_isTuyaBKOverseasAndConfigNet) {
        resultCode = await _startTuyaBKCheck();
      } else {
        resultCode = await _startBleCheck();
      }
    } on _SelfCheckException catch (e) {
      failureMessage = e.message;
    } on TimeoutException {
      failureMessage = '开锁自检失败，请稍后重试';
    } catch (e) {
      LogUtils.doorLock.log('opening direction self check error: $e');
      failureMessage = '开锁自检失败，请重试';
    }

    KToast.dismiss();
    if (_disposed) return;

    checking = false;
    if (resultCode == 0) {
      selfCheckSuccess = true;
      tipsText = '开锁方向检测完成！';
    } else {
      tipsText = _initialTips;
    }
    _notify();

    if (resultCode > 0) {
      _showErrorWithCode(resultCode);
    } else if (resultCode < 0 && failureMessage != null) {
      KToast.show(status: failureMessage);
    }
  }

  ///检查蓝牙权限和开关后发送自检命令
  Future<int> _startBleCheck() async {
    await _checkBlePermission();
    if (!await ensureBleReadyForCommand()) {
      throw const _SelfCheckException('连接失败，请靠近门锁后重试');
    }

    final api = doorLockBleApi;
    if (api == null) {
      throw const _SelfCheckException('蓝牙连接失败，请稍后重试');
    }

    final completer = Completer<int>();
    _bleSubscription = api.listenStream(
      (message) {
        final bytes = message.bytes;
        if (bytes.length < 6) {
          if (!completer.isCompleted) {
            completer.completeError(
              const _SelfCheckException('门锁响应数据异常，请重试'),
            );
          }
          return;
        }
        if (!completer.isCompleted) {
          completer.complete(bytesToInt(bytes.sublist(4, 6)));
        }
      },
      where: (message) =>
          message.bytes.isNotEmpty && message.bytes.first == 0x48,
      completer: completer,
      needTimeoOut: false,
    );

    try {
      final sent = await api.bleObject.sendMsgTransparent(
        bytesToHex(const [0x48, 0x02, 0x01, 0x03]),
      );
      if (!sent) {
        throw const _SelfCheckException('自检命令发送失败，请重试');
      }
      return await completer.future.timeout(_responseTimeout);
    } finally {
      unawaited(_bleSubscription?.cancel());
      _bleSubscription = null;
    }
  }

  Future<void> _checkBlePermission() async {
    try {
      await GlobalBleSearchManager.instance.checkPermission();
    } catch (e) {
      throw const _SelfCheckException('操作失败，请确认蓝牙权限是否已打开');
    }

    final authorized = await PermissionUtils.checkPermission(
      permission: XPermission.blueService,
      onlyStatus: true,
    );
    if (!authorized) {
      throw const _SelfCheckException('操作失败，请确认蓝牙权限是否已打开');
    }

    final bluetoothEnabled = await PermissionUtils.checkPermission(
      permission: XPermission.blueSwitch,
      onlyStatus: true,
    );
    if (!bluetoothEnabled) {
      throw const _SelfCheckException('操作失败，请确认蓝牙是否已打开');
    }
  }

  bool get _isTuyaBKOverseasAndConfigNet {
    final parentPid = device.parentPid;
    final isTuyaBK =
        parentPid == 'HAVLK001X0001001' || parentPid == 'HAVLK0020000100V';
    return isTuyaBK && device.doorlockIsConfigNet;
  }

  bool get _isBLEUserManager {
    return device.props?.any(
          (prop) => prop.toLowerCase() == 'bleusermanager',
        ) ??
        false;
  }

  bool get _canDeviceWakeUp {
    return device.doolockCmdStatus != DoolockCmdStatus.offline &&
        device.sleepState != DeviceSleepState.deepSleep &&
        device.sleepState != DeviceSleepState.preSleep;
  }

  bool get _needBleConnectGuide {
    return _isTuyaBKOverseasAndConfigNet &&
        _isBLEUserManager &&
        supportConfigByWifiTrans &&
        !device.blueOnline &&
        !_canDeviceWakeUp;
  }

  Future<int> _startTuyaBKCheck() async {
    if (_isBLEUserManager && supportConfigByWifiTrans) {
      if (device.blueOnline) return _startBleCheck();
      if (_canDeviceWakeUp) return _startWifiCheck();
    }
    if (!_isBLEUserManager || !supportConfigByWifiTrans) {
      return _startWifiCheck();
    }
    return _startBleCheck();
  }

  ///通过串口发送自检帧并等待锁端应答
  Future<int> _startWifiCheck() async {
    final serialPort = DeviceSerialPort(
      deviceId: deviceId,
      type: SerialPortType.rs232,
    );
    _wifiSerialPort = serialPort;
    final completer = Completer<int>();

    try {
      await serialPort.open();
      if (!serialPort.isOpen) {
        throw const _SelfCheckException('设备连接失败，请稍后重试');
      }

      _wifiPortSubscription = serialPort.portStream.listen(
        (data) {
          if (data.isEmpty || completer.isCompleted) return;
          try {
            final bytes = base64Decode(data);
            if (bytes.length < 6 || bytes.first != 0x48) {
              throw const _SelfCheckException('门锁响应数据异常，请重试');
            }
            completer.complete(bytesToInt(bytes.sublist(4, 6)));
          } catch (e) {
            if (!completer.isCompleted) completer.completeError(e);
          }
        },
        onError: (Object error) {
          if (!completer.isCompleted) completer.completeError(error);
        },
      );

      await serialPort.write(base64Encode(_buildSelfCheckWifiFrame()));
      return await completer.future.timeout(_responseTimeout);
    } finally {
      await _closeWifiSerialPort();
    }
  }

  List<int> _buildSelfCheckWifiFrame() {
    const header = [0x55, 0xAA, 0x00, 0x06];
    const command = [0x48, 0x02, 0x01, 0x03];
    final length = [
      (command.length >> 8) & 0xFF,
      command.length & 0xFF,
    ];
    final frame = [...header, ...length, ...command];
    final crc = frame.fold<int>(0, (sum, byte) => sum + byte) % 256;
    return [...frame, crc];
  }

  Future<bool?> _showBleConnectGuideDialog() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('提示'),
        content: const Text('请在门外操作按键输入5#后，\n于一分钟内完成操作'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('开始连接'),
          ),
        ],
      ),
    );
  }

  void _showErrorWithCode(int errorCode) {
    if (!context.mounted) return;
    const errorMessages = [
      '开门光电异常',
      '回位光电异常',
      '关门光电异常',
      '干簧管异常',
      '开关门堵转',
      '回位堵转',
      '开关门超时',
      '回位超时',
    ];
    final errors = <String>[];
    for (var bit = 0; bit < errorMessages.length; bit++) {
      if (errorCode & (1 << bit) != 0) {
        errors.add(errorMessages[bit]);
      }
    }
    final message = errors.isEmpty ? '开锁自检失败' : '开锁自检失败：${errors.join('、')}';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _closeWifiSerialPort() async {
    await _wifiPortSubscription?.cancel();
    _wifiPortSubscription = null;
    await _wifiSerialPort?.close();
    _wifiSerialPort = null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_bleSubscription?.cancel());
    _bleSubscription = null;
    unawaited(_closeWifiSerialPort());
    if (checking) KToast.dismissInDispose();
    super.dispose();
  }
}

class _SelfCheckException implements Exception {
  final String message;

  const _SelfCheckException(this.message);
}
