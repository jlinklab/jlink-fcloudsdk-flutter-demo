import 'dart:async';

import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/ble_by_sdk/ble_device.dart';
import 'package:fcloudsdk/ble_by_sdk/ble_distribute.dart';
import 'package:fcloudsdk/ble_by_sdk/ble_search.dart';
import 'package:fcloudsdk/door_lock/ble_distribute_new.dart';
import 'package:fcloudsdk/door_lock/ble_upgrade.dart';
import 'package:fcloudsdk/door_lock/door_lock_ble_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_ble_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_business_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_key_value.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_parse.dart';
import 'package:fcloudsdk/door_lock/door_lock_shadow.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:fcloudsdk/wifi/wifi_config.dart';
import 'package:fcloudsdk/wifi/wifi_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../../../api/door_lock_api.dart';
import '../../../pages/door_lock/usecase/door_lock_helper.dart';
import '../../add_device/models/add_device_center.dart';

///配网页参数：由激活页携带（激活+昵称+添加服务器完成后）
class BlePairConfigArgs {
  final DeviceAddModel model;
  final BleSearchDeviceBySDK bleDevice;

  ///是否支持蓝牙netip（国内锁）
  final bool isNetip;

  ///锁板能力集(EB)（激活后步骤已拉取，避免重复请求）
  final DoorLockBleAbility? ability;

  ///锁板产品额外信息
  final DoorLockExInfo? exInfo;

  ///锁板用户密码长度区间（激活后步骤已拉取）
  final DoorLockPwdLengthRange? pwdLengthRange;

  ///锁版配置能力集 navVersion（'v1.2'时配网后需检查密码管理员）
  final String? navVersion;

  BlePairConfigArgs({
    required this.model,
    required this.bleDevice,
    required this.isNetip,
    this.ability,
    this.exInfo,
    this.pwdLengthRange,
    this.navVersion,
  });
}

///门锁蓝牙配网控制器
///国内锁(netip)：有WiFi→WiFi输入→(非一体化锁)等待锁端重置→真配网
///             无WiFi→选择：有网络同上；没网络→一体化锁完成/非一体化锁假配网
///海外/低功耗锁：门锁初始化→(自检)→支持WiFi则真配网否则完成
class MainBlePairConfigController extends ChangeNotifier {
  final BuildContext context;
  final BlePairConfigArgs args;

  DeviceAddModel get model => args.model;

  final List<String> logs = [];

  ///配网完成（真/假配网成功或无需配网）
  bool isDone = false;

  ///配网失败（可重试）
  bool isFail = false;

  ///是否假配网
  bool isFake = false;

  ///当前阶段描述
  String stage = '';

  ///等待锁端重置网络的倒计时（秒）
  int waitResetCount = 0;

  late final DoorLockBleApi doorLockBleApi;

  BleNewDistribute? bleDistribute;

  ///门锁初始化中间数据
  Map<int, String>? doorLockAllConfig;
  bool syncKeyPair = true;
  bool syncJvssBaseYear = true;

  ///管理员/用户系统能力集（影子上报用）
  DoorManagerAbility? doorManagerAbility;
  DoorManagerAbility? doorUserAbility;

  ///配网防重入标志（isDone在流程真正结束时由_finish设置）
  bool _distributeDone = false;

  Timer? _waitResetTimer;

  ///蓝牙搜索结果监听（等待锁端重置时使用）
  void Function(BleSearchDeviceBySDK device)? _searchListener;

  MainBlePairConfigController({
    required this.context,
    required this.args,
  }) {
    doorLockBleApi =
        DoorLockBleApi(uuid: model.blueUUID, activeSn: model.deviceId);
  }

  _updateView() {
    notifyListeners();
  }

  _log(String msg) {
    logs.add(msg);
    _updateView();
  }

  ///是否一体化锁（用户管理能力）
  bool get isIntegrated => args.ability?.byte1.supportUserManager ?? false;

  ///配网是否需要authKey
  bool _needAuthKey() {
    return DoorLockHelper.isNeedSetAuthKey(deviceId: model.deviceId);
  }

