import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:xcloudsdk_flutter_example/api/core/api_url.dart';
import 'package:xcloudsdk_flutter_example/api/core/dio_config.dart';
import 'package:xcloudsdk_flutter_example/pages/device_setting/model/model.dart';
import 'package:xcloudsdk_flutter_example/pages/share/model/model.dart';

export 'package:dio/src/headers.dart';

part 'share_api.g.dart';

//脚本  flutter packages pub run build_runner build

@RestApi(baseUrl: "https://ams.jftechws.com", parser: Parser.JsonSerializable)
abstract class ShareAPI {
  factory ShareAPI(Dio dio, {String baseUrl}) = _ShareAPI;

  @POST('/usersearch/v3/{timeMillis}/{secret}.rs')
  @Headers({'host': ams})
  @FormUrlEncoded()
  Future<List<SharedUser>> searchUser(@Path('uname') String uname,
      @Path('upass') String upass, @Field('search') String searchName);

  @POST('/deviceShare/v3$uselessSegment')
  @Headers({'host': ams})
  @FormUrlEncoded()
  Future<dynamic> shareToAccount(
    @Field('shareUuid') String shareUuid,
    @Field('acceptId') String acceptId,
    @Field('powers') String powers,
    @Field('permissions') String permissions,
    @Field('shareChannels') String? shareChannels,
    @Field('nickname') String nickname,
    @Field('expireTime') int? expireTime,
  );

  @POST('/mdshareaccept/v3$uselessSegment')
  @Headers({'host': ams})
  @FormUrlEncoded()
  Future<dynamic> acceptSharedDevice(
    @Field('devId') String shareId,
    @Field('nickname') String nickname,
  );

  @POST('/mdsharerefuse/v3$uselessSegment')
  @Headers({'host': ams})
  @FormUrlEncoded()
  Future<dynamic> refuseSharedDevice(@Field('devId') String shareId);

  @POST('/mdsharemylist/v3$uselessSegment')
  @Headers({'host': ams})
  @FormUrlEncoded()
  Future<List<SharedDevice>> mySharedList(@Field('shareUuid') String deviceId);

  @POST('/mdsharelist/v3$uselessSegment')
  @Headers({'host': ams})
  @FormUrlEncoded()
  Future<List<SharedDevice>> mySharedToMeList();

  @POST('/mdsharesetpermission/v3$uselessSegment')
  @Headers({'host': ams})
  @FormUrlEncoded()
  Future<dynamic> changeSharePermission(
      @Field('shareId') String shareId,
      @Field('permissions') String permissions,
      @Field('shareChannels') String? shareChannels);

  @POST('/mdsharedel/v3$uselessSegment')
  @Headers({'host': ams})
  @FormUrlEncoded()
  Future<dynamic> cancelShare(@Field('devId') String shareId);

  /// 二维码分享设备 不支持跨区添加
  @POST('/qrCodeShareDevice/v3$uselessSegment')
  @Headers({'host': ams})
  @FormUrlEncoded()
  Future<dynamic> addShare(
    @Field('shareUuid') String shareUuid,
    @Field('acceptId') String acceptId,
    @Field('powers') String powers,
    @Field('permissions') String permissions,
    @Field('nickname') String nickname,
    @Field('expireTime') int? expireTime,
  );

  /// 添加分享的设备,直接通过userid添加, 支持跨区添加
  @POST('/mdshareadd2/v3$uselessSegment')
  @Headers({'host': ams})
  @FormUrlEncoded()
  Future<dynamic> addDeviceBySharedWithUserId(
    @Field('shareUuid') String shareUuid,
    @Field('acceptId') String acceptId,
    @Field('powers') String powers,
    @Field('permissions') String permissions,
    @Field('shareChannels') String? shareChannels,
    @Field('nickname') String nickname,
    @Field('expireTime') int? expireTime,
  );

  @POST('/setShareNickname/v3$uselessSegment')
  @Headers({'host': ams})
  @FormUrlEncoded()
  Future<dynamic> setShareNickname(
      @Field('shareId') String shareId, @Field('nickname') String nickname);
}

ShareAPI shareAPI = ShareAPI(DioConfig.getDio());
