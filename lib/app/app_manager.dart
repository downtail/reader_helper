import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reader_helper/app/app_controller.dart';
import 'package:reader_helper/app/db_manager.dart';
import 'package:reader_helper/app/sp_manager.dart';
import 'package:reader_helper/entity/method_entity.dart';
import 'package:reader_helper/http/data_manager.dart';

/// @author yi1993
/// @created at 2022/5/6
/// @description:
class AppManager {
  static Future<void> init() async {
    Get.put(AppController());
  }

  static Future<void> initMethods() async {
    List<MethodEntity> data = await rootBundle.loadStructuredData(
      'assets/method.json',
      (value) => DataManager().parseMethod(value),
    );
    AppController appController = Get.find<AppController>();
    appController.setGlobalMethods(data: data);
  }

  static void setMethod() async {
    int? methodCode = SpManager().getMethodCode();
    if (methodCode == null || methodCode == 0) {
      return;
    } else {
      AppController appController = Get.find<AppController>();
      appController.setMethodCode(methodCode: methodCode);
    }
  }

  static void initBook() async {
    var data = await DbManager().getCollect();
    AppController appController = Get.find<AppController>();
    appController.setBooks(data: data ?? []);
  }
}
