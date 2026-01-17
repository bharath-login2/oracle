import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:typed_data';

class PdfMemoryView extends StatelessWidget {
  final Uint8List bytes;

  const PdfMemoryView({super.key, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booked Data"),
       backgroundColor: const Color.fromARGB(255, 22, 145, 216),
        foregroundColor: Colors.white,
        elevation: 0,),
      body: PdfView(
        controller: PdfController(
          document: PdfDocument.openData(bytes),
        ),
      ),
    );
  }
}
