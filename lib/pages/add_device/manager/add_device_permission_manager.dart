import 'dart:io';

import 'package:xcloudsdk_flutter_example/utils/permission_utils.dart';

///检查添加设备所需权限开关状态
class AddDevicePermissionUsecase {
  static final AddDevicePermissionUsecase instance =
      AddDevicePermissionUsecase();

  bool isPermissionBleSwitch = false; //蓝牙开关
  bool isPermissionBleService = false; //蓝牙服务
  bool isPermissionLocation = false; //定位权限
  // bool isPermissionLocationService = false; //定位开关
  bool isPermissionWifiService = false; //wifi开关
  bool isPermissionLocalNet = false; //本地网络权限

  checkOnlyBlue({bool onlyStatus = false}) async {
    isPermissionBleSwitch = await PermissionUtils.checkPermission(
        permission: XPermission.blueSwitch, onlyStatus: onlyStatus);
    isPermissionBleService = await PermissionUtils.checkPermission(
        permission: XPermission.blueService, onlyStatus: onlyStatus);
    isPermissionLocalNet = await PermissionUtils.checkPermission(
        permission: XPermission.localNet, onlyStatus: onlyStatus);
    if (Platform.isAndroid || Platform.operatingSystem == 'ohos') {
      isPermissionLocation = await PermissionUtils.checkPermission(
          permission: XPermission.location, onlyStatus: onlyStatus);
    }
  }

  ///是否可以进行蓝牙搜素
  bool isCanBleSearch() {
    var enable =
        isPermissionBleSwitch && isPermissionBleService && isPermissionLocalNet;
    if (Platform.isIOS) {
      return enable;
    }
    return isPermissionLocation && enable;
  }

  checkOnlyWifi({bool onlyStatus = false}) async {
    isPermissionLocation = await PermissionUtils.checkPermission(
        permission: XPermission.location, onlyStatus: onlyStatus);
    isPermissionWifiService = await PermissionUtils.checkPermission(
        permission: XPermission.wifiSwitch, onlyStatus: onlyStatus);
    isPermissionLocalNet = await PermissionUtils.checkPermission(
        permission: XPermission.localNet, onlyStatus: onlyStatus);
  }
}
