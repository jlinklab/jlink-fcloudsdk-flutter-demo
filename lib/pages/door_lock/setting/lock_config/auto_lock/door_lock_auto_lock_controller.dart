import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_set_config.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';

///自动关锁页面控制器
class DoorLockAutoLockController extends DoorLockPageController
    with DoorLockSetConfigMixin {
  @override
  final String deviceId;

  final DoorLockSetConfig initSetConfig;
  final TextEditingController customController = TextEditingController();

  bool open = false;
  int value = 0;
  int autoValue = 10;
  double draftValue = 10;
  int step = 10;
  int min = 5;
  int max = 900;
  bool canChangeTime = true;
  bool isCustom = false;
  bool writing = false;
  bool _disposed = false;

  DoorLockAutoLockController({
    required super.context,
    required this.deviceId,
    required this.initSetConfig,
  }) {
    createDoorLockAPI();
    _initData();
    Future.microtask(_syncLatest);
  }

  bool get isBle => !DoorLockHelper.isIotDoorLock(deviceId);

  bool get autoLockAlwaysOn =>
      device.doorLockBleAbility?.byte5.supportAutoLockV2 == true &&
      device.doorLockExInfo?.byte2.supportSemiAutomaticAutoLock == true;

  bool get isAuto => autoLockAlwaysOn || value > 0;

  List<int> get fixedTimes => const [5, 10, 15, 30, 60]
      .where((time) => time >= min && time <= max)
      .toList();

  String get delayText => isCustom ? '自定义' : '$autoValue 秒';

  void _initData() {
    final config = initSetConfig.autoLock;
    final defaultMin = isBle ? 5 : 10;
    final defaultMax = isBle ? 900 : 90;
    value = config?.value ?? 0;
    step = config?.step ?? 10;
    min = config?.min ?? defaultMin;
    max = config?.max ?? defaultMax;
    if (step <= 0) step = 1;
    canChangeTime =
        !((config?.min ?? defaultMin) <= 0 && (config?.max ?? defaultMax) <= 0);
    if (min <= 0) min = defaultMin;
    if (max <= min) max = defaultMax > min ? defaultMax : min + step;

    autoValue = value > 0 ? value : 10;
    if (autoValue < min) autoValue = min;
    if (autoValue > max) autoValue = max;
    draftValue = autoValue.toDouble();
    open = autoLockAlwaysOn || value > 0;
    isCustom = !fixedTimes.contains(autoValue);
    if (isCustom) customController.text = autoValue.toString();
  }

  Future<void> _syncLatest() async {
    final latest = await syncLatestSetConfig();
    if (_disposed || writing || latest?.autoLock == null) return;
    initSetConfig.autoLock = latest!.autoLock;
    _initData();
    _notify();
  }

  void updateOpen(bool newValue) {
    if (writing || autoLockAlwaysOn) return;
    open = newValue;
    _notify();
  }

  void selectFixedTime(int newValue) {
    if (writing || !fixedTimes.contains(newValue)) return;
    autoValue = newValue;
    isCustom = false;
    _notify();
  }

  void selectCustom() {
    if (writing) return;
    isCustom = true;
    customController.text = autoValue.toString();
    _notify();
  }

  Future<bool> saveBle() async {
    if (writing || !isBle) return false;
    var target = open ? autoValue : 0;
    if (open && isCustom) {
      final customValue = int.tryParse(customController.text);
      if (customValue == null || customValue < min || customValue > max) {
        KToast.show(status: '自动关锁时间必须在$min秒到$max秒范围内');
        return false;
      }
      autoValue = customValue;
      target = customValue;
    }
    return _writeValue(target);
  }

  Future<bool> changeMode(bool auto) async {
    if (writing || isBle || isAuto == auto) return false;
    if (!auto && autoLockAlwaysOn) return false;
    return _writeValue(auto ? autoValue : 0);
  }

  void updateDraftValue(double newValue) {
    if (writing || isBle || !isAuto || !canChangeTime) return;
    final steps = ((newValue - min) / step).round();
    draftValue = (min + steps * step).clamp(min, max).toDouble();
    _notify();
  }

  Future<bool> changeValue(int newValue) async {
    if (writing || isBle || !isAuto || !canChangeTime) return false;
    if (newValue < min || newValue > max || (newValue - min) % step != 0) {
      draftValue = autoValue.toDouble();
      _notify();
      return false;
    }
    return _writeValue(newValue);
  }

  Future<bool> _writeValue(int target) async {
    if (writing ||
        target < 0 ||
        (target == 0 && autoLockAlwaysOn) ||
        (target > 0 && (target < min || target > max))) {
      return false;
    }
    writing = true;
    _notify();
    try {
      final result = await setAutoLock(value: target);
      if (!result) {
        draftValue = autoValue.toDouble();
        return false;
      }
      value = target;
      if (target > 0) autoValue = target;
      open = autoLockAlwaysOn || target > 0;
      if (isBle && target > 0) {
        isCustom = !fixedTimes.contains(autoValue);
      }
      draftValue = autoValue.toDouble();
      _updateConfig();
      await _saveConfig();
      KToast.show(status: '保存成功');
      return true;
    } catch (e) {
      draftValue = autoValue.toDouble();
      KToast.show(status: kErrorMsg(e));
      return false;
    } finally {
      writing = false;
      _notify();
    }
  }

  void _updateConfig() {
    initSetConfig.autoLock = DoorLockAutoLockConfig(
      0x08,
      0x13,
      value,
      step,
      min,
      max,
    );
  }

  Future<void> _saveConfig() async {
    await DoorLockHelper.instance.saveOnlineConfig(
      deviceId,
      [
        bytesToHex([
          0x08,
          0x13,
          ..._uint16Le(value),
          step,
          min,
          ..._uint16Le(max),
        ])
      ],
    );
  }

  static List<int> _uint16Le(int value) {
    return [value & 0xFF, (value >> 8) & 0xFF];
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    customController.dispose();
    super.dispose();
  }
}
