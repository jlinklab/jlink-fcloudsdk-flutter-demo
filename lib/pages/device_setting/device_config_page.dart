import 'dart:convert';

import 'package:fcloudsdk_example/manager/device_property_manager.dart';
import 'package:fcloudsdk_example/pages/device_setting/aov/device_aov_setting_page.dart';
import 'package:flutter/material.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/common/event.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';
import 'package:fcloudsdk_example/pages/device_ability/device_ability_manager.dart';
import 'package:fcloudsdk_example/pages/device_pwd_setting/device_pwd_reset_page.dart';
import 'package:fcloudsdk_example/pages/device_setting/device_alarm_page.dart';
import 'package:fcloudsdk_example/pages/device_setting/device_basic_page.dart';
import 'package:fcloudsdk_example/pages/device_setting/device_info_page.dart';
import 'package:fcloudsdk_example/pages/device_setting/device_record_set_page.dart';
import 'package:fcloudsdk_example/pages/device_setting/device_image_setting_page.dart';
import 'package:fcloudsdk_example/pages/device_setting/device_storage_manage_page.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/pages/device_setting/device_firmware_manage_page.dart';
import 'package:fcloudsdk_example/pages/device_setting/device_firmware_upgrade_page.dart';

typedef GetTitle = String Function(BuildContext context);

// ignore: must_be_immutable
class DeviceConfigPage extends StatefulWidget {
  DeviceConfigPage(
      {Key? key,
      required this.deviceId,
      required this.channel,
      required this.type,
      required this.pid})
      : super(key: key);

  final String deviceId;
  final int channel;
  final int type;
  final String pid;

  List<GetTitle> dataSource = [
    (context) => TR.current.basicSetting,
    (context) => TR.current.resetDevPwd,
    (context) => TR.current.storageManagement,
    (context) => TR.current.recordSetting,
    (context) => TR.current.imageSetting,
    (context) => TR.current.alarm,
    (context) => TR.current.devInfo,
    (context) => TR.current.deviceRestart,
    (context) => TR.current.deviceReset,
    (context) => TR.current.deviceFirmwareUpgrade,
    (context) => TR.current.firmwareManageTitle,
  ];

  @override
  State<DeviceConfigPage> createState() => _DeviceConfigPageState();
}

