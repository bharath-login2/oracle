import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/projectdetails/staff_list_model.dart';
import '../../models/projectdetails/unit_list_model.dart';
import '../../models/projectdetails/deduction_work/deduction_work_model.dart';
import '../../service/service.dart';

class DeductionWorkScreen extends StatefulWidget {
  final String projectId;
  final String projectNo;
  final String clientId;

  const DeductionWorkScreen({
    super.key,
    required this.projectId,
    required this.projectNo,
    required this.clientId,
  });

  @override
  State<DeductionWorkScreen> createState() => _DeductionWorkScreenState();
}

class _DeductionWorkScreenState extends State<DeductionWorkScreen> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  bool _isLoading = false;
  List<DeductionWorkRecord> _deductionList = [];
  String _totalAmount = '0.00';

  @override
  void initState() {
    super.initState();
    _loadDeductionWork();
  }

  Future<void> _loadDeductionWork() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await HttpService.getDeductionWork(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        setState(() {
          _deductionList = response.data?.records ?? [];
          _totalAmount = response.data?.totalAmount ?? '0.00';
        });
      } else {
        setState(() {
          _deductionList = [];
          _totalAmount = '0.00';
        });
      }
    } catch (e) {
      log('Load deduction work error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ADD (item == null) / EDIT (item != null) DIALOG
  void _openDeductionDialog({DeductionWorkRecord? item}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _DeductionDialog(
          projectId: widget.projectId,
          projectNo: widget.projectNo,
          clientId: widget.clientId,
          existing: item,
          onSuccess: () {
            _loadDeductionWork();
          },
        );
      },
    );
  }

  // DELETE
  Future<void> _confirmDelete(DeductionWorkRecord item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text('Delete Deduction Work'),
        content: Text('Are you sure you want to delete "${item.workName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    bool success = false;
    try {
      success = await HttpService.deleteDeductionWork(
        projectId: widget.projectId,
        deductionWorkId: item.id.toString(), // deduction_work_id
      );
    } catch (e) {
      log('Delete deduction work error: $e');
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Deduction work deleted successfully'
              : 'Failed to delete deduction work',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (success) {
      await _loadDeductionWork();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
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
                Icons.trending_down,
                size: 42,
                color: _primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No deduction work found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No deduction work records are available for this project.',
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

  // DEDUCTION WORK CARD UI

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return Colors.orange;
      case 'completed':
      case 'complete':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // The API returns a Google Drive file id (or sometimes a full url).
  // Build a viewable link from it.
  String _fileUrl(String file) {
    final value = file.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return 'https://drive.google.com/file/d/$value/view';
  }

  Future<void> _openFile(String file) async {
    final url = _fileUrl(file);
    if (url.isEmpty) return;

    try {
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the file'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      log('Open file error: $e');
    }
  }

  // One detail item: logo + name (label) + value
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = _primary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                  fontSize: 13.5,
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

  // EDIT + DELETE ICON BUTTONS
  Widget _buildHeaderIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildDeductionCard(DeductionWorkRecord item) {
    final statusColor = _statusColor(item.workStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: logo + work name + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo (old style) + small status colour dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.construction_rounded,
                      size: 20,
                      color: _primary,
                    ),
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Work Name',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.workName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildHeaderIconButton(
                icon: Icons.edit_rounded,
                color: _primary,
                onTap: () => _openDeductionDialog(item: item),
              ),
              const SizedBox(width: 8),
              _buildHeaderIconButton(
                icon: Icons.delete_rounded,
                color: Colors.red,
                onTap: () => _confirmDelete(item),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // ROW 2: Unit Name + Site Lift Name
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.badge_rounded,
                  label: 'Unit No',
                  value: item.unitName,
                  iconColor: Colors.purple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.label_rounded,
                  label: 'Site Lift No',
                  value: item.siteLiftName,
                  iconColor: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ROW 3: Amount + File
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Amount',
                  value: '₹ ${item.amount}',
                  iconColor: Colors.red,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: item.file.trim().isEmpty
                    ? _buildDetailItem(
                        icon: Icons.attach_file_rounded,
                        label: 'File',
                        value: 'No file',
                        iconColor: Colors.grey,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const Text(
                          //   'File',
                          //   style: TextStyle(
                          //     fontSize: 11,
                          //     color: Colors.grey,
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                          const SizedBox(height: 4),
                          Material(
                            color: Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () => _openFile(item.file),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 36,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.visibility_rounded,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'View File',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.open_in_new_rounded,
                                      size: 14,
                                      color: Colors.orange,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),

          // Description
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailItem(
              icon: Icons.notes_rounded,
              label: 'Description',
              value: item.description,
              iconColor: Colors.blueGrey,
            ),
          ],
        ],
      ),
    );
  }

  // FIXED BOTTOM TOTAL BAR
  Widget _buildTotalBottomBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '₹ $_totalAmount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        title: const Text(
          'Deduction work',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        backgroundColor: _primary,
        elevation: 0,
        // Back button
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // Add button
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => _openDeductionDialog(),
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
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : RefreshIndicator(
              color: _primary,
              onRefresh: _loadDeductionWork,
              child: _deductionList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: _buildEmptyState(),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: _deductionList.length,
                      itemBuilder: (context, index) {
                        return _buildDeductionCard(_deductionList[index]);
                      },
                    ),
            ),
      bottomNavigationBar: _buildTotalBottomBar(),
    );
  }
}

