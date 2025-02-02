import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trail_tracker/utils/app_translations.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: Locale('en'), // Default language
      fallbackLocale: Locale('en'),
      title: 'Splash to OTP Login',
      home: SplashScreen(),
    );
  }
}