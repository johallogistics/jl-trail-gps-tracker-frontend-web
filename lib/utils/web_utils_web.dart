// Only used on Flutter Web
import 'dart:html' as html;

void loadMapmyIndiaCSS() {
  if (html.document.querySelector(
      'link[rel="stylesheet"][href*="mapmyindia"]') == null) {
    final css = html.LinkElement()
      ..rel = 'stylesheet'
      ..href =
          'https://apis.mappls.com/advancedmaps/api/YOUR_API_KEY/map_sdk.css';
    html.document.head?.append(css);
    print('✅ MapmyIndia CSS loaded at startup.');
  }
}
