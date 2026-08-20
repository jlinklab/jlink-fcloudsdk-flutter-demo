import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:fcloudsdk/api/api_center.dart';

///添加设备的方式
//wifi、blueTooth、deviceScanCode这总体上都属于配网的
enum AddDeviceType {
  wifi, //wifi配网
  blueTooth, //蓝牙配网
  deviceScanCode, //二维码配网
  localNet, //局域网 - 无需配网直接添加
  scan, //手机扫码(设备的二维码) - 无需配网直接添加
}

class DeviceAddModel {
  String deviceId = '';
  String loginName = 'admin';
  String loginPassword = '';
  String ip = '';
  String port = '';
  String adminToken = '';
  String guestToken = '';
  String hostName = ''; //设备本身的名称 和 昵称不同
  String deviceName = ''; //设备昵称
  String pid = '';
  String cryNum = ''; //特征码
  int type = 0; // 设备类型，先给个默认的类型
  int retryTimes = 0; //重试次数，大于0就是需要重试
  bool isSupportRandom = false; //是否支持随机登录名和密码
  bool isSupportAutoChangeRandom = false; //支持设置随机登录名和密码
  bool isSupportToken = false; //是否支持token
  bool isNeedRestart = false; //是否需要重启重新配置
  AddDeviceType addDeviceType = AddDeviceType.wifi;
  String extInfo = ''; //额外信息
  String devMac = '';
  bool? delOth; //是否删除别人的设备
  bool? ma; //是否设为主账号 是否是主账号添加

  String toJsonString() {
    Map<String, dynamic> map = {};
    map['uuid'] = deviceId;
    map['username'] = loginName;
    map['password'] = loginPassword;
    map['ip'] = ip;
    map['port'] = port;
    if (adminToken.isNotEmpty) {
      Map tokenMap = {'AdminToken': adminToken};
      if (guestToken.isNotEmpty) {
        tokenMap['GuestToken'] = guestToken;
      }
      map['deviceToken'] = tokenMap;
    }
    map['nickname'] = deviceName;
    map['type'] = type;
    map['pid'] = pid;
    map['extinfo'] = extInfo;
    if (cryNum.isNotEmpty) {
      map['cryNum'] = cryNum;
    }
    if (ma != null) {
      map['ma'] = ma!.toString();
    }
    if (delOth != null) {
      map['delOth'] = delOth!.toString();
    }
    return json.encode(map);
  }

  ///wifi配网成功后，处理返回来的数据
  ///jsonStr:  {"randomUser":"","hostName":"IPC","type":24,"pid":"A908007CF000000H","deviceSn":"44b9dc1867ef3bea","randomPwd":"","resume":""}
  static DeviceAddModel genFromWifiDevice(String jsonStr) {
    //   {
    //     "HostIP":	"0x702a8c0",
    //   "HostName":	"IPC",
    //   "DeviceType":	7,
    //   "MAC":	"30:ff:f6:8c:14:9f",
    //   "SN":	"d0af4c4d5d70f965",
    //   "TCPPort":	34567
    // }
    Map<String, dynamic> pMap = json.decode(jsonStr);
    DeviceAddModel model = DeviceAddModel();
    model.addDeviceType = AddDeviceType.wifi;
    model.deviceId = pMap['SN'] ?? '';
    model.hostName = pMap['HostName'] ?? '';
    model.type = pMap['DeviceType'] ?? '';
    model.pid = pMap['pid'] ?? '';
    model.loginName = pMap['randomUser'] ?? 'admin';
    model.loginPassword = pMap['randomPwd'] ?? '';
    model.extInfo = pMap['resume'] ?? '';
    return model;
  }

  ///额外的属性或者方法======= 解析蓝牙配网完成的设备
  static DeviceAddModel parseFromDistributeBle(Map map) {
    DeviceAddModel model = DeviceAddModel();
    model.addDeviceType = AddDeviceType.blueTooth;
    model.deviceId = map['SerialNum'] ?? '';
    model.ip = map['IP'] ?? '';
    model.devMac = map['Mac'] ?? '';
    model.loginName = map['RandomUser'] ?? 'admin';
    model.loginPassword = map['RandomPassword'] ?? '';
    model.adminToken = map['Token'] ?? '';
    return model;
  }

