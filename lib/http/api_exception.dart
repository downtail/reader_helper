/// @author yi1993
/// @created at 2022/4/8
/// @description: 自定义异常

class ApiException {
  int errType;
  int? errCode;
  String? errMessage;

  static const errNetwork = 0x01;
  static const errBusiness = 0x02;

  ApiException(
    this.errType, {
    this.errCode,
    this.errMessage,
  });
}
