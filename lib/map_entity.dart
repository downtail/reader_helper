import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:svg_path_parser/svg_path_parser.dart';

void tryCatch(Function f) {
  try {
    f.call();
  } catch (e, stack) {
    log('$e');
    log('$stack');
  }
}

class FFConvert {
  FFConvert._();

  static T? Function<T>(dynamic value) convert = <T>(dynamic value) {
    if (value == null) {
      return null;
    }
    return json.decode(value.toString()) as T?;
  };
}

T? asT<T>(dynamic value, {bool isSetDefaultValue = true}) {
  if (value is T) {
    return value;
  }
  try {
    if (value != null) {
      final String valueS = value.toString();
      if ('' is T) {
        return valueS as T;
      } else if (0 is T) {
        return int.parse(valueS) as T;
      } else if (0.0 is T) {
        return double.parse(valueS) as T;
      } else if (false is T) {
        if (valueS == '0' || valueS == '1') {
          return (valueS == '1') as T;
        }
        return (valueS == 'true') as T;
      } else {
        return FFConvert.convert<T>(value);
      }
    }
  } catch (e, stackTrace) {
    log('asT<$T>', error: e, stackTrace: stackTrace);
  }

  if (isSetDefaultValue) {
    // 处理默认值
    if (T.toString() == 'String') {
      return '' as T;
    } else if (T.toString() == 'int') {
      return 0 as T;
    } else if (T.toString() == 'double') {
      return 0.0 as T;
    } else if (T.toString() == 'bool') {
      return false as T;
    }
  }

  return null;
}

class MapEntity {
  String? name;
  String? path;
  Path? shape;
  List<MapEntity>? children;
  String? code;

  MapEntity({
    this.name,
    this.path,
    this.children,
    this.code,
    this.shape,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'path': path,
      'children': children,
    };
  }

  factory MapEntity.fromJson(Map<String, dynamic> json) {
    final List<MapEntity>? children = json['children'] is List ? <MapEntity>[] : null;
    if (children != null) {
      for (final dynamic item in json['children']!) {
        if (item != null) {
          children.add(MapEntity.fromJson(asT<Map<String, dynamic>>(item)!));
        }
      }
    }
    return MapEntity(
      name: asT<String?>(json['name']),
      path: asT<String?>(json['path']),
      children: children,
      code: asT<String?>(json['code']),
      shape: json['path'] != null ? parseSvgPath(json['path']) : null,
    );
  }

  @override
  String toString() {
    return 'MapEntity{name: $name, path: $path, children: $children, code: $code}';
  }
}
