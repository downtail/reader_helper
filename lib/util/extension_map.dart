/// @author yi1993
/// @created at 2022/4/23
/// @description:
extension MapUtil<K, V> on Map<K, V> {
  Map<K, V> get filterNullValue {
    removeWhere((key, value) => value == null);
    return this;
  }
}
