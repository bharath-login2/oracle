import 'dart:developer';
import 'package:flutter/material.dart';
import '../../models/projectdetails/staff_list_model.dart';
import '../../models/projectdetails/unit_list_model.dart';
import '../../models/projectdetails/extra_work/extra_work_model.dart';
import '../../service/service.dart';

class ExtraWorkScreen extends StatefulWidget {
  final String projectId;
  final String projectNo;
  final String clientId;

  const ExtraWorkScreen({
    super.key,
    required this.projectId,
    required this.projectNo,
    required this.clientId,
  });

  @override
  State<ExtraWorkScreen> createState() => _ExtraWorkScreenState();
}

class _ExtraWorkScreenState extends State<ExtraWorkScreen> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  bool _isLoading = false;
  List<ExtraWorkRecord> _extraWorkList = [];
  String _totalAmount = '0.00';

  @override
  void initState() {
    super.initState();
    _loadExtraWork();
  }

  Future<void> _loadExtraWork() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await HttpService.getExtraWork(
        projectId: widget.projectId,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        setState(() {
          _extraWorkList = response.data?.records ?? [];
          _totalAmount = response.data?.totalAmount ?? '0.00';
        });
      } else {
        setState(() {
          _extraWorkList = [];
          _totalAmount = '0.00';
        });
      }
    } catch (e) {
      log('Load extra work error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ADD (item == null) / EDIT (item != null) DIALOG
  void _openExtraWorkDialog({ExtraWorkRecord? item}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _ExtraWorkDialog(
          projectId: widget.projectId,
          projectNo: widget.projectNo,
          clientId: widget.clientId,
          existing: item,
          onSuccess: () {
            _loadExtraWork();
          },
        );
      },
    );
  }

  // DELETE
  Future<void> _confirmDelete(ExtraWorkRecord item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text('Delete Extra Work'),
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
      success = await HttpService.deleteExtraWork(
        projectId: widget.projectId,
        workId: item.id.toString(), // work_id
      );
    } catch (e) {
      log('Delete extra work error: $e');
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Extra work deleted successfully'
              : 'Failed to delete extra work',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (success) {
      await _loadExtraWork();
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
                Icons.work_outline_rounded,
                size: 42,
                color: _primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No extra work found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No extra work records are available for this project.',
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

  // EXTRA WORK CARD UI

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

  String _formatDate(ExtraWorkRecord item) {
    final d = item.createdAtDate;
    if (d == null) return item.createdAt;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd-$mm-${d.year}';
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

  Widget _buildExtraWorkCard(ExtraWorkRecord item) {
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
          // HEADER: logo + small status indicator + work name + actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                onTap: () => _openExtraWorkDialog(item: item),
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

          // ROW 2: Amount + Date
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Amount',
                  value: '₹ ${item.amount}',
                  iconColor: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: _formatDate(item),
                  iconColor: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Staff
          _buildDetailItem(
            icon: Icons.person_rounded,
            label: 'Created by',
            value: item.staffName,
            iconColor: Colors.purple,
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
          'Extra work',
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
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => _openExtraWorkDialog(),
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
              onRefresh: _loadExtraWork,
              child: _extraWorkList.isEmpty
                  ? ListView(
                      // Allows pull-to-refresh even when list is empty
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
                      itemCount: _extraWorkList.length,
                      itemBuilder: (context, index) {
                        return _buildExtraWorkCard(_extraWorkList[index]);
                      },
                    ),
            ),
      bottomNavigationBar: _buildTotalBottomBar(),
    );
  }
}

// ADD / EDIT EXTRA WORK DIALOG

class _ExtraWorkDialog extends StatefulWidget {
  final String projectId;
  final String projectNo;
  final String clientId;
  final ExtraWorkRecord? existing; // null = add, not null = edit
  final VoidCallback onSuccess;

  const _ExtraWorkDialog({
    required this.projectId,
    required this.projectNo,
    required this.clientId,
    required this.onSuccess,
    this.existing,
  });

  @override
  State<_ExtraWorkDialog> createState() => _ExtraWorkDialogState();
}

class _ExtraWorkDialogState extends State<_ExtraWorkDialog> {
  static const Color _primary = Color(0xFF00BFA5);

  final _formKey = GlobalKey<FormState>();

  ProjectDocumentUnit? _selectedUnit;
  SiteLift? _selectedSiteLift;

  bool _isLoadingUnits = false;
  bool _isLoadingSiteLifts = false;
  bool _isSubmitting = false;

  List<ProjectDocumentUnit> _unitList = [];
  List<SiteLift> _siteLiftList = [];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _workNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();

    // Pre-fill fields when editing
    final e = widget.existing;
    if (e != null) {
      _amountController.text = e.amount.toString();
      _workNameController.text = e.workName;
      _descriptionController.text = e.description;
    }

    _loadUnits();
    _loadSiteLifts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _workNameController.dispose();
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

          // Pre-select unit when editing (matches by id or unit no)
          final e = widget.existing;
          if (e != null) {
            for (final u in _unitList) {
              if (u.id.toString() == e.unitNo.toString() ||
                  u.unitNo.toString() == e.unitNo.toString()) {
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
                  l.siteLiftName.toString() == e.siteLiftNo.toString()) {
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
      final String amount = _amountController.text.trim();
      final String workName = _workNameController.text.trim();
      final String description = _descriptionController.text.trim();

      bool success;

      if (_isEdit) {
        success = await HttpService.editExtraWork(
          projectId: widget.projectId,
          extraWorkId: widget.existing!.id.toString(),
          unitNo: unitId,
          siteLiftNo: siteLiftId,
          workName: workName,
          amount: amount,
          description: description,
        );
      } else {
        success = await HttpService.addExtraWork(
          projectId: widget.projectId,
          unitNo: unitId,
          siteLiftNo: siteLiftId,
          workName: workName,
          amount: amount,
          description: description,
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
                  ? 'Extra work updated successfully'
                  : 'Extra work added successfully',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdit
                  ? 'Failed to update extra work'
                  : 'Failed to add extra work',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      log('Save extra work error: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save extra work: $e'),
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
                        _isEdit ? 'Edit Extra Work' : 'Add Extra Work',
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

                  // 3. AMOUNT FIELD WITH RUPEE ICON
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

                  // 4. WORK NAME FIELD
                  _buildLabel('Work Name', required: true),
                  TextFormField(
                    controller: _workNameController,
                    decoration: _inputDecoration('Enter Work Name'),
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
