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

  ///是否正在扫描
  bool isScanning() {
    return isBleSearching;
  }

  MainBleScanController({
    required this.context,
  }) {
    checkPermission();
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

    isCheckingRelatedPermissionStatus = false;

    startScanIfNeed();
  }

  ///开始扫描
  startScanIfNeed() {
    var needResetTimer = false;

    ///判断是否可以蓝牙搜索
    if (AddDevicePermissionUsecase.instance.isCanBleSearch() &&
        isBleSearching == false) {
      _openBleSearch();
      needResetTimer = true;
    }
  }

  stopScan() {
    ///停止蓝牙搜索
    if (isBleSearching) {
      GlobalBleSearchManager.instance.stopScan();
    }

    _updateView();
  }

  _openBleSearch() async {
    ///监听蓝牙是否在扫描
    BleSearch.instance.addSearchStatusListener((isSearching) {
      _updateView();
    });

    ///扫描到的设备结果
    BleSearch.instance.addSearchResultListener((device) {
      _handSearchBleDevices(device);
    });

    //开始蓝牙搜索
    GlobalBleSearchManager.instance.startScan(retryCountMax: 0);
  }

  ///处理搜到的蓝牙设备
  _handSearchBleDevices(BleSearchDeviceBySDK bleDevice) {
    var newDevice = ScannedDevice(bleDevice: bleDevice);

    var index = scannedBleDeviceList.indexWhere((e) => e.id == newDevice.id);
    if (index != -1) {
      //已存在，不处理
    } else {
      scannedBleDeviceList.add(newDevice); //新增
    }
    _updateView();

    ///获取设备数据
    Future.delayed(const Duration(milliseconds: 500), () {
      for (ScannedDevice device in scannedBleDeviceList) {
        device.queryDeviceDetailTypeInfoIfNeed();
      }
    });
    _updateView();
  }

  _updateView() {
    if (hasListeners) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopScan();
    super.dispose();
  }
}
