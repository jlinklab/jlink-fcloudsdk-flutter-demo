import 'package:fcloudsdk/ble_by_sdk/ble_device.dart';
import 'package:fcloudsdk_example/api/add_device_api.dart';
import 'package:fcloudsdk_example/api/core/dio_config.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/manager/user_group_manager.dart';

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

  ///检查过存在的error, 接口报错才有
  BusinessError? checkExistenceError;

  ///是否支持蓝牙配对（门锁）
  ///version: 4用于XM650的海外视频锁，蓝牙配对；5用于通用门锁设备（除了XM650海外视频锁），蓝牙配对功能（比如BK门锁）
  bool supportBlePair() {
    if (bleDevice != null) {
      if (bleDevice!.version == 4 || bleDevice!.version == 5) {
        return true;
      }
    }
    return false;
  }

  ///检查蓝牙设备是否是激活状态
  ///extra: 0初始值 1蓝牙未配对 2已激活 3蓝牙二次配对 4已激活需假配网并需锁板网络重置 5已激活需假配网无需锁板网络重置
  bool isBlueActive() {
    if (bleDevice != null) {
      var status = bleDevice!.extra;
      if (status == 2 || status == 4 || status == 5) {
        return true;
      }
      if (supportBlePair() && status == 0) {
        return true;
      }
    }
    return false;
  }

  ///是否展示搜到的蓝牙设备
  Future<bool> needShowBlue() async {
    var show = false;
    if (bleDevice != null) {
      show = true;
      if (supportBlePair() && isBlueActive()) {
        show = false;

        ///国内锁重置后状态可能还是已激活，这里做特殊处理，服务器上没有就可以添加
        if (bleDevice!.version == 5 &&
            (bleDevice!.extra == 4 || bleDevice!.extra == 5)) {
          await checkDeviceExistenceIfNeed();
          show = isCanAdd;
        }
      }
    }
    return show;
  }

  ///检查设备是否存在服务器
  Future checkDeviceExistenceIfNeed() async {
    if (hadCheckExistence) {
      return;
    }

    if (sn.isEmpty) {
      return;
    }

    try {
      await addDeviceAPI.queryDeviceExistence(
        userGroupId: UserGroupManager.instance.currentGroupId,
        deviceNo: sn,
        areaCheck: true,
      );
      isCanAdd = true;
    } catch (error) {
      if (error.runtimeType == BusinessError) {
        checkExistenceError = error as BusinessError;
        String code = checkExistenceError!.code.toString();

        ///打印服务器返回的原始数据，排查数据中是否携带被哪个家庭/账号绑定的信息

        if (code == '-91005') {
          //超出账号添加数量
          isCanAdd = false;
        }
        if (code == '-91012') {
          //已在当前用户组
          isCanAdd = false;
        }
        if (code == '-91013') {
          //已在[***]下，msg 为服务端下发的家庭组名称，用于"已在[xxx]下"展示
          isCanAdd = false;
        }
      }
    } finally {
      hadCheckExistence = true;
    }
    return;
  }
}
