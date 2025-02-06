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

class ReviewFormScreen extends StatelessWidget {
  final FormController controller = Get.find<FormController>();
  final td.Uint8List? signature;

  ReviewFormScreen({super.key, this.signature});

  // Function to generate the PDF
  Future<void> generatePdf(Map<String, dynamic> formData) async {
    final pdf = pw.Document();

    // Create a new page for the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Form Review',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Location: ${formData['location']}'),
              pw.Text('Date: ${formData['date']}'),
              pw.Text('Master Driver Name: ${formData['master_driver_name']}'),
              pw.Text('Employee Code: ${formData['emp_code']}'),
              pw.Text('Mobile Number: ${formData['mobile_no']}'),
              pw.Text('Customer Driver Name: ${formData['customer_driver_name']}'),
              pw.Text('Customer Mobile No: ${formData['customer_mobile_no']}'),
              pw.Text('License No: ${formData['license_no']}'),
              pw.SizedBox(height: 20),

              // Vehicle Details Section
              pw.Text('Vehicle Details:',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...formData['vehicle_details'].entries.map<pw.Widget>((entry) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${entry.key}: ${entry.value}'),
                    pw.SizedBox(height: 5),
                  ],
                );
              }).toList(),

              pw.SizedBox(height: 20),

              // Competitor Data Section
              pw.Text('Competitor Data:',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...formData['competitor_data'].entries.map<pw.Widget>((entry) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${entry.key}: ${entry.value}'),
                    pw.SizedBox(height: 5),
                  ],
                );
              }).toList(),
              if (signature != null)
                pw.Column(
                  children: [
                    pw.Text("Signature:"),
                    pw.SizedBox(height: 10),
                    pw.Image(pw.MemoryImage(signature!), width: 100, height: 50),
                  ],
                ),
            ],
          );
        },
      ),
    );

    // Get the app's document directory and save the PDF file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/review_form.pdf');
    await file.writeAsBytes(await pdf.save());
    print('PDF saved at: ${file.path}');
  }

  @override
  Widget build(BuildContext context) {
    // Get the form data
    final formData = {
      'location': controller.locationController.text,
      'date': controller.dateController.text,
      'master_driver_name': controller.masterDriverNameController.text,
      'emp_code': controller.empCodeController.text,
      'mobile_no': controller.mobileNoController.text,
      'customer_driver_name': controller.customerDriverNameController.text,
      'customer_mobile_no': controller.customerMobileNoController.text,
      'license_no': controller.licenseNoController.text,
      'vehicle_details': {
        'vehicleRegNo': controller.vehicleDetails[0].vehicleRegNo.text ?? 'N/A',
        'brand': controller.vehicleDetails[0].brand.text ?? 'N/A',
        'chassisNo': controller.vehicleDetails[0].chassisNo.text ?? 'N/A',
        'vehicleModel': controller.vehicleDetails[0].vehicleModel.text ?? 'N/A',
        'wheelBase': controller.vehicleDetails[0].wheelBase.text ?? 'N/A',
        'atsType': controller.vehicleDetails[0].atsType.text ?? 'N/A',
        'emission': controller.vehicleDetails[0].emission.text ?? 'N/A',
        'tyreBrand': controller.vehicleDetails[0].tyreBrand.text ?? 'N/A',
        'application': controller.vehicleDetails[0].application.text ?? 'N/A',
        'gvwCarried': controller.vehicleDetails[0].gvwCarried.text ?? 'N/A',
        'tripStartDate': controller.vehicleDetails[0].tripStartDate.text ?? 'N/A',
        'startOdo': controller.vehicleDetails[0].startOdo.text ?? 'N/A',
        'tripFinishDate': controller.vehicleDetails[0].tripFinishDate.text ?? 'N/A',
        'endOdo': controller.vehicleDetails[0].endOdo.text ?? 'N/A',
        'startPlace': controller.vehicleDetails[0].startPlace.text ?? 'N/A',
        'endPlace': controller.vehicleDetails[0].endPlace.text ?? 'N/A',
        'totalTrailKms': controller.vehicleDetails[0].totalTrailKms.text ?? 'N/A',
        'fuelConsumed': controller.vehicleDetails[0].fuelConsumed.text ?? 'N/A',
        'adBlueConsumedCluster': controller.vehicleDetails[0].adBlueConsumedCluster.text ?? 'N/A',
        'didRegenerationHappen': controller.vehicleDetails[0].didRegenerationHappen.value,
        'leadDistance': controller.vehicleDetails[0].leadDistance.text ?? 'N/A',
        'drivingSpeed': controller.vehicleDetails[0].drivingSpeed.text ?? 'N/A',
        'actualFeInBB': controller.vehicleDetails[0].actualFeInBB.text ?? 'N/A',
      },
      'competitor_data': {
        'vehicleRegNo': controller.competitorData[0].vehicleRegNo.text ?? 'N/A',
        'brand': controller.competitorData[0].brand.text ?? 'N/A',
        'chassisNo': controller.competitorData[0].chassisNo.text ?? 'N/A',
        'vehicleModel': controller.competitorData[0].vehicleModel.text ?? 'N/A',
        'wheelBase': controller.competitorData[0].wheelBase.text ?? 'N/A',
        'atsType': controller.competitorData[0].atsType.text ?? 'N/A',
        'emission': controller.competitorData[0].emission.text ?? 'N/A',
        'tyreBrand': controller.competitorData[0].tyreBrand.text ?? 'N/A',
        'application': controller.competitorData[0].application.text ?? 'N/A',
        'gvwCarried': controller.competitorData[0].gvwCarried.text ?? 'N/A',
        'tripStartDate': controller.competitorData[0].tripStartDate.text ?? 'N/A',
        'startOdo': controller.competitorData[0].startOdo.text ?? 'N/A',
        'tripFinishDate': controller.competitorData[0].tripFinishDate.text ?? 'N/A',
        'endOdo': controller.competitorData[0].endOdo.text ?? 'N/A',
        'startPlace': controller.competitorData[0].startPlace.text ?? 'N/A',
        'endPlace': controller.competitorData[0].endPlace.text ?? 'N/A',
        'totalTrailKms': controller.competitorData[0].totalTrailKms.text ?? 'N/A',
        'fuelConsumed': controller.competitorData[0].fuelConsumed.text ?? 'N/A',
        'adBlueConsumedCluster': controller.competitorData[0].adBlueConsumedCluster.text ?? 'N/A',
        'didRegenerationHappen': controller.competitorData[0].didRegenerationHappen.value,
        'leadDistance': controller.competitorData[0].leadDistance.text ?? 'N/A',
        'drivingSpeed': controller.competitorData[0].drivingSpeed.text ?? 'N/A',
        'actualFeInBB': controller.competitorData[0].actualFeInBB.text ?? 'N/A',
      }
    } as Map<String, dynamic>;


    return Scaffold(
      appBar: AppBar(title: Text('Review Trip Form')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Please review the form below before submitting:'),
              SizedBox(height: 20),
              // Display the form data for review
              Text('Location: ${formData['location']}'),
              Text('Date: ${formData['date']}'),
              Text('Master Driver Name: ${formData['master_driver_name']}'),
              Text('Employee Code: ${formData['emp_code']}'),
              Text('Mobile No: ${formData['mobile_no']}'),
              Text('Customer Driver Name: ${formData['customer_driver_name']}'),
              Text('Customer Mobile No: ${formData['customer_mobile_no']}'),
              Text('License No: ${formData['license_no']}'),
              SizedBox(height: 20),
              // Display vehicle details and competitor data side by side
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Vehicle Details Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vehicle Details:'),
                        Text('Vehicle Reg No: ${formData['vehicle_details']['vehicleRegNo']}'),
                        Text('Brand: ${formData['vehicle_details']['brand']}'),
                        Text('Chassis No: ${formData['vehicle_details']['chassisNo']}'),
                        Text('Vehicle Model: ${formData['vehicle_details']['vehicleModel']}'),
                        Text('Wheel Base: ${formData['vehicle_details']['wheelBase']}'),
                        Text('ATS Type: ${formData['vehicle_details']['atsType']}'),
                        Text('Emission: ${formData['vehicle_details']['emission']}'),
                        Text('Tyre Brand: ${formData['vehicle_details']['tyreBrand']}'),
                        Text('Application: ${formData['vehicle_details']['application']}'),
                        Text('GVW Carried: ${formData['vehicle_details']['gvwCarried']}'),
                        Text('Trip Start Date: ${formData['vehicle_details']['tripStartDate']}'),
                        Text('Start Odo: ${formData['vehicle_details']['startOdo']}'),
                        Text('Trip Finish Date: ${formData['vehicle_details']['tripFinishDate']}'),
                        Text('End Odo: ${formData['vehicle_details']['endOdo']}'),
                        Text('Start Place: ${formData['vehicle_details']['startPlace']}'),
                        Text('End Place: ${formData['vehicle_details']['endPlace']}'),
                        Text('Total Trail Kms: ${formData['vehicle_details']['totalTrailKms']}'),
                        Text('Fuel Consumed: ${formData['vehicle_details']['fuelConsumed']}'),
                        Text('Ad Blue Consumed Cluster: ${formData['vehicle_details']['adBlueConsumedCluster']}'),
                        Text('Did Regeneration Happen: ${formData['vehicle_details']['didRegenerationHappen']}'),
                        Text('Lead Distance: ${formData['vehicle_details']['leadDistance']}'),
                        Text('Driving Speed: ${formData['vehicle_details']['drivingSpeed']}'),
                        Text('Actual FE in BB: ${formData['vehicle_details']['actualFeInBB']}'),
                      ],
                    ),
                  ),
                  SizedBox(width: 20), // Add spacing between the two columns
                  // Competitor Data Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Competitor Data:'),
                        Text('Vehicle Reg No: ${formData['competitor_data']['vehicleRegNo']}'),
                        Text('Brand: ${formData['competitor_data']['brand']}'),
                        Text('Chassis No: ${formData['competitor_data']['chassisNo']}'),
                        Text('Vehicle Model: ${formData['competitor_data']['vehicleModel']}'),
                        Text('Wheel Base: ${formData['competitor_data']['wheelBase']}'),
                        Text('ATS Type: ${formData['competitor_data']['atsType']}'),
                        Text('Emission: ${formData['competitor_data']['emission']}'),
                        Text('Tyre Brand: ${formData['competitor_data']['tyreBrand']}'),
                        Text('Application: ${formData['competitor_data']['application']}'),
                        Text('GVW Carried: ${formData['competitor_data']['gvwCarried']}'),
                        Text('Trip Start Date: ${formData['competitor_data']['tripStartDate']}'),
                        Text('Start Odo: ${formData['competitor_data']['startOdo']}'),
                        Text('Trip Finish Date: ${formData['competitor_data']['tripFinishDate']}'),
                        Text('End Odo: ${formData['competitor_data']['endOdo']}'),
                        Text('Start Place: ${formData['competitor_data']['startPlace']}'),
                        Text('End Place: ${formData['competitor_data']['endPlace']}'),
                        Text('Total Trail Kms: ${formData['competitor_data']['totalTrailKms']}'),
                        Text('Fuel Consumed: ${formData['competitor_data']['fuelConsumed']}'),
                        Text('Ad Blue Consumed Cluster: ${formData['competitor_data']['adBlueConsumedCluster']}'),
                        Text('Did Regeneration Happen: ${formData['competitor_data']['didRegenerationHappen']}'),
                        Text('Lead Distance: ${formData['competitor_data']['leadDistance']}'),
                        Text('Driving Speed: ${formData['competitor_data']['drivingSpeed']}'),
                        Text('Actual FE in BB: ${formData['competitor_data']['actualFeInBB']}'),
                      ],
                    ),
                  ),
                ],
              ),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await controller.submitForm();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Form submitted!')));
                },
                child: Text('Submit Form'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  PdfServiceConsolidatedForm.generatePdf(formData,signature);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('PDF Generated!')));
                },
                child: Text('Generate PDF'),
              ),
            ],
          ),
        ),
      ),
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
      yOffset += isTitle ? 30 : 20; // Increase spacing for title
    }

    // Header
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

    // Create Table for Vehicle Details & Competitor Data
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 2);
    grid.headers.add(1);

    final PdfGridRow headerRow = grid.headers[0];
    headerRow.cells[0].value = 'Vehicle Details';
    headerRow.cells[1].value = 'Competitor Data';
    headerRow.style = PdfGridCellStyle(
      backgroundBrush: PdfBrushes.lightGray,
      font: PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
    );

    final Map<String, dynamic> vehicleDetails = formData['vehicle_details'];
    final Map<String, dynamic> competitorData = formData['competitor_data'];

    int maxLength = vehicleDetails.length > competitorData.length
        ? vehicleDetails.length
        : competitorData.length;

    for (int i = 0; i < maxLength; i++) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = i < vehicleDetails.length
          ? '${vehicleDetails.keys.elementAt(i)}: ${vehicleDetails.values.elementAt(i)}'
          : '';
      row.cells[1].value = i < competitorData.length
          ? '${competitorData.keys.elementAt(i)}: ${competitorData.values.elementAt(i)}'
          : '';
    }

    // Draw table on page
    final PdfLayoutResult? result = grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, yOffset, pageWidth, 0), // Height will be calculated dynamically
    );

    if (result != null) {
      yOffset = result.bounds.bottom + 20; // Update yOffset based on the table's actual height
    }
    // Add Signature if Available
    if (signature != null) {
      graphics.drawString("Signature:", font, bounds: Rect.fromLTWH(0, yOffset, pageWidth, 20));
      yOffset += 20;
      final PdfBitmap signatureImage = PdfBitmap(signature);
      graphics.drawImage(signatureImage, Rect.fromLTWH(0, yOffset, 200, 100));
    }

    // Save PDF
    final List<int> bytes = await document.save();
    document.dispose();

    // Ask user to choose save location
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final file = File('$selectedDirectory/FormReview.pdf');
      await file.writeAsBytes(bytes);
      print('PDF saved at: ${file.path}');
    }
  }
}


