import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../controllers/consolidated_form_controller.dart';
import 'dart:typed_data' as td;
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';

import '../utils/image_upload_service.dart';

class ReviewFormScreen extends StatelessWidget {
  final FormController controller = Get.put(FormController());
  // final FormController controller = Get.find<FormController>();
  final td.Uint8List? signature;

  ReviewFormScreen({super.key, this.signature});

  @override
  Widget build(BuildContext context) {
    final formData = _getFormData();
    List<String> urls = [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Trip Form'),
        backgroundColor: Colors.blueAccent, // ✅ Blue theme
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form Data Card
            buildSectionCard('Form Details', [
              buildReviewRow('Location', formData['location']),
              buildReviewRow('Date', formData['date']),
              buildReviewRow('Master Driver Name', formData['master_driver_name']),
              buildReviewRow('Employee Code', formData['emp_code']),
              buildReviewRow('Mobile No', formData['mobile_no']),
              buildReviewRow('Customer Driver Name', formData['customer_driver_name']),
              buildReviewRow('Customer Mobile No', formData['customer_mobile_no']),
              buildReviewRow('License No', formData['license_no']),
            ]),

            const SizedBox(height: 20),

            // Vehicle Details and Competitor Data Card
            buildSectionCard('Vehicle & Competitor Details', [
              _buildVehicleAndCompetitorData(formData['vehicle_details'], formData['competitor_data']),
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
            ElevatedButton(
              onPressed: () async {
                urls =  await uploadMultipleToBackblaze();
                print(urls);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text('Upload Images and Videos', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                ElevatedButton(
                  onPressed: () async {
                    await controller.submitForm(urls);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Form submitted!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Submit Form', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await PdfServiceConsolidatedForm.generatePdf(formData, signature);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF Generated!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Generate PDF', style: TextStyle(color: Colors.white)),
                ), //        uploadMultipleMediaAndSendUrls();
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getFormData() {
    return {
      'location': controller.locationController.text,
      'date': controller.dateController.text,
      'master_driver_name': controller.masterDriverNameController.text,
      'emp_code': controller.empCodeController.text,
      'mobile_no': controller.mobileNoController.text,
      'customer_driver_name': controller.customerDriverNameController.text,
      'customer_mobile_no': controller.customerMobileNoController.text,
      'license_no': controller.licenseNoController.text,
      'vehicle_details': _getVehicleDetails(controller.vehicleDetails[0]),
      'competitor_data': _getVehicleDetails(controller.competitorData[0]),
    };
  }

  Map<String, dynamic> _getVehicleDetails(dynamic data) {
    return {
      'Vehicle Reg No': data.vehicleRegNo.text ?? 'N/A',
      'Brand': data.brand.text ?? 'N/A',
      'Chassis No': data.chassisNo.text ?? 'N/A',
      'Vehicle Model': data.vehicleModel.text ?? 'N/A',
      'Wheel Base': data.wheelBase.text ?? 'N/A',
      'ATS Type': data.atsType.text ?? 'N/A',
      'Emission': data.emission.text ?? 'N/A',
      'Tyre Brand': data.tyreBrand.text ?? 'N/A',
      'Application': data.application.text ?? 'N/A',
      'GVW Carried': data.gvwCarried.text ?? 'N/A',
      'Trip Start Date': data.tripStartDate.text ?? 'N/A',
      'Start Odo': data.startOdo.text ?? 'N/A',
      'Trip Finish Date': data.tripFinishDate.text ?? 'N/A',
      'End Odo': data.endOdo.text ?? 'N/A',
      'Start Place': data.startPlace.text ?? 'N/A',
      'End Place': data.endPlace.text ?? 'N/A',
      'Total Trail Kms': data.totalTrailKms.text ?? 'N/A',
      'Fuel Consumed': data.fuelConsumed.text ?? 'N/A',
      'AdBlue Consumed Cluster': data.adBlueConsumedCluster.text ?? 'N/A',
      'Did Regeneration Happen': data.didRegenerationHappen.value.toString(),
      'Lead Distance': data.leadDistance.text ?? 'N/A',
      'Driving Speed': data.drivingSpeed.text ?? 'N/A',
      'Actual FE in BB': data.actualFeInBB.text ?? 'N/A',
    };
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

  // 🔹 Build Vehicle and Competitor Data Table
  Widget _buildVehicleAndCompetitorData(Map<String, dynamic> vehicleDetails, Map<String, dynamic> competitorData) {
    return Column(
      children: vehicleDetails.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Expanded(
                flex: 2,
                child: Text(entry.value.toString(), style: const TextStyle(fontSize: 16, color: Colors.black87)),
              ),
              Expanded(
                flex: 2,
                child: Text(competitorData[entry.key].toString(), style: const TextStyle(fontSize: 16, color: Colors.black87)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class PdfServiceConsolidatedForm {
  static Future<void> generatePdf(Map<String, dynamic> formData, Uint8List? signature) async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;
    const double pageWidth = 500;
    double yOffset = 20;

    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold);
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);

    void addText(String text, {bool isTitle = false}) {
      graphics.drawString(text, isTitle ? titleFont : font, bounds: Rect.fromLTWH(0, yOffset, pageWidth, 20));
      yOffset += isTitle ? 30 : 20;
    }

    addText('Form Review', isTitle: true);

    addText('Location: ${formData['location']}');
    addText('Date: ${formData['date']}');
    addText('Master Driver Name: ${formData['master_driver_name']}');
    addText('Employee Code: ${formData['emp_code']}');
    addText('Mobile Number: ${formData['mobile_no']}');
    addText('Customer Driver Name: ${formData['customer_driver_name']}');
    addText('Customer Mobile No: ${formData['customer_mobile_no']}');
    addText('License No: ${formData['license_no']}');

    yOffset += 10;

    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 3);
    grid.headers.add(1);

    final PdfGridRow headerRow = grid.headers[0];
    headerRow.cells[0].value = 'Key';
    headerRow.cells[1].value = 'Vehicle Details';
    headerRow.cells[2].value = 'Competitor Data';
    headerRow.style = PdfGridCellStyle(
      backgroundBrush: PdfBrushes.lightGray,
      font: PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
    );

    final Map<String, dynamic> vehicleDetails = formData['vehicle_details'];
    final Map<String, dynamic> competitorData = formData['competitor_data'];

    vehicleDetails.forEach((key, value) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = key;
      row.cells[1].value = value.toString();
      row.cells[2].value = competitorData[key].toString();
    });

    final PdfLayoutResult? result = grid.draw(page: page, bounds: Rect.fromLTWH(0, yOffset, pageWidth, 0));

    if (result != null) {
      yOffset = result.bounds.bottom + 20;
    }

    if (signature != null) {
      graphics.drawString("Signature:", font, bounds: Rect.fromLTWH(0, yOffset, pageWidth, 20));
      yOffset += 20;
      final PdfBitmap signatureImage = PdfBitmap(signature);
      graphics.drawImage(signatureImage, Rect.fromLTWH(0, yOffset, 200, 100));
    }

    final List<int> bytes = await document.save();
    document.dispose();

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final file = File('$selectedDirectory/FormReview.pdf');
      await file.writeAsBytes(bytes);
      print('PDF saved at: ${file.path}');
    }
  }
}