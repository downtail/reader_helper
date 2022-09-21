import 'package:get/get.dart';
import 'package:reader_helper/entity/db/collect_entity.dart';
import 'package:reader_helper/entity/method_entity.dart';
import 'package:reader_helper/util/extension_list.dart';

/// @author yi1993
/// @created at 2022/5/6
/// @description:
class AppController extends GetxController {
  var books = RxList<CollectEntity>([]);
  List<MethodEntity> methods = List.empty(growable: true);
  var targetMethod = Rx<MethodEntity>(MethodEntity(
    methodCode: 0,
    methodName: '暂无来源',
  ));

  setBooks({
    required List<CollectEntity> data,
  }) {
    books.value = data;
    books.refresh();
  }

  setGlobalMethods({
    required List<MethodEntity> data,
  }) {
    methods = data;
    if (methods.isNotEmptyOrNull) {
      targetMethod.value = data[0];
    }
  }

  setCurrentMethod({
    required MethodEntity method,
  }) {
    targetMethod.value = method;
  }

  setMethodCode({
    required int methodCode,
  }) {
    targetMethod.value = methods.firstWhere((element) => element.methodCode == methodCode);
  }

  getTargetMethod({
    required int code,
  }) {
    return methods.firstWhere(
      (element) => element.methodCode == code,
      orElse: () => MethodEntity(
        methodCode: 0,
        methodName: '暂无来源',
      ),
    );
  }
}
