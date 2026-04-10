import 'package:flutter/foundation.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/local_device_cache.dart';
import 'package:xcloudsdk_flutter_example/models/user_instance.dart';
import 'package:xcloudsdk_flutter_example/pages/cloud/device_cloud_service_manager.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/model/model.dart';

class DevListViewModel extends ChangeNotifier {
  List<Device> mineDevs = [];

  List<Device> shareDevs = [];

  DevListViewModel() {
    AlarmMessageInitModel model = AlarmMessageInitModel(
        language: 'Chinese',
        user: UserInfo.instance.userName,
        pwd: UserInfo.instance.userPwd,

        /// 下面是安卓需要的参数
        tk: '',
        userid: '');
    JFApi.xcAlarmMessage.xcAlarmInit(model);

    onRefresh();

    AccountAPI.instance.deviceStateStream.listen((event) {
      (mineDevs + shareDevs)
          .firstWhere((element) => element.uuid == event.uuid)
          .state = event.state;
      notifyListeners();
    });
  }

  Future<void> onRefresh() async {
    if (UserInfo.instance.isLogin == false) {
      return;
    }
    // final devicesJson = await JFApi.xcAccount.xcLoginAndGetDeviceList(
    //     UserInfo.instance.userName, UserInfo.instance.userPwd);
    final devicesJson = await JFApi.xcAccount.xcQueryDeviceList();
    final devices = Devices.fromJson(devicesJson);
    mineDevs = devices.mine;
    shareDevs = devices.share;

    ///根据userName查询本地设备状态缓存，先展示，后面一个个设备再请求状态更新
    Map deviceMap = await LocalDeviceCache.fetchDevicesDataMap(
        userId: UserInfo.instance.userId);
    for (Device device in mineDevs) {
      if (deviceMap.containsKey(device.uuid)) {
        Device pDevice = deviceMap[device.uuid];
        device.state = pDevice.state;
      }
    }
    for (Device device in shareDevs) {
      if (deviceMap.containsKey(device.uuid)) {
        Device pDevice = deviceMap[device.uuid];
        device.state = pDevice.state;
      }
    }

    getDevState();
    getCloudState();
    notifyListeners();
  }

  getCloudState() {
    DeviceCloudServiceManager.instance
        .refreshCloudServicesStatus(devices: mineDevs + shareDevs);
  }

  void getDevState() async {
    AccountAPI.instance.xcGetDevicesState(
        uuids: (mineDevs + shareDevs).map((e) => e.uuid).toList());

    ///更新用户的设备数据
    List<Device> tempList = [];
    tempList.addAll(mineDevs);
    tempList.addAll(shareDevs);
    LocalDeviceCache.saveDevicesState(
        userId: UserInfo.instance.userId, deviceList: tempList);
  }

  void deleteDev(String devId, int type) {
    if (type == 0) {
      mineDevs.removeWhere((element) => element.uuid == devId);
    } else if (type == 1) {
      shareDevs.removeWhere((element) => element.uuid == devId);
    }
    notifyListeners();
  }
}
