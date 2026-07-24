import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/media/media_player.dart';
import 'package:xcloudsdk_flutter/utils/extensions.dart';
import 'package:xcloudsdk_flutter_example/common/common_path.dart';
import 'package:xcloudsdk_flutter_example/common/match.dart';
import 'package:xcloudsdk_flutter_example/pages/media_realplay/model/preset.dart';
import 'package:xcloudsdk_flutter_example/views/dialog/edit_text_widget.dart';
import 'package:xcloudsdk_flutter_example/views/toast/toast.dart';

import '../../../common/code_prase.dart';

///预置点View
class DevPresetView extends StatefulWidget {
  final PreviewMediaController previewController;
  final String devId;

  const DevPresetView(
      {Key? key, required this.previewController, required this.devId})
      : super(key: key);

  @override
  State<DevPresetView> createState() => _DevPresetViewState();
}

class _DevPresetViewState extends State<DevPresetView> {
  ///所有添加的预置点
  List<Preset?> presets = [null];

  ///巡航点 最多三个
  List<Preset> tours = [];

  ///航线id, 一般只为一条
  int tourId = 0;

  @override
  void initState() {
    _loadPresets();
    super.initState();
  }

  void _loadPresets() async {
    try {
      var result = await DeviceAPI.instance.xcDevGetSysConfig(
          deviceId: widget.devId,
          commandName: 'Uart.PTZPreset',
          command: 1042,
          timeout: 15000);
      presets.clear();
      presets.addAll(await Preset.getPresetList(widget.devId, result));
      presets.add(null);
      if (mounted) {
        setState(() {});
      }
      _loadTours();
    } catch (e) {
      if (e is int) {
        //特殊兼容.某些设备恢复出厂设置之后,查询预置点,会报这两个code
        if (e != -70607 && e != -70102) {
          KToast.show(status: kErrorMsg(e));
        }
      }
    }
  }

  @override
  void dispose() async {
    super.dispose();
  }

  int _pageCount() {
    return (presets.length - 1) ~/ 4 + 1;
  }

