//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

// ignore_for_file: constant_identifier_names

import 'package:fcloudsdk/utils/string_utils.dart';
import 'package:fcloudsdk_example/models/device_model.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';

enum DeviceType {
  MONITOR(0, "0"),
  SOCKET(1, "1"),
  BULB(2, "2"),
  BULB_SOCKET(3, "3"),
  CAR(4, "4"),
  BEYE(5, "5"),
  SEYE(6, "6"),
  NSEYE(1, "601"),
  ROBOT(7, "7"),
  MOV(8, "8"),
  FEYE(9, "9"),
  FBULB(10, "10"),
  BOB(11, "11"),
  MUSIC_BOX(12, "12"),
  SPEAKER(13, "13"),
  LINKCENTERT(14, "14"),
  DASH_CAMERA(15, "15"),
  POWERSTRIP(16, "16"),
  FISH_FUN(17, "17"),
  DRIVE_BEYE(18, "18"),
  UFO(20, "20"),
  IDR(21, "21"),
  BULLET(22, "22"),
  DRUM(23, "23"),
  CAMERA(24, "24"),
  PEEPHOLE(26, "26"),
  DEV_CZ_IDR(286457857, "286457857"),
  EE_DEV_LOW_POWER(285409282, "285409282"),
  EE_DEV_DOORLOCK(286326823, "286326823"),
  EE_DEV_BULLET_EG(288423976, "288423976"),
  EE_DEV_BULLET_EC(288423977, "288423977"),
  EE_DEV_BULLET_EB(288423984, "288423984"),
  EE_DEV_DOORLOCK_V2(286326833, "286326833"),
  EE_DEV_SMALL_V(286326834, "286326834"),
  EE_DEV_DOORLOCK_PEEPHOLE(286326835, "286326835"),
  EE_DEV_XIAODING(286326836, "286326836"),
  EE_DEV_SMALL_V_2(286326837, "286326837"),
  EE_DEV_BULLET_ESC_WB3F(286326838, "286326838"),
  EE_NO_NETWORK_BULLET(288423991, "288423991"),
  EE_DEV_ESC_WY3(286326840, "286326840"),
  EE_DEV_ESC_WR3F(286326841, "286326841"),
  EE_DEV_ESC_WR4F(286326848, "286326848"),
  EE_DEV_K_FEED(288424001, "288424001"),
  EE_DEV_B_FEED(288424002, "288424002"),
  EE_DEV_C_FEED(288424003, "288424003"),
  EE_DEV_F_FEED(288424004, "288424004"),
  EE_DEV_CAT(288424005, "288424005"),
  EE_DEV_WBS(305201153, "305201153"),
  EE_DEV_WNVR(305201154, "305201154"),
  EE_DEV_WBS_IOT(305201155, "305201155"),
  PID_T_PET_FEED("HAPFR0001000100R", "HAPFR0001000100R"),
  PID_T_DOOR_BELL_B("HADBL0002000100B", "HADBL0002000100B"),
  PID_T_DOOR_BELL_P("HADBL0016000100F", "HADBL0016000100F"),
  PID_T_DOOR_BELL_LX("HADBL00170001007", "HADBL00170001007"),
  PID_T_DOOR_LOCK_LX("HAVLS0011000100A", "HAVLS0011000100A"),
  PID_T_DOOR_LOCK_LX_100E("HAVLS0016000100E", "HAVLS0016000100E"),
  PID_T_DOOR_LOCK_LX_CS_AC1003("HAVLS00180001007", "HAVLS00180001007"),
  PID_T_DOOR_LOCK_LX_4D5_LCD("HAVLS0017000100F", "HAVLS0017000100F"),
  PID_T_DOOR_LOCK_LX_100B("HAVLS0021000100B", "HAVLS0021000100B"),
  PID_T_DOOR_LOCK_LX_P("HAVLS001E000100P", "HAVLS001E000100P"),
  PID_T_DOOR_LOCK_LX_BK("HAVLS001D0001004", "HAVLS001D0001004"),
  PID_T_DOOR_LOCK_LX_B("HAVLS0012000100B", "HAVLS0012000100B"),
  PID_T_DOOR_LOCK_LX_C("HAVLS0013000100C", "HAVLS0013000100C"),
  PID_T_SOCKET("ECSKT0003000100Z", "ECSKT0003000100Z"),
  PID_T_SOCKET_SUM("ECSKT00050001009", "ECSKT00050001009"),
  PID_T_SOCKET_XBT("ECSKT0020000100Y", "ECSKT0020000100Y"),
  PID_T_SOCKET_XBT_SUM("ECSKT0021000100Z", "ECSKT0021000100Z"),
  PID_T_DOOR_LOCK("HAVLS0008000100F", "HAVLS0008000100F"),
  PID_T_LIGHT("LTLSE0004000100G", "LTLSE0004000100G"),
  PID_T_MULTI_SOCKET("ECSKT0012000100Z", "ECSKT0012000100Z"),
  PID_T_MULTI_SOCKET_SUM("ECSKT0011000100Y", "ECSKT0011000100Y"),
  PID_T_MULTI_SOCKET_FIVE_WAY("ECSKT0007000100B", "ECSKT0007000100B"),
  PID_XBT_MULTI_SOCKET("ECSKT0026000100C", "ECSKT0026000100C"),
  PID_XBT_MULTI_SOCKET_SUM("ECSKT00270001008", "ECSKT00270001008"),
  PID_T_PANEL("ECSWH00100001001", "ECSWH00100001001"),
  PID_T_PANEL_ONE("ECSWH00130001000", "ECSWH00130001000"),
  PID_T_PANEL_TWO("ECSWH00140001009", "ECSWH00140001009"),
  PID_T_PANEL_THREE("ECSWH0006000100A", "ECSWH0006000100A"),
  PID_VIDEO_FEED("HAPFR0029000100Y", "HAPFR0029000100Y"),
  PID_VIDEO_FEED_IDR("HAPFR20000001003", "HAPFR20000001003"),
  PID_XM_530_FEED("HAPFR0022000100T", "HAPFR0022000100T"),
  PID_XM_530_FEED_100U("HAPFRV300000100U", "HAPFRV300000100U"),
  PID_XM_DOUBLE_530_FEED_100("HAPFRV6500001000", "HAPFRV6500001000"),
  PID_XM_DOUBLE_530_FEED_100_DUDU("HAPFRX535000000B", "HAPFRX535000000B"),
  PID_XM_530_FEED_300W("HAPFR0030000100S", "HAPFR0030000100S"),
  PID_XM_530_FEED_100T("HAPFRV200000100T", "HAPFRV200000100T"),
  PID_XM_530_FEED_FISH_100O("HAPFRFISH000000O", "HAPFRFISH000000O"),
  PID_XM_650_V200_DOOR_LOCK("HAVLS00090001007", "HAVLS00090001007"),
  PID_XM_650_V200_DOOR_LOCK_PRO("HAVLS00100001009", "HAVLS00100001009"),
  PID_XM_650_V200_DOOR_LOCK_PRO2("HAVLK00080001000", "HAVLK00080001000"),
  PID_BLE_VIDEO_LOCK("HAVLK0002000100V", "HAVLK0002000100V"),
  PID_USB_SINGLE_SHOT_DOOR_LOCK("HAVLS00140001008", "HAVLS00140001008"),
  PID_USB_DOUBLE_SHOT_DOOR_LOCK("HAVLS0015000100D", "HAVLS0015000100D"),
  PID_USB_DOUBLE_SHOT_DOOR_LOCK_100C("HAVLS0022000100C", "HAVLS0022000100C"),
  PID_SMART_DOOR_LOCK_AHD("HAVLS001A000100M", "HAVLS001A000100M"),
  PID_DOOR_LOCK_LX_CAT("HAVLS001C000100O", "HAVLS001C000100O"),
  PID_XM_650_DOOR_LOCK("HAVLK00090001009", "HAVLK00090001009"),
  PID_BLE_DOOR_LOCK("HABLK0012000100H", "HABLK0012000100H"),
  PID_BLE_DOOR_LOCK_100I("HABLK0013000100I", "HABLK0013000100I"),
  PID_BLE_DOOR_LOCK_1006("HABLK00140001006", "HABLK00140001006"),
  PID_BK_OVERSEA_VIDEO_LOCK("HAVLK001X0001001", "HAVLK001X0001001"),
  PID_BK_OVERSEA_NONE_VIDEO_LOCK("HAVLK0020000100V", "HAVLK0020000100V"),
  PID_LX_WB3S_PET_FEED("HAPFR0023000100U", "HAPFR0023000100U"),
  PID_T_PET_FEED_OLD("hapfr0001000100c", "hapfr0001000100c"),
  PID_XM_TRADITIONAL_CAMERA("A908009P6000000G", "A908009P6000000G"),
  PID_XM_TRADITIONAL_CAMERA_DL("A908007B90000001", "A908007B90000001"),
  JFT_IPC_SDK("JPIPCCT00000100H", "JPIPCCT00000100H"),
  PID_XM_TRADITIONAL_BULLET_DL("A908007C1000000S", "A908007C1000000S"),
  PID_XM_TRADITIONAL_BULLET_DL_E("A908007CB000000E", "A908007CB000000E"),
  PID_XM_TRADITIONAL_BULLET_DL_H("A908007CF000000H", "A908007CF000000H"),
  PID_XBT_WB2L_LIGHT("LTLSE0024000100I", "LTLSE0024000100I"),
  PID_DIY_CAMERA("ECVTL10000001009", "ECVTL10000001009"),
  PID_LX_WB2L_STRIP_LIGHT("LTSLT0025000100U", "LTSLT0025000100U"),
  PID_XY_GATEWAY("GWZTHLLID000000J", "GWZTHLLID000000J"),
  PID_Lx_S302_Iot_Feed("HAPFR20000001003", "HAPFR20000001003"),
  PID_DuDu_Photo_Feed("HAPFRES30000100G", "HAPFRES30000100G"),
  PID_DuDu_WiFi_Feed("HAPFRES00000100E", "HAPFRES00000100E"),
  PID_DuDu_Single_Vertical_Feed("HAPFRM533000100T", "HAPFRM533000100T"),
  PID_DuDu_Double_Land_Feed("HAPFRV35D0001005", "HAPFRV35D0001005"),
  PID_Dudu_Protol_Double("HAPFRT203000100U", "HAPFRT203000100U"),
  PID_ROBOT("HAPRBAI00000000R", "HAPRBAI00000000R");

