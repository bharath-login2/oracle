import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class GalleryPage extends StatefulWidget {
  final String projectId;
  final String projectNo;

  const GalleryPage({
    super.key,
    required this.projectId,
    required this.projectNo,
  });

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  final List<PlatformFile> _images = [];

  Future<void> _uploadImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'webp',
      ],
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _images.addAll(result.files);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 45,
                color: _primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Images Yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload photos to see them here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            // ElevatedButton.icon(
            //   onPressed: _uploadImages,
            //   icon: const Icon(
            //     Icons.cloud_upload_outlined,
            //     size: 19,
            //   ),
            //   label: const Text('Upload Images'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: _primary,
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 20,
            //       vertical: 12,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // IMAGE GRID
  // ------------------------------------------------------------

  Widget _buildImageGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final file = _images[index];

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: file.path != null
                  ? Image.file(
                      File(file.path!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
            ),

            // Delete button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        title: const Text(
          'Gallery',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: _uploadImages,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '+ Upload',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _primary,
                _primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _images.isEmpty ? _buildEmptyState() : _buildImageGrid(),
    );
  }
}
