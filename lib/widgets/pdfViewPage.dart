// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:login2/service/service.dart';
// import 'package:share_plus/share_plus.dart';

// class PdfViewPage extends StatefulWidget {
//   final String quotationId;
//   const PdfViewPage({super.key, required this.quotationId});

//   @override
//   State<PdfViewPage> createState() => _PdfViewPageState();
// }

// class _PdfViewPageState extends State<PdfViewPage> {
//   final HttpService httpService = HttpService();
//   bool isLoading = true;
//   String? pdfPath;

//   @override
//   void initState() {
//     super.initState();
//     _loadPdf();
//   }

//   Future<void> _loadPdf() async {
//     setState(() => isLoading = true);
//     final path = await httpService.apiViewPdf(widget.quotationId);
//     if (mounted) {
//       setState(() {
//         pdfPath = path;
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _downloadPdf() async {
//     if (pdfPath == null) return;
//     await Share.shareXFiles([XFile(pdfPath!)], text: "Quotation PDF");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Quotation PDF"),
//         backgroundColor: const Color(0xFF1C1A79),
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPdf),
//           IconButton(icon: const Icon(Icons.download), onPressed: _downloadPdf),
//           IconButton(icon: const Icon(Icons.share), onPressed: _downloadPdf),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : pdfPath != null
//           ? SfPdfViewer.file(File(pdfPath!))
//           : const Center(child: Text("PDF not available")),
//     );
//   }
// }
