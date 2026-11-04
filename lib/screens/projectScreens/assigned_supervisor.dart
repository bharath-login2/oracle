import 'dart:developer';
import 'package:flutter/material.dart';

// Replace these model/service imports with your actual project file paths
import '../../core/common.dart';
import '../../models/projectdetails/assigned_supervisor/assigned_supervidor_model.dart';
import '../../models/projectdetails/unit_list_model.dart';
import '../../models/projectdetails/staff_list_model.dart';
import '../../models/userManagement/viewStaffModel.dart';
import '../../service/service.dart';

class AssignedStaffScreen extends StatefulWidget {
  final String projectId;
  final String projectNo;
  final String clientId;

  const AssignedStaffScreen({
    super.key,
    required this.projectId,
    required this.projectNo,
    required this.clientId,
  });

  @override
  State<AssignedStaffScreen> createState() => _AssignedStaffScreenState();
}

class _AssignedStaffScreenState extends State<AssignedStaffScreen> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  bool _isLoading = false;
  List<AssignedStaff> _staffList = [];

  @override
  void initState() {
    super.initState();
    _loadAssignedStaff();
  }

  Future<void> _loadAssignedStaff() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await HttpService.getAssignedStaff(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        setState(() {
          _staffList = response.data;
        });
      } else {
        setState(() {
          _staffList = [];
        });
      }
    } catch (e) {
      log('Load assigned staff error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ASSIGN + button action
  void _openAssignDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _AssignStaffDialog(
          projectId: widget.projectId,
          clientId: widget.clientId,
          onSuccess: () {
            _loadAssignedStaff();
          },
        );
      },
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
                Icons.groups_rounded,
                size: 42,
                color: _primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No assigned staff found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No staff have been assigned to this project yet.',
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

  // PROFILE PIC (network image with icon fallback)
  Widget _buildProfilePic(AssignedStaff item) {
    const double size = 54;

    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 28,
        color: _primary,
      ),
    );

    if (item.proPic.trim().isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        item.proPic,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: size,
            height: size,
            color: _primary.withOpacity(0.08),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _primary,
              ),
            ),
          );
        },
      ),
    );
  }

  // STAFF CARD UI
  Widget _buildStaffCard(AssignedStaff item) {
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
      child: Row(
        children: [
          _buildProfilePic(item),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.staffName.isEmpty ? '-' : item.staffName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.badge_rounded,
                        size: 14,
                        color: _primary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          item.designation.isEmpty ? '-' : item.designation,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        title: const Text(
          'Assigned staff',
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
            child: Center(
              child: InkWell(
                onTap: _openAssignDialog,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  child: const Text(
                    'Assign +',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : RefreshIndicator(
              color: _primary,
              onRefresh: _loadAssignedStaff,
              child: _staffList.isEmpty
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
                      itemCount: _staffList.length,
                      itemBuilder: (context, index) {
                        return _buildStaffCard(_staffList[index]);
                      },
                    ),
            ),
    );
  }
}

// ASSIGN STAFF DIALOG

class _AssignStaffDialog extends StatefulWidget {
  final String projectId;
  final String clientId;
  final VoidCallback onSuccess;

  const _AssignStaffDialog({
    required this.projectId,
    required this.clientId,
    required this.onSuccess,
  });

  @override
  State<_AssignStaffDialog> createState() => _AssignStaffDialogState();
}

class _AssignStaffDialogState extends State<_AssignStaffDialog> {
  static const Color _primary = Color(0xFF00BFA5);

  final _formKey = GlobalKey<FormState>();

  ProjectDocumentUnit? _selectedUnit;
  SiteLift? _selectedSiteLift;
  StaffList? _selectedStaff;

  bool _isLoadingUnits = false;
  bool _isLoadingSiteLifts = false;
  bool _isLoadingStaff = false;
  bool _isSubmitting = false;

  List<ProjectDocumentUnit> _unitList = [];
  List<SiteLift> _siteLiftList = [];
  List<StaffList> _staffList = [];

  @override
  void initState() {
    super.initState();
    _loadUnits();
    _loadSiteLifts();
    _loadStaff();
  }

  // LOAD UNITS API
  Future<void> _loadUnits() async {
    setState(() => _isLoadingUnits = true);
    try {
      final response = await HttpService.getProjectDocumentUnits(
        projectId: widget.projectId,
      );
      if (!mounted) return;
      if (response != null && response.status) {
        setState(() => _unitList = response.data);
      }
    } catch (e) {
      log('Unit API error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingUnits = false);
    }
  }

  // LOAD SITE LIFTS API
  Future<void> _loadSiteLifts() async {
    setState(() => _isLoadingSiteLifts = true);
    try {
      final response = await HttpService.getSiteLifts(
        projectId: widget.projectId,
      );
      if (!mounted) return;
      if (response != null && response.status) {
        setState(() => _siteLiftList = response.data);
      }
    } catch (e) {
      log('Site Lift API error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingSiteLifts = false);
    }
  }

  // LOAD STAFF (same API as the View Staff page)
  Future<void> _loadStaff() async {
    setState(() => _isLoadingStaff = true);
    try {
      final token = await Common.getSharedPref("token");
      final response = await HttpService.viewStaffs(token);
      if (!mounted) return;
      if (response != null) {
        setState(() => _staffList = response.data.staffList);
      }
    } catch (e) {
      log('Staff API error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingStaff = false);
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
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
        borderSide: const BorderSide(color: _primary, width: 1.5),
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
      isExpanded: true,
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
          child: Text(getLabel(item), overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: isLoading ? null : onChanged,
      validator: (val) => val == null ? 'This field is required' : null,
    );
  }

  // STAFF DROPDOWN: shows name + designation, passes staff id
  Widget _buildStaffDropdown() {
    return DropdownButtonFormField<StaffList>(
      value: _selectedStaff,
      isExpanded: true,
      decoration:
          _inputDecoration(_isLoadingStaff ? 'Loading...' : 'Select Staff'),
      icon: _isLoadingStaff
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.keyboard_arrow_down_rounded),
      // Selected value (single line when closed)
      selectedItemBuilder: (context) {
        return _staffList.map((s) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${s.name} (${s.designation})',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
      // Menu items: name + designation
      items: _staffList.map((s) {
        return DropdownMenuItem<StaffList>(
          value: s,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.name.toString(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                s.designation.toString(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: _isLoadingStaff
          ? null
          : (value) => setState(() => _selectedStaff = value),
      validator: (val) => val == null ? 'This field is required' : null,
    );
  }

  // SUBMIT
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final success = await HttpService.assignProjectStaff(
        projectId: widget.projectId,
        staffId: _selectedStaff!.staffId.toString(),
        clientId: widget.clientId,
        unitNo: _selectedUnit!.id.toString(),
        siteLiftNo: _selectedSiteLift!.id.toString(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Staff assigned successfully'
                : 'Failed to assign staff',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (success) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      log('Assign staff error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to assign staff: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                      const Text(
                        'Assign Supervisor',
                        style: TextStyle(
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

                  // 1. UNIT NO
                  _buildLabel('Unit No.', required: true),
                  _buildDropdown<ProjectDocumentUnit>(
                    value: _selectedUnit,
                    hint: 'Select a Unit',
                    items: _unitList,
                    getLabel: (unit) => unit.unitNo,
                    onChanged: (v) => setState(() => _selectedUnit = v),
                    isLoading: _isLoadingUnits,
                  ),
                  const SizedBox(height: 16),

                  // 2. SITE LIFT NO
                  _buildLabel('Site Lift No.', required: true),
                  _buildDropdown<SiteLift>(
                    value: _selectedSiteLift,
                    hint: 'Select Site Lift No.',
                    items: _siteLiftList,
                    getLabel: (lift) => lift.siteLiftName,
                    onChanged: (v) => setState(() => _selectedSiteLift = v),
                    isLoading: _isLoadingSiteLifts,
                  ),
                  const SizedBox(height: 16),

                  // 3. SELECT STAFF
                  _buildLabel('Select Staff', required: true),
                  _buildStaffDropdown(),
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
                            : const Text(
                                'Submit',
                                style: TextStyle(fontWeight: FontWeight.bold),
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