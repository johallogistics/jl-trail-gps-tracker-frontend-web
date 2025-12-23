// lib/utils/file_download_service_web.dart
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:csv/csv.dart';

import '../models/shift_log_model.dart';

Future<void> downloadFileFromUrl(String url, {String? filename}) async {
  final req = await html.HttpRequest.request(url, responseType: 'arraybuffer');
  final buffer = req.response as ByteBuffer;
  final blob = html.Blob([buffer]);
  final blobUrl = html.Url.createObjectUrlFromBlob(blob);

  final defaultName = Uri.parse(url).pathSegments.isNotEmpty ? Uri.parse(url).pathSegments.last : 'file';

  final anchor = html.AnchorElement(href: blobUrl)
    ..setAttribute('download', filename ?? defaultName);

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  html.Url.revokeObjectUrl(blobUrl);
}

Future<void> downloadCsv(String csvData, {String filename = 'export.csv'}) async {
  final bytes = utf8.encode(csvData);
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)..setAttribute('download', filename);
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

/// Provide web implementation of exporting ShiftLog list to CSV.
/// Triggers browser download and returns null (no file path on web).
Future<String?> exportShiftLogsToCsvImpl(List<ShiftLog> logs, {String filename = 'shift_logs.csv'}) async {
  String _fmt(dynamic v) {
    if (v == null) return '';
    if (v is DateTime) return v.toIso8601String();
    if (v is bool) return v ? 'true' : 'false';
    if (v is num) return v.toString();
    if (v is List || v is Map) return jsonEncode(v);
    try {
      final toJson = (v as dynamic).toJson;
      if (toJson is Function) return jsonEncode(toJson());
    } catch (_) {}
    return v.toString();
  }

  // New header order as requested
  final headers = [
    'S.NO',
    'DATE',
    'REGION',
    'EMP CODE',
    'DRIVER NAME',
    // 'Allocation', // NEW allocation field (distinct from trialAllocation)
    'Contact No.',
    // 'Designation',
    // 'Native Place',
    // 'Available at',
    'Driver Status',
    'Capitalized Vehicle/Customer Vehicle',
    // 'Purpose of Trial',
    'Reason (If Others)',
    'Date Of Sale',
    'VECV Incharge',
    'Dealer Name',
    'Customer Name',
    'Customer Driver (Name / No)',
    'Present location',
    'Vehicle No.',
    'Chassis No.',
    'Vehicle Model',
    'GVW',
    'Payload',
    'Previous KMPL',
    'Trial KMPL',
    'Cluster KMPL',
    'Vehicle Odometer - Starting reading (Kms.)',
    'Vehicle Odometer - Ending reading (Kms.)',
    'Trial KMS',
    'HighWay Sweet Spot %',
    'Normal Road Sweet Spot %',
    'Hills Road Sweet Spot %',
    'Trial Allocation' // existing trialAllocation (kept at end as requested)
  ];

  final rows = <List<dynamic>>[];
  rows.add(headers);

  for (final log in logs) {
    // Safely read fields and combine where needed
    final customerDriverCombined = [
      if ((log.customerDriverName ?? '').isNotEmpty) log.customerDriverName,
      if ((log.customerDriverNo ?? '').isNotEmpty) log.customerDriverNo
    ].join(' / ');

    rows.add([
      _fmt(log.id), // S.NO
      _fmt(log.date), // DATE
      _fmt(log.region), // REGION (nullable)
      _fmt(log.employeeCode), // EMP CODE
      _fmt(log.employeeName), // DRIVER NAME (mapped to employeeName)
      // _fmt((log as dynamic).allocation ?? ''), // Allocation (new field) — defensive cast to dynamic in case model updated
      _fmt(log.employeePhoneNo), // Contact No.
      // _fmt(log.driverStatus), // Designation (best-fit; adjust if you have a separate designation field)
      // _fmt(log.fromPlace), // Native Place
      // _fmt(log.presentLocation), // Available at
      _fmt(log.driverStatus), // Driver Status (explicit)
      _fmt(log.capitalizedVehicleOrCustomerVehicle), // Capitalized Vehicle/Customer Vehicle
      // _fmt(log.purposeOfTrial), // Purpose of Trial
      _fmt(log.reason), // Reason (If Others)
      _fmt(log.dateOfSale), // Date Of Sale
      _fmt(log.vecvReportingPerson), // VECV reporting Person
      _fmt(log.dealerName), // Dealer Name
      _fmt(log.customerName), // Customer Name
      _fmt(customerDriverCombined), // Customer Driver (Name / No)
      _fmt(log.presentLocation), // Present location
      _fmt(log.vehicleNo), // Vehicle No.
      _fmt(log.chassisNo), // Chassis No.
      _fmt(log.vehicleModel), // Vehicle Model
      _fmt(log.gvw), // GVW
      _fmt(log.payload), // Payload
      _fmt(log.previousKmpl), // Previous KMPL
      // _fmt(log.trialKMPL), // Trial KMPL
      _fmt(log.clusterKmpl), // Cluster KMPL
      _fmt(log.startingKm), // Vehicle Odometer - Starting
      _fmt(log.endingKm), // Vehicle Odometer - Ending
      _fmt(log.totalKm), // Trial KMS
      _fmt(log.highwaySweetSpotPercent), // HighWay Sweet Spot %
      _fmt(log.normalRoadSweetSpotPercent), // Normal Road Sweet Spot %
      _fmt(log.hillsRoadSweetSpotPercent), // Hills Road Sweet Spot %
      _fmt(log.trialAllocation) // Trial Allocation (existing)
    ]);
  }

  final csv = const ListToCsvConverter().convert(rows);
  final bytes = utf8.encode(csv);

  // Web download (same as before)
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);

  // No file path on web — return null.
  return null;
}
