import 'package:fcloudsdk_example/generated/l10n.dart';

/// 门锁类型
enum JFDoorLockType {
  /// 未知类型
  none,

  /// 全自动锁
  fullAuto,

  /// 半自动锁
  halfAuto,

  /// 呆锁
  normal,

  /// 把手锁
  handle,
}

/// 本机安全验证结果
enum LocalAuthResult {
  ///手机未设置锁屏凭据（无密码/指纹/人脸），未弹验证
  noCredential,

  ///验证通过
  passed,

  ///验证失败/取消/异常
  failed,
}

/// 省电模式类型
enum DoorLockSavePowerModeType {
  unknown(-1),

  ///触发模式
  triggerMode(0),

  ///图传模式
  imageTransMode(1),

  ///监控模式
  monitorMode(2),

  ///哨兵模式
  sentinelMode(3),

  ///监控自定义时段模式
  monitorCustomMode(4);

  final int value;
  const DoorLockSavePowerModeType(this.value);

  String toKey() {
    switch (this) {
      case DoorLockSavePowerModeType.triggerMode:
        return 'TriggerMode';
      case DoorLockSavePowerModeType.monitorMode:
        return 'MonitorModel';
      case DoorLockSavePowerModeType.imageTransMode:
        return 'ImageTransmissionMode';
      default:
        return '';
    }
  }

  String toStr() {
    switch (this) {
      case DoorLockSavePowerModeType.triggerMode:
        return TR.current.TR_Setting_Trigger_Mode;
      case DoorLockSavePowerModeType.monitorMode:
      case DoorLockSavePowerModeType.monitorCustomMode:
        return TR.current.TR_Setting_Monitor_Mode;
      case DoorLockSavePowerModeType.imageTransMode:
        return TR.current.TR_Setting_Image_Transmission_Mode;
      default:
        return '';
    }
  }

  static DoorLockSavePowerModeType fromKey(String value) {
    switch (value) {
      case 'TriggerMode':
        return DoorLockSavePowerModeType.triggerMode;
      case 'MonitorModel':
        return DoorLockSavePowerModeType.monitorMode;
      case 'ImageTransmissionMode':
        return DoorLockSavePowerModeType.imageTransMode;
      default:
        return DoorLockSavePowerModeType.unknown;
    }
  }

  static DoorLockSavePowerModeType from(int value) {
    return DoorLockSavePowerModeType.values.firstWhere((e) => e.value == value,
        orElse: () => DoorLockSavePowerModeType.unknown);
  }
}