  start() async {
    if (!args.isNetip) {
      ///海外/低功耗锁：门锁初始化 → 自检 → 真配网/完成
      await _doorLockInit();
      if (!syncKeyPair || !syncJvssBaseYear) {
        isFail = true;
        stage = '门锁初始化失败';
        _log('门锁初始化失败: 同步密钥对=$syncKeyPair 同步基准年=$syncJvssBaseYear');
        _updateView();
        return;
      }

      ///开锁方向自检
      if (args.ability?.byte3.supportOpeningDirectionSelfCheck == true) {
        await _showSelfCheckDialog();
      }

      if (args.exInfo?.byte2.supportConnectToWiFi ?? false) {
        ///支持配网，WiFi输入后真配网
        await _wifiInputAndDistribute();
      } else {
        ///不支持配网，直接完成
        _finish();
      }
      return;
    }

    ///国内锁
    stage = '检查网络环境';
    if (await DoorLockHelper.hadConnectedWifi()) {
      ///手机连着WiFi：WiFi输入 → (非一体化锁)等待锁端重置 → 真配网
      _log('手机已连接WiFi');
      if (await _checkNeedWaitDoorLockOperation()) {
        await _wifiInputAndDistribute();
      } else {
        isFail = true;
        stage = '等待锁端重置超时';
        _updateView();
      }
    } else {
      _log('手机未连接WiFi');
      var hadNet = await _showNoWifiChooseDialog();
      if (hadNet == null) {
        ///用户取消
        return;
      }
      if (hadNet) {
        ///有网络：WiFi输入 → (非一体化锁)等待锁端重置 → 真配网
        if (await _checkNeedWaitDoorLockOperation()) {
          await _wifiInputAndDistribute();
        } else {
          isFail = true;
          stage = '等待锁端重置超时';
          _updateView();
        }
      } else {
        ///没网络
        if (isIntegrated) {
          ///一体化锁直接完成（jlink 还有引导添加管理员步骤，demo未同步）
          _finish();
        } else {
          ///非一体化锁：等待锁端重置 → 假配网
          if (await _checkNeedWaitDoorLockOperation()) {
            await _startFakeDistribute();
          } else {
            isFail = true;
            stage = '等待锁端重置超时';
            _updateView();
          }
        }
      }
    }
  }

  //====================门锁初始化（海外/低功耗锁）====================

  _doorLockInit() async {
    stage = '门锁初始化';
    _updateView();

    var ready = await doorLockBleApi.bleObject.waitReadyIfNeed();
    if (!ready.item1) {
      syncKeyPair = false;
      _log('蓝牙连接失败: ${ready.item2}');
      return;
    }

    await _sendKeyPairIfNeed();
    await _syncJvssBaseYearIfNeed();
    await _getDeviceVersion();
    await _getDoorLockAllConfig();
    await _getDoorManagerAbility();
    await _getDoorUserAbility();
    await _uploadInfoToShadow();
    await _uploadInfoToJvss();

    _log('门锁初始化结束');
    _updateView();
  }

  ///获取并设置离线密钥组
  _sendKeyPairIfNeed() async {
    if (args.exInfo?.byte1.supportLockEndOffLinePwd == false) {
      _log('锁板不支持离线密码，跳过密钥组同步');
      return;
    }
    try {
      var result = await doorlockAPI.getKeyPair(deviceSn: model.deviceId);
      if (result is List) {
        var keyPair = result.join().replaceAll(':', '');
        var sendCallBack = await doorLockBleApi.sendKeyPair(1, keyPair);
        if (sendCallBack != null) {
          syncKeyPair = sendCallBack.item1;
          _log('同步离线密钥组: $syncKeyPair');
          if (!sendCallBack.item1 && sendCallBack.item2.first == 2) {
            ///密钥组回退
            try {
              await doorlockAPI.rollBackKeyPair(deviceSn: model.deviceId);
              syncKeyPair = true;
              _log('回退服务器密钥组成功');
            } catch (e) {
              _log('回退服务器密钥组失败: $e');
            }
          }
        }
      } else {
        _log('获取离线密钥组返回异常: $result');
      }
    } catch (e) {
      syncKeyPair = false;
      _log('同步离线密钥组异常: $e');
    }
  }

  ///同步jvss基准年
  _syncJvssBaseYearIfNeed() async {
    try {
      var year = DateTime.now().year;
      await doorlockAPI.addOrUpdateDeviceYear(
          deviceSn: model.deviceId, activeYear: year, pwdYear: year);
      syncJvssBaseYear = true;
      _log('同步JVSS基准年成功: $year');
    } catch (e) {
      syncJvssBaseYear = false;
      _log('同步JVSS基准年失败: $e');
    }
  }

