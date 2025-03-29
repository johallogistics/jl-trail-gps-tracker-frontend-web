import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trail_tracker/utils/app_translations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trail_tracker/views/admin/admin_dashboard_screen.dart';
import 'package:trail_tracker/views/home_screen.dart';
import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(Duration(milliseconds: 500));
  loadMapmyIndiaCSS();
  await GetStorage.init();
  runApp(MyApp());
}


void loadMapmyIndiaCSS() {
  if (html.document.querySelector('link[rel="stylesheet"][href*="mapmyindia"]') == null) {
    final css = html.LinkElement()
      ..rel = 'stylesheet'
      ..href = 'https://apis.mappls.com/advancedmaps/api/c3a84b3348cc7861088428534d704753/map_sdk.css';

    html.document.head?.append(css);
    print('✅ MapmyIndia CSS loaded at startup.');
  }
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
      home: HomeScreen(),
      // home:  DashboardScreen(),
    );
  }
}