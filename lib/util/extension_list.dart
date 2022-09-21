/// @author yi1993
/// @created at 2022/5/25
/// @description:
extension ListUtil<E> on List<E> {
  bool get isNotEmptyOrNull {
    return _isNotEmptyOrNull(this);
  }
}

bool _isNotEmptyOrNull<E>(List<E>? list) {
  return list != null && list.isNotEmpty;
}
