import 'package:fcloudsdk/utils/log_util.dart';
import 'package:flutter/material.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/media/controller/media_controller.dart';
import 'package:fcloudsdk/media/controller/mixin/media_record_video_mixin.dart';
import 'package:fcloudsdk/media/controller/preview_media_controller.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/common/event.dart';
import 'package:fcloudsdk_example/event/event.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/manager/device_property_manager.dart';
import 'package:fcloudsdk_example/manager/idr_property_manager.dart';
import 'package:fcloudsdk_example/models/user_instance.dart';
import 'package:fcloudsdk_example/pages/device_ability/device_ability_manager.dart';
import 'package:fcloudsdk_example/pages/device_pwd_setting/device_pwd_find_back_page.dart';
import 'package:fcloudsdk_example/pages/device_setting/model/model.dart';
import 'package:fcloudsdk_example/views/toast/device_pwd_input.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

class MediaRealplayController extends ChangeNotifier {
  final BuildContext context;

  ///设备序列号
  final String deviceId;

  ///设备对象
  late Device device;

  late final PreviewMediaController mediaController;

  bool _isSupportBatteryInfo = false;

  int uploadHandle = -1;

  ///是否预览已经出图，进入页面时，直播起流之后，在收到[MediaStatus.playing]时
  ///可以更新设备能力级等，和设备交互
  bool hasRenderedPreview = false;

  MediaRealplayController({required this.context, required this.deviceId}) {
    device = DeviceManager.instance.getDevice(deviceId: deviceId)!;
    initMediaPlay();
    startPlay();
  }

  void startPlay() async {
    mediaController.startPreview();
  }

  void initMediaPlay() async {
    mediaController = PreviewMediaController(deviceId: deviceId);
    mediaController.addStatusListener((status) {
      if (status == MediaStatus.playing && hasRenderedPreview == false) {
        //等出图后再去请求别的，加快出图速度
        hasRenderedPreview = true;
        _startUploadData();
        eventBus.fire(PreviewRenderedEvent());
      }
    });
    mediaController.addErrorListener((code) {
      dealErrorCode(code);
    });
    mediaController.addListener(() {
      if (hasListeners) {
        notifyListeners();
      }
    });
    mediaController.snapshoEvent.listen((event) {
      if (event.controllerId != mediaController.controllerId) {
        return;
      }
      if (event.snapshotKey == 'preset') {
        return;
      }
      _handleSnapshotEvent(event);
    });
  }

  void _startUploadData() async {
    /// 是否支持GetBatteryInfo
    _isSupportBatteryInfo = await DeviceAbilityManager.getAbilityEnableIfNeed(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionGetBatteryInfo);

    // 上报电量或sd卡状态
    if (DevicePropertyManager.instance.isAOV(deviceId: deviceId) ||
        DevicePropertyManager.instance.isLowPower(deviceId: deviceId) ||
        _isSupportBatteryInfo) {
      uploadHandle = await IDRPropertyManager.instance
          .makeStartUploadProperty(deviceId: deviceId);
    }
  }

  void _handleSnapshotEvent(SnapshotCallback event) {
    if (event.code >= 0) {
      KToast.show(status: '抓图成功');
    } else {
      KToast.show(status: '抓图失败 $event.code');
    }
  }

  void dealErrorCode(int code) {
    if (code == -70106 || code == -70163 || code == -70203 || code == -70205) {
      //设备密码错误 需要重新输入
      showDialog(
          context: context,
          builder: (context) {
            return Material(
              color: Colors.black26,
              child: Center(
                child: DevicePwdInput(
                  deviceId: deviceId,
                  completion: (name, password) async {
                    Navigator.of(context).pop();
                    UserInfo.instance.saveDeviceInfo(deviceId, name, password);
                    await JFApi.xcDevice.xcSetLocalUserNameAndPwd(
                        deviceId: deviceId, userName: name, pwd: password);
                    mediaController.restart();
                  },
                  onFindPwd: () {
                    ///找回密码
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return DevicePwdFindBackPage(
                        deviceId: deviceId,
                      );
                    }));
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            );
          });
    } else {
      //其他的直接显示错误码
      KToast.show(status: kErrorMsg(code));
    }
  }

  Future<void> sleepIfNeed() async {
    //调休眠接口是不会给回调的
    await JFApi.xcDevice.xcDeviceSleep(deviceId: deviceId);
    var result = await JFApi.xcDevice.xcLoginOut(deviceId: deviceId);
    LogUtils.idr.log('低功耗设备是否休眠?=$result, deviceId=$deviceId');
  }

  @override
  void dispose() {
    mediaController.dispose();
    if (DevicePropertyManager.instance.isAOV(deviceId: deviceId) ||
        DevicePropertyManager.instance.isLowPower(deviceId: deviceId) ||
        _isSupportBatteryInfo) {
      IDRPropertyManager.instance
          .makeStopUploadProperty(deviceId: deviceId, handle: uploadHandle);
    }
    if (DevicePropertyManager.instance.isLowPower(deviceId: deviceId)) {
      //退出预览页就去休眠，登出设备（如果需要退出预览页xx秒再去休眠登出，需要自己加定时器）
      sleepIfNeed();
    }
    super.dispose();
  }
}
