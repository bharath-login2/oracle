import 'package:flutter/material.dart';
import '../../models/projectdetails/unit_info_model.dart';

class AddUnitInfoPage extends StatefulWidget {
  final String projectId;
  final UnitInfoData? unit;

  const AddUnitInfoPage({
    super.key,
    required this.projectId,
    this.unit,
  });

  bool get isEditMode => unit != null;

  @override
  State<AddUnitInfoPage> createState() => _AddUnitInfoPageState();
}

class _AddUnitInfoPageState extends State<AddUnitInfoPage> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  final _formKey = GlobalKey<FormState>();

  // ------------------------------------------------------------
  // Controllers
  // ------------------------------------------------------------

  final TextEditingController _siteLiftController = TextEditingController();

  final TextEditingController _unitMachineController = TextEditingController();

  final TextEditingController _capacityController = TextEditingController();

  final TextEditingController _travelHeightController = TextEditingController();

  final TextEditingController _doorSizeController = TextEditingController();

  final TextEditingController _productModelController = TextEditingController();

  // ------------------------------------------------------------
  // Dropdown values
  // ------------------------------------------------------------

  String? _selectedLiftSpeed;
  String? _selectedStops;
  String? _selectedOpenings;
  String? _selectedDoorType;
  String? _selectedDoorModel;
  String? _selectedMachineRoomType;
  String? _selectedStandardType;
  String? _selectedStatus;
  String? _selectedInstallationMethod;

  // ------------------------------------------------------------
  // Dates
  // ------------------------------------------------------------

  DateTime? _startDate;
  DateTime? _plannedFinish;
  DateTime? _actualFinish;

  // ------------------------------------------------------------
  // Dropdown lists
  // ------------------------------------------------------------

  final List<String> _liftSpeeds = [
    '1 M/S',
    '1.5 M/S',
  ];

  final List<String> _stops = List.generate(
    10,
    (index) => 'No of Stops ${index + 1}',
  );

  final List<String> _openings = List.generate(
    10,
    (index) => 'No of Openings ${index + 1}',
  );

  final List<String> _doorTypes = [
    'Center Opening',
    'Side Opening',
    'Manual Opening',
  ];

  final List<String> _doorModels = [
    'Painted',
    'Not Painted',
    'Stainless Steel',
  ];

  final List<String> _machineRoomTypes = [
    'MRL',
    'URL',
    'CRL',
  ];

  final List<String> _standardTypes = [
    'Standard',
    'Non Standard',
  ];

  final List<String> _statuses = [
    'Pending',
    'In progress',
  ];

  final List<String> _installationMethods = [
    'Scaffolding',
    'Fit Method',
    'False Car',
    'Rope Climbing',
    'Platform',
  ];

  // ------------------------------------------------------------
  // Init
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    if (widget.isEditMode) {
      _loadExistingUnit();
    }
  }

  void _loadExistingUnit() {
    final unit = widget.unit!;

    // Fixed fields
    _siteLiftController.text = unit.siteLiftNo;
    _unitMachineController.text = unit.unitMachineNo;

    // Editable text fields
    _capacityController.text = unit.capacity;
    _travelHeightController.text = unit.travelHeight;
    _doorSizeController.text = unit.doorSize;
    _productModelController.text = unit.productModelName;

    // Dropdowns
    _selectedLiftSpeed = _convertLiftSpeed(unit.speed);

    _selectedStops = _convertStops(unit.numberOfStops);

    _selectedOpenings = _convertOpenings(unit.numberOfOpening);

    _selectedDoorType = _convertDoorType(unit.doorTypeId);

    _selectedDoorModel = _convertDoorModel(unit.doorModelId);

    _selectedMachineRoomType = _convertMachineRoomType(unit.machineRoomTypeId);

    _selectedStandardType = _convertStandardType(unit.standardType);

    _selectedStatus = _convertStatus(unit.status);

    // Fixed in edit mode
    _selectedInstallationMethod = unit.methodName;

    // Dates
    _startDate = _parseDate(unit.startDate);
    _plannedFinish = _parseDate(unit.endDate);
    _actualFinish = _parseDate(unit.actualFinish);
  }

  // ------------------------------------------------------------
  // Convert API values to dropdown values
  // ------------------------------------------------------------

  String? _convertLiftSpeed(String value) {
    if (value.isEmpty) return null;

    if (value == '1') {
      return '1 M/S';
    }

    if (value == '1.5') {
      return '1.5 M/S';
    }

    if (_liftSpeeds.contains(value)) {
      return value;
    }

    return null;
  }

  String? _convertStops(String value) {
    if (value.isEmpty) return null;

    final number = int.tryParse(value);

    if (number != null && number >= 1 && number <= 10) {
      return 'No of Stops $number';
    }

    if (_stops.contains(value)) {
      return value;
    }

    return null;
  }

  String? _convertOpenings(String value) {
    if (value.isEmpty) return null;

    final number = int.tryParse(value);

    if (number != null && number >= 1 && number <= 10) {
      return 'No of Openings $number';
    }

    if (_openings.contains(value)) {
      return value;
    }

    return null;
  }

  String? _convertDoorType(String value) {
    switch (value) {
      case '1':
        return 'Center Opening';
      case '2':
        return 'Side Opening';
      case '3':
        return 'Manual Opening';
    }

    if (_doorTypes.contains(value)) {
      return value;
    }

    return null;
  }

  String? _convertDoorModel(String value) {
    switch (value) {
      case '1':
        return 'Painted';
      case '2':
        return 'Not Painted';
      case '3':
        return 'Stainless Steel';
    }

    if (_doorModels.contains(value)) {
      return value;
    }

    return null;
  }

  String? _convertMachineRoomType(String value) {
    switch (value) {
      case '1':
        return 'MRL';
      case '2':
        return 'URL';
      case '3':
        return 'CRL';
    }

    if (_machineRoomTypes.contains(value)) {
      return value;
    }

    return null;
  }

  String? _convertStandardType(String value) {
    if (value.toLowerCase() == 'standard') {
      return 'Standard';
    }

    if (value.toLowerCase() == 'non_standard' ||
        value.toLowerCase() == 'non standard') {
      return 'Non Standard';
    }

    return null;
  }

  String? _convertStatus(String value) {
    if (value.toLowerCase() == 'pending') {
      return 'Pending';
    }

    if (value.toLowerCase() == 'in progress' ||
        value.toLowerCase() == 'in_progress') {
      return 'In progress';
    }

    return null;
  }

  // ------------------------------------------------------------
  // Date parsing
  // ------------------------------------------------------------

  DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;

    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------
  // Dispose
  // ------------------------------------------------------------

  @override
  void dispose() {
    _siteLiftController.dispose();
    _unitMachineController.dispose();
    _capacityController.dispose();
    _travelHeightController.dispose();
    _doorSizeController.dispose();
    _productModelController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // Date Picker
  // ------------------------------------------------------------

  Future<void> _selectDate({
    required DateTime? currentDate,
    required Function(DateTime) onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onSelected(picked);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  // ------------------------------------------------------------
  // Text Field
  // ------------------------------------------------------------

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool requiredField = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(
            label,
            requiredField: requiredField,
          ),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            decoration: _inputDecoration(
              hintText: 'Enter $label',
              readOnly: readOnly,
            ),
            validator: requiredField
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Dropdown
  // ------------------------------------------------------------

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool requiredField = false,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(
            label,
            requiredField: requiredField,
          ),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            value: items.contains(value) ? value : null,
            isExpanded: true,
            decoration: _inputDecoration(
              hintText: 'Select $label',
              readOnly: readOnly,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: readOnly ? null : onChanged,
            validator: requiredField
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Date Field
  // ------------------------------------------------------------

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required Function(DateTime) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 7),
          InkWell(
            onTap: () {
              _selectDate(
                currentDate: date,
                onSelected: onSelected,
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      date == null ? 'Select $label' : _formatDate(date),
                      style: TextStyle(
                        fontSize: 14,
                        color: date == null
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: _primary,
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Label
  // ------------------------------------------------------------

  Widget _buildLabel(
    String text, {
    bool requiredField = false,
  }) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: requiredField
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ]
            : null,
      ),
    );
  }

  // ------------------------------------------------------------
  // Input Decoration
  // ------------------------------------------------------------

  InputDecoration _inputDecoration({
    required String hintText,
    bool readOnly = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 14,
      ),
      filled: true,
      fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
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
          width: 1.4,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Section Header
  // ------------------------------------------------------------

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 21,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 9),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Submit
  // ------------------------------------------------------------

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    debugPrint(
      widget.isEditMode ? 'EDIT UNIT' : 'ADD UNIT',
    );

    debugPrint('Project ID: ${widget.projectId}');

    if (widget.isEditMode) {
      debugPrint(
        'Unit ID: ${widget.unit!.id}',
      );
    }

    debugPrint(
      'Site Lift No: ${_siteLiftController.text}',
    );

    debugPrint(
      'Unit/Machine No: ${_unitMachineController.text}',
    );

    debugPrint(
      'Capacity: ${_capacityController.text}',
    );

    debugPrint(
      'Lift Speed: $_selectedLiftSpeed',
    );

    debugPrint(
      'Stops: $_selectedStops',
    );

    debugPrint(
      'Openings: $_selectedOpenings',
    );

    debugPrint(
      'Door Type: $_selectedDoorType',
    );

    debugPrint(
      'Door Model: $_selectedDoorModel',
    );

    debugPrint(
      'Machine Room: $_selectedMachineRoomType',
    );

    debugPrint(
      'Product Model: ${_productModelController.text}',
    );

    debugPrint(
      'Standard Type: $_selectedStandardType',
    );

    debugPrint(
      'Status: $_selectedStatus',
    );

    debugPrint(
      'Installation: $_selectedInstallationMethod',
    );

    debugPrint(
      'Start Date: ${_formatDate(_startDate)}',
    );

    debugPrint(
      'Planned Finish: ${_formatDate(_plannedFinish)}',
    );

    debugPrint(
      'Actual Finish: ${_formatDate(_actualFinish)}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditMode
              ? 'Unit information updated successfully'
              : 'Unit information validated successfully',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // ADD:
    // HttpService.addUnitInfo(...)

    // EDIT:
    // HttpService.updateUnitInfo(
    //   unitId: widget.unit!.id,
    //   projectId: widget.projectId,
    //   ...
    // );
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Edit Unit Information' : 'Add Unit Information',
          style: const TextStyle(
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
            children: [
              // ==================================================
              // UNIT INFORMATION
              // ==================================================

              _buildFormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Unit Information',
                    ),

                    // FIXED IN EDIT
                    _buildTextField(
                      label: 'Site Lift No',
                      controller: _siteLiftController,
                      requiredField: true,
                      readOnly: widget.isEditMode,
                    ),

                    // FIXED IN EDIT
                    _buildTextField(
                      label: 'Unit/Machine No',
                      controller: _unitMachineController,
                      requiredField: true,
                      readOnly: widget.isEditMode,
                    ),

                    _buildTextField(
                      label: 'Capacity',
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                    ),

                    _buildDropdown(
                      label: 'Lift Speed',
                      value: _selectedLiftSpeed,
                      items: _liftSpeeds,
                      onChanged: (value) {
                        setState(() {
                          _selectedLiftSpeed = value;
                        });
                      },
                    ),

                    _buildDropdown(
                      label: 'Number of Stops',
                      value: _selectedStops,
                      items: _stops,
                      onChanged: (value) {
                        setState(() {
                          _selectedStops = value;
                        });
                      },
                    ),

                    _buildDropdown(
                      label: 'Number of Opening',
                      value: _selectedOpenings,
                      items: _openings,
                      onChanged: (value) {
                        setState(() {
                          _selectedOpenings = value;
                        });
                      },
                    ),

                    _buildTextField(
                      label: 'Travel Height',
                      controller: _travelHeightController,
                      keyboardType: TextInputType.number,
                    ),

                    _buildTextField(
                      label: 'Door Size',
                      controller: _doorSizeController,
                    ),

                    _buildDropdown(
                      label: 'Door Type',
                      value: _selectedDoorType,
                      items: _doorTypes,
                      onChanged: (value) {
                        setState(() {
                          _selectedDoorType = value;
                        });
                      },
                    ),

                    _buildDropdown(
                      label: 'Door Model',
                      value: _selectedDoorModel,
                      items: _doorModels,
                      onChanged: (value) {
                        setState(() {
                          _selectedDoorModel = value;
                        });
                      },
                    ),

                    _buildDropdown(
                      label: 'Machine Room Type',
                      value: _selectedMachineRoomType,
                      items: _machineRoomTypes,
                      onChanged: (value) {
                        setState(() {
                          _selectedMachineRoomType = value;
                        });
                      },
                    ),

                    _buildTextField(
                      label: 'Product Model Name',
                      controller: _productModelController,
                    ),

                    _buildDropdown(
                      label: 'Standard or Non Standard',
                      value: _selectedStandardType,
                      items: _standardTypes,
                      onChanged: (value) {
                        setState(() {
                          _selectedStandardType = value;
                        });
                      },
                    ),

                    _buildDropdown(
                      label: 'Current Status',
                      value: _selectedStatus,
                      items: _statuses,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),

                    _buildDateField(
                      label: 'Start Date',
                      date: _startDate,
                      onSelected: (date) {
                        setState(() {
                          _startDate = date;
                        });
                      },
                    ),

                    _buildDateField(
                      label: 'Planned Finish',
                      date: _plannedFinish,
                      onSelected: (date) {
                        setState(() {
                          _plannedFinish = date;
                        });
                      },
                    ),

                    _buildDateField(
                      label: 'Actual Finish',
                      date: _actualFinish,
                      onSelected: (date) {
                        setState(() {
                          _actualFinish = date;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // METHOD OF INSTALLATION
              // ==================================================

              _buildFormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Method of Installation',
                    ),

                    // FIXED IN EDIT
                    _buildDropdown(
                      label: 'Method of Installation',
                      value: _selectedInstallationMethod,
                      items: _installationMethods,
                      readOnly: widget.isEditMode,
                      onChanged: (value) {
                        setState(() {
                          _selectedInstallationMethod = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // SAVE / UPDATE
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: Icon(
                    widget.isEditMode
                        ? Icons.update_rounded
                        : Icons.save_rounded,
                    size: 20,
                  ),
                  label: Text(
                    widget.isEditMode
                        ? 'Update Unit Information'
                        : 'Save Unit Information',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  // ------------------------------------------------------------
  // Form Card
  // ------------------------------------------------------------

  Widget _buildFormCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:login2/service/service.dart';

// class AddUnitInfoPage extends StatefulWidget {
//   final String projectId;

//   // ADD / EDIT
//   final bool isEdit;

//   // Existing values used only in EDIT
//   final String? siteLiftNo;
//   final String? unitMachineNo;
//   final String? installationMethod;

//   const AddUnitInfoPage({
//     super.key,
//     required this.projectId,
//     this.isEdit = false,
//     this.siteLiftNo,
//     this.unitMachineNo,
//     this.installationMethod,
//   });

//   @override
//   State<AddUnitInfoPage> createState() => _AddUnitInfoPageState();
// }

// class _AddUnitInfoPageState extends State<AddUnitInfoPage> {
//   static const Color _primary = Color(0xFF2A86C9);
//   static const Color _primaryDark = Color(0xFF1A6CA8);

//   final _formKey = GlobalKey<FormState>();

//   // ============================================================
//   // Controllers
//   // ============================================================

//   final TextEditingController _siteLiftController =
//       TextEditingController();

//   final TextEditingController _unitMachineController =
//       TextEditingController();

//   final TextEditingController _capacityController =
//       TextEditingController();

//   final TextEditingController _travelHeightController =
//       TextEditingController();

//   final TextEditingController _doorSizeController =
//       TextEditingController();

//   final TextEditingController _productModelController =
//       TextEditingController();

//   // ============================================================
//   // Dropdown values
//   // ============================================================

//   String? _selectedLiftSpeed;
//   String? _selectedStops;
//   String? _selectedOpenings;
//   String? _selectedDoorType;
//   String? _selectedDoorModel;
//   String? _selectedMachineRoomType;
//   String? _selectedStandardType;
//   String? _selectedStatus;
//   String? _selectedInstallationMethod;

//   // ============================================================
//   // Dates
//   // ============================================================

//   DateTime? _startDate;
//   DateTime? _plannedFinish;
//   DateTime? _actualFinish;

//   // ============================================================
//   // Activity
//   // ============================================================

//   List<ActivityItem> _activities = [];

//   bool _isLoadingActivities = false;

//   // ============================================================
//   // Dropdown data
//   // ============================================================

//   final List<String> _liftSpeeds = [
//     '1 M/S',
//     '1.5 M/S',
//   ];

//   final List<String> _stops = List.generate(
//     10,
//     (index) => 'No of Stops ${index + 1}',
//   );

//   final List<String> _openings = List.generate(
//     10,
//     (index) => 'No of Openings ${index + 1}',
//   );

//   final List<String> _doorTypes = [
//     'Center Opening',
//     'Side Opening',
//     'Manual Opening',
//   ];

//   final List<String> _doorModels = [
//     'Painted',
//     'Not Painted',
//     'Stainless Steel',
//   ];

//   final List<String> _machineRoomTypes = [
//     'MRL',
//     'URL',
//     'CRL',
//   ];

//   final List<String> _standardTypes = [
//     'Standard',
//     'Non Standard',
//   ];

//   final List<String> _statuses = [
//     'Pending',
//     'In progress',
//   ];

//   final List<String> _installationMethods = [
//     'Scaffolding',
//     'Fit Method',
//     'False Car',
//     'Rope Climbing',
//     'Platform',
//   ];

//   final List<String> _activityStatuses = [
//     'Completed',
//     'In Progress',
//     'Pending',
//     'On Hold',
//     'Not Applicable',
//   ];

//   // ============================================================
//   // INIT
//   // ============================================================

//   @override
//   void initState() {
//     super.initState();

//     if (widget.isEdit) {
//       _siteLiftController.text = widget.siteLiftNo ?? '';
//       _unitMachineController.text = widget.unitMachineNo ?? '';

//       _selectedInstallationMethod = widget.installationMethod;

//       if (_selectedInstallationMethod != null &&
//           _selectedInstallationMethod!.isNotEmpty) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _loadActivities(_selectedInstallationMethod!);
//         });
//       }
//     }
//   }

//   // ============================================================
//   // DISPOSE
//   // ============================================================

//   @override
//   void dispose() {
//     _siteLiftController.dispose();
//     _unitMachineController.dispose();
//     _capacityController.dispose();
//     _travelHeightController.dispose();
//     _doorSizeController.dispose();
//     _productModelController.dispose();

//     super.dispose();
//   }

//   // ============================================================
//   // LOAD ACTIVITIES
//   // ============================================================

//   Future<void> _loadActivities(String installationMethod) async {
//     if (installationMethod.trim().isEmpty) {
//       return;
//     }

//     setState(() {
//       _isLoadingActivities = true;
//       _activities = [];
//     });

//     try {
//       /*
//        * IMPORTANT:
//        *
//        * Replace this call with your actual service method.
//        *
//        * Only these values should be sent:
//        *
//        * projectId
//        * token
//        * installationMethod
//        *
//        */

//       final response =
//           await HttpService.getInstallationActivities(
//         projectId: widget.projectId,
//         installationMethod: installationMethod,
//       );

//       if (!mounted) return;

//       setState(() {
//         _activities = response.data;
//       });

//       log(
//         'Activities loaded: ${_activities.length}',
//       );
//     } catch (e, stackTrace) {
//       log(
//         'Failed to load activities',
//         error: e,
//         stackTrace: stackTrace,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Failed to load activities: $e',
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } finally {
//       if (!mounted) return;

//       setState(() {
//         _isLoadingActivities = false;
//       });
//     }
//   }

//   // ============================================================
//   // DATE PICKER
//   // ============================================================

//   Future<void> _selectDate({
//     required DateTime? currentDate,
//     required Function(DateTime) onSelected,
//   }) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: currentDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: _primary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       onSelected(picked);
//     }
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return '';

//     return '${date.day.toString().padLeft(2, '0')}-'
//         '${date.month.toString().padLeft(2, '0')}-'
//         '${date.year}';
//   }

//   // ============================================================
//   // TEXT FIELD
//   // ============================================================

//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     bool requiredField = false,
//     TextInputType keyboardType = TextInputType.text,
//     bool readOnly = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 18),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildLabel(
//             label,
//             requiredField: requiredField,
//           ),
//           const SizedBox(height: 7),
//           TextFormField(
//             controller: controller,
//             keyboardType: keyboardType,
//             readOnly: readOnly,
//             decoration: _inputDecoration(
//               hintText: 'Enter $label',
//             ).copyWith(
//               fillColor: readOnly
//                   ? Colors.grey.shade200
//                   : Colors.grey.shade50,
//               suffixIcon: readOnly
//                   ? const Icon(
//                       Icons.lock_outline_rounded,
//                       size: 19,
//                       color: Colors.grey,
//                     )
//                   : null,
//             ),
//             validator: requiredField
//                 ? (value) {
//                     if (value == null ||
//                         value.trim().isEmpty) {
//                       return '$label is required';
//                     }

//                     return null;
//                   }
//                 : null,
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // DROPDOWN
//   // ============================================================

//   Widget _buildDropdown({
//     required String label,
//     required String? value,
//     required List<String> items,
//     required Function(String?)? onChanged,
//     bool requiredField = false,
//   }) {
//     final bool disabled = onChanged == null;

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 18),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildLabel(
//             label,
//             requiredField: requiredField,
//           ),
//           const SizedBox(height: 7),
//           DropdownButtonFormField<String>(
//             value: value,
//             isExpanded: true,
//             decoration: _inputDecoration(
//               hintText: 'Select $label',
//             ).copyWith(
//               fillColor: disabled
//                   ? Colors.grey.shade200
//                   : Colors.grey.shade50,
//               suffixIcon: disabled
//                   ? const Icon(
//                       Icons.lock_outline_rounded,
//                       size: 19,
//                       color: Colors.grey,
//                     )
//                   : null,
//             ),
//             icon: Icon(
//               Icons.keyboard_arrow_down_rounded,
//               color: disabled
//                   ? Colors.grey.shade400
//                   : Colors.grey,
//             ),
//             items: items.map((item) {
//               return DropdownMenuItem<String>(
//                 value: item,
//                 child: Text(
//                   item,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               );
//             }).toList(),
//             onChanged: onChanged,
//             validator: requiredField
//                 ? (value) {
//                     if (value == null ||
//                         value.isEmpty) {
//                       return '$label is required';
//                     }

//                     return null;
//                   }
//                 : null,
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // DATE FIELD
//   // ============================================================

//   Widget _buildDateField({
//     required String label,
//     required DateTime? date,
//     required Function(DateTime) onSelected,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 18),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildLabel(label),
//           const SizedBox(height: 7),
//           InkWell(
//             onTap: () {
//               _selectDate(
//                 currentDate: date,
//                 onSelected: onSelected,
//               );
//             },
//             borderRadius: BorderRadius.circular(10),
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 14,
//                 vertical: 14,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(
//                   color: Colors.grey.shade300,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       date == null
//                           ? 'Select $label'
//                           : _formatDate(date),
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: date == null
//                             ? Colors.grey.shade600
//                             : Colors.black87,
//                       ),
//                     ),
//                   ),
//                   const Icon(
//                     Icons.calendar_month_rounded,
//                     color: _primary,
//                     size: 21,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // LABEL
//   // ============================================================

//   Widget _buildLabel(
//     String text, {
//     bool requiredField = false,
//   }) {
//     return RichText(
//       text: TextSpan(
//         text: text,
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//           color: Colors.black87,
//         ),
//         children: requiredField
//             ? const [
//                 TextSpan(
//                   text: ' *',
//                   style: TextStyle(
//                     color: Colors.red,
//                   ),
//                 ),
//               ]
//             : null,
//       ),
//     );
//   }

//   // ============================================================
//   // INPUT DECORATION
//   // ============================================================

//   InputDecoration _inputDecoration({
//     required String hintText,
//   }) {
//     return InputDecoration(
//       hintText: hintText,
//       hintStyle: TextStyle(
//         color: Colors.grey.shade500,
//         fontSize: 14,
//       ),
//       filled: true,
//       fillColor: Colors.grey.shade50,
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 13,
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(
//           color: Colors.grey.shade300,
//         ),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(
//           color: Colors.grey.shade300,
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(
//           color: _primary,
//           width: 1.4,
//         ),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(
//           color: Colors.red,
//         ),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(
//           color: Colors.red,
//           width: 1.4,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // SECTION HEADER
//   // ============================================================

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(
//         bottom: 16,
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 4,
//             height: 21,
//             decoration: BoxDecoration(
//               color: _primary,
//               borderRadius: BorderRadius.circular(3),
//             ),
//           ),
//           const SizedBox(width: 9),
//           Expanded(
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // ACTIVITY SECTION
//   // ============================================================

//   Widget _buildActivitySection() {
//     if (_isLoadingActivities) {
//       return _buildFormCard(
//         child: const Padding(
//           padding: EdgeInsets.all(25),
//           child: Center(
//             child: CircularProgressIndicator(
//               color: _primary,
//             ),
//           ),
//         ),
//       );
//     }

//     if (_selectedInstallationMethod == null) {
//       return const SizedBox.shrink();
//     }

//     if (_activities.isEmpty) {
//       return _buildFormCard(
//         child: const Padding(
//           padding: EdgeInsets.all(8),
//           child: Text(
//             'No activities found for this installation method.',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//         ),
//       );
//     }

//     return _buildFormCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader(
//             'Activity Management '
//             '($_selectedInstallationMethod)',
//           ),

//           ..._activities.map(
//             (activity) => _buildActivityItem(
//               activity,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // ACTIVITY ITEM
//   // ============================================================

//   Widget _buildActivityItem(
//     ActivityItem activity,
//   ) {
//     return Container(
//       margin: const EdgeInsets.only(
//         bottom: 14,
//       ),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Colors.grey.shade200,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             activity.name,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),

//           const SizedBox(height: 12),

//           _buildActivityDropdown(
//             activity: activity,
//           ),

//           const SizedBox(height: 12),

//           TextFormField(
//             initialValue:
//                 activity.percentage?.toString() ?? '',
//             keyboardType: TextInputType.number,
//             decoration: _inputDecoration(
//               hintText: '% of Completion',
//             ),
//             onChanged: (value) {
//               activity.percentage = value;
//             },
//           ),

//           const SizedBox(height: 12),

//           _buildActivityDateField(
//             label: 'Start Date',
//             date: activity.startDate,
//             onSelected: (date) {
//               setState(() {
//                 activity.startDate = date;
//               });
//             },
//           ),

//           const SizedBox(height: 12),

//           _buildActivityDateField(
//             label: 'Completed Date',
//             date: activity.completedDate,
//             onSelected: (date) {
//               setState(() {
//                 activity.completedDate = date;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // ACTIVITY STATUS DROPDOWN
//   // ============================================================

//   Widget _buildActivityDropdown({
//     required ActivityItem activity,
//   }) {
//     return DropdownButtonFormField<String>(
//       value: _activityStatuses.contains(
//         activity.status,
//       )
//           ? activity.status
//           : null,
//       isExpanded: true,
//       decoration: _inputDecoration(
//         hintText: 'Select Status',
//       ),
//       icon: const Icon(
//         Icons.keyboard_arrow_down_rounded,
//         color: Colors.grey,
//       ),
//       items: _activityStatuses.map((status) {
//         return DropdownMenuItem<String>(
//           value: status,
//           child: Text(status),
//         );
//       }).toList(),
//       onChanged: (value) {
//         setState(() {
//           activity.status = value;
//         });
//       },
//     );
//   }

//   // ============================================================
//   // ACTIVITY DATE
//   // ============================================================

//   Widget _buildActivityDateField({
//     required String label,
//     required DateTime? date,
//     required Function(DateTime) onSelected,
//   }) {
//     return InkWell(
//       onTap: () {
//         _selectDate(
//           currentDate: date,
//           onSelected: onSelected,
//         );
//       },
//       borderRadius: BorderRadius.circular(10),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 14,
//         ),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: Colors.grey.shade300,
//           ),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 date == null
//                     ? label
//                     : _formatDate(date),
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: date == null
//                       ? Colors.grey.shade600
//                       : Colors.black87,
//                 ),
//               ),
//             ),
//             const Icon(
//               Icons.calendar_month_rounded,
//               color: _primary,
//               size: 21,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // SUBMIT
//   // ============================================================

//   void _submit() {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_selectedInstallationMethod == null ||
//         _selectedInstallationMethod!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Please select Method of Installation',
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );

//       return;
//     }

//     log('==============================');
//     log(
//       widget.isEdit
//           ? 'EDIT UNIT'
//           : 'ADD UNIT',
//     );
//     log('Project ID: ${widget.projectId}');
//     log(
//       'Site Lift No: '
//       '${_siteLiftController.text}',
//     );
//     log(
//       'Unit/Machine No: '
//       '${_unitMachineController.text}',
//     );
//     log(
//       'Installation Method: '
//       '$_selectedInstallationMethod',
//     );

//     for (final activity in _activities) {
//       log(
//         'Activity: ${activity.name}',
//       );

//       log(
//         'Status: ${activity.status}',
//       );

//       log(
//         'Percentage: ${activity.percentage}',
//       );

//       log(
//         'Start Date: ${activity.startDate}',
//       );

//       log(
//         'Completed Date: '
//         '${activity.completedDate}',
//       );
//     }

//     log('==============================');

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           widget.isEdit
//               ? 'Unit information ready for update'
//               : 'Unit information validated successfully',
//         ),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );

//     /*
//      * Later:
//      *
//      * if (widget.isEdit) {
//      *   HttpService.updateUnitInfo(...)
//      * } else {
//      *   HttpService.addUnitInfo(...)
//      * }
//      */
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF1F5FB),

//       // ========================================================
//       // APP BAR
//       // ========================================================

//       appBar: AppBar(
//         title: Text(
//           widget.isEdit
//               ? 'Edit Unit Information'
//               : 'Add Unit Information',
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 17,
//           ),
//         ),
//         backgroundColor: _primary,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new_rounded,
//             color: Colors.white,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 _primary,
//                 _primaryDark,
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),

//       // ========================================================
//       // BODY
//       // ========================================================

//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(
//             16,
//             16,
//             16,
//             30,
//           ),
//           child: Column(
//             children: [
//               // ==================================================
//               // UNIT INFORMATION
//               // ==================================================

//               _buildFormCard(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     _buildSectionHeader(
//                       'Unit Information',
//                     ),

//                     // Site Lift No
//                     _buildTextField(
//                       label: 'Site Lift No',
//                       controller:
//                           _siteLiftController,
//                       requiredField: true,
//                       readOnly: widget.isEdit,
//                     ),

//                     // Unit / Machine No
//                     _buildTextField(
//                       label: 'Unit/Machine No',
//                       controller:
//                           _unitMachineController,
//                       requiredField: true,
//                       readOnly: widget.isEdit,
//                     ),

//                     // Capacity
//                     _buildTextField(
//                       label: 'Capacity',
//                       controller:
//                           _capacityController,
//                       keyboardType:
//                           TextInputType.number,
//                     ),

//                     // Lift Speed
//                     _buildDropdown(
//                       label: 'Lift Speed',
//                       value:
//                           _selectedLiftSpeed,
//                       items: _liftSpeeds,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedLiftSpeed =
//                               value;
//                         });
//                       },
//                     ),

//                     // Stops
//                     _buildDropdown(
//                       label: 'Number of Stops',
//                       value: _selectedStops,
//                       items: _stops,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedStops =
//                               value;
//                         });
//                       },
//                     ),

//                     // Openings
//                     _buildDropdown(
//                       label: 'Number of Opening',
//                       value:
//                           _selectedOpenings,
//                       items: _openings,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedOpenings =
//                               value;
//                         });
//                       },
//                     ),

//                     // Travel Height
//                     _buildTextField(
//                       label: 'Travel Height',
//                       controller:
//                           _travelHeightController,
//                       keyboardType:
//                           TextInputType.number,
//                     ),

//                     // Door Size
//                     _buildTextField(
//                       label: 'Door Size',
//                       controller:
//                           _doorSizeController,
//                     ),

//                     // Door Type
//                     _buildDropdown(
//                       label: 'Door Type',
//                       value:
//                           _selectedDoorType,
//                       items: _doorTypes,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedDoorType =
//                               value;
//                         });
//                       },
//                     ),

//                     // Door Model
//                     _buildDropdown(
//                       label: 'Door Model',
//                       value:
//                           _selectedDoorModel,
//                       items: _doorModels,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedDoorModel =
//                               value;
//                         });
//                       },
//                     ),

//                     // Machine Room
//                     _buildDropdown(
//                       label:
//                           'Machine Room Type',
//                       value:
//                           _selectedMachineRoomType,
//                       items:
//                           _machineRoomTypes,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedMachineRoomType =
//                               value;
//                         });
//                       },
//                     ),

//                     // Product Model
//                     _buildTextField(
//                       label:
//                           'Product Model Name',
//                       controller:
//                           _productModelController,
//                     ),

//                     // Standard
//                     _buildDropdown(
//                       label:
//                           'Standard or Non Standard',
//                       value:
//                           _selectedStandardType,
//                       items:
//                           _standardTypes,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedStandardType =
//                               value;
//                         });
//                       },
//                     ),

//                     // Current Status
//                     _buildDropdown(
//                       label: 'Current Status',
//                       value:
//                           _selectedStatus,
//                       items: _statuses,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedStatus =
//                               value;
//                         });
//                       },
//                     ),

//                     // Start Date
//                     _buildDateField(
//                       label: 'Start Date',
//                       date: _startDate,
//                       onSelected: (date) {
//                         setState(() {
//                           _startDate = date;
//                         });
//                       },
//                     ),

//                     // Planned Finish
//                     _buildDateField(
//                       label: 'Planned Finish',
//                       date: _plannedFinish,
//                       onSelected: (date) {
//                         setState(() {
//                           _plannedFinish =
//                               date;
//                         });
//                       },
//                     ),

//                     // Actual Finish
//                     _buildDateField(
//                       label: 'Actual Finish',
//                       date: _actualFinish,
//                       onSelected: (date) {
//                         setState(() {
//                           _actualFinish =
//                               date;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // ==================================================
//               // METHOD OF INSTALLATION
//               // ==================================================

//               _buildFormCard(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     _buildSectionHeader(
//                       'Method of Installation',
//                     ),

//                     _buildDropdown(
//                       label:
//                           'Method of Installation',
//                       value:
//                           _selectedInstallationMethod,
//                       items:
//                           _installationMethods,

//                       // EDIT = disabled
//                       // ADD = enabled
//                       onChanged: widget.isEdit
//                           ? null
//                           : (value) {
//                               setState(() {
//                                 _selectedInstallationMethod =
//                                     value;

//                                 _activities = [];
//                               });

//                               if (value != null) {
//                                 _loadActivities(
//                                   value,
//                                 );
//                               }
//                             },

//                       requiredField: true,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // ==================================================
//               // ACTIVITY MANAGEMENT
//               // ==================================================

//               _buildActivitySection(),

//               const SizedBox(height: 22),

//               // ==================================================
//               // SAVE BUTTON
//               // ==================================================

//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton.icon(
//                   onPressed: _submit,
//                   icon: Icon(
//                     widget.isEdit
//                         ? Icons.update_rounded
//                         : Icons.save_rounded,
//                     size: 20,
//                   ),
//                   label: Text(
//                     widget.isEdit
//                         ? 'Update Unit Information'
//                         : 'Save Unit Information',
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight:
//                           FontWeight.w600,
//                     ),
//                   ),
//                   style:
//                       ElevatedButton.styleFrom(
//                     backgroundColor:
//                         _primary,
//                     foregroundColor:
//                         Colors.white,
//                     elevation: 0,
//                     shape:
//                         RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(
//                         12,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FORM CARD
//   // ============================================================

//   Widget _buildFormCard({
//     required Widget child,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color:
//                 _primary.withOpacity(0.07),
//             blurRadius: 12,
//             offset:
//                 const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }

// // ================================================================
// // ACTIVITY MODEL
// // ================================================================

// class ActivityItem {
//   final int id;

//   final String name;

//   String? status;

//   String? percentage;

//   DateTime? startDate;

//   DateTime? completedDate;

//   ActivityItem({
//     required this.id,
//     required this.name,
//     this.status,
//     this.percentage,
//     this.startDate,
//     this.completedDate,
//   });

//   factory ActivityItem.fromJson(
//     Map<String, dynamic> json,
//   ) {
//     return ActivityItem(
//       id: _parseInt(json['id']),
//       name:
//           json['name']?.toString() ??
//           json['activity_name']?.toString() ??
//           '',
//       status:
//           json['status']?.toString(),
//       percentage:
//           json['percentage']?.toString() ??
//           json['completion_percentage']
//               ?.toString(),
//       startDate:
//           _parseDate(
//         json['start_date'],
//       ),
//       completedDate:
//           _parseDate(
//         json['completed_date'],
//       ),
//     );
//   }

//   static int _parseInt(dynamic value) {
//     if (value is int) {
//       return value;
//     }

//     return int.tryParse(
//           value?.toString() ?? '',
//         ) ??
//         0;
//   }

//   static DateTime? _parseDate(
//     dynamic value,
//   ) {
//     if (value == null) {
//       return null;
//     }

//     return DateTime.tryParse(
//       value.toString(),
//     );
//   }
// }
