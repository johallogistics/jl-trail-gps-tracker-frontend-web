  import 'dart:html' as html;
  import 'dart:js' as js;
  import 'package:js/js.dart'; // <-- correct package for @JS
  import 'package:flutter/foundation.dart' show kIsWeb;
  import 'package:flutter/material.dart';
  import 'dart:ui_web' as ui;

  class LiveTrackingWebMap extends StatefulWidget {
    final double currentLat;
    final double currentLng;
    final double destLat;
    final double destLng;

    const LiveTrackingWebMap({
      super.key,
      required this.currentLat,
      required this.currentLng,
      required this.destLat,
      required this.destLng,
    });

    @override
    State<LiveTrackingWebMap> createState() => _LiveTrackingWebMapState();
  }

  class _LiveTrackingWebMapState extends State<LiveTrackingWebMap> {
    void _waitForSdkAndInit() {
      if (js.context.hasProperty('mapplsReady') &&
          js.context['mapplsReady'] == true) {
        js.context.callMethod('initMapplsMap', [
          'map-div',
          widget.currentLat,
          widget.currentLng,
          widget.destLat,
          widget.destLng,
        ]);
      } else {
        Future.delayed(const Duration(milliseconds: 300), _waitForSdkAndInit);
      }
    }

    @override
    void initState() {
      super.initState();
      _waitForSdkAndInit();
    }


    @override
    Widget build(BuildContext context) {
      const viewId = 'map-div';

      if (kIsWeb) {
        // Register HTML container for Mappls
        // ignore: undefined_prefixed_name
        ui.platformViewRegistry.registerViewFactory(
          viewId,
              (int id) {
            final element = html.DivElement()
              ..id = viewId
              ..style.width = '100%'
              ..style.height = '100%';
            return element;
          },
        );
      }

      return SizedBox.expand(
        child: const HtmlElementView(viewType: viewId),
      );
    }
  }
