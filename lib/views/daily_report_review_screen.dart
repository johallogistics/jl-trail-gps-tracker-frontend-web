// daily_report_review_screen.dart
import 'dart:typed_data' as td;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/shift_log_model.dart';
import '../utils/image_upload_service.dart';
import '../utils/pdf_service.dart';
import 'daily_report_screen.dart';

class DailyReportReviewScreen extends StatefulWidget {
  final Map<String, String> employeeData;
  final td.Uint8List? signature;
  final ShiftLog? shiftLog;

  DailyReportReviewScreen({
    super.key,
    required this.employeeData,
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

  /// Safe getter: returns from model if exists, else fallback, else '-'
  String s(String? Function(ShiftLog? m) fromModel, String fallback) {
    final modelValue = fromModel(widget.shiftLog);
    if (modelValue != null && modelValue.trim().isNotEmpty) {
      return modelValue.trim();
    }
    final fb = fallback.trim();
    if (fb.isNotEmpty) return fb;
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
            buildSectionCard('Employee Details', [
              buildReviewRow('employee_name'.tr, s((m) => m?.employeeName, controller.employeeNameController.text)),
              buildReviewRow('employee_phone'.tr, s((m) => m?.employeePhoneNo, controller.employeePhoneController.text)),
              buildReviewRow('employee_code'.tr, s((m) => m?.employeeCode, controller.employeeCodeController.text)),
              buildReviewRow('month'.tr, s((m) => m?.monthYear.split('-').first, controller.monthController.text)),
              buildReviewRow('year'.tr, s((m) => (m?.monthYear.split('-').length ?? 0) > 1 ? m?.monthYear.split('-')[1] : null, controller.yearController.text)),
              buildReviewRow('incharge_name'.tr, s((m) => m?.dicvInchargeName, controller.inchargeNameController.text)),
              buildReviewRow('incharge_phone'.tr, s((m) => m?.dicvInchargePhoneNo, controller.inchargePhoneController.text)),
            ]),

            const SizedBox(height: 20),

            // Report Details
            buildSectionCard('Report Details', [
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

            // Signature
            if (widget.signature != null)
              buildSectionCard('Signature', [
                const Text('In-charge Signature:', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Image.memory(widget.signature!, width: 300, height: 120),
              ])
            else if (widget.shiftLog != null && widget.shiftLog!.inchargeSign.isNotEmpty)
              buildSectionCard('Signature', [
                const Text('In-charge Signature (from model):', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                if (_isBase64(widget.shiftLog!.inchargeSign))
                  Image.memory(base64Decode(widget.shiftLog!.inchargeSign), width: 300, height: 120)
                else
                  Text('Signature saved as URL: ${widget.shiftLog!.inchargeSign}', style: const TextStyle(color: Colors.blue)),
              ])
            else
              const Text("Signature Not Available", style: TextStyle(color: Colors.redAccent, fontSize: 16)),

            const SizedBox(height: 20),

            // Upload
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
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload Images and Videos', style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 20),

            // Submit & PDF
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('submit_report'.tr, style: const TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    PdfService.generatePdf(controller, widget.employeeData, widget.signature);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('generate_pdf'.tr, style: const TextStyle(color: Colors.white)),
                ),
              ],
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
    padding: const EdgeInsets.symmetric(vertical: 4.0),
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
      payload = widget.shiftLog!.toJsonWithoutId();
      if (imageVideoUrls.isNotEmpty) payload['imageVideoUrls'] = imageVideoUrls;
      if (widget.signature != null) payload['inchargeSign'] = base64Encode(widget.signature!);
    } else {
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
        'fuelAvg': double.tryParse(controller.fuelAvgController.text) ?? 0.0,
        'coDriverName': controller.coDriverNameController.text,
        'coDriverPhoneNo': controller.coDriverPhoneController.text,
        'employeeName': controller.employeeNameController.text,
        'employeePhoneNo': controller.employeePhoneController.text,
        'employeeCode': controller.employeeCodeController.text,
        'dicvInchargeName': controller.inchargeNameController.text,
        'dicvInchargePhoneNo': controller.inchargePhoneController.text,
        'monthYear': '${controller.monthController.text}-${controller.yearController.text}',
        'imageVideoUrls': imageVideoUrls,
      };
      if (widget.signature != null) payload['inchargeSign'] = base64Encode(widget.signature!);
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
        Get.snackbar("Error", "Failed: ${response.statusCode}\n${response.body}", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Network error: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