  List<Preset?> _pagePresets(int index) {
    return presets
        .getRange(4 * index, min(4 * index + 4, presets.length))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          color: Colors.white),
      child: Column(
        children: [
          Expanded(
              child: PageView.builder(
            itemBuilder: (context, pageIndex) {
              List<Preset?> presets = _pagePresets(pageIndex);
              return SizedBox(
                height: 200,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      crossAxisCount: 2,
                      childAspectRatio: 1.68),
                  itemBuilder: (context, index) {
                    Preset? preset = presets[index];
                    int indexInPage = 4 * pageIndex + index;
                    return preset == null
                        ? _addPresetWidget()
                        : GestureDetector(
                            onTap: () async {
                              _gotoPreset(indexInPage);
                            },
                            onLongPress: () {
                              //删除预置点
                              _clearPreset(index);
                            },
                            onDoubleTap: () {
                              _changeName(indexInPage);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16)),
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.5))),
                              child: preset == null
                                  ? const Icon(Icons.add_rounded)
                                  : Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(16)),
                                          child: _getImage(preset),
                                        ),
                                        Center(
                                          child: Text(preset.name.isEmpty
                                              ? '$indexInPage'
                                              : preset.name),
                                        ),
                                        Checkbox(
                                            value: preset.tour,
                                            onChanged: (check) {
                                              _optPresetTour(indexInPage);
                                            })
                                      ],
                                    ),
                            ),
                          );
                  },
                  itemCount: presets.length,
                ),
              );
            },
            itemCount: _pageCount(),
          )),
          ElevatedButton(
              onPressed: () {
                JFApi.xcDevice.xcDevStartPtzTour(
                    deviceId: widget.devId, channel: 0, tourIndex: tourId);
              },
              child: const Text('开始巡航')),
          const SizedBox(
            height: 32,
          ),
        ],
      ),
    );
  }

  Widget _addPresetWidget() {
    return GestureDetector(
      onTap: () {
        _addPreset();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Colors.grey)),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _getImage(Preset preset) {
    return FadeInImage(
      key: UniqueKey(),
      width: double.infinity,
      fit: BoxFit.cover,
      image: FileImage(File(preset.cover)),
      placeholder: const AssetImage('images/monitor_bg.png'),
    );
  }

  void _changeName(int index) async {
    Preset preset = presets[index]!;
    String? name = await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return EditTextDialog(
            initText: preset.name,
          );
        });
    if (name != null) {
      if (JFMatch.kIsValidPresetPointName(name)) {
        setState(() {
          preset.name = name;
        });
      } else {
        KToast.show(
            status:
                "添加失败,预置点名称不符合，要求长度1-16，中文、大小写英文、数字，以及下列特殊字符 @#%^&*()_[]{}?/.<>,';:-");
      }
    }
  }

  void _optPresetTour(int index) {
    Preset preset = presets[index]!;
    //1.如果当前不是巡航点,则判断能否添加
    if (!preset.tour) {
      //当前是否已经存在三个巡航点了.
      int tourLength = presets.where((e) => e?.tour ?? false).length;
      if (tourLength >= 3) {
        return;
      }
      _addTour(preset);
    } else {
      //删除巡航点
      _deleteTour(preset);
    }
  }

  void _addTour(Preset preset) async {
    try {
      preset.tour = true;
      //添加
      tours.add(preset);
      var commend = {
        "Command": "AddTour",
        "Parameter": {
          "Preset": preset.id, //预置点编号
          "Step": 3, //步长(写死为3)
          "Tour": tourId, //巡航线编号
          "PresetIndex": tours.length //当前预置点所在航线的编号
        }
      };
      String commendJson = json.encode(commend);
      await DeviceAPI.instance.xcDevSetSysConfig(
          deviceId: widget.devId,
          commandName: 'OPPTZControl',
          config: commendJson,
          configLen: commendJson.length,
          command: 1400,
          timeout: 1500);
      _loadTours();
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  void _deleteTour(Preset preset) async {
    //删除
    try {
      tours.remove(preset);
      preset.tour = false;

      var commend = {
        "Command": "DeleteTour",
        "Parameter": {"Preset": preset.id, "Tour": tourId}
      };
      String commendJson = json.encode(commend);
      await DeviceAPI.instance.xcDevSetSysConfig(
          deviceId: widget.devId,
          commandName: 'OPPTZControl',
          config: commendJson,
          configLen: commendJson.length,
          command: 1400,
          timeout: 1500);

      _loadTours();
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  //预置点数据请求到之后,再去请求巡航点位信息,并保存到预置点Item中
  void _loadTours() async {
    try {
      var result = await DeviceAPI.instance.xcDevGetSysConfig(
          deviceId: widget.devId, commandName: 'Uart.PTZTour');
      Preset.syncTourInfo(presets, tourId, result);
      setState(() {});
    } catch (e) {
      //ignore
    }
  }

  StreamSubscription? snapshotSub;

  ///添加预置点
  ///[index] 添加的位置
  void _addPreset() async {
    //最多添加32个, 还有一个 null
    if (presets.length == 33) {
      return;
    }
    //获取可用的预置点id
    int enableId = 0;
    for (int i = 1; i < 32; i++) {
      Preset? preset =
          presets.firstWhereOrNull((e) => (e != null && e.id == i));
      if (preset == null) {
        enableId = i;
        break;
      }
    }
    try {
      final code = await JFApi.xcDevice
          .xcDevSetPreset(deviceId: widget.devId, channel: 0, preset: enableId);
      if (code >= 0) {
        KToast.show(status: '添加成功');
        String image = await getEnableCoverPath(enableId);
        await _onSnap(presetId: enableId, imagePath: image);
        Preset preset = Preset(id: enableId);
        if (snapshotSub != null) {
          snapshotSub!.cancel();
          snapshotSub = null;
        }

        snapshotSub =
            widget.previewController.snapshoEvent.listen((event) async {
          if (event.controllerId != widget.previewController.controllerId) {
            return;
          }
          if (event.snapshotKey != 'preset') {
            return;
          }
          if (event.code >= 0) {
            FileImage(File(event.filePath)).evict();
            preset.cover = image;
          }
          setState(() {
            presets.insert(presets.length - 1, preset);
          });
        });
      }
    } catch (e) {
      if (e is int && e < 0) {
        KToast.show(status: kErrorMsg(e));
      }
    }
  }

  void _clearPreset(int index) async {
    Preset preset = presets[index]!;
    final code = await JFApi.xcDevice.xcDevClearPreset(
        deviceId: widget.devId, channel: 0, preset: preset.id);
    if (code >= 0) {
      KToast.show(status: '删除成功');
      preset.deletePresetCover(widget.devId);
      _deleteTour(preset);
      setState(() {
        presets.removeWhere((e) => e?.id == preset.id);
      });
    }
  }

  void _gotoPreset(int index) async {
    Preset preset = presets[index]!;
    final code = await JFApi.xcDevice
        .xcDevGotoPreset(deviceId: widget.devId, channel: 0, preset: preset.id);
    if (code >= 0) {
      KToast.show(status: '跳转预置点成功');
    }
  }

  Future<void> _onSnap({required int presetId, String imagePath = ''}) async {
    String presetImagePath = '';
    if (imagePath.isEmpty) {
      //获取本地存图片的文件夹路径
      String directoryPath = await kDirectoryPresetImagePath();
      String deviceId = widget.devId;
      String channel = 'channel0'; //预留通道位置
      presetImagePath =
          '/$directoryPath/$kPresetImage${deviceId}_${channel}_$presetId.jpg';
    } else {
      presetImagePath = imagePath;
    }
    await widget.previewController
        .snapshot(presetImagePath, snapshotKey: 'preset');
  }

  Future<String> getEnableCoverPath(int presetId) async {
    //获取本地存图片的文件夹路径
    String directoryPath = await kDirectoryPresetImagePath();
    String deviceId = widget.devId;
    String channel = 'channel0'; //预留通道位置
    return '/$directoryPath/$kPresetImage${deviceId}_${channel}_$presetId.jpg';
  }
}
