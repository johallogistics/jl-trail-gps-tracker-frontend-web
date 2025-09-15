import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  static Future<String?> getDeviceId() async {
    if (kIsWeb) {
      // ❌ Web flow doesn’t need deviceId
      return null;
    }

    final deviceInfo = DeviceInfoPlugin();

    try {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // ✅ unique per device
    } catch (e) {
      return DateTime.now().millisecondsSinceEpoch.toString(); // fallback
    }
  }
}
