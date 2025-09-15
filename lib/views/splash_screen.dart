import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/device_utils.dart';
import 'phone_number_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String BACKEND_BASE_URL = "https://jl-trail-gps-tracker-backend-production.up.railway.app";
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (kIsWeb) {
      // 🌐 Web always goes to normal login
      Get.offNamed('/login');
      return;
    }

    // 📱 Android flow
    final storedPhone = box.read('phone');
    final token = box.read('token');

    final deviceId = await DeviceUtils.getDeviceId();


    if (storedPhone == null || deviceId == null) {
      Get.off(() => PhoneNumberScreen());
      return;
    }

    final success = await _tryDirectLogin(storedPhone, deviceId);

    if (success) {
      Get.offAll(() => HomeScreen());
    } else {
      Get.off(() => LoginScreen(phoneNumber: storedPhone));
    }
  }

  Future<bool> _tryDirectLogin(String phone, String deviceId) async {
    try {
      final url = Uri.parse('https://$BACKEND_BASE_URL/login-direct');
      final body = jsonEncode({'phone': phone, 'deviceId': deviceId});
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          await prefs.setString('phone', phone);
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Text(
          'JL',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
