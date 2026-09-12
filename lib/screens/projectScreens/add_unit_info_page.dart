import 'package:flutter/material.dart';

import '../../models/projectdetails/unit_info_model.dart';
import '../../models/projectdetails/unit_dropdown_model.dart';
import '../../models/projectdetails/installation_method_model.dart';
import '../../models/projectdetails/method_of_installation.dart';
import '../../service/service.dart';

class AddUnitInfoPage extends StatefulWidget {
  final String projectId;
  final UnitInfoData? unit;

  const AddUnitInfoPage({
    super.key,
    required this.projectId,
    this.unit,
  });

  bool get isEdit => unit != null;

  @override
  State<AddUnitInfoPage> createState() => _AddUnitInfoPageState();
}

class _AddUnitInfoPageState extends State<AddUnitInfoPage> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);
  static const Color _pageBackground = Color(0xFFF1F5FB);

  final _formKey = GlobalKey<FormState>();

  // ---------------------------------------------------------------------------
  // Controllers
  // ---------------------------------------------------------------------------

  final _siteLiftNoController = TextEditingController();
  final _unitMachineNoController = TextEditingController();
  final _capacityController = TextEditingController();
  final _travelHeightController = TextEditingController();
  final _doorSizeController = TextEditingController();
  final _productModelNameController = TextEditingController();
  final _totalManpowerController = TextEditingController();
  final _startDateController = TextEditingController();
  final _plannedFinishController = TextEditingController();
  final _actualFinishController = TextEditingController();

  // ---------------------------------------------------------------------------
  // Unit dropdowns
  // ---------------------------------------------------------------------------

  List<UnitDropdownItem> _liftSpeeds = [];
  List<UnitDropdownItem> _stops = [];
  List<UnitDropdownItem> _openings = [];
  List<UnitDropdownItem> _doorTypes = [];
  List<UnitDropdownItem> _doorModels = [];
  List<UnitDropdownItem> _machineRoomTypes = [];
  List<UnitDropdownItem> _liftTypes = [];
  List<UnitDropdownItem> _statuses = [];

  String? _selectedLiftSpeedId;
  String? _selectedStopsId;
  String? _selectedOpeningsId;
  String? _selectedDoorTypeId;
  String? _selectedDoorModelId;
  String? _selectedMachineRoomTypeId;
  String? _selectedLiftTypeId;
  String? _selectedStatusId;

  // Only these two values are intentionally hardcoded.
  String? _selectedStandardType;

  final List<String> _standardTypes = const [
    'Standard',
    'Non Standard',
  ];

  // ---------------------------------------------------------------------------
  // Installation method
  // ---------------------------------------------------------------------------

  List<InstallationMethodItem> _installationMethods = [];
  String? _selectedMethodId;

  bool _loadingMethods = false;

  // ---------------------------------------------------------------------------
  // Installation activities
  // ---------------------------------------------------------------------------

  List<MethodActivityItem> _installationActivities = [];
  bool _loadingActivities = false;

  final Map<String, TextEditingController> _activityPercentageControllers = {};

  final Map<String, String?> _activityStatuses = {};
  final Map<String, String?> _activityStartDates = {};
  final Map<String, String?> _activityCompletedDates = {};

  final List<Map<String, String>> _activityStatusOptions = const [
    {
      'value': 'completed',
      'label': 'Completed',
    },
    {
      'value': 'in_progress',
      'label': 'In Progress',
    },
    {
      'value': 'pending',
      'label': 'Pending',
    },
    {
      'value': 'on_hold',
      'label': 'On Hold',
    },
    {
      'value': 'not_applicable',
      'label': 'Not Applicable',
    },
  ];

  bool _isLoadingDropdowns = false;
  bool _isSaving = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _initializeUnitValues();
    _loadDropdownValues();
    _loadInstallationMethods();
  }

  @override
  void dispose() {
    _siteLiftNoController.dispose();
    _unitMachineNoController.dispose();
    _capacityController.dispose();
    _travelHeightController.dispose();
    _doorSizeController.dispose();
    _productModelNameController.dispose();
    _totalManpowerController.dispose();
    _startDateController.dispose();
    _plannedFinishController.dispose();
    _actualFinishController.dispose();

    for (final controller in _activityPercentageControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Initial values
  // ---------------------------------------------------------------------------

  void _initializeUnitValues() {
    final unit = widget.unit;

    if (unit == null) {
      return;
    }

    _siteLiftNoController.text = unit.siteLiftNo;
    _unitMachineNoController.text = unit.unitMachineNo;
    _capacityController.text = unit.capacity;
    _travelHeightController.text = unit.travelHeight;
    _doorSizeController.text = unit.doorSize;
    _productModelNameController.text = unit.productModelName;
    _totalManpowerController.text = unit.totalManpower;
    _startDateController.text = unit.startDate;
    _plannedFinishController.text = unit.endDate;
    _actualFinishController.text = unit.actualFinish;

    _selectedLiftSpeedId = unit.speed.isNotEmpty ? unit.speed : null;
    _selectedStopsId =
        unit.numberOfStops.isNotEmpty ? unit.numberOfStops : null;
    _selectedOpeningsId =
        unit.numberOfOpening.isNotEmpty ? unit.numberOfOpening : null;
    _selectedDoorTypeId =
        unit.doorTypeId.isNotEmpty ? unit.doorTypeId : null;
    _selectedDoorModelId =
        unit.doorModelId.isNotEmpty ? unit.doorModelId : null;
    _selectedMachineRoomTypeId =
        unit.machineRoomTypeId.isNotEmpty ? unit.machineRoomTypeId : null;
    _selectedLiftTypeId = unit.typeId.isNotEmpty ? unit.typeId : null;
    _selectedStatusId = unit.statusId.isNotEmpty ? unit.statusId : null;

    if (unit.standardType.isNotEmpty) {
      final normalized = unit.standardType.trim().toLowerCase();
      if (normalized == 'standard') {
        _selectedStandardType = 'Standard';
      } else if (normalized == 'non standard' ||
          normalized == 'non-standard' ||
          normalized == 'nonstandard') {
        _selectedStandardType = 'Non Standard';
      }
    }

    _selectedMethodId = unit.methodId.isNotEmpty ? unit.methodId : null;
  }

  // ---------------------------------------------------------------------------
  // Load Unit Dropdowns
  // ---------------------------------------------------------------------------

  Future<void> _loadDropdownValues() async {
    if (!mounted) return;

    setState(() {
      _isLoadingDropdowns = true;
    });

    try {
      final firstResponse = await HttpService.getUnitDropdownValues();

      final secondResponse =
          await HttpService.getUnitAdditionalDropdownValues();

      if (!mounted) return;

      setState(() {
        // FIRST API
        _liftSpeeds = firstResponse['lift_speed'] ?? [];
        _stops = firstResponse['no_of_stops'] ?? [];
        _openings = firstResponse['no_of_opening'] ?? [];
        _doorTypes = firstResponse['door_type'] ?? [];
        _liftTypes = firstResponse['lift_type'] ?? [];

        // SECOND API
        _doorModels = secondResponse['door_model'] ?? [];
        _machineRoomTypes = secondResponse['machine_room_types'] ?? [];
        _statuses = secondResponse['current_statuses'] ?? [];

        _isLoadingDropdowns = false;
      });
    } catch (e) {
      print('LOAD UNIT DROPDOWNS ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingDropdowns = false;
      });

      _showMessage(
        'Failed to load unit dropdown values',
        isError: true,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Load Installation Methods
  // ---------------------------------------------------------------------------

  Future<void> _loadInstallationMethods() async {
    if (!mounted) return;

    setState(() {
      _loadingMethods = true;
    });

    try {
      final response = await HttpService.getMethodOfInstallation();

      if (!mounted) return;

      if (response.status) {
        setState(() {
          _installationMethods = response.data;
          _loadingMethods = false;
        });

        // In edit mode, automatically load activities for the pre-selected method
        if (widget.isEdit &&
            _selectedMethodId != null &&
            _selectedMethodId!.isNotEmpty) {
          _loadActivitiesForMethod(_selectedMethodId!, isInitialEditLoad: true);
        }
      } else {
        setState(() {
          _installationMethods = [];
          _loadingMethods = false;
        });
      }
    } catch (e) {
      print('LOAD INSTALLATION METHODS ERROR: $e');

      if (!mounted) return;

      setState(() {
        _loadingMethods = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Installation Method Changed
  // ---------------------------------------------------------------------------

  Future<void> _onInstallationMethodChanged(
    String? methodId,
  ) async {
    if (methodId == null || methodId.isEmpty) {
      setState(() {
        _selectedMethodId = null;
        _installationActivities = [];
        _loadingActivities = false;
      });

      _clearActivityControllers();
      return;
    }

    await _loadActivitiesForMethod(methodId, isInitialEditLoad: false);
  }

  Future<void> _loadActivitiesForMethod(
    String methodId, {
    bool isInitialEditLoad = false,
  }) async {
    setState(() {
      _selectedMethodId = methodId;
      _installationActivities = [];
      _loadingActivities = true;
    });

    _clearActivityControllers();

    try {
      print('GET INSTALLATION ACTIVITIES METHOD ID: $methodId');

      final response = await HttpService.getInstallationActivities(
        methodId: methodId,
      );

      if (!mounted) return;

      if (response.status) {
        setState(() {
          _installationActivities = response.data;
          _loadingActivities = false;
        });

        _initializeActivityFields(response.data);

        // In edit mode on initial load, populate saved activity values
        if (isInitialEditLoad && widget.isEdit && widget.unit != null) {
          await _populateSavedUnitActivities();
        }
      } else {
        setState(() {
          _installationActivities = [];
          _loadingActivities = false;
        });

        if (!isInitialEditLoad) {
          _showMessage(
            response.message.isNotEmpty
                ? response.message
                : 'No activities found',
            isError: true,
          );
        }
      }
    } catch (e) {
      print('LOAD INSTALLATION ACTIVITIES ERROR: $e');

      if (!mounted) return;

      setState(() {
        _installationActivities = [];
        _loadingActivities = false;
      });

      if (!isInitialEditLoad) {
        _showMessage(
          'Failed to load installation activities',
          isError: true,
        );
      }
    }
  }

  Future<void> _populateSavedUnitActivities() async {
    final unit = widget.unit;
    if (unit == null) return;

    final unitId = unit.unitId.isNotEmpty ? unit.unitId : unit.id;
    final methodId =
        unit.methodId.isNotEmpty ? unit.methodId : (_selectedMethodId ?? '');

    if (unitId.isNotEmpty && methodId.isNotEmpty) {
      try {
        final savedResponse = await HttpService.getUnitActivityDetails(
          projectId: widget.projectId,
          unitNo: unitId,
          methodId: methodId,
        );

        if (!mounted) return;

        if (savedResponse != null && savedResponse.data.isNotEmpty) {
          setState(() {
            for (final saved in savedResponse.data) {
              final key = saved.activityKey;
              if (_activityPercentageControllers.containsKey(key)) {
                if (saved.percentage.isNotEmpty) {
                  _activityPercentageControllers[key]?.text =
                      saved.percentage;
                }
                if (saved.status.isNotEmpty) {
                  _activityStatuses[key] =
                      _normalizeActivityStatus(saved.status);
                }
                if (saved.startDate.isNotEmpty) {
                  _activityStartDates[key] = saved.startDate;
                }
                if (saved.completedDate.isNotEmpty) {
                  _activityCompletedDates[key] = saved.completedDate;
                }
              }
            }
          });
        }
      } catch (e) {
        print('ERROR POPULATING SAVED ACTIVITIES: $e');
      }
    }

    // Fallback if UnitInfoData itself had fields
    if (unit.activityKey.isNotEmpty &&
        _activityPercentageControllers.containsKey(unit.activityKey)) {
      setState(() {
        if (unit.percentage.isNotEmpty &&
            (_activityPercentageControllers[unit.activityKey]
                    ?.text
                    .isEmpty ??
                true)) {
          _activityPercentageControllers[unit.activityKey]?.text =
              unit.percentage;
        }
        if (unit.status.isNotEmpty &&
            _activityStatuses[unit.activityKey] == null) {
          _activityStatuses[unit.activityKey] =
              _normalizeActivityStatus(unit.status);
        }
        if (unit.startDate.isNotEmpty &&
            _activityStartDates[unit.activityKey] == null) {
          _activityStartDates[unit.activityKey] = unit.startDate;
        }
        if (unit.completedDate.isNotEmpty &&
            _activityCompletedDates[unit.activityKey] == null) {
          _activityCompletedDates[unit.activityKey] = unit.completedDate;
        }
      });
    }
  }

  String? _normalizeActivityStatus(String? status) {
    if (status == null || status.trim().isEmpty) return null;
    final clean =
        status.trim().toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    for (final opt in _activityStatusOptions) {
      if (opt['value'] == clean) {
        return opt['value'];
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Activity fields
  // ---------------------------------------------------------------------------

  void _initializeActivityFields(
    List<MethodActivityItem> activities,
  ) {
    for (final activity in activities) {
      if (!_activityPercentageControllers.containsKey(
        activity.activityKey,
      )) {
        _activityPercentageControllers[activity.activityKey] =
            TextEditingController();
      }

      _activityStatuses[activity.activityKey] = null;
      _activityStartDates[activity.activityKey] = null;
      _activityCompletedDates[activity.activityKey] = null;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _clearActivityControllers() {
    for (final controller in _activityPercentageControllers.values) {
      controller.dispose();
    }

    _activityPercentageControllers.clear();
    _activityStatuses.clear();
    _activityStartDates.clear();
    _activityCompletedDates.clear();
  }

  // ---------------------------------------------------------------------------
  // Date picker
  // ---------------------------------------------------------------------------

  Future<void> _selectDate({
    required String activityKey,
    required bool isStartDate,
  }) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    final formatted = _formatDate(picked);

    setState(() {
      if (isStartDate) {
        _activityStartDates[activityKey] = formatted;
      } else {
        _activityCompletedDates[activityKey] = formatted;
      }
    });
  }

  Future<void> _selectNormalDate({
    required TextEditingController controller,
  }) async {
    DateTime initialDate = DateTime.now();

    if (controller.text.isNotEmpty) {
      try {
        final parts = controller.text.split('-');

        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    controller.text = _formatDate(picked);

    setState(() {});
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  UnitDropdownItem? _findItemById(
    List<UnitDropdownItem> items,
    String? id,
  ) {
    if (id == null || id.isEmpty) {
      return null;
    }

    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }

    for (final item in items) {
      if (item.name.trim().toLowerCase() == id.trim().toLowerCase()) {
        return item;
      }
    }

    return null;
  }


  InputDecoration _inputDecoration(
    String label, {
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _primary,
          width: 1.5,
        ),
      ),
    );
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : _primary,
      ),
    );
  }

  List<Map<String, String>> _buildActivityPayload() {
    return _installationActivities.map((activity) {
      return {
        'activity_key': activity.activityKey,
        'activity_name': activity.activityName,
        'status': _activityStatuses[activity.activityKey] ?? '',
        'percentage':
            _activityPercentageControllers[activity.activityKey]?.text.trim() ??
                '',
        'start_date': _activityStartDates[activity.activityKey] ?? '',
        'completed_date': _activityCompletedDates[activity.activityKey] ?? '',
      };
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _saveUnitInformation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final activityData = _buildActivityPayload();
      print('========== UNIT SAVE DEBUG ==========');
      print('Is Edit: ${widget.isEdit}');
      print('Current Status ID: $_selectedStatusId');
      print('Standard Type: $_selectedStandardType');
      print('Lift Speed ID: $_selectedLiftSpeedId');
      print('Stops ID: $_selectedStopsId');
      print('Openings ID: $_selectedOpeningsId');
      print('Door Type ID: $_selectedDoorTypeId');
      print('Door Model ID: $_selectedDoorModelId');
      print('Machine Room Type ID: $_selectedMachineRoomTypeId');
      print('Lift Type ID: $_selectedLiftTypeId');
      print('=====================================');

      final Map<String, dynamic> response;

      if (widget.isEdit && widget.unit != null) {
        final unitId = widget.unit!.unitId.isNotEmpty
            ? widget.unit!.unitId
            : widget.unit!.id;

        response = await HttpService.updateUnitInfo(
          unitId: unitId,
          projectId: widget.projectId,
          siteLiftNo: _siteLiftNoController.text.trim(),
          unitMachineNo: _unitMachineNoController.text.trim(),

          // Optional fields
          capacity: _capacityController.text.trim(),
          speed: _selectedLiftSpeedId ?? '',
          numberOfStops: _selectedStopsId ?? '',
          numberOfOpening: _selectedOpeningsId ?? '',
          travelHeight: _travelHeightController.text.trim(),
          doorSize: _doorSizeController.text.trim(),
          doorTypeId: _selectedDoorTypeId ?? '',
          doorModelId: _selectedDoorModelId ?? '',
          machineRoomTypeId: _selectedMachineRoomTypeId ?? '',
          typeId: _selectedLiftTypeId ?? '',
          productModelName: _productModelNameController.text.trim(),

          // Optional - no !
          standardType: _selectedStandardType?.toLowerCase() ?? '',

          statusId: _selectedStatusId ?? '',
          startDate: _startDateController.text.trim(),
          endDate: _plannedFinishController.text.trim(),
          actualFinish: _actualFinishController.text.trim(),
          totalManpower: _totalManpowerController.text.trim(),

          // Optional - no !
          methodOfInstallation: _selectedMethodId ?? '',

          activity: activityData,
        );
      } else {
        response = await HttpService.addUnitInfo(
          projectId: widget.projectId,
          siteLiftNo: _siteLiftNoController.text.trim(),
          unitMachineNo: _unitMachineNoController.text.trim(),

          // Optional fields
          capacity: _capacityController.text.trim(),
          speed: _selectedLiftSpeedId ?? '',
          numberOfStops: _selectedStopsId ?? '',
          numberOfOpening: _selectedOpeningsId ?? '',
          travelHeight: _travelHeightController.text.trim(),
          doorSize: _doorSizeController.text.trim(),
          doorTypeId: _selectedDoorTypeId ?? '',
          doorModelId: _selectedDoorModelId ?? '',
          machineRoomTypeId: _selectedMachineRoomTypeId ?? '',
          typeId: _selectedLiftTypeId ?? '',
          productModelName: _productModelNameController.text.trim(),

          // Optional - no !
          standardType: _selectedStandardType?.toLowerCase() ?? '',

          statusId: _selectedStatusId ?? '',
          startDate: _startDateController.text.trim(),
          endDate: _plannedFinishController.text.trim(),
          actualFinish: _actualFinishController.text.trim(),
          totalManpower: _totalManpowerController.text.trim(),

          // Optional - no !
          methodOfInstallation: _selectedMethodId ?? '',

          activity: activityData,
        );
      }

      print('===== API RETURNED =====');
      print('response: $response');

      if (!mounted) return;

      if (response['status'] == true) {
        setState(() {
          _isSaving = false;
        });

        _showMessage(
          response['message']?.toString() ??
              (widget.isEdit
                  ? 'Unit information updated successfully'
                  : 'Unit information added successfully'),
        );

        Navigator.pop(context, true);
        return;
      }

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        response['message']?.toString() ??
            (widget.isEdit
                ? 'Failed to update unit information'
                : 'Failed to add unit information'),
        isError: true,
      );
    } catch (e) {
      print('SAVE UNIT INFORMATION ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        widget.isEdit
            ? 'Failed to update unit information'
            : 'Failed to add unit information',
        isError: true,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Text field
  // ---------------------------------------------------------------------------

  Widget _textField({
    required String label,
    required TextEditingController controller,
    bool requiredField = false,
    TextInputType? keyboardType,
    String? hint,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: _inputDecoration(
        label,
        hint: hint,
        suffixIcon: onTap != null
            ? const Icon(
                Icons.calendar_today_outlined,
                size: 20,
              )
            : null,
      ),
      validator: requiredField
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }

              return null;
            }
          : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Dropdown
  // ---------------------------------------------------------------------------

  Widget _dropdownField({
    required String label,
    required List<UnitDropdownItem> items,
    required String? selectedId,
    required ValueChanged<String?> onChanged,
    bool requiredField = false,
  }) {
    final validSelectedId = _findItemById(
      items,
      selectedId,
    );

    return DropdownButtonFormField<String>(
      value: validSelectedId?.id,
      isExpanded: true,
      decoration: _inputDecoration(label),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item.id,
          child: Text(
            item.name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      validator: requiredField
          ? (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }

              return null;
            }
          : null,
    );
  }

  Widget _standardDropdown() {
    final hasMatch = _standardTypes.contains(_selectedStandardType);

    return DropdownButtonFormField<String>(
      value: hasMatch ? _selectedStandardType : null,
      isExpanded: true,
      decoration: _inputDecoration(
        'Standard or Non Standard',
      ),
      items: _standardTypes.map((value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStandardType = value;
        });
      },
    );
  }

  Widget _statusDropdown() {
    return _dropdownField(
      label: 'Current Status',
      items: _statuses,
      selectedId: _selectedStatusId,
      onChanged: (value) {
        setState(() {
          _selectedStatusId = value;
          print('status id $_selectedStatusId');
        });
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Installation Method Dropdown
  // ---------------------------------------------------------------------------

  Widget _installationMethodDropdown() {
    final List<InstallationMethodItem> displayMethods =
        List.from(_installationMethods);

    if (widget.isEdit &&
        widget.unit != null &&
        _selectedMethodId != null &&
        _selectedMethodId!.isNotEmpty) {
      final exists =
          displayMethods.any((m) => m.methodId == _selectedMethodId);
      if (!exists) {
        displayMethods.add(
          InstallationMethodItem(
            methodId: _selectedMethodId!,
            methodName: widget.unit!.methodName.isNotEmpty
                ? widget.unit!.methodName
                : 'Method $_selectedMethodId',
          ),
        );
      }
    }

    final hasMatch =
        displayMethods.any((m) => m.methodId == _selectedMethodId);

    return DropdownButtonFormField<String>(
      value: hasMatch ? _selectedMethodId : null,
      isExpanded: true,
      decoration: _inputDecoration(
        'Method of Installation',
      ),
      items: displayMethods.map((method) {
        return DropdownMenuItem<String>(
          value: method.methodId,
          child: Text(
            method.methodName,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (widget.isEdit || _loadingMethods)
          ? null
          : _onInstallationMethodChanged,
    );
  }

  // ---------------------------------------------------------------------------
  // Activity Card
  // ---------------------------------------------------------------------------

  Widget _activityCard(
    MethodActivityItem activity,
    int index,
  ) {
    final percentageController =
        _activityPercentageControllers[activity.activityKey];

    final currentStatus = _activityStatuses[activity.activityKey];

    final startDate = _activityStartDates[activity.activityKey];

    final completedDate = _activityCompletedDates[activity.activityKey];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  activity.activityName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status
          DropdownButtonFormField<String>(
            value: _activityStatusOptions
                    .any((item) => item['value'] == currentStatus)
                ? currentStatus
                : null,
            isExpanded: true,
            decoration: _inputDecoration(
              'Status',
            ),
            items: _activityStatusOptions.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(
                  item['label'] ?? '',
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _activityStatuses[activity.activityKey] = value;
              });
            },
          ),

          const SizedBox(height: 12),

          // Percentage
          TextFormField(
            controller: percentageController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: _inputDecoration(
              'Percentage',
              hint: '0 - 100',
            ),
          ),

          const SizedBox(height: 12),

          // Start Date
          TextFormField(
            readOnly: true,
            controller: TextEditingController(
              text: startDate ?? '',
            ),
            onTap: () {
              _selectDate(
                activityKey: activity.activityKey,
                isStartDate: true,
              );
            },
            decoration: _inputDecoration(
              'Start Date',
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Completed Date
          TextFormField(
            readOnly: true,
            controller: TextEditingController(
              text: completedDate ?? '',
            ),
            onTap: () {
              _selectDate(
                activityKey: activity.activityKey,
                isStartDate: false,
              );
            },
            decoration: _inputDecoration(
              'Completed Date',
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section
  // ---------------------------------------------------------------------------

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: Text(
          widget.isEdit ? 'Edit Unit Information' : 'Add Unit Information',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoadingDropdowns
          ? const Center(
              child: CircularProgressIndicator(
                color: _primary,
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ---------------------------------------------------------
                    // Basic Unit Information
                    // ---------------------------------------------------------

                    _sectionCard(
                      title: 'Unit Information',
                      children: [
                        _textField(
                          label: 'Site Lift No',
                          controller: _siteLiftNoController,
                          requiredField: true,
                          readOnly: widget.isEdit,
                        ),
                        const SizedBox(height: 14),
                        _textField(
                          label: 'Unit / Machine No',
                          controller: _unitMachineNoController,
                          requiredField: true,
                          readOnly: widget.isEdit,
                        ),
                        const SizedBox(height: 14),
                        _textField(
                          label: 'Capacity',
                          controller: _capacityController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        _dropdownField(
                          label: 'Lift Speed',
                          items: _liftSpeeds,
                          selectedId: _selectedLiftSpeedId,
                          onChanged: (value) {
                            setState(() {
                              _selectedLiftSpeedId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _dropdownField(
                          label: 'Number of Stops',
                          items: _stops,
                          selectedId: _selectedStopsId,
                          onChanged: (value) {
                            setState(() {
                              _selectedStopsId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _dropdownField(
                          label: 'Number of Openings',
                          items: _openings,
                          selectedId: _selectedOpeningsId,
                          onChanged: (value) {
                            setState(() {
                              _selectedOpeningsId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _textField(
                          label: 'Travel Height',
                          controller: _travelHeightController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),

                    // ---------------------------------------------------------
                    // Door / Machine Information
                    // ---------------------------------------------------------

                    _sectionCard(
                      title: 'Door & Machine Information',
                      children: [
                        _textField(
                          label: 'Door Size',
                          controller: _doorSizeController,
                        ),
                        const SizedBox(height: 14),
                        _dropdownField(
                          label: 'Door Type',
                          items: _doorTypes,
                          selectedId: _selectedDoorTypeId,
                          onChanged: (value) {
                            setState(() {
                              _selectedDoorTypeId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _dropdownField(
                          label: 'Door Model',
                          items: _doorModels,
                          selectedId: _selectedDoorModelId,
                          onChanged: (value) {
                            setState(() {
                              _selectedDoorModelId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _dropdownField(
                          label: 'Machine Room Type',
                          items: _machineRoomTypes,
                          selectedId: _selectedMachineRoomTypeId,
                          onChanged: (value) {
                            setState(() {
                              _selectedMachineRoomTypeId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _dropdownField(
                          label: 'Lift Type',
                          items: _liftTypes,
                          selectedId: _selectedLiftTypeId,
                          onChanged: (value) {
                            setState(() {
                              _selectedLiftTypeId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _textField(
                          label: 'Product Model Name',
                          controller: _productModelNameController,
                        ),
                        const SizedBox(height: 14),
                        _standardDropdown(),
                        const SizedBox(height: 14),
                        _statusDropdown(),
                      ],
                    ),

                    // ---------------------------------------------------------
                    // Dates
                    // ---------------------------------------------------------

                    _sectionCard(
                      title: 'Dates',
                      children: [
                        _textField(
                          label: 'Start Date',
                          controller: _startDateController,
                          readOnly: true,
                          onTap: () {
                            _selectNormalDate(
                              controller: _startDateController,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _textField(
                          label: 'Planned Finish',
                          controller: _plannedFinishController,
                          readOnly: true,
                          onTap: () {
                            _selectNormalDate(
                              controller: _plannedFinishController,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _textField(
                          label: 'Actual Finish',
                          controller: _actualFinishController,
                          readOnly: true,
                          onTap: () {
                            _selectNormalDate(
                              controller: _actualFinishController,
                            );
                          },
                        ),
                      ],
                    ),

                    // ---------------------------------------------------------
                    // Method of Installation
                    // ---------------------------------------------------------

                    _sectionCard(
                      title: 'Method of Installation',
                      children: [
                        _installationMethodDropdown(),
                      ],
                    ),

                    // ---------------------------------------------------------
                    // Activities
                    // ---------------------------------------------------------

                    if (_loadingActivities)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          vertical: 28,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Column(
                          children: [
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: _primary,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Loading installation activities...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (!_loadingActivities &&
                        _installationActivities.isNotEmpty)
                      _sectionCard(
                        title: 'Installation Activities',
                        children: [
                          ...List.generate(
                            _installationActivities.length,
                            (index) {
                              return _activityCard(
                                _installationActivities[index],
                                index,
                              );
                            },
                          ),
                        ],
                      ),

                    if (_selectedMethodId != null &&
                        _installationActivities.isEmpty &&
                        !_loadingMethods)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'No activities available for the selected installation method.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),

                    // ---------------------------------------------------------
                    // Save
                    // ---------------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveUnitInformation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.isEdit ? 'Update Unit' : 'Save Unit',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
