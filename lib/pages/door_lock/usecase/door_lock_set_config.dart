import 'dart:convert';

import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_parse.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk/utils/log_util.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

///锁具配置读取、写入与同步
mixin DoorLockSetConfigMixin on DoorLockOperationMixin {
  bool get supportConfigByWifiTrans =>
      device.doorFunction?.localAbilityMask?.byte1
          .supportWifiTransSettingsGetAndSet ??
      false;

  ///读取锁端配置，返回几维协议十六进制字符串数组
  Future<Tuple2<List<String>, dynamic>> getDoorLockConfig() async {
    Future<Tuple2<List<String>, dynamic>> sendByBlue() async {
      if (!await ensureBleReadyForCommand()) {
        return const Tuple2([], null);
      }
      try {
        final result = await doorLockBleApi?.getDoorLockAllConfig();
        return Tuple2(parseBleDeviceInfoToRaw(result), result);
      } catch (e) {
        LogUtils.doorLock.log('getDoorLockConfig sendByBlue error: $e');
        return const Tuple2([], null);
      }
    }

    Future<Tuple2<List<String>, dynamic>> sendByNetIp() async {
      if (!await beforeNetIp(
        showLoading: false,
        needKeepAlive: false,
        showErrorTip: false,
        showAnotherOperatingTip: false,
      )) {
        return const Tuple2([], null);
      }

      try {
        if (supportConfigByWifiTrans) {
          final result =
              await DoorLockNetIpWifiTransExtSetConfig.getDoorLockAllConfig(
                  deviceId);
          if (!result.item1) return Tuple2([], result);
          final rawStr = result.item2?.data['RawData']?.toString() ?? '';
          if (rawStr.isEmpty) return Tuple2([], result);
          final rawList =
              parseWifiTransConfigToRaw(bytesToHex(base64Decode(rawStr)));
          return Tuple2(rawList, result);
        }

        final result = await DoorLockNetIp.getDoorLockConfig(deviceId);
        if (!result.item1 || result.item2 == null) {
          return Tuple2([], result);
        }
        return Tuple2(parseWifiConfigToRaw(result.item2?.data), result);
      } catch (e) {
        LogUtils.doorLock.log('getDoorLockConfig sendByNetIp error: $e');
        return const Tuple2([], null);
      }
    }

    if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi) {
      return sendByNetIp();
    }
    if (device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
      return sendByBlue();
    }
    if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue) {
      return await isBlueSwitchOn ? sendByBlue() : sendByNetIp();
    }
    if (DoorLockHelper.isLowPowerBle(deviceId) ||
        DoorLockHelper.isOverSeaDoorLock(deviceId)) {
      if (await waitBleOnline()) return sendByBlue();
    }
    return const Tuple2([], null);
  }

  ///读取在线配置和锁端实际配置，优先使用锁端数据并回传差异
  Future<DoorLockSetConfig?> syncLatestSetConfig() async {
    var keepAliveOk = true;
    final status = device.doolockCmdStatus;
    final useNetIp = status == DoolockCmdStatus.onlyWifi ||
        (status == DoolockCmdStatus.wifiAndBlue && !await isBlueSwitchOn);
    if (useNetIp) {
      keepAliveOk = await beforeNetIp(
        showLoading: false,
        showAnotherOperatingTip: false,
        showErrorTip: false,
      );
    }

    final onlineRawList =
        await DoorLockHelper.instance.queryOnlineCongfig(deviceId);
    var latestRawList = onlineRawList;
    if (!keepAliveOk && (latestRawList == null || latestRawList.isEmpty)) {
      return null;
    }

    var deviceConfig = keepAliveOk
        ? await getDoorLockConfig()
        : const Tuple2<List<String>, dynamic>(<String>[], null);
    if (keepAliveOk && deviceConfig.item1.isEmpty) {
      deviceConfig = await getDoorLockConfig();
    }

    if (deviceConfig.item1.isNotEmpty) {
      final needUpload = onlineRawList
              ?.toSet()
              .difference(deviceConfig.item1.toSet())
              .isNotEmpty ??
          true;
      if (needUpload) {
        await DoorLockHelper.instance
            .saveOnlineConfig(deviceId, deviceConfig.item1);
      }
      latestRawList = deviceConfig.item1;
    }

    if (latestRawList == null || latestRawList.isEmpty) return null;
    return parseRawToSetConfig(latestRawList);
  }

  Future<_ConfigWriteResult> _sendByBlue(Future<bool> Function() write) async {
    if (!await ensureBleReadyForCommand()) {
      return const _ConfigWriteResult(false, error: '蓝牙连接失败，请稍后重试');
    }
    try {
      final success = await write();
      return _ConfigWriteResult(success, error: success ? null : '设置失败');
    } catch (e) {
      LogUtils.doorLock.log('set config sendByBlue error: $e');
      return _ConfigWriteResult(false, error: kErrorMsg(e));
    }
  }

  Future<_ConfigWriteResult> _sendByNetIp(
      Future<Tuple3<bool, DoorLockNetIpResponse?, dynamic>> Function()
          write) async {
    if (!await beforeNetIp(
      showLoading: false,
      showErrorTip: false,
      showAnotherOperatingTip: false,
    )) {
      return _ConfigWriteResult(
        false,
        error: lastNetIpSyncError != null
            ? kErrorMsg(lastNetIpSyncError)
            : '设备保活失败，请稍后重试',
      );
    }
    try {
      final result = await write();
      if (result.item1) return const _ConfigWriteResult(true);
      if (result.item2?.err == DoorLockNetIpOperaterResult.needSync) {
        return const _ConfigWriteResult(false, needSync: true);
      }
      return _ConfigWriteResult(
        false,
        error: result.item3 != null
            ? kErrorMsg(result.item3)
            : '设置失败：${result.item2?.err ?? '未知错误'}',
      );
    } catch (e) {
      LogUtils.doorLock.log('set config sendByNetIp error: $e');
      return _ConfigWriteResult(false, error: kErrorMsg(e));
    }
  }

  Future<bool> _writeConfig({
    required Future<bool> Function() ble,
    required Future<Tuple3<bool, DoorLockNetIpResponse?, dynamic>> Function()
        netIp,
  }) async {
    KToast.show();
    _ConfigWriteResult result;
    try {
      if (device.doolockCmdStatus == DoolockCmdStatus.onlyWifi) {
        result = await _sendByNetIp(netIp);
      } else if (device.doolockCmdStatus == DoolockCmdStatus.onlyBlue) {
        result = await _sendByBlue(ble);
      } else if (device.doolockCmdStatus == DoolockCmdStatus.wifiAndBlue) {
        result = await isBlueSwitchOn
            ? await _sendByBlue(ble)
            : await _sendByNetIp(netIp);
      } else if (DoorLockHelper.isLowPowerBle(deviceId) ||
          DoorLockHelper.isOverSeaDoorLock(deviceId)) {
        result = await waitBleOnline()
            ? await _sendByBlue(ble)
            : const _ConfigWriteResult(false, error: '设备不在附近，请靠近后重试');
      } else {
        result = const _ConfigWriteResult(false, error: '设备离线，请稍后重试');
      }
    } catch (e) {
      LogUtils.doorLock.log('set config error: $e');
      result = _ConfigWriteResult(false, error: kErrorMsg(e));
    }
    KToast.dismiss();

    if (result.needSync) {
      dealNeedSyncError();
      return false;
    }
    if (!result.success) {
      KToast.show(status: result.error ?? '设置失败');
    }
    return result.success;
  }

  void dealNeedSyncError() {
    final currentContext = pageContext;
    if (currentContext == null || !currentContext.mounted) return;
    showDialog(
      context: currentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('提示'),
        content: const Text('同步状态过期，请返回后重新进入锁具配置页。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  ///逗留侦测
  Future<bool> setPirConfig({required bool enable, required int value}) {
    return _writeConfig(
      ble: () async =>
          await doorLockBleApi?.setPirConfig(
            enable: enable ? 1 : 0,
            value: value,
          ) ==
          true,
      netIp: () => supportConfigByWifiTrans
          ? DoorLockNetIpWifiTransExtSetConfig.setPirConfig(
              deviceId,
              enable: enable,
              value: value,
            )
          : DoorLockNetIp.setPirConfig(
              deviceId: deviceId,
              enable: enable,
              value: value,
            ),
    );
  }

  ///人体感应
  Future<bool> setHumanSensor({required bool enable, required int value}) {
    return _writeConfig(
      ble: () async =>
          await doorLockBleApi?.setHumanSensor(
            enable: enable ? 1 : 0,
            value: value,
          ) ==
          true,
      netIp: () => supportConfigByWifiTrans
          ? DoorLockNetIpWifiTransExtSetConfig.setHumanSensorConfig(
              deviceId,
              enable: enable,
              value: value,
            )
          : DoorLockNetIp.setHumanSensor(
              deviceId: deviceId,
              enable: enable,
              value: value,
            ),
    );
  }

  Future<bool> setVolumeControl({required int level}) {
    return _writeConfig(
      ble: () async {
        final result = await doorLockBleApi?.setVolumeLevel(level: level);
        return result?.item1 == true;
      },
      netIp: () => DoorLockNetIp.setVolumeLevel(
        deviceId: deviceId,
        level: level,
      ),
    );
  }

  ///设置门锁语言
  Future<bool> setLanguage({required DoorLockLanguage language}) {
    return _writeConfig(
      ble: () async {
        final result = await doorLockBleApi?.setLanguage(language: language);
        return result?.item1 == true;
      },
      netIp: () => DoorLockNetIp.setLanguage(
        deviceId: deviceId,
        language: language,
      ),
    );
  }

  Future<bool> setFaceAlarmTone({required int isOpen}) {
    return _writeConfig(
      ble: () async {
        final result = await doorLockBleApi?.setFaceAlarmTone(isOpen: isOpen);
        return result?.item1 == true;
      },
      netIp: () => DoorLockNetIp.setFaceAlarmTone(
        deviceId: deviceId,
        isOpen: isOpen != 0,
      ),
    );
  }

  Future<bool> setAutoLock({required int value}) {
    return _writeConfig(
      ble: () async => await doorLockBleApi?.setAutoLock(value: value) == true,
      netIp: () => DoorLockNetIp.setAutoLock(
        deviceId: deviceId,
        value: value,
      ),
    );
  }

  Future<bool> setDeployDefense({required int isOpen}) {
    return _writeConfig(
      ble: () async {
        final result = await doorLockBleApi?.setDeployDefense(isOpen: isOpen);
        return result?.item1 == true;
      },
      netIp: () => DoorLockNetIp.setDeployDefense(
        deviceId: deviceId,
        isOpen: isOpen != 0,
      ),
    );
  }

  Future<bool> setUnlockMode({required int mode}) {
    return _writeConfig(
      ble: () async {
        final result = await doorLockBleApi?.setUnlockMode(mode: mode);
        return result?.item1 == true;
      },
      netIp: () => DoorLockNetIp.setUnlockMode(
        deviceId: deviceId,
        mode: mode,
      ),
    );
  }

  Future<bool> setUnlockDirection({required int direction}) {
    return _writeConfig(
      ble: () async {
        final result =
            await doorLockBleApi?.setUnlockDirection(direction: direction);
        return result?.item1 == true;
      },
      netIp: () => DoorLockNetIp.setUnlockDirection(
        deviceId: deviceId,
        direction: direction,
      ),
    );
  }

  ///电机扭矩 0小 1中 2大
  Future<bool> setMotorTorque({required int motorTorque}) {
    return _writeConfig(
      ble: () async {
        final result =
            await doorLockBleApi?.setMotorTorque(motorTorque: motorTorque);
        return result?.item1 == true;
      },
      netIp: () => DoorLockNetIp.setMotorTorque(
        deviceId: deviceId,
        motorTorque: motorTorque,
      ),
    );
  }

  Future<bool> setSupportReverseLock({required int isOpen}) {
    return _writeConfig(
      ble: () async {
        final result =
            await doorLockBleApi?.setSupportReverseLock(isOpen: isOpen);
        return result?.item1 == true;
      },
      netIp: () => DoorLockNetIpWifiTransExtSetConfig.setSupportReverseLock(
        deviceId: deviceId,
        isOpen: isOpen,
      ),
    );
  }

  ///禁用重置键
  Future<bool> setResetButton({required int isOpen}) {
    return _writeConfig(
      ble: () async {
        final result = await doorLockBleApi?.setResetButton(isOpen: isOpen);
        return result?.item1 == true;
      },
      netIp: () => DoorLockNetIpWifiTransExtSetConfig.setResetButton(
        deviceId: deviceId,
        isOpen: isOpen,
      ),
    );
  }

  ///门锁常开模式
  ///cmd: 半透传设置项内容（无长度前缀，SDK发送时统一包装）
  Future<bool> setNormalOpenMode({
    required bool isOpen,
    required bool isAllDay,
    required List<int> weekValue,
    required int startTime,
    required int endTime,
    required List<int> cmd,
  }) {
    return _writeConfig(
      ble: () async {
        final result = await doorLockBleApi?.setNormalOpenMode(
          isOpen: isOpen,
          isAllDay: isAllDay,
          weekValue: weekValue,
          startTime: startTime,
          endTime: endTime,
        );
        return result?.item1 == true;
      },
      netIp: () => DoorLockNetIp.setNormalOpenMode(
        deviceId: deviceId,
        cmd: cmd,
      ),
    );
  }

  ///门锁临时常开
  ///cmd: 半透传设置项内容（无长度前缀，SDK发送时统一包装）
  Future<bool> setTemporaryNormalOpenMode({
    required bool isOpen,
    required List<int> cmd,
  }) {
    return _writeConfig(
      ble: () async {
        final result = await doorLockBleApi?.setTemporaryNormalOpenMode(
          isOpen: isOpen ? 1 : 0,
        );
        return result?.item1 == true;
      },
      netIp: () => DoorLockNetIp.setTempOpenMode(
        deviceId: deviceId,
        cmd: cmd,
      ),
    );
  }
}

class _ConfigWriteResult {
  final bool success;
  final bool needSync;
  final String? error;

  const _ConfigWriteResult(
    this.success, {
    this.needSync = false,
    this.error,
  });
}
