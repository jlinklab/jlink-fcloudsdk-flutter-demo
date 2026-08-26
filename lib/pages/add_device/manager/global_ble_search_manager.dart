import 'package:flutter/foundation.dart';
import 'package:fcloudsdk/ble_by_sdk/ble_search.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/add_device_permission_manager.dart';
import 'package:fcloudsdk_example/pages/add_device/models/scanned_device.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

class GlobalBleSearchManager {
  static final GlobalBleSearchManager instance = GlobalBleSearchManager();

  List<ScannedDevice> displayDeviceList = [];
  Map<String, int> allDeviceMap = {};

  final displayUpdateListener = _GlobalBleSearchListener();

  ///重试次数
  int retryCount = 0;

  ///重试次数上限
  int? retryCountMax;

  ///sdk无法区别手动stop还是超时，这里记一个主动操作的标记
  bool manualStop = false;

  init() {
    BleSearch.instance.addSearchStatusListener((isSearching) {
      if (!isSearching && !manualStop) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _retry();
        });
      }
      manualStop = false;
    });

    BleSearch.instance.addSearchResultListener((device) {});
  }

  unInit() {
    displayUpdateListener.clearListeners();
    stopScan();
  }

  checkPermission() async {
    ///新的权限类
    await AddDevicePermissionUsecase.instance.checkOnlyBlue(onlyStatus: false);
  }

  startScan({int? retryCountMax}) async {
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

    if (BleSearch.instance.isSearching) {
      return;
    }

    ///开始扫描
    await BleSearch.instance.start(timeout: 30);
  }

  stopScan() async {
    if (BleSearch.instance.isSearching) {
      manualStop = true;
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
