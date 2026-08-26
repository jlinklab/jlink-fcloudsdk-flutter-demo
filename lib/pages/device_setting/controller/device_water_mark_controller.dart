import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/manager/device_config_manager.dart';
import 'package:fcloudsdk/media/media_player.dart';
import 'package:fcloudsdk/utils/extensions.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/generated/l10n.dart';
import 'package:fcloudsdk_example/manager/device_manager.dart';
import 'package:fcloudsdk_example/pages/device_ability/device_ability_manager.dart';
import 'package:fcloudsdk_example/pages/device_setting/model/model.dart';
import 'package:fcloudsdk_example/utils/jpeg_chn_title_helper.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

/// 水印配置控制器
/// 参考 iCSeeHuoYan 的水印流程（JpegChnTitleHelper）与宽动态控制器的交互模式：
/// 修改设备名称后统一下发水印配置，成功后重启预览呈现水印效果
class DeviceWaterMarkController extends ChangeNotifier {
  final String deviceId;
  final int channel;

  /// 当前设备名称（水印内容）
  String deviceName = '';

  /// 是否支持图片水印（JpegChnTitleOSD）
  bool supportJpegChnTitleOSD = false;

  /// 是否正在下发配置，防止重复请求
  bool saving = false;

  /// 是否已销毁，防止异步查询完成后对已销毁对象通知刷新
  bool _isDisposed = false;

  late final PreviewMediaController mediaController;

  DeviceWaterMarkController(this.deviceId, this.channel) {
    mediaController = PreviewMediaController(
      deviceId: deviceId,
      channel: channel,
      streamType: StreamType.hd,
    );
    mediaController.addStatusListener((status) {
      if (hasListeners) {
        notifyListeners();
      }
    });
    mediaController.addErrorListener((code) {
      KToast.show(status: kErrorMsg(code));
    });
    _init();
  }

  void _init() async {
    final device = DeviceManager.instance.getDevice(deviceId: deviceId);
    deviceName = device?.nickname ?? device?.uuid ?? '';
    supportJpegChnTitleOSD = await DeviceAbilityManager.getAbilityEnableIfNeed(
        deviceId: deviceId,
        type: DeviceAbilityType.bOtherFunctionJpegChnTitleOSD);
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// 仅更新本地设备名称状态
  void setDeviceName(String name) {
    deviceName = name;
    notifyListeners();
  }

  /// 保存水印：
  /// 1. 更新设备昵称（服务器侧）
  /// 2. 支持图片水印时走 JPG 图片水印流程，失败兜底老式点阵水印
  /// 3. 重启预览呈现水印效果
  Future<void> saveWaterMark() async {
    if (saving || deviceName.trim().isEmpty) return;
    saving = true;
    notifyListeners();
    KToast.show();
    try {
      final editName = deviceName.trim();
      await _editDeviceNickname(editName);

      if (supportJpegChnTitleOSD) {
        try {
          await JpegChnTitleHelper.instance.getJpegChnTitle(deviceId, editName);
        } catch (e) {
          // JPG 图片水印失败，兜底老式点阵水印
          debugPrint('图片水印下发失败，走老式点阵水印: ${kErrorMsg(e)}');
          await _setLegacyWaterMark(editName);
        }
      } else {
        await _setLegacyWaterMark(editName);
      }

      final device = DeviceManager.instance.getDevice(deviceId: deviceId);
      device?.nickname = editName;
      KToast.show(status: TR.current.saveSuccess);
      // 重启预览呈现水印效果
      mediaController.restart();
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    } finally {
      saving = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  /// 更新设备昵称
  Future<void> _editDeviceNickname(String newName) async {
    final device = DeviceManager.instance.getDevice(deviceId: deviceId);
    if (device != null && device.fromShare) {
      // 分享设备修改昵称
      if ((device as SharedDevice).shareId.isNotEmpty) {
        await JFApi.xcAccount.xcEditDeviceInfo(
          deviceId: deviceId,
          userName: '',
          nickName: newName,
        );
      }
    } else {
      final userName =
          await JFApi.xcDevice.xcDevGetLocalUserName(deviceId: deviceId);
      await JFApi.xcAccount.xcEditDeviceInfo(
        deviceId: deviceId,
        userName: userName,
        nickName: newName,
      );
    }
  }

  /// 老式点阵水印流程：修改通道标题 + 下发点阵水印
  Future<void> _setLegacyWaterMark(String editName) async {
    var videoWidget = await DeviceConfigManager.getConfigToObject<
            List<Map<String, dynamic>>>(
        deviceId: deviceId, commandName: DeviceJsonName.aVEncVideoWidget);
    Map<String, dynamic>? chanelTitle =
        videoWidget.firstWhereOrNull((e) => e.containsKey('ChannelTitle'));
    if (chanelTitle != null && chanelTitle['ChannelTitle'] != null) {
      chanelTitle['ChannelTitle']['Name'] = editName;
    }
    Map<String, dynamic>? chanelTitleAttr = videoWidget
        .firstWhereOrNull((e) => e.containsKey('ChannelTitleAttribute'));
    if (chanelTitleAttr != null &&
        chanelTitleAttr['ChannelTitleAttribute'] != null) {
      chanelTitleAttr['ChannelTitleAttribute']['EncodeBlend'] = true;
      chanelTitleAttr['ChannelTitleAttribute']['PreviewBlend'] = true;
    }
    await DeviceConfigManager.setConfig(
        deviceId: deviceId,
        commandName: DeviceJsonName.aVEncVideoWidget,
        config: jsonEncode(videoWidget));

    final waterMarkMark = await JpegChnTitleHelper.instance
        .buildLegacyWatermarkMark(deviceId: deviceId, editName: editName);
    await JFApi.xcDevice
        .devSetWaterMark(deviceId: deviceId, mark: waterMarkMark);
  }

  /// 起流
  void startPreview() {
    mediaController.startPreview();
  }

  @override
  void dispose() {
    _isDisposed = true;
    mediaController.dispose();
    super.dispose();
  }
}
