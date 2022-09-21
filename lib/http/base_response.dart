/// @author yi1993
/// @created at 2022/4/6
/// @description: BaseResponse

class BaseResponse<T> {
  int? code;
  String? message;
  T? data;

  BaseResponse({
    this.code,
    this.message,
    this.data,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic> data)? majorFunc,
    T Function(List<dynamic> data)? minorFunc,
    String field = 'data',
  }) {
    return BaseResponse(
      code: json['code'] as int?,
      message: json['message'] as String?,
      data: json[field] == null
          ? null
          : getRealGeneric<T>(
              json[field],
              majorFunc: majorFunc,
              minorFunc: minorFunc,
            ),
    );
  }
}

T? getRealGeneric<T>(
  dynamic data, {
  T Function(Map<String, dynamic> data)? majorFunc,
  T Function(List<dynamic> data)? minorFunc,
}) {
  if (data is T) {
    return data;
  }
  if (data is String) {
    return data as T;
  } else if (data is int) {
    return data as T;
  } else if (data is double) {
    return data as T;
  } else if (data is bool) {
    return data as T;
  } else if (data is List) {
    if (minorFunc == null) {
      return null;
    }
    return minorFunc(data);
  } else {
    if (majorFunc == null) {
      return null;
    }
    return majorFunc(data);
  }
}
