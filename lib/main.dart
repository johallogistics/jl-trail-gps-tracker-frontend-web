import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trail_tracker/utils/app_translations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trail_tracker/views/admin/admin_dashboard_screen.dart';
import 'package:trail_tracker/views/admin/admin_login_screen.dart';
import 'package:trail_tracker/views/home_screen.dart';
import 'dart:html' as html;

import 'package:trail_tracker/views/splash_screen.dart';

import 'controllers/admin/admin_login_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.lazyPut(() => AdminLoginController());

  await Future.delayed(Duration(milliseconds: 500));
  await Supabase.initialize(
    url: 'https://bkzkunjuoshokpilksxp.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJremt1bmp1b3Nob2twaWxrc3hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0ODEwMzAsImV4cCI6MjA2NjA1NzAzMH0.esUaqXN6y88-BroMRW19SyqjVdBNbl_KeI0bJILyS60',                  // Replace with your Supabase anon/public API key
  );
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
      initialRoute: '/login', // default initial route
      getPages: [
        GetPage(name: '/login', page: () => AdminLoginScreen()),
        GetPage(name: '/dashboard', page: () => DashboardScreen()),
        GetPage(name: '/home', page: () => HomeScreen(phone: "918925450309")),
        GetPage(name: '/splash', page: () => SplashScreen()),
        // Add more as needed
      ],
      translations: AppTranslations(),
      locale: Locale('en'),
      fallbackLocale: Locale('en'),
      title: 'Splash to OTP Login',
      // home: SplashScreen(),
      // home: HomeScreen(phone: "918925450309"),
      home:AdminLoginScreen(),
      // DashboardScreen(),
    );
  }
}