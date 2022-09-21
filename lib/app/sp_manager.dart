import 'package:shared_preferences/shared_preferences.dart';

/// @author yi1993
/// @created at 2022/5/25
/// @description:
class SpManager {
  static const String methodCode = 'methodCode';
  late final SharedPreferences _sharedPreferences;
  static final SpManager _spManager = SpManager._();

  factory SpManager() => _spManager;

  SpManager._();

  Future<void> initSp() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  int? getMethodCode() {
    return _sharedPreferences.getInt(methodCode);
  }

  Future<void> setMethodCode({
    required int code,
  }) async {
    await _sharedPreferences.setInt(methodCode, code);
  }
}