  Map<String, dynamic> toJsonMapForDefault() {
    Map<String, dynamic> map = {};
    map['uuid'] = deviceId;
    map['username'] = loginName.isNotEmpty ? loginName : 'admin';
    map['password'] = loginPassword;
    map['ip'] = ip;
    map['port'] = port;
    if (adminToken.isNotEmpty) {
      Map tokenMap = {'AdminToken': adminToken};
      if (guestToken.isNotEmpty) {
        tokenMap['GuestToken'] = guestToken;
      }
      map['deviceToken'] = tokenMap;
    }
    map['nickname'] = deviceName;
    map['type'] = type;
    map['pid'] = pid;
    if (cryNum.isNotEmpty) {
      map['cryNum'] = cryNum;
    }
    if (ma != null) {
      map['ma'] = ma!.toString();
    }
    if (delOth != null) {
      map['delOth'] = delOth!.toString();
    }
    map['extinfo'] = extInfo;
    return map;
  }
}

///全局添加设备中心
class DeviceAddCenter {
  static final DeviceAddCenter instance = DeviceAddCenter();
  final Map<String, DeviceAddModel> _deviceMap = {};
  Function(DeviceAddModel model)? _onCompleteCallback;
  late DeviceAddModel _curModel;

  ///获取设备本地的token
  Future<String> getDeviceLocalToken({required String deviceId}) async {
    return JFApi.xcDevice.xcGetDeviceToken(deviceId: deviceId);
  }

  ///设置设备本地的token
  Future<void> setDeviceLocalToken({
    required String deviceId,
    required String token,
  }) async {
    return JFApi.xcDevice.xcSetDeviceToken(deviceId: deviceId, token: token);
  }

  ///设备登录出
  Future<bool> deviceLoginOut({required String deviceId}) async {
    return JFApi.xcDevice.xcLoginOut(deviceId: deviceId);
  }

  ///获取某个设备的信息
  DeviceAddModel? getDeviceConfigInfo({required String deviceId}) {
    return _deviceMap[deviceId];
  }

  ///最终添加设备添加设备
  ///retrun >= 0 添加成功， < 0 失败
  Future<int> addDeviceWithModel(DeviceAddModel model) async {
    if (kDebugMode) {
      print(
          'DeviceAddCenter---设备添加之流程 3.最终添加 \n 当前设备信息为：${model.toJsonString()}');
    }
    var map = model.toJsonMapForDefault();
    return AccountAPI.instance.xcAddDeviceV1(requestJs: jsonEncode(map));
  }

  ///配置随机用户密码流程
  addDeviceWithConfigRandomDeviceLoginNameAndPasswordProgress(
      {required DeviceAddModel model,
      required Function(DeviceAddModel deviceConfigInfo) onComplete}) async {
    _curModel = model;
    _onCompleteCallback = onComplete;
    if (kDebugMode) {
      print(
          'DeviceAddCenter---设备添加之流程1.配置随机用户密码 \n 当前设备信息为：${model.toJsonString()}');
    }

    ///去配置随机设备登录名和密码
    _configDeviceRandomLoginNameAndPassword(deviceId: _curModel.deviceId);
  }

