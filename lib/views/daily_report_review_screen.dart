// daily_report_review_screen.dart
import 'dart:typed_data' as td;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/shift_log_model.dart';
import '../utils/image_upload_service.dart';
import '../utils/pdf_service.dart';
import '../utils/upload_signature.dart';
import 'daily_report_screen.dart';

class DailyReportReviewScreen extends StatefulWidget {
  final td.Uint8List? signature;
  final ShiftLog? shiftLog;

  DailyReportReviewScreen({
    super.key,
    this.signature,
    this.shiftLog,
  });

  @override
  State<DailyReportReviewScreen> createState() => _DailyReportReviewScreenState();
}

class _DailyReportReviewScreenState extends State<DailyReportReviewScreen> {
  final DailyReportController controller = Get.find<DailyReportController>();

  List<String> urls = [];
  bool uploading = false;
  bool submitting = false;

  /// Safe getter: returns from model (cast to String) if exists & non-empty, else fallback, else '-'
  String s(String? Function(ShiftLog? m) fromModel, String fallback) {
    try {
      final modelValue = fromModel(widget.shiftLog);
      if (modelValue != null && modelValue.trim().isNotEmpty) return modelValue.trim();
    } catch (_) {}
    final fb = fallback.trim();
    if (fb.isNotEmpty) return fb;
    return '-';
  }

  /// Safe numeric getter: try to get from model then fallback.
  String sn(String? Function(ShiftLog? m) fromModel, String fallback) {
    try {
      final v = fromModel(widget.shiftLog);
      if (v != null) return v;
    } catch (_) {}
    return fallback.isNotEmpty ? fallback : '-';
  }