  final Object code;
  final String pid;

  String getPid() {
    return pid;
  }

  const DeviceType(this.code, this.pid);
}

///设备功能跳转枚举
enum DeviceLocalUIKeyType {
  /// IOT门铃
  IOT_DOORBELL("ui_doorbell"),

  /// IOT门锁
  IOT_DOORLOCK("ui_doorlock"),

  /// 新门锁页面
  NEW_DOORLOCK_HOME("ui_doorlock_home"),

  /// 纯蓝牙锁
  BLUE_TOOTH_DOORLOCK("ui_doorlock_ctrl"),

  /// 蓝牙视频呆锁新界面
  BLUE_TOOTH_DOORLOCK_HOME("ui_doorlock_ctrl_home"),

  /// 不带视频(猫眼)的海外锁
  BK100W_NoVideo("ui_doorlock_ctrl_home_no_video"),

  /// DIY摄像头
  DIY_CAMERA("ui_ctrl_camera"),

  /// 普通摄像机
  CAMERA("ui_camera"),

  /// 不可视喂食器
  NO_VIDEO_FEED("ui_feed_no_video"),

  /// 可视喂食器(默认竖屏)
  VIDEO_PET_FEED("ui_feed_have_video"),

  /// 可视喂食器(横屏)
  VIDEO_PET_FEED_H("ui_feed_have_video_h"),