// ADD / EDIT DEDUCTION WORK DIALOG

class _DeductionDialog extends StatefulWidget {
  final String projectId;
  final String projectNo;
  final String clientId;
  final DeductionWorkRecord? existing; // null = add, not null = edit
  final VoidCallback onSuccess;

  const _DeductionDialog({
    required this.projectId,
    required this.projectNo,
    required this.clientId,
    required this.onSuccess,
    this.existing,
  });

  @override
  State<_DeductionDialog> createState() => _DeductionDialogState();
}

class _DeductionDialogState extends State<_DeductionDialog> {
  static const Color _primary =
      Color(0xFF00BFA5); // Teal theme matching dialog screenshot

  final _formKey = GlobalKey<FormState>();

  ProjectDocumentUnit? _selectedUnit;
  SiteLift? _selectedSiteLift;

  bool _isLoadingUnits = false;
  bool _isLoadingSiteLifts = false;
  bool _isSubmitting = false;

  List<ProjectDocumentUnit> _unitList = [];
  List<SiteLift> _siteLiftList = [];

  final TextEditingController _workController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  PlatformFile? _selectedFile;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();

    // Pre-fill fields when editing
    final e = widget.existing;
    if (e != null) {
      _workController.text = e.workName;
      _amountController.text = e.amount.toString();
      _descriptionController.text = e.description;
    }

