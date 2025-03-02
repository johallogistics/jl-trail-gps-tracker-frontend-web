import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapmyindia_flutter/MapImage/src/MapmyIndiaStillmap.dart';
import 'package:trail_tracker/utils/app_translations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trail_tracker/views/admin/admin_dashboard_screen.dart';
import 'package:trail_tracker/views/admin/driver_live_location_screen.dart';
import 'package:trail_tracker/views/consolidated_report_screen.dart';
import 'package:trail_tracker/views/test_data.dart';
import 'views/splash_screen.dart';
import 'dart:html' as html;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(Duration(milliseconds: 500));
  String mapImageUrl = MapMyIndiaStillMap("dffc6557266bf7fc552c9ed64a6a3e8f")
      .getMapImage(
    13.0827,80.2707,
  );
  ui.platformViewRegistry.registerViewFactory(
    'mapmyindia-map',
        (int viewId) {
      final img = html.ImageElement()
        ..src = mapImageUrl // Default location
        ..style.width = "600px"  // Set appropriate width
        ..style.height = "300px" // Set appropriate height
        ..style.objectFit = "cover" // Ensure image covers the area
        ..onError.listen((event) => print("Image failed to load")) // Debugging
        ..onLoad.listen((event) => print("Image loaded successfully")) // Debugging
        ..alt = "Driver Location";

      final div = html.DivElement()
        ..style.display = 'flex'
        ..style.justifyContent = 'center'
        ..style.alignItems = 'center'
        ..style.width = '100%'
        ..style.height = '100%'
        ..append(img);

      return div;
    },
  );
  await GetStorage.init();
  runApp(MyApp());
}

void registerWebView() {
  // Ensure this runs only on web
  if (!identical(0, 0.0)) return;

  // Register the MapMyIndia Map Container
  ui.platformViewRegistry.registerViewFactory(
    'mapmyindia-map',
        (int viewId) {
      final div = html.DivElement()
        ..id = 'map-container'
        ..style.width = '100%'
        ..style.height = '100%';
      return div;
    },
  );
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
      home:  DashboardScreen(),
    );
  }
}