  /// 喂鱼器
  VIDEO_FISH_FEED("ui_feed_fish_have_video"),

  /// 嘟嘟喂食器
  DUDU_FEED("ui_feed_dudu"),

  /// 宠物机器人
  IOT_ROBOT("ui_robot"),

  /// 猫砂盆
  Cat_Toilet("ui_Cat_Toilet");

  final String type;

  const DeviceLocalUIKeyType(this.type);

  String getType() {
    return type;
  }
}

class DeviceTypeUtil {
  ///是否iot设备
  static bool isIOT(String? pid) {
    if (pid == null) {
      return false;
    }
    if (pid.length > 10) {
      return true;
    }
    return false;
  }

  ///是否是普通喂食器
  static bool isPetFeed(Device? device) {
    return isVideoPetFeed(device) ||
        isInvisiblePetFeed(device) ||
        isFishPetFeed(device);
  }

  /// 是否为可视喂食器
  ///
  /// @param resp 设备信息
  /// @return
  static bool isVideoPetFeed(Device? device) {
    if (device == null) {
      return false;
    }

    if (StringUtils.contrastIgnoreCase(
            device.parentPid, DeviceType.EE_DEV_K_FEED.getPid()) ||
        StringUtils.contrastIgnoreCase(
            device.parentPid, DeviceType.EE_DEV_B_FEED.getPid()) ||
        //PID_LX_WB3S_PET_FEED
        StringUtils.contrastIgnoreCase(
            device.parentPid, DeviceType.EE_DEV_C_FEED.getPid()) ||
        StringUtils.contrastIgnoreCase(
            device.parentPid, DeviceType.EE_DEV_F_FEED.getPid()) ||
        StringUtils.contrastIgnoreCase(
            device.localUiKey, DeviceLocalUIKeyType.VIDEO_PET_FEED.getType()) ||
        StringUtils.contrastIgnoreCase(device.localUiKey,
            DeviceLocalUIKeyType.VIDEO_PET_FEED_H.getType()) ||
        isXM530VideoPetFeed(device.parentPid ?? '') ||
        isVideoPortraitPetFeed(device.parentPid ?? '') ||
        isXM530300WVideoFishFeedByPid(device.parentPid ?? '')) {
      return true;
    }
    return false;
  }

