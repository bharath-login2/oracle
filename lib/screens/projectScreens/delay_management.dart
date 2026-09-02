import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/projectdetails/project_delay_management.dart';
import '../../models/projectdetails/staff_list_model.dart';
import '../../models/projectdetails/unit_list_model.dart';
import '../../service/service.dart';

class DelayManagementPage extends StatefulWidget {
  final String projectId;
  final String projectNo;

  const DelayManagementPage({
    super.key,
    required this.projectId,
    required this.projectNo,
  });

  @override
  State<DelayManagementPage> createState() => _DelayManagementPageState();
}

class _DelayManagementPageState extends State<DelayManagementPage> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  List<ProjectDelay> _delayList = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDelays();
  }

  // LOAD DELAYS

  Future<void> _loadDelays() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await HttpService.getProjectDelays(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      setState(() {
        _delayList = response?.data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      log('Load delays error: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load delays: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ADD DELAY

  void _addDelay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _AddDelayDialog(
          projectId: widget.projectId,
          projectNo: widget.projectNo,
          onSuccess: () {
            _loadDelays();
          },
        );
      },
    );
  }

  // EDIT DELAY

  void _editDelay(ProjectDelay delay) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _EditDelayDialog(
          projectId: widget.projectId,
          projectNo: widget.projectNo,
          delay: delay,
          onSuccess: () {
            _loadDelays();
          },
        );
      },
    );
  }

  // DELETE DELAY

  Future<void> _deleteDelay(ProjectDelay delay) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Delay'),
          content: Text(
            'Are you sure you want to delete Delay #${delay.id}?',
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

    if (confirmed != true) {
      return;
    }

    try {
      final success = await HttpService.deleteProjectDelay(
          delayId: delay.id, projectId: widget.projectId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delay deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        await _loadDelays();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete delay'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      log('Delete delay error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete delay: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // SUPPORTING PHOTOS

  Widget _buildSupportingPhotos(ProjectDelay delay) {
    final photoIds = delay.supportingPhotoFileIds;

    print('Delay ${delay.id} photo IDs: $photoIds');

    if (photoIds.isEmpty) {
      return _buildInfoRow(
        Icons.photo_library_outlined,
        'Supporting Photos',
        'No Photos',
      );
    }

    return InkWell(
      onTap: () {
        _openSupportingPhotos(photoIds);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 4,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 19,
              color: _primary,
            ),
            const SizedBox(width: 10),
            const SizedBox(
              width: 125,
              child: Text(
                'Supporting Photos',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Text(
                    '${photoIds.length} Photo(s)',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF263238),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.open_in_new,
                    size: 17,
                    color: _primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSupportingPhotos(List<String> ids) async {
    if (ids.isEmpty) {
      return;
    }

    if (ids.length == 1) {
      await _openDriveFile(ids.first);
      return;
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Supporting Photos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${ids.length} photo(s) available',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  ids.length,
                  (index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: _primary,
                        ),
                      ),
                      title: Text(
                        'Photo ${index + 1}',
                      ),
                      subtitle: const Text(
                        'Open supporting photo',
                      ),
                      trailing: const Icon(
                        Icons.open_in_new,
                        color: _primary,
                      ),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await _openDriveFile(ids[index]);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDriveFile(String fileId) async {
    final cleanId = fileId.trim();

    if (cleanId.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid photo file ID'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final url = Uri.parse(
      'https://drive.google.com/file/d/$cleanId/view?usp=sharing',
    );

    log('Opening Drive file: $cleanId');
    log('Drive URL: $url');

    try {
      final canOpen = await canLaunchUrl(url);

      log('Can launch URL: $canOpen');

      if (!canOpen) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open Google Drive'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      log('URL launched: $launched');

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Google Drive'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e, stackTrace) {
      log(
        'Error opening Drive file: $e',
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open photo: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Delay Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _addDelay,
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildDelayList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDelayList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _primary,
        ),
      );
    }

    if (_delayList.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _loadDelays,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          20,
        ),
        itemCount: _delayList.length,
        itemBuilder: (context, index) {
          final delay = _delayList[index];

          return _buildDelayCard(
            delay,
            index + 1,
          );
        },
      ),
    );
  }

  Widget _buildDelayCard(
    ProjectDelay delay,
    int number,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER

            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    delay.delayTypeName.isEmpty
                        ? 'Unknown Delay'
                        : delay.delayTypeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF263238),
                    ),
                  ),
                ),

                // Edit
                SizedBox(
                  width: 30,
                  height: 36,
                  child: IconButton(
                    onPressed: () {
                      _editDelay(delay);
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: 'Edit',
                  ),
                ),

                // Delete
                SizedBox(
                  width: 30,
                  height: 36,
                  child: IconButton(
                    onPressed: () {
                      _deleteDelay(delay);
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: 'Delete',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // DELAY TYPE

            _buildInfoRow(
              Icons.warning_amber_outlined,
              'Delay Type',
              delay.delayTypeName,
            ),

            const SizedBox(height: 10),

            // LOOSE TYPE

            _buildInfoRow(
              Icons.category_outlined,
              'Loose Type',
              delay.looseTypeName,
            ),

            const SizedBox(height: 10),

            // RESPONSIBLE PARTY

            _buildInfoRow(
              Icons.person_outline,
              'Responsible Party',
              delay.responsiblePartyId.isEmpty ? '-' : delay.responsiblePartyId,
            ),

            const SizedBox(height: 10),

            // SUPPORTING PHOTOS

            _buildSupportingPhotos(delay),

            const SizedBox(height: 10),

            // CREATED DATE

            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Created Date',
              _formatDate(delay.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: _primary,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 125,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF263238),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 42,
                color: _primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No delays found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No project delay records are available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) {
      return '-';
    }

    try {
      final parsedDate = DateTime.parse(
        date.replaceFirst(' ', 'T'),
      );

      return '${parsedDate.day.toString().padLeft(2, '0')}-'
          '${parsedDate.month.toString().padLeft(2, '0')}-'
          '${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }
}

// ADD DELAY DIALOG

class _AddDelayDialog extends StatefulWidget {
  final String projectId;
  final String projectNo;
  final VoidCallback onSuccess;

  const _AddDelayDialog({
    required this.projectId,
    required this.projectNo,
    required this.onSuccess,
  });

  @override
  State<_AddDelayDialog> createState() => _AddDelayDialogState();
}

class _AddDelayDialogState extends State<_AddDelayDialog> {
  static const Color _primary = Color(0xFF2A86C9);

  final _formKey = GlobalKey<FormState>();

  ProjectDocumentUnit? _selectedUnit;
  SiteLift? _selectedSiteLift;

  bool _isLoadingUnits = false;
  bool _isLoadingSiteLifts = false;
  bool _isSubmitting = false;

  List<ProjectDocumentUnit> _unitList = [];
  List<SiteLift> _siteLiftList = [];

  String? _selectedDelayType;
  String? _selectedLooseType;

  final TextEditingController _responsiblePartyController =
      TextEditingController();

  final List<PlatformFile> _supportingPhotos = [];

  // DELAY TYPES

  final List<Map<String, String>> _delayTypes = [
    {
      'id': '1',
      'name': 'Materials Delay',
    },
    {
      'id': '2',
      'name': 'Capital tools delay',
    },
  ];

  // LOOSE TYPES

  final List<Map<String, String>> _looseTypes = [
    {
      'id': '1',
      'name': 'Idile Manpower',
    },
    {
      'id': '2',
      'name': 'Activity Hold',
    },
  ];

  @override
  void initState() {
    super.initState();

    _loadUnits();
    _loadSiteLifts();
  }

  @override
  void dispose() {
    _responsiblePartyController.dispose();
    super.dispose();
  }

  // UNIT API

  Future<void> _loadUnits() async {
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

  // SITE LIFT API

  Future<void> _loadSiteLifts() async {
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

  // PHOTO PICKER

  Future<void> _addPhotos() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false, // ONLY ONE PHOTO
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      if (file.size > 5 * 1024 * 1024) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${file.name} exceeds 5 MB'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      if (file.path == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        // Replace existing photo instead of adding multiple
        _supportingPhotos.clear();
        _supportingPhotos.add(file);
      });
    } catch (e) {
      log('Photo picker error: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _supportingPhotos.removeAt(index);
    });
  }

  // INPUT DECORATION

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
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
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildLabel(
    String text, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // DROPDOWN

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) getLabel,
    required ValueChanged<T?> onChanged,
    bool isLoading = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: _inputDecoration(
        isLoading ? 'Loading...' : hint,
      ),
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : const Icon(
              Icons.keyboard_arrow_down_rounded,
            ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            getLabel(item),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: isLoading ? null : onChanged,
      validator: (value) {
        if (value == null) {
          return 'This field is required';
        }

        return null;
      },
    );
  }

  // STRING DROPDOWN

  Widget _buildStringDropdown({
    required String? value,
    required String hint,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(hint),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['id'],
          child: Text(
            item['name'] ?? '',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }

        return null;
      },
    );
  }

  // PHOTO UI

  Widget _buildPhotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Supporting Photos'),
        InkWell(
          onTap: _addPhotos,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    color: _primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _supportingPhotos.isEmpty
                        ? 'Add Supporting Photos'
                        : 'Photo Selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: _supportingPhotos.isEmpty
                          ? Colors.grey.shade600
                          : Colors.black87,
                      fontWeight: _supportingPhotos.isEmpty
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.add_rounded,
                  color: _primary,
                ),
              ],
            ),
          ),
        ),
        if (_supportingPhotos.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _supportingPhotos.length,
              itemBuilder: (context, index) {
                final file = _supportingPhotos[index];

                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: file.path != null
                            ? Image.file(
                                File(file.path!),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey.shade100,
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            _removePhoto(index);
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // SUBMIT

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await HttpService.addProjectDelay(
        projectId: widget.projectId,
        projectNo: widget.projectNo,
        siteLiftNo: _selectedSiteLift!.id,
        unitNo: _selectedUnit!.id,
        delayTypeId: _selectedDelayType!,
        looseTypeId: _selectedLooseType!,
        responsiblePartyId: _responsiblePartyController.text.trim(),
        supportingPhotos: _supportingPhotos,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);

        widget.onSuccess();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delay added successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add delay'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      log('Add Delay error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add delay: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 700,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                12,
                16,
              ),
              decoration: const BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Delay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(
                        'Unit No.',
                        required: true,
                      ),
                      _buildDropdown<ProjectDocumentUnit>(
                        value: _selectedUnit,
                        hint: 'Select Unit No.',
                        items: _unitList,
                        getLabel: (item) => item.unitNo,
                        isLoading: _isLoadingUnits,
                        onChanged: (value) {
                          setState(() {
                            _selectedUnit = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel(
                        'Site Lift No.',
                        required: true,
                      ),
                      _buildDropdown<SiteLift>(
                        value: _selectedSiteLift,
                        hint: 'Select Site Lift No.',
                        items: _siteLiftList,
                        getLabel: (item) => item.siteLiftName,
                        isLoading: _isLoadingSiteLifts,
                        onChanged: (value) {
                          setState(() {
                            _selectedSiteLift = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel(
                        'Project No.',
                        required: true,
                      ),
                      TextFormField(
                        initialValue: widget.projectNo,
                        readOnly: true,
                        decoration: _inputDecoration(
                          'Project No.',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Project No. is required';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel(
                        'Delay Type',
                        required: true,
                      ),
                      _buildStringDropdown(
                        value: _selectedDelayType,
                        hint: 'Select Delay Type',
                        items: _delayTypes,
                        onChanged: (value) {
                          setState(() {
                            _selectedDelayType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel(
                        'Loose Type',
                        required: true,
                      ),
                      _buildStringDropdown(
                        value: _selectedLooseType,
                        hint: 'Select Loose Type',
                        items: _looseTypes,
                        onChanged: (value) {
                          setState(() {
                            _selectedLooseType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel(
                        'Responsible Party',
                      ),
                      TextFormField(
                        controller: _responsiblePartyController,
                        keyboardType: TextInputType.text,
                        decoration: _inputDecoration(
                          'Enter Responsible Party',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPhotoPicker(),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// EDIT DELAY DIALOG

class _EditDelayDialog extends StatefulWidget {
  final String projectId;
  final String projectNo;
  final ProjectDelay delay;
  final VoidCallback onSuccess;

  const _EditDelayDialog({
    required this.projectId,
    required this.projectNo,
    required this.delay,
    required this.onSuccess,
  });

  @override
  State<_EditDelayDialog> createState() => _EditDelayDialogState();
}

class _EditDelayDialogState extends State<_EditDelayDialog> {
  static const Color _primary = Color(0xFF2A86C9);

  final _formKey = GlobalKey<FormState>();

  ProjectDocumentUnit? _selectedUnit;
  SiteLift? _selectedSiteLift;

  bool _isLoadingUnits = false;
  bool _isLoadingSiteLifts = false;
  bool _isSubmitting = false;

  List<ProjectDocumentUnit> _unitList = [];
  List<SiteLift> _siteLiftList = [];

  String? _selectedDelayType;
  String? _selectedLooseType;

  late TextEditingController _responsiblePartyController;

  final List<PlatformFile> _supportingPhotos = [];
  final List<String> _existingPhotoIds = [];
  // IMPORTANT:
  // These IDs now match the API response.
  //
  // API:
  // delay_type_id = 2
  // delay_type_name = Capital tools delay
  //
  // loose_type_id = 1
  // loose_type_name = Idile Manpower

  final List<Map<String, String>> _delayTypes = [
    {
      'id': '1',
      'name': 'Materials Delay',
    },
    {
      'id': '2',
      'name': 'Capital tools delay',
    },
  ];

  final List<Map<String, String>> _looseTypes = [
    {
      'id': '1',
      'name': 'Idile Manpower',
    },
    {
      'id': '2',
      'name': 'Activity Hold',
    },
  ];

  @override
  void initState() {
    super.initState();

    _responsiblePartyController = TextEditingController(
      text: widget.delay.responsiblePartyId,
    );

    _selectedDelayType = widget.delay.delayTypeId;
    _selectedLooseType = widget.delay.looseTypeId;

    // Load existing supporting photos
    _existingPhotoIds.addAll(
      widget.delay.supportingPhotoFileIds,
    );

    log(
      'Edit Delay ${widget.delay.id} existing photo IDs: $_existingPhotoIds',
    );

    _loadUnits();
    _loadSiteLifts();
  }

  @override
  void dispose() {
    _responsiblePartyController.dispose();
    super.dispose();
  }

  // UNIT API

  Future<void> _loadUnits() async {
    setState(() {
      _isLoadingUnits = true;
    });

    try {
      final response = await HttpService.getProjectDocumentUnits(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        final units = response.data;

        ProjectDocumentUnit? matchedUnit;

        // First try matching unit.id with unit_no.
        for (final unit in units) {
          if (unit.id.toString() == widget.delay.unitNo.toString()) {
            matchedUnit = unit;
            break;
          }
        }

        // If IDs are different, try unitNo.
        if (matchedUnit == null) {
          for (final unit in units) {
            if (unit.unitNo.toString() == widget.delay.unitNo.toString()) {
              matchedUnit = unit;
              break;
            }
          }
        }

        setState(() {
          _unitList = units;
          _selectedUnit = matchedUnit;
        });

        log(
          'Edit Unit API loaded: ${units.length}',
        );

        log(
          'Delay unit_no: ${widget.delay.unitNo}',
        );

        log(
          'Matched Unit: ${matchedUnit?.unitNo}',
        );
      }
    } catch (e) {
      log('Edit Unit API error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUnits = false;
        });
      }
    }
  }

  // SITE LIFT API

  Future<void> _loadSiteLifts() async {
    setState(() {
      _isLoadingSiteLifts = true;
    });

    try {
      final response = await HttpService.getSiteLifts(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        final lifts = response.data;

        SiteLift? matchedLift;

        // First try matching ID.
        for (final lift in lifts) {
          if (lift.id.toString() == widget.delay.siteLiftNo.toString()) {
            matchedLift = lift;
            break;
          }
        }

        // If ID does not match, try site lift name.
        if (matchedLift == null) {
          for (final lift in lifts) {
            if (lift.siteLiftName.toString() ==
                widget.delay.siteLiftNo.toString()) {
              matchedLift = lift;
              break;
            }
          }
        }

        setState(() {
          _siteLiftList = lifts;
          _selectedSiteLift = matchedLift;
        });

        log(
          'Edit Site Lift API loaded: ${lifts.length}',
        );

        log(
          'Delay site_lift_no: ${widget.delay.siteLiftNo}',
        );

        log(
          'Matched Site Lift: '
          '${matchedLift?.siteLiftName}',
        );
      }
    } catch (e) {
      log('Edit Site Lift API error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSiteLifts = false;
        });
      }
    }
  }

  // PHOTO PICKER

  Future<void> _addPhotos() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false, // ONLY ONE PHOTO
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      if (file.size > 5 * 1024 * 1024) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${file.name} exceeds 5 MB'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      if (file.path == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        // Replace existing selected photo
        _supportingPhotos.clear();
        _supportingPhotos.add(file);
      });
    } catch (e) {
      log('Edit photo picker error: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _supportingPhotos.removeAt(index);
    });
  }

  // INPUT DECORATION

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
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
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildLabel(
    String text, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // DROPDOWN

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) getLabel,
    required ValueChanged<T?> onChanged,
    bool isLoading = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: _inputDecoration(
        isLoading ? 'Loading...' : hint,
      ),
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : const Icon(
              Icons.keyboard_arrow_down_rounded,
            ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            getLabel(item),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: isLoading ? null : onChanged,
      validator: (value) {
        if (value == null) {
          return 'This field is required';
        }

        return null;
      },
    );
  }

  // STRING DROPDOWN

  Widget _buildStringDropdown({
    required String? value,
    required String hint,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(hint),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['id'],
          child: Text(
            item['name'] ?? '',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }

        return null;
      },
    );
  }

  // PHOTO UI

  Widget _buildPhotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Supporting Photos'),

        InkWell(
          onTap: _addPhotos,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    color: _primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _supportingPhotos.isEmpty
                        ? 'Add New Supporting Photos'
                        : '${_supportingPhotos.length} New Photo(s) Selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: _supportingPhotos.isEmpty
                          ? Colors.grey.shade600
                          : Colors.black87,
                      fontWeight: _supportingPhotos.isEmpty
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.add_rounded,
                  color: _primary,
                ),
              ],
            ),
          ),
        ),

        // EXISTING PHOTOS
        if (_existingPhotoIds.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'Existing Photos',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _existingPhotoIds.length,
              itemBuilder: (context, index) {
                final fileId = _existingPhotoIds[index];

                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          'https://drive.google.com/uc?export=view&id=$fileId',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            log(
                              'Failed to load existing photo: $fileId',
                            );

                            return Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        left: 5,
                        bottom: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Existing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],

        // NEW PHOTOS
        if (_supportingPhotos.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'New Photos',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _supportingPhotos.length,
              itemBuilder: (context, index) {
                final file = _supportingPhotos[index];

                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.file(
                          File(file.path!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            _removePhoto(index);
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],

        // NO EXISTING + NO NEW
        if (_existingPhotoIds.isEmpty && _supportingPhotos.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'No supporting photos',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  // SUBMIT / UPDATE

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      print(
        'Updating project ID: ${widget.projectId}',
      );
      print(
        'Updating project no: ${widget.projectNo}',
      );
      print(
        'Updating Delay ID: ${widget.delay.id}',
      );

      print(
        'Unit ID: ${_selectedUnit?.id}',
      );

      print(
        'Site Lift ID: ${_selectedSiteLift?.id}',
      );

      print(
        'Delay Type ID: $_selectedDelayType',
      );

      print(
        'Loose Type ID: $_selectedLooseType',
      );

      print(
        'Responsible Party: '
        '${_responsiblePartyController.text.trim()}',
      );

      final success = await HttpService.updateProjectDelay(
        delayId: widget.delay.id,
        projectId: widget.projectId,
        // projectNo: widget.projectNo,
        siteLiftNo: _selectedSiteLift!.id,
        unitNo: _selectedUnit!.id,
        delayTypeId: _selectedDelayType!,
        looseTypeId: _selectedLooseType!,
        responsiblePartyId: _responsiblePartyController.text.trim(),
        supportingPhotos: _supportingPhotos,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);

        widget.onSuccess();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Delay updated successfully',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to update delay',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      log('Update Delay error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update delay: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 700,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                12,
                16,
              ),
              decoration: const BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit Delay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // UNIT

                      _buildLabel(
                        'Unit No.',
                        required: true,
                      ),

                      _buildDropdown<ProjectDocumentUnit>(
                        value: _selectedUnit,
                        hint: 'Select Unit No.',
                        items: _unitList,
                        getLabel: (item) => item.unitNo,
                        isLoading: _isLoadingUnits,
                        onChanged: (value) {
                          setState(() {
                            _selectedUnit = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // SITE LIFT

                      _buildLabel(
                        'Site Lift No.',
                        required: true,
                      ),

                      _buildDropdown<SiteLift>(
                        value: _selectedSiteLift,
                        hint: 'Select Site Lift No.',
                        items: _siteLiftList,
                        getLabel: (item) => item.siteLiftName,
                        isLoading: _isLoadingSiteLifts,
                        onChanged: (value) {
                          setState(() {
                            _selectedSiteLift = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // PROJECT NO

                      _buildLabel(
                        'Project No.',
                        required: true,
                      ),

                      TextFormField(
                        initialValue: widget.projectNo,
                        readOnly: true,
                        decoration: _inputDecoration(
                          'Project No.',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // DELAY TYPE

                      _buildLabel(
                        'Delay Type',
                        required: true,
                      ),

                      _buildStringDropdown(
                        value: _selectedDelayType,
                        hint: 'Select Delay Type',
                        items: _delayTypes,
                        onChanged: (value) {
                          setState(() {
                            _selectedDelayType = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // LOOSE TYPE

                      _buildLabel(
                        'Loose Type',
                        required: true,
                      ),

                      _buildStringDropdown(
                        value: _selectedLooseType,
                        hint: 'Select Loose Type',
                        items: _looseTypes,
                        onChanged: (value) {
                          setState(() {
                            _selectedLooseType = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // RESPONSIBLE PARTY

                      _buildLabel(
                        'Responsible Party',
                      ),

                      TextFormField(
                        controller: _responsiblePartyController,
                        decoration: _inputDecoration(
                          'Enter Responsible Party',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // PHOTOS

                      _buildPhotoPicker(),
                    ],
                  ),
                ),
              ),
            ),

            // BUTTONS

            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Update',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