  ///获取锁版本信息
  _getDeviceVersion() async {
    try {
      var bleUpgrade =
          BleUpgrade(uuid: model.blueUUID, activeSn: model.deviceId);
      var result = await bleUpgrade.getDeviceVersion();
      _log('获取锁版本: $result');
      await bleUpgrade.dispose();
    } catch (e) {
      _log('获取锁版本失败: $e');
    }
  }

  ///获取锁所有数据
  _getDoorLockAllConfig() async {
    try {
      doorLockAllConfig = await doorLockBleApi.getDoorLockAllConfig();
      _log('获取锁全部配置成功');
    } catch (e) {
      _log('获取锁全部配置失败: $e');
    }
  }

  ///获取锁管理员系统能力集
  _getDoorManagerAbility() async {
    try {
      doorManagerAbility = await doorLockBleApi.getDoorManagerAbility();
      _log(
          '获取管理员能力集成功: ${doorManagerAbility != null ? bytesToBin(doorManagerAbility!.values) : null}');
    } catch (e) {
      _log('获取管理员能力集失败: $e');
    }
  }

  ///获取用户系统能力集
  _getDoorUserAbility() async {
    try {
      doorUserAbility = await doorLockBleApi.getDoorUserAbility();
      _log(
          '获取用户能力集成功: ${doorUserAbility != null ? bytesToBin(doorUserAbility!.values) : null}');
    } catch (e) {
      _log('获取用户能力集失败: $e');
    }
  }

  ///上报能力集到影子服务
  _uploadInfoToShadow() async {
    try {
      await DoorLockShadow.uploadDoorFunctionToShadow(
        sn: model.deviceId,
        doorLockBleAbility: args.ability,
        doorLockExInfo: args.exInfo,
        doorManagerAbility: doorManagerAbility,
        doorUserAbility: doorUserAbility,
        doorLockPwdLengthRange: args.pwdLengthRange,
      );
      _log('能力集影子上报成功');
    } catch (e) {
      _log('能力集影子上报失败: $e');
    }
  }

  ///上报设备信息到jvss
  _uploadInfoToJvss() async {
    if (doorLockAllConfig == null) {
      return;
    }

    List<Map<String, dynamic>> doorInfos = [];
    List<Map<String, dynamic>> userInfos = [];
    var unlockModels = parseBleUnlockType(doorLockAllConfig);

    for (DoorLockUnlockModel m in unlockModels) {
      if (m.hardwareType == DoorLockBleHardwareType.offLinePwd) {
        doorInfos.add({
          'name': m.pwd ?? '',
          'deviceSn': model.deviceId,
          'unlockMode': '0x${bytesToHex([m.hardwareTypeOri])}',
          'validTime': m.timeliness,
          'validType': bytesToHex([m.timelinessTypeOri]),
          'hardwareId': m.hardwareId,
          'memberId': m.memberId,
          'createTime': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'password': m.pwd ?? '',
        });
      } else {
        userInfos.add({
          'Auth': m.memberId == 2 ? 0 : 1,
          'Id': m.hardwareId,
          'Type': m.hardwareType.toJvssType(),
        });
      }
    }

    if (!DoorLockKeyValueLocal.supportLowPowerBle(deviceId: model.deviceId)) {
      _log('非低功耗锁，跳过用户信息上报');
      return;
    }

    if (userInfos.isNotEmpty) {
      try {
        await doorlockAPI.saveDoorLockUser(
            sn: model.deviceId,
            users: userInfos,
            operationStr: JvssOperationAction.updateAll.value);
        _log('上报用户信息成功: ${userInfos.length}条');
      } catch (e) {
        _log('上报用户信息失败: $e');
      }
    }

    if (doorInfos.isNotEmpty) {
      try {
        await doorlockAPI.syncUnlockInfo(
          deviceSn: model.deviceId,
          syncTime: DateTime.now().millisecondsSinceEpoch,
          infoDTOS: doorInfos,
        );
        _log('上报开锁方式成功: ${doorInfos.length}条');
      } catch (e) {
        _log('上报开锁方式失败: $e');
      }
    }
  }

  //====================等待锁端重置网络====================

