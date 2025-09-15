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

  final headers = [
    'ID', 'Shift', 'OT Hours', 'Vehicle', 'Reg No', 'Chassis No', 'GVW',
    'Payload', 'Vehicle No', 'In Time', 'Out Time', 'Working Hours',
    'Starting KM', 'Ending KM', 'Total KM', 'From', 'To', 'Present Location',
    'Fuel Avg', 'Prev KMPL', 'Trial KMPL', 'Cluster KMPL', 'Trial KMS',
    'ODO Start', 'ODO End', 'Sweet Spot HW', 'Sweet Spot NR', 'Sweet Spot Hill',
    'Trial Allocation', 'Purpose', 'Reason', 'Date of Sale', 'Customer Name',
    'Customer Driver', 'Customer Driver No', 'Dealer Name', 'VECV Reporting',
    'Driver Status', 'Customer Vehicle', 'Cap. Vehicle', 'Cap. Cust/Vehicle',
    'Co-Driver', 'Co-Driver Phone', 'Incharge Sign', 'Employee Name',
    'Employee Phone', 'Employee Code', 'Month-Year', 'DICV Incharge',
    'DICV Phone', 'Trail ID'
  ];

  final rows = <List<dynamic>>[];
  rows.add(headers);

  for (final log in logs) {
    rows.add([
      _fmt(log.id),
      _fmt(log.shift),
      _fmt(log.otHours),
      _fmt(log.vehicleModel),
      _fmt(log.regNo),
      _fmt(log.chassisNo),
      _fmt(log.gvw),
      _fmt(log.payload),
      _fmt(log.vehicleNo),
      _fmt(log.inTime is DateTime ? log.inTime : (log.inTime != null ? DateTime.tryParse(log.inTime.toString()) : null)),
      _fmt(log.outTime is DateTime ? log.outTime : (log.outTime != null ? DateTime.tryParse(log.outTime.toString()) : null)),
      _fmt(log.workingHours),
      _fmt(log.startingKm),
      _fmt(log.endingKm),
      _fmt(log.totalKm),
      _fmt(log.fromPlace),
      _fmt(log.toPlace),
      _fmt(log.presentLocation),
      _fmt(log.fuelAvg),
      _fmt(log.previousKmpl),
      _fmt(log.trialKMPL),
      _fmt(log.clusterKmpl),
      _fmt(log.trialKMS),
      _fmt(log.vehicleOdometerStartingReading),
      _fmt(log.vehicleOdometerEndingReading),
      _fmt(log.highwaySweetSpotPercent),
      _fmt(log.normalRoadSweetSpotPercent),
      _fmt(log.hillsRoadSweetSpotPercent),
      _fmt(log.trialAllocation),
      _fmt(log.purposeOfTrial),
      _fmt(log.reason),
      _fmt(log.dateOfSale),
      _fmt(log.customerName),
      _fmt(log.customerDriverName),
      _fmt(log.customerDriverNo),
      _fmt(log.dealerName),
      _fmt(log.vecvReportingPerson),
      _fmt(log.driverStatus),
      _fmt(log.customerVehicle),
      _fmt(log.capitalizedVehicle),
      _fmt(log.capitalizedVehicleOrCustomerVehicle),
      _fmt(log.coDriverName),
      _fmt(log.coDriverPhoneNo),
      _fmt(log.inchargeSign),
      _fmt(log.employeeName),
      _fmt(log.employeePhoneNo),
      _fmt(log.employeeCode),
      _fmt(log.monthYear),
      _fmt(log.dicvInchargeName),
      _fmt(log.dicvInchargePhoneNo),
      _fmt(log.trailId),
    ]);
  }

  final csv = const ListToCsvConverter().convert(rows);
  final bytes = utf8.encode(csv);
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
