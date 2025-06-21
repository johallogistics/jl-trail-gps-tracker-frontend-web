import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'dart:html' as html;

Future<void> downloadFileFromUrl(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    final blob = html.Blob([response.bodyBytes]);
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: blobUrl)
      ..setAttribute("download", url.split('/').last)
      ..click();

    html.Url.revokeObjectUrl(blobUrl); // Clean up
  } catch (e) {
    print("❌ Error downloading file: $e");
  }
}




Future<void> downloadFileFromPhoneUrl(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final dir = await getDownloadsDirectory(); // Desktop Downloads folder
      final fileName = p.basename(url);
      final file = File('${dir?.path}/$fileName');
      await file.writeAsBytes(bytes);
      print("✅ Downloaded: $fileName");
    } else {
      print("❌ Failed to download: $url");
    }
  } catch (e) {
    print("❌ Error downloading file: $e");
  }
}
