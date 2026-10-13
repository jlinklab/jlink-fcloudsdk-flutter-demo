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

}

WeatherService weatherService = WeatherService(DioConfig.getDio());
