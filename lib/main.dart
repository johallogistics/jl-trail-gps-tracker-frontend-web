import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trail_tracker/utils/app_translations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trail_tracker/views/admin/admin_dashboard_screen.dart';
import 'package:trail_tracker/views/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(Duration(milliseconds: 500));

  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: Locale('en'),
      fallbackLocale: Locale('en'),
      title: 'Splash to OTP Login',
      home:  HomeScreen(),
    );
  }
}