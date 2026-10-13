import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/common/event.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/models/device_type.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:go_router/go_router.dart';

/// Create by JFtech on 2025/4/24
/// 低功耗设备通用方法帮助类
/// since

///唤醒回调
///[isSuccess] 是否成功
///[deviceId] 设备序列号
typedef IWakeUpAction = void Function(bool isSuccess, String deviceId);

///休眠回调
///[deviceId] 设备序列号
typedef ISleepAction = void Function(String deviceId);

class LPDHelper {
  static final LPDHelper me = LPDHelper._();

  LPDHelper._();

  ///唤醒重试次数
  static int wakeUpRetryCount = 0; //默认重试0次

  ///休眠延时时间 15S
  static const int sleepDelay = 15;

  ///唤醒设备【低功耗】
  ///[deviceId] 设备序列号
  ///[callBack] 回调
  Future wakeUpIfNeed(String deviceId,
      {IWakeUpAction? callBack, int retryCount = 0}) async {
    if (isLPDById(deviceId)) {
      LogUtils.idr.log('try inner wakeup device, retry count $retryCount, deviceId: $deviceId');

      String? exInfo;
      if (DoorLockHelper.isDoorLock(deviceId)) {
        exInfo = jsonEncode({
          'ExtInfo': {'Cmd': '1'}
        });
      }

      var result = -1;
      var device = DeviceManager.instance.getDevice(deviceId: deviceId);
      //蓝牙netip状态下，不去调唤醒
      if ((device?.isBlueNetIpEnable ?? false) == false) {
        result = await JFApi.xcDevice.xcDeviceWakeup(
            deviceId: deviceId, exInfo: exInfo, timeout: 15000); //唤醒超时15秒
      } else {
        result = 0;
        LogUtils.idr.log(
            'wakeup skipped!, is blue netip door lock, deviceId=$deviceId');
      }

      if (result >= 0) {
        retryCount = 0;
        LogUtils.idr.log('inner wakeup device success deviceId=$deviceId');
        callBack?.call(true, deviceId);
      } else {
        if (retryCount == wakeUpRetryCount) {
          LogUtils.idr.log(
              'inner wakeup device fail, retry count $retryCount, deviceId=$deviceId');
          callBack?.call(false, deviceId);
          return;
        }

        //重试
        LogUtils.idr.log(
            'inner wakeup device fail, start retry: $retryCount, deviceId=$deviceId');
        retryCount++;
        return wakeUpIfNeed(deviceId,
            callBack: callBack, retryCount: retryCount);
      }
    }
  }

  ///休眠设备【低功耗】
  ///[deviceId] 设备序列号
  ///[sleepOnReady] 即将休眠（这里可能要处理一些额外逻辑）
  ///[sleepOnSuccess] 休眠结束【只是业务调用结束，设备不一定真正休眠】（这里可能要处理一些额外逻辑）
  Future sleepIfNeed(String deviceId,
      {ISleepAction? sleepOnReady,
      ISleepAction? sleepOnSuccess,
      ISleepAction? sleepOnFailed}) async {
    if (isLPDById(deviceId)) {
     LogUtils.idr.log('low power device to sleep, deviceId=$deviceId');

      sleepOnReady?.call(deviceId);

      var device = DeviceManager.instance.getDevice(deviceId: deviceId);
      //特殊喂食器休眠会使RPS设备状态变为离线，不去休眠
      if ((device?.isBlueNetIpEnable ?? false) == false &&
          !DeviceTypeUtil.isNotNeedSleepFeeder(device)) {
        await JFApi.xcDevice.xcDeviceSleep(deviceId: deviceId);
      } else {
        LogUtils.idr.log(
            'sleep skipped!, is blue netip door lock or special feeder, deviceId=$deviceId');
      }
      var result = await JFApi.xcDevice.xcLoginOut(deviceId: deviceId);

    LogUtils.idr.log(
          'low power device sleep and loginOut ok?=$result, deviceId=$deviceId');

      if (result) {
        sleepOnSuccess?.call(deviceId);
      } else {
        sleepOnFailed?.call(deviceId);
      }
    }
  }

  ///是否是低功耗设备
  ///[deviceId] 设备序列号
  bool isLPDById(String deviceId) {
    return isLPD(DeviceManager.instance.getDevice(deviceId: deviceId));
  }

