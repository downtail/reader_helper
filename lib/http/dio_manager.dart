import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reader_helper/http/api_exception.dart';
import 'package:reader_helper/http/base_response.dart';

/// @author yi1993
/// @created at 2022/4/4
/// @description: DioManager

final BaseOptions _options = BaseOptions(
  connectTimeout: 10 * 1000,
  sendTimeout: 10 * 1000,
  receiveTimeout: 10 * 1000,
);
final Dio _dio = Dio(_options);

enum Method {
  get,
  post,
}

class DioManager {
  static final DioManager _dioManager = DioManager._();

  DioManager._() {
    init();
  }

  static Future<void> initCookiesSetting() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    var cj = PersistCookieJar(ignoreExpires: true, storage: FileStorage(appDocPath + "/.cookies/"));
    DioManager()._getDio().interceptors.add(CookieManager(cj));
  }

  factory DioManager() => _dioManager;

  void init() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio _getDio() {
    return _dio;
  }

  Future<T?> get<T>(
    String url, {
    Map<String, dynamic>? params,
    bool formatted = true,
    T Function(Map<String, dynamic> data)? majorFunc,
    T Function(List<dynamic> data)? minorFunc,
    String field = 'data',
  }) async {
    return request<T>(
      Method.get,
      url,
      params: params,
      formatted: formatted,
      majorFunc: majorFunc,
      minorFunc: minorFunc,
      field: field,
    );
  }

  Future<T?> post<T>(
    String url, {
    Map<String, dynamic>? params,
    bool formatted = true,
    T Function(Map<String, dynamic> data)? majorFunc,
    T Function(List<dynamic> data)? minorFunc,
    String field = 'data',
  }) async {
    return request<T>(
      Method.post,
      url,
      params: params,
      formatted: formatted,
      majorFunc: majorFunc,
      minorFunc: minorFunc,
      field: field,
    );
  }

  Future<T?> request<T>(
    Method method,
    String url, {
    Map<String, dynamic>? params,
    bool formatted = true,
    T Function(Map<String, dynamic> data)? majorFunc,
    T Function(List<dynamic> data)? minorFunc,
    String field = 'data',
  }) async {
    Map<String, dynamic> data = params ?? {};
    try {
      Response response;
      if (method == Method.get) {
        response = await _getDio().get(
          url,
          queryParameters: data,
        );
      } else if (method == Method.post) {
        response = await _getDio().post(
          url,
          data: data,
        );
      } else {
        throw ApiException(
          ApiException.errNetwork,
          errCode: -1,
          errMessage: '请求方法缺失',
        );
      }
      if (response.statusCode != 200) {
        throw ApiException(
          ApiException.errNetwork,
          errCode: response.statusCode,
          errMessage: response.statusMessage,
        );
      }
      if (formatted) {
        return _makeVerificationBeforeUse<T>(
          response,
          majorFunc: majorFunc,
          minorFunc: minorFunc,
          field: field,
        );
      } else {
        return getRealGeneric<T>(response.data);
      }
    } catch (e, s) {
      _handleException(e);
      rethrow;
      //log(s.toString(), name: 'ErrHandler');
    }
  }

  T? _makeVerificationBeforeUse<T>(
    Response response, {
    T Function(Map<String, dynamic> data)? majorFunc,
    T Function(List<dynamic> data)? minorFunc,
    String field = 'data',
  }) {
    BaseResponse<T> data = BaseResponse.fromJson(
      response.data,
      majorFunc: majorFunc,
      minorFunc: minorFunc,
      field: field,
    );
    if (data.code != 200) {
      throw ApiException(
        ApiException.errBusiness,
        errCode: data.code,
        errMessage: data.message,
      );
    }
    return data.data;
  }

  _handleException(err) {
    if (err is ApiException) {
    } else if (err is DioError) {}
    //throw err; //捕获异常后仍然抛出?
  }
}
