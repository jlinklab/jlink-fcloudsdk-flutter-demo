import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_model.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';

///镜头反转条目：对应能力集里的一个镜头及其显示文案
class DoorLockScreenCameraItem {
  ///能力集中的镜头
  final CameraId camera;

  ///按镜头数量与内外/上下关系计算出的文案
  final String title;

  DoorLockScreenCameraItem({required this.camera, required this.title});
}

///屏幕设置页控制器：条目按猫眼能力集显隐，配置读写走设备系统配置通道
class DoorLockScreenSetPageSetController extends ChangeNotifier {
  final BuildContext context;

  final String deviceId;

  ///猫眼能力集
  final DoorLockCatEyeFunction? catEyeFunction;

  ///数据加载完成
  bool isReady = false;

  ///息屏时间
  int? shutDownValue;

  ///显示时间
  bool? showTimeTitle;

  ///显示更多（wifi，天气）
  bool? showExWidgets;

  ///其他屏幕设置
  DoorLockScreenConfig? screenConfig;

  ///是否有设置项正在保存
  bool _writing = false;

  ///控制器是否已销毁，销毁后不再刷新视图
  bool _disposed = false;

  ///镜头反转条目
  final List<DoorLockScreenCameraItem> _cameraItems = [];

  DoorLockScreenSetPageSetController({
    required this.context,
    required this.deviceId,
    required this.catEyeFunction,
  }) {
    _initCameraItems();
    _initData();
  }

  @override
  dispose() {
    _disposed = true;
    super.dispose();
  }

  ///保存中，禁止重复操作
  bool get writing => _writing;

  ///是否支持息屏时间
  bool get supportScreenShutDown => catEyeFunction?.screenShutDown == true;

  ///是否支持屏幕显示时间
  bool get supportShowTimeTitle => catEyeFunction?.showTimeTitle == true;

  ///是否支持屏幕显示更多
  bool get supportShowExWidgets => catEyeFunction?.showExWidgets == true;

  ///是否支持门铃亮屏
  bool get supportDoorbellScreenWakeOn =>
      catEyeFunction?.doorbellScreenWakeon == true;

  ///是否支持屏幕反转
  bool get supportScreenInvert => catEyeFunction?.screenInvert == true;

  ///是否支持镜头USB速度
  bool get supportVideoUsbSpeedMode =>
      catEyeFunction?.videoUsbSpeedMode == true;

  ///镜头反转条目列表
  List<DoorLockScreenCameraItem> get cameraItems => _cameraItems;

  ///高级设置分组是否有内容
  bool get hasAdvancedGroup =>
      supportShowTimeTitle ||
      supportShowExWidgets ||
      supportDoorbellScreenWakeOn;

  ///出厂设置分组是否有内容
  bool get hasFactoryGroup =>
      supportScreenInvert ||
      _cameraItems.isNotEmpty ||
      supportVideoUsbSpeedMode;

  ///息屏时间是否为选中值
  bool shutDownSelected(int value) => shutDownValue == value;

  ///息屏时间选项文案
  String shutDownOptionText(int value) =>
      '$value${TR.current.TR_Common_Second}';

  ///屏幕显示时间开关状态
  bool get showTimeTitleOn => showTimeTitle ?? false;

  ///屏幕显示更多开关状态
  bool get showExWidgetsOn => showExWidgets ?? false;

  ///门铃亮屏开关状态：设备侧存的是“门铃不亮屏”，显示需取反
  bool get wakeOn => screenConfig != null && !screenConfig!.wakeOnDisable;

  ///屏幕反转开关状态
  bool get screenInvertOn => screenConfig?.screenInvert ?? false;

  ///镜头USB速度是否为1.1
  bool get usbSpeedMode11 => screenConfig?.videoUSBSpeedMode == '1.1';

  ///指定镜头的反转状态
  bool cameraInvertOn(int cameraId) =>
      screenConfig?.getCameraId(cameraId)?.invert == true;

