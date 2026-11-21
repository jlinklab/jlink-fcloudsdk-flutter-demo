import 'dart:async';

import 'package:fcloudsdk/ble_by_sdk/ble_message.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:flutter/material.dart';

///网络检测结果
enum DoorLockNetCheckStatus {
  ///未开始
  nostart,

  ///检测中
  checking,

  ///检测成功（已连接云服务器）
  success,

  ///检测结束（未连接云服务器）
  failed,
}

///网络检测页：30s内轮询下发蓝牙网络检测指令，返回终态即停，超时按最后状态收口
class DoorLockNetCheckController extends DoorLockPageController {
  @override
  final String deviceId;

  ///网络检测指令帧主体：版本02+命令字01+指令类型0001+数据类型00+长度0001+数据00
  ///空数据也需要传长度
  static const String _checkNetFrame = '0201000100000100';

  ///网络检测指令类型
  static const int _cmdCheckNet = 0x0001;

  ///单次检测等待设备响应超时
  static const Duration _responseTimeout = Duration(seconds: 10);

  ///检测总时长
  static const Duration _totalTimeout = Duration(seconds: 30);

  ///检测结果状态
  DoorLockNetCheckStatus status = DoorLockNetCheckStatus.nostart;

  ///当前状态文案
  String stateText = '';

  ///剩余检测秒数
  int countdown = 0;

  ///是否检测中
  bool _checking = false;

  ///最后一次查询到的状态文案（超时收口用）
  String? _lastStateText;

  ///控制器是否已销毁，销毁后不再刷新视图
  bool _disposed = false;

  StreamSubscription<BleMessage>? _bleSub;
  Timer? _countdownTimer;
  Timer? _responseTimer;

  ///蓝牙离线重连弹窗标志，防止重复弹出
  bool _reconnectDialogShowing = false;

