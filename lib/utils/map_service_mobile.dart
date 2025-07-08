class MapService {
  static Future<void> initializeMap(double lat, double lng) async {
    print("❌ MapService is not available on mobile.");
  }

  static void updateMap(double lat, double lng) {
    print("❌ updateMap is not supported on mobile.");
  }

  static void destroyMap() {
    print("❌ destroyMap is not supported on mobile.");
  }
}
