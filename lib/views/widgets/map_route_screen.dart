import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui_web' as ui;

class LiveTrackingWebMap extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final url = Uri.encodeFull(
        'https://maps.mapmyindia.com/route?start=$currentLat,$currentLng&end=$destLat,$destLng');

    final viewType =
        'mapmyindia-map-${currentLat.toStringAsFixed(4)}-${currentLng.toStringAsFixed(4)}-${destLat.toStringAsFixed(4)}-${destLng.toStringAsFixed(4)}';

    if (kIsWeb) {
      ui.platformViewRegistry.registerViewFactory(
        viewType,
            (int viewId) => html.IFrameElement()
          ..src = url
          ..width = '100%'
          ..height = '100%'
          ..style.border = 'none'
          ..style.height = '500px'
          ..style.width = '100%',
      );
    }

    return SizedBox.expand(
      child: HtmlElementView(viewType: viewType),
    );
  }
}
