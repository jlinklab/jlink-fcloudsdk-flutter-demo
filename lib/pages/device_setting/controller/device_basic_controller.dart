import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/device_ability/device_ability_manager.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

class DeviceBasicController extends ChangeNotifier {
  final BuildContext context;
  final String deviceId;
  int channel = 0;

  List<ListTile> dataSource = [];

  DeviceBasicController({
    required this.context,
    required this.deviceId,
  }) {
    _init();
  }

  void _init() {
    _queryData();
    _configDeviceSetItemMoleList();
  }

  _configDeviceSetItemMoleList() {
    dataSource.clear();

    dataSource.add(ListTile(
      title: Text(TR.current.imageFlipLeftRight),
      trailing: CupertinoSwitch(
          value: isFlipImageLeftRight,
          onChanged: (value) {
            isFlipImageLeftRight = value;
            Map<String, dynamic> requestMap = Map.from(mapCameraParam);
            requestMap['PictureMirror'] = !isFlipImageLeftRight ? '0x0' : '0x1';
            _setCameraInfo(requestMap);
          }),
    ));

    dataSource.add(ListTile(
      title: Text(TR.current.imageFlipUpDown),
      trailing: CupertinoSwitch(
          value: isFlipImageTopBottom,
          onChanged: (value) {
            isFlipImageTopBottom = value;
            Map<String, dynamic> requestMap = Map.from(mapCameraParam);
            requestMap['PictureFlip'] = !isFlipImageTopBottom ? '0x0' : '0x1';
            _setCameraInfo(requestMap);
          }),
    ));

    notifyListeners();
  }

  ///请求页面数据
  void _queryData() async {
    // KToast.show();
    await _queryCameraInfo();
    _configDeviceSetItemMoleList();
  }

  ///图片翻转 日夜切换灵敏度  相关属性和方法 ###########################
  //是否支持隐藏图片翻转默认
  bool bSupportHidePictureFlip = false;
  bool bSupportHidePictureMirror = false;

  //是否支持隐藏图片翻转
  bool bSupportPictureFlipMirror = false;

  //图片是否翻转
  bool isFlipImageLeftRight = false;
  bool isFlipImageTopBottom = false;

  bool bDayNightSensibility = false;
  double dayNightSensibilityValue = 0;

  //Camera.Param
  Map<String, dynamic> mapCameraParam = {};

  //查询图片翻转信息
  Future _queryCameraInfo({bool bShowLoading = false}) async {
    bSupportHidePictureFlip = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportHidePictureFlip);
    bSupportHidePictureMirror = await DeviceAbilityManager.queryAbility(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionSupportHidePictureMirror);
    if (bSupportHidePictureFlip && bSupportHidePictureMirror) {
      return;
    }

    if (bShowLoading) {
      KToast.show();
    }
    try {
      const command = 'Camera.Param';
      final resultMap = await JFApi.xcDevice.xcDevGetChnConfig(
          deviceId: deviceId,
          channelNo: channel,
          commandName: command,
          command: 1042,
          timeout: 15000);
      if (bShowLoading) {
        KToast.dismiss();
      }
      if (resultMap['Ret'] != null && resultMap['Ret'] == 100) {
        bSupportPictureFlipMirror = true;
        mapCameraParam = resultMap['$command.[$channel]'];
        isFlipImageLeftRight = mapCameraParam['PictureMirror'] == '0x1';
        isFlipImageTopBottom = mapCameraParam['PictureFlip'] == '0x1';
        if (bShowLoading) {
          _configDeviceSetItemMoleList();
        }
      }
    } catch (result) {
      result as XCloudAPIException;
      if (result.code == -400009 || result.code == -11406) {
        bSupportPictureFlipMirror = false;
        bDayNightSensibility = false;
        if (bShowLoading) {
          _configDeviceSetItemMoleList();
        }
      } else {
        KToast.show(status: kErrorMsg(result.code));
        if (bShowLoading == false && context.mounted) {
          context.pop();
        }
      }
    }
    return Future.value();
  }

  _setCameraInfo(Map<String, dynamic> requestMap) {
    String jsonStr = jsonEncode(requestMap);
    KToast.show();
    JFApi.xcDevice
        .xcDevSetChnConfig(
            deviceId: deviceId,
            channelNo: channel,
            commandName: 'Camera.Param',
            config: jsonStr,
            configLen: jsonStr.length + 1,
            command: 1040,
            timeout: 15000)
        .then((resultMap) {
      KToast.dismiss();
      _queryCameraInfo(bShowLoading: true);
    }).catchError((e) {
      KToast.show(status: kErrorMsg(e));
    });
  }
}
