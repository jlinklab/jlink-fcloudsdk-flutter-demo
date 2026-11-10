import 'package:flutter/material.dart';
import 'package:fcloudsdk/ble_by_sdk/ble_device.dart';
import 'package:fcloudsdk/ble_by_sdk/ble_search.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/add_device_permission_manager.dart';
import 'package:fcloudsdk_example/pages/add_device/manager/global_ble_search_manager.dart';
import 'package:fcloudsdk_example/pages/add_device/models/scanned_device.dart';

class MainBleScanController extends ChangeNotifier {
  final BuildContext context;

  ///蓝牙搜索到的设备
  List<ScannedDevice> scannedBleDeviceList = [];

  bool get isBleSearching => BleSearch.instance.isSearching; //蓝牙是否正在搜索

  ///是否正在检查相关权限
  bool isCheckingRelatedPermissionStatus = true;

  void Function(bool isSearching, int? errorCode)? _searchStatusListener;
  void Function(BleSearchDeviceBySDK device)? _searchResultListener;
  bool _isDisposed = false;

  ///是否正在扫描
  bool isScanning() {
    return isBleSearching;
  }

  MainBleScanController({
    required this.context,
  }) {
    start();
  }

  checkPermission() async {
    ///新的权限类
    await AddDevicePermissionUsecase.instance.checkOnlyBlue(onlyStatus: false);
  }

  ///申请权限 + 开始扫描
  start() async {
    isCheckingRelatedPermissionStatus = true;

    ///先检查添加相关的权限
    await checkPermission();
    if (_isDisposed) {
      return;
    }

    isCheckingRelatedPermissionStatus = false;

    startScanIfNeed();
  }

  ///开始扫描
  startScanIfNeed() {
    if (_isDisposed) {
      return;
    }

    ///判断是否可以蓝牙搜索
    if (AddDevicePermissionUsecase.instance.isCanBleSearch()) {
      _openBleSearch();
    }
  }

  stopScan() {
    ///停止蓝牙搜索
    if (isBleSearching) {
      GlobalBleSearchManager.instance.stopScan();
    }

    _updateView();
  }

  _openBleSearch() {
    if (_isDisposed) {
      return;
    }

    ///监听蓝牙是否在扫描
    if (_searchStatusListener == null) {
      _searchStatusListener = (isSearching, errorCode) {
        _updateView();
      };
      BleSearch.instance.addSearchStatusListener(_searchStatusListener!);
    }

    ///扫描到的设备结果
    if (_searchResultListener == null) {
      _searchResultListener = (device) {
        _handSearchBleDevices(device);
      };
      BleSearch.instance.addSearchResultListener(_searchResultListener!);
    }

    //开始蓝牙搜索
    GlobalBleSearchManager.instance.startScan(retryCountMax: 0);
  }

  ///处理搜到的蓝牙设备
  _handSearchBleDevices(BleSearchDeviceBySDK bleDevice) async {
    if (_isDisposed) {
      return;
    }
    var newDevice = ScannedDevice(bleDevice: bleDevice);

    if (await newDevice.needShowBlue()) {
      if (_isDisposed) {
        return;
      }
      var index = scannedBleDeviceList.indexWhere((e) => e.id == newDevice.id);
      if (index != -1) {
        //已存在，不处理
      } else {
        scannedBleDeviceList.add(newDevice); //新增
      }
    }
    _updateView();

    ///获取设备数据
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isDisposed) {
        return;
      }
      for (ScannedDevice device in scannedBleDeviceList) {
        device.queryDeviceDetailTypeInfoIfNeed().then((_) {
          ///数据回来后刷新 UI，否则列表不会显示设备名称和图片
          _updateView();
        });
      }
    });
  }

  _updateView() {
    if (!_isDisposed && hasListeners) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    final statusListener = _searchStatusListener;
    if (statusListener != null) {
      BleSearch.instance.removeSearchStatusListener(statusListener);
      _searchStatusListener = null;
    }
    final resultListener = _searchResultListener;
    if (resultListener != null) {
      BleSearch.instance.removeSearchResultListener(resultListener);
      _searchResultListener = null;
    }
    stopScan();
    super.dispose();
  }
}