  String _vehicleTypeDisplay() {
    // Prefer model value if present
    final modelVal = widget.shiftLog?.capitalizedVehicleOrCustomerVehicle;
    if (modelVal != null && modelVal.trim().isNotEmpty) return modelVal;
    // Otherwise prefer controller text (if set)
    final ctrl = controller.capitalizedVehicleOrCustomerVehicleController.text.trim();
    if (ctrl.isNotEmpty) return ctrl;
    // fallback to selectedVehicleType Rx (could be canonical or english)
    final sel = controller.selectedVehicleType.value;
    if (sel != null && sel.trim().isNotEmpty) return sel;
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('review_report'.tr),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Employee Details
            buildSectionCard('employee_details'.tr, [
              buildReviewRow('employee_name'.tr, s((m) => m?.employeeName, controller.employeeNameController.text)),
              buildReviewRow('employee_phone'.tr, s((m) => m?.employeePhoneNo, controller.employeePhoneController.text)),
              buildReviewRow('employee_code'.tr, s((m) => m?.employeeCode, controller.employeeCodeController.text)),
              buildReviewRow('month'.tr, s((m) => m?.monthYear.split('-').first, controller.monthController.text)),
              buildReviewRow(
                'year'.tr,
                s((m) => (m?.monthYear.split('-').length ?? 0) > 1 ? m?.monthYear.split('-')[1] : null,
                    controller.yearController.text),
              ),
              buildReviewRow('incharge_name'.tr, s((m) => m?.dicvInchargeName, controller.inchargeNameController.text)),
              buildReviewRow('incharge_phone'.tr, s((m) => m?.dicvInchargePhoneNo, controller.inchargePhoneController.text)),
            ]),

            const SizedBox(height: 20),

            // Report Details
            buildSectionCard('report_details'.tr, [
              buildReviewRow('date'.tr, widget.shiftLog != null ? widget.shiftLog!.inTime.toIso8601String().split('T').first : controller.date),
              buildReviewRow('shift'.tr, s((m) => m?.shift, controller.shiftController.text)),
              buildReviewRow('ot_hours'.tr, s((m) => m?.otHours.toString(), controller.otHoursController.text)),
              buildReviewRow('vehicle_model'.tr, s((m) => m?.vehicleModel, controller.vehicleModelController.text)),
              buildReviewRow('vehicle_reg_no'.tr, s((m) => m?.regNo, controller.regNoController.text)),
              buildReviewRow('in_time'.tr, s((m) => m?.inTime.toIso8601String(), controller.inTimeController.text)),
              buildReviewRow('out_time'.tr, s((m) => m?.outTime.toIso8601String(), controller.outTimeController.text)),
              buildReviewRow('working_hours'.tr, s((m) => m?.workingHours.toString(), controller.workingHoursController.text)),
              buildReviewRow('starting_km'.tr, s((m) => m?.startingKm.toString(), controller.startingKmController.text)),
              buildReviewRow('ending_km'.tr, s((m) => m?.endingKm.toString(), controller.endingKmController.text)),
              buildReviewRow('total_km'.tr, s((m) => m?.totalKm.toString(), controller.totalKmController.text)),
              buildReviewRow('from_place'.tr, s((m) => m?.fromPlace, controller.fromPlaceController.text)),
              buildReviewRow('to_place'.tr, s((m) => m?.toPlace, controller.toPlaceController.text)),
              buildReviewRow('fuel_avg'.tr, s((m) => m?.fuelAvg.toString(), controller.fuelAvgController.text)),
              buildReviewRow('co_driver_name'.tr, s((m) => m?.coDriverName, controller.coDriverNameController.text)),
              buildReviewRow('co_driver_phone'.tr, s((m) => m?.coDriverPhoneNo, controller.coDriverPhoneController.text)),
            ]),

            const SizedBox(height: 20),

            // Extra/Trial/Vehicle Details
            buildSectionCard('other_details'.tr, [
              buildReviewRow('chassis_no'.tr, s((m) => m?.chassisNo, controller.chassisNoController.text)),
              buildReviewRow('gvw'.tr, s((m) => m?.gvw.toString(), controller.gvwController.text)),
              buildReviewRow('payload'.tr, s((m) => m?.payload.toString(), controller.payloadController.text)),
              buildReviewRow('present_location'.tr, s((m) => m?.presentLocation, controller.presentLocationController.text)),
              buildReviewRow('previous_kmpl'.tr, s((m) => m?.previousKmpl.toString(), controller.previousKmplController.text)),
              buildReviewRow('cluster_kmpl'.tr, s((m) => m?.clusterKmpl.toString(), controller.clusterKmplController.text)),
              buildReviewRow('highway_sweet_spot_pct'.tr, s((m) => m?.highwaySweetSpotPercent.toString(), controller.highwaySweetSpotPercentController.text)),
              buildReviewRow('normal_road_sweet_spot_pct'.tr, s((m) => m?.normalRoadSweetSpotPercent.toString(), controller.normalRoadSweetSpotPercentController.text)),
              buildReviewRow('hills_road_sweet_spot_pct'.tr, s((m) => m?.hillsRoadSweetSpotPercent.toString(), controller.hillsRoadSweetSpotPercentController.text)),
              buildReviewRow('trial_kmpl'.tr, s((m) => m?.trialKMPL, controller.trialKMPLController.text)),
              buildReviewRow('odo_start_reading'.tr, s((m) => m?.vehicleOdometerStartingReading, controller.vehicleOdometerStartingReadingController.text)),
              buildReviewRow('odo_end_reading'.tr, s((m) => m?.vehicleOdometerEndingReading, controller.vehicleOdometerEndingReadingController.text)),
              buildReviewRow('trial_kms'.tr, s((m) => m?.trialKMS, controller.trialKMSController.text)),
              buildReviewRow('trial_allocation'.tr, s((m) => m?.trialAllocation, controller.trialAllocationController.text)),
              buildReviewRow('vecv_reporting_person'.tr, s((m) => m?.vecvReportingPerson, controller.vecvReportingPersonController.text)),
              buildReviewRow('dealer_name'.tr, s((m) => m?.dealerName, controller.dealerNameController.text)),
              buildReviewRow('customer_name'.tr, s((m) => m?.customerName, controller.customerNameController.text)),
              buildReviewRow('customer_driver_name'.tr, s((m) => m?.customerDriverName, controller.customerDriverNameController.text)),
              buildReviewRow('customer_driver_no'.tr, s((m) => m?.customerDriverNo, controller.customerDriverNoController.text)),
              buildReviewRow('capitalized_customer_vehicle'.tr, _vehicleTypeDisplay()),
              buildReviewRow('customer_vehicle'.tr, s((m) => m?.customerVehicle, controller.customerVehicleController.text)),
              buildReviewRow('capitalized_vehicle'.tr, s((m) => m?.capitalizedVehicle, controller.capitalizedVehicleController.text)),
              buildReviewRow('vehicle_no'.tr, s((m) => m?.vehicleNo, controller.vehicleNoController.text)),
              buildReviewRow('driver_status'.tr, s((m) => m?.driverStatus, controller.driverStatusController.text)),
              buildReviewRow('purpose_of_trial'.tr, s((m) => m?.purposeOfTrial, controller.purposeOfTrialController.text)),
              buildReviewRow('reason'.tr, s((m) => m?.reason, controller.reasonController.text)),
              buildReviewRow('date_of_sale'.tr, s((m) => m?.dateOfSale, controller.dateOfSaleController.text)),
              buildReviewRow('trail_id'.tr, s((m) => m?.trailId, controller.trailIdController.text)),
            ]),

            const SizedBox(height: 20),

            // Signature
            if (widget.signature != null)
              buildSectionCard('signature'.tr, [
                Text('incharge_signature'.tr, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Image.memory(widget.signature!, width: 300, height: 120),
              ])
            else if (widget.shiftLog != null && widget.shiftLog!.inchargeSign.isNotEmpty)
              buildSectionCard('signature'.tr, [
                Text('incharge_signature'.tr, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                if (_isBase64(widget.shiftLog!.inchargeSign))
                  Image.memory(base64Decode(widget.shiftLog!.inchargeSign), width: 300, height: 120)
                else
                  Text('signature_saved_url'.trParams({'url': widget.shiftLog!.inchargeSign}), style: const TextStyle(color: Colors.blue)),
              ])
            else
              buildSectionCard('signature'.tr, [Text('signature_not_available'.tr, style: const TextStyle(color: Colors.redAccent, fontSize: 16))]),

            const SizedBox(height: 20),

            // Uploaded media URLs list
            if (urls.isNotEmpty)
              buildSectionCard('uploaded_media'.tr, urls.map((u) => SelectableText(u)).toList()),

            const SizedBox(height: 12),

            // Upload button
            ElevatedButton(
              onPressed: uploading ? null : () async {
                setState(() => uploading = true);
                try {
                  final result = await uploadMultipleMediaAndSendUrls();
                  setState(() => urls = result);
                  Get.snackbar('Upload', 'Uploaded ${result.length} items', backgroundColor: Colors.green, colorText: Colors.white);
                } catch (e) {
                  Get.snackbar('Upload Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
                } finally {
                  setState(() => uploading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: uploading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('upload_media'.tr, style: const TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 20),

            // Submit & PDF buttons

                ElevatedButton(
                  onPressed: submitting ? null : () async {
                    setState(() => submitting = true);
                    try {
                      await submitData(urls);
                    } finally {
                      setState(() => submitting = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: submitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('submit_report'.tr, style: const TextStyle(color: Colors.white)),
                ),
            const SizedBox(height: 20),
            ElevatedButton(
                  onPressed: () {
                    PdfService.generatePdf(controller, widget.signature);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('generate_pdf'.tr, style: const TextStyle(color: Colors.white)),
                ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildSectionCard(String title, List<Widget> children) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 5,
    color: Colors.blue[50],
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        const Divider(),
        ...children,
      ]),
    ),
  );

  Widget buildReviewRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        Expanded(flex: 5, child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87))),
      ],
    ),
  );

  bool _isBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> submitData(List<String> imageVideoUrls) async {
    final uri = Uri.parse("https://jl-trail-gps-tracker-backend-production.up.railway.app/dailyReport");

    Map<String, dynamic> payload;

    if (widget.shiftLog != null) {
      // use model payload and attach uploaded urls if any
      payload = widget.shiftLog!.toJsonWithoutId();
      if (imageVideoUrls.isNotEmpty) payload['imageVideoUrls'] = imageVideoUrls;
    } else {
      // build complete payload from controllers (include all fields)
      payload = {
        'date': controller.date,
        'shift': controller.shiftController.text,
        'otHours': int.tryParse(controller.otHoursController.text) ?? 0,
        'vehicleModel': controller.vehicleModelController.text,
        'regNo': controller.regNoController.text,
        'inTime': controller.inTimeController.text,
        'outTime': controller.outTimeController.text,
        'workingHours': int.tryParse(controller.workingHoursController.text) ?? 0,
        'startingKm': int.tryParse(controller.startingKmController.text) ?? 0,
        'endingKm': int.tryParse(controller.endingKmController.text) ?? 0,
        'totalKm': int.tryParse(controller.totalKmController.text) ?? 0,
        'fromPlace': controller.fromPlaceController.text,
        'toPlace': controller.toPlaceController.text,
        'presentLocation': controller.presentLocationController.text,
        'fuelAvg': double.tryParse(controller.fuelAvgController.text) ?? 0.0,
        'coDriverName': controller.coDriverNameController.text,
        'coDriverPhoneNo': controller.coDriverPhoneController.text,
        'employeeName': controller.employeeNameController.text,
        'employeePhoneNo': controller.employeePhoneController.text,
        'employeeCode': controller.employeeCodeController.text,
        'dicvInchargeName': controller.inchargeNameController.text,
        'dicvInchargePhoneNo': controller.inchargePhoneController.text,
        'monthYear': '${controller.monthController.text}-${controller.yearController.text}',
        'chassisNo': controller.chassisNoController.text,
        'gvw': double.tryParse(controller.gvwController.text) ?? 0.0,
        'payload': double.tryParse(controller.payloadController.text) ?? 0.0,
        'previousKmpl': double.tryParse(controller.previousKmplController.text) ?? 0.0,
        'clusterKmpl': double.tryParse(controller.clusterKmplController.text) ?? 0.0,
        'highwaySweetSpotPercent': double.tryParse(controller.highwaySweetSpotPercentController.text) ?? 0.0,
        'normalRoadSweetSpotPercent': double.tryParse(controller.normalRoadSweetSpotPercentController.text) ?? 0.0,
        'hillsRoadSweetSpotPercent': double.tryParse(controller.hillsRoadSweetSpotPercentController.text) ?? 0.0,
        'trialKMPL': controller.trialKMPLController.text,
        'vehicleOdometerStartingReading': controller.vehicleOdometerStartingReadingController.text,
        'vehicleOdometerEndingReading': controller.vehicleOdometerEndingReadingController.text,
        'trialKMS': controller.trialKMSController.text,
        'trialAllocation': controller.trialAllocationController.text,
        'vecvReportingPerson': controller.vecvReportingPersonController.text,
        'dealerName': controller.dealerNameController.text,
        'customerName': controller.customerNameController.text,
        'customerDriverName': controller.customerDriverNameController.text,
        'customerDriverNo': controller.customerDriverNoController.text,
        'capitalizedVehicleOrCustomerVehicle': controller.capitalizedVehicleOrCustomerVehicleController.text.isNotEmpty
            ? controller.capitalizedVehicleOrCustomerVehicleController.text
            : (controller.selectedVehicleType.value ?? ''),
        'customerVehicle': controller.customerVehicleController.text,
        'capitalizedVehicle': controller.capitalizedVehicleController.text,
        'vehicleNo': controller.vehicleNoController.text,
        'driverStatus': controller.driverStatusController.text,
        'purposeOfTrial': controller.selectedPurposeOfTrial.value ?? controller.purposeOfTrialController.text,
        'reason': controller.reasonController.text,
        'dateOfSale': controller.dateOfSaleController.text,
        'trailId': controller.trailIdController.text,
        'inchargeSign': controller.inchargeSignController.text,
        'imageVideoUrls': imageVideoUrls,
      };
    }

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar("Success", "Report submitted successfully", backgroundColor: Colors.green, colorText: Colors.white);
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back(result: true);
        });
      } else {
        print("Error, Failed: ${response.statusCode}\n${response.body}");
        Get.snackbar("Error", "Failed: ${response.statusCode}\n${response.body}", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("Network error: $e");
      Get.snackbar("Error", "Network error: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
