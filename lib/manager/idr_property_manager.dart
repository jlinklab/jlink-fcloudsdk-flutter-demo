import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:fcloudsdk/api/device_upload_dev_data/device_upload_dev_data_api.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/utils/map_utils.dart';

/// 低功耗设备：电量+4G信号+充电状态 等设备属性获取更新管理类
class IDRPropertyManager {
  static final IDRPropertyManager instance = IDRPropertyManager._();

  IDRPropertyManager._();

  ///4G信号更新行为
  final Map<String, BehaviorSubject> _signalSubjects = {};

  ///信噪比
  final Map<String, BehaviorSubject> _sinrSubjects = {};

  /// 电量+充电状态更新行为
  final Map<String, BehaviorSubject> _eleSubjects = {};

  /// live sd卡状态值
  final Map<String, BehaviorSubject> _liveSDStateSubjects = {};

  ///Wi-Fi信号更新行为
  final Map<String, BehaviorSubject> _wifiSignalSubjects = {};

  ///4G信号状态Stream
  ///[deviceId] 设备Id
  Stream<SignalLevelEntry?> signal4GLevelStream(String deviceId) {
    BehaviorSubject? subject = _signalSubjects[deviceId];
    bool needAdd = subject == null;
    subject ??= BehaviorSubject<SignalLevelEntry?>();
    if (needAdd) {
      _signalSubjects[deviceId] = subject;
    }
    return subject.stream.cast<SignalLevelEntry?>();
  }

  ///电量Stream + 充电状态
  ///[deviceId] 设备Id
  Stream<EleEntry?> eleStream(String deviceId) {
    BehaviorSubject? subject = _eleSubjects[deviceId];
    bool needAdd = subject == null;
    subject ??= BehaviorSubject<EleEntry?>();
    if (needAdd) {
      _eleSubjects[deviceId] = subject;
    }
    return subject.stream.cast<EleEntry?>();
  }

  ///获取当前电池状态
  ///[deviceId] 设备序列号
  int? getEleLevel(String deviceId) {
    return _eleSubjects[deviceId]?.valueOrNull?.level;
  }

  /// 有卡状态
  ///[devId] 设备Id
  Stream<LiveSDStatusEntry?> listenLiveSDState(String devId) {
    BehaviorSubject? subject = _liveSDStateSubjects[devId];
    bool needAdd = subject == null;
    subject ??= BehaviorSubject<LiveSDStatusEntry?>();
    if (needAdd) {
      _liveSDStateSubjects[devId] = subject;
    }
    return subject.stream.cast<LiveSDStatusEntry?>();
  }

  ///Wifi信号状态Stream
  ///[deviceId] 设备Id
  Stream<SignalLevelEntry?> signalWifiLevelStream(String deviceId) {
    BehaviorSubject? subject = _wifiSignalSubjects[deviceId];
    bool needAdd = subject == null;
    subject ??= BehaviorSubject<SignalLevelEntry?>();
    if (needAdd) {
      _wifiSignalSubjects[deviceId] = subject;
    }
    return subject.stream.cast<SignalLevelEntry?>();
  }

  ///获取当前4G信号
  ///[deviceId] 设备序列号
  int? getSignal4GLevel(String deviceId) {
    return _signalSubjects[deviceId]?.valueOrNull?.level;
  }

  ///信噪比
  ///[deviceId] 设备序列号
  int? getSinrLevel(String deviceId) {
    return _sinrSubjects[deviceId]?.valueOrNull?.level;
  }

  ///获取当前充电状态
  ///[deviceId] 设备序列号
  bool? getChargingState(String deviceId) {
    return _eleSubjects[deviceId]?.valueOrNull?.isCharging;
  }

  /// 获取当前直播页面 sd卡状态值
  /// devId 设备序列号
  int? getLiveSDStatus(String devId) {
    return _liveSDStateSubjects[devId]?.valueOrNull?.status;
  }

