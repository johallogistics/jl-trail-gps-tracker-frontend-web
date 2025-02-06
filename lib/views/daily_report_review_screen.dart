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
      appBar: AppBar(title: Text('review_report'.tr)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displaying Employee Details
            buildReviewRow('employee_name'.tr, employeeData['name'] ?? ''),
            buildReviewRow('employee_phone'.tr, employeeData['phone'] ?? ''),
            buildReviewRow('employee_code'.tr, employeeData['code'] ?? ''),
            buildReviewRow('month'.tr, employeeData['month'] ?? ''),
            buildReviewRow('year'.tr, employeeData['year'] ?? ''),
            buildReviewRow('incharge_name'.tr, employeeData['inchargeName'] ?? ''),
            buildReviewRow('incharge_phone'.tr, employeeData['inchargePhone'] ?? ''),
            const SizedBox(height: 20),

            // Displaying Form Data
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

            const SizedBox(height: 20),

            // Display Signature Preview
            if (signature != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('In-charge Signature:', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Image.memory(signature!, width: 200, height: 100),
                  const SizedBox(height: 20),
                ],
              ) else
              Text("Signature Not Available"),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    submitData();
                  },
                  child: Text('submit_report'.tr),
                ),
                ElevatedButton(
                  onPressed: () {
                    PdfService.generatePdf(controller, employeeData, signature);
                  },
                  child: Text('generate_pdf'.tr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }
  void submitData() async {
    final url = Uri.parse("http://localhost:3000/dailyReport");

    final employeeData = {
      'name': 'John Doe',
      'phone': '123-456-7890',
      'code': 'EMP123',
      'month': 'January',
      'year': '2025',
      'inchargeName': 'Jane Smith',
      'inchargePhone': '987-654-3210',
    };

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
        "employeeName": "emp name",
        "employeePhoneNo": "emp phone",
        "employeeCode": "code",
        "monthYear": "feb",
        "dicvInchargeName": "icharger",
        "dicvInchargePhoneNo": "phone",
        "trailId": "T1",
      }),

    );

    if (response.statusCode == 201) {
      Get.snackbar("Success", "Report submitted successfully");
    } else {
      Get.snackbar("Error", "Failed to submit report");
    }
  }

}

