import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trail_tracker/repositories/sign_off_services.dart';
import 'package:trail_tracker/utils/app_translations.dart';
import 'package:trail_tracker/utils/auth_middleware.dart';
import 'package:trail_tracker/views/admin/admin_dashboard_screen.dart';
import 'package:trail_tracker/views/admin/admin_login_screen.dart';
import 'package:trail_tracker/views/admin/privacy_policy_screen.dart';
import 'package:trail_tracker/views/admin/sign_off_list_screen.dart';
import 'package:trail_tracker/views/driver/driver_form_screen.dart';
import 'package:trail_tracker/views/home_screen.dart';
import 'package:trail_tracker/views/splash_screen.dart';
import 'controllers/admin/admin_login_controller.dart';
import 'controllers/new_trail_controller.dart';
import 'controllers/sign_off_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    Get.lazyPut(() => AdminLoginController());
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => TrialFormController());

  await GetStorage.init();

  const apiBaseUrl = "https://jl-trail-gps-tracker-backend-production.up.railway.app";

  Get.lazyPut<SignOffService>(() => SignOffService(apiBaseUrl));
  Get.lazyPut<SignOffController>(() => SignOffController(Get.find<SignOffService>()));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/login', page: () => AdminLoginScreen()),
        GetPage(name: '/privacy', page: () => PrivacyPolicyScreen()),
        GetPage(
          name: '/dashboard',
          page: () => DashboardScreen(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/home',
          page: () => HomeScreen(),
          // middlewares: [AuthMiddleware()],
        ),
        GetPage(
            name: '/splash', page: () => SplashScreen()), //LiveTrackingWebMap
          GetPage(name: '/driver', page: () => DriverFormScreen()),
          GetPage(name: '/signOffList', page: () => const SignOffListScreen()),
      ],
      translations: AppTranslations(),
      locale: const Locale('en'),
      fallbackLocale: const Locale('en'),
      title: 'Trail Tracker',
    );
  }
}

