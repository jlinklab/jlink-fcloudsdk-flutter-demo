import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fcloudsdk/manager/device_config_manager.dart';
import 'package:fcloudsdk/media/media_player.dart';
import 'package:fcloudsdk_example/common/code_prase.dart';
import 'package:fcloudsdk_example/views/toast/toast.dart';

/// 宽动态（WDR）配置控制器
/// 参考 iCSeeFlutterCode 的 DeviceWideDynamicController 交互：
/// 开关切换后立即下发 Camera.ParamEx 配置，成功后回查刷新状态
class DeviceWideDynamicController extends ChangeNotifier {
  final String deviceId;
  final int channel;

  /// 宽动态开关状态
  bool wdrStatus = false;

  /// 是否正在下发配置，防止重复请求
  bool saving = false;

  /// 查询到的 Camera.ParamEx 原始配置
  Map<String, dynamic>? _mapCameraParamEx;

  /// 是否已销毁，防止异步查询完成后对已销毁对象通知刷新
  bool _isDisposed = false;

  late final PreviewMediaController mediaController;

  DeviceWideDynamicController(this.deviceId, this.channel) {
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
    _queryWdrConfig();
  }

  /// 查询宽动态状态（Camera.ParamEx）
  Future<void> _queryWdrConfig() async {
    try {
      _mapCameraParamEx =
          await DeviceConfigManager.getConfigToObject<Map<String, dynamic>>(
        deviceId: deviceId,
        commandName: DeviceJsonName.cameraParamEx,
      );
      if (_isDisposed) return;
      if (_mapCameraParamEx != null) {
        final broadTrends = _mapCameraParamEx!['BroadTrends'];
        if (broadTrends != null && broadTrends is Map) {
          wdrStatus = broadTrends['AutoGain'] == 'Open';
        }
      }
      notifyListeners();
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
    }
  }

  /// 设置宽动态开关，成功后回查刷新状态，失败回查恢复开关状态
  Future<void> setWideDynamicCfg(bool open) async {
    if (saving || _mapCameraParamEx == null) return;
    saving = true;
    notifyListeners();
    KToast.show();
    try {
      _mapCameraParamEx!['BroadTrends'] = {
        ...?(_mapCameraParamEx!['BroadTrends'] as Map?),
        'AutoGain': open ? 'Open' : 'Close',
      };
      final jsonStr = jsonEncode([_mapCameraParamEx]);
      await DeviceConfigManager.setConfig(
        deviceId: deviceId,
        commandName: DeviceJsonName.cameraParamEx,
        config: jsonStr,
        configLength: jsonStr.length,
      );
      KToast.dismiss();
      await _queryWdrConfig();
    } catch (e) {
      KToast.show(status: kErrorMsg(e));
      await _queryWdrConfig();
    } finally {
      saving = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
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
