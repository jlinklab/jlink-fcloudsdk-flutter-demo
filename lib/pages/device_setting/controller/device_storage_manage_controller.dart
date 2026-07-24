import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter_example/common/code_prase.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

class DeviceStorageManageController extends ChangeNotifier {
  final BuildContext context;
  final String deviceId;
  int channel = 0;

  Map? storageDataMap = {};

  ///查询存储信息 #######################
  //tf卡的状态
  //0：异常
  //1：没有TF
  //2：有,正常
  int tfStatus = 2;

  //存储容量(总)
  int storageTotal = 0;

  //视频容量
  int storageVideo = 0;

  //图片容量
  int storagePic = 0;

  //剩余容量
  int storageRemain = 0;

  bool isLoading = true;

  List<ListTile> dataSource = [];

  DeviceStorageManageController({
    required this.context,
    required this.deviceId,
  }) {
    _init();
  }

  void _init() {
    _configDeviceSetItemMoleList();
    _queryData();
  }

  ///请求页面数据
  void _queryData() async {
    await _queryStorageInfo();

    await _queryRecordFull();

    isLoading = false;

    _configDeviceSetItemMoleList();
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
      KToast.show(status: kErrorMsg(e));
    }
  }

  handleStorageData() {
    int sdkMaxDiskPerMachine = 8; //最多支持8块硬盘

    ///是否异常
    bool isAbnormal = false;
    int totalStorage = 0; // 总容量
    int freeStorage = 0; // 总剩余容量
    int videoTotalStorage = 0; // 录像总容量
    int videoFreeStorage = 0; // 录像总剩余容量
    int imgTotalStorage = 0; // 图像总容量
    int imgFreeStorage = 0; // 图像总剩余容量

    List storageInfoList = storageDataMap?['StorageInfo'];
    for (Map subMap in storageInfoList) {
      List partitionList = subMap['Partition'];
      for (int i = 0;
          i < partitionList.length && i < sdkMaxDiskPerMachine;
          i++) {
        Map ssMap = partitionList[i];

        ///判断SD卡状态是否异常
        if (ssMap['Status'] == null || ssMap['Status'] != 0) {
          isAbnormal = true;
          break;
        }

        ///录像分区计算
        if (ssMap['DirverType'] == 0) {
          final a = ssMap['TotalSpace'];
          print(a.runtimeType);

          videoTotalStorage += int.parse(ssMap['TotalSpace']);
          videoFreeStorage += int.parse(ssMap['RemainSpace']);
        }

        ///图片分区计算
        if (ssMap['DirverType'] == 4) {
          imgTotalStorage += int.parse(ssMap['TotalSpace']);
          imgFreeStorage += int.parse(ssMap['RemainSpace']);
        }
      }
    }

    totalStorage = videoTotalStorage + imgTotalStorage;
    freeStorage = videoFreeStorage + imgFreeStorage;

    ///组装数据
    if (isAbnormal) {
      tfStatus = 0;
    } else {
      tfStatus = totalStorage > 0 ? 2 : 1;
      storageTotal = totalStorage;
      storageRemain = freeStorage;
      storageVideo = videoTotalStorage;
      videoFreeStorage = videoFreeStorage;
      storagePic = imgTotalStorage;
      imgFreeStorage = imgFreeStorage;
    }
    KToast.dismiss();
    _configDeviceSetItemMoleList();
  }

  _configDeviceSetItemMoleList() {
    dataSource.clear();

    dataSource.add(ListTile(
      title: const Text('存储容量'),
      trailing: Text(_storageDataStr(storageTotal)),
    ));

    dataSource.add(ListTile(
      title: const Text('录像分区'),
      trailing: Text(_storageDataStr(storageVideo)),
    ));

    dataSource.add(ListTile(
      title: const Text('图片分区'),
      trailing: Text(_storageDataStr(storagePic)),
    ));

    dataSource.add(ListTile(
      title: const Text('剩余容量'),
      trailing: Text(_storageDataStr(storageRemain)),
    ));

    dataSource.add(const ListTile(
      title: Text('录像满时'),
      trailing: Text(''),
    ));

    dataSource.add(ListTile(
      title: Text(
        '暂停录像',
        style: TextStyle(
            color: recordFullType == 0 ? Colors.blueAccent : Colors.black),
      ),
      onTap: () {
        onSetRecordFullType(0);
      },
    ));
    dataSource.add(ListTile(
      title: Text('循环录像',
          style: TextStyle(
              color: recordFullType == 1 ? Colors.blueAccent : Colors.black)),
      onTap: () {
        onSetRecordFullType(1);
      },
    ));
    notifyListeners();
  }

  _storageDataStr(int storage) {
    if (storage > 1024) {
      return "${(storage / 1024).toStringAsFixed(2)}G";
    }
    return "${(storage.toDouble()).toStringAsFixed(2)}M";
  }

  ///查询录像满时 ###########################
  //录像满时： 0：停止录像(StopRecord) 1：循环录像(OverWrite)
  int recordFullType = -1;
  Map? mapGeneral;

  Future _queryRecordFull() async {
    try {
      final resultMap = await JFApi.xcDevice.xcDevGetSysConfig(
        deviceId: deviceId, commandName: 'General.General',
        // command: 1360
      );
      KToast.dismiss();
      if (resultMap['Ret'] != null && resultMap['Ret'] == 100) {
        mapGeneral = resultMap['General.General'];
        if (mapGeneral!.isNotEmpty && mapGeneral!['OverWrite'] != null) {
          recordFullType = mapGeneral!['OverWrite']! == 'OverWrite' ? 1 : 0;
        }
      }
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
    _configDeviceSetItemMoleList();
    return Future.value();
  }

  onSetRecordFullType(int type) async {
    if (type == recordFullType) {
      return;
    }
    String typeStr = type == 0 ? 'StopRecord' : 'OverWrite';
    mapGeneral!['OverWrite'] = typeStr;
    String jsStr = jsonEncode(mapGeneral);
    KToast.show();
    JFApi.xcDevice
        .xcDevSetSysConfig(
            deviceId: deviceId,
            commandName: 'General.General',
            config: jsStr,
            configLen: jsStr.length,
            command: 1040,
            timeout: 10000)
        .then((value) {
      KToast.dismiss();
      recordFullType = type;
      _configDeviceSetItemMoleList();
    }).catchError((e) {
      KToast.show(status: kErrorMsg(e));
    });
  }

  ///格式化
  onStorageFormatter() async {
    if (storageDataMap == null) {
      print('storageDataMap == null');
      return;
    }

    if (storageDataMap!['StorageInfo'] == null) {
      return;
    }
    List<Map<String, int>> willClearMapList = [];
    List oMapList = storageDataMap!['StorageInfo']!;
    for (int disk = 0; disk < oMapList.length; disk++) {
      Map partMap = oMapList[disk];
      if (partMap['Partition'] != null) {
        List oPartitionMapList = partMap['Partition']!;
        for (int partition = 0;
            partition < oPartitionMapList.length;
            partition++) {
          Map subPartitionMap = oPartitionMapList[partition];
          if (subPartitionMap['TotalSpace'] != '0x00000000') {
            Map<String, int> willClearMap = {
              'Disc': disk, //磁盘
              'Partition': partition //分区
            };
            willClearMapList.add(willClearMap);
          }
        }
      }
    }

    KToast.show();
    dfsFormatter(willClearMapList);
  }

  dfsFormatter(List<Map<String, int>> willClearMapList) async {
    if (willClearMapList.isEmpty) {
      KToast.show(status: '格式化成功');
      // ///格式化成功后，发送刷新录像文件的请求，重置SD卡回放页面数据
      // eventBusRefreshSDRecord.send({
      //   'action' : 'update',
      // });
      await Future.delayed(const Duration(milliseconds: 300));
      //格式化成功后 返回home页
      if (context.mounted) {
        //退到首页
        Navigator.popUntil(context, (route) => route.isFirst);
      }
      return;
    }
    final map = willClearMapList.removeAt(0);
    Map rMap = {
      'Action': 'Clear',
      'SerialNo': map['Disc'],
      'PartNo': map['Partition'],
      'Type': 'Data'
    };
    final String jsStr = jsonEncode(rMap);
    JFApi.xcDevice
        .xcDevSetSysConfig(
            deviceId: deviceId,
            commandName: 'OPStorageManager',
            config: jsStr,
            configLen: jsStr.length + 1,
            command: 1460,
            timeout: 250000)
        .then((value) {
      dfsFormatter(willClearMapList);
    }).catchError((e) {
      KToast.show(status: kErrorMsg(e));
    });
  }
}