  ///配置随机设备登录名和密码
  _configDeviceRandomLoginNameAndPassword({required String deviceId}) async {
    ///1.检查设备是否 获取设备随机登录名和密码
    JFApi.xcDevice
        .xcGetDeviceRandomUserInfoNotLogin(deviceId: deviceId)
        .then((value) async {
      final Map rMap = value;
      if (rMap.containsKey('GetRandomUser') == false) {
        if (kDebugMode) {
          print('DeviceAddCenter----获取设备随机登录名和密码失败，使用默认值1');
        }
        _onCompleteRandom();
        return;
      }

      if (rMap['GetRandomUser'] == null) {
        if (kDebugMode) {
          print('DeviceAddCenter----获取设备随机登录名和密码失败，使用默认值2');
        }
        _onCompleteRandom();
        return;
      }

      ///拿到GetRandomUser字段map
      final Map randomUserMap = rMap['GetRandomUser'];

      ///针对IPC，如果设备当前不是随机用户名密码，或者开机超过一个小时，就不会返回Info字段，而是返回InfoUser字段，字段数据格式和加密方式与Info是一样的
      ///需要提示用户重启设备后再尝试添加
      if (randomUserMap.containsKey('InfoUser') == true) {
        if (kDebugMode) {
          print('DeviceAddCenter----获取设备随机登录名和密码失败，需要设备重启后再尝试连接');
        }
        _curModel.isNeedRestart = true;
        _onCompleteRandom();
        return;
      }

      if (randomUserMap['AutoChangeRandomAcc'] != null) {
        ///是否支持自动修改随机用户名密码
        bool isSupportAutoChangeRandom = randomUserMap['AutoChangeRandomAcc'];
        _curModel.isSupportAutoChangeRandom = isSupportAutoChangeRandom;
        debugPrint(
            'DeviceAddCenter---- 是否支持自动修改随机用户名密码: $isSupportAutoChangeRandom');
      }

      ///拿到info字段map
      String randomUserInfoStr = randomUserMap['Info'];

      ///调获取随机用户信息接口解析 randomUserInfoStr字段
      String randomUserInfoData = await JFApi.xcDevice.xcParseRandomUserInfo(
          deviceId: deviceId, encodeDataStr: randomUserInfoStr);
      if (kDebugMode) {
        print('DeviceAddCenter----randomUserInfoData: $randomUserInfoData');
      }
      List<String> dataList = randomUserInfoData.split(' ');
      if (randomUserInfoData.isEmpty ||
          dataList.isEmpty ||
          dataList.length < 2) {
        if (kDebugMode) {
          print('DeviceAddCenter----randomUserInfoStr参数有误，使用默认值3');
        }
        _onCompleteRandom();
        return;
      }

      final String randomDeviceLoginNamePart = dataList[0];
      final String randomDeviceLoginPasswordPart = dataList[1];
      if (randomDeviceLoginNamePart.length <= 3 ||
          randomDeviceLoginPasswordPart.length <= 6) {
        if (kDebugMode) {
          print(
              'DeviceAddCenter----randomDeviceLoginNamePart&randomDeviceLoginPasswordPart参数有误，使用默认值');
        }
        _onCompleteRandom();
        return;
      }

      ///拿到随机用户名和密码
      final String randomDeviceLoginName = dataList[0].substring(3);
      final String randomDeviceLoginPassword = dataList[1].substring(3);

      ///保存下新的设备信息
      _curModel.loginName = randomDeviceLoginName;
      _curModel.loginPassword = randomDeviceLoginPassword;
      _curModel.isSupportRandom = true;
      if (kDebugMode) {
        print(
            'DeviceAddCenter----> 获取到了随机用户名和密码：randomDeviceLoginName:$randomDeviceLoginName, randomDeviceLoginPassword:$randomDeviceLoginPassword');
      }

      ///尝试登录下设备
      _onTryDeviceLogin(
          deviceId: deviceId,
          deviceLoginName: randomDeviceLoginName,
          deviceLoginPassword: randomDeviceLoginPassword);
    }).catchError((result) {
      ///埋点相关 暂时不做
      if (_curModel.addDeviceType == AddDeviceType.blueTooth) {
        // [[XMTracker tracker]trackerEvent:@"bluetooth_get_random_config_error" options:@{@"error_code":@(msg->param1)}];
      } else {
        // [[XMTracker tracker]trackerEvent:@"wifi_get_random_config_error" options:@{@"error_code":@(msg->param1)}];
      }

      result as XCloudAPIException;

      ///是否需要重试
      if (_curModel.retryTimes > 0) {
        if (result.code == -11406 || result.code == -400009) {
          _curModel.retryTimes--;

          ///重试
          _configDeviceRandomLoginNameAndPassword(deviceId: deviceId);
          return;
        }
      }

      ///其他情况就返回默认的
      _onCompleteRandom();
    });
  }

