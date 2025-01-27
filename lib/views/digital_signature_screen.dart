import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DigitalSignatureScreen extends StatefulWidget {
  @override
  _DigitalSignatureScreenState createState() => _DigitalSignatureScreenState();
}

class _DigitalSignatureScreenState extends State<DigitalSignatureScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
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
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Title',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'This is the content of the report. Please review the details below and provide your signature.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  // Add more report content here
                ],
              ),
            ),
          ),
          const Divider(),

          // Signature Pad
          const Text(
            'Customer Signature:',
            style: TextStyle(fontSize: 18),
          ),
          Container(
            height: 150,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Signature(
              controller: _signatureController,
              backgroundColor: Colors.white,
            ),
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
    // Check if the user signed
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

    // Add a page
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
    final Uint8List uint8ListBytes = Uint8List.fromList(bytes);
    // Save to device storage
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/SignedReport.pdf';
    final file = File(path);
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report saved at: $path')),
    );
  }
}
