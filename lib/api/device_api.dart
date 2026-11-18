import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/http.dart';
import 'package:retrofit/error_logger.dart';
import 'package:fcloudsdk_example/api/core/api_url.dart';
import 'package:fcloudsdk_example/api/core/dio_config.dart';

part 'device_api.g.dart';

///脚本  flutter packages pub run build_runner build

@RestApi(
    baseUrl: "https://cn-ams.jftechws.com", parser: Parser.JsonSerializable)
abstract class DeviceAPI {
  factory DeviceAPI(Dio dio, {String baseUrl}) = _DeviceAPI;

  @POST('/v3/device/updateDevice$uselessSegmentBase')
  @Headers({'host': jvss})
  Future<dynamic> updateDevice(@Body() Map<String, dynamic> body);
}

DeviceAPI deviceAPI = DeviceAPI(DioConfig.getDio());
