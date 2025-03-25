import 'dart:html' as html;
import 'dart:async';
import 'package:js/js_util.dart';

class MapService {
  static bool _mapInitialized = false;          // ✅ Prevent multiple initializations
  static html.ScriptElement? _mapmyIndiaScript; // ✅ Store MapmyIndia SDK reference
  static html.ScriptElement? _leafletScript;    // ✅ Store Leaflet reference
  static dynamic _map;                          // ✅ Store map reference
  static dynamic _marker;                       // ✅ Store marker reference

  /// ✅ Initialize the map only if not already initialized
  static Future<void> initializeMap(double lat, double lng) async {
    print('🔄 Waiting for map container to appear...');

    await _waitForMapContainer();

    print('✅ Map container found. Initializing...');

    if (!_mapInitialized) {
      await _loadLeaflet();           // ✅ Load Leaflet first
      await _loadMapmyIndiaSDK();     // ✅ Load MapmyIndia SDK

      print('✅ Both SDKs loaded. Initializing map...');
      await _waitForLeaflet();
      _initializeMapInstance(lat, lng);
    } else {
      // ✅ If already initialized, just update the map coordinates
      updateMap(lat, lng);
    }

    _mapInitialized = true;  // ✅ Prevent re-initialization
  }

  /// ✅ Load Leaflet Library
  static Future<void> _loadLeaflet() async {
    if (_leafletScript == null) {
      print('🚀 Loading Leaflet...');
      _leafletScript = html.ScriptElement()
        ..type = 'text/javascript'
        ..src = 'https://unpkg.com/leaflet@1.7.1/dist/leaflet.js'
        ..async = true;

      html.document.body?.append(_leafletScript!);

      await _leafletScript!.onLoad.first;
      print('✅ Leaflet loaded!');
    }
  }

  /// ✅ Load Leaflet CSS dynamically
  static Future<void> _loadLeafletCSS() async {
    if (html.document.querySelector('link[rel="stylesheet"][href*="leaflet"]') == null) {
      print('🚀 Loading Leaflet CSS...');
      final css = html.LinkElement()
        ..rel = 'stylesheet'
        ..href = 'https://unpkg.com/leaflet@1.7.1/dist/leaflet.css';

      html.document.head?.append(css);

      await css.onLoad.first;
      print('✅ Leaflet CSS loaded!');
    }
  }


  /// ✅ Load MapmyIndia SDK
  static Future<void> _loadMapmyIndiaSDK() async {
    if (_mapmyIndiaScript == null) {
      print('🚀 Loading MapmyIndia SDK...');
      _mapmyIndiaScript = html.ScriptElement()
        ..type = 'text/javascript'
        ..src = 'https://apis.mappls.com/advancedmaps/api/c3a84b3348cc7861088428534d704753/map_sdk?layer=vector&v=3.0'
        ..async = true;

      html.document.body?.append(_mapmyIndiaScript!);

      await _mapmyIndiaScript!.onLoad.first;
      print('✅ MapmyIndia SDK loaded!');
    }
  }

  /// ✅ Wait for Leaflet (L) to be fully available before initializing the map
  static Future<void> _waitForLeaflet() async {
    print('🔄 Waiting for Leaflet (L) to load...');
    final completer = Completer<void>();

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (hasProperty(html.window, 'L')) {
        print('✅ Leaflet (L) detected!');
        timer.cancel();
        completer.complete();
      }
    });

    return completer.future;
  }
  /// ✅ Map initialization logic with container check
  /// ✅ Map initialization logic with MapmyIndia Marker
  static void _initializeMapInstance(double lat, double lng) {
    final html.Element? container = html.document.getElementById('map-container');

    if (container == null) {
      print('❌ Map container not found. Retrying...');
      Future.delayed(const Duration(seconds: 1), () => _initializeMapInstance(lat, lng));
      return;
    }

    print('✅ Initializing MapmyIndia Map...');

    final html.ScriptElement script = html.ScriptElement();
    script.type = 'text/javascript';
    script.text = '''
    (function() {
      console.log("✅ Creating Map instance...");

      if (window.map) {
        console.log("🔄 Destroying existing map...");
        window.map.remove();
        window.map = null;
      }

      // ✅ Create the map instance
      window.map = new mappls.Map('map-container', {
        center: [${lat}, ${lng}],
        zoom: 14,
        pitch: 45,        // 3D tilt for better visuals
        bearing: 0
      });

      console.log("✅ Map initialized successfully.");

      // ✅ Use MapmyIndia's native marker
      setTimeout(() => {
        console.log("📌 Adding MapmyIndia marker...");

        var marker = new mappls.Marker({
          map: window.map,
          position: {lat: ${lat}, lng: ${lng}},
          icon_url: 'https://cdn-icons-png.flaticon.com/512/684/684908.png',
          icon_size: [40, 40],
          fitbounds: true,
          popup: {
            html: '<b>Driver Location</b><br>Lat: ${lat}, Lng: ${lng}'
          }
        });

        console.log("✅ MapmyIndia Marker added.");
      }, 1500);  // ✅ Delay by 1.5 seconds

    })();
  ''';

    html.document.body?.append(script);
    _map = script;  // ✅ Store map reference
  }


  /// ✅ Ensure the map container exists before initializing the map
  static Future<void> _waitForMapContainer() async {
    final completer = Completer<void>();

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final container = html.document.getElementById('map-container');

      if (container != null) {
        print('✅ Map container detected!');
        timer.cancel();
        completer.complete();
      } else {
        print('❌ Map container not found. Retrying...');
      }
    });

    return completer.future;
  }


  /// 🔄 **Update the map with new coordinates**
  /// 🔄 **Update the map with new coordinates**
  static void updateMap(double lat, double lng) {
    if (!_mapInitialized) {
      print('⚠️ Map not initialized yet! Retrying...');
      Future.delayed(const Duration(seconds: 1), () => updateMap(lat, lng));
      return;
    }

    final html.ScriptElement script = html.ScriptElement();
    script.type = 'text/javascript';
    script.text = '''
    if (window.map) {
      console.log("✅ Updating map coordinates...");

      // ✅ Update map center
      window.map.setCenter([${lat}, ${lng}]);
      window.map.setZoom(14);

      setTimeout(() => {
        console.log("📌 Updating MapmyIndia marker...");

        var marker = new mappls.Marker({
          map: window.map,
          position: {lat: ${lat}, lng: ${lng}},
          icon_url: 'https://cdn-icons-png.flaticon.com/512/684/684908.png',
          icon_size: [40, 40],
          fitbounds: true,
          popup: {
            html: '<b>Updated Location</b><br>Lat: ${lat}, Lng: ${lng}'
          }
        });

        console.log("✅ Marker updated.");
      }, 1000);  // ✅ Delay by 1 second

    }
  ''';

    html.document.body?.append(script);
  }


  /// ✅ **Destroy map when leaving screen**
  static void destroyMap() {
    if (_mapInitialized && html.document.getElementById('map-container') != null) {
      print('🗑️ Destroying map...');
      final html.ScriptElement script = html.ScriptElement();
      script.type = 'text/javascript';
      script.text = '''
        if (window.map) {
          window.map.remove();
          window.map = null;
          console.log("✅ Map destroyed.");
        }
      ''';
      html.document.body?.append(script);

      _mapInitialized = false;  // Reset flag
    }
  }
}