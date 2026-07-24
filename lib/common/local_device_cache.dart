import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/model/model.dart';

///缓存设备状态数据
class LocalDeviceCache {
  ///保存设备列表数据
  static Future<void> saveDevicesState(
      {required String userId, required List<Device> deviceList}) async {
    if (deviceList.isEmpty) {
      return;
    }
    String jsonString = jsonEncode(deviceList);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userId, jsonString);
    return Future.value();
  }

  ///查询设备列表数据 返回设备数组
  static Future<List<Device>> fetchDevicesData({required String userId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(userId)) {
      return []; // if no data saved, return empty list
    }

    final jsonString = prefs.getString(userId) ?? "";

    try {
      final parsedJson = jsonDecode(jsonString);
      List<dynamic> jsonList = parsedJson;

      // Convert each item in the JSON list to a Follow object and return the list.
      List<Device> deviceList =
          jsonList.map((item) => Device.fromJson(item)).toList();
      return deviceList;
    } catch (e) {
      return []; // catching exception upon failing to parse json
    }
  }

  ///查询设备列表数据 返回设备数组
  static Future<Map<String, Device>> fetchDevicesDataMap(
      {required String userId}) async {
    List<Device> deviceList =
        await LocalDeviceCache.fetchDevicesData(userId: userId);
    Map<String, Device> ans = {};
    for (Device device in deviceList) {
      ans[device.uuid] = device;
    }
    return ans;
  }
}