  ///尝试使用设备下发登录名和密码登录
  _onTryDeviceLogin(
      {required String deviceId,
      required String deviceLoginName,
      required String deviceLoginPassword}) async {
    ///1. 先设置设备的登录名和密码
    ///将随机用户名密码保存到本地SDK
    await JFApi.xcDevice.xcSetLocalUserNameAndPwd(
        deviceId: deviceId,
        userName: deviceLoginName,
        pwd: deviceLoginPassword);

    ///2. 再重新登录(获取设备系统信息SDK内部就会重新登录)
    getDeviceSystemInfo(
        deviceId: deviceId,
        onComplete: (bool isSuccess, Map? dataMap) async {
          if (isSuccess) {
            if (kDebugMode) {
              print('DeviceAddCenter----设备登录--成功');
            }
            String token = await DeviceAddCenter.instance
                .getDeviceLocalToken(deviceId: _curModel.deviceId);
            if (token.isNotEmpty) {
              _curModel.isSupportToken = true;
              _curModel.adminToken = token;
            }
            _onSaveLoginInfo(
                deviceId: deviceId,
                deviceLoginName: deviceLoginName,
                deviceLoginPwd: deviceLoginPassword);
          } else {
            if (kDebugMode) {
              print('DeviceAddCenter----设备登录--失败');
            }
            _onCompleteRandom();
          }
        });
  }

  _onSaveLoginInfo(
      {required String deviceId,
      required String deviceLoginName,
      required String deviceLoginPwd}) async {
    ///获取下设备token
    String token =
        await DeviceAddCenter.instance.getDeviceLocalToken(deviceId: deviceId);
    if (kDebugMode) {
      print('DeviceAddCenter----最新的设备token:$token');
    }

    if (token.isEmpty) {
      if (kDebugMode) {
        print('DeviceAddCenter---token为空,返回已知数据');
      }
      _onCompleteRandom();
      return;
    } else {
      ///有token
      _curModel.isSupportToken = true;
      _curModel.adminToken = token;
    }

    ///保存到SDK本地
    await DeviceAddCenter.instance
        .setDeviceLocalToken(deviceId: deviceId, token: token);

    ///不支持自动修改
    if (_curModel.isSupportAutoChangeRandom == false) {
      _onCompleteRandom();
      return;
    }

    ///登出下
    await DeviceAddCenter.instance.deviceLoginOut(deviceId: deviceId);

    ///因为登录出接口没有回调，延迟个1秒钟，保证登出成功
    Future.delayed(const Duration(seconds: 1), () {
      ///再次生成随机的设备用户名和密码
      ///为什么要再次生成一个设备随机登录名和密码：因为第一次的随机登录名和密码手机设备下发的，其每次都是一样的，并不随机，所以需要再生成一次修改掉原来设备下发的
      String newRandomDeviceLoginName = _onGenRandomCode(length: 8);
      String newRandomDeviceLoginPwd = _onGenRandomCode(length: 16);

      ///修改随机登录名和密码
      _changeDeviceRandomLoginNameAndPassword(
              deviceId: deviceId,
              oldRandomDeviceLoginName: deviceLoginName,
              oldRandomDeviceLoginPassword: deviceLoginPwd,
              newRandomDeviceLoginName: newRandomDeviceLoginName,
              newRandomDeviceLoginPassword: newRandomDeviceLoginPwd)
          .then((value) async {
        final Map map = value;
        if (map['success'] == true) {
          if (kDebugMode) {
            print('DeviceAddCenter----设置设备随机登录名和密码---成功');
          }

          // ///将修改成功的密码同步到本地
          // await DeviceAddCenter.instance.setDeviceLocalLoginNameAndPassword(
          //     deviceId: deviceId,
          //     deviceLoginName: newRandomDeviceLoginName,
          //     deviceLoginPassword: newRandomDeviceLoginPwd);
          ///更新新的token
          final adminToken = map['adminToken'];
          final guestToken = map['guestToken'];
          _curModel.adminToken = adminToken;
          _curModel.guestToken = guestToken;
          _curModel.loginName = newRandomDeviceLoginName;
          _curModel.loginPassword = newRandomDeviceLoginPwd;

          ///同步设备登录名和密码给SDK
          await JFApi.xcDevice.xcSetLocalUserNameAndPwd(
              deviceId: deviceId,
              userName: newRandomDeviceLoginName,
              pwd: newRandomDeviceLoginPwd);

          ///同步token给SDK
          await DeviceAddCenter.instance
              .setDeviceLocalToken(deviceId: deviceId, token: adminToken);
          _onCompleteRandom();
        } else {
          if (kDebugMode) {
            print('DeviceAddCenter----设置设备随机登录名和密码---失败-解析失败,返回已知数据');
          }
          _onCompleteRandom();
        }
      }).catchError((e) {
        if (kDebugMode) {
          print('DeviceAddCenter----设置设备随机登录名和密码---失败-接口失败,返回已知数据');
        }
        _onCompleteRandom();
      });
    });
  }

