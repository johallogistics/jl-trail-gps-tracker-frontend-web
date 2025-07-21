import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trail_tracker/utils/app_translations.dart';
import 'package:trail_tracker/utils/auth_middleware.dart';
import 'package:trail_tracker/utils/web_utils.dart';
import 'package:trail_tracker/views/admin/admin_dashboard_screen.dart';
import 'package:trail_tracker/views/admin/admin_login_screen.dart';
import 'package:trail_tracker/views/home_screen.dart';
import 'package:trail_tracker/views/splash_screen.dart';
import 'package:trail_tracker/views/widgets/map_route_screen.dart';
import 'controllers/admin/admin_login_controller.dart';
import 'controllers/new_trail_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    Get.lazyPut(() => AdminLoginController());
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => TrialFormController());

    loadMapmyIndiaCSS();
    // registerMapIframe();
  }

  await GetStorage.init();

  await Supabase.initialize(
    url: 'https://bkzkunjuoshokpilksxp.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJremt1bmp1b3Nob2twaWxrc3hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0ODEwMzAsImV4cCI6MjA2NjA1NzAzMH0.esUaqXN6y88-BroMRW19SyqjVdBNbl_KeI0bJILyS60',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/test',
      getPages: [
        GetPage(name: '/login', page: () => AdminLoginScreen()),
        GetPage(
          name: '/dashboard',
          page: () => DashboardScreen(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/home',
          page: () => HomeScreen(phone: "918925450309"),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(name: '/splash', page: () => SplashScreen()),  //LiveTrackingWebMap
        GetPage(name: '/test', page: () => const LiveTrackingWebMap(currentLat: 12.9716, currentLng: 77.5946, destLat: 13.0827, destLng: 80.2707,))
      ],
      translations: AppTranslations(),
      locale: const Locale('en'),
      fallbackLocale: const Locale('en'),
      title: 'Trail Tracker',
    );
  }
}
