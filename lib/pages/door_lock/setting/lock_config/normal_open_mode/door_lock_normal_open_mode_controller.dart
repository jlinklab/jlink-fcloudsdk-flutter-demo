import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_set_config.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

///常开模式页面控制器
class DoorLockNormalOpenModeController extends DoorLockPageController
    with DoorLockSetConfigMixin {
  @override
  final String deviceId;

  DoorLockSetConfig initSetConfig;
  late final bool supportTemp;

  bool open = false;
  bool tempOpen = false;
  bool allDayOpen = false;
  List<int> weeks = [];
  int startTime = 0;
  int endTime = 0;
  bool saving = false;
  bool _disposed = false;

  DoorLockNormalOpenModeController({
    required super.context,
    required this.deviceId,
    required this.initSetConfig,
  }) {
    supportTemp =
        device.doorLockExInfo?.byte3.supportTemporaryConstantOpen == true;
    _initData();
  }

  void _initData() {
    final now = DateTime.now();
    startTime = now.hour * 60 + now.minute;
    endTime = (startTime + 60).clamp(0, 1439);

    open = (initSetConfig.bleOpenMode ?? 0) > 0;
    tempOpen = (initSetConfig.bleTempOpenMode ?? 0) > 0;
    allDayOpen = (initSetConfig.bleNormalOpenModeAllDay ?? 0) <= 0;
    weeks = List<int>.of(initSetConfig.bleNormalOpenModeWeeks ?? []);

    final savedStart = initSetConfig.bleNormalOpenModeStartTime;
    final savedEnd = initSetConfig.bleNormalOpenModeEndTime;
    if (savedStart != null && savedEnd != null && savedEnd != 0) {
      startTime = savedStart;
      endTime = savedEnd;
    }
  }

  void updateOpen(bool value) {
    open = value;
    _notify();
  }

  void updateTempOpen(bool value) {
    tempOpen = value;
    _notify();
  }

  void updateAllDay(bool value) {
    allDayOpen = value;
    _notify();
  }

  void updateWeek(int day, bool selected) {
    if (selected) {
      if (!weeks.contains(day)) weeks.add(day);
    } else {
      weeks.remove(day);
    }
    weeks.sort();
    _notify();
  }

  void updateStartTime(int value) {
    startTime = value;
    _notify();
  }

  void updateEndTime(int value) {
    endTime = value;
    _notify();
  }

  Future<DoorLockSetConfig?> saveConfig() async {
    if (saving) return null;
    if (open && weeks.isEmpty) {
      KToast.show(status: '请至少选择一天');
      return null;
    }
    if (open && !allDayOpen && startTime >= endTime) {
      KToast.show(status: '结束时间需晚于开始时间');
      return null;
    }

    saving = true;
    _notify();
    try {
      if (supportTemp) {
        ///设备端配置会相互覆盖，先写临时常开再写日期常开
        final tempOk = await setTemporaryNormalOpenMode(
          isOpen: tempOpen,
          cmd: getTempTransCmd(),
        );
        if (!tempOk) {
          await _restoreLatest();
          return null;
        }
      }

      final result = await setNormalOpenMode(
        isOpen: open,
        isAllDay: allDayOpen,
        weekValue: weeks,
        startTime: startTime,
        endTime: endTime,
        cmd: getNormalTransCmd(),
      );
      if (!result) {
        await _restoreLatest();
        return null;
      }

      _applyExpectedConfig();
      await DoorLockHelper.instance.saveOnlineConfig(
        deviceId,
        supportTemp
            ? [getTempUploadCmdStr(), getUploadCmdStr()]
            : [getUploadCmdStr()],
      );

      final latest = await syncLatestSetConfig();
      if (latest != null) {
        initSetConfig = latest;
        _initData();
      }
      KToast.show(status: '保存成功');
      return initSetConfig;
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      await _restoreLatest();
      return null;
    } finally {
      saving = false;
      _notify();
    }
  }

  Future<void> _restoreLatest() async {
    final latest = await syncLatestSetConfig();
    if (latest == null || _disposed) return;
    initSetConfig = latest;
    _initData();
    _notify();
  }

  void _applyExpectedConfig() {
    initSetConfig
      ..bleOpenMode = open ? 1 : 0
      ..bleNormalOpenModeAllDay = allDayOpen ? 0 : 16
      ..bleNormalOpenModeWeeks = List<int>.of(weeks)
      ..bleNormalOpenModeStartTime = startTime
      ..bleNormalOpenModeEndTime = endTime;
    if (supportTemp) {
      initSetConfig.bleTempOpenMode = tempOpen ? 1 : 0;
    }
  }

  String getTempUploadCmdStr() {
    return bytesToHex([3, 0x1F, tempOpen ? 0x01 : 0x00]);
  }

  List<int> getTempTransCmd() {
    return [0x1F, tempOpen ? 0x01 : 0x00];
  }

  List<int> getNormalTransCmd() {
    var switchOpenValue = 0x00;
    if (open && allDayOpen) {
      switchOpenValue = 0x01;
    } else if (!open && !allDayOpen) {
      switchOpenValue = 0x10;
    } else if (open && !allDayOpen) {
      switchOpenValue = 0x11;
    }
    return [
      0x11,
      switchOpenValue,
      weekArrayToByte(weeks),
      ...timeMinutesToBytes(startTime, endTime),
    ];
  }

  String getUploadCmdStr() {
    final content = getNormalTransCmd();
    return bytesToHex([content.length + 1, ...content]);
  }

  int weekArrayToByte(List<int> weekIndexes) {
    var byteValue = 0;
    for (final index in weekIndexes) {
      byteValue |= 1 << index;
    }
    return byteValue & 0x7F;
  }

  List<int> timeMinutesToBytes(int startMinutes, int endMinutes) {
    return [
      startMinutes & 0xFF,
      (startMinutes >> 8) & 0x0F,
      endMinutes & 0xFF,
      (endMinutes >> 8) & 0x0F,
    ];
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
