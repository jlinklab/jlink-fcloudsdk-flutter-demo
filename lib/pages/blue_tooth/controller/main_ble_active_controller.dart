import 'dart:async';
import 'dart:convert';

import 'package:fcloudsdk/api/api_center.dart';
import 'package:fcloudsdk/ble_by_sdk/ble_device.dart';
import 'package:fcloudsdk/door_lock/ble_active.dart';
import 'package:fcloudsdk/door_lock/door_lock_ble_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_ble_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/door_lock/door_lock_key_value.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_api.dart';
import 'package:fcloudsdk/door_lock/door_lock_netip_model.dart';
import 'package:fcloudsdk/door_lock/door_lock_parse.dart';
import 'package:fcloudsdk/door_lock/door_lock_shadow.dart';
import 'package:fcloudsdk/utils/bit_util.dart';
import 'package:flutter/material.dart';

import '../../../api/add_device_api.dart';
import '../../../api/door_lock_api.dart';
import '../../../pages/door_lock/usecase/device_sync_time.dart';
import '../../../pages/door_lock/usecase/door_lock_helper.dart';
import '../../add_device/models/add_device_center.dart';

///门锁蓝牙激活控制器
///流程：连接 → 下发激活(0010) → 激活响应(拿 authKey/token/newSn) → 服务器校验
///→ 获取能力集(0003) → 通知设备校验结果(0011) → 握手协商密钥 → 成功
class MainBleActiveController extends ChangeNotifier {
  final BuildContext context;

  ///蓝牙扫描到的设备（获取锁版配置能力集后会改写广播包状态）
  BleSearchDeviceBySDK bleDevice;

  ///日志
  final List<String> logs = [];

  ///激活响应
  BleActiveResponse? activeResponse;

  ///是否激活成功
  bool isSuccess = false;

  ///是否失败
  bool isFail = false;

  ///是否已添加服务器
  bool hadAddService = false;

  ///添加服务器是否成功
  bool isAddServiceSuccess = false;

  ///配网数据（激活成功后填充，供后续添加服务器/配网步骤使用）
  final DeviceAddModel model = DeviceAddModel();

  late BleActive bleActive;

  ///锁板业务接口（激活后可选步骤使用）
  late DoorLockBleApi doorLockBleApi;

  ///锁板能力集(EB)
  DoorLockBleAbility? doorLockBleAbility;

  ///锁板额外的产品信息
  DoorLockExInfo? doorLockExInfo;

  ///锁板用户密码长度区间（激活后步骤获取，影子上报用）
  DoorLockPwdLengthRange? pwdLengthRange;

  ///锁版配置能力集（getDoorFunction，国内锁配网后管理员检查用 navVersion）
  DoorFunction? doorFunction;

  ///密码管理员是否添加完成（null/true=完成或无需添加）
  bool? addManagerDone;

  ///jvss基准年是否已同步
  bool? syncJvssBaseYear;

  MainBleActiveController({
    required this.context,
    required this.bleDevice,
  }) {
    model.addDeviceType = AddDeviceType.blueToothPair;
    model.deviceId = bleDevice.sn;
    model.pid = bleDevice.pid;
    doorLockBleApi = DoorLockBleApi(uuid: bleDevice.uuid, activeSn: '');
  }

  ///开始激活
  start() async {
    logs.add('开始蓝牙激活: uuid=${bleDevice.uuid}, sn=${model.deviceId}, pid=${model.pid}');
    _updateView();

    ///获取accessToken
    String accessToken = '';
    try {
      accessToken = await JFApi.xcAccount.xcGetAccessToken();
    } catch (e) {
      debugPrint('get accessToken fail: $e');
    }

    bleActive = BleActive(
      uuid: bleDevice.uuid,
      searchSn: model.deviceId,
      pid: model.pid,
      accessToken: accessToken,
      type: DoorLockHelper.blueActiveType(device: bleDevice),
    );

    bleActive.addActiveStatusListener(_onActiveStatus);

    if (model.deviceId.isEmpty || model.pid.isEmpty || accessToken.isEmpty) {
      logs.add(
          '激活前置参数检查异常: sn=${model.deviceId}, pid=${model.pid}, token=${accessToken.isEmpty ? '空' : '有'}');
      _updateView();
    }

    await bleActive.start();
  }

