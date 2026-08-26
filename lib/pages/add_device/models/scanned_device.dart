import 'package:fcloudsdk/ble_by_sdk/ble_device.dart';
import 'package:fcloudsdk_example/api/add_device_api.dart';
import 'package:fcloudsdk_example/api/core/dio_config.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';

///蓝牙扫描到的设备，需要显示到发现以下设备组件中
class ScannedDevice {
  ///蓝牙扫描到的设备
  BleSearchDeviceBySDK? bleDevice;

  ScannedDevice({this.bleDevice});

  String get id {
    if (bleDevice != null) {
      return bleDevice!.uuid; //蓝牙mac
    }
    return '';
  }

  String get sn {
    if (bleDevice != null) {
      return bleDevice!.sn;
    }
    return '';
  }

  String get pid {
    String pid = '';
    if (bleDevice != null) {
      pid = bleDevice!.pid.isNotEmpty ? bleDevice!.pid : '0';
    }
    return pid;
  }

  String _devicePicUrl = '';
  String onGetDevicePic() {
    return _devicePicUrl;
  }

  String _deviceName = '';
  String onGetDeviceName() {
    return _deviceName;
  }

  ///找到设备页面展示的设备名称
  String displayName = '';
  updateDeviceShowName(String name) {
    displayName = name;
  }

  ///不支持获取设备类型, 防止一直获取
  bool _unSupportQueryType = false;

  ///查询设备类型详情
  DeviceDetailTypeModel? deviceDetailTypeModel;
  Future<bool> queryDeviceDetailTypeInfoIfNeed() async {
    if (_unSupportQueryType) {
      return true;
    }
    if (deviceDetailTypeModel != null &&
        _deviceName.isNotEmpty &&
        _devicePicUrl.isNotEmpty) {
      return true;
    }

    try {
      deviceDetailTypeModel =
          await addDeviceAPI.queryDeviceTypeDetailInfo(pid: pid);
    } catch (e) {
      if (e is BusinessError) {
        if (e.code == -91007) {
          _unSupportQueryType = true;
          if (_deviceName.isEmpty) {
            _deviceName = TR.current.sceneAddDevice;
          }
        }
      }
    }
    if (deviceDetailTypeModel != null) {
      _deviceName =
          deviceDetailTypeModel!.deviceTypeName ?? TR.current.sceneAddDevice;
      _devicePicUrl = deviceDetailTypeModel!.devicePic ?? '';
    }
    return true;
  }

  ///是否可以添加
  bool isCanAdd = true;

  ///设备持有账号
  String oldDeviceAccount = '';

  ///是否检查过存在
  bool hadCheckExistence = false;

  ///检查蓝牙设备是否是激活状态
  bool isBlueActive() {
    if (bleDevice != null) {
      var version = bleDevice!.extra;
      if (version == 2 || version == 4 || version == 5) {
        return true;
      }
    }
    return false;
  }
}
