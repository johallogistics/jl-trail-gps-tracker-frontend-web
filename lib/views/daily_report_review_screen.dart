import 'dart:typed_data' as td;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/pdf_service.dart';
import 'daily_report_screen.dart';

class DailyReportReviewScreen extends StatelessWidget {
  final Map<String, String> employeeData;
  final DailyReportController controller = Get.find<DailyReportController>();
  final td.Uint8List? signature;

  DailyReportReviewScreen({super.key, required this.employeeData, this.signature});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('review_report'.tr),
        backgroundColor: Colors.blueAccent, // ✅ Blue theme
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Employee Details Card
            buildSectionCard('Employee Details', [
              buildReviewRow('employee_name'.tr, employeeData['name'] ?? ''),
              buildReviewRow('employee_phone'.tr, employeeData['phone'] ?? ''),
              buildReviewRow('employee_code'.tr, employeeData['code'] ?? ''),
              buildReviewRow('month'.tr, employeeData['month'] ?? ''),
              buildReviewRow('year'.tr, employeeData['year'] ?? ''),
              buildReviewRow('incharge_name'.tr, employeeData['inchargeName'] ?? ''),
              buildReviewRow('incharge_phone'.tr, employeeData['inchargePhone'] ?? ''),
            ]),

            const SizedBox(height: 20),

            // Form Data Card
            buildSectionCard('Report Details', [
              buildReviewRow('date'.tr, controller.date),
              buildReviewRow('shift'.tr, controller.shiftController.text),
              buildReviewRow('ot_hours'.tr, controller.otHoursController.text),
              buildReviewRow('vehicle_model'.tr, controller.vehicleModelController.text),
              buildReviewRow('vehicle_reg_no'.tr, controller.regNoController.text),
              buildReviewRow('in_time'.tr, controller.inTimeController.text),
              buildReviewRow('out_time'.tr, controller.outTimeController.text),
              buildReviewRow('working_hours'.tr, controller.workingHoursController.text),
              buildReviewRow('starting_km'.tr, controller.startingKmController.text),
              buildReviewRow('ending_km'.tr, controller.endingKmController.text),
              buildReviewRow('total_km'.tr, controller.totalKmController.text),
              buildReviewRow('from_place'.tr, controller.fromPlaceController.text),
              buildReviewRow('to_place'.tr, controller.toPlaceController.text),
              buildReviewRow('fuel_avg'.tr, controller.fuelAvgController.text),
              buildReviewRow('co_driver_name'.tr, controller.coDriverNameController.text),
              buildReviewRow('co_driver_phone'.tr, controller.coDriverPhoneController.text),
            ]),

            const SizedBox(height: 20),

            // Signature Preview
            if (signature != null)
              buildSectionCard('Signature', [
                const Text('In-charge Signature:', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Image.memory(signature!, width: 200, height: 100),
              ])
            else
              const Text("Signature Not Available", style: TextStyle(color: Colors.redAccent, fontSize: 16)),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    submitData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('submit_report'.tr, style: const TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    PdfService.generatePdf(controller, employeeData, signature);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('generate_pdf'.tr, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable Card for Sections
  Widget buildSectionCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  // 🔹 Improved Review Row
  Widget buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            flex: 5,
            child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  // 🔹 Submit Data API Call
  void submitData() async {
    final url = Uri.parse("http://localhost:3000/dailyReport");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "date": controller.date,
        "shift": controller.shiftController.text,
        "otHours": controller.otHoursController.text,
        "vehicleModel": controller.vehicleModelController.text,
        "regNo": controller.regNoController.text,
        "inTime": controller.inTimeController.text,
        "outTime": controller.outTimeController.text,
        "workingHours": controller.workingHoursController.text,
        "startingKm": controller.startingKmController.text,
        "endingKm": controller.endingKmController.text,
        "totalKm": controller.totalKmController.text,
        "fromPlace": controller.fromPlaceController.text,
        "toPlace": controller.toPlaceController.text,
        "fuelAvg": controller.fuelAvgController.text,
        "coDriverName": controller.coDriverNameController.text,
        "coDriverPhoneNo": controller.coDriverPhoneController.text,
      }),
    );

    if (response.statusCode == 201) {
      Get.snackbar("Success", "Report submitted successfully", backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar("Error", "Failed to submit report", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
