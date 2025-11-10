import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class PrintInvoiceViewTemp extends StatelessWidget {
  final String pdfPath;

  const PrintInvoiceViewTemp({super.key, required this.pdfPath});

  Future<String> _saveWithNewName() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final fileName = "Proformainvoice_$formattedDate.pdf";

    final directory = await getTemporaryDirectory(); // safer for sharing
    final newPath = "${directory.path}/$fileName";

    final file = File(pdfPath);
    final newFile = await file.copy(newPath);
    return newFile.path;
  }

  Future<void> _downloadPDF(BuildContext context) async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);
      final fileName = "Proformainvoice_$formattedDate.pdf";

      final directory = await getExternalStorageDirectory();
      final downloadPath = "${directory!.path}/$fileName";

      final file = File(pdfPath);
      await file.copy(downloadPath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PDF saved successfully ✅"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving PDF: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sharePDF(BuildContext context) async {
    try {
      final newPath = await _saveWithNewName();
      await Share.shareXFiles(
        [XFile(newPath)],
        text: 'Here is your Proforma Invoice PDF.',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sharing PDF: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Proforma Preview',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Download PDF",
            onPressed: () => _downloadPDF(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: "Share PDF",
            onPressed: () => _sharePDF(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: PDFView(
            filePath: pdfPath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error opening PDF: $error")),
              );
            },
          ),
        ),
      ),
    );
  }
}
