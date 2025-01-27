import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Splash to OTP Login',
      home: SplashScreen(),
    );
  }
}
