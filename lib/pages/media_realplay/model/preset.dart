import 'dart:io';

import 'package:fcloudsdk/utils/extensions.dart';

import '../../../common/common_path.dart';

///预置点
class Preset {
  ///id 从 0 开始
  final int id;

  ///自定义名称..双击修改
  String name = '';
  String cover = '';

  ///是否为巡航点
  bool tour = false;

  ///若为巡航点,则此为巡航点下标
  int tourIndex = 0;

  Preset({required this.id, this.cover = ''});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['id'] = id;
    map['name'] = name;
    map['cover'] = cover;
    map['tour'] = tour;
    return map;
  }

  factory Preset.fromJson(Map<String, dynamic> json) {
    return Preset(id: json['Id']);
  }

  static Future<List<Preset>> getPresetList(
      String deviceId, Map<String, dynamic> json) async {
    List<Preset> presets = [];
    if (json.containsKey('Name')) {
      String name = json['Name'];
      if (json.containsKey(name)) {
        List<Map<String, dynamic>> originPresets = [];
        dynamic ptzPresets = json[name];
        if (ptzPresets != null && ptzPresets is List && ptzPresets.isNotEmpty) {
          dynamic ptzPreset = ptzPresets[0];
          if (ptzPreset != null && ptzPreset is List && ptzPreset.isNotEmpty) {
            originPresets.addAll(List<Map<String, dynamic>>.from(ptzPreset));
          }
        }
        presets.addAll(originPresets.map((e) => Preset.fromJson(e)).toList());
        presets.removeWhere(
            (e) => e.id == 99 || e.id == 100 || e.id == 128 || e.id == 250);
        for (var preset in presets) {
          preset.cover = await getExistsCoverPath(deviceId, preset.id);
        }
      }
    }
    return presets;
  }

  static Future<String> getExistsCoverPath(
      String deviceId, int presetId) async {
    Directory directory = Directory(await kDirectoryPresetImagePath());
    if (!directory.existsSync()) {
      return '';
    }
    var files = directory.listSync();
    String channel = 'channel0'; //预留通道位置
    for (FileSystemEntity entity in files) {
      if (entity is File) {
        String path = entity.path;
        if (path.contains('${deviceId}_${channel}_$presetId')) {
          return path;
        }
      }
    }
    return '';
  }

  static int syncTourInfo(
      List<Preset?> presets, int tourId, Map<String, dynamic> json) {
    List<Tour> tours = [];
    if (json.containsKey('Name')) {
      String name = json['Name'];
      if (json.containsKey(name)) {
        dynamic channels = json[name];
        if (channels != null && channels is List && channels.isNotEmpty) {
          dynamic channel = channels[0];
          if (channel != null && channel is List && channel.isNotEmpty) {
            dynamic tourMap = channel[0];
            if (tourMap != null && tourMap is Map) {
              tourId = tourMap['Id'] ?? 0;
              if (tourMap.containsKey('Tour')) {
                List<dynamic> tourListJson = tourMap['Tour'] ?? [];
                if (tourListJson.isNotEmpty) {
                  tours.addAll(
                      tourListJson.map((e) => Tour.fromJson(e)).toList());
                }
              }
            }
          }
        }
      }
    }
    //清除之前的巡航点数据
    for (var preset in presets) {
      if (preset != null) {
        preset.tour = false;
        preset.tourIndex = 0;
      }
    }

    if (tours.isEmpty) {
      return 0;
    }

    for (int i = 0; i < tours.length; i++) {
      int id = tours[i].id;
      Preset? preset = presets.firstWhereOrNull((e) => e?.id == id);
      preset?.tour = true;
      preset?.tourIndex = i;
    }
    return tours.length;
  }

  Future<void> deletePresetCover(String deviceId) async {
    Directory directory = Directory(await kDirectoryPresetImagePath());
    if (!directory.existsSync()) {
      return;
    }
    String channel = 'channel0'; //预留通道位置
    var files = directory.listSync();
    for (FileSystemEntity entity in files) {
      if (entity is File) {
        String path = entity.path;
        if (path.contains('${deviceId}_${channel}_$id')) {
          entity.deleteSync();
        }
      }
    }
  }
}

class Tour {
  int id;
  String name;
  int time;

  Tour({required this.id, this.name = '', this.time = 3});

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
        id: json['Id'], name: json['Name'] ?? '', time: json['Time'] ?? 3);
  }
}
