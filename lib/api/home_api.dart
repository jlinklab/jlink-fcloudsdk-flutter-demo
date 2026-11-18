import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/http.dart';
import 'package:retrofit/error_logger.dart';
import 'package:fcloudsdk_example/api/core/api_url.dart';
import 'package:fcloudsdk_example/api/core/dio_config.dart';
import 'package:fcloudsdk_example/models/user_room.dart';

part 'home_api.g.dart';

///脚本  flutter packages pub run build_runner build

@RestApi(
    baseUrl: "https://cn-ams.jftechws.com", parser: Parser.JsonSerializable)
abstract class HomeAPI {
  factory HomeAPI(Dio dio, {String baseUrl}) = _HomeAPI;

  ///查询家庭组下面都有哪些房间
  @POST('/v3/room/getRoomListByPage$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<UserRoomResponse> getRoomByGrop(@Body() Map<String, dynamic> body);
}

HomeAPI homeAPI = HomeAPI(DioConfig.getDio());
