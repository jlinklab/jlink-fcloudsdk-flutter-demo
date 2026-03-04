import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/generated/l10n.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/views/common_item_list.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

class DeviceRecordSetController extends ChangeNotifier {
  final BuildContext context;
  final String deviceId;
  int channel = 0;

  Map? storageDataMap = {};

  List<ListTile> dataSource = [];

  DeviceRecordSetController({
    required this.context,
    required this.deviceId,
  }) {
    _init();
  }

  void _init() {
    _queryData();
    configDeviceSetItemMoleList();
  }

  configDeviceSetItemMoleList() {
    dataSource.clear();

    dataSource.add(ListTile(
      title: Text(TR.current.recordMode),
      trailing: CupertinoSwitch(
          value: bRecordSwitch,
          onChanged: (value) {
            bRecordSwitch = value;
            onSetRecordConfig(bShowLoading: true);
          }),
    ));

    ///没有打开就不再显示后续的配置
    if (bRecordSwitch == false) {
      notifyListeners();
      return;
    }

    dataSource.add(ListTile(
      title: Text(TR.current.recordClip),
    ));
    dataSource.add(ListTile(
      title: Text(TR.current.recordAudio),
      trailing: CupertinoSwitch(
          value: bMainAudio,
          onChanged: (value) {
            bMainAudio = value;
            onSetEncodeConfig(bShowLoading: true);
          }),
    ));
    dataSource.add(ListTile(
      title: Text(TR.current.recordQuality),
      trailing: Text(qualityList[curMainQualityIndex]['title']),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return CommonItemListWidget(
              dataList: qualityList.map((e) => e['title'].toString()).toList(),
              callBack: (index) {
                curMainQualityIndex = index;
                onSetEncodeConfig(bShowLoading: true);
              });
        }));
      },
    ));

    notifyListeners();
  }

  ///请求页面数据
  void _queryData() async {
    // KToast.show();
    await _queryStorageInfo();
    await _queryRecordConfig();
    await _queryEncodeConfig();
    configDeviceSetItemMoleList();
    KToast.dismiss();
  }

  _queryStorageInfo() async {
    try {
      storageDataMap = await JFApi.xcDevice.xcDevGetSysConfig(
          deviceId: deviceId,
          commandName: 'StorageInfo',
          command: 1020,
          timeout: 8000);
      handleStorageData();
    } catch (e) {
      KToast.show(status: KErrorMsg(e));
    }
  }

  bool bExistSD = true;

  handleStorageData() {
    int sdkMaxDiskPerMachine = 8; //最多支持8块硬盘

    int totalStorage = 0; // 总容量
    int videoTotalStorage = 0; // 录像总容量
    int imgTotalStorage = 0; // 图像总容量
    List storageInfoList = storageDataMap?['StorageInfo'];
    for (Map subMap in storageInfoList) {
      List partitionList = subMap['Partition'];
      for (int i = 0;
          i < partitionList.length && i < sdkMaxDiskPerMachine;
          i++) {
        Map ssMap = partitionList[i];

        ///判断SD卡状态是否异常
        if (ssMap['Status'] == null || ssMap['Status'] != 0) {
          bExistSD = false;
          break;
        }

        ///录像分区计算
        if (ssMap['DirverType'] == 0) {
          final a = ssMap['TotalSpace'];
          print(a.runtimeType);

          videoTotalStorage += int.parse(ssMap['TotalSpace']);
        }

        ///图片分区计算
        if (ssMap['DirverType'] == 4) {
          imgTotalStorage += int.parse(ssMap['TotalSpace']);
        }
      }
    }

    totalStorage = videoTotalStorage + imgTotalStorage;
    bExistSD = totalStorage > 0;
  }

  ///录像配置 ##############
  Map? mapRecordConfig;

  //录像开关
  bool bRecordSwitch = false;

  //录像段-时间 5-120
  int recordPartTime = 5;

  //预录
  int preRecordTime = 5;

  Future _queryRecordConfig({bool bShowLoading = false}) async {
    if (bShowLoading) {
      KToast.show();
    }
    try {
      final Map resultMap = await JFApi.xcDevice
          .xcDevGetSysConfig(deviceId: deviceId, commandName: 'Record');
      if (bShowLoading) {
        KToast.dismiss();
      }
      if (resultMap['Ret'] == 100) {
        if (resultMap['Record'].runtimeType == List) {
          mapRecordConfig = resultMap['Record'][0];
        } else {
          mapRecordConfig = resultMap['Record'];
        }
        recordPartTime = mapRecordConfig!['PacketLength'];
        preRecordTime = mapRecordConfig!['PreRecord'];
        //录像方式
        final String pRecordMode = mapRecordConfig!['RecordMode'];
        int mask = 0;
        List masks = mapRecordConfig!['Mask'];
        if (masks.isNotEmpty) {
          mask = int.parse(masks[0][0]); //'0x00000007'  0x7
        }

        ///录像开关状态
        bRecordSwitch = pRecordMode == 'ConfigRecord' && mask == 7;
        if (bShowLoading) {
          notifyListeners();
        }
      }
    } catch (e) {
      KToast.show(status: KErrorMsg(e));
      if (bShowLoading == false) {
        context.pop();
      }
    }
    return Future.value();
  }

  onSetRecordConfig({bool bShowLoading = false}) async {
    if (mapRecordConfig == null) {
      return;
    }
    final tempMap = Map.from(mapRecordConfig!);
    tempMap['RecordMode'] = 'ConfigRecord';

    ///录像开关
    if (bRecordSwitch) {
      //打开
      List masks = tempMap['Mask'];
      for (List subMask in masks) {
        subMask[0] = '0x00000007';
      }
      List timeSections = tempMap['TimeSection'];
      for (List subTimeSections in timeSections) {
        subTimeSections[0] = '1 00:00:00-24:00:00';
      }
    } else {
      //关闭
      List masks = tempMap['Mask'];
      for (List subMask in masks) {
        subMask[0] = '0x00000006';
      }
      List timeSections = tempMap['TimeSection'];
      for (List subTimeSections in timeSections) {
        subTimeSections[0] = '1 00:00:00-24:00:00';
      }
    }

    // ///预录像
    // tempMap['PreRecord'] = preRecordTime;
    ///录像段
    tempMap['PacketLength'] = recordPartTime;
    if (bShowLoading) {
      KToast.show();
    }
    try {
      String jsStr = jsonEncode([tempMap]);
      await JFApi.xcDevice.xcDevSetSysConfig(
          deviceId: deviceId,
          commandName: 'Record',
          config: jsStr,
          configLen: 2048,
          command: 1040,
          timeout: 5000);
      if (bShowLoading) {
        KToast.dismiss();
      }
      configDeviceSetItemMoleList();
    } catch (e) {
      KToast.show(status: KErrorMsg(e));
    }
    return Future.value();
  }

  ///编码配置 ##################
  bool bSupportEncode = false;
  Map? mapEncodeConfig;

  //主码流音频开关
  bool bMainAudio = false;

  //主码流 FPS
  int mainFps = 0;

  //主码流 Resolution: 1080P 、720P 、3M
  //Resolution 会影响FPS的最大值， Resolution越清晰FPS最大值越小
  String mainResolution = '';

  //主码流 画质
  int curMainQualityIndex = 0;
  List<Map> qualityList = [
    {
      'value': 1,
      'title': TR.current.recordQualityVeryBad,
    },
    {
      'value': 2,
      'title': TR.current.recordQualityBad,
    },
    {
      'value': 3,
      'title': TR.current.recordQualityNormal,
    },
    {
      'value': 4,
      'title': TR.current.recordQualityGood,
    },
    {
      'value': 5,
      'title': TR.current.recordQualityVeryGood,
    },
    {
      'value': 6,
      'title': TR.current.recordQualityBestGood,
    },
  ];

  Future _queryEncodeConfig({bool bShowLoading = false}) async {
    if (bShowLoading) {
      KToast.show();
    }
    try {
      final Map resultMap = await JFApi.xcDevice.xcDevGetSysConfig(
          deviceId: deviceId, commandName: 'Simplify.Encode');
      log(resultMap.toString());
      if (bShowLoading) {
        KToast.dismiss();
      }
      if (resultMap['Ret'] == 100) {
        bSupportEncode = true;
        mapEncodeConfig = resultMap['Simplify.Encode'][0];
        bMainAudio = mapEncodeConfig!['MainFormat']['AudioEnable'] as bool;
        mainFps = mapEncodeConfig!['MainFormat']['Video']['FPS'] as int;
        mainResolution =
            mapEncodeConfig!['MainFormat']['Video']['Resolution'] as String;
        final pMainQuality =
            mapEncodeConfig!['MainFormat']['Video']['Quality'] as int;
        for (int i = 0; i < qualityList.length; i++) {
          if (qualityList[i]['value'] == pMainQuality) {
            curMainQualityIndex = i;
            break;
          }
        }
        if (bShowLoading) {
          configDeviceSetItemMoleList();
        }
      }
    } catch (e) {
      bSupportEncode = false;
      KToast.show(status: KErrorMsg(e));
      if (bShowLoading) {
        configDeviceSetItemMoleList();
      }
      if (bShowLoading == false) {
        context.pop();
      }
    }
    return Future.value();
  }

  Future onSetEncodeConfig({bool bShowLoading = false}) async {
    if (mapEncodeConfig == null) {
      return;
    }
    Map tempMap = Map.from(mapEncodeConfig!);
    tempMap['MainFormat']['AudioEnable'] = bMainAudio;
    tempMap['MainFormat']['Video']['Quality'] =
        qualityList[curMainQualityIndex]['value'];
    if (bShowLoading) {
      KToast.show();
    }
    try {
      String jsStr = jsonEncode([tempMap]);
      await JFApi.xcDevice.xcDevSetSysConfig(
          deviceId: deviceId,
          commandName: 'Simplify.Encode',
          config: jsStr,
          configLen: 2048,
          command: 1040,
          timeout: 5000);
      if (bShowLoading) {
        KToast.dismiss();
      }
      _queryEncodeConfig(bShowLoading: true);
    } catch (e) {
      KToast.show(status: KErrorMsg(e));
    }
    return Future.value();
  }
}