    _loadUnits();
    _loadSiteLifts();
  }

  @override
  void dispose() {
    _workController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // LOAD UNITS API
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

          // Pre-select unit when editing (matches by id or name)
          final e = widget.existing;
          if (e != null) {
            for (final u in _unitList) {
              if (u.id.toString() == e.unitNo.toString() ||
                  u.unitNo.toString() == e.unitName.toString()) {
                _selectedUnit = u;
                break;
              }
            }
          }
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

  // LOAD SITE LIFTS API
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

          // Pre-select site lift when editing (matches by id or name)
          final e = widget.existing;
          if (e != null) {
            for (final l in _siteLiftList) {
              if (l.id.toString() == e.siteLiftNo.toString() ||
                  l.siteLiftName.toString() == e.siteLiftName.toString()) {
                _selectedSiteLift = l;
                break;
              }
            }
          }
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

  // FILE PICKER
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      log('File picker error: $e');
    }
  }

  InputDecoration _inputDecoration(String hint, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon: prefixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: _primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildLabel(String labelText, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
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
      decoration: _inputDecoration(isLoading ? 'Loading...' : hint),
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.keyboard_arrow_down_rounded),
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
      validator: (val) => val == null ? 'This field is required' : null,
    );
  }

  // File name text shown in the picker box
  String get _fileLabel {
    if (_selectedFile != null) return _selectedFile!.name;
    final existingFile = widget.existing?.file ?? '';
    if (existingFile.isNotEmpty) return 'Existing file attached';
    return 'No file chosen';
  }

  bool get _hasAnyFile =>
      _selectedFile != null || (widget.existing?.file ?? '').isNotEmpty;

  // SUBMIT FORM (ADD or EDIT)
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // IDs from the dropdowns
      final String unitId = _selectedUnit?.id.toString() ?? '';
      final String siteLiftId = _selectedSiteLift?.id.toString() ?? '';
      final String work = _workController.text.trim();
      final String amount = _amountController.text.trim();
      final String description = _descriptionController.text.trim();

      bool success;

      if (_isEdit) {
        success = await HttpService.editDeductionWork(
          projectId: widget.projectId,
          workId: widget.existing!.id.toString(),
          unitNo: unitId,
          siteLiftNo: siteLiftId,
          workName: work,
          amount: amount,
          description: description,
          file: _selectedFile, // optional
        );
      } else {
        success = await HttpService.addDeductionWork(
          projectId: widget.projectId,
          unitNo: unitId,
          siteLiftNo: siteLiftId,
          workName: work,
          amount: amount,
          description: description,
          file: _selectedFile, // optional
        );
      }

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdit
                  ? 'Deduction work updated successfully'
                  : 'Deduction work added successfully',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdit
                  ? 'Failed to update deduction work'
                  : 'Failed to add deduction work',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      log('Save deduction work error: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save deduction work: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEdit ? 'Edit Deduction Work' : 'Add Deduction Work',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 1. UNIT NO DROPDOWN
                  _buildLabel('Unit No.', required: true),
                  _buildDropdown<ProjectDocumentUnit>(
                    value: _selectedUnit,
                    hint: 'Select a Unit',
                    items: _unitList,
                    getLabel: (unit) => unit.unitNo,
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value;
                      });
                    },
                    isLoading: _isLoadingUnits,
                  ),
                  const SizedBox(height: 16),

                  // 2. SITE LIFT NO DROPDOWN
                  _buildLabel('Site Lift No.', required: true),
                  _buildDropdown<SiteLift>(
                    value: _selectedSiteLift,
                    hint: 'Select Site Lift No.',
                    items: _siteLiftList,
                    getLabel: (lift) => lift.siteLiftName,
                    onChanged: (value) {
                      setState(() {
                        _selectedSiteLift = value;
                      });
                    },
                    isLoading: _isLoadingSiteLifts,
                  ),
                  const SizedBox(height: 16),

                  // 3. WORK FIELD
                  _buildLabel('Work', required: true),
                  TextFormField(
                    controller: _workController,
                    decoration: _inputDecoration('Enter Work Name'),
                    validator: (val) => val == null || val.isEmpty
                        ? 'This field is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // 4. AMOUNT FIELD
                  _buildLabel('Amount', required: true),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      'Enter Amount',
                      prefixIcon: const Icon(Icons.currency_rupee,
                          size: 16, color: Colors.grey),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'This field is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // 5. DESCRIPTION FIELD
                  _buildLabel('Description'),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _inputDecoration('Enter Description'),
                  ),
                  const SizedBox(height: 16),

                  // 6. CHOOSE FILE PICKER UI (optional: image or PDF)
                  _buildLabel('Choose File'),
                  InkWell(
                    onTap: _pickFile,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Choose File',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _fileLabel,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    _hasAnyFile ? Colors.black87 : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed:
                            _isSubmitting ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEdit ? 'Update' : 'Submit',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
