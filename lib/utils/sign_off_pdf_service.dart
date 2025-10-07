import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/sign_off_models/sign_off.dart';
import '../models/sign_off_models/trip_details.dart';

class SignOffPdfService {
  static Future<void> savePdf(SignOff signOff) async {
    final pdf = pw.Document(
      title: 'Sign-Off Report #${signOff.id}',
      author: signOff.customerName,
    );

    final font = await PdfGoogleFonts.openSansRegular();
    final bold = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          // Title
          pw.Center(
            child: pw.Text(
              'Customer Sign-Off Report',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // --- General FE Summary ---
          _buildSectionTitle(context, 'Fuel Efficiency Summary', bold),
          _buildSummaryTable(context, signOff, font, bold),
          pw.SizedBox(height: 15),

          // --- Customer & Vehicle Details ---
          _buildSectionTitle(context, 'Customer & Vehicle Details', bold),
          _buildCustomerVehicleDetails(context, signOff, font, bold),
          pw.SizedBox(height: 15),

          // --- Trials Details (Trip Table) ---
          _buildSectionTitle(context, 'Trials Details', bold),
          _buildTrialsDetailsTable(context, signOff.tripDetails, font, bold),
          pw.SizedBox(height: 15),

          // --- Issues and Remarks ---
          _buildIssuesAndRemarks(context, signOff, font, bold),
          pw.SizedBox(height: 15),

          // --- Participant Sign-Off ---
          _buildSignOffTable(context, signOff, font, bold),

          // The PDF package handles page breaks, so photos would follow naturally
          if (signOff.photos.isNotEmpty) ...[
            pw.SizedBox(height: 15),
            _buildSectionTitle(context, 'Vehicle Photographs', bold),
            _buildPhotoSection(context, signOff, font, bold),
          ]
        ],
      ),
    );