  ///是否是低功耗设备
  ///[device] 设备实体
  bool isLPD(Device? device) {
    if (device == null) {
      return false;
    }

    var isSleepState = device.propList?.contains('sleepState') ?? false;

    if (device.isLowPowerType || //deviceType
            isSleepState || //pro is `sleepState`
            DeviceSleepState.lightSleep == device.sleepState //兜底
        ) {
      return true;
    }

    return false;
  }

  ///获取设备休眠状态(接口返回的原始数据)
  Future<int> getIDRDeviceState(String deviceId) async {
    int state = await JFApi.xcDevice
        .xcGetDeviceState(deviceId: deviceId, stateType: 8); //此接口不会唤醒设备
    LogUtils.idr.log('device state=$state, deviceId=$deviceId');
    _updateDeviceState(deviceId, state: DeviceSleepState.from(state));
    return state;
  }
}

///低功耗设备，延迟15秒休眠
extension IDRFixed on LPDHelper {
  static final Map<String, DeviceSleepState> _deviceStateMap = {};

  ///退出页面 15 S休眠
  static final Map<String, Timer?> _sleepTimerMap = {};
  static final Map<String, int> _sleepCountMap = {};

  _updateDeviceState(String deviceId, {DeviceSleepState? state}) {
    if (state != null) {
      _deviceStateMap[deviceId] = state;
    }
  }

  DeviceSleepState getIDRState({required String deviceId}) {
    return _deviceStateMap[deviceId] ?? DeviceSleepState.unknown;
  }

  ///唤醒设备
  ///检测所打开的页面是否需要唤醒设备.
  ///所打开的页面依赖设备交互,只有唤醒之后才能进行下一步,比如登录设备, 获取SystemFunction
  ///业务中有涉及到的页面有,[预览][回放-卡回放][设备配置]
  ///[wakeupDevice]方法的调用时机, 在页面打开之后, Controller 请求数据之前.
  Future<bool> wakeupDeviceIfNeed(
    String deviceId, {
    Duration? loadingTimeOut /*超时时间显示loading*/,
    bool showLoading = true,
    bool dismissOnTap = true,
    int? retryCount = 0,
  }) async {
    if (!isLPDById(deviceId)) {
      LogUtils.idr.log('wakeup skipped!, not `IDR` device, deviceId=$deviceId');
      return true;
    }

    _updateDeviceState(deviceId, state: DeviceSleepState.waking);

    //检查一下是否存在要休眠的延迟任务
    Timer? timer = _sleepTimerMap[deviceId];
    if (timer != null) {
      timer.cancel();
      LogUtils.idr.log('call #wakeUp, and cancel sleep task, deviceId=$deviceId');
    }

    _sleepTimerMap[deviceId] = null;
    _sleepCountMap[deviceId] = LPDHelper.sleepDelay;

    bool wakeEnd = false;

    if (retryCount != null) {
      LPDHelper.wakeUpRetryCount = retryCount;
    } else {
      LPDHelper.wakeUpRetryCount = 0;
    }

    if (showLoading) {
      if (dismissOnTap) {
        KToast.show();
      } else {
        if (loadingTimeOut == null ||
            loadingTimeOut.inMilliseconds > /*容错：别乱传参数*/
                ((LPDHelper.wakeUpRetryCount + 1) *
                    LPDHelper.sleepDelay *
                    1000)) {
          KToast.show(); //点击不可消失loading，物理/侧滑 返回可以
        } else {
          Future.delayed(loadingTimeOut, () {
            if (wakeEnd == false) {
              KToast.show(); //点击不可消失loading，物理/侧滑 返回可以
            }
          });
        }
      }
    }

    Completer<bool> completer = Completer<bool>();
    completer.future.whenComplete(() => KToast.dismiss());
    await wakeUpIfNeed(deviceId, retryCount: retryCount ?? 0,
        callBack: (isSuccess, deviceId) async {
      if (isSuccess) {
        _updateDeviceState(deviceId, state: DeviceSleepState.wakeUp);

         LogUtils.idr.log('device wake success, deviceId=$deviceId');
      } else {
        //唤醒失败，重新获取休眠状态
        int state = await getIDRDeviceState(deviceId);

         LogUtils.idr.log(
            'device wake failed state=${DeviceSleepState.from(state)}, deviceId=$deviceId');
        _updateDeviceState(deviceId, state: DeviceSleepState.from(state));
      }
      wakeEnd = true;
      completer.complete(isSuccess);
    });
    return completer.future;
  }

