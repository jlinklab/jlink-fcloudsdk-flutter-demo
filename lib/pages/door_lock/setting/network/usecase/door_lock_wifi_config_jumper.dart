import 'package:fcloudsdk_example/common/event.dart';
import 'package:fcloudsdk_example/event/event.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/pages/add_device/models/add_device_center.dart';
import 'package:fcloudsdk_example/pages/blue_tooth/ble_pair_config_page.dart';
import 'package:fcloudsdk_example/pages/blue_tooth/controller/main_ble_pair_config_controller.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_helper.dart';
import 'package:fcloudsdk_example/pages/door_lock/usecase/door_lock_operation.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:flutter/material.dart';

///门锁蓝牙配网跳转：填充配网临时数据后进入wifi密码配网页
class DoorLockWifiConfigJumper {
  ///进入wifi密码配网页重新配网，配网完成后回调[onComplete]
  static jumpBlueConfig(
    DoorLockPageController controller, {
    VoidCallback? onComplete,
  }) async {
    var context = controller.pageContext;
    var deviceId = controller.deviceId;
    var device = controller.device;

    if (context == null || !context.mounted) {
      return;
    }

    ///设备不在附近时弹提示，用户取消则中断
    if (DoorLockHelper.checkNeedTipsDeviceIsNotNearby(deviceId)) {
      var confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            content: Text(TR.current.TR_Ble_DoorLock_Connect_Fail_Confirm_Tips),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('确定'),
              ),
            ],
          );
        },
      );
      if (confirm != true) {
        return;
      }
    }

    if (!device.blueOnline) {
      KToast.show();
      bool online = await controller.waitBleOnline();
      KToast.dismiss();
      if (!context.mounted) {
        return;
      }
      if (online == false) {
        KToast.show(status: TR.current.TR_Ble_DoorLock_Connect_Failed);
      }
    }

    ///前面的弹窗/等待蓝牙在线均为异步操作，使用前校验页面仍在树上
    if (!context.mounted) {
      return;
    }
    var blueUUID = DoorLockHelper.getBlueUUID(deviceId);
    if (blueUUID == null || device.searchResult == null) {
      KToast.show(status: TR.current.TR_Ble_DoorLock_Connect_Failed);
      return;
    }

    var model = DeviceAddModel()
      ..deviceId = deviceId
      ..blueUUID = blueUUID
      ..pid = device.pid
      ..addDeviceType = AddDeviceType.blueToothPair;

    ///取消倒计时休眠，防止配网过程中断开连接
    controller.doorLockBleApi?.cancelDisConnectCount();

    var args = BlePairConfigArgs(
      model: model,
      bleDevice: device.searchResult!,
      isNetip: DoorLockHelper.isSuppportBleNetip(deviceId: deviceId),
      ability: device.doorLockBleAbility,
      exInfo: device.doorLockExInfo,
      pwdLengthRange: device.doorLockPwdLengthRange,
      navVersion: device.navVersion,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BlePairConfigPage(args: args)),
    );

    ///配网流程结束，重启倒计时休眠
    controller.doorLockBleApi?.startDisConnectCount();

    ///重新配网成功，通知网络设置页刷新wifi信息
    eventBus.fire(DoorLockResetNetSuccessEvent(deviceId: deviceId));
    onComplete?.call();
  }
}
