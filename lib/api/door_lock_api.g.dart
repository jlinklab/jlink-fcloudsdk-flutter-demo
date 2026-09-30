// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'door_lock_api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _DoorLockAPI implements DoorLockAPI {
  _DoorLockAPI(
    this._dio, {
    this.baseUrl,
    this.errorLogger,
  }) {
    baseUrl ??= 'https://jvss.xmcsrv.net';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<dynamic> setDeviceNetProvision({
    required String deviceSn,
    required String connectNetType,
    required int netProvision,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'deviceNo': deviceSn,
      'connectNetType': connectNetType,
      'netProvision': netProvision,
    };
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/device/setDeviceNetProvision/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> getDeviceNetProvision(
      {required List<String> deviceSn}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'deviceNo': deviceSn};
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/device/getDeviceNetProvision/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> keyValueInsertOrUpdate({
    required String deviceNo,
    required String key,
    required String value,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'deviceNo': deviceNo,
      'specialKey': key,
      'specialValue': value,
    };
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/keyValue/insertOrUpdate/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> addOrUpdateDeviceYear({
    required String deviceSn,
    required int activeYear,
    required int pwdYear,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'deviceSn': deviceSn,
      'activeYear': activeYear,
      'pwdYear': pwdYear,
    };
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/deviceYear/addOrUpdateDeviceYear/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> getKeyPair({required String deviceSn}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'deviceSn': deviceSn};
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/unlockInfo/getKeyPair/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> rollBackKeyPair({required String deviceSn}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _data = {'deviceSn': deviceSn};
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/unlockInfo/rollBackKeyPair/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> saveDoorLockUser({
    required String operationStr,
    required String sn,
    required List<Map<String, dynamic>> users,
    List<int>? userTypes,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'operation': operationStr,
      'sn': sn,
      'users': users,
      'userTypes': userTypes,
    };
    _data.removeWhere((k, v) => v == null);
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/device_cfg/doorLockUser/save/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> syncUnlockInfo({
    required String deviceSn,
    required int syncTime,
    required List<Map<String, dynamic>> infoDTOS,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'deviceSn': deviceSn,
      'syncTime': syncTime,
      'infoDTOS': infoDTOS,
    };
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/unlockInfo/syncUnlockInfo/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> updateToken({
    required String sn,
    required String adminToken,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'sn': sn,
      'adminToken': adminToken,
    };
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/device/updateToken/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> saveOnline({
    required String sn,
    String cset = 'json',
    required Map<String, dynamic> data,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'sn': sn,
      'cset': cset,
      'data': data,
    };
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/device_cfg/config/app/saveOnline/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> syncCaps({
    required String sn,
    required Map<String, dynamic> caps,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{
      r'host': 'caps',
      r'encryot': false,
      r'decrypt': false,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'sn': sn,
      'caps': caps,
    };
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/syncCaps/{timeMillis}/{secret}.caps',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> modifyAlarmMessageNickName({
    required String deviceSn,
    required String userType,
    required String userId,
    required String userNickname,
    required String headPortrait,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'deviceSn': deviceSn,
      'userType': userType,
      'userId': userId,
      'userNickname': userNickname,
      'headPortrait': headPortrait,
    };
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/doorLockUserNickname/insertOrUpdate/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> getUserDeviceListByPage({
    int page = 1,
    int limit = 999,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _data = {
      'page': page,
      'limit': limit,
    };
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/device/getUserDeviceListByPage/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> getSharedDeviceList(Map<String, dynamic> body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/deviceShare/getSharedDeviceList/v2/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<dynamic> getUserGroupListByPage(Map<String, dynamic> body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'host': 'jvss'};
    _headers.removeWhere((k, v) => v == null);
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/v3/userGroup/getUserGroupListByPage/{timeMillis}/{secret}',
          queryParameters: queryParameters,
          data: body,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(
    String dioBaseUrl,
    String? baseUrl,
  ) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
