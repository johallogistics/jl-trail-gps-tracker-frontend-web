import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../views/daily_report_screen.dart';

class PdfService {
  static Future<void> generatePdf(DailyReportController controller, Map<String, String> employeeData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Daily Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Employee Name: ${employeeData['name']}'),
              pw.Text('Employee Phone: ${employeeData['phone']}'),
              pw.Text('Employee Code: ${employeeData['code']}'),
              pw.Text('Month: ${employeeData['month']}'),
              pw.Text('Year: ${employeeData['year']}'),
              pw.Text('Incharge Name: ${employeeData['inchargeName']}'),
              pw.Text('Incharge Phone: ${employeeData['inchargePhone']}'),
              pw.SizedBox(height: 20),
              pw.Text('Date: ${controller.date}'),
              pw.Text('Shift: ${controller.shiftController.text}'),
              pw.Text('OT Hours: ${controller.otHoursController.text}'),
              pw.Text('Vehicle Model: ${controller.vehicleModelController.text}'),
              pw.Text('Reg No: ${controller.regNoController.text}'),
              pw.Text('In Time: ${controller.inTimeController.text}'),
              pw.Text('Out Time: ${controller.outTimeController.text}'),
              pw.Text('Working Hours: ${controller.workingHoursController.text}'),
              pw.Text('Starting KM: ${controller.startingKmController.text}'),
              pw.Text('Ending KM: ${controller.endingKmController.text}'),
              pw.Text('Total KM: ${controller.totalKmController.text}'),
              pw.Text('From Place: ${controller.fromPlaceController.text}'),
              pw.Text('To Place: ${controller.toPlaceController.text}'),
              pw.Text('Fuel Avg: ${controller.fuelAvgController.text}'),
              pw.Text('Co-Driver Name: ${controller.coDriverNameController.text}'),
              pw.Text('Co-Driver Phone: ${controller.coDriverPhoneController.text}'),
              pw.Text('Incharge Sign: ${controller.inchargeSignController.text}'),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/daily_report.pdf');
    await file.writeAsBytes(await pdf.save());

    print('PDF saved at: ${file.path}');
  }
}
