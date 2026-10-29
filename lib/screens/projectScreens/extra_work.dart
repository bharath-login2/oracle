import 'dart:developer';
import 'package:flutter/material.dart';

// Replace these model/service imports with your actual project file paths
import '../../models/projectdetails/staff_list_model.dart';
import '../../models/projectdetails/unit_list_model.dart';
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
  List<dynamic> _extraWorkList =
      []; // Replace with your model list type if available

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
      // TODO: Replace with your actual HttpService call to fetch extra work records
      // final response = await HttpService.getExtraWork(projectId: widget.projectId);
      await Future.delayed(
          const Duration(milliseconds: 800)); // Mock network delay

      if (!mounted) return;

      setState(() {
        _extraWorkList = []; // Set data here from response
        _isLoading = false;
      });
    } catch (e) {
      log('Load extra work error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openAddExtraWorkDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _AddExtraWorkDialog(
          projectId: widget.projectId,
          projectNo: widget.projectNo,
          clientId: widget.clientId,
          onSuccess: () {
            _loadExtraWork();
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
              onPressed: _openAddExtraWorkDialog,
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
                        // Build your extra work card item here
                        return const SizedBox.shrink();
                      },
                    ),
            ),
    );
  }
}

// ADD EXTRA WORK DIALOG

class _AddExtraWorkDialog extends StatefulWidget {
  final String projectId;
  final String projectNo;
  final String clientId;
  final VoidCallback onSuccess;

  const _AddExtraWorkDialog({
    required this.projectId,
    required this.projectNo,
    required this.clientId,
    required this.onSuccess,
  });

  @override
  State<_AddExtraWorkDialog> createState() => _AddExtraWorkDialogState();
}

class _AddExtraWorkDialogState extends State<_AddExtraWorkDialog> {
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

  @override
  void initState() {
    super.initState();
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

  // SUBMIT FORM
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String unitId = _selectedUnit?.id ?? '';
      final String siteLiftId = _selectedSiteLift?.id ?? '';
      final String amount = _amountController.text.trim();
      final String workName = _workNameController.text.trim();
      final String description = _descriptionController.text.trim();

      log('Unit: $unitId, Lift: $siteLiftId, Amt: $amount, Work: $workName, Desc: $description');

      // TODO: Replace with your actual HttpService call for adding extra work
      await Future.delayed(const Duration(seconds: 1));
      bool success = true;

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Extra work added successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      log('Add extra work error: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add extra work: $e'),
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
                      const Text(
                        'Add Extra Work',
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

                  // 1. UNIT NO DROPDOWN
                  _buildLabel('Unit No.', required: true),
                  _buildDropdown<ProjectDocumentUnit>(
                    value: _selectedUnit,
                    hint: 'Select a Unit',
                    items: _unitList,
                   // getLabel: (unit) => unit.unitNo ?? 'Unit #${unit.id}',
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
                     // getLabel: (lift) => lift.siteLiftName ?? 'Lift #${lift.id}',
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