  ///休眠设备
  ///调用时机. Controller 或页面 dispose回调中
  ///5S之后才休眠
  ///当 Flutter 应用切换到后台时，默认情况下 Dart 的 Timer 定时器会停止执行。这是由操作系统对后台应用的限制所导致的。
  ///前台运行：Timer 会按预期正常执行
  ///后台运行：
  /// Android/iOS 都会暂停或限制 Dart 代码的执行
  /// Timer 回调将不会触发
  /// 当应用回到前台时，Timer 会继续运行（但会丢失后台期间的触发次数）
  Future sleepDeviceIfNeed(String deviceId) async {
    if (!isLPDById(deviceId)) {
      /*防止非低功耗设备重复频繁创建计时器*/
       LogUtils.idr.log('sleep skipped!, not `IDR` device, deviceId=$deviceId');
      return;
    }

    Timer? timer = _sleepTimerMap[deviceId];
    if (timer != null) {
      timer.cancel();
       LogUtils.idr.log(
          'call #sleep, and cancel old sleep task, deviceId=$deviceId');
    }

    _sleepCountMap[deviceId] = 5;

    LogUtils.idr.log('device will be to sleep after 5s, deviceId=$deviceId');

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      int count = _sleepCountMap[deviceId]!;
      _sleepCountMap[deviceId] = --count;
       LogUtils.idr.log(
          'device will be to sleep after ${_sleepCountMap[deviceId]}s, deviceId=$deviceId');
      if (_sleepCountMap[deviceId] == 0) {
        timer.cancel();
        _sleepTimerMap[deviceId] = null;

        await sleepIfNeed(deviceId, sleepOnReady: (deviceId) {
          _updateDeviceState(deviceId, state: DeviceSleepState.sleeping);
        }, sleepOnSuccess: (deviceId) {
          _refreshStatue(deviceId);
        }, sleepOnFailed: (deviceId) async {
          _refreshStatue(deviceId);
        });
      }
    });

    _sleepTimerMap[deviceId] = timer;

    if (Platform.isIOS) {
      /*此处仅仅是注释*/
      // iOS 不允许精确的短间隔(如15秒)后台定时任务
      // iOS对后台任务有严格限制以防止电池滥用，过于频繁的后台唤醒会导致应用被系统终止或App Store审核被拒。
      // 如果后台执行Timer，实际执行时间由系统决定，不保证准时，所以针对iOS:
      // 统一对app进行后台保活【beginBackgroundTaskWithName方式】
    }
  }

  ///MQTT收到设备的休眠状态,更新休眠状态
  void refreshIDRStateByMQTT(String deviceId, String state) {
    DeviceSleepState? devState;
    if (state.toLowerCase() == "offline") {
    } else if (state == "WakeUp") {
      devState = DeviceSleepState.wakeUp;
    } else if (state == "LightSleep") {
      devState = DeviceSleepState.lightSleep;
    } else if (state == "DeepSleep") {
      devState = DeviceSleepState.deepSleep;
    } else if (state == "PreSleep") {
      devState = DeviceSleepState.preSleep;
    }
    if (devState != null) {
      LogUtils.idr.log('MQTT update device state, deviceId=$deviceId $devState');
      _updateDeviceState(deviceId, state: devState);
    }
  }

  ///重置所有休眠休眠定时器
  ///首页前后台切换时. 回到前台时调用
  void resetSleepTimers() {
    for (var deviceId in _sleepTimerMap.keys) {
      resetSleepTimer(deviceId);
    }
     LogUtils.idr.log('resetSleepTimers');
  }

  void resetSleepTimer(String deviceId) {
    Timer? timer = _sleepTimerMap[deviceId];
    timer?.cancel();
    _sleepTimerMap[deviceId] = null;
  }

  _refreshStatue(String deviceId) async {
    //5秒后重新获取休眠状态(兜底，同《超级看看》)
    Future.delayed(const Duration(seconds: 5), () async {
      await JFApi.xcAccount.xcGetDevState(deviceId: deviceId); //通知SDK刷新服务器
      getIDRDeviceState(deviceId); //更新设备休眠状态
    });

    //刷新首页设备的状态
    // eventBus.fire(BackResultEvent<String>(BackKeys.EV_REFRESH_DEV_STATUE,
    //     data: deviceId));
  }
}