class _DeviceConfigPageState extends State<DeviceConfigPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updateDeviceSystemFunction();
  }

  _updateDeviceSystemFunction() async {
    try {
      bool isLowpower = await DevicePropertyManager.instance
          .isLowPowerAsync(deviceId: widget.deviceId);
      //获取能力集前低功耗设备需要先唤醒
      if (isLowpower) {
        KToast.show();
        var result = await JFApi.xcDevice.xcDeviceWakeup(
            deviceId: widget.deviceId, timeout: 10000); //唤醒超时10秒
        if (result < 0) {
          KToast.show(status: TR.current.TR_Wakeup_Failed);
          return;
        }
      }
      await JFApi.xcDevice.xcDeviceLogin(deviceId: widget.deviceId);
      await DeviceAbilityManager.update(deviceId: widget.deviceId);
      bool isAov = await DevicePropertyManager.instance
          .isAOVAsync(deviceId: widget.deviceId);
      if (isAov) {
        widget.dataSource.add(
          (context) => TR.current.TR_Setting_AOV_Device_Config,
        );
        if (mounted) {
          setState(() {});
        }
      }
      KToast.dismiss();
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TR.current.setting),
        centerTitle: true,
      ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: const Icon(Icons.message),
              title: Text(widget.dataSource[index](context)),
              onTap: () {
                clickRespond(context, widget.dataSource[index](context));
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              color: Colors.grey,
            );
          },
          itemCount: widget.dataSource.length),
    );
  }

  void clickRespond(BuildContext context, String title) {
    if (title == "报警" || title == "alarm") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return DeviceAlarmPage(
            deviceId: widget.deviceId, channel: widget.channel);
      }));
    } else if (title == "设备信息" || title == "device info") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return DeviceInfoPage(
            deviceId: widget.deviceId, channel: widget.channel);
      }));
    } else if (title == "重置设备密码" || title == "reset device password") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return DevicePwdResetPage(
          deviceId: widget.deviceId,
        );
      }));
    } else if (title == "存储管理" || title == "storage management") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return DeviceStoragePage(
            deviceId: widget.deviceId, channel: widget.channel);
      }));
    } else if (title == "录像设置" || title == "Video recording settings") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return DeviceRecordSetPage(
            deviceId: widget.deviceId, channel: widget.channel);
      }));
    } else if (title == "基本设置" || title == "Basic Settings") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return DeviceBasicPage(
            deviceId: widget.deviceId, channel: widget.channel);
      }));
    } else if (title == TR.current.deviceRestart) {
      showRebootConfirmDialog(context);
    } else if (title == TR.current.deviceReset) {
      showResetConfirmDialog(context);
    } else if (title == TR.current.deviceFirmwareUpgrade) {
      if (widget.pid == '-1') {
        KToast.show(status: TR.current.firmwarePidFail);
        return;
      }
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return DeviceFirmwareUpgradePage(
          deviceId: widget.deviceId,
          pid: widget.pid != '-1' ? widget.pid : '',
        );
      }));
    } else if (title == TR.current.firmwareManageTitle) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return DeviceFirmwareManagePage(deviceId: widget.deviceId);
      }));
    } else if (title == TR.current.imageSetting) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return DeviceImageSettingPage(
            deviceId: widget.deviceId, channel: widget.channel);
      }));
    } else if (title == TR.current.TR_Setting_AOV_Device_Config) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return DeviceAovSettingPage(deviceId: widget.deviceId);
      }));
    }
  }

  showRebootConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(TR.current.deviceRestartTip),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    executeDeviceReboot();
                  },
                  child: Text(TR.current.confirmBtn),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(TR.current.cancelBtn),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  executeDeviceReboot() async {
    KToast.show();
    try {
      final config = jsonEncode({
        "Name": "OPMachine",
        "SessionID": "0x01",
        "OPMachine": {"Action": "Reboot"}
      });
      await JFApi.xcDevice.xcDevSetSysConfig(
        deviceId: widget.deviceId,
        commandName: "OPMachine",
        config: config,
        configLen: config.length,
        command: 1450,
        timeout: 15000,
      );
      KToast.show(status: TR.current.rebootSuccess);
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  /// 设备恢复出厂设置确认弹窗
  /// 提供两个选项：仅恢复出厂设置 / 恢复出厂设置并删除设备
  showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(TR.current.deviceResetTip),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(TR.current.onlyFactoryReset),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  executeDeviceReset(deleteDevice: false);
                },
              ),
              const Divider(),
              ListTile(
                title: Text(TR.current.factoryResetAndDeleteDev),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  executeDeviceReset(deleteDevice: true);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(TR.current.cancelBtn),
            ),
          ],
        );
      },
    );
  }

  /// 执行设备恢复出厂设置
  /// 通过 OPMachine 命令发送 Action: "Reset" 到设备
  /// [deleteDevice] 为 true 时，恢复出厂后从本地设备列表中删除设备
  executeDeviceReset({required bool deleteDevice}) async {
    KToast.show();
    try {
      final config = jsonEncode({
        "Name": "OPMachine",
        "SessionID": "0x01",
        "OPMachine": {"Action": "Reset"}
      });
      await JFApi.xcDevice
          .xcDevSetSysConfig(
        deviceId: widget.deviceId,
        commandName: "OPMachine",
        config: config,
        configLen: config.length,
        command: 1450,
        timeout: 15000,
      )
          .then((value) {
        KToast.show(status: TR.current.resetSuccess);
        try {
          // 如果选择恢复出厂并删除设备，从本地设备列表中移除
          if (deleteDevice) {
            JFApi.xcAccount.xcRemoveDevice(widget.deviceId).then((value) {
              DeviceManager.instance
                  .removeDevice(deviceId: widget.deviceId, type: widget.type);
              eventBus.fire(RemoveDeviceUpdateEvent(type: widget.type));
            });
          }
          // 恢复出厂设置后设备会重启，延迟返回首页
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          });
        } catch (e) {
          KToast.show(status: kErrorMsg(e));
        }
      });
    } catch (e) {
      KToast.show(status: TR.current.resetFailed);
    }
  }

  _DeviceConfigPageState();
}