  ///检测是否需要等待锁端手动操作进入配网状态（国内非一体化锁特有）
  Future<bool> _checkNeedWaitDoorLockOperation() async {
    if (isIntegrated) {
      ///一体化锁，直接跳过
      return true;
    }

    ///非一体化锁：激活后需假配网并且需要锁板进行网络重置操作
    return _waitDoorLockResetNet();
  }

  ///断开蓝牙连接，持续蓝牙搜索，等待设备操作让广播包04变05/02
  Future<bool> _waitDoorLockResetNet() async {
    stage = '等待锁端重置网络';
    _log('等待锁端手动操作进入配网状态(广播包04→05)，最长180秒');
    _updateView();

    try {
      await doorLockBleApi.bleObject.stopConnect();
    } catch (_) {}
    try {
      await JFApi.xcDevice.xcLoginOut(deviceId: model.deviceId);
    } catch (_) {}

    Completer<bool> completer = Completer();

    waitResetCount = 180;
    _waitResetTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      waitResetCount--;
      if (waitResetCount <= 0) {
        timer.cancel();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      }
      _updateView();
    });

    Future.delayed(const Duration(seconds: 3), () async {
      if (completer.isCompleted) {
        return;
      }
      try {
        if (!BleSearch.instance.isSearching) {
          await BleSearch.instance.start(timeout: 180);
        }
        _searchListener = (device) {
          if (device.uuid == model.blueUUID) {
            _log('搜索到设备: sn=${device.sn} extra=${device.extra}');
            if (device.extra == 5 || device.extra == 2) {
              if (!completer.isCompleted) {
                completer.complete(true);
              }
            }
          }
        };
        BleSearch.instance.addSearchResultListener(_searchListener!);
      } catch (e) {
        _log('蓝牙搜索异常: $e');
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      }
    });

    var result = await completer.future;
    _waitResetTimer?.cancel();
    try {
      await BleSearch.instance.stop();
    } catch (_) {}
    _log(result ? '锁端已进入配网状态' : '等待锁端重置网络超时/失败');
    _updateView();
    return result;
  }

  ///用户取消等待
  cancelWaitReset() {
    _waitResetTimer?.cancel();
    try {
      BleSearch.instance.stop();
    } catch (_) {}
    _log('用户取消等待锁端重置');
    _updateView();
  }

  //====================真/假配网====================

  ///WiFi输入后真配网
  _wifiInputAndDistribute() async {
    var wifi = await _showWifiInputDialog();
    if (wifi == null) {
      _log('取消WiFi输入');
      isFail = true;
      stage = '已取消';
      _updateView();
      return;
    }
    await _startTrueDistribute(ssid: wifi.$1, wifiPwd: wifi.$2);
  }

  ///真配网
  _startTrueDistribute({required String ssid, required String wifiPwd}) async {
    stage = '蓝牙配网中';
    _log('真配网开始: ssid=$ssid');
    _updateView();

    _stopDistribute();
    bleDistribute = BleNewDistribute(
      uuid: model.blueUUID,
      wifiConfig: WifiConfig(ssid: ssid, wifiPwd: wifiPwd),
      dns: '',
      authKey: _needAuthKey()
          ? DoorLockKeyValueLocal.authKey(deviceId: model.deviceId)
          : null,
      activeSn: model.deviceId,
    );
    _addDistributeListeners(isFake: false);
    await bleDistribute!.startDistribute();
  }

  ///假配网
  _startFakeDistribute() async {
    stage = '假配网中';
    _log('假配网开始');
    _updateView();

    _stopDistribute();
    bleDistribute = BleNewDistribute(
      uuid: model.blueUUID,
      wifiConfig: const WifiConfig(ssid: '', wifiPwd: ''),
      dns: '',
      authKey: _needAuthKey()
          ? DoorLockKeyValueLocal.authKey(deviceId: model.deviceId)
          : null,
      activeSn: model.deviceId,
    );
    _addDistributeListeners(isFake: true);
    await bleDistribute!.startFakeDistribute();
  }

  _addDistributeListeners({required bool isFake}) {
    var distribute = bleDistribute!;

    ///连接状态监听
    distribute.addConnectStatusListener((status, errorCode) {
      if (status == BleDistributeStatus.connected) {
        _log('蓝牙连接成功，开始发送配网信息');
      } else if (status == BleDistributeStatus.connectFail) {
        _log('蓝牙连接失败: $errorCode');
        _onDistributeFail(errorCode, isFake: isFake);
      } else if (status == BleDistributeStatus.breaked) {
        if (!isDone) {
          _log('蓝牙连接断开: $errorCode');
          _onDistributeFail(errorCode, isFake: isFake);
        }
      }
    });

    ///配网状态监听
    distribute
        .addDistributeResultListener((status, device, errorCode, jsonStr) {
      if (status == BleDistributeStatus.distributing) {
        _log('设备已接收配网信息，等待设备连接路由器');
      } else if (status == BleDistributeStatus.distributeSuccess) {
        if (isFake) {
          _onFakeDistributeSuccess();
        } else {
          if (device == null) {
            _log('配网成功但数据解析失败');
            _onDistributeSuccess(null);
          } else {
            _onDistributeSuccess(device);
          }
        }
      } else if (status == BleDistributeStatus.error) {
        distribute.stop();
        _log('配网出错: $errorCode');
        _onDistributeFail(errorCode, isFake: isFake);
      }
    });
  }

  ///真配网成功
  _onDistributeSuccess(BleDistributeDeviceBySDK? device) async {
    if (isDone || _distributeDone) {
      return;
    }

    ///防重复回调（管理员检查等后续流程中才置isDone，期间页面不显示完成）
    _distributeDone = true;
    stage = '配网成功';
    _log('真配网成功');
    _updateView();

    ///同步adminToken到服务器
    var token = device?.token;
    if (token != null && token.isNotEmpty) {
      try {
        await doorlockAPI.updateToken(sn: model.deviceId, adminToken: token);
        _log('同步adminToken成功');
      } catch (e) {
        _log('同步adminToken失败: $e');
      }
    }

    ///回填配网返回的设备信息
    if (device != null) {
      var json = device.toJson();
      model.ip = json['IP'] ?? model.ip;
      model.devMac = json['Mac'] ?? model.devMac;
      model.adminToken = json['Token'] ?? model.adminToken;
    }

    ///国内锁：登出设备&退出蓝牙netip，不然sdk依旧会使用蓝牙netip，不走普通netip
    if (args.isNetip) {
      try {
        await JFApi.xcDevice.xcLoginOut(deviceId: model.deviceId);
      } catch (_) {}
      await DoorLockHelper.closeBlueNetIp(sn: model.deviceId);
    }

    ///上传已配网状态
    DoorLockHelper.setDeviceNetProvision(true, model.deviceId);
    _log('已上报配网状态: 已配网');
    _updateView();

    ///缓存蓝牙设备信息到本地
    if (model.ip.isNotEmpty) {
      try {
        UtilAPI.instance
            .xcCacheBluetoothInfo(deviceId: model.deviceId, deviceIp: model.ip);
      } catch (_) {}
    }

    ///配网成功后：设置本地token + 管理员检查
    await _afterDistributeNetLogin();
  }

  ///配网成功后的登录/管理员检查
  _afterDistributeNetLogin() async {
    ///设置本地token
    if (model.adminToken.isNotEmpty) {
      try {
        await JFApi.xcDevice.xcSetDeviceToken(
            deviceId: model.deviceId, token: model.adminToken);
        _log('设置本地token成功');
      } catch (e) {
        _log('设置本地token失败: $e');
      }
    }

    ///一体化锁且navVersion为v1.2：需要检查/添加密码管理员
    if (isIntegrated && args.navVersion == 'v1.2') {
      await _checkAdminAfterDisNet();
      return;
    }
    _finish();
  }

  ///配网后检查是否需要添加密码管理员
  _checkAdminAfterDisNet() async {
    stage = '检查密码管理员';
    _log('开始检查密码管理员');
    _updateView();

    DoorLockNetIpOperaterResult? syncStatus;
    try {
      var result = await DoorLockNetIp.syncDoorStatus(model.deviceId);
      if (result.item2?.err != DoorLockNetIpOperaterResult.anotherOperating) {
        syncStatus = result.item2?.err;
      }
      _log('保活结果: ${result.item1}, err=$syncStatus');
    } catch (e) {
      _log('保活异常: $e');
    }

    if (syncStatus == DoorLockNetIpOperaterResult.addUserAdminNotskip) {
      ///请先添加或修改管理员密码（不可跳过）：app端输入密码
      await _pushEnterAdmin();
    } else if (syncStatus ==
        DoorLockNetIpOperaterResult.frontLockNeedAddAdmin) {
      ///需要先在前锁添加管理员：引导去锁端录入
      await _pushAddAdminGuide();
    } else {
      _log('无需添加密码管理员');
      _finish();
    }
  }

  ///app端输入密码添加密码管理员
  _pushEnterAdmin() async {
    var minLength = args.pwdLengthRange?.min ?? 6;
    var maxLength = args.pwdLengthRange?.max ?? 6;
    var pwd =
        await _showAdminPwdDialog(minLength: minLength, maxLength: maxLength);
    if (pwd == null) {
      ///用户取消，跳过
      _log('用户取消添加管理员');
      _finish();
      return;
    }

    try {
      ///先保活
      await DoorLockNetIp.syncDoorStatus(model.deviceId);
      var result = await DoorLockNetIp.addDoorOpenType(
        deviceId: model.deviceId,
        type: JvssOperateType.password,
        isAdmin: true,
        isCancel: false,
        pwd: pwd,
      );
      if (result.item1 && result.item2?.parse is DookLockOpenTypeUser) {
        var admin = result.item2!.parse as DookLockOpenTypeUser;
        _log('添加密码管理员成功: id=${admin.id}');
        await _saveAdminToService(admin);
        await _editAdminNickName(admin);
      } else {
        _log('添加密码管理员失败: ${result.item2?.err}');
        _finish();
      }
    } catch (e) {
      _log('添加密码管理员异常: $e');
      _finish();
    }
  }

  ///引导去锁端录入管理员（锁端进入录入状态，180s）
  _pushAddAdminGuide() async {
    var addFuture = DoorLockNetIp.addDoorOpenType(
      deviceId: model.deviceId,
      type: JvssOperateType.password,
      isAdmin: true,
      isCancel: false,
      timeout: 180,
    );

    ///等待用户在锁端完成录入（弹窗确认/取消）
    var confirmed = await _showWaitLockAddAdminDialog();
    if (!confirmed) {
      ///取消：发送取消添加指令并完成
      try {
        await DoorLockNetIp.addDoorOpenType(
          deviceId: model.deviceId,
          type: JvssOperateType.password,
          isAdmin: true,
          isCancel: true,
        );
      } catch (_) {}
      _finish();
      return;
    }

    var result = await addFuture.catchError((e) {
      _log('等待锁端录入结果异常: $e');
      return Tuple3(false, null, e);
    });
    if (result.item1 && result.item2?.parse is DookLockOpenTypeUser) {
      var admin = result.item2!.parse as DookLockOpenTypeUser;
      _log('锁端录入管理员成功: id=${admin.id}');
      await _saveAdminToService(admin);
      await _editAdminNickName(admin);
    } else {
      _log('锁端录入管理员未完成: ${result.item2?.err}');
      _finish();
    }
  }

  ///管理员信息上报服务器
  _saveAdminToService(DookLockOpenTypeUser admin) async {
    try {
      await doorlockAPI.saveDoorLockUser(
          sn: model.deviceId,
          users: [
            {'Id': admin.id, 'Type': JvssOperateType.password.value, 'Auth': 0}
          ],
          operationStr: JvssOperationAction.add.value,
          userTypes: [JvssOperateType.password.value]);
      _log('管理员信息上报服务器成功');
    } catch (e) {
      _log('管理员信息上报服务器失败: $e');
    }
  }

  ///设置管理员昵称
  _editAdminNickName(DookLockOpenTypeUser admin) async {
    var name = await _showAdminNickNameDialog();
    if (name == null || name.isEmpty) {
      _finish();
      return;
    }
    try {
      await doorlockAPI.modifyAlarmMessageNickName(
          deviceSn: model.deviceId,
          userType: JvssOperateType.password.toJvssString(),
          userId: admin.id.toString(),
          userNickname: name,
          headPortrait: '');
      _log('管理员昵称设置成功: $name');
    } catch (e) {
      _log('管理员昵称设置失败: $e');
    }
    _finish();
  }

  ///假配网成功
  _onFakeDistributeSuccess() async {
    if (isDone) {
      return;
    }
    isDone = true;
    isFake = true;
    stage = '假配网成功';
    _log('假配网成功');

    ///上传假配网状态
    DoorLockHelper.setDeviceNetProvision(false, model.deviceId, isFake: true);
    _log('已上报配网状态: 假配网');
    _updateView();

    ///假配网就一条指令很快，防止页面一闪而过，给一些延迟
    await Future.delayed(const Duration(seconds: 1));
  }

  ///配网失败
  _onDistributeFail(int? errorCode, {required bool isFake}) {
    if (isDone) {
      return;
    }
    isFail = true;
    stage = isFake ? '假配网失败' : '配网失败';
    _log('配网失败: errorCode=$errorCode');
    _updateView();
  }

  ///失败重试（重新走配网，WiFi会重新输入）
  retry() async {
    if (isDone) {
      return;
    }
    isFail = false;
    stage = '';
    _log('重试配网');
    _updateView();
    if (args.isNetip) {
      if (await _checkNeedWaitDoorLockOperation()) {
        await _wifiInputAndDistribute();
      } else {
        isFail = true;
        stage = '等待锁端重置超时';
        _updateView();
      }
    } else {
      if (args.exInfo?.byte2.supportConnectToWiFi ?? false) {
        await _wifiInputAndDistribute();
      } else {
        _finish();
      }
    }
  }

  _finish() {
    isDone = true;
    stage = '完成';
    _log('配对流程完成');
    _updateView();
  }

  _stopDistribute() {
    bleDistribute?.dispose();
    bleDistribute = null;
  }

  //====================弹窗====================

  ///密码管理员密码输入弹窗，取消返回 null
  Future<String?> _showAdminPwdDialog(
      {required int minLength, required int maxLength}) {
    var pwdController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('设置管理员密码'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('请设置管理员密码，用于后续管理门锁'),
              const SizedBox(height: 12),
              TextField(
                controller: pwdController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(hintText: '请输入$minLength-$maxLength位数字密码'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('跳过'),
            ),
            TextButton(
              onPressed: () {
                var pwd = pwdController.text.trim();
                if (pwd.length >= minLength && pwd.length <= maxLength) {
                  Navigator.of(dialogContext).pop(pwd);
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  ///等待锁端录入管理员弹窗，返回是否确认完成
  Future<bool> _showWaitLockAddAdminDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('锁端录入管理员'),
          content: const Text('请在门锁键盘上输入管理员密码完成录入（180秒内有效），完成后点击"已完成"'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('已完成'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  ///管理员昵称输入弹窗，取消返回 null
  Future<String?> _showAdminNickNameDialog() {
    var nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('设置管理员昵称'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: '请输入管理员昵称'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('跳过'),
            ),
            TextButton(
              onPressed: () {
                var name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(dialogContext).pop(name);
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  ///WiFi输入弹窗，返回 (ssid, pwd)，取消返回 null
  Future<(String, String)?> _showWifiInputDialog() async {
    var pwdController = TextEditingController();

    ///自动获取当前连接的WiFi SSID
    String ssid = await WifiPlatform.instance.getSSID();
    if (ssid.toLowerCase().contains('unknown') ||
        ssid.toLowerCase().contains('null')) {
      ssid = '';
    }
    var ssidController = TextEditingController(text: ssid);
    return showDialog<(String, String)>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('输入WiFi信息'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ssidController,
                readOnly: true,
                decoration: const InputDecoration(hintText: 'WiFi名称(ssid)'),
              ),
              TextField(
                controller: pwdController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'WiFi密码'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                var ssid = ssidController.text.trim();
                var pwd = pwdController.text;
                if (ssid.isNotEmpty) {
                  Navigator.of(dialogContext).pop((ssid, pwd));
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  ///无WiFi选择弹窗：true有网络 / false没网络 / null取消
  Future<bool?> _showNoWifiChooseDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('网络选择'),
          content: const Text('当前手机未连接WiFi，请选择网络环境'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('没有网络'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('有网络'),
            ),
          ],
        );
      },
    );
  }

  ///开锁方向自检
  ///蓝牙透传发0x48指令，监听锁端响应，resultCode=0成功，非零按位解析错误，可重试可跳过）
  Future<void> _showSelfCheckDialog() async {
    stage = '开锁方向自检';
    _log('设备支持开锁方向自检');
    _updateView();
    while (true) {
      var start = await _showSelfCheckStartDialog();
      if (start != true) {
        ///跳过自检，继续后续流程
        _log('跳过开锁方向自检');
        return;
      }

      stage = '开锁方向自检中';
      _log('开始发送自检指令');
      _updateView();
      var resultCode = await _doSelfCheck();
      if (resultCode == 0) {
        _log('开锁方向自检成功，开锁方向确认');
        await _showSelfCheckSuccessDialog();
        return;
      }

      ///失败：负数为超时/异常，正数为锁端错误码
      var errorMsg =
          resultCode > 0 ? _parseSelfCheckErrors(resultCode) : '自检超时或蓝牙连接失败';
      _log('开锁方向自检失败: $errorMsg');
      var retry = await _showSelfCheckFailDialog(errorMsg);
      if (retry != true) {
        ///下一步（跳过），继续后续流程
        _log('自检失败后跳过，继续流程');
        return;
      }
    }
  }

  ///发送开锁方向自检BLE命令并等待锁端响应
  ///返回0=成功，正数=锁端错误码，负数=超时/发送失败
  Future<int> _doSelfCheck() async {
    var completer = Completer<int>();

    ///监听锁端响应（bytes[0]==0x48，resultCode取bytes[4..6]）
    doorLockBleApi.listenStream(
      (message) {
        var bytes = message.bytes;
        if (bytes.length < 6) {
          if (!completer.isCompleted) {
            completer.completeError('响应过短: ${bytes.length} bytes');
          }
          return;
        }
        var resultCode = bytesToInt(bytes.sublist(4, 6));
        if (!completer.isCompleted) {
          if (resultCode == 0) {
            completer.complete(0);
          } else {
            completer.completeError(resultCode);
          }
        }
      },
      where: (msg) {
        return msg.bytes.isNotEmpty && msg.bytes[0] == 0x48;
      },
      completer: completer,
    );

    ///发送自检命令（0x48指令：开锁方向自检）
    var cmdBytes = [0x48, 0x02, 0x01, 0x03];
    var sent =
        await doorLockBleApi.bleObject.sendMsgTransparent(bytesToHex(cmdBytes));
    if (!sent) {
      return -1;
    }

    try {
      return await completer.future;
    } catch (e) {
      if (e is int) {
        return e;
      }
      if (e is XCloudAPIException) {
        ///listenStream内置15s超时
        return e.code;
      }
      return -1;
    }
  }

  ///按位解析自检错误码（低位到高位）
  String _parseSelfCheckErrors(int errorCode) {
    errorCode = errorCode & 0xFFFF;
    var binaryStr = errorCode.toRadixString(2).padLeft(8, '0');
    if (binaryStr.length > 8) {
      binaryStr = binaryStr.substring(binaryStr.length - 8);
    }
    var errors = <String>[];
    if (binaryStr[7] == '1') errors.add('开锁方向异常');
    if (binaryStr[6] == '1') errors.add('回位方向异常');
    if (binaryStr[5] == '1') errors.add('关锁方向异常');
    if (binaryStr[4] == '1') errors.add('硬件异常');
    if (binaryStr[3] == '1') errors.add('开锁/关锁堵塞');
    if (binaryStr[2] == '1') errors.add('回位堵塞');
    if (binaryStr[1] == '1') errors.add('开锁/关锁超时');
    if (binaryStr[0] == '1') errors.add('回位超时');
    return errors.join('、');
  }

  ///自检开始弹窗：true=开始自检，null=跳过
  Future<bool?> _showSelfCheckStartDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('开锁方向自检'),
          content: const Text('请确认门锁安装方向正确，自检将自动验证开锁/回位方向。\n若方向错误，可能导致无法正常开锁。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('跳过'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('开始自检'),
            ),
          ],
        );
      },
    );
  }

  ///自检成功弹窗
  Future<void> _showSelfCheckSuccessDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('开锁方向自检'),
          content: const Text('自检成功，开锁方向确认。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('下一步'),
            ),
          ],
        );
      },
    );
  }

  ///自检失败弹窗：true=重试，null=下一步（跳过）
  Future<bool?> _showSelfCheckFailDialog(String errorMsg) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('开锁方向自检失败'),
          content: Text('自检失败：$errorMsg\n请检查门锁安装方向后重试，或跳过继续后续流程。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('下一步'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('重试'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _waitResetTimer?.cancel();
    if (_searchListener != null) {
      BleSearch.instance.removeSearchResultListener(_searchListener!);
    }
    _stopDistribute();
    doorLockBleApi.dispose();
    super.dispose();
  }
}
