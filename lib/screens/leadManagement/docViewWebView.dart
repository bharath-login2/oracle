import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../core/common.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String? documentUrl;
  final String? title;
  final String? extension;
  final String? fileSize;
  final String? createdDate;
  final String? createdBy;

  const DocumentViewerScreen({
    super.key,
    this.documentUrl,
    this.title,
    this.extension,
    this.fileSize,
    this.createdDate,
    this.createdBy,
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  late WebViewController _webViewController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) setState(() => isLoading = false);
          },
        ),
      );

    _loadContent();
  }

  void _loadContent() {
    bool isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic']
        .contains(widget.extension?.toLowerCase());
    if (!isImage) {
      String url = (widget.extension == 'pdf' ||
              widget.extension == 'doc' ||
              widget.extension == 'docx')
          ? 'https://docs.google.com/viewer?url=${widget.documentUrl}'
          : widget.documentUrl!;

      _webViewController.loadRequest(Uri.parse(url));
    } else {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> downloadFile(String url, String fileName) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      if (mounted) {
        Common.showProgressDialog(context, "Downloading...");
      }
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final filePath = '/storage/emulated/0/Download/$fileName';
          File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          Common.toastMessaage('Download Successfully', Colors.green);
        } else {
          Common.toastMessaage('Download Failed', Colors.red);
        }
      } catch (e) {
        Common.toastMessaage('Error: $e', Colors.red);
      } finally {
        if (mounted) Navigator.pop(context);
      }
    }
  }

  Future<void> _fileFromImageUrl() async {
    try {
      final response = await http.get(Uri.parse(widget.documentUrl!));
      if (response.statusCode == 200) {
        final documentDirectory = await getApplicationDocumentsDirectory();
        final file =
            File(p.join(documentDirectory.path, widget.title.toString()));
        await file.writeAsBytes(response.bodyBytes);
        XFile xfile = XFile(file.path);
        await Share.shareXFiles([xfile]);
      } else {
        Common.toastMessaage("Failed to load file for sharing", Colors.red);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back_ios_outlined,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 25),
                    SizedBox(
                      width: 150,
                      child: Text(
                        widget.title ?? "Viewer",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _showInfoDialog(),
                      child:
                          const Icon(Icons.info_outline, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => downloadFile(widget.documentUrl.toString(),
                          widget.title.toString()),
                      child: const Icon(Icons.download, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => _fileFromImageUrl(),
                      child: const Icon(Icons.share, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildViewer(),
          if (isLoading)
            Center(
                child: Lottie.asset('assets/main/loading.json',
                    fit: BoxFit.fill, width: 150)),
        ],
      ),
    );
  }

  Widget _buildViewer() {
    bool isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic']
        .contains(widget.extension?.toLowerCase());
    if (isImage) {
      return Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            widget.documentUrl!,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
          ),
        ),
      );
    } else {
      return WebViewWidget(controller: _webViewController);
    }
  }

  void _showInfoDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Info",
      pageBuilder: (ctx, _, __) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("File Information",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => Navigator.pop(ctx)),
                    ]),
                const Divider(),
                _infoRow("File Name", widget.title),
                _infoRow("File Size", widget.fileSize),
                _infoRow("Created Date", widget.createdDate),
                _infoRow("Created By", widget.createdBy),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        SizedBox(
            width: 100,
            child: Text("$label :",
                style: const TextStyle(fontWeight: FontWeight.w500))),
        Expanded(
            child: Text(value ?? "N/A",
                style: const TextStyle(color: Colors.black54))),
      ]),
    );
  }
}