  ///获取设备信息
  getDeviceSystemInfo(
      {required String deviceId,
      required Function(bool isSuccess, Map? dataMap) onComplete}) {
    JFApi.xcDevice
        .xcDevGetSysConfig(
            deviceId: deviceId, commandName: 'SystemInfo', command: 1020)
        .then((value) {
      if (kDebugMode) {
        print('DeviceAddCenter----获取设备信息--成功');
      }
      onComplete(true, value);
    }).catchError((error) {
      if (kDebugMode) {
        print('DeviceAddCenter----获取设备信息--失败');
      }
      onComplete(false, null);
    });
  }

  ///绑定流程
  addDeviceWithConfigDeviceBindProgress(
      {required DeviceAddModel model,
      required Function(DeviceAddModel deviceConfigInfo) onComplete}) {
    if (kDebugMode) {
      print(
          'DeviceAddCenter---设备添加之流程 2.绑定流程  \n 当前设备信息为：${model.toJsonString()}');
    }
    _curModel = model;
    _onCompleteCallback = onComplete;

    ///先进行特征码配置
    _configCryNum();
  }

  ///特征码配置
  _configCryNum() {
    assert(_curModel.deviceId.length > 5, 'DeviceAddCenter---- 设备序列号异常');
    if (_curModel.addDeviceType == AddDeviceType.wifi ||
        _curModel.addDeviceType == AddDeviceType.blueTooth ||
        _curModel.addDeviceType == AddDeviceType.deviceScanCode) {
      _queryCloudCryNum(
          deviceId: _curModel.deviceId,
          onComplete: (bool isSuccess, String cryNum, bool isCanRetry) {
            if (isSuccess) {
              _curModel.cryNum = cryNum;

              ///如果有，说明是token设备并且登录上了，这时候必须要删除原有关系才能添加上
              if (_curModel.cryNum.isNotEmpty) {
                _curModel.delOth = true;
              }
              _configBind(cryNum);
            } else {
              ///需要重试
              if (isCanRetry && _curModel.retryTimes > 0) {
                _curModel.retryTimes--;

                ///递归调用
                _configCryNum();
                return;
              } else {
                _configBind('');
              }
            }
          });
    } else {
      _addNormal();
    }
  }

  /// 查询特征码
  /// Function(bool isSuccess,String cryNum, bool isCanRetry)onComplete
  /// [isSuccess] 是否成功
  /// [cryNum] 特征码
  /// [isCanRetry] 是否可以存在可以重试的情况，上层可以自定义需不需要重试
  _queryCloudCryNum(
      {required String deviceId,
      required Function(bool isSuccess, String cryNum, bool isCanRetry)
          onComplete}) {
    JFApi.xcDevice.xcQueryCloudCryNum(deviceId: deviceId).then((value) {
      final String pCryNum = value;
      if (pCryNum.isNotEmpty) {
        onComplete(true, pCryNum, false);
      } else {
        onComplete(false, '', false);
      }
    }).catchError((e) {
      e as XCloudAPIException;
      if (e.code == -11307) {
        //可以重试
        onComplete(false, '', true);
      }
      onComplete(false, '', false);
    });
  }

