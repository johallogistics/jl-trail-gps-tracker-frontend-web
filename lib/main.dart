import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trail_tracker/utils/app_translations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trail_tracker/views/consolidated_report_screen.dart';
import 'package:trail_tracker/views/test_data.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
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
      home: FormScreen(),
    );
  }
}