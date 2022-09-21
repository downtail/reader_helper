import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:reader_helper/app/app_manager.dart';
import 'package:reader_helper/app/db_manager.dart';
import 'package:reader_helper/app/sp_manager.dart';
import 'package:reader_helper/http/dio_manager.dart';
import 'package:reader_helper/ui/index_page.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  //设置状态栏&通知栏属性
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ),
  );
  await Future.wait(
    [
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
        ],
      ), //设置屏幕方向
      DioManager.initCookiesSetting(), //设置cookie
      AppManager.init().then(
        (value) => AppManager.initMethods(),
      ), //初始化全局变量
      SpManager().initSp(),
      DbManager().init(),
    ],
  )
      .then(
        (value) => AppManager.setMethod(),
      )
      .then(
        (value) => AppManager.initBook(),
      )
      .then((value) => runApp(
            const MyApp(),
          ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 3200),
      child: const IndexPage(),
      builder: (child) => GetMaterialApp(
        title: '阅读助手',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: child,
      ),
    );
  }
}