  ///按能力集逐项读取当前配置
  _initData() async {
    if (supportScreenShutDown) {
      var result =
          await DoorLockNetIp.getDoorLockScreenShutDown(deviceId: deviceId);
      if (_disposed) {
        return;
      }
      if (result.item1 != null) {
        shutDownValue = result.item1;
      } else if (result.item2 != null) {
        KToast.show(status: kErrorMsg(result.item2));
      }
    }

    if (supportShowTimeTitle || supportShowExWidgets) {
      var result = await DoorLockNetIp.getDesktopWidgets(deviceId: deviceId);
      if (_disposed) {
        return;
      }
      if (result.item1 != null) {
        showTimeTitle = result.item1;
      }
      if (result.item2 != null) {
        showExWidgets = result.item2;
      }
      if (result.item3 != null) {
        KToast.show(status: kErrorMsg(result.item3));
      }
    }

    if (supportDoorbellScreenWakeOn ||
        supportScreenInvert ||
        supportVideoUsbSpeedMode ||
        (catEyeFunction?.camsRotate.length ?? 0) > 0) {
      var result =
          await DoorLockNetIp.getDoorLockScreenConfig(deviceId: deviceId);
      if (_disposed) {
        return;
      }
      if (result.item1 != null) {
        screenConfig = result.item1;
      } else if (result.item2 != null) {
        KToast.show(status: kErrorMsg(result.item2));
      }
    }

    isReady = true;
    _notify();
  }

  ///生成镜头反转条目与文案
  _initCameraItems() {
    _cameraItems.clear();
    var cams = catEyeFunction?.camsRotate ?? [];
    if (cams.isEmpty || cams.length > 3) {
      ///超过3个镜头的机型目前不存在
      return;
    }

    ///单镜头：一定是单摄，显示一个镜头反转开关
    if (cams.length == 1) {
      _cameraItems.add(DoorLockScreenCameraItem(
        camera: cams[0],
        title: TR.current.TR_DoorLock_Single_Camera_Invert,
      ));
      return;
    }

    ///双镜头：相同内外即是上下关系，不同即是内外关系
    if (cams.length == 2) {
      _cameraItems.addAll([
        DoorLockScreenCameraItem(
          camera: cams[0],
          title: cams[0].isOutSideCams() == cams[1].isOutSideCams()
              ? _upOrDownCameraTitle(cams[0])
              : _insideOrOutsideCameraTitle(cams[0]),
        ),
        DoorLockScreenCameraItem(
          camera: cams[1],
          title: cams[1].isOutSideCams() == cams[0].isOutSideCams()
              ? _upOrDownCameraTitle(cams[1])
              : _insideOrOutsideCameraTitle(cams[1]),
        ),
      ]);
      return;
    }

    ///3个镜头：目前只可能是上下加一个门外或门内，按多数一方决定文案口径
    int outSideCamsNum = cams.where((e) => e.isOutSideCams()).length;
    for (var camera in cams) {
      _cameraItems.add(DoorLockScreenCameraItem(
        camera: camera,
        title: outSideCamsNum == 2
            ? (camera.isOutSideCams()
                ? _upOrDownCameraTitle(camera)
                : TR.current.TR_DoorLock_Inside_Camera_Invert)
            : (!camera.isOutSideCams()
                ? _upOrDownCameraTitle(camera)
                : TR.current.TR_DoorLock_Outside_Camera_Invert),
      ));
    }
  }

  ///上下镜头反转文案
  String _upOrDownCameraTitle(CameraId camera) => camera.isUpCams()
      ? TR.current.TR_DoorLock_Up_Camera_Invert
      : TR.current.TR_DoorLock_Down_Camera_Invert;

  ///内外镜头反转文案
  String _insideOrOutsideCameraTitle(CameraId camera) => camera.isOutSideCams()
      ? TR.current.TR_DoorLock_Outside_Camera_Invert
      : TR.current.TR_DoorLock_Inside_Camera_Invert;

  ///修改息屏时间
  changeShutDown(int target) async {
    if (!_startSave()) {
      return;
    }
    var result = await DoorLockNetIp.setDoorLockScreenShutDown(
        deviceId: deviceId, value: target);
    if (result.item1 == true) {
      shutDownValue = target;
    }
    _endSave(success: result.item1 == true, error: result.item2);
  }