    // Save/Share/Print the document
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'SignOff_Report_${signOff.id}_${signOff.customerName}.pdf',
    );
  }

  static pw.Widget _buildSectionTitle(pw.Context context, String title, pw.Font bold) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blueGrey700, width: 1),
        color: PdfColors.blueGrey100,
      ),
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(font: bold, fontSize: 10, color: PdfColors.blueGrey900),
      ),
    );
  }

  static pw.Widget _buildKv(String k, String v, pw.Font font, pw.Font bold, {double width = 120}) {
    return pw.SizedBox(
      width: width,
      child: pw.RichText(
        text: pw.TextSpan(
          style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.black),
          children: [
            pw.TextSpan(text: '$k: ', style: pw.TextStyle(font: bold)),
            pw.TextSpan(text: v),
          ],
        ),
      ),
    );
  }

  // --- FE Summary Table (Matches fields 2, 3, 4) ---
  static pw.Widget _buildSummaryTable(
      pw.Context context, SignOff s, pw.Font font, pw.Font bold) {
    return pw.Table.fromTextArray(
      cellAlignment: pw.Alignment.center,
      headerStyle: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellStyle: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.black),
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey600),
      columnWidths: const {
        0: pw.FlexColumnWidth(1),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
      },
      headers: ['Customer Expected FE', 'Before Trials FE', 'After Trials FE'],
      data: [
        [
          s.customerExpectedFE?.toStringAsFixed(2) ?? '-',
          s.beforeTrialsFE?.toStringAsFixed(2) ?? '-',
          s.afterTrialsFE?.toStringAsFixed(2) ?? '-',
        ],
      ],
    );
  }

  // --- Customer & Vehicle Details (Matches fields 5-18) ---
  static pw.Widget _buildCustomerVehicleDetails(
      pw.Context context, SignOff s, pw.Font font, pw.Font bold) {
    final vd = s.customerVehicleDetails;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildKv('Customer Name', s.customerName ?? '-', font, bold, width: 250),
            _buildKv('Vehicle No', vd?.vehicleNo ?? '-', font, bold),
            _buildKv('Model', vd?.model ?? '-', font, bold),
            _buildKv('Sale Date', vd?.saleDate ?? '-', font, bold),
            _buildKv('Trip Duration', vd?.tripDuration ?? '-', font, bold),
            _buildKv('Application', vd?.application ?? '-', font, bold),
            _buildKv('Road Type', vd?.roadType ?? '-', font, bold),
            _buildKv('Trip Route', vd?.tripRoute ?? '-', font, bold, width: 250),
          ],
        ),
        pw.SizedBox(height: 8),
        _buildKv('Customer Verbatim', vd?.customerVerbatim ?? '-', font, bold, width: double.infinity),
        pw.SizedBox(height: 8),
        pw.Text('Vehicle Check (In workshop) on Date: ${vd?.vehicleCheckDate ?? '-'}',
            style: pw.TextStyle(font: bold, fontSize: 9)),
        pw.Text('Issues found on vehicle: ${vd?.issuesFoundOnVehicleCheck ?? '-'}',
            style: pw.TextStyle(font: font, fontSize: 9)),
      ],
    );
  }

  // --- Trials Details Table (Matches fields 19-37) ---
  static pw.Widget _buildTrialsDetailsTable(
      pw.Context context, List<TripDetail> trips, pw.Font font, pw.Font bold) {
    final headers = [
      'Trip no', 'Trip Route', 'Trip Start Date', 'Trip End Date', 'Start km', 'End km', 'Trip km',
      'Max speed', 'Weight (GVW)', 'Actual Diesel Itrs', 'Total Trip km', 'Actual FE (kmpl)'
    ];

    final data = trips.map((td) => [
      td.tripNo,
      td.tripRoute,
      td.tripStartDate,
      td.tripEndDate,
      td.startKm?.toString() ?? '-',
      td.endKm?.toString() ?? '-',
      td.tripKm?.toString() ?? '-',
      td.maxSpeed?.toString() ?? '-',
      td.weightGVW?.toString() ?? '-',
      td.actualDieselLtrs?.toString() ?? '-',
      td.totalTripKm?.toString() ?? '-',
      td.actualFE?.toStringAsFixed(2) ?? '-',
    ]).toList();

    // Add "Over all Trip" row at the end
    final totalTripKm = trips.fold<double>(0, (sum, td) => sum + (td.totalTripKm ?? 0));
    final totalDieselLtrs = trips.fold<double>(0, (sum, td) => sum + (td.actualDieselLtrs ?? 0));
    final overallFE = (totalTripKm > 0 && totalDieselLtrs > 0) ? (totalTripKm / totalDieselLtrs).toStringAsFixed(2) : '-';

    data.add([
      'Over all Trip', // Trip No
      '-', '-', '-', '-', '-', '-', '-', '-',
      totalDieselLtrs.toStringAsFixed(2), // Actual Diesel Itrs
      totalTripKm.toStringAsFixed(2),      // Total Trip km
      overallFE                           // Actual FE
    ]);

    return pw.Table.fromTextArray(
      cellAlignment: pw.Alignment.center,
      headerStyle: pw.TextStyle(font: bold, fontSize: 6, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellStyle: pw.TextStyle(font: font, fontSize: 6, color: PdfColors.black),
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey600),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.5), 1: pw.FlexColumnWidth(1), 2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1), 4: pw.FlexColumnWidth(0.7), 5: pw.FlexColumnWidth(0.7),
        6: pw.FlexColumnWidth(0.7), 7: pw.FlexColumnWidth(0.7), 8: pw.FlexColumnWidth(0.7),
        9: pw.FlexColumnWidth(0.9), 10: pw.FlexColumnWidth(0.9), 11: pw.FlexColumnWidth(0.9),
      },
      headers: headers,
      data: data,
    );
  }

  // --- Issues and Remarks (Matches fields 38, 39) ---
  static pw.Widget _buildIssuesAndRemarks(
      pw.Context context, SignOff s, pw.Font font, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Issues found while trial/Customer driver habits corrected:',
            style: pw.TextStyle(font: bold, fontSize: 9)),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(5),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey500)),
          child: pw.Text(s.issuesFoundDuringTrial ?? '-', style: pw.TextStyle(font: font, fontSize: 9)),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Trial remarks:', style: pw.TextStyle(font: bold, fontSize: 9)),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(5),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey500)),
          child: pw.Text(s.trialRemarks ?? '-', style: pw.TextStyle(font: font, fontSize: 9)),
        ),
      ],
    );
  }

  // --- Participants and Signatures (Matches field 40) ---
  static pw.Widget _buildSignOffTable(
      pw.Context context, SignOff s, pw.Font font, pw.Font bold) {
    // Find participants by role
    final csm = s.participants.firstWhereOrNull((p) => p.role == 'CSM');
    final pc = s.participants.firstWhereOrNull((p) => p.role == 'PC');
    final customerDriver = s.participants.firstWhereOrNull((p) => p.role == 'Customer Driver');

    // Helper to get image or placeholder
    Future<pw.ImageProvider> getSignatureImage(String? url) async {
      if (url != null && url.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            return pw.MemoryImage(response.bodyBytes);
          }
        } catch (e) {
          // Ignore error, return placeholder
        }
      }
      // Placeholder for missing signature
      return pw.MemoryImage(
        (await rootBundle.load('assets/no_signature.png')).buffer.asUint8List(),
      );
    }

    // NOTE: For a real app, you would need to implement an image download
    // utility and fetch the signature image bytes to display them here.
    // For simplicity, we'll use a text/box placeholder unless you confirm
    // you have a way to fetch the image bytes (e.g. from a NetworkImage).

    pw.Widget signaturePlaceholder() {
      return pw.Container(
        height: 30,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey500)),
        child: pw.Text('Signature', style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600)),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey600),
      columnWidths: const {
        0: pw.FlexColumnWidth(1),
        1: pw.FlexColumnWidth(1.5),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('', style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('CSM', style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white), textAlign: pw.TextAlign.center),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('PC', style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white), textAlign: pw.TextAlign.center),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Customer Driver', style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white), textAlign: pw.TextAlign.center),
            ),
          ],
        ),
        // Participants Name Row
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Participants (Name)', style: pw.TextStyle(font: bold, fontSize: 8)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(csm?.name ?? '-', style: pw.TextStyle(font: font, fontSize: 8), textAlign: pw.TextAlign.center),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(pc?.name ?? '-', style: pw.TextStyle(font: font, fontSize: 8), textAlign: pw.TextAlign.center),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(customerDriver?.name ?? '-', style: pw.TextStyle(font: font, fontSize: 8), textAlign: pw.TextAlign.center),
            ),
          ],
        ),
        // Signature Row
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Sign', style: pw.TextStyle(font: bold, fontSize: 8)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: signaturePlaceholder(), // Placeholder for CSM signature
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: signaturePlaceholder(), // Placeholder for PC signature
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: signaturePlaceholder(), // Placeholder for Customer Driver signature
            ),
          ],
        ),
      ],
    );
  }

  // --- Photo Section (Matches fields 41, 42) ---
  static pw.Widget _buildPhotoSection(
      pw.Context context, SignOff s, pw.Font font, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('(Photo to be attached by (PC/CSM))',
            style: pw.TextStyle(font: font, fontSize: 8)),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 10,
          runSpacing: 10,
          children: s.photos.map((photo) {
            // NOTE: You must use the 'http' package and fetch the image bytes
            // to convert to a pw.Image. For simplicity, we'll use a placeholder.
            return pw.Container(
              width: 150,
              height: 100,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey600),
                color: PdfColors.grey300,
              ),
              alignment: pw.Alignment.center,
              child: pw.Text('Photo Placeholder\n(${photo.caption ?? 'No Caption'})',
                  style: pw.TextStyle(font: font, fontSize: 7)),
            );
          }).toList(),
        ),
      ],
    );
  }
}