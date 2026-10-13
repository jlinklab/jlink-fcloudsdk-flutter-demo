import 'dart:async';

import 'package:fcloudsdk/ble_by_sdk/ble_device.dart';
import 'package:fcloudsdk/ble_by_sdk/ble_search.dart';
import 'package:fcloudsdk/door_lock/door_lock_ble_manager.dart';
import 'package:fcloudsdk/door_lock/door_lock_event.dart';
import 'package:fcloudsdk/utils/event_bus.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/common/event.dart';
import 'package:fcloudsdk_example/event/event.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/add_device_permission_manager.dart';
import 'package:fcloudsdk_example/pages/add_device/models/scanned_device.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/utils/debounce_throttle.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlobalBleSearchManager {
  static final GlobalBleSearchManager instance = GlobalBleSearchManager();

  List<ScannedDevice> displayDeviceList = [];
  Map<String, BleSearchDeviceBySDK> allDeviceMap = {};

  final displayUpdateListener = _GlobalBleSearchListener();

  ///重试次数
  int retryCount = 0;

  ///重试间隔，低频搜索时使用，默认15s
  int lowRetryInterval = 15;

  ///重试次数上限
  int? retryCountMax;

  ///sdk无法区别手动stop还是超时，这里记一个主动操作的标记
  bool manualStop = false;

  ///是否低频搜索中
  bool isLowFrequency = false;

  ///收到蓝牙消息
  late StreamSubscription<ReceiveBlueMessage> _receiverBlueMessageSub;

  ///蓝牙搜索到后计时45s，45s内一直搜不到则为离线，搜到后立刻取消计时，视为在线
  final Map<String, Timer> _deviceOfflineTimers = {};

  init() {
    BleSearch.instance.addSearchStatusListener((isSearching, errorCode) {
      if (!isSearching && !manualStop && errorCode == null) {
        var delay = isLowFrequency
            ? Duration(seconds: lowRetryInterval)
            : const Duration(milliseconds: 500);
        Future.delayed(delay, () {
          ///delay过程中如果手动调了stop，放弃重试
          if (!manualStop) {
            _retry();
          } else {
            manualStop = false;
          }
        });
      }

      if (!isSearching && (manualStop)) {
        ///手动停止搜索后离线倒计时全部取消，保持蓝牙在线状态
        _cancanAllTimer();
        manualStop = false;
      }
    });

    BleSearch.instance.addSearchResultListener((device) {
      ///修改设备蓝牙在线状态
      _changeDeviceBleState(device);
      allDeviceMap[device.uuid] = device;
    });

    _receiverBlueMessageSub = xEventBus.on<ReceiveBlueMessage>().listen((e) {
      _setBlueOnline(uuid: e.uuid, sn: e.activeSn, online: true);
      _resetTimer(uuid: e.uuid, sn: e.activeSn);
    });
  }

  unInit() {
    displayUpdateListener.clearListeners();
    stopScan();
    _receiverBlueMessageSub.cancel();
  }

  checkPermission() async {
    ///新的权限类
    await AddDevicePermissionUsecase.instance.checkOnlyBlue(onlyStatus: false);
  }

  startScan({int? retryCountMax, bool lowFrequency = false}) async {
    ///仅检查权限
    if (!AddDevicePermissionUsecase.instance.isCanBleSearch()) {
      KToast.show(status: '权限未开启');
      return;
    }

    //重试上限变化，重新开始计数
    if (this.retryCountMax != retryCountMax) {
      this.retryCountMax = retryCountMax;
      retryCount = 0;
    }

    //蓝牙搜索频率
    if (isLowFrequency != lowFrequency) {
      isLowFrequency = lowFrequency;
    }

    if (BleSearch.instance.isSearching) {
      return;
    }

    ///开始扫描
    await BleSearch.instance.start(timeout: 30);
  }

  stopScan() async {
    manualStop = true;
    if (BleSearch.instance.isSearching) {
      await BleSearch.instance.stop();
    }
  }

  _retry() async {
    ///重新搜索
    if (!BleSearch.instance.isSearching) {
      if (retryCountMax != null && retryCount == retryCountMax) {
        debugPrint("蓝牙搜索：重试已经达到上限$retryCountMax");
        return;
      }
      retryCount++;
      debugPrint("蓝牙搜索：开始重试，次数$retryCount");
      await BleSearch.instance.start(timeout: 30);
    }
  }

  // ignore: unused_element
  clearCache() {
    displayDeviceList.clear();
    allDeviceMap.clear();
  }

  ///防止短时间内频繁开关蓝牙
  startScanByDebounce({
    BuildContext? pageContext,
    int? retryCountMax,
    bool lowFrequency = false,
  }) {
    Future.delayed(const Duration(milliseconds: 300), () {
      ///页面已销毁则不再开启搜索
      if (pageContext != null && !pageContext.mounted) {
        return;
      }
      startScan(retryCountMax: retryCountMax, lowFrequency: lowFrequency);
    });
  }

  ///定位目前设备
  Device? _findDevice({required String uuid, required String sn}) {
    var target = DeviceManager.instance.allDevices
        .where((e) =>
            (uuid.isNotEmpty &&
                e.devMac?.toUpperCase() == uuid.toUpperCase()) ||
            (uuid.isNotEmpty &&
                e.peripheralIdentifier?.toUpperCase() == uuid.toUpperCase()) ||
            (sn.isNotEmpty && e.oldDeviceId == sn) ||
            (sn.isNotEmpty && e.uuid == sn))
        .toList()
        .firstOrNull;
    return target;
  }

  _setBlueOnline({required String uuid, required String sn, required online}) {
    var target = _findDevice(uuid: uuid, sn: sn);
    if (target == null) {
      return;
    }
    var old = target.blueOnline;
    target.blueOnline = online;
    target.blueUUid = uuid;

    if (sn.isNotEmpty) {
      DoorLockHelper.refreshDoorLockStatus(sn);
    }

    eventBus.fire(BlueOnlineEvent(
        uuid: uuid, deviceId: sn, online: online, isChanged: old != online));
  }

  ///重置倒计时
  _resetTimer({required String uuid, required String sn}) {
    var target = _findDevice(uuid: uuid, sn: sn);
    if (target == null) {
      return;
    }

    ///取消离线倒计时
    if (_deviceOfflineTimers[uuid] != null) {
      _deviceOfflineTimers[uuid]!.cancel();
      _deviceOfflineTimers.remove(uuid);
    }

    ///重新开始离线倒计时
    var timer = Timer.periodic(const Duration(seconds: 45), (timer) async {
      var blueObj = DoorLockBleManager.instance.hadOrNull(uuid);
      if (blueObj == null || (blueObj.isConnected == false)) {
        LogUtils.doorLock.log('45s timer end $sn set blue online false');
        _setBlueOnline(uuid: uuid, sn: sn, online: false);
      }
      _deviceOfflineTimers[uuid]!.cancel();
      _deviceOfflineTimers.remove(uuid);
    });

    _deviceOfflineTimers[uuid] = timer;
  }

  _cancanAllTimer() {
    for (var timer in _deviceOfflineTimers.values) {
      timer.cancel();
    }
    _deviceOfflineTimers.clear();
  }

  ///修改设备蓝牙在线状态
  _changeDeviceBleState(BleSearchDeviceBySDK device) {
    DebounceThrottle.throttle(() {
      if (ScannedDevice(bleDevice: device).isBlueActive() == false) {
        //未激活状态，不视为在线
        return;
      }

      var target = _findDevice(uuid: device.uuid, sn: device.sn);
      if (target == null) {
        return;
      }

      ///蓝牙搜索包
      target.searchResult = device;

      ///设为蓝牙在线
      _setBlueOnline(uuid: device.uuid, sn: device.sn, online: true);

      ///重置倒计时
      _resetTimer(uuid: device.uuid, sn: device.sn);
    }, const Duration(seconds: 3), key: '_changeDeviceBleState_${device.uuid}');
  }
}

class _GlobalBleSearchListener<T extends Function> {
  final ObserverList<T> _callbacks = ObserverList();

  void addListener(T callback) {
    _callbacks.add(callback);
  }

  void removeListener(T callback) {
    _callbacks.remove(callback);
  }

  void clearListeners() {
    _callbacks.clear();
  }

  void notifyListeners(List<dynamic>? positionalArguments) {
    final List<Function> localListeners = _callbacks.toList(growable: false);
    for (final Function listener in localListeners) {
      Function.apply(listener, positionalArguments);
    }
  }
}
