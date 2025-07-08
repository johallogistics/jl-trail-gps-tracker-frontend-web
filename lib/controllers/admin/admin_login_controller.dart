import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AdminLoginController extends GetxController {
  static const String baseUrl = "https://jl-trail-gps-tracker-backend-production.up.railway.app";
  final storage = GetStorage(); // Initialize storage

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      storage.write('token', token); // ✅ Save token

      print("TOKEN:: $token");
      Get.offAllNamed('/dashboard'); // Navigate to dashboard
    } else {
      Get.snackbar("Login Failed", "Invalid username or password");
    }
  }
}