  ///获取当前Wifi信号
  ///[deviceId] 设备序列号
  int? getSignalWifiLevel(String deviceId) {
    return _wifiSignalSubjects[deviceId]?.valueOrNull?.level;
  }

  ///设备主动上报的监听缓存
  ///key 为 xcStartUploadDevData 返回的句柄
  ///在 xcStopUploadDevData 时取消监听
  final Map<int, StreamSubscription> _uploadSubMap = {};

  ///让设备主动上报属性，进行更新，一般在进入预览进行调用
  ///[deviceId] 设备Id
  ///返回监听句柄，-1失败，其它为成功，取消上报时使用 handle
  Future<int> makeStartUploadProperty({required String deviceId}) async {
    StreamSubscription? subscription;
    try {
      subscription = DeviceUploadDevDataAPI.instance.deviceUploadDataStream
          .listen((event) async {
        try {
          var map = event['Dev.ElectCapacity'];
          var percent = MapParser.readInt(map, 'percent');
          var level = MapParser.readInt(map, 'level');
          var devStorageStatus =
              MapParser.readInt(map, 'DevStorageStatus'); // 接收卡状态 返回值
          var electable = MapParser.readInt(
              map, 'electable'); //0：未充电 1：充电中 2：充电满 3:   电量模块未启动好，状态未知
          // 更新sd卡状态
          updateLiveSDStatus(deviceId, devStorageStatus);
          if (electable == 3) {
            ///模块异常，不处理
            return;
          }
          int? currentPower;
          if (percent != null) {
            currentPower = percent;
          } else if (level != null) {
            currentPower = level * 100 ~/ 7;
          }
          currentPower = currentPower?.clamp(0, 100);

          bool currentIsCharging = electable == 1 || electable == 2;
          updateEleLevel(deviceId, currentPower);
          updateEleCharging(deviceId, currentIsCharging);
        } catch (e) {
          //
        }
      });
      int handle = await DeviceUploadDevDataAPI.instance.xcStartUploadDevData(
          deviceId: deviceId,
          szUploadType: "",
          szUploadJson: "",
          nUploadType: 5);
      _uploadSubMap[handle] = subscription;
      return handle;
    } catch (error) {
      subscription?.cancel();
      return -1;
    }
  }

  ///取消设备上报
  ///[deviceId] 设备Id
  ///[handle]是[makeStartUploadProperty]返回的句柄
  void makeStopUploadProperty(
      {required String deviceId, required int handle}) async {
    try {
      if (handle < 0) {
        return;
      }
      _uploadSubMap.remove(handle)?.cancel();
      await DeviceUploadDevDataAPI.instance.xcStopUploadDevData(handle: handle);
    } catch (e) {
      //
    }
  }

  ///更新电量
  ///[deviceId] 设备序列号
  ///[level] 电量
  void updateEleLevel(String deviceId, int? level) {
    BehaviorSubject? subject = _eleSubjects[deviceId];
    bool needAdd = subject == null;
    subject ??= BehaviorSubject<EleEntry?>();
    if (needAdd) {
      _eleSubjects[deviceId] = subject;
    }
    if (!subject.isClosed) {
      subject.add(EleEntry(deviceId, level, getChargingState(deviceId)));
    }
  }

  ///更新4G信号
  ///[deviceId] 设备序列号
  ///[level] 信号强度
  void update4GSignalLevel(String deviceId, int? level) {
    BehaviorSubject? subject = _signalSubjects[deviceId];
    bool needAdd = subject == null;
    subject ??= BehaviorSubject<SignalLevelEntry?>();
    if (needAdd) {
      _signalSubjects[deviceId] = subject;
    }
    if (!subject.isClosed) {
      subject.add(SignalLevelEntry(deviceId, level));
    }
  }

