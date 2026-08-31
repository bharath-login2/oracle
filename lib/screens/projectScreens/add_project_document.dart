import 'dart:developer';
import '../../service/service.dart';
import '../../models/projectdetails/staff_list_model.dart';
import '../../models/projectdetails/unit_list_model.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddProjectDocumentPage extends StatefulWidget {
  final String projectId;
  final String projectNo;

  const AddProjectDocumentPage({
    super.key,
    required this.projectId,
    required this.projectNo,
  });

  @override
  State<AddProjectDocumentPage> createState() => _AddProjectDocumentPageState();
}

class _AddProjectDocumentPageState extends State<AddProjectDocumentPage> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _remarkController = TextEditingController();

  ProjectDocumentUnit? _selectedUnit;
  SiteLift? _selectedSiteLift;
  bool _isLoadingSiteLifts = false;
  bool _isLoadingUnits = false;

  PlatformFile? _uploadFile;
  PlatformFile? _drawingsFile;
  PlatformFile? _methodStatementFile;
  PlatformFile? _riskAssessmentFile;
  PlatformFile? _itpFile;
  PlatformFile? _wirFile;
  PlatformFile? _inspectionReportsFile;
  PlatformFile? _testReportsFile;
  PlatformFile? _photosFile;
  PlatformFile? _videosFile;

  List<ProjectDocumentUnit> _unitList = [];

  List<SiteLift> _siteLiftList = [];

  final List<String> _documentTypes = [
    'Drawings',
    'Method of Statement',
    'Risk Assessment',
    'ITP',
    'WIR',
    'Inspection Reports',
    'Test Reports (TPI)',
    'Photos',
    'Videos',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  //load site lifts
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

  //load unit no
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

  @override
  void initState() {
    super.initState();
    _loadSiteLifts();
    _loadUnits();
  }

  Future<PlatformFile?> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'png',
          'jpeg',
          'pdf',
        ],
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;

      // 5 MB limit
      if (file.size > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'File size must not exceed 5 MB',
            ),
          ),
        );
        return null;
      }

      return file;
    } catch (e) {
      log('File picker error: $e');
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      log('FORM VALIDATION FAILED');
      return;
    }

    if (widget.projectNo.trim().isEmpty) {
      log('PROJECT NO EMPTY');
      return;
    }

    log('BEFORE API CALL');
    // Validate Unit, Site Lift, Project No and Title
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Extra safety check for Project No
    if (widget.projectNo.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project No. is required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final hasAnyFile = _uploadFile != null ||
        _drawingsFile != null ||
        _methodStatementFile != null ||
        _riskAssessmentFile != null ||
        _itpFile != null ||
        _wirFile != null ||
        _inspectionReportsFile != null ||
        _testReportsFile != null ||
        _photosFile != null ||
        _videosFile != null;

    if (!hasAnyFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one file'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await HttpService.addProjectDocument(
      projectId: widget.projectId,
      projectNo: widget.projectNo.trim(),
      unitNo: _selectedUnit!.id,
      siteLiftNo: _selectedSiteLift!.id,
      title: _titleController.text.trim(),
      remark: _remarkController.text.trim(),
      file: _uploadFile ??
          _drawingsFile ??
          _methodStatementFile ??
          _riskAssessmentFile ??
          _itpFile ??
          _wirFile ??
          _inspectionReportsFile ??
          _testReportsFile ??
          _photosFile ??
          _videosFile!,
    );
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document added successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add document'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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

  Widget _buildFilePicker({
    required String title,
    required PlatformFile? file,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        InkWell(
          onTap: onTap,
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
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.upload_file_rounded,
                    color: _primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    file?.name ?? 'Choose File',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          file == null ? Colors.grey.shade600 : Colors.black87,
                      fontWeight:
                          file == null ? FontWeight.normal : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.attach_file_rounded,
                  color: _primary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        title: const Text(
          'Add Document',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Allowed types
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _primary.withOpacity(0.15),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: _primary,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Allowed Types: jpg / png / jpeg / pdf\n'
                        'Max upload size: 5 MB',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Unit No.
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

              // Site Lift No.
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

              // Project No.
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

              // Title
              _buildLabel(
                'Title',
                required: true,
              ),

              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration(
                  'Enter document title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Attachments
              // _buildLabel(
              //   'Upload File',
              //   required: true,
              // ),

              _buildFilePicker(
                title: 'Upload File',
                file: _uploadFile,
                onTap: () async {
                  final file = await _pickFile();

                  if (file != null) {
                    setState(() {
                      _uploadFile = file;
                    });
                  }
                },
              ),

              _buildFilePicker(
                title: 'Drawings',
                file: _drawingsFile,
                onTap: () async {
                  final file = await _pickFile();

                  if (file != null) {
                    setState(() {
                      _drawingsFile = file;
                    });
                  }
                },
              ),

              _buildFilePicker(
                title: 'Method of Statement',
                file: _methodStatementFile,
                onTap: () async {
                  final file = await _pickFile();

                  if (file != null) {
                    setState(() {
                      _methodStatementFile = file;
                    });
                  }
                },
              ),

              _buildFilePicker(
                title: 'Risk Assessment',
                file: _riskAssessmentFile,
                onTap: () async {
                  final file = await _pickFile();

                  if (file != null) {
                    setState(() {
                      _riskAssessmentFile = file;
                    });
                  }
                },
              ),

              _buildFilePicker(
                title: 'ITP',
                file: _itpFile,
                onTap: () async {
                  final file = await _pickFile();

                  if (file != null) {
                    setState(() {
                      _itpFile = file;
                    });
                  }
                },
              ),

              _buildFilePicker(
                title: 'WIR',
                file: _wirFile,
                onTap: () async {
                  final file = await _pickFile();

                  if (file != null) {
                    setState(() {
                      _wirFile = file;
                    });
                  }
                },
              ),

              _buildFilePicker(
                title: 'Inspection Reports',
                file: _inspectionReportsFile,
                onTap: () async {
                  final file = await _pickFile();

                  if (file != null) {
                    setState(() {
                      _inspectionReportsFile = file;
                    });
                  }
                },
              ),

              _buildFilePicker(
                title: 'Test Reports (TPI)',
                file: _testReportsFile,
                onTap: () async {
                  final file = await _pickFile();

                  if (file != null) {
                    setState(() {
                      _testReportsFile = file;
                    });
                  }
                },
              ),

              _buildFilePicker(
                title: 'Photos',
                file: _photosFile,
                onTap: () async {
                  final file = await _pickFile();

                  if (file != null) {
                    setState(() {
                      _photosFile = file;
                    });
                  }
                },
              ),

              _buildFilePicker(
                title: 'Videos',
                file: _videosFile,
                onTap: () async {
                  final file = await _pickFile();

                  if (file != null) {
                    setState(() {
                      _videosFile = file;
                    });
                  }
                },
              ),

              // Remark
              _buildLabel('Remark'),

              TextFormField(
                controller: _remarkController,
                maxLines: 4,
                decoration: _inputDecoration(
                  'Enter remark',
                ),
              ),

              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(
                    Icons.upload_rounded,
                  ),
                  label: const Text(
                    'Upload Document',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