  /// 配置绑定关系
  /// 支持读取设备恢复出厂状态，如果是恢复出厂状态下，添加设备（用户登录情况下），设置此用户为主联系人
  /// 需要提供设备读取和设置恢复出厂设置状态标志的接口
  /// 序列号 或者 本地搜索方式添加设备时
  /// 先判断是否有这个能力集
  /// 如果有再去获取这个配置
  /// 如果配置是非绑定 设置为绑定 清空订阅 设置为主账号 如果是绑定 普通添加
  /// 快速配置添加设备时
  /// 先判断是否有这个能力集
  /// 如果有再去获取这个配置
  /// 如果是绑定 使用普通添加 否则 设置为绑定 清空订阅 设置为主账号
  _configBind(String cryNum) {
    ///先获取下设备信息
    getDeviceSystemInfo(
        deviceId: _curModel.deviceId,
        onComplete: (bool isSuccess, Map? dataMap) {
          if (isSuccess) {
            if (kDebugMode) {
              print('DeviceAddCenter----配置绑定关系,获取设备信息--成功');
            }

            ///赋值Pid
            if (_curModel.pid.isEmpty && dataMap!['SystemInfo'] != null) {
              Map subMap = dataMap['SystemInfo'];
              if (subMap['Pid'] != null) {
                _curModel.pid = subMap['Pid'];
              }
            }

            ///检测是否支持app绑定
            checkDeviceSystemFunctionAbilityWithIsSupportAppBind(
                deviceId: _curModel.deviceId,
                onComplete: (bool isSupportAppBind) async {
                  if (isSupportAppBind) {
                    // ///获取下bind状态 0: 没有绑定，1.绑定 2：无效数据
                    // int bindStatus =
                    //     await getBindFlag(deviceId: _curModel.deviceId);
                    getBindFlag(deviceId: _curModel.deviceId)
                        .then((value) async {
                      int bindStatus = value;
                      // bindStatus 只可能是0或1或2
                      if (bindStatus == 0) {
                        //未绑定
                        //那就去绑定下
                        bool isSuccess = await setBindFlag(
                            deviceId: _curModel.deviceId, isBind: true);
                        _curModel.ma = true;
                        _curModel.delOth = true;
                        if (isSuccess && cryNum.isEmpty) {
                          _addNormal();
                        } else {
                          _addSpecify();
                        }
                      } else if (bindStatus == 1) {
                        _curModel.ma = true;
                        if (isSuccess && cryNum.isEmpty) {
                          _addNormal();
                        } else {
                          _addSpecify();
                        }
                      } else {
                        _curModel.ma = true;
                        _addSpecify();
                      }
                    }).catchError((error) {
                      if (isSuccess && cryNum.isEmpty) {
                        _addNormal();
                      } else {
                        _addSpecify();
                      }
                    });
                  } else {
                    if (cryNum.isNotEmpty) {
                      _addSpecify();
                    } else {
                      _addNormal();
                    }
                  }
                });
          } else {
            if (kDebugMode) {
              print('DeviceAddCenter----配置绑定关系,获取设备信息--失败');
            }
            if (cryNum.isNotEmpty) {
              _addSpecify();
            } else {
              _addNormal();
            }
          }
        });
  }

  ///获取设备信息 需要登录
  getDeviceInfo(
      {required String deviceId,
      required int type,
      required Function(
              bool isSuccess, Map<String, dynamic> dataMap, String errorMsg)
          onComplete}) {
    String pType = '';
    if (type == 0) {
      pType = 'SystemInfo';
    } else if (type == 1) {
      pType = 'SystemFunction';
    }
    assert(pType.isNotEmpty, 'DeviceAddCenter---- xcGetDeviceInfo type类型不支持');
    JFApi.xcDevice
        .xcGetDeviceInfo(deviceId: deviceId, type: pType)
        .then((value) {
      onComplete(true, jsonDecode(value), '');
    }).catchError((error) {
      // onComplete(false, {},kErrorMsg(error)!);
    });
  }

