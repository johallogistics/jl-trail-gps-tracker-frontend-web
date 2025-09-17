import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../api/api_manager.dart';
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
  String BACKEND_BASE_URL =
      "jl-trail-gps-tracker-backend-production.up.railway.app";
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

    // 📱 Mobile flow
    final storedPhone = box.read('phone') as String?;
    final storedToken = box.read('token') as String?;
    debugPrint('Splash: storedPhone=$storedPhone, token=$storedToken');

    // If no phone stored -> first time -> ask for phone
    if (storedPhone == null) {
      debugPrint('Splash: no stored phone -> ask for phone');
      Get.off(() => PhoneNumberScreen());
      return;
    }

    // try to fetch device id from device
    final deviceId = await DeviceUtils.getDeviceId();
    debugPrint('Splash: deviceId=$deviceId');

    // If deviceId not available -> request phone & OTP again (re-auth)
    if (deviceId == null) {
      debugPrint('Splash: deviceId null -> go to PhoneNumberScreen');
      Get.off(() => PhoneNumberScreen());
      return;
    }

    // We have stored phone AND deviceId. Now check whether driver exists and deviceId matches.
    final driver = await _fetchDriverByPhone(storedPhone);

    if (driver == null) {
      // driver not found -> contact admin and go to phone screen
      debugPrint('Splash: driver not found for $storedPhone');
      await _showContactAdminDialog();
      return;
    }

    // defensive read of deviceId from driver payload
    final driverDeviceId = (driver['deviceId'] ?? driver['device_id'] ?? '') as String;
    debugPrint('Splash: driverDeviceId=$driverDeviceId');

    // If driverDeviceId is empty => first-time driver on server (maybe not saved yet)
    // treat as not-registered-device: let OTP flow handle device registration
    if (driverDeviceId.isEmpty) {
      debugPrint('Splash: driver deviceId empty on server => OTP flow');
      Get.off(() => LoginScreen(phoneNumber: storedPhone));
      return;
    }

    // If deviceId matches -> try direct login
    if (driverDeviceId == deviceId) {
      debugPrint('Splash: deviceId matched -> trying direct login');
      final success = await _tryDirectLogin(storedPhone, deviceId);
      if (success) {
        debugPrint('Splash: direct login success -> Home');
        Get.offAll(() => HomeScreen());
      } else {
        debugPrint('Splash: direct login failed -> go to OTP login');
        // fallback to OTP (login screen)
        Get.off(() => LoginScreen(phoneNumber: storedPhone));
      }
      return;
    } else {
      // deviceId mismatch -> do not allow direct login; force OTP verification
      debugPrint('Splash: deviceId mismatch -> force OTP login');
      // Optionally show a message to user explaining device mismatch
      await Get.defaultDialog(
        title: 'Device mismatch',
        middleText:
        'This device is not registered for the stored phone number. Please verify with OTP.',
        onConfirm: () {
          Get.back();
        },
        textConfirm: 'OK',
      );
      Get.off(() => PhoneNumberScreen());
      return;
    }
  }

  Future<Map<String, dynamic>?> _fetchDriverByPhone(String phone) async {
    try {
      // normalize phone here as backend expects (e.g. +91...)
      final encoded = Uri.encodeComponent(phone);
      final resp = await ApiManager.get('drivers/verify-phone?phone=$encoded');

      debugPrint('verify-phone status=${resp.statusCode} body=${resp.body}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);

        // data should be { exists: true, driver: {...} }
        if (data is Map && data['exists'] == true && data['driver'] is Map) {
          return Map<String, dynamic>.from(data['driver'] as Map);
        }

        // If exists true but driver missing, return null so caller handles fallback
        return null;
      } else if (resp.statusCode == 404) {
        // phone not found
        return null;
      }
    } catch (e) {
      debugPrint('_fetchDriverByPhone error: $e');
    }

    return null;
  }



  Future<void> _showContactAdminDialog() async {
    await Get.defaultDialog(
      title: 'Contact admin',
      middleText:
      'Your account is not registered or not approved. Please contact the admin.',
      onConfirm: () {
        Get.back();
        Get.off(() => PhoneNumberScreen());
      },
      textConfirm: 'OK',
    );
  }

  Future<bool> _tryDirectLogin(String phone, String deviceId) async {
    try {
      // Try ApiManager first (if it returns Response-like object)
      try {
        final resp = await ApiManager.post('login-direct', {'phone': phone, 'deviceId': deviceId});
        debugPrint('login-direct (ApiManager) status=${resp.statusCode} body=${resp.body}');

        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);

          if ((data['success'] == true || data['success'] == 1) && data['token'] != null) {
            final prefs = await SharedPreferences.getInstance();

            final token = data['token'] as String;
            final driverId = data['driver'] != null ? data['driver']['id'].toString() : null;
            // save token + phone + driverId
            await prefs.setString('token', token);
            await prefs.setString('phone', phone);
            if (driverId != null) await prefs.setString('driverId', driverId);

            await box.write('token', token);
            await box.write('phone', phone);
            if (driverId != null) await box.write('driverId', driverId.toString());

            debugPrint('login-direct: saved token and driverId=$driverId');
            return true;
          }
        }
      } catch (e) {
        debugPrint('login-direct via ApiManager failed: $e');
      }

      // fallback to http.post if ApiManager isn't available or fails
      final url = Uri.parse('https://$BACKEND_BASE_URL/login-direct');
      final body = jsonEncode({'phone': phone, 'deviceId': deviceId});
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);
      debugPrint('login-direct (http) status=${response.statusCode} body=${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if ((data['success'] == true || data['success'] == 1) && data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();

          final token = data['token'] as String;
          final driverId = data['driver'] != null ? data['driver']['id'].toString() : null;

          await prefs.setString('token', token);
          await prefs.setString('phone', phone);
          if (driverId != null) await prefs.setString('driverId', driverId);

          await box.write('token', token);
          await box.write('phone', phone);
          if (driverId != null) await box.write('driverId', driverId);

          debugPrint('login-direct(http): saved token and driverId=$driverId');
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('_tryDirectLogin error: $e');
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
