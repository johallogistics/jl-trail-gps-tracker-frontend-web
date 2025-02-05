import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';


class DigitalSignatureScreen extends StatefulWidget {
  const DigitalSignatureScreen({super.key});

  @override
  _DigitalSignatureScreenState createState() => _DigitalSignatureScreenState();
}

class _DigitalSignatureScreenState extends State<DigitalSignatureScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review and Sign Report'),
      ),
      body: Column(
        children: [
          // Placeholder for the report
          const Text(
            'Report Title',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'This is the content of the report. Please review the details below and provide your signature.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const Divider(),

          // Signature Pad
          const Text(
            'Customer Signature:',
            style: TextStyle(fontSize: 18),
          ),
          Signature(
            width: 500,
            height: 150,
            controller: _signatureController,
            backgroundColor: Colors.blue.shade50,
          ),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _signatureController.clear();
                },
                child: const Text('Clear'),
              ),
              ElevatedButton(
                onPressed: _saveReportWithSignature,
                child: const Text('Save Report'),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Future<void> _saveReportWithSignature() async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a signature.')),
      );
      return;
    }

    // Capture the signature as an image
    final Uint8List? signature = await _signatureController.toPngBytes();
    if (signature == null) return;

    // Create the PDF document
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();

    // Add report content
    page.graphics.drawString(
      'Report Title',
      PdfStandardFont(PdfFontFamily.helvetica, 20),
      bounds: const Rect.fromLTWH(0, 0, 500, 30),
    );

    page.graphics.drawString(
      'This is the content of the report. Please review the details below.',
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      bounds: const Rect.fromLTWH(0, 40, 500, 20),
    );

    // Add the signature to the PDF
    final PdfBitmap signatureImage = PdfBitmap(signature);
    page.graphics.drawImage(
      signatureImage,
      const Rect.fromLTWH(0, 100, 200, 100),
    );

    // Save the PDF file
    final List<int> bytes = await document.save();
    document.dispose();

    // Ask user to choose save location
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      // User canceled the picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save canceled')),
      );
      return;
    }

    final path = '$selectedDirectory/SignedReport.pdf';
    final file = File(path);
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report saved at: $path')),
    );
  }
}
