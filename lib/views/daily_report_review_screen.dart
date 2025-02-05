import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/pdf_service.dart';
import 'daily_report_screen.dart';

class DailyReportReviewScreen extends StatelessWidget {
  final Map<String, String> employeeData;
  final DailyReportController controller = Get.find<DailyReportController>();

  DailyReportReviewScreen({super.key, required this.employeeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('review_report'.tr)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'employee_name'.tr}: ${employeeData['name']}'),
            Text('${'employee_phone'.tr}: ${employeeData['phone']}'),
            Text('${'employee_code'.tr}: ${employeeData['code']}'),
            Text('${'month'.tr}: ${employeeData['month']}'),
            Text('${'year'.tr}: ${employeeData['year']}'),
            Text('${'incharge_name'.tr}: ${employeeData['inchargeName']}'),
            Text('${'incharge_phone'.tr}: ${employeeData['inchargePhone']}'),
            SizedBox(height: 20),
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
            buildReviewRow('incharge_sign'.tr, controller.inchargeSignController.text),
            SizedBox(height: 20),
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
                    PdfService.generatePdf(controller, employeeData);
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
    final url = Uri.parse("https://yourbackend.com/api/dailyReport");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "date": controller.date,
        "shift": controller.shiftController.text,
        "ot_hours": controller.otHoursController.text,
        "vehicle_model": controller.vehicleModelController.text,
        "vehicle_reg_no": controller.regNoController.text,
        "in_time": controller.inTimeController.text,
        "out_time": controller.outTimeController.text,
        "working_hours": controller.workingHoursController.text,
        "starting_km": controller.startingKmController.text,
        "ending_km": controller.endingKmController.text,
        "total_km": controller.totalKmController.text,
        "from_place": controller.fromPlaceController.text,
        "to_place": controller.toPlaceController.text,
        "fuel_avg": controller.fuelAvgController.text,
        "co_driver_name": controller.coDriverNameController.text,
        "co_driver_phone": controller.coDriverPhoneController.text,
        "incharge_sign": controller.inchargeSignController.text,
      }),
    );

    if (response.statusCode == 200) {
      Get.snackbar("Success", "Report submitted successfully");
    } else {
      Get.snackbar("Error", "Failed to submit report");
    }
  }
}