  ///普通添加
  _addNormal() {
    _onCompleteBind();
  }

  ///特殊添加
  _addSpecify() async {
    ///清除所有账号订阅 不考虑是否取消成功
    await JFApi.xcAlarmMessage
        .xcCancelAllAlarmSubscribe(deviceList: [_curModel.deviceId]);

    ///设备退出登录
    await JFApi.xcDevice.xcLoginOut(deviceId: _curModel.deviceId);

    ///因为登录出接口没有回调，延迟个1秒钟，保证登出成功
    Future.delayed(const Duration(seconds: 1), () {
      ///获取设备信息接口内部会重新登录
      getDeviceSystemInfo(
          deviceId: _curModel.deviceId,
          onComplete: (bool isSuccess, Map? dataMap) async {
            if (isSuccess) {
              if (kDebugMode) {
                print('DeviceAddCenter----设备登录--成功');
              }
              String token = await DeviceAddCenter.instance
                  .getDeviceLocalToken(deviceId: _curModel.deviceId);
              if (token.isNotEmpty) {
                _curModel.isSupportToken = true;
                _curModel.adminToken = token;
              }

              _continueAdd(isNeedClean: false);
            } else {
              if (kDebugMode) {
                print('DeviceAddCenter----设备登录--失败');
              }
              _continueAdd(isNeedClean: true);
            }
          });
    });
  }

  _continueAdd({required bool isNeedClean}) {
    if (isNeedClean) {
      JFApi.xcDevice.xcSetLocalUserNameAndPwd(
          deviceId: _curModel.deviceId, userName: 'admin', pwd: '');
    }
    _onCompleteBind();
  }

  ///获取设备能力级-是否支持app绑定
  checkDeviceSystemFunctionAbilityWithIsSupportAppBind(
      {required String deviceId,
      required Function(bool isSupportAppBind) onComplete}) {
    JFApi.xcDevice
        .xcDeviceSystemFunctionAbility(deviceId: deviceId)
        .then((value) {
      // BOOL support = jSystemFunction.mOtherFunction.SupportAppBindFlag.Value();
      bool isSupport = true;
      onComplete(isSupport);
    }).catchError((error) {
      onComplete(false);
    });
  }

  ///获取app绑定标志
  /// return Future<int>  0: 没有绑定，1.绑定 2：无效数据
  Future<int> getBindFlag({
    required String deviceId,
  }) async {
    return JFApi.xcDevice.xcGetDeviceAppBindFlag(deviceId: deviceId);
  }

  ///设置绑定标志
  /// return Future<bool> 是否设置成功
  Future<bool> setBindFlag(
      {required String deviceId, required bool isBind}) async {
    return JFApi.xcDevice
        .xcSetDeviceAppBindFlag(deviceId: deviceId, isBind: isBind);
  }

  ///修改设备的随机用户名和密码
  Future<Map<String, dynamic>> _changeDeviceRandomLoginNameAndPassword(
      {required String deviceId,
      required String oldRandomDeviceLoginName,
      required String oldRandomDeviceLoginPassword,
      required String newRandomDeviceLoginName,
      required String newRandomDeviceLoginPassword}) async {
    const commandName = 'ChangeRandomUser';
    final rMap = {
      'Name': commandName,
      commandName: {
        'RandomName': oldRandomDeviceLoginName,
        'RandomPwd': oldRandomDeviceLoginPassword,
        'NewName': newRandomDeviceLoginName,
        'NewPwd': newRandomDeviceLoginPassword
      }
    };
    final String jsStr = jsonEncode(rMap);
    final result = await JFApi.xcDevice.xcDeviceSystemConfigNotLogin(
        deviceId: deviceId,
        commandName: commandName,
        configJs: jsStr,
        configJsLength: jsStr.length,
        cmdReq: 1660,
        timeout: 5000);
    if (result.code < 0) {
      return Future.error(result.code);
    }
    String resultStr = result.data! as String;

    ///数据处理
    resultStr.replaceAll('\n', '');
    resultStr.replaceAll('\t', '');
    final Map<String, dynamic> resultMap = json.decode(resultStr);
    if (resultMap.containsKey('AdminToken') &&
        resultMap.containsKey('GuestToken')) {
      ///组装返回数据
      final rMap = {
        'success': true,
        'adminToken': resultMap['AdminToken'],
        'guestToken': resultMap['GuestToken'],
      };
      return Future.value(rMap);
    } else {
      return Future.value({
        'success': false,
      });
    }
  }

