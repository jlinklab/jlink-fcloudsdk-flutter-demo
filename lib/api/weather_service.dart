import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import 'core/dio_config.dart';

export 'package:dio/src/headers.dart';

part 'weather_service.g.dart';

@RestApi(baseUrl: 'https://jlink-weather.jftechws.com')
abstract class WeatherService {
  factory WeatherService(Dio dio, {String baseUrl}) = _WeatherService;

  @GET('/jfweather/weather/queryWeather')
  Future<dynamic> queryWeather(@Queries() Map<String, dynamic> body);

  ///设置设备经纬度
  @POST('/jfweather/device/latlon/save')
  @Headers({'encryot': false, 'decrypt': false})
  Future<dynamic> updateDeviceLatlon({
    @Field('sn') required String sn,
    @Field('lat') required String lat,
    @Field('lon') required String lon,
  });

  ///设备区域信息上报
  @POST('/jfweather/device/latlon/report')
  @Headers({'Content-Type': 'application/x-plist'})
  Future<dynamic> reportDeviceLatlon(@Body() String aesBase64Body);

  ///设备区域信息获取
  @POST('/jfweather/device/latlon/detail')
  @Headers({'Content-Type': 'application/x-plist'})
  Future<dynamic> getDeviceLatlonDetail(@Body() String aesBase64Body);
}

WeatherService weatherService = WeatherService(DioConfig.getDio());