  ///修改屏幕显示时间
  changeShowTime() async {
    if (!_startSave()) {
      ///保存中：开关已本地翻转，刷新一次回到实际值
      _notify();
      return;
    }
    var target = !(showTimeTitle ?? false);
    var result = await DoorLockNetIp.setDesktopWidgets(
        deviceId: deviceId,
        showTimeTitle: target,
        showExWidgets: showExWidgets ?? false);
    if (result.item1 == true) {
      showTimeTitle = target;
    }
    _endSave(success: result.item1 == true, error: result.item2);
  }

  ///修改屏幕显示更多
  changeShowExWidgets() async {
    if (!_startSave()) {
      ///保存中：开关已本地翻转，刷新一次回到实际值
      _notify();
      return;
    }
    var target = !(showExWidgets ?? false);
    var result = await DoorLockNetIp.setDesktopWidgets(
        deviceId: deviceId,
        showTimeTitle: showTimeTitle ?? false,
        showExWidgets: target);
    if (result.item1 == true) {
      showExWidgets = target;
    }
    _endSave(success: result.item1 == true, error: result.item2);
  }

  ///修改门铃亮屏
  changeWakeOn() async {
    if (screenConfig == null || !_startSave()) {
      ///配置未就绪或保存中：开关已本地翻转，刷新一次回到实际值
      _notify();
      return;
    }
    var target = !screenConfig!.wakeOnDisable;
    var result = await DoorLockNetIp.setDoorLockScreenConfig(
      deviceId: deviceId,
      config: DoorLockScreenConfig.copy(screenConfig!)..wakeOnDisable = target,
    );
    if (result.item1 == true) {
      screenConfig!.wakeOnDisable = target;
    }
    _endSave(success: result.item1 == true, error: result.item2);
  }

  ///修改屏幕反转
  changeScreenInvert() async {
    if (screenConfig == null || !_startSave()) {
      ///配置未就绪或保存中：开关已本地翻转，刷新一次回到实际值
      _notify();
      return;
    }
    var target = !screenConfig!.screenInvert;
    var result = await DoorLockNetIp.setDoorLockScreenConfig(
      deviceId: deviceId,
      config: DoorLockScreenConfig.copy(screenConfig!)..screenInvert = target,
    );
    if (result.item1 == true) {
      screenConfig!.screenInvert = target;
    }
    _endSave(success: result.item1 == true, error: result.item2);
  }

  ///修改指定镜头反转
  changeCameraInvert({required int cameraId}) async {
    if (screenConfig == null ||
        screenConfig!.getCameraId(cameraId) == null ||
        !_startSave()) {
      ///配置未就绪或保存中：开关已本地翻转，刷新一次回到实际值
      _notify();
      return;
    }
    var target = !(screenConfig!.getCameraId(cameraId)!.invert ?? false);
    var result = await DoorLockNetIp.setDoorLockScreenConfig(
      deviceId: deviceId,
      config: DoorLockScreenConfig.copy(screenConfig!)
        ..getCameraId(cameraId)!.invert = target,
    );
    if (result.item1 == true) {
      screenConfig!.getCameraId(cameraId)!.invert = target;
    }
    _endSave(success: result.item1 == true, error: result.item2);
  }

  ///修改镜头USB速度
  changeUSB() async {
    if (screenConfig == null || !_startSave()) {
      ///配置未就绪或保存中：开关已本地翻转，刷新一次回到实际值
      _notify();
      return;
    }
    var target = screenConfig!.videoUSBSpeedMode == '1.1' ? '2.0' : '1.1';
    var result = await DoorLockNetIp.setDoorLockScreenConfig(
      deviceId: deviceId,
      config: DoorLockScreenConfig.copy(screenConfig!)
        ..videoUSBSpeedMode = target,
    );
    if (result.item1 == true) {
      screenConfig!.videoUSBSpeedMode = target;
    }
    _endSave(success: result.item1 == true, error: result.item2);
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
  _endSave({required bool success, dynamic error}) {
    KToast.dismiss();
    _writing = false;
    if (!_disposed) {
      if (success) {
        KToast.show(status: TR.current.TR_Common_Save_Success);
      } else {
        KToast.show(status: kErrorMsg(error));
      }
    }
    _notify();
  }

  _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