  ///激活状态监听
  _onActiveStatus(BleActiveStatus status, dynamic data, int? errorCode) {
    if (status == BleActiveStatus.connecting) {
      logs.add('开始连接蓝牙');
    } else if (status == BleActiveStatus.connectFail) {
      logs.add('蓝牙连接失败: $errorCode');
      _fail();
    } else if (status == BleActiveStatus.connectedBreak) {
      logs.add('蓝牙连接断开: $errorCode');
      _fail();
    } else if (status == BleActiveStatus.activateResponse) {
      if (data is BleActiveResponse) {
        activeResponse = data;
        _updateModel();
        logs.add('蓝牙激活响应: newSn=${data.newSn}, mac=${data.mac}');
      }
    } else if (status == BleActiveStatus.getAbilitySuccess) {
      logs.add('获取锁板能力集(0003)成功');
    } else if (status == BleActiveStatus.activateWaitOK) {
      logs.add('请在锁端按OK键确认');
    } else if (status == BleActiveStatus.activateWaitCheckUser) {
      logs.add('请在锁端验证管理员');
    } else if (status == BleActiveStatus.activateFail) {
      logs.add('蓝牙激活失败: $errorCode');
      _fail();
    } else if (status == BleActiveStatus.checkAuthKeyFail) {
      logs.add('蓝牙激活服务器校验失败: $errorCode');
      _fail();
    } else if (status == BleActiveStatus.handleShakeFail) {
      logs.add('蓝牙握手协商密钥失败: $errorCode');
      _fail();
    } else if (status == BleActiveStatus.activiteSuccess) {
      if (!bleActive.bleObject.autoHandleShakeAfterConnect) {
        _success();
      }
    } else if (status == BleActiveStatus.handleShakeSuccess) {
      if (bleActive.bleObject.autoHandleShakeAfterConnect) {
        _success();
      }
    }
    _updateView();
  }

  ///更新配网数据
  _updateModel() {
    if (activeResponse != null) {
      ///更新adminToken
      model.adminToken = activeResponse!.token;

      ///激活后的序列号可能与搜索时不一样，以激活后为准，这里存一下旧的
      var newSn = activeResponse!.newSn;
      if (newSn.isNotEmpty && newSn != model.deviceId) {
        model.oldSearchDeviceId = model.deviceId;
        model.deviceId = newSn;
      }

      ///设备mac地址
      model.devMac = activeResponse!.mac;

      ///协议格式类型
      model.devFormatType = activeResponse!.protocolFormatType;
    }

    ///蓝牙uuid（iOS外设peripheralIdentifier）
    model.blueUUID = bleDevice.uuid;
  }

  ///激活成功
  _success() async {
    if (isSuccess) {
      return;
    }

    ///防止重复回调
    bleActive.removeActiveStatusListener(_onActiveStatus);

    logs.add('蓝牙激活成功');
    logs.add('sn: ${model.deviceId}');
    logs.add('mac: ${model.devMac}');
    logs.add('adminToken: ${model.adminToken}');
    logs.add(
        '本地authKey: ${DoorLockKeyValueLocal.authKey(deviceId: model.deviceId)}');
    _updateView();

    ///支持蓝牙netip协议的锁不走后续锁板步骤（无低功耗锁板能力）
    if (DoorLockHelper.isSuppportBleNetip(
        deviceId: model.deviceId, activeResponse: activeResponse)) {
      logs.add('支持蓝牙netip协议，跳过锁板可选步骤');
      isSuccess = true;
      _updateView();

      ///设置设备昵称
      await askDeviceNickname();
      await addDeviceToService();

      ///国内锁：通知设备激活成功 + 开蓝牙netip + 影子服务链路
      if (isAddServiceSuccess) {
        await _doCnLockFinish();
      }
      return;
    }

    isSuccess = true;
    _updateView();

    ///激活后: 锁板能力集(EB) → 产品额外信息 → 强制添加密码管理员 → KV上报 → 同步时区
    await startGetDoorLockAbilityIfNeed();

    await startGetManager();

    startUploadInfo();

    if (addManagerDone != false) {
      await startSyncTime();

      ///设置设备昵称
      await askDeviceNickname();

      ///添加服务器
      await addDeviceToService();

      ///海外锁：上传QSPID到Caps
      if (isAddServiceSuccess) {
        await _updateQsPID();
      }
    }

    logs.add('激活后步骤完成');
    _updateView();

  }

