import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';

import '../views/daily_report_screen.dart';

class PdfService {
  static Future<void> generatePdf(DailyReportController controller, Map<String, String> employeeData, Uint8List? signature) async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;
    const double pageWidth = 500;

    // Header
    graphics.drawString(
      'Daily Report',
      PdfStandardFont(PdfFontFamily.helvetica, 20),
      bounds: const Rect.fromLTWH(0, 0, pageWidth, 30),
    );

    // Report Details
    double yOffset = 40;
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);

    void addText(String text) {
      graphics.drawString(text, font, bounds: Rect.fromLTWH(0, yOffset, pageWidth, 20));
      yOffset += 20;
    }

    addText('Employee Name: ${employeeData['name']}');
    addText('Phone: ${employeeData['phone']}');
    addText('Code: ${employeeData['code']}');
    addText('Month: ${employeeData['month']}');
    addText('Year: ${employeeData['year']}');
    addText('Incharge Name: ${employeeData['inchargeName']}');
    addText('Incharge Phone: ${employeeData['inchargePhone']}');
    addText('Shift: ${controller.shiftController.text}');
    addText('OT Hours: ${controller.otHoursController.text}');
    addText('Vehicle Model: ${controller.vehicleModelController.text}');
    addText('Reg No: ${controller.regNoController.text}');
    addText('In Time: ${controller.inTimeController.text}');
    addText('Out Time: ${controller.outTimeController.text}');
    addText('Working Hours: ${controller.workingHoursController.text}');
    addText('Starting KM: ${controller.startingKmController.text}');
    addText('Ending KM: ${controller.endingKmController.text}');
    addText('Total KM: ${controller.totalKmController.text}');
    addText('From: ${controller.fromPlaceController.text}');
    addText('To: ${controller.toPlaceController.text}');
    addText('Fuel Avg: ${controller.fuelAvgController.text}');
    addText('Co-Driver: ${controller.coDriverNameController.text}');
    addText('Co-Driver Phone: ${controller.coDriverPhoneController.text}');

    // Add Signature if Available
    if (signature != null) {
      final PdfBitmap signatureImage = PdfBitmap(signature);
      graphics.drawImage(signatureImage, Rect.fromLTWH(0, yOffset + 20, 200, 100));
    }

    // Save PDF
    final List<int> bytes = await document.save();
    document.dispose();

    // Ask user to choose save location
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      return;
    }

    final file = File('$selectedDirectory/DailyReport.pdf');
    await file.writeAsBytes(bytes);
  }
}
