// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/ble/ble_api.dart';
import 'package:xcloudsdk_flutter_example/utils/app_config.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

///权限工具类
/// isDenied 拒绝
/// isGranted 允许
/// isRestricted 家长控制
///
/// isPermanentlyDenied 拒绝并不再提示,需要先调到 request 才能获得此结果
/// isLimited 存在限制
class PermissionUtils {
  static PermissionUtils get instance => PermissionUtils._();

  PermissionUtils._();

  ///检查是否拥有权限[XPermission]
  ///[onlyStatus] 只检查是否授权或可以使用,不会申请权限
  static Future<bool> checkPermission({
    required XPermission permission,
    bool onlyStatus = false,
  }) async {
    PermissionHandler? handler;
    switch (permission) {
      case XPermission.blueSwitch:
        handler = BlueSwitchPermissionHandler();
        break;
      case XPermission.blueService:
        handler = BlueServicePermissionHandler();
        break;
      case XPermission.location:
        handler = LocationPermissionHandler();
        break;
      case XPermission.locationService:
        handler = LocationServicePermissionHandler();
        break;
      case XPermission.camera:
        handler = CameraPermissionHandler();
        break;
      case XPermission.localNet:
        handler = LocalNetPermissionHandler();
        break;
      case XPermission.microphone:
        handler = MicrophonePermissionHandler();
        break;
      default:
        break;
    }
    if (handler != null) {
      bool isGranted = await handler.checkPermission(onlyStatus: onlyStatus);
      handler.dispose();
      return isGranted;
    }
    return false;
  }
}

enum XPermission {
  ///蓝牙开关
  blueSwitch,

  ///蓝牙服务权限(扫描&连接)
  blueService,

  ///位置权限
  location,

  ///位置精细信息权限
  locationService,

  ///相机
  camera,

  ///存储(photo)
  storage,

  ///麦克风权限
  microphone,

  ///通知权限
  notification,

  ///本地网络
  localNet,

  ///wifi开关
  wifiSwitch,
}

abstract class PermissionHandler with WidgetsBindingObserver {
  ///所需权限
  Future<Permission> get permission;

  Completer<bool> checker = Completer();

  bool _hasOpenSettings = false;

  PermissionHandler() {
    WidgetsBinding.instance.addObserver(this);
  }

  ///检查权限
  Future<bool> checkPermission({bool onlyStatus = false}) async {
    PermissionStatus status = await (await permission).status;
    if (onlyStatus) {
      return status == PermissionStatus.granted;
    }
    if (status == PermissionStatus.granted) {
      return true;
    }

    /// 不允许，需要去请求
    return requestPermissionWithPreDialog();
  }

  ///请求权限前弹窗
  Future<bool> requestPermissionWithPreDialog() async {
    return requestPermission();
  }

  ///请求权限
  Future<bool> requestPermission() async {
    /// 请求系统授权
    PermissionStatus status = await (await permission).request();

    if (status == PermissionStatus.granted) {
      return true;
    }

    return requestPermissionWithAfterDialog();
  }

  /// 请求权限不允许，弹出提示
  bool requestPermissionWithAfterDialog() {
    KToast.show(status: '没权限');
    return false;
  }

  //打开系统的权限设置页面
  Future<bool> openSetting() {
    openAppSettings();
    _hasOpenSettings = true;
    return checker.future;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasOpenSettings) {
      _recheckFromSettings();
    }
  }

  void _recheckFromSettings() async {
    PermissionStatus status = await (await permission).status;
    if (status == PermissionStatus.denied) {
      //弹出没有权限提示
      KToast.show(status: '没权限');
      checker.complete(false);
      return;
    }
    if (status == PermissionStatus.granted) {
      checker.complete(true);
    } else {
      checker.complete(false);
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}

///蓝牙系统开关
class BlueSwitchPermissionHandler extends PermissionHandler {
  @override
  Future<Permission> get permission => Future.value(Permission.unknown);

  @override
  Future<bool> checkPermission({bool onlyStatus = false}) async {
    bool serviceEnabled = false;

    if (Platform.isIOS) {
      serviceEnabled = await JFApi.xcNet.xcBlueToothIsEnable();
    } else {
      serviceEnabled = await BleAPI.instance.isEnable();

      if (onlyStatus == true) {
        return serviceEnabled;
      }

      if (serviceEnabled == false) {
        KToast.show(status: '没权限');
      }
    }
    return serviceEnabled;
  }

  @override
  void _recheckFromSettings() async {
    bool serviceEnabled = false;
    if (Platform.isIOS) {
      serviceEnabled = await JFApi.xcNet.xcBlueToothIsEnable();
    } else {
      serviceEnabled = await BleAPI.instance.isEnable();
    }

    if (serviceEnabled) {
      checker.complete(true);
    } else {
      checker.complete(false);
    }
  }
}

///蓝牙应用权限(扫描&连接)
class BlueServicePermissionHandler extends PermissionHandler {
  BlueServicePermissionHandler() : super();
  @override
  Future<Permission> get permission async {
    if (Platform.isIOS) {
      return Permission.bluetooth;
    } else if (isOhos) {
      return Permission.bluetoothConnect;
    }
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    int sdkInt = androidInfo.version.sdkInt;
    if (sdkInt >= 31) {
      return Permission.bluetoothScan;
    }
    return Permission.location;
  }

  @override
  Future<bool> checkPermission({bool onlyStatus = false}) async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      int sdkInt = androidInfo.version.sdkInt;

      /// android 小于 31只需要请求Permission.location，会有单独的location权限请求，这里直接返回true
      if (sdkInt < 31) {
        return true;
      }
      PermissionStatus? statusBluetoothScan =
          await Permission.bluetoothScan.status;

      PermissionStatus? statusBluetoothConnect =
          await Permission.bluetoothConnect.status;

      bool isSupportBlueService =
          statusBluetoothConnect.isGranted && statusBluetoothScan.isGranted;
      if (onlyStatus) {
        return isSupportBlueService;
      } else if (!onlyStatus) {
        if (isSupportBlueService) {
          return true;
        }
        requestBlueServicePermission();
      }
      return false;
    }
    return super.checkPermission(onlyStatus: onlyStatus);
  }

  Future<bool> requestBlueServicePermission() async {
    List<Permission> permissions = [];

    permissions.add(Permission.bluetoothScan);
    permissions.add(Permission.bluetoothConnect);

    Map<Permission, PermissionStatus> result = await permissions.request();

    bool isGranted = true;

    PermissionStatus? bleScan = result[Permission.bluetoothScan];
    if (bleScan != null && bleScan.isGranted) {
    } else {
      isGranted = false;
    }

    PermissionStatus? bleConnect = result[Permission.bluetoothScan];
    if (bleConnect != null && bleConnect.isGranted) {
    } else {
      isGranted = false;
    }

    return Future(() => isGranted);
  }
}