  ///更新信噪比
  ///[deviceId] 设备序列号
  ///[level] 信号强度
  void updateSinrLevel(String deviceId, int? level) {
    BehaviorSubject? subject = _sinrSubjects[deviceId];
    bool needAdd = subject == null;
    subject ??= BehaviorSubject<SignalLevelEntry?>();
    if (needAdd) {
      _sinrSubjects[deviceId] = subject;
    }

    if (!subject.isClosed) {
      subject.add(SignalLevelEntry(deviceId, level));
    }
  }

  ///更新充电状态
  ///[deviceId] 设备序列号
  ///[level] 是否充电
  void updateEleCharging(String deviceId, bool? isCharging) {
    BehaviorSubject? subject = _eleSubjects[deviceId];
    bool needAdd = subject == null;
    subject ??= BehaviorSubject<EleEntry?>();
    if (needAdd) {
      _eleSubjects[deviceId] = subject;
    }
    if (!subject.isClosed) {
      subject.add(EleEntry(deviceId, getEleLevel(deviceId), isCharging));
    }
  }

  /// 更新 sd卡 状态值
  void updateLiveSDStatus(String devId, int? status) {
    // if (status == null) return;
    BehaviorSubject? subObj = _liveSDStateSubjects[devId];
    bool needAdd = subObj == null;
    subObj ??= BehaviorSubject<LiveSDStatusEntry?>();
    if (needAdd) {
      _liveSDStateSubjects[devId] = subObj;
    }
    if (!subObj.isClosed) {
      subObj.add(LiveSDStatusEntry(devId, status));
    }
  }

  // todo: 清除对应devId的sd卡状态
  /// 删除设备时移除缓存
  void cleanDeviceSDStateCache(String devId) {
    if (_liveSDStateSubjects.containsKey(devId)) {
      _liveSDStateSubjects.remove(devId);
    }
  }

  /// 更新 wifi信号 状态值
  void updateWifiSignalStatus(String devId, int? status) {
    LogUtils.idr.log('[wifi-signal-status] $devId $status');
    // if (status == null) return;
    BehaviorSubject? subObj = _wifiSignalSubjects[devId];
    bool needAdd = subObj == null;
    subObj ??= BehaviorSubject<SignalLevelEntry?>();
    if (needAdd) {
      _wifiSignalSubjects[devId] = subObj;
    }
    if (!subObj.isClosed) {
      subObj.add(SignalLevelEntry(devId, status));
    }
  }

  ///释放Stream
  Future<void> dispose() async {
    for (var subscribe in _uploadSubMap.values) {
      try {
        await subscribe.cancel();
      } catch (e) {
        //
      }
    }
    _uploadSubMap.clear();

    for (var subject in _signalSubjects.values) {
      try {
        await subject.close();
      } catch (e) {
        //
      }
    }
    _signalSubjects.clear();

    for (var subject in _sinrSubjects.values) {
      try {
        await subject.close();
      } catch (e) {
        //
      }
    }
    _sinrSubjects.clear();

    for (var subject in _eleSubjects.values) {
      try {
        await subject.close();
      } catch (e) {
        //
      }
    }
    _eleSubjects.clear();

    for (var subObj in _liveSDStateSubjects.values) {
      try {
        await subObj.close();
      } catch (e) {
        //
      }
    }
    _liveSDStateSubjects.clear();

    for (var subObj in _wifiSignalSubjects.values) {
      try {
        await subObj.close();
      } catch (e) {
        //
      }
    }
    _wifiSignalSubjects.clear();
  }
}

///电量+充电状态
class EleEntry {
  String deviceId;
  int? level;
  bool? isCharging;

  EleEntry(this.deviceId, this.level, this.isCharging);
  @override
  String toString() {
    return 'EleEntry{deviceId: $deviceId, level: $level, isCharging: $isCharging}';
  }
}

/// sd卡 状态值
class LiveSDStatusEntry {
  /// 设备序列号
  String devId;

  /// sd卡状态值
  int? status;
  LiveSDStatusEntry(this.devId, this.status);
}

///信号
class SignalLevelEntry {
  String deviceId;
  int? level;

  SignalLevelEntry(this.deviceId, this.level);
}
