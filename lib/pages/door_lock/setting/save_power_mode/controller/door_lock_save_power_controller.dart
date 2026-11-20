import 'dart:async';

import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_model.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/manager/device_property_manager.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/door_lock/model/door_lock_custom_enum.dart';
import 'package:fcloudsdk_example/pages/door_lock/setting/save_power_mode/door_lock_save_power_select_time_page.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/utils/map_utils.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

///省电模式控制器
class DoorLockSavePowerController extends DoorLockPageController {
  @override
  final String deviceId;

  ///原始数据
  DookLockSystemLightSleep? model;

  bool enableTriggerMode = false;
  bool enableMonitorMode = false;
  bool enableMonitorModeSelTime = false;
  bool enableSentinelMode = false;
  bool enableImageTransMode = false;

  ///可变数据
  var delay = 0;

  DoorLockSavePowerModeType currentMode = DoorLockSavePowerModeType.unknown;

  late DateTime monitorModeStart;
  late DateTime monitorModeEnd;
  bool get monitorisAllDay => monitorModeStart == monitorModeEnd;

  ///门锁首页直进时无上级页面收口End，退出时自己结束保活
  final bool fromHomePage;

  @override
  bool get keepSyncWhenDispose => !fromHomePage;

  DoorLockSavePowerController(
      {required super.context, required this.deviceId, this.fromHomePage = false}) {
    monitorModeStart = DateTime(DateTime.now().year);
    monitorModeEnd = DateTime(DateTime.now().year);

    init();
  }

  init() async {
    await queryJvss();

    ///直接从影子服务拿，如果是空的再从设备拿
    await queryShadow();

    notifyListeners();
  }

  queryJvss() async {
    try {
      List<Map<String, dynamic>>? propList = device.propList;
      if (propList == null || propList.isEmpty) {
        propList = await DevicePropertyManager.instance
            .getDeviceTypePropListByPid(pid: device.pid);
        device.propList = propList;
      }

      Map<String, dynamic>? map;
      for (var e in propList ?? []) {
        if (e['propCode'] == 'powerSavingMode') {
          map = e;
          break;
        }
      }

      if (map != null) {
        var values = (map['propValue'] as Map?)?['values'];
        if (values is List) {
          enableTriggerMode =
              values.contains(DoorLockSavePowerModeType.triggerMode.toKey());
          enableMonitorMode =
              values.contains(DoorLockSavePowerModeType.monitorMode.toKey());
          enableImageTransMode =
              values.contains(DoorLockSavePowerModeType.imageTransMode.toKey());
        }
      }
    } catch (e) {
      //
    }
  }

  queryShadow() async {
    try {
      await JFApi.xcDevice.xcDevGetConfigFromShadowServer(
          deviceId: device.uuid, configs: ['System.Sleep']).then((map) {
        if (map.isEmpty) {
          queryDeviceData();
          return;
        }
        map.forEach((key, value) {
          if (key == 'System.Sleep') {
            model = DookLockSystemLightSleep.from(value['LightSleep']);
            refreshData();
          }
        });
      });
    } catch (e) {
      queryDeviceData();
    }
  }

  queryDeviceData() async {
    if (device.sleepState == DeviceSleepState.deepSleep) {
      _showTipDialog(TR.current.TR_PowerSave_DeepSleepTip, onConfirm: () {
        Navigator.of(context).pop();
      });
      return;
    }

    if (await beforeNetIp(showAnotherOperatingTip: false) == false) {
      return;
    }

    var result = await DoorLockNetIp.getSystemSleep(deviceId: deviceId);
    if (result.item1 != null) {
      model = result.item1;
      refreshData();
      saveShadow(needShowTips: false);
    }

    ///设备获取还是失败，退出页面
    if (context.mounted && model == null) {
      var errorMsg = TR.current.TR_Common_DataGetFailed;
      if (result.item2 != null) {
        errorMsg = kErrorMsg(result.item2) ?? errorMsg;
      }
      _showTipDialog(errorMsg, onConfirm: () {
        Navigator.of(context).pop();
      });
    }
  }