  /// 是否机器人判断，通过localUiKey和parentPid判断
  static bool isRobotDevice(Device? device) {
    if (device == null) {
      return false;
    }
    if (StringUtils.contrastIgnoreCase(
            device.localUiKey, DeviceLocalUIKeyType.IOT_ROBOT.getType()) ||
        StringUtils.contrastIgnoreCase(
            device.parentPid, DeviceType.PID_ROBOT.getPid())) {
      return true;
    }
    return false;
  }

  /// 是否是300w喂鱼器（支持串口，不支持麦克风和喇叭，最大喂食份数是20份）
  ///
  /// @return
  static bool isXM530300WVideoFishFeedByPid(String pid) {
    if (StringUtils.contrastIgnoreCase(
        pid, DeviceType.PID_XM_530_FEED_FISH_100O.getPid())) {
      return true;
    }
    return false;
  }

  /// 是否为竖屏可视喂食器
  ///
  /// @param parentPid 主pid
  /// @return
  static bool isVideoPortraitPetFeed(String parentPid) {
    return StringUtils.contrastIgnoreCase(
            parentPid, DeviceType.PID_VIDEO_FEED.getPid()) ||
        StringUtils.contrastIgnoreCase(
            parentPid, DeviceType.PID_VIDEO_FEED_IDR.getPid());
  }

  ///特殊喂食器退出预览不需要休眠，否则RPS设备状态会变为离线
  ///pid为HAPFR20000001003，或localUiKey为ui_feed_fish_have_video且属性包含wifiFeeder
  static bool isNotNeedSleepFeeder(Device? device) {
    if (device == null) {
      return false;
    }
    if (StringUtils.contrastIgnoreCase(
        device.parentPid, DeviceType.PID_Lx_S302_Iot_Feed.getPid())) {
      return true;
    }
    return StringUtils.contrastIgnoreCase(device.localUiKey,
            DeviceLocalUIKeyType.VIDEO_FISH_FEED.getType()) &&
        (device.propList?.contains('wifiFeeder') ?? false);
  }

  /// 是否为300w可视喂食器（支持卡存）(喂食份数最大6份)
  ///
  /// @param parentPid 主pid
  /// @return
  static bool isXM530300WVideoPetFeed(String parentPid) {
    if (StringUtils.contrastIgnoreCase(
            parentPid, DeviceType.PID_XM_530_FEED_300W.getPid()) ||
        StringUtils.contrastIgnoreCase(
            parentPid, DeviceType.PID_XM_530_FEED_100T.getPid())) {
      return true;
    }
    return false;
  }

