// lib/driver/driver_form_screen.dart
import 'package:flutter/material.dart';
import '../../controllers/sign_off_controller.dart';
import '../../controllers/sign_off_list_controller.dart';
import '../../repositories/sign_off_services.dart';
import '../widgets/sign_off_form.dart';
import 'package:get/get.dart';

class DriverFormScreen extends StatelessWidget {
  DriverFormScreen({super.key});
  final d = Get.find<SignOffController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver – Sign Off Form')),
      body: const SignOffForm(submitRole: 'DRIVER'),
    );
  }
}