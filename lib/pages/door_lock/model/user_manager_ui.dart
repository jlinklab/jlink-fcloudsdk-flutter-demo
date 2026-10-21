import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:flutter/material.dart';

///门锁首页“用户管理”入口 UI 模型
class UserManagerUI {
  final JvssOperateType type;

  UserManagerUI({required this.type});

  ///入口图标
  IconData get icon {
    switch (type) {
      case JvssOperateType.password:
        return Icons.password;
      case JvssOperateType.card:
        return Icons.credit_card;
      case JvssOperateType.skin:
        return Icons.fingerprint;
      case JvssOperateType.tmpPassword:
        return Icons.timelapse;
      case JvssOperateType.electronicKey:
        return Icons.vpn_key;
      case JvssOperateType.palmprint:
        return Icons.pan_tool;
      case JvssOperateType.palmVein:
        return Icons.bloodtype;
      case JvssOperateType.fingervein:
        return Icons.touch_app;
      case JvssOperateType.face:
        return Icons.face;
      case JvssOperateType.settings:
        return Icons.settings;
      case JvssOperateType.accessory:
        return Icons.battery_charging_full;
      case JvssOperateType.operateRecord:
        return Icons.history;
      case JvssOperateType.humanDetect:
        return Icons.person_search;
      default:
        return Icons.help_outline;
    }
  }

  ///入口名称
  String get name {
    switch (type) {
      case JvssOperateType.password:
        return '密码';
      case JvssOperateType.card:
        return '卡片';
      case JvssOperateType.skin:
        return '指纹';
      case JvssOperateType.tmpPassword:
        return '临时密码';
      case JvssOperateType.electronicKey:
        return '电子钥匙';
      case JvssOperateType.palmprint:
        return '掌纹';
      case JvssOperateType.palmVein:
        return '掌静脉';
      case JvssOperateType.fingervein:
        return '指静脉';
      case JvssOperateType.face:
        return '人脸';
      case JvssOperateType.settings:
        return '设置';
      case JvssOperateType.accessory:
        return '配件';
      case JvssOperateType.operateRecord:
        return '操作记录';
      case JvssOperateType.humanDetect:
        return '人形侦测';
      default:
        return '未知';
    }
  }
}
