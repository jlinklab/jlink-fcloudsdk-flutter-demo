import 'dart:async';

import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/network/usecase/door_lock_wifi_config_jumper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:flutter/material.dart';

///清网流程步骤
enum DoorLockClearNetStep {
  ///未开始
  idle,

  ///连接蓝牙中
  connecting,

  ///发送清网命令中
  sending,

  ///等待设备重启
  waitingRestart,

  ///重连设备中
  reconnecting,

  ///流程失败，可重试
  failed,
}

///清空设备网络页：连接蓝牙 → 下发清网命令 → 等设备重启 → 重连后进入配网
class DoorLockResetNetController extends DoorLockPageController {
  @override
  final String deviceId;

  ///等待清网命令应答超时
  static const Duration _ackTimeout = Duration(seconds: 10);

  ///断开后等待设备重启的时间
  static const Duration _waitRestartDuration = Duration(milliseconds: 2500);

  ///重连失败重试次数
  static const int _reconnectRetryMax = 3;

  ///当前步骤
  DoorLockClearNetStep step = DoorLockClearNetStep.idle;

  ///步骤文案（连接蓝牙/发送命令/等待重启）
  String? step1Text;
  String? step2Text;
  String? step3Text;

  ///控制器是否已销毁，销毁后不再刷新视图
  bool _disposed = false;

  ///是否已发送清网命令（发送后退出需用户确认）
  bool _clearCmdSent = false;

  DoorLockResetNetController({required super.context, required this.deviceId}) {
    createDoorLockAPI();
  }

  ///是否已发送清网命令
  bool get clearCmdSent => _clearCmdSent;

  ///连接/发送按钮文案
  String get buttonText => step == DoorLockClearNetStep.failed
      ? TR.current.TR_Common_Try_Again
      : TR.current.TR_DoorLock_Clear_Net_Start_Ble_Connect;

  ///按钮是否显示（流程执行中隐藏）
  bool get showButton =>
      step == DoorLockClearNetStep.idle || step == DoorLockClearNetStep.failed;

  ///开始/重试清网流程
  startClearNet() async {
    if (step == DoorLockClearNetStep.connecting ||
        step == DoorLockClearNetStep.sending ||
        step == DoorLockClearNetStep.waitingRestart ||
        step == DoorLockClearNetStep.reconnecting) {
      return;
    }

    step1Text = null;
    step2Text = null;
    step3Text = null;
    step = DoorLockClearNetStep.connecting;
    step1Text = TR.current.TR_DoorLock_Clear_Net_Ble_Connect_Tip;
    _notify();
    debugPrint('clear net start: $deviceId');

    var api = doorLockBleApi;
    if (api == null) {
      _onFailed();
      return;
    }

    ///连接并握手
    var result = await api.bleObject.waitReadyIfNeed();
    if (_disposed) {
      return;
    }
    debugPrint('clear net ble ready: ${result.item1}, error: ${result.item2}');
    if (result.item1 != true) {
      _onFailed();
      return;
    }

    step1Text = TR.current.TR_DoorLock_Clear_Net_Ble_Connect_Success;
    step = DoorLockClearNetStep.sending;
    step2Text = TR.current.TR_DoorLock_Clear_Net_Send_Comm_Tip;
    _notify();

    ///重置网络即清网指令，内部包含连接与握手等待，结果通过14025回调
    int? resetResult;
    try {
      resetResult = await api.bleObject.blueResetNetwork().timeout(_ackTimeout);
    } on TimeoutException {
      debugPrint('clear net reset network ack timeout: $_ackTimeout');
      _onFailed();
      return;
    }
    if (_disposed) {
      return;
    }

    debugPrint('clear net result: $resetResult');
    if (resetResult == null || resetResult != 0) {
      debugPrint('clear net reset network fail: $resetResult');
      _onFailed();
      return;
    }

    _clearCmdSent = true;
    _handleClearNetSuccess();
  }

  ///收到清网应答：上报配网状态并等待设备重启重连
  _handleClearNetSuccess() async {
    debugPrint('clear net ack success, wait device restart');
    step2Text = TR.current.TR_DoorLock_Clear_Net_Send_Comm_Success;
    step = DoorLockClearNetStep.waitingRestart;
    step3Text = TR.current.TR_DoorLock_Clear_Net_Wait_Restart_Tip;
    _notify();

    ///清网后配网状态同步服务端
    await DoorLockHelper.setDeviceNetProvision(false, deviceId);

    ///断开蓝牙，等待设备重启
    await doorLockBleApi?.bleObject.stopConnect();
    if (_disposed) {
      return;
    }

    await Future.delayed(_waitRestartDuration);
    if (_disposed) {
      return;
    }

    step = DoorLockClearNetStep.reconnecting;
    _notify();

    ///重连设备，失败按固定间隔重试
    for (var i = 0; i < _reconnectRetryMax; i++) {
      var api = doorLockBleApi;
      if (api == null) {
        _onFailed();
        return;
      }
      await api.bleObject.connectIfNeed();
      var result = await api.bleObject.waitReadyIfNeed();
      if (_disposed) {
        return;
      }
      debugPrint('clear net reconnect ${i + 1}/$_reconnectRetryMax: '
          '${result.item1}, error: ${result.item2}');
      if (result.item1 == true) {
        _onReconnectSuccess();
        return;
      }
      await Future.delayed(const Duration(seconds: 1));
      if (_disposed) {
        return;
      }
    }

    _onFailed();
  }

  ///重连成功，进入wifi密码配网页
  _onReconnectSuccess() {
    debugPrint('clear net reconnect success, jump blue config');
    step3Text = TR.current.TR_DoorLock_Clear_Net_Wait_Restart_Success;
    _notify();

    DoorLockWifiConfigJumper.jumpBlueConfig(this);
  }

  ///流程失败：按钮变重试，并弹窗确认是否已操作按键
  _onFailed({bool needDialog = true}) {
    debugPrint('clear net failed: $deviceId, showDialog: $needDialog');
    step = DoorLockClearNetStep.failed;
    _notify();

    if (needDialog && context.mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            content: Text(_operateConfirmText()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('确定'),
              ),
            ],
          );
        },
      );
    }
  }

  ///按键操作确认文案
  String _operateConfirmText() {
    return TR.current.TR_DoorLock_Clear_Net_Sure_Lock_Operate(
        TR.current.TR_DoorLock_Clear_Net_Sure_Lock_Operate_Color);
  }

  _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  dispose() {
    _disposed = true;
    super.dispose();
  }
}
