import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/projectdetails/staff_list_model.dart';
import '../../models/projectdetails/unit_list_model.dart';
import '../../models/projectdetails/site_drawing_model.dart';
import '../../service/service.dart';

class SiteDrawingPage extends StatefulWidget {
  final String projectId;
  final String projectNo;
  final String clientId;

  const SiteDrawingPage({
    super.key,
    required this.projectId,
    required this.projectNo,
    required this.clientId,
  });

  @override
  State<SiteDrawingPage> createState() => _SiteDrawingPageState();
}

class _SiteDrawingPageState extends State<SiteDrawingPage> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  // ------------------------------------------------------------
  // ADD DRAWING VARIABLES
  // ------------------------------------------------------------

  PlatformFile? _selectedFile;

  ProjectDocumentUnit? _selectedUnit;
  SiteLift? _selectedSiteLift;

  final TextEditingController _remarksController = TextEditingController();

  // ------------------------------------------------------------
  // DRAWINGS
  // ------------------------------------------------------------

  List<SiteDrawing> _drawings = [];

  bool get canAddDrawing {
    return _drawings.any(
      (drawing) => drawing.workStatus.trim().toLowerCase() == 'running',
    );
  }

  // ------------------------------------------------------------
  // UNIT / SITE LIFT
  // ------------------------------------------------------------

  List<ProjectDocumentUnit> _unitList = [];
  List<SiteLift> _siteLiftList = [];

  bool _isLoadingUnits = false;
  bool _isLoadingSiteLifts = false;
  // bool _isSubmitting = false;

  // ------------------------------------------------------------
  // PAGE LOADING
  // ------------------------------------------------------------

  bool _isLoading = true;
  String? _errorMessage;

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _fetchDrawings();
    _loadUnits();
    _loadSiteLifts();
  }

  // ------------------------------------------------------------
  // FETCH DRAWINGS
  // ------------------------------------------------------------

  Future<void> _fetchDrawings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await HttpService.getSiteDrawings(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        setState(() {
          _drawings = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response?.message.isNotEmpty == true
              ? response!.message
              : 'Failed to load site drawings';

          _isLoading = false;
        });
      }
    } catch (e) {
      log('getSiteDrawings error: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // ------------------------------------------------------------
  // UNIT API
  // ------------------------------------------------------------

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
      log('Unit API error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUnits = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // SITE LIFT API
  // ------------------------------------------------------------

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
      log('Site Lift API error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSiteLifts = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // OPEN DRAWING
  // ------------------------------------------------------------

  Future<void> _openDrawing(String url) async {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Drawing URL is not available'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid drawing URL'),
        ),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open drawing'),
          ),
        );
      }
    } catch (e) {
      log('Open drawing error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open drawing: $e'),
        ),
      );
    }
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
                Icons.architecture_outlined,
                size: 45,
                color: _primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Drawings Yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add site drawings to see them here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ERROR
  // ------------------------------------------------------------

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _fetchDrawings,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DRAWING CARD
  // ------------------------------------------------------------

  Widget _buildDrawingCard(SiteDrawing drawing) {
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
            // ------------------------------------------------------------
            // HEADER
            // ------------------------------------------------------------
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
                  child: const Icon(
                    Icons.description_outlined,
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
                        'Site Drawing',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        drawing.createdAt,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // ----------------------------------------------------------
                // EDIT BUTTON
                // ----------------------------------------------------------
                InkWell(
                  onTap: () => _showEditDrawingDialog(drawing),
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

                // ----------------------------------------------------------
                // DELETE BUTTON
                // ----------------------------------------------------------
                InkWell(
                  onTap: () {
                    _deleteDrawing(drawing);
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

            // ------------------------------------------------------------
            // UNIT + SITE LIFT
            // ------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.home_work_outlined,
                    'Unit',
                    drawing.unitNo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoItem(
                    Icons.elevator_outlined,
                    'Site Lift',
                    drawing.siteLiftName,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------------------
            // STAFF + STATUS
            // ------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.person_outline_rounded,
                    'Staff',
                    drawing.staffName,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusItem(
                    drawing.workStatus,
                  ),
                ),
              ],
            ),

            // ------------------------------------------------------------
            // VIEW FILE
            // ------------------------------------------------------------
            const SizedBox(height: 12),

            InkWell(
              onTap: () => _openDrawing(drawing.mediaUrl),
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
                      child: const Icon(
                        Icons.insert_drive_file_outlined,
                        color: _primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'View File',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            drawing.fileName.isEmpty
                                ? 'View site drawing document'
                                : drawing.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            // ------------------------------------------------------------
            // REMARKS
            // ------------------------------------------------------------
            if (drawing.remarks.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 17,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        drawing.remarks,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // INFO ITEM
  // ------------------------------------------------------------

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
  ) {
    final displayValue = value.trim().isEmpty ? '--' : value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: _primary,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayValue,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // STATUS
  // ------------------------------------------------------------

  Widget _buildStatusItem(String status) {
    final value = status.trim().isEmpty ? 'Unknown' : status;

    final color = _getStatusColor(value);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.circle,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _capitalize(value),
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
      case 'ongoing':
        return Colors.orange;

      case 'completed':
        return Colors.green;

      case 'pending':
        return Colors.amber;

      case 'cancelled':
      case 'canceled':
        return Colors.red;

      default:
        return _primary;
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  // ------------------------------------------------------------
  // LOADING
  // ------------------------------------------------------------

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: _primary,
      ),
    );
  }

  // ------------------------------------------------------------
  // ADD DRAWING DIALOG
  // ------------------------------------------------------------

  Future<void> _showAddDrawingDialog() async {
    _selectedUnit = null;
    _selectedSiteLift = null;
    _selectedFile = null;
    _remarksController.clear();
    bool _isAdding = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Add Drawing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // UNIT
                    // ------------------------------------------------

                    const Text(
                      'Unit',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    DropdownButtonFormField<ProjectDocumentUnit>(
                      value: _selectedUnit,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: _isLoadingUnits
                            ? 'Loading units...'
                            : 'Select Unit',
                        prefixIcon: const Icon(
                          Icons.home_work_outlined,
                          size: 20,
                          color: _primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: _primary,
                          ),
                        ),
                      ),
                      items: _unitList.map((unit) {
                        return DropdownMenuItem<ProjectDocumentUnit>(
                          value: unit,
                          child: Text(
                            unit.unitNo,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _isLoadingUnits
                          ? null
                          : (value) {
                              setDialogState(() {
                                _selectedUnit = value;
                              });
                            },
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // SITE LIFT
                    // ------------------------------------------------

                    const Text(
                      'Site Lift',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    DropdownButtonFormField<SiteLift>(
                      value: _selectedSiteLift,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: _isLoadingSiteLifts
                            ? 'Loading site lifts...'
                            : 'Select Site Lift',
                        prefixIcon: const Icon(
                          Icons.elevator_outlined,
                          size: 20,
                          color: _primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: _primary,
                          ),
                        ),
                      ),
                      items: _siteLiftList.map((lift) {
                        return DropdownMenuItem<SiteLift>(
                          value: lift,
                          child: Text(
                            lift.siteLiftName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _isLoadingSiteLifts
                          ? null
                          : (value) {
                              setDialogState(() {
                                _selectedSiteLift = value;
                              });
                            },
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // FILE
                    // ------------------------------------------------

                    const Text(
                      'Drawing File',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    InkWell(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: [
                            'jpg',
                            'jpeg',
                            'png',
                            'pdf',
                          ],
                        );

                        if (result != null && result.files.isNotEmpty) {
                          setDialogState(() {
                            _selectedFile = result.files.first;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.attach_file_rounded,
                              color: _primary,
                              size: 21,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedFile == null
                                    ? 'Choose drawing file'
                                    : _selectedFile!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _selectedFile == null
                                      ? Colors.grey.shade600
                                      : Colors.black87,
                                  fontWeight: _selectedFile == null
                                      ? FontWeight.w400
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // REMARKS - LAST
                    // ------------------------------------------------

                    const Text(
                      'Remarks',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    TextField(
                      controller: _remarksController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter remarks',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(
                            bottom: 55,
                          ),
                          child: Icon(
                            Icons.notes_rounded,
                            size: 20,
                            color: _primary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: _primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                18,
                0,
                18,
                16,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isAdding
                      ? null
                      : () async {
                          // Unit validation
                          if (_selectedUnit == null ||
                              _selectedUnit!.unitNo.trim().isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Please select Unit'),
                              ),
                            );
                            return;
                          }

                          // Site Lift validation
                          if (_selectedSiteLift == null ||
                              _selectedSiteLift!.siteLiftName.trim().isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Please select Site Lift'),
                              ),
                            );
                            return;
                          }

                          // File validation
                          if (_selectedFile == null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Please select drawing file'),
                              ),
                            );
                            return;
                          }

                          // File size validation - 5 MB
                          if (_selectedFile!.size > 5 * 1024 * 1024) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('File size must not exceed 5 MB'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            _isAdding = true;
                          });

                          try {
                            final success = await HttpService.addSiteDrawing(
                              projectId: widget.projectId,
                              clientId: widget.clientId,
                              unitNo: _selectedUnit!.id,
                              liftNo: _selectedSiteLift!.id,
                              remarks: _remarksController.text.trim(),
                              siteDrawing: _selectedFile!,
                            );

                            if (!mounted) return;

                            if (success) {
                              Navigator.pop(dialogContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Site drawing added successfully'),
                                ),
                              );

                              await _fetchDrawings();
                            } else {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to add site drawing'),
                                ),
                              );
                            }
                          } catch (e) {
                            log('Submit site drawing error: $e');

                            if (!mounted) return;

                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Something went wrong: $e'),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setDialogState(() {
                                _isAdding = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primary.withOpacity(0.6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isAdding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //Edit Drawing dialog
  Future<void> _showEditDrawingDialog(SiteDrawing drawing) async {
    // Find existing unit by ID
    _selectedUnit = _unitList.cast<ProjectDocumentUnit?>().firstWhere(
          (unit) => unit?.id.toString() == drawing.unitId.toString(),
          orElse: () => null,
        );

    // Find existing site lift by ID
    // Find existing site lift by name
    _selectedSiteLift = _siteLiftList.cast<SiteLift?>().firstWhere(
          (lift) =>
              lift?.siteLiftName.trim().toLowerCase() ==
              drawing.siteLiftName.trim().toLowerCase(),
          orElse: () => null,
        );

    _selectedFile = null;

    _remarksController.text = drawing.remarks;
    bool _isEditing = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Edit Drawing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // UNIT
                    const Text(
                      'Unit',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    DropdownButtonFormField<ProjectDocumentUnit>(
                      value: _selectedUnit,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: _isLoadingUnits
                            ? 'Loading units...'
                            : 'Select Unit',
                        prefixIcon: const Icon(
                          Icons.home_work_outlined,
                          size: 20,
                          color: _primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: _unitList.map((unit) {
                        return DropdownMenuItem<ProjectDocumentUnit>(
                          value: unit,
                          child: Text(
                            unit.unitNo,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _isLoadingUnits
                          ? null
                          : (value) {
                              setDialogState(() {
                                _selectedUnit = value;
                              });
                            },
                    ),

                    const SizedBox(height: 16),

                    // SITE LIFT
                    const Text(
                      'Site Lift',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    DropdownButtonFormField<SiteLift>(
                      value: _selectedSiteLift,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: _isLoadingSiteLifts
                            ? 'Loading site lifts...'
                            : 'Select Site Lift',
                        prefixIcon: const Icon(
                          Icons.elevator_outlined,
                          size: 20,
                          color: _primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: _siteLiftList.map((lift) {
                        return DropdownMenuItem<SiteLift>(
                          value: lift,
                          child: Text(
                            lift.siteLiftName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _isLoadingSiteLifts
                          ? null
                          : (value) {
                              setDialogState(() {
                                _selectedSiteLift = value;
                              });
                            },
                    ),

                    const SizedBox(height: 16),

                    // FILE
                    const Text(
                      'Drawing File',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    InkWell(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: [
                            'jpg',
                            'jpeg',
                            'png',
                            'pdf',
                          ],
                        );

                        if (result != null && result.files.isNotEmpty) {
                          final file = result.files.first;

                          if (file.size > 5 * 1024 * 1024) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'File size must not exceed 5 MB',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            _selectedFile = file;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.attach_file_rounded,
                              color: _primary,
                              size: 21,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedFile == null
                                    ? drawing.fileName
                                    : _selectedFile!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // REMARKS
                    const Text(
                      'Remarks',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    TextField(
                      controller: _remarksController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter remarks',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 55),
                          child: Icon(
                            Icons.notes_rounded,
                            size: 20,
                            color: _primary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                18,
                0,
                18,
                16,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isEditing
                      ? null
                      : () async {
                          // UNIT VALIDATION
                          if (_selectedUnit == null ||
                              _selectedUnit!.unitNo.trim().isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select Unit',
                                ),
                              ),
                            );
                            return;
                          }

                          // SITE LIFT VALIDATION
                          if (_selectedSiteLift == null ||
                              _selectedSiteLift!.siteLiftName.trim().isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select Site Lift',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            _isEditing = true;
                          });

                          try {
                            final success = await HttpService.updateSiteDrawing(
                              drawingId: drawing.id,
                              projectId: widget.projectId,
                              clientId: widget.clientId,
                              unitNo: _selectedUnit!.id,
                              liftNo: _selectedSiteLift!.id,
                              remarks: _remarksController.text.trim(),
                              siteDrawing: _selectedFile,
                            );

                            if (!mounted) return;

                            if (success) {
                              Navigator.pop(dialogContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Site drawing updated successfully'),
                                ),
                              );

                              await _fetchDrawings();
                            } else {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Failed to update site drawing'),
                                ),
                              );
                            }
                          } catch (e) {
                            log('Update site drawing error: $e');

                            if (!mounted) return;

                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Something went wrong: $e'),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setDialogState(() {
                                _isEditing = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primary.withOpacity(0.6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isEditing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //delete function
  Future<void> _deleteDrawing(SiteDrawing drawing) async {
    bool _isDeleting = false;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Drawing'),
          content: const Text(
            'Are you sure you want to delete this site drawing?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      setState(() {
        _isDeleting = true;
      });

      final success = await HttpService.deleteSiteDrawing(
        drawingId: drawing.id,
        projectId: widget.projectId,
      );

      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Site drawing deleted successfully'),
          ),
        );

        await _fetchDrawings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete site drawing'),
          ),
        );
      }
    } catch (e) {
      log('Delete site drawing error: $e');

      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
        ),
      );
    }
  }
  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        title: const Text(
          'Site Drawing',
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
          if (canAddDrawing)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: _showAddDrawingDialog,
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
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Add Drawing',
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
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
              ? _buildError()
              : _drawings.isEmpty
                  ? RefreshIndicator(
                      color: _primary,
                      onRefresh: _fetchDrawings,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: _buildEmptyState(),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: _primary,
                      onRefresh: _fetchDrawings,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          top: 14,
                          bottom: 25,
                        ),
                        itemCount: _drawings.length,
                        itemBuilder: (context, index) {
                          return _buildDrawingCard(
                            _drawings[index],
                          );
                        },
                      ),
                    ),
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }
}