  // ///修改设备本地设备登录名和密码
  // ///修改时，设备的token也会变化
  // setDeviceLocalLoginNameAndPassword(
  //     {required String deviceId,
  //     required String deviceLoginName,
  //     required String deviceLoginPassword}) async {
  //   if (deviceLoginName.isEmpty) {
  //     deviceLoginName = 'admin';
  //   }
  //
  //   if (deviceLoginPassword.isEmpty) {
  //     deviceLoginPassword = '';
  //   }
  //
  //   //限制输入设备密码长度不超过64位 防止设备崩溃
  //   assert(deviceLoginPassword.length <= 64,
  //       'deviceLoginPassword String length exceeds 64 characters.');
  //
  //   ///1. 先设置设备的登录名和密码
  //   String tokenBefore = await getDeviceLocalToken(deviceId: deviceId);
  //   await JFApi.xcDevice.xcSetLocalUserNameAndPwd(
  //       deviceId, deviceLoginName, deviceLoginPassword);
  //   String tokenAfter = await getDeviceLocalToken(deviceId: deviceId);
  //   //防止SetLocalUserNameAndPwd之前有token的，set之后就没有token
  //   if (tokenAfter.isEmpty && tokenBefore.isNotEmpty) {
  //     await setDeviceLocalToken(deviceId: deviceId, token: tokenAfter);
  //   }
  // }

  ///随机码部分配置结束
  _onCompleteRandom() {
    if (_onCompleteCallback != null) {
      _onCompleteCallback!(_curModel);
    }
  }

  ///绑定关系部分配置结束
  _onCompleteBind() {
    if (_onCompleteCallback != null) {
      _onCompleteCallback!(_curModel);
    }
  }

  ///生成自定义长度的随机吗
  String _onGenRandomCode({required int length}) {
    String characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    List<String> codeList = List.generate(
        length, (index) => characters[random.nextInt(characters.length)]);
    return codeList.join('');
  }

  /// 清空随机用户名 & 密码 缓存
  clearRandomUserNameAndPwd(String deviceId) async {
    await JFApi.xcDevice.xcLoginOut(deviceId: deviceId);
    await JFApi.xcDevice.xcDeleteDevsInfo(deviceIds: deviceId);
    await JFApi.xcDevice.xcSetLocalUserNameAndPwd(
        deviceId: deviceId, userName: 'admin', pwd: '');
    if (kDebugMode) {
      print('DeviceAddCenter----清空随机用户名 & 密码 缓存');
    }
  }

  /// 尝试登录设备
  tryDeviceLogin(DeviceAddModel curModel) async {
    try {
      ///获取SystemInfo，获取成功代表设备登录成功
      var result = await JFApi.xcDevice.xcDevGetSysConfig(
          deviceId: curModel.deviceId,
          commandName: 'SystemInfo',
          command: 1020);

      ///更新Pid
      if (curModel.pid.isEmpty &&
          result['SystemInfo']['Pid'] != null &&
          result['SystemInfo']['Pid'] is String &&
          (result['SystemInfo']['Pid'] as String).isNotEmpty) {
        curModel.pid = result['SystemInfo']['Pid'];
      }

      await getDeviceLocalToken(deviceId: curModel.deviceId);
    } catch (e) {
      e as XCloudAPIException;
      await JFApi.xcDevice.xcLoginOut(deviceId: curModel.deviceId);
      rethrow;
    }
  }
}
