import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:login2/models/lead_management/newProjectListModel.dart';
import '../../models/projectdetails/project_documents_models.dart';
import '../../models/projectdetails/staff_list_model.dart';
import '../../models/projectdetails/unit_list_model.dart';
import 'package:file_picker/file_picker.dart';
import '../../service/service.dart';
import 'add_project_document.dart';

class ProjectDocumentsPage extends StatefulWidget {
  final NewProjectItem project;

  const ProjectDocumentsPage({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDocumentsPage> createState() => _ProjectDocumentsPageState();
}

class _ProjectDocumentsPageState extends State<ProjectDocumentsPage> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  List<ProjectDocument> _documents = [];
  // ProjectDocumentsResponse? _response;
  String _projectNo = '';
  bool _isLoading = true;
  String? _errorMessage;

  List<ProjectDocumentUnit> _unitList = [];
  List<SiteLift> _siteLiftList = [];

  bool _isLoadingUnits = false;
  bool _isLoadingSiteLifts = false;

  @override
  void initState() {
    super.initState();
    _fetchProjectDocuments();
    _loadUnits();
    _loadSiteLifts();
  }

  Future<void> _fetchProjectDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await HttpService.getProjectDocuments(
        widget.project.id,
      );

      if (response != null && response.status) {
        setState(() {
          _documents = response.data.projectDocs;
          _projectNo = response.data.projectDetails.projectNo;
          _isLoading = false;
        });

        print('Documents count: ${_documents.length}');

        for (final document in _documents) {
          print('Title: ${document.title}');
          print('File: ${document.uploadFile}');
          print('URL: ${document.mediaUrl}');
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load project documents';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('getProjectDocuments error: $e');

      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUnits() async {
    setState(() {
      _isLoadingUnits = true;
    });

    try {
      final response = await HttpService.getProjectDocumentUnits(
        projectId: widget.project.id,
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

  Future<void> _loadSiteLifts() async {
    setState(() {
      _isLoadingSiteLifts = true;
    });

    try {
      final response = await HttpService.getSiteLifts(
        projectId: widget.project.id,
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

  //for upload file in edit
  Future<PlatformFile?> _pickReplacementFile() async {
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

      if (file.size > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size must not exceed 5 MB'),
          ),
        );
        return null;
      }

      return file;
    } catch (e) {
      print('Replacement file picker error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Header Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  _primary,
                  _primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.folder_special_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              widget.project.projectName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Section Header
  // ─────────────────────────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Project Documents',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
             
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProjectDocumentPage(
                    projectId: widget.project.id,
                    projectNo: _projectNo,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.add_circle_outline,
              color: _primary,
            ),
            tooltip: 'Add Document',
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Open Document
  // ─────────────────────────────────────────────────────────────
  Future<void> _viewDocument(ProjectDocument document) async {
    final url = Uri.parse(document.mediaUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Widget _buildDocumentList() {
    if (_documents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            'No documents found',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          final document = _documents[index];

          return _buildDocumentCard(document);
        },
      ),
    );
  }

  Widget _buildDocumentCard(ProjectDocument document) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  document.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {
                  _editDocument(document);
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  color: _primary,
                  size: 21,
                ),
              ),
              IconButton(
                onPressed: () {
                  _deleteDocument(document);
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _viewDocument(document);
              },
              icon: const Icon(
                Icons.image_outlined,
                size: 19,
              ),
              label: const Text('View Image'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: BorderSide(
                  color: _primary.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editDocument(ProjectDocument document) async {
    final titleController = TextEditingController(
      text: document.title,
    );

    final remarkController = TextEditingController(
      text: document.remark,
    );

    String? selectedUnitId;
    String? selectedSiteLiftId;
    PlatformFile? replacementFile;

    // ---------------------------------------------------------
    // 1. Make sure dropdown data is loaded
    // ---------------------------------------------------------
    if (_unitList.isEmpty || _siteLiftList.isEmpty) {
      await Future.wait([
        if (_unitList.isEmpty) _loadUnits(),
        if (_siteLiftList.isEmpty) _loadSiteLifts(),
      ]);
    }

    // ---------------------------------------------------------
    // 2. Find initial Unit value
    // ---------------------------------------------------------
    final documentUnitNo = document.unitNo.trim();

    for (final unit in _unitList) {
      // Match using unit number
      if (unit.unitNo.trim() == documentUnitNo) {
        selectedUnitId = unit.id;
        break;
      }

      // Also try matching document value with ID
      if (unit.id.trim() == documentUnitNo) {
        selectedUnitId = unit.id;
        break;
      }
    }

    // ---------------------------------------------------------
    // 3. Find initial Site Lift value
    // ---------------------------------------------------------
    final documentSiteLiftNo = document.siteLiftNo.trim();

    for (final siteLift in _siteLiftList) {
      // Match using site lift name
      if (siteLift.siteLiftName.trim() == documentSiteLiftNo) {
        selectedSiteLiftId = siteLift.id;
        break;
      }

      // Also try matching document value with ID
      if (siteLift.id.trim() == documentSiteLiftNo) {
        selectedSiteLiftId = siteLift.id;
        break;
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Edit Document',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Allowed Types
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
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

                      const SizedBox(height: 18),

                      // Unit No
                      const Text(
                        'Unit No.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 7),

                      DropdownButtonFormField<String>(
                        value: _unitList.any(
                          (unit) => unit.id == selectedUnitId,
                        )
                            ? selectedUnitId
                            : null,
                        decoration: InputDecoration(
                          hintText: _isLoadingUnits
                              ? 'Loading...'
                              : 'Select Unit No.',
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
                        ),
                        icon: _isLoadingUnits
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
                        items: _unitList.map((unit) {
                          return DropdownMenuItem<String>(
                            value: unit.id,
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
                                  selectedUnitId = value;
                                });
                              },
                      ),

                      const SizedBox(height: 16),

                      // Site Lift No
                      const Text(
                        'Site Lift No.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 7),

                      DropdownButtonFormField<String>(
                        value: _unitList.any(
                          (unit) => unit.id == selectedUnitId,
                        )
                            ? selectedUnitId
                            : null,
                        decoration: InputDecoration(
                          hintText: _isLoadingUnits
                              ? 'Loading...'
                              : 'Select Unit No.',
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
                        ),
                        icon: _isLoadingUnits
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
                        items: _unitList.map((unit) {
                          return DropdownMenuItem<String>(
                            value: unit.id,
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
                                  selectedUnitId = value;
                                });
                              },
                      ),

                      const SizedBox(height: 16),

                      // Project No
                      const Text(
                        'Project No.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 7),

                      TextFormField(
                        initialValue: _projectNo,
                        readOnly: true,
                        decoration: InputDecoration(
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
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Title
                      const Text(
                        'Title',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 7),

                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter document title',
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
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Replace File
                      const Text(
                        'Replace File',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 7),

                      InkWell(
                        onTap: () async {
                          final file = await _pickReplacementFile();

                          if (file != null) {
                            setDialogState(() {
                              replacementFile = file;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
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
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: _primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: const Icon(
                                  Icons.upload_file_rounded,
                                  color: _primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  replacementFile?.name ??
                                      (document.uploadFile.isNotEmpty
                                          ? document.uploadFile
                                          : 'Choose File'),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: replacementFile == null
                                        ? Colors.grey.shade700
                                        : Colors.black87,
                                    fontWeight: replacementFile == null
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                  ),
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

                      // Remark
                      const Text(
                        'Remark',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 7),

                      TextFormField(
                        controller: remarkController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Enter remark',
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (selectedUnitId == null ||
                        selectedUnitId!.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select Unit No.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    if (selectedSiteLiftId == null ||
                        selectedSiteLiftId!.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select Site Lift No.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    if (_projectNo.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Project No. is required.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter document title.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    final success = await HttpService.updateProjectDocument(
                      documentId: document.id,
                      projectId: document.projectId,
                      projectNo: _projectNo.trim(),
                      unitNo: selectedUnitId!.trim(),
                      siteLiftNo: selectedSiteLiftId!.trim(),
                      title: titleController.text.trim(),
                      remark: remarkController.text.trim(),
                      file: replacementFile,
                    );

                    if (success) {
                      Navigator.pop(dialogContext);

                      await _fetchProjectDocuments();

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Document updated successfully',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to update document',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.save_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Update Document',
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
              ],
            );
          },
        );
      },
    );
  }

  //delete functionality
  Future<void> _deleteDocument(ProjectDocument document) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: Text(
            'Are you sure you want to delete "${document.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
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

    final success = await HttpService.deleteProjectDocument(
      documentId: document.id,
      projectId: widget.project.id,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh the document list
      _fetchProjectDocuments();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete document'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),

      // ─────────────────────────────────────────────
      // Main Header
      // ─────────────────────────────────────────────
      appBar: AppBar(
        title: const Text(
          'Project Documents',
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

      // ─────────────────────────────────────────────
      // Body
      // ─────────────────────────────────────────────
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: _primary,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchProjectDocuments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchProjectDocuments,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main project header
                        _buildHeaderCard(),

                        // Section title
                        _buildSectionHeader(),

                        // API document listing
                        _buildDocumentList(),
                      ],
                    ),
                  ),
                ),
    );
  }
}