  ///设置设备昵称
  askDeviceNickname() async {
    ///先请求推荐的名字List，取第一个
    var adviceNames = <String>[];
    try {
      var result = await addDeviceAPI.queryDeviceAdviceName(
          pid: model.pid, curLanguage: 'zh_CN');
      if (result is List) {
        adviceNames = result.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    var defaultName = adviceNames.isNotEmpty ? adviceNames.first : model.deviceId;
    logs.add('推荐设备名: $adviceNames');
    _updateView();

    var name = await _showNicknameDialog(
        defaultName: defaultName, adviceNames: adviceNames);
    model.deviceName = name;
    logs.add('设备昵称: $name');
    _updateView();
  }

  ///设备昵称弹窗
  Future<String> _showNicknameDialog({
    required String defaultName,
    required List<String> adviceNames,
  }) {
    var textController = TextEditingController()..text = defaultName;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('设置设备名称'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(hintText: '请输入设备名称'),
              ),
              if (adviceNames.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: adviceNames
                        .map((name) => ActionChip(
                              label: Text(name),
                              onPressed: () {
                                textController.text = name;
                              },
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                var name = textController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(dialogContext).pop(name);
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    ).then((name) => name ?? defaultName);
  }

  ///添加服务器
  ///使用静默获取的默认家庭组ID（在model.toJsonMapForPair()中处理）
  addDeviceToService() async {
    logs.add('开始添加服务器(JVSS)');
    _updateView();
    try {
      var body = await model.toJsonMapForPair();
      await addDeviceAPI.addDeviceToUserGroup(body: body);
      hadAddService = true;
      isAddServiceSuccess = true;
      logs.add('添加服务器成功: ${model.deviceId}');

      ///配对添加时，把配网状态同步到服务器（此时配网未开始，上报未配网）
      DoorLockHelper.setDeviceNetProvision(false, model.deviceId);
    } catch (e) {
      hadAddService = true;
      isAddServiceSuccess = false;
      logs.add('添加服务器失败: $e');
    }
    _updateView();
  }

  ///国内锁（支持蓝牙netip）添加服务器后的影子服务链路
  _doCnLockFinish() async {
    logs.add('国内锁影子服务链路开始');
    _updateView();

    ///发送激活成功给设备（指令02，重试5次，失败也继续流程）
    var activeSuccess = false;
    for (var i = 0; i < 5; i++) {
      try {
        if (await bleActive.sendBleActiveSuccess() == true) {
          activeSuccess = true;
          break;
        }
      } catch (e) {
        logs.add('通知设备激活成功失败(${i + 1}/5): $e');
      }
    }
    bleActive.clearListen();
    logs.add(activeSuccess ? '通知设备激活成功(指令02)' : '通知设备激活成功失败，继续流程');
    _updateView();

    ///上报经纬度：demo暂不接 WeatherService，跳过

    ///开启蓝牙netip（获取锁版配置能力集的必要前置）
    await DoorLockHelper.openBlueNetIp(
        sn: model.deviceId,
        mac: model.blueUUID,
        adminToken: model.adminToken);

    ///获取锁版配置能力集 → 影子上报/保活/在线配置/用户信息上报（并行）
    var doorFunctionFuture = _getDoorFunctionAndReport();

    ///同步时间（netip通道）
    var syncTimeFuture = DeviceSyncTime.syncTimeToDevice(deviceId: model.deviceId);

    ///并行等待异步任务组，10秒超时兜底
    try {
      await Future.wait<dynamic>(
              [doorFunctionFuture, syncTimeFuture])
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      logs.add('国内锁影子链路10s超时兜底，继续流程');
    }
    logs.add('国内锁影子服务链路完成');
    _updateView();
  }

  ///获取锁版配置能力集并执行影子上报等后续（重试3次，失败后也继续流程）
  _getDoorFunctionAndReport() async {
    for (var i = 0; i < 3; i++) {
      try {
        var result =
            await DoorLockNetIp.getDoorFunction(deviceId: model.deviceId);
        if (result.item1 != null && result.item2 != null) {
          await _afterGetDoorFunction(result.item1!, result.item2!);
          return;
        }
        logs.add('获取锁版配置能力集失败(${i + 1}/3): ${result.item3}');
      } catch (e) {
        logs.add('获取锁版配置能力集异常(${i + 1}/3): $e');
      }
    }
    logs.add('获取锁版配置能力集重试失败，继续流程');
  }

  ///获取锁版配置能力集成功后的影子服务上报
  _afterGetDoorFunction(
      DoorFunction doorFunctionResult, Map<String, dynamic> data) async {
    try {
      ///保存锁版配置能力集（含 navVersion，配网后管理员检查用）
      doorFunction = doorFunctionResult;

      ///更新锁板能力集
      doorLockBleAbility = doorFunctionResult.doorLockBleAbility;

      ///改写广播包状态（本地标记）：
      ///一体化锁=2：已激活；非一体化锁=4：已激活，需假配网并且需要锁板进行网络重置操作
      var isIntegrated =
          doorLockBleAbility?.byte1.supportUserManager ?? false;
      bleDevice = BleSearchDeviceBySDK.fromJson(
          bleDevice.toJson()..['BTDevExtra'] = isIntegrated ? 2 : 4);
      logs.add('广播包状态改写: extra=${isIntegrated ? 2 : 4}(${isIntegrated ? '一体化锁' : '非一体化锁'})');

      ///上报影子服务
      await JFApi.xcDevice.xcDevSetConfigByShadowServer(
          deviceId: model.deviceId, config: {'DoorFunction': data});

      ///保存到本地
      await DoorLockShadow.saveDoorFunction(model.deviceId, data);
      logs.add('锁版配置能力集影子上报成功');

      ///保活
      var syncStatusResult = await DoorLockNetIp.syncDoorStatus(model.deviceId);
      logs.add('保活syncDoorStatus: ${syncStatusResult.item1}');

      if (syncStatusResult.item1) {
        ///获取配置并上报在线配置
        var configResult =
            await DoorLockNetIp.getDoorLockConfig(model.deviceId);
        if (configResult.item1 && configResult.item2 != null) {
          var rawList =
              parseWifiConfigToRaw(configResult.item2!.data);
          try {
            var datas =
                rawList.map((e) => base64Encode(hexToBytes(e))).toList();
            var cmd = {
              'OPDoorLockProCmd': {
                'DoorConfig': {
                  'RawData': datas,
                }
              }
            };
            await doorlockAPI.saveOnline(sn: model.deviceId, data: cmd);
            logs.add('上报在线配置成功');
          } catch (e) {
            logs.add('上报在线配置失败: $e');
          }
        }

        ///获取锁端全部开锁方式并上报所有用户信息
        var doorOpenTypeResult = await DoorLockNetIp.getDoorOpenType(
            deviceId: model.deviceId, type: JvssOperateType.saveAllUserInfo);
        if (doorOpenTypeResult.item1 &&
            doorOpenTypeResult.item2?.parse is List<DookLockOpenTypeUser>) {
          var users =
              (doorOpenTypeResult.item2?.parse as List<DookLockOpenTypeUser>)
                  .map((e) => <String, dynamic>{
                        'Sn': null,
                        'Id': e.id,
                        'Type': e.type,
                        'Auth': e.auth,
                      })
                  .toList();
          try {
            await doorlockAPI.saveDoorLockUser(
                sn: model.deviceId,
                users: users,
                operationStr: JvssOperationAction.updateAll.value);
            logs.add('上报所有用户信息成功');
          } catch (e) {
            logs.add('上报所有用户信息失败: $e');
          }
        }
      }
    } catch (e) {
      logs.add('影子上报后续处理异常: $e');
    }
  }

  ///上报设备经纬度：demo暂不接 WeatherService，跳过

  ///上传QSPID到Caps（海外锁）
  _updateQsPID() async {
    var qsPid = doorLockExInfo?.pid;
    if (qsPid == null || qsPid.isEmpty) {
      return;
    }
    try {
      await doorlockAPI.syncCaps(
          sn: model.deviceId, caps: {'dev.ext.pid2': qsPid});
      logs.add('上传QSPID成功: $qsPid');
    } catch (e) {
      logs.add('上传QSPID失败: $e');
    }
  }

  ///获取锁板能力集(EB)及锁板额外的产品信息
  startGetDoorLockAbilityIfNeed() async {
    try {
      doorLockBleAbility = await doorLockBleApi.requestAbility();
      logs.add('获取锁板能力集(EB)成功');
    } catch (e) {
      logs.add('获取锁板能力集(EB)失败: $e');
    }

    ///获取锁板额外的产品信息
    if (doorLockBleAbility?.byte4.supportUploadLockExInfo == true) {
      try {
        doorLockExInfo = await doorLockBleApi.requestLockExInfo();
        logs.add('获取锁板产品额外信息成功');
      } catch (e) {
        logs.add('获取锁板产品额外信息失败: $e');
      }
    }
    _updateView();
  }

  ///查询管理员状态&密码，需要时强制添加密码管理员
  startGetManager() async {
    if (doorLockExInfo?.byte1.supportForceRecMgrPswOrChkMgr != true) {
      return;
    }

    ///获取锁板用户的密码长度
    try {
      pwdLengthRange = await doorLockBleApi.requestUserPwdLengthRange();
      logs.add('获取密码长度范围成功: ${pwdLengthRange?.min}-${pwdLengthRange?.max}');
    } catch (e) {
      logs.add('获取密码长度范围失败: $e');
    }

    ///添加服务器前查询管理员状态
    bool needAddManager = false;
    try {
      needAddManager = await doorLockBleApi.requestNeedAddManager();
      logs.add('查询管理员状态成功: needAdd=$needAddManager');
    } catch (e) {
      logs.add('查询管理员状态失败: $e');
    }

    ///强制添加管理员
    if (needAddManager && context.mounted) {
      addManagerDone = false;
      var pwd = await _showAddManagerDialog(
        minLength: pwdLengthRange?.min ?? 6,
        maxLength: pwdLengthRange?.max ?? 8,
      );

      if (pwd == null) {
        ///强制退出，未返回结果
        logs.add('用户取消添加密码管理员');
        stop();
        return;
      }

      ///添加密码管理员
      try {
        Completer completer = Completer();
        StreamSubscription<DoorLockAddBleOpenTypeResponse>? sub;
        sub = doorLockBleApi
            .addPwdManager(pwd)
            .listen((DoorLockAddBleOpenTypeResponse response) {
          switch (response.stage) {
            case BleInputStage.process:
            case BleInputStage.start:
              break;
            case BleInputStage.fail:
              logs.add('添加密码管理员失败: ${response.error.value}');
              !completer.isCompleted ? completer.complete() : null;
              break;
            case BleInputStage.appCancel:
              logs.add('添加密码管理员被取消');
              sub?.cancel();
              !completer.isCompleted ? completer.complete() : null;
              break;
            case BleInputStage.done:
              addManagerDone = true;
              logs.add('添加密码管理员成功');
              sub?.cancel();
              !completer.isCompleted ? completer.complete() : null;
              break;
            default:
              !completer.isCompleted ? completer.complete() : null;
              sub?.cancel();
              break;
          }
          _updateView();
        });

        await completer.future;
      } catch (e) {
        logs.add('添加密码管理员异常: $e');
      }
    }
    _updateView();
  }

  ///强制添加密码管理员弹窗，返回 null 表示用户取消
  Future<String?> _showAddManagerDialog({
    required int minLength,
    required int maxLength,
  }) {
    var controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('设置管理员密码'),
          content: TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration:
                InputDecoration(hintText: '请输入$minLength-$maxLength位数字密码'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                var pwd = controller.text;
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

  ///存储一些属性到服务器&本地，方便获取
  startUploadInfo() {
    if (doorLockExInfo != null) {
      var exInfo = doorLockExInfo!;
      doorlockAPI.keyValueInsertOrUpdate(
          deviceNo: model.deviceId,
          key: 'supportLowPowerBle',
          value: exInfo.byte1.supportBluetoothOnLockPlate ? "1" : "0");
      DoorLockKeyValueLocal.saveSupportLowPowerBle(
          model.deviceId, exInfo.byte1.supportBluetoothOnLockPlate);

      doorlockAPI.keyValueInsertOrUpdate(
          deviceNo: model.deviceId,
          key: 'supportConnectToWifi',
          value: exInfo.byte2.supportConnectToWiFi ? "1" : "0");
      DoorLockKeyValueLocal.saveSupportConnectToWifi(
          model.deviceId, exInfo.byte2.supportConnectToWiFi);

      doorlockAPI.keyValueInsertOrUpdate(
          deviceNo: model.deviceId,
          key: 'supportUpgradeByLockPlate',
          value: exInfo.byte2.supportUpgradeByLockPlate ? "1" : "0");
      DoorLockKeyValueLocal.saveSupportUpgradeByLockPlate(
          model.deviceId, exInfo.byte2.supportUpgradeByLockPlate);

      logs.add('锁板扩展属性已上报KV');
    }
  }

  ///同步时区/夏令时/锁端时间/jvss基准年
  ///hadAddService: 是否已添加服务器（第 3 步后置 true，基准年需设备先入库）
  startSyncTime({bool hadAddService = false}) async {
    ///同步夏令时
    try {
      await doorLockBleApi.syncDst();
      logs.add('同步夏令时成功');
    } catch (e) {
      logs.add('同步夏令时失败: $e');
    }

    ///同步锁端时间
    try {
      await doorLockBleApi.syncTime();
      logs.add('同步锁端时间成功');
    } catch (e) {
      logs.add('同步锁端时间失败: $e');
    }

    ///jvss更新基准年
    if (hadAddService && syncJvssBaseYear != true) {
      try {
        var year = DateTime.now().year;
        await doorlockAPI.addOrUpdateDeviceYear(
            deviceSn: model.deviceId, activeYear: year, pwdYear: year);
        syncJvssBaseYear = true;
        logs.add('jvss更新基准年成功');
      } catch (e) {
        syncJvssBaseYear = false;
        logs.add('jvss更新基准年失败: $e');
      }
    }
    _updateView();
  }

  _fail() {
    if (isFail || isSuccess) {
      return;
    }
    isFail = true;
    bleActive.stop();
    _updateView();
  }

  stop() {
    bleActive.stop();
    logs.add('停止蓝牙配对');
    _updateView();
  }

  _updateView() {
    if (hasListeners) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    bleActive.dispose();
    super.dispose();
  }
}