  /// 是否为XM530-可视喂食器（特殊配置）
  ///
  /// @param parentPid 主pid
  /// @return
  static bool isXM530VideoPetFeed(String parentPid) {
    if (StringUtils.contrastIgnoreCase(
            parentPid, DeviceType.PID_XM_530_FEED.getPid()) ||
        StringUtils.contrastIgnoreCase(
            parentPid, DeviceType.PID_XM_530_FEED_100U.getPid()) ||
        StringUtils.contrastIgnoreCase(
            parentPid, DeviceType.PID_XM_530_FEED_100T.getPid()) ||
        StringUtils.contrastIgnoreCase(
            parentPid, DeviceType.PID_XM_530_FEED_300W.getPid()) ||
        StringUtils.contrastIgnoreCase(
            parentPid, DeviceType.PID_XM_DOUBLE_530_FEED_100.getPid())) {
      return true;
    }
    return false;
  }

  /// 是否为双目喂食器
  ///
  /// @param parentPid 主pid
  /// @return
  static bool isXM530VideoDoubleEyePetFeed(String parentPid) {
    if (StringUtils.contrastIgnoreCase(
            parentPid, DeviceType.PID_XM_DOUBLE_530_FEED_100.getPid()) ||
        StringUtils.contrastIgnoreCase(
            parentPid, DeviceType.PID_XM_DOUBLE_530_FEED_100_DUDU.getPid())) {
      return true;
    }
    return false;
  }

  static bool isInvisiblePetFeed(Device? device) {
    if (device == null) {
      return false;
    }
    if (StringUtils.contrastIgnoreCase(
            device.parentPid, DeviceType.PID_T_PET_FEED.getPid()) ||
        StringUtils.contrastIgnoreCase(
            device.parentPid, DeviceType.PID_LX_WB3S_PET_FEED.getPid()) ||
        StringUtils.contrastIgnoreCase(
            device.parentPid, DeviceType.PID_T_PET_FEED_OLD.getPid())) {
      return true;
    }
    return false;
  }

  /// 是否为喂鱼器
  static bool isFishPetFeed(Device? device) {
    if (device == null) {
      return false;
    }
    if (StringUtils.contrastIgnoreCase(
            device.parentPid, DeviceType.PID_XM_530_FEED_FISH_100O.getPid()) ||
        StringUtils.contrastIgnoreCase(device.localUiKey,
            DeviceLocalUIKeyType.VIDEO_FISH_FEED.getType())) {
      return true;
    }
    return false;
  }

  ///是否是可视控制器
  static bool isVisibleControlDevice(Device? device) {
    if (device == null) {
      return false;
    }
    if (StringUtils.contrastIgnoreCase(
        device.parentPid, DeviceType.PID_DIY_CAMERA.getPid())) {
      return true;
    }
    return false;
  }

  ///是否是低功耗设备
  static bool isSleepSateDevice(Device? device) {
    if (device == null) {
      return false;
    }
    if (StringUtils.contrastIgnoreCase(
            device.pid, DeviceType.PID_Lx_S302_Iot_Feed.getPid()) ||
        StringUtils.contrastIgnoreCase(
            device.pid, DeviceType.PID_BLE_VIDEO_LOCK.getPid()) ||
        StringUtils.contrastIgnoreCase(
            device.localUiKey, DeviceLocalUIKeyType.IOT_DOORBELL.getType()) ||
        StringUtils.contrastIgnoreCase(
            device.localUiKey, DeviceLocalUIKeyType.IOT_DOORLOCK.getType()) ||
        device.deviceType == DeviceType.IDR.code ||
        device.deviceType == DeviceType.EE_DEV_LOW_POWER.code ||
        DoorLockHelper.isDoorLock(device.uuid ?? "") ||
        (device.propList?.contains('sleepState') ?? false)) {
      return true;
    }
    return false;
  }

  ///无需主动调休眠的设备
  static bool noNeedActiveSleepDevice(Device? device) {
    if (device == null) {
      return false;
    }
    if (StringUtils.contrastIgnoreCase(
            device.localUiKey, DeviceLocalUIKeyType.NO_VIDEO_FEED.getType()) ||
        StringUtils.contrastIgnoreCase(
            device.parentPid, DeviceType.PID_Lx_S302_Iot_Feed.getPid()) ||
        isDuDuPetFeed(device) ||
        isInvisiblePetFeed(device)) {
      return true;
    }
    return false;
  }