  DoorLockNetCheckController({required super.context, required this.deviceId}) {
    createDoorLockAPI();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      startCheck();
    });
  }

  ///开始/重新检测
  Future<void> startCheck() async {
    if (doorLockBleApi == null) {
      ///蓝牙对象未建立，弹窗询问用户是否重试连接
      var confirm = await _dealBleNotReady();
      if (!confirm) {
        return;
      }
    }

    _stopTimers();
    _checking = true;
    status = DoorLockNetCheckStatus.checking;
    stateText = TR.current.TR_DoorLock_Net_Checking;
    _lastStateText = null;
    countdown = _totalTimeout.inSeconds;
    _notify();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown--;
      if (countdown <= 0) {
        ///超时按最后查到的状态收口
        _finishCheck(
            _lastStateText ?? TR.current.TR_DoorLock_Settings_Net_Check_Failed,
            success: false);
      } else {
        _notify();
      }
    });

    _listenCheckNetResult();

    if (doorLockBleApi == null || _disposed) {
      ///等待蓝牙在线
      bool online = await waitBleOnline();
      if (!online || _disposed) {
        _finishCheck(TR.current.TR_Ble_DoorLock_Reconnect_Failed,
            success: false);
        return;
      }

      await DoorLockHelper.refreshDoorLockStatus(deviceId, queryNet: true);
      createDoorLockAPI();
    }

    if (doorLockBleApi == null || _disposed) {
      _finishCheck(TR.current.TR_Ble_DoorLock_Reconnect_Failed, success: false);
      return;
    }

    _sendCheck();
  }

  ///下发一次网络检测指令
  _sendCheck() async {
    _responseTimer?.cancel();
    _responseTimer = Timer(_responseTimeout, () {
      ///单次检测无响应视为检测失败
      _finishCheck(TR.current.TR_DoorLock_Settings_Net_Check_Failed,
          success: false);
    });

    try {
      ///内部包含连接与握手等待，未就绪返回false
      var sent = await doorLockBleApi?.bleObject
          .sendTransparentDataHex(_checkNetFrame);
      if (!_checking) return;
      if (sent != true) {
        _finishCheck(TR.current.TR_Ble_DoorLock_Reconnect_Failed,
            success: false);
      }
    } catch (e) {
      if (!_checking) return;
      _finishCheck(TR.current.TR_Ble_DoorLock_Reconnect_Failed, success: false);
    }
  }

  ///蓝牙未就绪处理：弹窗询问用户是否重试连接
  Future<bool> _dealBleNotReady() async {
    if (_reconnectDialogShowing || _disposed) {
      return false;
    }
    _reconnectDialogShowing = true;

    try {
      if (!context.mounted) {
        return false;
      }

      var confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('提示'),
            content: Text(TR.current.TR_Ble_DoorLock_Reconnect_Tips),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(TR.current.TR_Common_Try_Again),
              ),
            ],
          );
        },
      );

      if (confirm != true) {
        return false;
      }

      return true;
    } finally {
      _reconnectDialogShowing = false;
    }
  }

  ///监听网络检测指令透传应答
  _listenCheckNetResult() {
    var api = doorLockBleApi;
    if (api == null) {
      return;
    }
    _bleSub?.cancel();
    _bleSub = api.bleObject.apiStreamController.stream.listen(
      (message) {
        if (!_checking) {
          return;
        }
        if (message.what != BleMessageID.DOORLOCK_TRANSPARENT_DATA_HEX) {
          return;
        }
        if (message.param1 != _cmdCheckNet) {
          return;
        }
        if (message.str.length < 18) {
          return;
        }

        ///帧主体数据段：[0]=结果（1成功），[1]=网络状态
        var resultByte =
            int.tryParse(message.str.substring(14, 16), radix: 16) ?? 0;
        var stateByte =
            int.tryParse(message.str.substring(16, 18), radix: 16) ?? 0;
        debugPrint(
            'net check result: $resultByte, state: $stateByte, data: ${message.str}');
        _onCheckResult(stateByte);
      },
      onError: (error) {
        debugPrint('BLE stream error: $error');
        if (_checking) {
          _finishCheck(TR.current.TR_DoorLock_Settings_Net_Check_Failed,
              success: false);
        }
      },
    );
  }

  ///处理设备网络状态
  ///0=未获取到Wifi状态（重新查询）、1=门锁未配网（终态）、2=路由器连接失败/连接中（重新查询）、
  ///3=路由器连接成功云服务器失败（重新查询）、4=已连接云服务器（终态）、255=仅支持蓝牙（终态）
  _onCheckResult(int state) {
    if (!_checking) {
      return;
    }

    var text = TR.current.TR_DoorLock_Settings_Net_Not_Get_State;
    var terminal = false;
    switch (state) {
      case 0:
        text = TR.current.TR_DoorLock_Settings_Net_Not_Get_State;
        terminal = false;
        break;
      case 1:
        text = TR.current.TR_DoorLock_Settings_Net_Not_Config_Wifi;
        terminal = true;
        break;
      case 2:
        text = TR.current.TR_DoorLock_Settings_Net_Connecting;
        terminal = false;
        break;
      case 3:
        text = TR.current.TR_DoorLock_Settings_Net_Already_Connect_Station;
        terminal = false;
        break;
      case 4:
        text = TR.current.TR_DoorLock_Settings_Net_Already_Connect_Server;
        terminal = true;
        break;
      case 255:
        text = TR.current.TR_DoorLock_Settings_Net_Not_Support_Wifi;
        terminal = true;
        break;
      default:
        text = TR.current.TR_DoorLock_Settings_Net_Check_Failed;
        terminal = true;
        break;
    }

    if (terminal) {
      ///终态：1=未配网、4=已连接云服务器、255=仅支持蓝牙、其他=检测失败
      bool success = state == 4;
      _finishCheck(text, success: success);
    } else {
      _lastStateText = text;
      stateText = text;
      _notify();

      ///非终态继续查询
      _sendCheck();
    }
  }

  ///结束检测并展示结果
  _finishCheck(String text, {required bool success}) {
    _checking = false;
    _stopTimers();
    stateText = text;
    status = success
        ? DoorLockNetCheckStatus.success
        : DoorLockNetCheckStatus.failed;
    _notify();
  }

  _stopTimers() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _responseTimer?.cancel();
    _responseTimer = null;
  }

  _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  dispose() {
    _disposed = true;
    _checking = false;
    _stopTimers();
    _bleSub?.cancel();
    _bleSub = null;
    super.dispose();
  }
}
