// ignore: depend_on_referenced_packages
import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:xcloudsdk_flutter/api/api_center.dart';
import 'package:xcloudsdk_flutter/api/sdk_init/sdk_init_api.dart';
import 'package:xcloudsdk_flutter_example/api/core/api_url.dart';
import 'package:xcloudsdk_flutter_example/api/core/param_encoder.dart';
import 'package:xcloudsdk_flutter_example/utils/app_config.dart';

///几乎所有的接口都是这种加密方式
///在拦截器中 生成 timeMillis 和 secret 参数, 替换参数之后发起请求
const String uselessSegment = '/{timeMillis}/{secret}.rs';
const String uselessSegmentCaps = '/{timeMillis}/{secret}.caps';
const String uselessSegmentBase = '/{timeMillis}/{secret}';
const String mdsharemylist = 'mdsharemylist';
const String mdsharelist = 'mdsharelist';

///全局网络
class DioConfig {
  static Dio? _dio;

  static Dio getDio() {
    if (_dio == null) {
      _dio = Dio(BaseOptions());
      _dio!.interceptors.addAll([
        HostRedirectInterceptor(),
        RequestInterceptor(),
        SecurityInterceptor(),
        ResponseInterceptor(),
      ]);
      if (kDebugMode) {
        _dio!.interceptors.add(PrettyDioLogger(requestBody: true));
      }
    }
    return _dio!;
  }

  static Dio dio() {
    Dio dio = Dio(BaseOptions());
    dio.interceptors.addAll([
      HostRedirectInterceptor(),
      RequestInterceptor(),
      SecurityInterceptor(),
      ResponseInterceptor(),
    ]);
    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(requestBody: true));
    }
    return dio;
  }
}

///拦截重定向域名
///当国家切换时,请求到对应的域名服务器上
class HostRedirectInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Map<String, dynamic> headers = options.headers;
    if (headers.containsKey('host')) {
      String host = headers['host'];
      options.baseUrl = ApiUrl.getHost(host);
    }
    options.responseType = ResponseType.plain;
    if (options.headers.containsKey('host')) {
      options.headers.remove('host');
    }
    super.onRequest(options, handler);
  }
}

class SecurityInterceptor extends Interceptor {
  String key = '';

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String method = options.method.toLowerCase().trim();
    //约定只关注POST请求，上层应用会将 GET 改为 POST
    if ("post" != method) {
      return super.onRequest(options, handler);
    }

    if (!options.path.endsWith(uselessSegment) &&
        !options.path.endsWith(uselessSegmentBase) &&
        !options.path.endsWith(uselessSegmentCaps)) {
      return super.onRequest(options, handler);
    }

    //加密key
    String json = await SDKInitAPI.instance.getAuthSignInfo();
    Map map = jsonDecode(json);
    String timeMillis = map['TimeMillis'];

    if (kDebugMode) {
      print('secret:${map['Signature']}');
    }

    options.path = options.path
        .replaceAll('{timeMillis}', timeMillis)
        .replaceAll('{secret}', map['Signature']);

    ///  拿到时间戳去取签名和加解密的key
    key = map['AesKey'];

    //加密数据
    debugPrint('参数类型 ${options.data.runtimeType}');
    if (options.data != null) {
      String originBody =
          ParamEncoder.encode(options.data, options.contentType);
      debugPrint('加密前的 body --> $originBody');
      final encryptData =
          await UtilAPI.instance.xcAesEncryptToHexString(originBody, key);
      debugPrint('加密后的 body --> ${encryptData.length}  $encryptData');
      options.data = encryptData;
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if ("post" != response.requestOptions.method.toLowerCase().trim()) {
      super.onResponse(response, handler);
      return;
    }
    // 分享列表走正常解密流程
    bool needDecrypt = response.requestOptions.headers['decrypt'] ?? true;
    if (response.data is String && key.isNotEmpty && needDecrypt) {
      final encryptedData = response.data;
      final decryptedData =
          await UtilAPI.instance.xcAesDecryptToHexString(encryptedData, key);
      response.data = decryptedData;
    }

    super.onResponse(response, handler);
  }
}

class RequestInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String authorizationToken = await JFApi.xcAccount.xcGetRealAccessToken();
    options.headers.addAll(
      {
        'uuid': AppConfig.uuid(),
        'appKey': AppConfig.appKey(),
        'Authorization': authorizationToken,
        'Accept-Language': 'zh_CN',
      },
    );
    super.onRequest(options, handler);
  }
}

class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    //解析
    Map<String, dynamic> responseData = response.data is String
        ? json.decode(response.data)
        : Map.from(response.data);
    int code = responseData['code'] ?? 0;
    if (code != 2000) {
      String errorMessage = responseData['msg'] ?? '';
      if (errorMessage.isNotEmpty) {
        // showError(errorMessage);
      }
      throw BusinessError(code, errorMessage,
          requestOptions: response.requestOptions);
    } else {
      response.data = responseData['data'] ?? response.data;

      response.data ??= {};
      if (response.data is String ||
          response.data is num ||
          response.data is bool) {
        response.data = {'data': response.data};
      }
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null && err.response!.data is Map) {
      String errorMessage = (err.response!.data as Map)['msg'] ?? '';
      if (errorMessage.isNotEmpty) {
        //showError(errorMessage);
      }
    }
    super.onError(err, handler);
  }
}

class BusinessError extends DioException {
  final int code;

  final String errorMessage;

  BusinessError(this.code, this.errorMessage, {required super.requestOptions});
}
