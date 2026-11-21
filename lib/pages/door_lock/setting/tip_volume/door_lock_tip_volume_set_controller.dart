import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_set_config.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';

///音量选项：显示位与文案
class DoorLockVolumeOption {
  ///显示位：0静音 1低 2中 3高；两级音量锁板没有“中”，“高”占显示位2
  final int position;

  final String title;

  const DoorLockVolumeOption(this.position, this.title);
}

///提示音设置页控制器：室内门铃音量 + 门锁音量
class DoorLockTipVolumeSetController extends DoorLockPageController
    with DoorLockSetConfigMixin {
  @override
  final String deviceId;

  ///室内门铃音量 0-3
  int? bellVolume;

  ///门锁音量 0-3；null 表示还没读到真实档位，此时不选中任何选项
  int? lockVolume;

  bool _lockSaving = false;
  bool _writing = false;
  bool _disposed = false;

  DoorLockTipVolumeSetController({
    required super.context,
    required this.deviceId,
  }) {
    createDoorLockAPI();

    _loadBellVolume();

    if (isSupportLockVolume) {
      _syncLatestSetConfig();
    }
  }

  @override
  bool get keepBleConnectWhenDispose => false;

  @override
  bool get keepSyncWhenDispose => false;

  ///锁板是否支持音量控制
  bool get isSupportLockVolume =>
      device.doorLockBleAbility?.byte1.supportVolumeControl == true;

  ///两级音量锁板：只展示静音/低/高，显示位与设备档位不再一一对应
  bool get isTwoLevelsVolume =>
      (device.props ?? []).contains('TwoLevelsVolume');

  ///室内门铃音量选项
  List<DoorLockVolumeOption> get bellOptions => _options(withMiddle: true);

  ///门锁音量选项
  List<DoorLockVolumeOption> get lockOptions =>
      _options(withMiddle: !isTwoLevelsVolume);

  List<DoorLockVolumeOption> _options({required bool withMiddle}) => [
        DoorLockVolumeOption(0, TR.current.TR_Device_Volume_Mute),
        DoorLockVolumeOption(1, TR.current.TR_Settings_Level_Low),
        if (withMiddle)
          DoorLockVolumeOption(2, TR.current.TR_Settings_Level_Middle),
        DoorLockVolumeOption(
            withMiddle ? 3 : 2, TR.current.TR_Settings_Level_High),
      ];

  ///室内门铃音量选项是否选中
  bool bellSelected(int position) => bellVolume == position;

  ///门锁音量选项是否选中：还没读到真实档位时不选中任何选项
  bool lockSelected(int position) {
    var volume = lockVolume;
    if (volume == null) {
      return false;
    }
    return _volumeToDisplay(volume) == position;
  }

  ///显示位转设备档位：两级锁板的“高”占位2，设备档位为3
  int _displayToVolume(int position) =>
      isTwoLevelsVolume && position == 2 ? 3 : position;

  ///设备档位转显示位：两级锁板设备回2/3时显示位为档位减1
  int _volumeToDisplay(int volume) =>
      isTwoLevelsVolume && volume >= 2 ? volume - 1 : volume;

  ///读取室内门铃音量
  _loadBellVolume() async {
    KToast.show();
    var result = await DoorLockNetIp.getRearLockVolume(deviceId: deviceId);
    KToast.dismiss();
    if (_disposed) {
      return;
    }
    if (result.item1 != null) {
      bellVolume = result.item1;
    } else {
      KToast.show(
          status: result.item2 != null
              ? kErrorMsg(result.item2)
              : TR.current.TR_Common_Data_Get_Failed);
    }
    _notify();
  }

  ///同步最新锁具配置取门锁音量
  _syncLatestSetConfig() async {
    var latest = await syncLatestSetConfig();
    if (latest != null && latest.volumeControl != null) {
      lockVolume = latest.volumeControl!;
      _notify();
    }
  }

  ///修改室内门铃音量：先按选择刷新，失败不回滚
  changeBellVolume(int volume) async {
    if (bellVolume == volume || !_startSave()) {
      return;
    }
    bellVolume = volume;
    _notify();

    var result = await DoorLockNetIp.setRearLockVolume(
        deviceId: deviceId, volume: volume);
    _endSave(
      success: result.item1 == true,
      error: result.item2,
      failText: TR.current.TR_Ble_Doorlock_Voice_Update_Failed,
    );
  }

  ///修改门锁音量：写锁具配置，成功后回传服务器在线配置
  changeLockVolume(int position) async {
    if (_lockSaving || _disposed) {
      return;
    }
    var target = _displayToVolume(position);
    if (lockVolume == target) {
      return;
    }

    var old = lockVolume;
    lockVolume = target;
    _notify();

    _lockSaving = true;
    try {
      var ok = await setVolumeControl(level: target);
      if (ok) {
        _updateToJvss(target);
        if (!_disposed) {
          KToast.show(status: TR.current.TR_Common_Save_Success);
        }
      } else {
        lockVolume = old;
      }
    } catch (e) {
      lockVolume = old;
      debugPrint('changeLockVolume error: ${kErrorMsg(e)}');
    }
    _lockSaving = false;
    _notify();
  }

  ///门锁音量回传服务器在线配置（几维协议：03 05 档位）
  _updateToJvss(int level) async {
    try {
      await DoorLockHelper.instance.saveOnlineConfig(deviceId, [
        bytesToHex([3, 0x05, level])
      ]);
    } catch (e) {
      debugPrint('saveOnlineConfig error: ${kErrorMsg(e)}');
    }
  }

  ///开始一次保存：保存中不允许重复操作，不刷新视图以免其余条目闪动
  bool _startSave() {
    if (_writing || _disposed) {
      return false;
    }
    _writing = true;
    KToast.show();
    return true;
  }

  ///结束一次保存并提示结果
  _endSave({required bool success, dynamic error, String? failText}) {
    KToast.dismiss();
    _writing = false;
    if (!_disposed) {
      if (success) {
        KToast.show(status: TR.current.TR_Common_Save_Success);
      } else {
        KToast.show(status: error != null ? kErrorMsg(error) : failText);
      }
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
