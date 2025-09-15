// lib/bindings/signoff_binding.dart
import 'package:get/get.dart';
import '../controllers/sign_off_controller.dart';
import '../repositories/sign_off_services.dart';

class SignOffBinding extends Bindings {
  @override
  void dependencies() {
    // register service first
    Get.lazyPut<SignOffService>(() => SignOffService("https://jl-trail-gps-tracker-backend-production.up.railway.app"));
    // register controller and inject service via Get.find()
    Get.lazyPut<SignOffController>(() => SignOffController(Get.find()));
  }
}