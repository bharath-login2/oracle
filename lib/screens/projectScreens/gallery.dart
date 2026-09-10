import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../service/service.dart';
import '../../models/projectdetails/unit_list_model.dart';
import '../../models/projectdetails/staff_list_model.dart';
import '../../models/projectdetails/gallery_model.dart';
import 'package:url_launcher/url_launcher.dart';

class GalleryPage extends StatefulWidget {
  final String projectId;
  final String projectNo;
  final String clientId;

  const GalleryPage({
    super.key,
    required this.projectId,
    required this.projectNo,
    required this.clientId,
  });

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);
  //FOR UNIT LIST DROPDOWN
  List<ProjectDocumentUnit> _unitList = [];
  //FOR SITE LIFT DROPDOWN
  List<SiteLift> _siteLiftList = [];
  List<GalleryData> _galleryList = [];
  bool _isLoadingGallery = false;
  bool _isLoadingUnits = false;
  bool _isLoadingSiteLifts = false;

  //FOR ADD LOADING

  PlatformFile? _photo1;
  PlatformFile? _photo2;
  PlatformFile? _photo3;
  // REPLACE IMAGE

  final _video1Controller = TextEditingController();
  final _video2Controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  //FOR LOAD UNIT LIST NO DROPDOWN
  Future<void> _loadUnits() async {
    if (!mounted) return;

    setState(() {
      _isLoadingUnits = true;
    });

    try {
      final response = await HttpService.getProjectDocumentUnits(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        setState(() {
          _unitList = response.data;
        });
      }
    } catch (e) {
      print('Unit API error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUnits = false;
        });
      }
    }
  }

  //FOR LOAD SITE LIFT NO DROPDOWN
  Future<void> _loadSiteLifts() async {
    if (!mounted) return;

    setState(() {
      _isLoadingSiteLifts = true;
    });

    try {
      final response = await HttpService.getSiteLifts(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        setState(() {
          _siteLiftList = response.data;
        });
      }
    } catch (e) {
      print('Site Lift API error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSiteLifts = false;
        });
      }
    }
  }

  Future<void> _loadGallery() async {
    if (!mounted) return;

    setState(() {
      _isLoadingGallery = true;
    });

    try {
      final response = await HttpService.getGallery(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        setState(() {
          _galleryList = response.data;
        });
      }
    } catch (e) {
      print('Gallery API error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGallery = false;
        });
      }
    }
  }

  // PICK PHOTO
  Future<void> _pickPhoto(int photoNumber, StateSetter setDialogState) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    // 5 MB = 5 * 1024 * 1024 bytes
    if (file.size > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File size must be less than 5 MB'),
        ),
      );
      return;
    }

    setDialogState(() {
      if (photoNumber == 1) {
        _photo1 = file;
      } else if (photoNumber == 2) {
        _photo2 = file;
      } else {
        _photo3 = file;
      }
    });
  }

  // EMPTY STATE

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
              'No Gallery Items Yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload files to see them here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // SHOW ADD DIALOG
  Future<void> _showUploadDialog() async {
    ProjectDocumentUnit? selectedUnit;
    SiteLift? selectedSiteLift;
    bool _isSubmitting = false;

    _photo1 = null;
    _photo2 = null;
    _photo3 = null;

    _video1Controller.clear();
    _video2Controller.clear();
    //PHPTO PICKER
    Widget _buildPhotoPicker({
      required String title,
      required PlatformFile? file,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: _isSubmitting ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade400,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.upload_file,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  file == null ? title : file.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (file != null)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
            ],
          ),
        ),
      );
    }

    //FOR ADD LOADING

    await Future.wait([
      _loadUnits(),
      _loadSiteLifts(),
    ]);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Upload File',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Allowed Types: jpg/png/jpeg\n'
                        'Max upload size: 5 MB',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ---------------- UNIT ----------------
                      const Text(
                        'Unit No. *',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      DropdownButtonFormField<ProjectDocumentUnit>(
                        value: selectedUnit,
                        decoration: const InputDecoration(
                          hintText: 'Select Unit',
                          border: OutlineInputBorder(),
                        ),
                        items: _unitList.map((unit) {
                          return DropdownMenuItem<ProjectDocumentUnit>(
                            value: unit,
                            child: Text(unit.unitNo),
                          );
                        }).toList(),
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedUnit = value;
                                });
                              },
                      ),

                      const SizedBox(height: 16),

                      // ---------------- SITE LIFT ----------------
                      const Text(
                        'Site Lift No. *',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      DropdownButtonFormField<SiteLift>(
                        value: selectedSiteLift,
                        decoration: const InputDecoration(
                          hintText: 'Select Site Lift',
                          border: OutlineInputBorder(),
                        ),
                        items: _siteLiftList.map((lift) {
                          return DropdownMenuItem<SiteLift>(
                            value: lift,
                            child: Text(lift.siteLiftName),
                          );
                        }).toList(),
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedSiteLift = value;
                                });
                              },
                      ),

                      const SizedBox(height: 20),

                      // ---------------- PHOTO 1 ----------------
                      _buildPhotoPicker(
                        title: 'Upload Photo (1)',
                        file: _photo1,
                        onTap: () {
                          _pickPhoto(1, setDialogState);
                        },
                      ),

                      const SizedBox(height: 10),

                      // ---------------- PHOTO 2 ----------------
                      _buildPhotoPicker(
                        title: 'Upload Photo (2)',
                        file: _photo2,
                        onTap: () {
                          _pickPhoto(2, setDialogState);
                        },
                      ),

                      const SizedBox(height: 10),

                      // ---------------- PHOTO 3 ----------------
                      _buildPhotoPicker(
                        title: 'Upload Photo (3)',
                        file: _photo3,
                        onTap: () {
                          _pickPhoto(3, setDialogState);
                        },
                      ),

                      const SizedBox(height: 20),

                      // ---------------- VIDEO 1 ----------------
                      const Text(
                        'Upload Video Link (1)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      TextFormField(
                        controller: _video1Controller,
                        enabled: !_isSubmitting,
                        decoration: const InputDecoration(
                          hintText: 'Your URL',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ---------------- VIDEO 2 ----------------
                      const Text(
                        'Upload Video Link (2)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      TextFormField(
                        controller: _video2Controller,
                        enabled: !_isSubmitting,
                        decoration: const InputDecoration(
                          hintText: 'Your URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------- BUTTONS ----------------
              actions: [
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          // Unit validation
                          if (selectedUnit == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select Unit No.'),
                              ),
                            );
                            return;
                          }

                          // Site Lift validation
                          if (selectedSiteLift == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select Site Lift No.'),
                              ),
                            );
                            return;
                          }

                          // At least one photo OR video
                          final hasPhoto = _photo1 != null ||
                              _photo2 != null ||
                              _photo3 != null;

                          final hasVideo =
                              _video1Controller.text.trim().isNotEmpty ||
                                  _video2Controller.text.trim().isNotEmpty;

                          if (!hasPhoto && !hasVideo) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please upload at least one photo or add one video link.',
                                ),
                              ),
                            );
                            return;
                          }

                          // ---------------- SUBMIT ----------------
                          setDialogState(() {
                            _isSubmitting = true;
                          });

                          try {
                            final video =
                                _video1Controller.text.trim().isNotEmpty
                                    ? _video1Controller.text.trim()
                                    : _video2Controller.text.trim();

                            final success = await HttpService.addGallery(
                              projectId: widget.projectId,
                              clientId:
                                  widget.clientId, // <-- your actual client ID
                              unitNo: selectedUnit!.id,
                              liftNo: selectedSiteLift!.id,
                              photo1: _photo1,
                              photo2: _photo2,
                              photo3: _photo3,
                              video: video,
                            );

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pop(dialogContext);

                              await _loadGallery();

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Uploaded successfully'),
                                ),
                              );
                            } else {
                              setDialogState(() {
                                _isSubmitting = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Upload failed'),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() {
                              _isSubmitting = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Upload failed: $e',
                                ),
                              ),
                            );
                          }
                        },
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //SHOW EDIT DIALOG
  Future<void> _showEditDialog({
    required String projectId,
    required String galleryId,
    required String unitId,
    required String liftId,
    required String existingImageUrl,
    required String existingVideoUrl,
    required bool isVideo,
  }) async {
    // ============================================================
    // LOCAL DIALOG STATE
    // ============================================================

    final videoController = TextEditingController(
      text: existingVideoUrl,
    );

    ProjectDocumentUnit? selectedUnit;
    SiteLift? selectedSiteLift;
    PlatformFile? replacementImage;

    bool isSubmitting = false;

    // ============================================================
    // LOAD DROPDOWN DATA
    // ============================================================

    await Future.wait([
      _loadUnits(),
      _loadSiteLifts(),
    ]);

    if (!mounted) return;

    // ============================================================
    // FIND CURRENT UNIT
    // ============================================================

    for (final unit in _unitList) {
      if (unit.id == unitId) {
        selectedUnit = unit;
        break;
      }
    }

    // ============================================================
    // FIND CURRENT SITE LIFT
    // ============================================================

    for (final lift in _siteLiftList) {
      if (lift.id == liftId) {
        selectedSiteLift = lift;
        break;
      }
    }

    // ============================================================
    // SHOW DIALOG
    // ============================================================

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Edit Gallery',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // ==================================================
              // CONTENT
              // ==================================================

              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // INFO
                      // ==================================================

                      Text(
                        isVideo
                            ? 'Replace video using a YouTube link.'
                            : 'Replace image: jpg/png/jpeg\n'
                                'Max upload size: 5 MB',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // UNIT
                      // ==================================================

                      const Text(
                        'Unit No.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      DropdownButtonFormField<ProjectDocumentUnit>(
                        value: selectedUnit,
                        decoration: const InputDecoration(
                          hintText: 'Select Unit',
                          border: OutlineInputBorder(),
                        ),
                        items: _unitList.map((unit) {
                          return DropdownMenuItem<ProjectDocumentUnit>(
                            value: unit,
                            child: Text(unit.unitNo),
                          );
                        }).toList(),
                        onChanged: isSubmitting
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedUnit = value;
                                });
                              },
                      ),

                      const SizedBox(height: 16),

                      // ==================================================
                      // SITE LIFT
                      // ==================================================

                      const Text(
                        'Site Lift No.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      DropdownButtonFormField<SiteLift>(
                        value: selectedSiteLift,
                        decoration: const InputDecoration(
                          hintText: 'Select Site Lift',
                          border: OutlineInputBorder(),
                        ),
                        items: _siteLiftList.map((lift) {
                          return DropdownMenuItem<SiteLift>(
                            value: lift,
                            child: Text(lift.siteLiftName),
                          );
                        }).toList(),
                        onChanged: isSubmitting
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedSiteLift = value;
                                });
                              },
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // CURRENT MEDIA
                      // ==================================================

                      const Text(
                        'Current Media',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // --------------------------------------------------
                      // CURRENT IMAGE
                      // --------------------------------------------------

                      if (!isVideo && existingImageUrl.isNotEmpty)
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _getGoogleDriveImageUrl(
                                existingImageUrl,
                              ),
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) {
                                  return child;
                                }

                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 45,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        )

                      // --------------------------------------------------
                      // CURRENT VIDEO
                      // --------------------------------------------------

                      else if (isVideo && existingVideoUrl.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.video_library_outlined,
                                size: 45,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                existingVideoUrl,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  _openYouTube(existingVideoUrl);
                                },
                                icon: const Icon(
                                  Icons.open_in_new,
                                ),
                                label: const Text(
                                  'Watch Current Video',
                                ),
                              ),
                            ],
                          ),
                        )

                      // --------------------------------------------------
                      // NO CURRENT MEDIA
                      // --------------------------------------------------

                      else
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'No media available',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // REPLACE IMAGE
                      // ONLY SHOW FOR IMAGE RECORD
                      // ==================================================

                      if (!isVideo) ...[
                        const Text(
                          'Replace Image',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        InkWell(
                          onTap: isSubmitting
                              ? null
                              : () async {
                                  final result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: [
                                      'jpg',
                                      'jpeg',
                                      'png',
                                    ],
                                  );

                                  if (result == null || result.files.isEmpty) {
                                    return;
                                  }

                                  final file = result.files.first;

                                  if (file.path == null) {
                                    return;
                                  }

                                  // 5 MB validation
                                  if (file.size > 5 * 1024 * 1024) {
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'File size must be less than 5 MB',
                                        ),
                                      ),
                                    );

                                    return;
                                  }

                                  setDialogState(() {
                                    replacementImage = file;
                                  });
                                },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade400,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.image_outlined,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    replacementImage == null
                                        ? 'Choose replacement image'
                                        : replacementImage!.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (replacementImage != null)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Leave empty to keep the current image.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),

                        // ==================================================
                        // NEW IMAGE PREVIEW
                        // ==================================================

                        if (replacementImage != null &&
                            replacementImage!.path != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(
                                replacementImage!.path!,
                              ),
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ],

                      // ==================================================
                      // REPLACE VIDEO
                      // ONLY SHOW FOR VIDEO RECORD
                      // ==================================================

                      if (isVideo) ...[
                        const Text(
                          'Replace Video Link',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: videoController,
                          enabled: !isSubmitting,
                          keyboardType: TextInputType.url,
                          decoration: const InputDecoration(
                            hintText: 'Enter YouTube video link',
                            prefixIcon: Icon(
                              Icons.video_library_outlined,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter a new YouTube link to replace the current video.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ==========================================================
              // BUTTONS
              // ==========================================================

              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          // ==================================================
                          // UNIT VALIDATION
                          // ==================================================

                          if (selectedUnit == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select Unit No.',
                                ),
                              ),
                            );

                            return;
                          }

                          // ==================================================
                          // SITE LIFT VALIDATION
                          // ==================================================

                          if (selectedSiteLift == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select Site Lift No.',
                                ),
                              ),
                            );

                            return;
                          }

                          // ==================================================
                          // VIDEO VALIDATION
                          // ONLY FOR VIDEO RECORD
                          // ==================================================

                          final videoLink = videoController.text.trim();

                          if (isVideo) {
                            if (videoLink.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter a YouTube video link.',
                                  ),
                                ),
                              );

                              return;
                            }

                            if (!_isYouTubeUrl(videoLink)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter a valid YouTube video link.',
                                  ),
                                ),
                              );

                              return;
                            }
                          }

                          // ==================================================
                          // IMAGE VALIDATION
                          // ==================================================

                          if (!isVideo &&
                              replacementImage != null &&
                              replacementImage!.path == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select a valid image.',
                                ),
                              ),
                            );

                            return;
                          }

                          // ==================================================
                          // SUBMITTING
                          // ==================================================

                          setDialogState(() {
                            isSubmitting = true;
                          });

                          try {
                            final success = await HttpService.editGallery(
                              projectId: projectId,
                              galleryId: galleryId,
                              clientId: widget.clientId,

                              unitNo: selectedUnit!.id,
                              liftNo: selectedSiteLift!.id,

                              // IMAGE RECORD
                              replacementImage:
                                  !isVideo ? replacementImage : null,

                              // VIDEO RECORD
                              replacementVideoLink: isVideo ? videoLink : null,
                            );

                            if (!context.mounted) return;

                            // ==================================================
                            // SUCCESS
                            // ==================================================

                            if (success) {
                              Navigator.pop(dialogContext);

                              await _loadGallery();

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Gallery updated successfully',
                                  ),
                                ),
                              );
                            }

                            // ==================================================
                            // FAILED
                            // ==================================================

                            else {
                              setDialogState(() {
                                isSubmitting = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Gallery update failed',
                                  ),
                                ),
                              );
                            }
                          }

                          // ==================================================
                          // ERROR
                          // ==================================================

                          catch (e) {
                            if (!context.mounted) return;

                            setDialogState(() {
                              isSubmitting = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Update failed: $e',
                                ),
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    videoController.dispose();
  }

  //check youtube url
  bool _isYouTubeUrl(String url) {
    if (url.trim().isEmpty) {
      return true; // Empty is allowed
    }

    final uri = Uri.tryParse(url.trim());

    if (uri == null || !uri.hasAbsolutePath) {
      return false;
    }

    final host = uri.host.toLowerCase();

    return host == 'youtube.com' ||
        host == 'www.youtube.com' ||
        host == 'm.youtube.com' ||
        host == 'youtu.be' ||
        host == 'www.youtu.be';
  }

  //open youtubee
  Future<void> _openYouTube(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) return;

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open YouTube'),
        ),
      );
    }
  }

  String _getGoogleDriveImageUrl(String url) {
    final regex = RegExp(r'/file/d/([^/]+)');
    final match = regex.firstMatch(url);

    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }

    return url;
  }

  //view imgae
  void _viewImage(String mediaUrl) {
    final imageUrl = _getGoogleDriveImageUrl(mediaUrl);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 400,
                      child: Center(
                        child: Text(
                          'Unable to load image',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //CARD WIDGET
  Widget _buildGalleryCard({
    required String galleryId,
    required int index,
    required String date,
    required String unitNo,
    required String siteLiftNo,
    required String mediaUrl,
    required String createdBy,
    required String mediaType,
  }) {
    final bool isVideo = mediaType == '2' || mediaType.toLowerCase() == 'video';
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isVideo ? Icons.videocam_outlined : Icons.image_outlined,
                    color: _primary,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gallery',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // EDIT BUTTON
                InkWell(
                  onTap: () {
                    final gallery = _galleryList.firstWhere(
                      (item) => item.id == galleryId,
                    );

                    _showEditDialog(
                      projectId: widget.projectId,
                      galleryId: gallery.id,
                      unitId: gallery.unitId,
                      liftId: gallery.liftId,
                      existingImageUrl: gallery.fileType == '1'
                          ? (gallery.mediaUrl ?? '')
                          : '',
                      existingVideoUrl:
                          gallery.fileType == '2' ? gallery.fileName : '',
                      isVideo: gallery.fileType == '2',
                    );
                  },
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: _primary,
                      size: 18,
                    ),
                  ),
                ),

                const SizedBox(width: 7),

                // DELETE BUTTON
                InkWell(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Delete Gallery'),
                          content: const Text(
                            'Are you sure you want to delete this gallery item?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext, false);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext, true);
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    // User pressed Cancel or closed the dialog
                    if (confirm != true) return;

                    // Call delete API only after confirmation
                    final success = await HttpService.deleteGallery(
                      galleryId: galleryId,
                    );

                    if (!mounted) return;

                    if (success) {
                      await _loadGallery();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gallery deleted successfully'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Delete failed'),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                      size: 19,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Divider(height: 1),

            const SizedBox(height: 12),

            // UNIT
            _buildInfoRow(
              label: 'Unit',
              value: unitNo,
            ),
            const SizedBox(height: 12),
            //SITE LIFT
            _buildInfoRow(
              label: 'Site Lift',
              value: siteLiftNo,
            ),
            const SizedBox(height: 12),

            // CREATED BY
            _buildInfoRow(
              label: 'Created By',
              value: createdBy,
            ),

            const SizedBox(height: 15),

            const SizedBox(height: 12),

            const SizedBox(height: 12),

            // VIEW BUTTON
            InkWell(
              onTap: () {
                if (isVideo) {
                  _openYouTube(mediaUrl);
                } else {
                  _viewImage(mediaUrl);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _primary.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        isVideo
                            ? Icons.play_circle_outline
                            : Icons.visibility_outlined,
                        color: _primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isVideo ? 'Watch Video' : 'View Image',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isVideo
                                ? 'Open video on YouTube'
                                : 'View gallery image',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  // BUILD

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
              onTap: _showUploadDialog,
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
      // body:
      // _buildEmptyState()
      body: _isLoadingGallery
          ? const Center(
              child: CircularProgressIndicator(
                color: _primary,
              ),
            )
          : _galleryList.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _galleryList.length,
                  itemBuilder: (context, index) {
                    final gallery = _galleryList[index];

                    return _buildGalleryCard(
                      index: index + 1,
                      galleryId: gallery.id,
                      date: gallery.createdAt,
                      unitNo: gallery.unitNo,
                      siteLiftNo: gallery.siteLiftName,

                      // Image → mediaUrl
                      // YouTube → fileName
                      mediaUrl: gallery.fileType == '2'
                          ? gallery.fileName
                          : (gallery.mediaUrl ?? ''),

                      createdBy: gallery.staffName,
                      mediaType: gallery.fileType,
                    );
                  },
                ),
    );
  }
}
