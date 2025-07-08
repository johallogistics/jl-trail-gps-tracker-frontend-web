import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthMiddleware extends GetMiddleware {
  final storage = GetStorage();

  @override
  RouteSettings? redirect(String? route) {
    final token = storage.read('token');

    if (token == null || token == '') {
      return const RouteSettings(name: '/login'); // Redirect to login if no token
    }
    return null; // Allow navigation if token exists
  }
}
