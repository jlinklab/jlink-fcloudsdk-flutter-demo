import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/http.dart';
import 'package:retrofit/error_logger.dart';
import 'package:fcloudsdk_example/api/core/api_url.dart';
import 'package:fcloudsdk_example/api/core/dio_config.dart';

part 'door_lock_api.g.dart';

///脚本  flutter packages pub run build_runner build

@RestApi(baseUrl: "https://jvss.xmcsrv.net", parser: Parser.JsonSerializable)
abstract class DoorLockAPI {
  factory DoorLockAPI(Dio dio, {String baseUrl}) = _DoorLockAPI;

  ///设置配网状态
  @POST('/v3/device/setDeviceNetProvision$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> setDeviceNetProvision({
    @Field('deviceNo') required String deviceSn,
    @Field('connectNetType') required String connectNetType,
    @Field('netProvision') required int netProvision,
  });

  ///获取配网状态
  @POST('/v3/device/getDeviceNetProvision$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> getDeviceNetProvision({
    @Field('deviceNo') required List<String> deviceSn,
  });

  ///插入key和Value（用于存放设备扩展信息）
  @POST('/v3/keyValue/insertOrUpdate$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> keyValueInsertOrUpdate({
    @Field('deviceNo') required String deviceNo,
    @Field('specialKey') required String key,
    @Field('specialValue') required String value,
  });

  ///新增或更新门锁基准年
  @POST('/v3/deviceYear/addOrUpdateDeviceYear$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> addOrUpdateDeviceYear({
    @Field('deviceSn') required String deviceSn,
    @Field('activeYear') required int activeYear,
    @Field('pwdYear') required int pwdYear,
  });

  ///生成离线秘钥组
  @POST('/v3/unlockInfo/getKeyPair$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> getKeyPair({
    @Field('deviceSn') required String deviceSn,
  });

  ///回退服务器秘钥组
  @POST('/v3/unlockInfo/rollBackKeyPair$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> rollBackKeyPair({
    @Field('deviceSn') required String deviceSn,
  });

  ///保存门锁用户信息
  @POST('/v3/device_cfg/doorLockUser/save$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> saveDoorLockUser({
    @Field('operation') required String operationStr,
    @Field('sn') required String sn,
    @Field('users') required List<Map<String, dynamic>> users,
    @Field('userTypes') List<int>? userTypes,
  });

  ///同步开锁指纹/卡/密码
  @POST('/v3/unlockInfo/syncUnlockInfo$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> syncUnlockInfo({
    @Field('deviceSn') required String deviceSn,
    @Field('syncTime') required int syncTime,
    @Field('infoDTOS') required List<Map<String, dynamic>> infoDTOS,
  });

  ///更新设备token
  @POST('/v3/device/updateToken$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> updateToken({
    @Field('sn') required String sn,
    @Field('adminToken') required String adminToken,
  });

  ///保存门锁在线配置（国内锁）
  @POST('/v3/device_cfg/config/app/saveOnline$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> saveOnline({
    @Field('sn') required String sn,
    @Field('cset') String cset = 'json',
    @Field('data') required Map<String, dynamic> data,
  });

  ///新增或更新门锁固件版本
  @POST('/v3/device/getOrUpdateFirmwareVersion$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> getOrUpdateFirmwareVersion({
    @Field('deviceNo') required String deviceNo,
    @Field('ver') String? ver,
  });

  ///新增或更新门锁配置
  @POST('/v3/doorLockInfo/insertOrUpdateDoorLockInfo$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> insertOrUpdateDoorLockInfo({
    @Field('deviceSn') required String deviceSn,
    @Field('password') String? password,
    @Field('ver') String? ver,
    @Field('volume') String? volume,
    @Field('openModeTime') String? openModeTime,
    @Field('batteryPower') String? batteryPower,
    @Field('autoLock') String? autoLock,
    @Field('supportDeadbolt') String? supportDeadbolt,
    @Field('doorOpenDirection') String? doorOpenDirection,
    @Field('pirDetection') String? pirDetection,
    @Field('keySyncState') bool? keySyncState,
    @Field('yearSyncState') bool? yearSyncState,
    @Field('deviceLanguage') String? deviceLanguage,
    @Field('devLanList') String? devLanList,
    @Field('humanSensor') String? humanSensor,
    @Field('doorUnlockMode') String? doorUnlockMode,
    @Field('doorFaceAlarmTone') String? doorFaceAlarmTone,
    @Field('doorLockAntiPryAlarm') String? doorLockAntiPryAlarm,
    @Field('lockState') bool? lockState,
    @Field('reverseLockState') bool? reverseLockState,
  });

  ///上传caps（QSPID）
  @POST('/api/syncCaps$uselessSegmentCaps')
  @Headers({'host': caps, 'encryot': false, 'decrypt': false})
  Future<dynamic> syncCaps({
    @Field('sn') required String sn,
    @Field('caps') required Map<String, dynamic> caps,
  });

  ///修改云事件（用户）昵称
  @POST('/v3/doorLockUserNickname/insertOrUpdate$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> modifyAlarmMessageNickName({
    @Field('deviceSn') required String deviceSn,
    @Field('userType') required String userType,
    @Field('userId') required String userId,
    @Field('userNickname') required String userNickname,
    @Field('headPortrait') required String headPortrait,
  });

  ///查询设备列表
  @POST('/v3/device/getUserDeviceListByPage$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> getUserDeviceListByPage({
    @Field('page') int page = 1,
    @Field('limit') int limit = 999,
  });

  ///查询分享设备
  @POST('/v3/deviceShare/getSharedDeviceList/v2$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> getSharedDeviceList(@Body() Map<String, dynamic> body);

  ///查询激活信息
  @POST('/v3/sysFuncActive/select$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> sysFuncActiveSelect({
    @Field('deviceNo') required String deviceNo,
  });

  ///插入或更新激活接口
  @POST('/v3/sysFuncActive/insertOrUpdate$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> sysFuncActiveInsertOrUpdate({
    @Field('deviceNo') required String deviceNo,
    @Field('active') required int active,
  });

  ///查询家庭组列表
  @POST('/v3/userGroup/getUserGroupListByPage$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> getUserGroupListByPage(@Body() Map<String, dynamic> body);
}

DoorLockAPI doorlockAPI = DoorLockAPI(DioConfig.getDio());
