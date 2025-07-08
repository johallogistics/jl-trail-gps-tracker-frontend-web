import 'dart:convert';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;

import '../models/shift_log_model.dart';

Future<void> downloadFileFromUrl(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    final blob = html.Blob([response.bodyBytes]);
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: blobUrl)
      ..setAttribute("download", url.split('/').last)
      ..click();

    html.Url.revokeObjectUrl(blobUrl);
    print("✅ Download started in browser.");
  } catch (e) {
    print("❌ Error downloading file on web: $e");
  }
}

void exportShiftLogsToCsvImpl(List<ShiftLog> logs) {
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

  final rows = [
    headers,
    ...logs.map((log) => [
      log.id ?? '',
      log.shift,
      log.otHours.toString(),
      log.vehicleModel,
      log.regNo,
      log.chassisNo,
      log.gvw.toString(),
      log.payload.toString(),
      log.vehicleNo,
      log.inTime.toString(),
      log.outTime.toString(),
      log.workingHours.toString(),
      log.startingKm.toString(),
      log.endingKm.toString(),
      log.totalKm.toString(),
      log.fromPlace,
      log.toPlace,
      log.presentLocation,
      log.fuelAvg.toString(),
      log.previousKmpl.toString(),
      log.trialKMPL,
      log.clusterKmpl.toString(),
      log.trialKMS,
      log.vehicleOdometerStartingReading,
      log.vehicleOdometerEndingReading,
      log.highwaySweetSpotPercent.toString(),
      log.normalRoadSweetSpotPercent.toString(),
      log.hillsRoadSweetSpotPercent.toString(),
      log.trialAllocation,
      log.purposeOfTrial,
      log.reason,
      log.dateOfSale,
      log.customerName,
      log.customerDriverName,
      log.customerDriverNo,
      log.dealerName,
      log.vecvReportingPerson,
      log.driverStatus,
      log.customerVehicle,
      log.capitalizedVehicle,
      log.capitalizedVehicleOrCustomerVehicle,
      log.coDriverName,
      log.coDriverPhoneNo,
      log.inchargeSign,
      log.employeeName,
      log.employeePhoneNo,
      log.employeeCode,
      log.monthYear,
      log.dicvInchargeName,
      log.dicvInchargePhoneNo,
      log.trailId
    ])
  ];

  final csvContent = const ListToCsvConverter().convert(rows);
  final bytes = utf8.encode(csvContent);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'shift_logs.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
}