///摄像机权限
class CameraPermissionHandler extends PermissionHandler {
  @override
  Future<Permission> get permission => Future.value(Permission.camera);
}

///定位服务开关, 并不属于权限申请, 但是业务上的提示基本一致
class LocationServicePermissionHandler extends PermissionHandler {
  @override
  Future<Permission> get permission => Future.value(Permission.unknown);

  @override
  Future<bool> checkPermission({bool onlyStatus = false}) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (onlyStatus) {
      return serviceEnabled;
    }
    if (serviceEnabled) {
      return true;
    }

    return requestPermissionWithAfterDialog();
  }

  @override
  Future<bool> openSetting() {
    Geolocator.openAppSettings();
    _hasOpenSettings = true;
    return checker.future;
  }

  @override
  void _recheckFromSettings() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      checker.complete(true);
    } else {
      checker.complete(false);
    }
  }
}

///位置权限
class LocationPermissionHandler extends PermissionHandler {
  @override
  Future<Permission> get permission => Future.value(Permission.location);
}

///localNet 本地网络
class LocalNetPermissionHandler extends PermissionHandler {
  @override
  Future<Permission> get permission => Future.value(Permission.unknown);

  @override
  Future<bool> checkPermission({bool onlyStatus = false}) async {
    bool isPermissionLocalNet = false;
    if (Platform.isAndroid || Platform.operatingSystem == 'ohos') {
      isPermissionLocalNet = true;
    } else {
      isPermissionLocalNet = await JFApi.xcUtil.xcCheckPermissionLocationNet();
    }

    if (onlyStatus) {
      return isPermissionLocalNet;
    }
    if (isPermissionLocalNet == true) {
      return true;
    }

    return requestPermissionWithAfterDialog();
  }

  @override
  void _recheckFromSettings() async {
    if (Platform.isAndroid || Platform.operatingSystem == 'ohos') {
      checker.complete(true);
    } else {
      var isPermissionLocalNet =
          await JFApi.xcUtil.xcCheckPermissionLocationNet();
      if (isPermissionLocalNet) {
        checker.complete(true);
      } else {
        checker.complete(false);
      }
    }
  }
}

///麦克风权限
class MicrophonePermissionHandler extends PermissionHandler {
  @override
  Future<Permission> get permission => Future.value(Permission.microphone);
}

///wifi开关
class WifiSwitchPermissionHandler extends PermissionHandler {
  @override
  Future<Permission> get permission => Future.value(Permission.unknown);

  @override
  Future<bool> checkPermission({bool onlyStatus = false}) async {
    //检查wifi是否打开
    bool serviceEnabled = await Future.value(false);

    if (Platform.isAndroid) {
      final connectivityResult = await Connectivity().checkConnectivity();
      serviceEnabled = connectivityResult == ConnectivityResult.wifi;
      if (onlyStatus) {
        return serviceEnabled;
      }
      if (serviceEnabled == true) {
        return true;
      }
      return requestPermissionWithPreDialog();
    } else if (Platform.operatingSystem == 'ohos') {
      serviceEnabled = await JFApi.xcNet.xcWifiEnabled();
    } else {
      final wifiName = await NetAPI.instance.xcWifiGetSSID();
      serviceEnabled = wifiName.isNotEmpty;
    }

    return serviceEnabled;
  }

  @override
  Future<bool> requestPermission() async {
    return openSetting();
  }

  @override
  Future<bool> openSetting() {
    if (Platform.operatingSystem == 'ohos') {
      JFApi.xcNet.xcOpenWifi();
    } else {
      AppSettings.openAppSettings(type: AppSettingsType.wifi);
    }

    _hasOpenSettings = true;
    return checker.future;
  }

  @override
  void _recheckFromSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    bool isEnable =
        await Connectivity().checkConnectivity() == ConnectivityResult.wifi;
    checker.complete(isEnable);
  }
}
