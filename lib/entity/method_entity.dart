/// @author yi1993
/// @created at 2022/5/25
/// @description:
List<MethodEntity> toMethodList(List<dynamic> json) => json.map((e) => MethodEntity.fromJson(e)).toList();

class MethodEntity {
  int? methodCode;
  String? methodName;

  MethodEntity({
    this.methodCode,
    this.methodName,
  });

  Map<String, dynamic> toJson() => {
        'methodCode': methodCode,
        'methodName': methodName,
      };

  MethodEntity.fromJson(dynamic json) {
    methodCode = json['methodCode'];
    methodName = json['methodName'];
  }
}