  saveShadow({bool needShowTips = true}) async {
    if (model == null) {
      return;
    }
    var map = {
      'System.Sleep': {'LightSleep': model!.toJson()}
    };
    if (needShowTips) {
      KToast.show();
    }
    try {
      await JFApi.xcDevice
          .xcDevSetConfigByShadowServer(deviceId: deviceId, config: map);
      if (needShowTips) {
        KToast.dismiss();
        _showTipDialog(TR.current.TR_PowerSave_SuccessToShadow,
            onConfirm: () async {
          Navigator.of(context).pop();
        });
      }
    } catch (e) {
      if (needShowTips) {
        KToast.dismiss();
        KToast.show(status: kErrorMsg(e));
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) Navigator.of(context).pop();
        });
      }
    }
  }

  refreshData() {
    if (model == null) {
      return;
    }

    if (model!.supportMods.contains(0)) {
      enableTriggerMode == true;
    }
    if (model!.supportMods.contains(1)) {
      enableImageTransMode == true;
    }
    if (model!.supportMods.contains(2)) {
      enableMonitorMode == true;
    }
    if (model!.supportMods.contains(3)) {
      enableSentinelMode = true;
    }
    if (model!.supportMods.contains(4)) {
      enableMonitorModeSelTime = true;
    }

    if (model!.mode != -1) {
      currentMode = DoorLockSavePowerModeType.from(model!.mode);
      if (currentMode == DoorLockSavePowerModeType.monitorMode &&
          enableMonitorModeSelTime) {
        currentMode = DoorLockSavePowerModeType.monitorCustomMode;
      }
    }

    var delayMap = model!.param.isNotEmpty ? model!.param.first : null;
    if (delayMap != null) {
      delay = MapParser.queryInt(delayMap, 'Delay', 0);
      if (delay == 0) {
        delay = enableMonitorMode ? 300 : 180;
      }
    }

    var guardPeriod =
        model!.guardPeriods.isNotEmpty ? model!.guardPeriods.first : null;
    if (guardPeriod != null) {
      var start = MapParser.queryString(guardPeriod, 'Start', '');
      var end = MapParser.queryString(guardPeriod, 'End', '');
      monitorModeStart = DateFormat('HH:mm:ss').parse(start, true).toLocal();
      monitorModeEnd = DateFormat('HH:mm:ss').parse(end, true).toLocal();
    }

    notifyListeners();
  }

  changeCurrentMode(DoorLockSavePowerModeType mode) {
    currentMode = mode;
    notifyListeners();
  }

  ///选择触发模式时间
  selectTriggerModeMin() async {
    var result = await Navigator.of(context).push<int>(MaterialPageRoute(
        builder: (context) =>
            DoorLockSavePowerSelectTimePage(originDelay: delay)));
    if (result is int) {
      delay = result;
      notifyListeners();
    }
  }

  ///选择监控模式时间段
  selectMonitorModeDuration() async {
    var start = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(monitorModeStart));
    if (start == null || !context.mounted) return;
    var end = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(monitorModeEnd));
    if (end == null) return;

    monitorModeStart =
        DateTime(DateTime.now().year, 1, 1, start.hour, start.minute);
    monitorModeEnd = DateTime(DateTime.now().year, 1, 1, end.hour, end.minute);
    notifyListeners();
  }

  ///保存
  save() async {
    if (model == null) {
      return;
    }
    try {
      model!.mode = currentMode.value;
      model!.param.first['Value'] = currentMode.value;

      if (currentMode == DoorLockSavePowerModeType.triggerMode) {
        model!.param.first['Delay'] = delay;
      }

      if (currentMode == DoorLockSavePowerModeType.monitorCustomMode) {
        model!.guardPeriods.first['Start'] =
            DateFormat('HH:mm:ss').format(monitorModeStart.toUtc());
        model!.guardPeriods.first['End'] =
            DateFormat('HH:mm:ss').format(monitorModeEnd.toUtc());
      }

      if (device.state > 0 && device.sleepState != DeviceSleepState.deepSleep) {
        if (await beforeNetIp() == false) {
          await saveShadow();
          return;
        }
        saveShadow(needShowTips: false);

        KToast.show();
        var reuslt = await DoorLockNetIp.saveSystemSleep(
            model: model!, deviceId: deviceId);
        KToast.dismiss();
        if (reuslt.item1) {
          KToast.show(status: TR.current.saveSuccess);
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) Navigator.of(context).pop();
          });
        } else {
          KToast.show(status: kErrorMsg(reuslt.item2));
        }
      } else {
        await saveShadow();
      }
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  ///统一提示弹窗，确认后执行回调
  _showTipDialog(String message, {VoidCallback? onConfirm}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onConfirm?.call();
                },
                child: Text(TR.current.save),
              ),
            ],
          );
        });
  }
}