  /// 是否是嘟嘟喂食器
  static bool isDuDuPetFeed(Device? device) {
    if (device == null) {
      return false;
    }
    if (StringUtils.contrastIgnoreCase(
            device.parentPid, DeviceType.PID_DuDu_Photo_Feed.getPid()) ||
        StringUtils.contrastIgnoreCase(
            device.parentPid, DeviceType.PID_DuDu_WiFi_Feed.getPid()) ||
        StringUtils.contrastIgnoreCase(device.parentPid,
            DeviceType.PID_DuDu_Single_Vertical_Feed.getPid()) ||
        StringUtils.contrastIgnoreCase(
            device.parentPid, DeviceType.PID_DuDu_Double_Land_Feed.getPid()) ||
        StringUtils.contrastIgnoreCase(
            device.localUiKey, DeviceLocalUIKeyType.DUDU_FEED.getType())) {
      return true;
    }
    return false;
  }

  /// 是否是嘟嘟视频款喂食器
  static bool isDuDuVideoPetFeed(String parentPid) {
    if (StringUtils.contrastIgnoreCase(
            parentPid, DeviceType.PID_DuDu_Single_Vertical_Feed.getPid()) ||
        StringUtils.contrastIgnoreCase(
            parentPid, DeviceType.PID_DuDu_Double_Land_Feed.getPid())) {
      return true;
    }
    return false;
  }

  /// 是否是嘟嘟协议款喂食器，协议是嘟嘟，跳转不是嘟嘟
  static bool isDuDuProtocalPetFeed(String parentPid) {
    if (StringUtils.contrastIgnoreCase(
        parentPid, DeviceType.PID_Dudu_Protol_Double.getPid())) {
      return true;
    }
    return false;
  }

  /// 是否是嘟嘟乐鑫款喂食器
  static bool isDuDuLXPetFeed(String parentPid) {
    if (StringUtils.contrastIgnoreCase(
        parentPid, DeviceType.PID_DuDu_Photo_Feed.getPid())) {
      return true;
    }
    return false;
  }

  /// 是否是嘟嘟拍照款喂食器
  static bool isDuDuPhotoPetFeed(String parentPid) {
    if (StringUtils.contrastIgnoreCase(
        parentPid, DeviceType.PID_DuDu_Photo_Feed.getPid())) {
      return true;
    }
    return false;
  }

  /// 是否是嘟嘟wifi款喂食器
  static bool isDuDuWifiPetFeed(String parentPid) {
    if (StringUtils.contrastIgnoreCase(
        parentPid, DeviceType.PID_DuDu_WiFi_Feed.getPid())) {
      return true;
    }
    return false;
  }

  ///获取喂食器最大喂食份数
  static int getPetFeedServingsCount(String pid) {
    if (isXM530300WVideoPetFeed(pid)) {
      return 6;
    } else if (isXM530300WVideoFishFeedByPid(pid)) {
      return 20;
    } else {
      return 12;
    }
  }
}

///iot 获取设备WiFi信号强度
class IotDeviceUtil {
  static int convertdBm2RSSI(int dBm) {
    int level = 0;
    if (dBm < 0 && dBm >= -40) {
      level = 100;
    } else if (dBm < -40 && dBm >= -50) {
      level = (dBm + 90) * 2;
    } else if (dBm < -50 && dBm >= -80) {
      level = dBm + 129;
    } else if (dBm < -80 && dBm >= -85) {
      level = (dBm + 96) * 3;
    } else if (dBm < -85 && dBm > -100) {
      level = (dBm + 100) * 2;
    } else if (dBm <= -100) {
      level = 0;
    }
    return level;
  }

  ///iot 获取设备网络是否是AP热点模式
  static bool connectDeviceHotSpot(String ssid) {
    if (ssid.startsWith('robot_') ||
        ssid.startsWith("card") ||
        ssid.startsWith("car_") ||
        ssid.startsWith("seye_") ||
        ssid.startsWith("NVR") ||
        ssid.startsWith("DVR") ||
        ssid.startsWith("beye_") ||
        ssid.startsWith("IPC") ||
        ssid.startsWith("ipc") ||
        ssid.startsWith("Car_") ||
        ssid.startsWith("BOB_") ||
        ssid.startsWith("xmjp_") ||
        ssid.startsWith("UTEC") ||
        ssid.startsWith("camera_") ||
        ssid.startsWith("Camera_") ||
        ssid.startsWith("dev_cz_idr") ||
        ssid.startsWith("drum_") ||
        ssid.startsWith("bullet_")) {
      return true;
    }

    return false;
  }
}
