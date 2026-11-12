import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/assignedWorkStatusModel.dart';
import 'package:login2/models/lead_management/priorityStatusModel.dart';
import 'package:login2/models/lead_management/taskStatusModel.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import 'package:login2/widgets/timer_widget.dart';

import '../../core/common.dart';
import '../../models/lead_management/projectList_model.dart';
import '../../models/lead_management/titleListModel.dart';
import '../../models/lead_management/workstatus_model.dart';
import '../../service/service.dart';
import 'package:login2/models/expense/staffListModel.dart';

class TaskForm {
  TextEditingController controller;
  String? status;
  String? taskId;
  String? activityId;
  List<TextEditingController> remarksControllers;
  bool isChecked;
  double completion;

  TaskForm({
    required this.controller,
    this.status,
    this.taskId,
    this.activityId,
    List<TextEditingController>? remarks,
    this.isChecked = false,
    this.completion = 0.0,
  }) : remarksControllers = remarks ?? [TextEditingController()] {
    if (remarksControllers.isEmpty) {
      remarksControllers.add(TextEditingController());
    }
  }
}

class DelayTypeItem {
  final String id;
  final String name;

  DelayTypeItem({required this.id, required this.name});

  factory DelayTypeItem.fromJson(Map<String, dynamic> json) {
    return DelayTypeItem(
      id: json['status_id']?.toString() ??
          json['delay_type_id']?.toString() ??
          json['id']?.toString() ??
          '',
      name: json['status_name']?.toString() ??
          json['delay_type_name']?.toString() ??
          json['name']?.toString() ??
          json['title']?.toString() ??
          '',
    );
  }
}

class LooseTypeItem {
  final String id;
  final String name;

  LooseTypeItem({required this.id, required this.name});

  factory LooseTypeItem.fromJson(Map<String, dynamic> json) {
    return LooseTypeItem(
      id: json['loose_type_id']?.toString() ??
          json['status_id']?.toString() ??
          json['id']?.toString() ??
          '',
      name: json['loose_type_name']?.toString() ??
          json['status_name']?.toString() ??
          json['name']?.toString() ??
          json['title']?.toString() ??
          '',
    );
  }
}

class AddWorkPage extends StatefulWidget {
  final String workId;
  final WorkStatus? existingWork;
  final Function() onSuccess;
  final int isPaused;
  final int Restart;
  final int isAssigned;
  const AddWorkPage({
    super.key,
    required this.workId,
    this.existingWork,
    required this.onSuccess,
    this.isPaused = 0,
    this.Restart = 0,
    this.isAssigned = 0,
  });

  @override
  _AddWorkPageState createState() => _AddWorkPageState();
}

class _AddWorkPageState extends State<AddWorkPage> {
  late TextEditingController titleController;
  late List<TaskForm> tasks;
  String? selectedProjectId;
  String? selectedProjectName;
  String? selectedTitleId;
  DateTime? dueDate;
  String? priority;
  String? assignedTo;
  String? sectionId;
  DateTime? currentDate;
  String? ProjectDashboardPermission;
  final TextEditingController _searchController = TextEditingController();
  List<Projects> _filteredProjects = [];
  bool _isSearching = false;
  List<Projects> projectList = [];
  List<TitleListDet> titleList = [];
  bool isLoading = true;
  final TextEditingController search = TextEditingController();
  final TextEditingController selectedProjectController =
      TextEditingController();
  List<dynamic> filteredNames = [];
  List<dynamic> filteredTemplates = [];
  List<Projects> filteredProjects = [];
  List<dynamic> filteredProducts = [];
  dynamic customerNameExisting = TextEditingController();
  dynamic customerIdExisting;
  dynamic remindMeExisting = TextEditingController();
  dynamic templateIdExisting;
  dynamic productIdExisting;
  dynamic productNameExisting = TextEditingController();
  dynamic prodRateExisting = TextEditingController();
  dynamic prodTaxExisting = TextEditingController();
  dynamic typeDuration;
  bool isLocationEnabled = false;
  bool _isGettingLocation = false;
  double? currentLatitude;
  double? currentLongitude;
  String? currentAddress;
  void filterCustomers(String value) {}
  void filterTemplates(String value) {}
  void filterProjects(String value) {}
  void filterProducts(String value) {}
  void calculateTotalExisting() {}
  late String token;
  late String userId;
  String? addWorkModule;
  List<Staff> staffList = [];
  List<TaskState> allTaskStates = [];
  List<PrioState> allPriorities = [];
  AssignedWorkStatus? assignedWorks;

  String? selectedUnitNo;
  String? selectedSiteLiftNo;

  // Is Delay section state
  bool isDelay = false;
  bool hasAssignedDelay = false;
  String? selectedDelayType;
  String? selectedLooseType;
  String? previousTimeline;
  final TextEditingController responsiblePartyController =
      TextEditingController();
  final TextEditingController hoursController = TextEditingController();

  Future<void> _selectHours(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final String formattedHours =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        hoursController.text = formattedHours;
      });
    }
  }

  // Upload File state
  File? uploadedFile;
  String? uploadedFileName;
  List<File> uploadedFiles = [];

  void _syncUploadedFilesState() {
    if (uploadedFiles.isEmpty) {
      uploadedFile = null;
      uploadedFileName = null;
    } else {
      uploadedFile = uploadedFiles.first;
      uploadedFileName = uploadedFiles
          .map((f) => f.path.split(Platform.pathSeparator).last)
          .join(', ');
    }
  }

  bool _isImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.bmp') ||
        lower.endsWith('.heic');
  }

  Future<void> _capturePhotoFromCamera() async {
    try {
      final XFile? photo =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          final file = File(photo.path);
          if (!uploadedFiles.any((f) => f.path == file.path)) {
            uploadedFiles.add(file);
          }
          _syncUploadedFilesState();
        });
      }
    } catch (e) {
      log('Error capturing photo: $e');
    }
  }

  void _removeUploadedFile(int index) {
    if (index < 0 || index >= uploadedFiles.length) return;
    setState(() {
      uploadedFiles.removeAt(index);
      _syncUploadedFilesState();
    });
  }

  void _showImagePreviewDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedFilesPreview() {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: uploadedFiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final file = uploadedFiles[index];
          final fileName = file.path.split(Platform.pathSeparator).last;
          final isImage = _isImageFile(file.path);

          return Stack(
            children: [
              GestureDetector(
                onTap: isImage ? () => _showImagePreviewDialog(file) : null,
                child: Container(
                  width: isImage ? 84 : 140,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: isImage
                      ? Image.file(
                          file,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey.shade500,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.insert_drive_file_outlined,
                                color: Colors.blue.shade700,
                                size: 26,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fileName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeUploadedFile(index),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<DelayTypeItem> delayTypeList = [];
  List<LooseTypeItem> looseTypeList = [];
  bool isLoadingDelayTypes = false;
  bool isLoadingLooseTypes = false;
  bool _isStartingWork = false;
  bool _isStoppingWork = false;
  bool _isRestartingWork = false;
  bool _isSavingWork = false;
  bool _submitWorkSucceeded = false;
  bool _saveWorkSucceeded = false;
  bool _restartWorkSucceeded = false;

  bool get isStopWork =>
      widget.existingWork != null &&
      widget.isPaused != 1 &&
      widget.Restart != 1;

  bool get isStartOrRestartWork =>
      widget.existingWork == null || widget.Restart == 1;

  String selectedWorkCategory = 'site'; // 'site' = Site Work (2), 'office' = Office Work (1)
  bool get _isOfficeWork => selectedWorkCategory == 'office';

  void _applyStaffType(
    String? rawStaffType, {
    String? projectId,
    String? projectName,
  }) {
    final st = rawStaffType?.trim().toLowerCase() ?? '';
    if (st == '1' ||
        st == 'office' ||
        st == 'office_work' ||
        st == 'office work') {
      selectedWorkCategory = 'office';
      isDelay = false;
    } else if (st == '2' ||
        st == 'site' ||
        st == 'site_work' ||
        st == 'site work') {
      selectedWorkCategory = 'site';
    } else if (st.isEmpty || st == '0' || st == 'null') {
      final pid = projectId?.trim() ?? '';
      if ((pid.isEmpty || pid == '0' || pid.toLowerCase() == 'null') &&
          (widget.existingWork != null || assignedWorks != null)) {
        selectedWorkCategory = 'office';
        isDelay = false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('Work is paused? ${widget.isPaused == 1 ? "Yes" : "No"}');
    debugPrint('Work is restarted? ${widget.Restart == 1 ? "Yes" : "No"}');

    titleController = TextEditingController(
      text: widget.existingWork?.title_name ?? '',
    );
    _searchController.addListener(_filterProjects);
    tasks = widget.existingWork != null
        ? widget.existingWork!.tasks
            .map((task) => TaskForm(
                  controller: TextEditingController(text: task.taskName),
                  status: task.status,
                  taskId: task.taskId,
                  activityId: task.activityId ?? task.taskId,
                  isChecked: task.status == '4',
                  completion: double.tryParse(task.completion) ??
                      (task.status == '4' ? 100.0 : 10.0),
                  remarks: task.remarks
                      .map((remark) => TextEditingController(text: remark))
                      .toList(),
                ))
            .toList()
        : [
            TaskForm(
              controller: TextEditingController(),
              status: allTaskStates.isNotEmpty ? allTaskStates.first.id : null,
              taskId: null,
              completion: 0.0,
              remarks: [TextEditingController()],
            )
          ];

    if (widget.existingWork != null) {
      selectedProjectId = widget.existingWork!.projectId;
      selectedTitleId = widget.existingWork!.title;
      dueDate = widget.existingWork!.dueDate;
      priority = widget.existingWork!.priority;
      assignedTo = widget.existingWork!.assignedTo;
      selectedUnitNo = (widget.existingWork?.unitName?.isNotEmpty == true)
          ? widget.existingWork!.unitName
          : widget.existingWork?.unitNo;
      selectedSiteLiftNo = (widget.existingWork?.siteLiftName?.isNotEmpty == true)
          ? widget.existingWork!.siteLiftName
          : widget.existingWork?.siteLiftNo;
      if (widget.existingWork!.projectName != null &&
          widget.existingWork!.projectName!.isNotEmpty) {
        selectedProjectName = widget.existingWork!.projectName;
        selectedProjectController.text = widget.existingWork!.projectName!;
      }
      if (selectedProjectId == "0" ||
          (selectedProjectId != null && selectedProjectId!.isEmpty)) {
        selectedProjectId = null;
      }
      final rawExistingStaffType = widget.existingWork!.staffType ??
          (widget.existingWork!.tasks.isNotEmpty
              ? widget.existingWork!.tasks.first.staffType
              : null);
      _applyStaffType(
        rawExistingStaffType,
        projectId: widget.existingWork!.projectId,
        projectName: widget.existingWork!.projectName,
      );
      if (!_isOfficeWork && widget.existingWork!.tasks.isNotEmpty) {
        final firstTask = widget.existingWork!.tasks.first;
        if (firstTask.isDelay == 'Y' || firstTask.isDelay == '1') {
          hasAssignedDelay = true;
          isDelay = true;
          selectedDelayType = firstTask.delayTypeId;
          selectedLooseType = firstTask.looseTypeId;
          if (firstTask.responsibleParty != null &&
              firstTask.responsibleParty!.isNotEmpty) {
            responsiblePartyController.text = firstTask.responsibleParty!;
          }
          if (firstTask.hours != null && firstTask.hours!.isNotEmpty) {
            hoursController.text = firstTask.hours!;
          }
          if (firstTask.previousTimeline != null &&
              firstTask.previousTimeline!.isNotEmpty) {
            previousTimeline = firstTask.previousTimeline;
          } else if (widget.existingWork!.previousTimeline != null &&
              widget.existingWork!.previousTimeline!.isNotEmpty) {
            previousTimeline = widget.existingWork!.previousTimeline;
          }
        }
      }
    }

    _initAsync();
    _loadStaffs();
    _loadTaskState();
    _loadPrioState();
    _loadDelayTypes();
    _loadLooseTypes();
    checkAssignedWorks();
  }

  void _initAsync() async {
    token = await Common.getSharedPref("token") ?? "";
    userId = await Common.getSharedPref("userId");
    addWorkModule = await Common.getSharedPref("addWorkModule");
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    await _loadProjects();
    if (assignedTo == null) {
      setState(() {
        assignedTo = userId;
      });
    }
  }

  Future<void> _loadDelayTypes() async {
    if (!mounted) return;
    setState(() => isLoadingDelayTypes = true);
    try {
      final res = await HttpService.getDelayTypes();
      if (res != null && mounted) {
        final List<dynamic> list = (res is Map && res['data'] != null)
            ? res['data']
            : (res is List ? res : []);
        setState(() {
          delayTypeList = list
              .map((item) =>
                  DelayTypeItem.fromJson(Map<String, dynamic>.from(item)))
              .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
              .toList();
          if (selectedDelayType != null && selectedDelayType!.isNotEmpty) {
            final match = delayTypeList.firstWhere(
              (t) =>
                  t.id == selectedDelayType ||
                  t.name.toLowerCase() == selectedDelayType!.toLowerCase(),
              orElse: () => DelayTypeItem(
                  id: selectedDelayType!, name: selectedDelayType!),
            );
            selectedDelayType = match.id;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading delay types: $e');
    } finally {
      if (mounted) setState(() => isLoadingDelayTypes = false);
    }
  }

  Future<void> _loadLooseTypes() async {
    if (!mounted) return;
    setState(() => isLoadingLooseTypes = true);
    try {
      final res = await HttpService.getLooseTypes();
      if (res != null && mounted) {
        final List<dynamic> list = (res is Map && res['data'] != null)
            ? res['data']
            : (res is List ? res : []);
        setState(() {
          looseTypeList = list
              .map((item) =>
                  LooseTypeItem.fromJson(Map<String, dynamic>.from(item)))
              .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
              .toList();
          if (selectedLooseType != null && selectedLooseType!.isNotEmpty) {
            final match = looseTypeList.firstWhere(
              (t) =>
                  t.id == selectedLooseType ||
                  t.name.toLowerCase() == selectedLooseType!.toLowerCase(),
              orElse: () => LooseTypeItem(
                  id: selectedLooseType!, name: selectedLooseType!),
            );
            selectedLooseType = match.id;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading loose types: $e');
    } finally {
      if (mounted) setState(() => isLoadingLooseTypes = false);
    }
  }

  bool _validateTasks() {
    bool atLeastOneChecked =
        tasks.any((task) => task.status == '4' || task.isChecked);
    if (tasks.isEmpty ||
        !tasks.any((task) => task.controller.text.trim().isNotEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one task to proceed'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return false;
    }

    if (!atLeastOneChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please check at least one task to proceed'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return false;
    }

    // Check if mandatory descriptions (remarks) are provided for checked/completed tasks
    // User requested mandatory only for Save Work and Stop Work
    bool isSaveOrStopWork = widget.existingWork != null &&
        widget.Restart != 1 &&
        widget.isPaused != 1;

    if (isSaveOrStopWork) {
      for (int i = 0; i < tasks.length; i++) {
        if (tasks[i].isChecked || tasks[i].status == '4') {
          bool hasRemark = tasks[i]
              .remarksControllers
              .any((controller) => controller.text.trim().isNotEmpty);
          if (!hasRemark) {
            String label = widget.Restart == 1
                ? 'remark'
                : (widget.existingWork != null &&
                        widget.isPaused != 1 &&
                        widget.Restart != 1)
                    ? 'remark'
                    : 'description';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Please provide a $label for task: ${tasks[i].controller.text.isEmpty ? (i + 1) : tasks[i].controller.text}'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            return false;
          }
        }
      }
    }
    return true;
  }

  Future<void> checkAssignedWorks() async {
    final String effectiveWorkId = widget.workId.isNotEmpty
        ? widget.workId
        : (widget.existingWork?.assignedId != null &&
                widget.existingWork!.assignedId!.isNotEmpty &&
                widget.existingWork!.assignedId != "0"
            ? widget.existingWork!.assignedId!
            : "");
    if (effectiveWorkId.isEmpty) return;

    final AssignedWorkModel =
        await HttpService.getAssinedWorkStatus(effectiveWorkId, sectionId = "");
    setState(() {
      if (AssignedWorkModel != null && AssignedWorkModel.data.isNotEmpty) {
        assignedWorks = AssignedWorkModel.data.first;

        final rawStaffType = assignedWorks?.staffType ??
            (assignedWorks?.tasks.isNotEmpty == true
                ? assignedWorks!.tasks.first.staffType
                : null);
        _applyStaffType(
          rawStaffType,
          projectId: assignedWorks?.projectId,
          projectName: assignedWorks?.projectName,
        );

        final rawIsDelay = assignedWorks?.isDelay ??
            (assignedWorks?.tasks.isNotEmpty == true
                ? assignedWorks!.tasks.first.isDelay
                : null);
        final rawDelayType = assignedWorks?.delayTypeId ??
            (assignedWorks?.tasks.isNotEmpty == true
                ? assignedWorks!.tasks.first.delayTypeId
                : null);
        final rawLooseType = assignedWorks?.looseTypeId ??
            (assignedWorks?.tasks.isNotEmpty == true
                ? assignedWorks!.tasks.first.looseTypeId
                : null);
        final rawRespParty = assignedWorks?.responsibleParty ??
            (assignedWorks?.tasks.isNotEmpty == true
                ? assignedWorks!.tasks.first.responsibleParty
                : null);
        final rawHours = assignedWorks?.delayHours ??
            (assignedWorks?.tasks.isNotEmpty == true
                ? (assignedWorks!.tasks.first.delayHours ??
                    assignedWorks!.tasks.first.hours)
                : null);
        final rawPrevTimeline = assignedWorks?.previousTimeline ??
            (assignedWorks?.tasks.isNotEmpty == true
                ? assignedWorks!.tasks.first.previousTimeline
                : null);

        if (rawPrevTimeline != null && rawPrevTimeline.isNotEmpty) {
          previousTimeline = rawPrevTimeline;
        }

        final bool isApiDelay = !_isOfficeWork &&
            rawIsDelay != null &&
            (rawIsDelay.trim().toUpperCase() == 'Y' ||
                rawIsDelay.trim() == '1' ||
                rawIsDelay.trim().toLowerCase() == 'true');
        hasAssignedDelay = isApiDelay;

        if (_isOfficeWork) {
          isDelay = false;
        } else if (isApiDelay) {
          isDelay = true;
        } else if (rawIsDelay == 'N' ||
            rawIsDelay == '0' ||
            rawIsDelay?.toLowerCase() == 'false' ||
            widget.Restart == 1) {
          isDelay = false;
        }

        if (rawDelayType != null && rawDelayType.isNotEmpty) {
          selectedDelayType = rawDelayType;
          if (delayTypeList.isNotEmpty) {
            final match = delayTypeList.firstWhere(
              (t) =>
                  t.id == selectedDelayType ||
                  t.name.toLowerCase() == selectedDelayType!.toLowerCase(),
              orElse: () => DelayTypeItem(
                  id: selectedDelayType!, name: selectedDelayType!),
            );
            selectedDelayType = match.id;
          }
        }
        if (rawLooseType != null && rawLooseType.isNotEmpty) {
          selectedLooseType = rawLooseType;
          if (looseTypeList.isNotEmpty) {
            final match = looseTypeList.firstWhere(
              (t) =>
                  t.id == selectedLooseType ||
                  t.name.toLowerCase() == selectedLooseType!.toLowerCase(),
              orElse: () => LooseTypeItem(
                  id: selectedLooseType!, name: selectedLooseType!),
            );
            selectedLooseType = match.id;
          }
        }
        if (rawRespParty != null && rawRespParty.isNotEmpty) {
          responsiblePartyController.text = rawRespParty;
        }
        if (rawHours != null && rawHours.isNotEmpty) {
          hoursController.text = rawHours;
        }

        if (widget.existingWork == null) {
          titleController.text = assignedWorks?.titleName ?? '';
          selectedProjectId = assignedWorks?.projectId;
          if (selectedProjectId == "0" ||
              (selectedProjectId != null && selectedProjectId!.isEmpty)) {
            selectedProjectId = null;
          }
          selectedProjectName = assignedWorks?.projectName;
          selectedTitleId = assignedWorks?.title;
          dueDate = assignedWorks?.dueDate;
          priority = assignedWorks?.priority;
          assignedTo = assignedWorks?.assignedTo;

          if (selectedProjectName != null) {
            selectedProjectController.text = selectedProjectName!;
          }
          selectedUnitNo = (assignedWorks?.unitName?.isNotEmpty == true)
              ? assignedWorks!.unitName
              : assignedWorks?.unitNo;
          selectedSiteLiftNo = (assignedWorks?.siteLiftName?.isNotEmpty == true)
              ? assignedWorks!.siteLiftName
              : assignedWorks?.siteLiftNo;
          tasks = (assignedWorks?.tasks ?? [])
              .map((task) => TaskForm(
                    controller: TextEditingController(text: task.taskName),
                    status: task.status,
                    taskId: task.taskId,
                    activityId: task.activityId ?? task.taskId,
                    isChecked: task.status == '4',
                    completion: double.tryParse(task.completion) ??
                        (task.status == '4' ? 100.0 : 10.0),
                    remarks: task.remarks.isNotEmpty
                        ? task.remarks
                            .map(
                                (remark) => TextEditingController(text: remark))
                            .toList()
                        : [TextEditingController()],
                  ))
              .toList();

          if (tasks.isEmpty) {
            tasks.add(TaskForm(
              controller: TextEditingController(),
              status: allTaskStates.isNotEmpty ? allTaskStates.first.id : null,
              remarks: [TextEditingController()],
            ));
          }
        }
      } else {
        assignedWorks = null;
        tasks = [
          TaskForm(
            controller: TextEditingController(),
            status: allTaskStates.isNotEmpty ? allTaskStates.first.id : null,
            remarks: [TextEditingController()],
          )
        ];
      }
    });

    if (selectedProjectId != null) {
      await _loadTitle();
    }
  }

  Future<void> _loadProjects() async {
    try {
      final response = await HttpService.getProjectList();
      setState(() {
        projectList = response!.data;

        final uniqueProjects = <String, Projects>{};
        for (var project in projectList) {
          uniqueProjects[project.id] = project;
        }
        projectList = uniqueProjects.values.toList();
        filteredProjects = List.from(projectList);

        if (selectedProjectId != null) {
          final exists = projectList.any((p) => p.id == selectedProjectId);
          if (!exists && widget.existingWork == null && assignedWorks == null) {
            selectedProjectId = null;
          }
          _loadTitle();
        }

        if (selectedProjectId != null && projectList.any((p) => p.id == selectedProjectId)) {
          final selectedProject =
              projectList.firstWhere((p) => p.id == selectedProjectId);

          selectedProjectName = selectedProject.name;
          selectedProjectController.text = selectedProject.name;
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        selectedProjectId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load projects: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _loadTitle() async {
    if (selectedProjectId == null) return;
    try {
      final response = await HttpService.getTitleList(selectedProjectId!);
      setState(() {
        titleList = response!.data;
        if (widget.existingWork == null &&
            selectedTitleId != null &&
            selectedTitleId!.isNotEmpty) {
          final matched = titleList.where((t) => t.id == selectedTitleId);
          if (matched.isNotEmpty) {
            titleController.text = matched.first.name;
          }
        }
        if (widget.existingWork != null &&
            widget.existingWork!.title.isNotEmpty) {
          final matchedTitle = titleList.firstWhere(
            (title) => title.id == widget.existingWork!.title,
            orElse: () => TitleListDet(
                id: widget.existingWork!.title,
                name: widget.existingWork!.title),
          );
          selectedTitleId = matchedTitle.id;
          titleController.text = matchedTitle.name;
          if (!titleList.any((t) => t.id == matchedTitle.id)) {
            titleList.add(matchedTitle);
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading titles: $e');
    }
  }

  Future<void> _loadStaffs() async {
    final response = await HttpService.getStaffs();
    if (response != null && response.status == true) {
      setState(() {
        staffList = response.data;
        if (assignedTo == null) {
          if (staffList.any((staff) => staff.id == userId)) {
            assignedTo = userId;
          }
        }
      });
    }
  }

  Future<void> _loadTaskState() async {
    final response = await HttpService.getTaskState();
    if (response != null && response.status == true) {
      setState(() {
        allTaskStates = response.data;
      });
      log("✅ Task States Loaded: ${allTaskStates.length}");
      for (var t in allTaskStates) {
        log("TaskState: id=${t.id}, status=${t.status}");
      }
    } else {
      log("❌ Failed to load task states or status is false");
    }
  }

  Future<void> _loadPrioState() async {
    final response = await HttpService.getPrioState();
    if (response != null && response.status == true) {
      setState(() {
        allPriorities = response.data;
        if (priority == null && allPriorities.isNotEmpty) {
          final highPriority = allPriorities.firstWhere(
            (p) => p.priority.toLowerCase() == 'high',
            orElse: () => allPriorities.first,
          );
          priority = highPriority.id;
        }
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String? resolvedAddress;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 5));
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = <String>[];
          void addPart(String? value) {
            if (value != null) {
              final trimmed = value.trim();
              if (trimmed.isNotEmpty && !parts.contains(trimmed)) {
                parts.add(trimmed);
              }
            }
          }

          addPart(place.name);
          addPart(place.street);
          addPart(place.subLocality);
          addPart(place.locality);
          addPart(place.subAdministrativeArea);
          addPart(place.administrativeArea);
          addPart(place.postalCode);
          addPart(place.country);

          resolvedAddress = parts.join(', ');
        }
      } catch (e) {
        debugPrint('Error getting address: $e');
      }

      if (mounted) {
        setState(() {
          currentLatitude = position.latitude;
          currentLongitude = position.longitude;
          currentAddress = resolvedAddress;
        });
      } else {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
        currentAddress = resolvedAddress;
      }
      debugPrint(
          'Lat: ${position.latitude}, Long: ${position.longitude}, Address: $currentAddress');
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var task in tasks) {
      task.controller.dispose();
      for (var remark in task.remarksControllers) {
        remark.dispose();
      }
    }
    _searchController.dispose();
    super.dispose();
  }

  void _filterProjects() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProjects = projectList.where((project) {
        return project.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void filterProjectsDialog(String query) {
    setState(() {
      filteredProjects = projectList
          .where((project) =>
              project.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredProjects = projectList;
      }
    });
  }

  void _addDescriptionField(int taskIndex) {
    setState(() {
      tasks[taskIndex].remarksControllers.add(TextEditingController());
    });
  }

  void _removeDescriptionField(int taskIndex, int remarkIndex) {
    if (tasks[taskIndex].remarksControllers.length > 1) {
      setState(() {
        tasks[taskIndex].remarksControllers.removeAt(remarkIndex);
      });
    }
  }

  Future<void> _submitWork() async {
    final bool isStopAction = widget.existingWork != null;
    if (isStopAction) {
      if (_isStoppingWork) return;
      setState(() => _isStoppingWork = true);
    } else {
      if (_isStartingWork) return;
      setState(() => _isStartingWork = true);
    }
    _submitWorkSucceeded = false;
    try {
      await _performSubmitWork();
    } finally {
      if (!_submitWorkSucceeded && mounted) {
        setState(() {
          if (isStopAction) {
            _isStoppingWork = false;
          } else {
            _isStartingWork = false;
          }
        });
      }
    }
  }

  Future<void> _performSubmitWork() async {
    if (widget.existingWork == null) {
      final loginResponse = await HttpService.getCurrentLoginStatus();
      if (loginResponse == null ||
          loginResponse.status != true ||
          loginResponse.data != true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please login first.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
    }
    if (!_validateTasks()) return;

    if (!_isOfficeWork && selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a project'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (_isGettingLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please wait, fetching location...'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (isLocationEnabled &&
        (currentLatitude == null || currentLongitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location not available yet.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (!_isOfficeWork &&
        (selectedTitleId == null ||
            selectedTitleId!.isEmpty ||
            titleController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a title'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    await _getCurrentLocation();

    final workData = {
      'work_id': widget.existingWork?.id,
      'staff_type': _isOfficeWork ? 1 : 2,
      'staff_type_name': _isOfficeWork ? 1 : 2,
      'project_id': _isOfficeWork ? null : selectedProjectId,
      'project_name': _isOfficeWork ? null : selectedProjectName,
      'unit_no': selectedUnitNo ?? widget.existingWork?.unitNo ?? assignedWorks?.unitNo,
      'site_lift_no': selectedSiteLiftNo ?? widget.existingWork?.siteLiftNo ?? assignedWorks?.siteLiftNo,
      'title': _isOfficeWork ? '' : titleController.text,
      'title_id': _isOfficeWork ? '' : selectedTitleId,
      'activity_id': tasks.isNotEmpty ? (tasks.first.activityId ?? tasks.first.taskId ?? '') : '',
      if (widget.workId != "") 'attendance_id': widget.workId,
      'assignedId': widget.existingWork?.assignedId,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'address': currentAddress,
      'action': widget.existingWork != null ? 'stop' : 'start',
      'is_delay': (!_isOfficeWork && isDelay) ? 'Y' : 'N',
      'delay_type': (!_isOfficeWork && isDelay) ? (selectedDelayType ?? '') : '',
      'loose_type': (!_isOfficeWork && isDelay) ? (selectedLooseType ?? '') : '',
      'responsible_party':
          (!_isOfficeWork && isDelay) ? responsiblePartyController.text : '',
      'hours': (!_isOfficeWork && isDelay) ? hoursController.text : '',
      if (uploadedFile != null) 'file': uploadedFile,
      if (uploadedFiles.isNotEmpty) 'files': uploadedFiles,
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'activity_id': task.activityId ?? task.taskId ?? '',
          'description': task.controller.text,
          'status': task.status,
          'is_checked': task.isChecked ? 1 : 0,
          'completion': task.completion.round().toString(),
          'task_description': task.remarksControllers
              .map((controller) => controller.text)
              .where((remark) => remark.isNotEmpty)
              .join('\n'),
        };
      }).toList(),
    };
    try {
      final response = widget.existingWork != null
          ?await HttpService.saveWorkData(workData)
          // await HttpService.updateWorkData(workData)
          : await HttpService.submitWorkData(workData);
      _submitWorkSucceeded = response.status;

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingWork != null
                ? 'Work stopped successfully!'
                : 'Work started successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        if (widget.existingWork != null) {
          RunningWorkTimerService.instance.clear();
        } else {
          await RunningWorkTimerService.instance.refresh();
        }
        ProjectDashboard.triggerRefresh();
        await Future.delayed(const Duration(seconds: 1));
        widget.onSuccess();
        await RunningWorkTimerService.instance.refresh();
        ProjectDashboard.triggerRefresh();
        ProjectDashboardPermission == "true"
            ? Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
              )
            : Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
              );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Operation failed'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _savework() async {
    if (_isSavingWork) return;
    setState(() => _isSavingWork = true);
    _saveWorkSucceeded = false;
    try {
      await _performSaveWork();
    } finally {
      if (!_saveWorkSucceeded && mounted) {
        setState(() => _isSavingWork = false);
      }
    }
  }

  Future<void> _performSaveWork() async {
    if (!_validateTasks()) return;
    if (!_isOfficeWork && selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a project'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    await _getCurrentLocation();
    final workData = {
      'work_id': widget.existingWork?.id,
      'staff_type': _isOfficeWork ? 1 : 2,
      'staff_type_name': _isOfficeWork ? 1 : 2,
      'project_id': _isOfficeWork ? null : selectedProjectId,
      'project_name': _isOfficeWork ? null : selectedProjectName,
      'unit_no': selectedUnitNo ?? widget.existingWork?.unitNo ?? assignedWorks?.unitNo,
      'site_lift_no': selectedSiteLiftNo ?? widget.existingWork?.siteLiftNo ?? assignedWorks?.siteLiftNo,
      'title': _isOfficeWork ? '' : titleController.text,
      'title_id': _isOfficeWork ? '' : selectedTitleId,
      'activity_id': tasks.isNotEmpty ? (tasks.first.activityId ?? tasks.first.taskId ?? '') : '',
      'assignedId': widget.existingWork?.assignedId,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'address': currentAddress,
      'action': 'save',
      'is_delay': (!_isOfficeWork && isDelay) ? 'Y' : 'N',
      'delay_type': (!_isOfficeWork && isDelay) ? (selectedDelayType ?? '') : '',
      'loose_type': (!_isOfficeWork && isDelay) ? (selectedLooseType ?? '') : '',
      'responsible_party':
          (!_isOfficeWork && isDelay) ? responsiblePartyController.text : '',
      'hours': (!_isOfficeWork && isDelay) ? hoursController.text : '',
      if (uploadedFile != null) 'file': uploadedFile,
      if (uploadedFiles.isNotEmpty) 'files': uploadedFiles,
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'activity_id': task.activityId ?? task.taskId ?? '',
          'description': task.controller.text,
          'status': task.status,
          'is_checked': task.isChecked ? 1 : 0,
          'completion': task.completion.round().toString(),
          'task_description': task.remarksControllers
              .map((controller) => controller.text)
              .where((remark) => remark.isNotEmpty)
              .join('\n'),
        };
      }).toList(),
    };
    try {
      final response = await HttpService.saveWorkData(workData);
      _saveWorkSucceeded = response.status;
      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Work saved successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        widget.onSuccess();
        ProjectDashboard.triggerRefresh();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to save work'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving work: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _pauseWork() async {
    if (!_validateTasks()) return;
    if (!_isOfficeWork && selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a project'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (_isGettingLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please wait, fetching location...'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (isLocationEnabled &&
        (currentLatitude == null || currentLongitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location not available yet.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (!_isOfficeWork &&
        (selectedTitleId == null ||
            selectedTitleId!.isEmpty ||
            titleController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a title'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    await _getCurrentLocation();

    final workData = {
      'work_id': widget.existingWork?.id,
      'staff_type': _isOfficeWork ? 1 : 2,
      'staff_type_name': _isOfficeWork ? 1 : 2,
      'project_id': _isOfficeWork ? null : selectedProjectId,
      'project_name': _isOfficeWork ? null : selectedProjectName,
      'title': _isOfficeWork ? '' : titleController.text,
      'title_id': _isOfficeWork ? '' : selectedTitleId,
      'activity_id': tasks.isNotEmpty ? (tasks.first.activityId ?? tasks.first.taskId ?? '') : '',
      'assignedId': widget.existingWork?.assignedId,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'address': currentAddress,
      if (isDelay) ...{
        'is_delay': 1,
        'delay_type': selectedDelayType,
        'loose_type': selectedLooseType,
        'responsible_party': responsiblePartyController.text,
        'hours': hoursController.text,
      },
      if (uploadedFile != null) 'file': uploadedFile,
      if (uploadedFiles.isNotEmpty) 'files': uploadedFiles,
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'activity_id': task.activityId ?? task.taskId ?? '',
          'description': task.controller.text,
          'status': task.status,
          'completion': task.completion.round().toString(),
          'task_description': task.remarksControllers
              .map((controller) => controller.text)
              .where((remark) => remark.isNotEmpty)
              .join('\n'),
        };
      }).toList(),
    };
    try {
      final response = await HttpService.pauseWorkData(workData);

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingWork != null
                ? 'Work stopped successfully!'
                : 'Work started successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        await RunningWorkTimerService.instance.refresh();
        ProjectDashboard.triggerRefresh();
        await Future.delayed(const Duration(seconds: 1));
        widget.onSuccess();
        await RunningWorkTimerService.instance.refresh();
        ProjectDashboard.triggerRefresh();

        ProjectDashboardPermission == "true"
            ? Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
              )
            : Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
              );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Operation failed'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _restartWork() async {
    if (_isRestartingWork) return;
    setState(() => _isRestartingWork = true);
    _restartWorkSucceeded = false;
    try {
      await _performRestartWork();
    } finally {
      if (!_restartWorkSucceeded && mounted) {
        setState(() => _isRestartingWork = false);
      }
    }
  }

  Future<void> _performRestartWork() async {
    final loginResponse = await HttpService.getCurrentLoginStatus();
    if (loginResponse == null ||
        loginResponse.status != true ||
        loginResponse.data != true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login first.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (!_validateTasks()) return;
    if (!_isOfficeWork && selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a project'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (_isGettingLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please wait, fetching location...'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (isLocationEnabled &&
        (currentLatitude == null || currentLongitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location not available yet.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (!_isOfficeWork &&
        (selectedTitleId == null ||
            selectedTitleId!.isEmpty ||
            titleController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a title'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    await _getCurrentLocation();

    final workData = {
      'work_id': widget.existingWork?.id,
      'staff_type': _isOfficeWork ? 1 : 2,
      'staff_type_name': _isOfficeWork ? 1 : 2,
      'project_id': _isOfficeWork ? null : selectedProjectId,
      'project_name': _isOfficeWork ? null : selectedProjectName,
      'unit_no': selectedUnitNo ?? widget.existingWork?.unitNo ?? assignedWorks?.unitNo,
      'site_lift_no': selectedSiteLiftNo ?? widget.existingWork?.siteLiftNo ?? assignedWorks?.siteLiftNo,
      'title': _isOfficeWork ? '' : titleController.text,
      'title_id': _isOfficeWork ? '' : selectedTitleId,
      'activity_id': tasks.isNotEmpty ? (tasks.first.activityId ?? tasks.first.taskId ?? '') : '',
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'address': currentAddress,
      if (widget.workId != "") 'attendance_id': widget.workId,
      'is_delay': isDelay ? 'Y' : 'N',
      'delay_type_id': isDelay ? (selectedDelayType ?? '') : '',
      'delay_type': isDelay ? (selectedDelayType ?? '') : '',
      'loose_type_id': isDelay ? (selectedLooseType ?? '') : '',
      'loose_type': isDelay ? (selectedLooseType ?? '') : '',
      'responsible_party': isDelay ? responsiblePartyController.text : '',
      'delay_hours': isDelay ? hoursController.text : '',
      'hours': isDelay ? hoursController.text : '',
      'previous_timeline': previousTimeline ?? '',
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'activity_id': task.activityId ?? task.taskId ?? '',
          'description': task.controller.text,
          'status': task.status,
          'completion': task.completion.round().toString(),
          'task_description': task.remarksControllers
              .map((controller) => controller.text)
              .where((remark) => remark.isNotEmpty)
              .join('\n'),
        };
      }).toList(),
    };
    try {
      final response = await HttpService.restartWork(workData);
      _restartWorkSucceeded = response.status;

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingWork != null &&
                    widget.isPaused != 1 &&
                    widget.Restart != 1
                ? 'Work stopped successfully!'
                : widget.isPaused == 1
                    ? 'Work Paused successfully!'
                    : widget.Restart == 1
                        ? 'Work Restarted successfully!'
                        : 'Work started successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        await RunningWorkTimerService.instance.refresh();
        ProjectDashboard.triggerRefresh();
        await Future.delayed(const Duration(seconds: 1));
        widget.onSuccess();
        await RunningWorkTimerService.instance.refresh();
        ProjectDashboard.triggerRefresh();

        ProjectDashboardPermission == "true"
            ? Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
              )
            : Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
              );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Operation failed'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          widget.isPaused != 1 && widget.Restart != 1
              ? (widget.existingWork != null ? 'Stop Work' : 'Start Work')
              : (widget.Restart != 1
                  ? 'Pause Work'
                  : (assignedWorks != "" ? 'Start Work' : 'Restart Work')),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          RunningWorkTimerBadge(
            enableTapNavigation: false,
            margin: EdgeInsets.only(right: 12),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (isStopWork) ...[
                    // Work Details section for Stop Work popup
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: Client(Project), Unit No, Site Lift No
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Client(Project)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (selectedProjectName?.isNotEmpty == true)
                                          ? selectedProjectName!
                                          : (widget.existingWork?.projectName?.isNotEmpty == true)
                                              ? widget.existingWork!.projectName!
                                              : (assignedWorks?.projectName.isNotEmpty == true)
                                                  ? assignedWorks!.projectName
                                                  : 'Soorya',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Unit No',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (assignedWorks?.unitName?.isNotEmpty == true)
                                          ? assignedWorks!.unitName!
                                          : (widget.existingWork?.unitName?.isNotEmpty == true)
                                              ? widget.existingWork!.unitName!
                                              : (selectedUnitNo?.isNotEmpty == true)
                                                  ? selectedUnitNo!
                                                  : (widget.existingWork?.unitNo?.isNotEmpty == true)
                                                      ? widget.existingWork!.unitNo!
                                                      : (assignedWorks?.unitNo?.isNotEmpty == true)
                                                          ? assignedWorks!.unitNo!
                                                          : '-',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Site Lift No',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (assignedWorks?.siteLiftName?.isNotEmpty == true)
                                          ? assignedWorks!.siteLiftName!
                                          : (widget.existingWork?.siteLiftName?.isNotEmpty == true)
                                              ? widget.existingWork!.siteLiftName!
                                              : (selectedSiteLiftNo?.isNotEmpty == true)
                                                  ? selectedSiteLiftNo!
                                                  : (widget.existingWork?.siteLiftNo?.isNotEmpty == true)
                                                      ? widget.existingWork!.siteLiftNo!
                                                      : (assignedWorks?.siteLiftNo?.isNotEmpty == true)
                                                          ? assignedWorks!.siteLiftNo!
                                                          : '-',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Stage (Renamed from Modules)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stage',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (assignedWorks?.titleName.isNotEmpty == true &&
                                        assignedWorks!.titleName != assignedWorks!.title)
                                    ? assignedWorks!.titleName
                                    : (widget.existingWork?.title_name.isNotEmpty == true &&
                                            widget.existingWork!.title_name != widget.existingWork!.title)
                                        ? widget.existingWork!.title_name
                                        : (titleController.text.isNotEmpty &&
                                                titleController.text != widget.existingWork?.title &&
                                                titleController.text != assignedWorks?.title)
                                            ? titleController.text
                                            : (widget.existingWork?.title_name.isNotEmpty == true)
                                                ? widget.existingWork!.title_name
                                                : (assignedWorks?.titleName.isNotEmpty == true)
                                                    ? assignedWorks!.titleName
                                                    : (titleController.text.isNotEmpty)
                                                        ? titleController.text
                                                        : '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (!_isOfficeWork) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Project Field
                          InkWell(
                            onTap: null, /*
                          InkWell(
                            onTap: () async {
                              final selected =
                                  await dropDialogExisting(context, "Projects");
                              if (selected != null) {
                                setState(() {
                                  selectedProjectId = selected['id'];
                                  selectedProjectController.text =
                                      selected['name'] ?? '';
                                });
                                await _loadTitle();
                              }
                            },
                            */ child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Project',
                                labelStyle:
                                    TextStyle(color: Colors.blue.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                prefixIcon: Icon(Icons.work_outline,
                                    color: Colors.blue.shade700, size: 20),
                                suffixIcon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.grey),
                              ),
                              child: Text(
                                selectedProjectController.text.isEmpty
                                    ? 'Select Project'
                                    : selectedProjectController.text,
                                style: TextStyle(
                                  color: selectedProjectController.text.isEmpty
                                      ? Colors.grey.shade600
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Stage Field (Renamed from Module)
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: null, /* () async {
                                    final selected =
                                        await dropTitleDialog(context, titleList);
                                    if (selected != null) {
                                      setState(() {
                                        selectedTitleId = selected['id'];
                                        titleController.text = selected['name']!;
                                      });
                                    }
                                  },
                                  */ child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Stage',
                                      labelStyle:
                                          TextStyle(color: Colors.blue.shade700),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      prefixIcon: Icon(Icons.category_outlined,
                                          color: Colors.blue.shade700, size: 20),
                                      suffixIcon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.grey),
                                    ),
                                    child: Text(
                                      titleController.text.isEmpty
                                          ? 'Select Stage'
                                          : titleController.text,
                                      style: TextStyle(
                                        color: titleController.text.isEmpty
                                            ? Colors.grey.shade600
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // if (addWorkModule.toString() == "true")
                              //   Container(
                              //     margin: const EdgeInsets.only(left: 8),
                              //     decoration: BoxDecoration(
                              //       color: Colors.blue.shade50,
                              //       borderRadius: BorderRadius.circular(10),
                              //     ),
                              //     child: IconButton(
                              //       icon: Icon(Icons.add,
                              //           color: Colors.blue.shade700),
                              //       onPressed: () async {
                              //         final newTitle =
                              //             await showProjectTitleDialog(context);
                              //         if (newTitle != null) {
                              //           setState(() {
                              //             titleList.add(newTitle);
                              //             selectedTitleId = newTitle.id;
                              //             titleController.text = newTitle.name;
                              //           });
                              //         }
                              //       },
                              //     ),
                              //   ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ...List.generate(tasks.length, (taskIndex) {
                    final now = DateTime.now();
                    final formattedTime = DateFormat('hh:mm a').format(now);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isStopWork ? const Color(0xFFEDF7F2) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: tasks[taskIndex].isChecked
                            ? Border.all(color: isStopWork ? Colors.teal.shade300 : Colors.blue.shade200, width: 1)
                            : null,
                      ),
                      child: Container(
                        decoration: tasks[taskIndex].isChecked
                            ? BoxDecoration(
                                color: isStopWork ? const Color(0xFFE0F2F1) : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Checkbox(
                                    value: tasks[taskIndex].isChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          for (var i = 0;
                                              i < tasks.length;
                                              i++) {
                                            if (i != taskIndex) {
                                              tasks[i].isChecked = false;
                                              final toDoStatus =
                                                  allTaskStates.firstWhere(
                                                (status) =>
                                                    status.status
                                                        .toLowerCase()
                                                        .contains('to-do') ||
                                                    status.status
                                                        .toLowerCase()
                                                        .contains('todo'),
                                                orElse: () =>
                                                    allTaskStates.first,
                                              );
                                              tasks[i].status = toDoStatus.id;
                                            }
                                          }
                                          tasks[taskIndex].isChecked = true;
                                          final completedStatus =
                                              allTaskStates.firstWhere(
                                            (status) => status.id == '4',
                                            orElse: () =>
                                                allTaskStates.firstWhere(
                                              (status) => status.status
                                                  .toLowerCase()
                                                  .contains('complete'),
                                              orElse: () => allTaskStates.first,
                                            ),
                                          );
                                          tasks[taskIndex].status =
                                              completedStatus.id;
                                        } else {
                                          tasks[taskIndex].isChecked = false;
                                        }
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: tasks[taskIndex].controller,
                                    minLines: 1,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      hintText: 'Enter task title',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Status Dropdown
                                Container(
                                  width: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value:
                                        tasks[taskIndex].status?.isNotEmpty ==
                                                true
                                            ? tasks[taskIndex].status
                                            : (allTaskStates.isNotEmpty
                                                ? allTaskStates.first.id
                                                : null),
                                    items: allTaskStates
                                        .map((status) => DropdownMenuItem(
                                              value: status.id,
                                              child: Text(
                                                status.status,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) => setState(() {
                                      tasks[taskIndex].status = value;
                                      final selectedStatusObj =
                                          allTaskStates.firstWhere(
                                        (s) => s.id == value,
                                        orElse: () => TaskState(
                                            id: value ?? '', status: ''),
                                      );
                                      bool isCompleted = value == '4' ||
                                          selectedStatusObj.status
                                              .toLowerCase()
                                              .contains('complete');
                                      if (isCompleted) {
                                        tasks[taskIndex].isChecked = true;
                                        tasks[taskIndex].completion = 100.0;
                                      }
                                    }),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                    ),
                                    icon: const Icon(Icons.arrow_drop_down,
                                        size: 20),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Time and Delete
                                Column(
                                  children: [
                                    if (taskIndex != 0)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red, size: 16),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                              maxWidth: 30, maxHeight: 30),
                                          onPressed: () {
                                            setState(() {
                                              tasks.removeAt(taskIndex);
                                            });
                                          },
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        formattedTime,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            if (!isStartOrRestartWork) ...[
                              const SizedBox(height: 12),

                              // Completion Field (Draggable Progress Slider)
                              if (!_isOfficeWork) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Completion: ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                          Text(
                                            '${tasks[taskIndex].completion.round()}%',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1B5E20),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 10,
                                          thumbShape: const RoundSliderThumbShape(
                                              enabledThumbRadius: 9),
                                          overlayShape: const RoundSliderOverlayShape(
                                              overlayRadius: 16),
                                          activeTrackColor: const Color(0xFF2E7D32),
                                          inactiveTrackColor: Colors.grey.shade300,
                                          thumbColor: const Color(0xFF1B5E20),
                                        ),
                                        child: Slider(
                                          value: tasks[taskIndex]
                                              .completion
                                              .clamp(0.0, 100.0),
                                          min: 0,
                                          max: 100,
                                          divisions: 100,
                                          label:
                                              '${tasks[taskIndex].completion.round()}%',
                                          onChanged: (value) {
                                            setState(() {
                                              tasks[taskIndex].completion = value;
                                              if (value == 100.0) {
                                                tasks[taskIndex].isChecked = true;
                                                final completedStatus =
                                                    allTaskStates.firstWhere(
                                                  (status) => status.id == '4',
                                                  orElse: () =>
                                                      allTaskStates.firstWhere(
                                                    (status) => status.status
                                                        .toLowerCase()
                                                        .contains('complete'),
                                                    orElse: () =>
                                                        allTaskStates.first,
                                                  ),
                                                );
                                                tasks[taskIndex].status =
                                                    completedStatus.id;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),
                              ],

                              ...List.generate(
                                  tasks[taskIndex].remarksControllers.length,
                                  (remarkIndex) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: tasks[taskIndex]
                                              .remarksControllers[remarkIndex],
                                          minLines: 1,
                                          maxLines: 2,
                                          decoration: InputDecoration(
                                            hintText:
                                                '${widget.Restart == 1 ? "Remark" : (widget.existingWork != null && widget.isPaused != 1 && widget.Restart != 1) ? "Remark" : "Description"} ${remarkIndex + 1}',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: remarkIndex == 0
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            remarkIndex == 0
                                                ? Icons.add
                                                : Icons.remove,
                                            color: remarkIndex == 0
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                            size: 18,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                              maxWidth: 32, maxHeight: 32),
                                          onPressed: () {
                                            if (remarkIndex == 0) {
                                              _addDescriptionField(taskIndex);
                                            } else {
                                              _removeDescriptionField(
                                                  taskIndex, remarkIndex);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],

                            // Add Task Button (only for last task)
                            if ((taskIndex == tasks.length - 1) && widget.Restart != 1 && widget.isAssigned != 1)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.add_circle_outline,
                                      size: 18),
                                  label: const Text(
                                    "Add Task",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.green.shade700,
                                    backgroundColor: Colors.green.shade50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      tasks.add(TaskForm(
                                        controller: TextEditingController(),
                                        status: allTaskStates.isNotEmpty
                                            ? allTaskStates.first.id
                                            : '',
                                        taskId: null,
                                        remarks: [TextEditingController()],
                                      ));
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Is Delay section (for Stop Work, and for Restart Work only when is_delay == "Y")
                  if (!_isOfficeWork &&
                      (isStopWork || (widget.Restart == 1 && hasAssignedDelay))) ...[
                    const SizedBox(height: 16),
                    // Is Delay Section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: isDelay,
                                  activeColor: const Color(0xFF2E4B72),
                                  onChanged: (val) {
                                    setState(() {
                                      isDelay = val ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isDelay = !isDelay;
                                  });
                                },
                                child: Text(
                                  'Is Delay',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isDelay) ...[
                            const SizedBox(height: 16),
                            // Delay Type Dropdown
                            Text(
                              'Delay Type',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: (selectedDelayType != null &&
                                      delayTypeList.any((t) =>
                                          t.id == selectedDelayType ||
                                          t.name.toLowerCase() ==
                                              selectedDelayType!.toLowerCase()))
                                  ? (delayTypeList
                                          .any((t) => t.id == selectedDelayType)
                                      ? selectedDelayType
                                      : delayTypeList
                                          .firstWhere((t) =>
                                              t.name.toLowerCase() ==
                                              selectedDelayType!.toLowerCase())
                                          .id)
                                  : null,
                              hint: Text(
                                isLoadingDelayTypes ? 'Loading Delay Types...' : 'Select Delay Type',
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 14),
                              ),
                              isExpanded: true,
                              items: delayTypeList
                                  .map((type) => DropdownMenuItem(
                                        value: type.id,
                                        child: Text(type.name,
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedDelayType = val;
                                });
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Loose Type Dropdown
                            Text(
                              'Loose Type',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: (selectedLooseType != null &&
                                      looseTypeList.any((t) =>
                                          t.id == selectedLooseType ||
                                          t.name.toLowerCase() ==
                                              selectedLooseType!.toLowerCase()))
                                  ? (looseTypeList
                                          .any((t) => t.id == selectedLooseType)
                                      ? selectedLooseType
                                      : looseTypeList
                                          .firstWhere((t) =>
                                              t.name.toLowerCase() ==
                                              selectedLooseType!.toLowerCase())
                                          .id)
                                  : null,
                              hint: Text(
                                isLoadingLooseTypes ? 'Loading Loose Types...' : 'Select Loose Type',
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 14),
                              ),
                              isExpanded: true,
                              items: looseTypeList
                                  .map((type) => DropdownMenuItem(
                                        value: type.id,
                                        child: Text(type.name,
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedLooseType = val;
                                });
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Responsible Party Field
                            Text(
                              'Responsible Party',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: responsiblePartyController,
                              decoration: InputDecoration(
                                hintText: 'Enter Responsible Party',
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Hours Field (Time Selection)
                            Text(
                              'Hours',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => _selectHours(context),
                              child: IgnorePointer(
                                child: TextField(
                                  controller: hoursController,
                                  decoration: InputDecoration(
                                    hintText: 'Select Hours',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade400, fontSize: 14),
                                    suffixIcon: const Icon(Icons.access_time,
                                        color: Colors.grey),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (isStopWork) ...[
                    const SizedBox(height: 16),
                    // Upload File Section (OUTSIDE Is Delay Section, ALWAYS VISIBLE)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload File',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(allowMultiple: true);
                              if (result != null &&
                                  result.files.isNotEmpty) {
                                setState(() {
                                  for (final picked in result.files) {
                                    if (picked.path != null &&
                                        !uploadedFiles.any((f) => f.path == picked.path)) {
                                      uploadedFiles.add(File(picked.path!));
                                    }
                                  }
                                  _syncUploadedFilesState();
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(7),
                                        bottomLeft: Radius.circular(7),
                                      ),
                                    ),
                                    child: Text(
                                      'Choose Files',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(
                                        uploadedFileName ?? 'No file chosen',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: uploadedFileName != null
                                              ? Colors.black87
                                              : Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 44,
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  InkWell(
                                    onTap: _capturePhotoFromCamera,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(7),
                                      bottomRight: Radius.circular(7),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 11),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(7),
                                          bottomRight: Radius.circular(7),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 20,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (uploadedFiles.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildUploadedFilesPreview(),
                          ],
                          if (false)
                            InkWell(
                              child: Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.zero,
                                        child: Text(
                                          '',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
          ),

          // Bottom Action Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Location Toggle
                InkWell(
                  onTap: _isGettingLocation
                      ? null
                      : () async {
                          setState(() {
                            isLocationEnabled = !isLocationEnabled;
                            _isGettingLocation = true;
                          });

                          if (isLocationEnabled) {
                            await _getCurrentLocation();
                          } else {
                            currentLatitude = null;
                            currentLongitude = null;
                            currentAddress = null;
                          }

                          setState(() {
                            _isGettingLocation = false;
                          });
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    // child: Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Checkbox(
                    //       value: isLocationEnabled,
                    //       activeColor: Colors.blue.shade700,
                    //       onChanged: _isGettingLocation
                    //           ? null
                    //           : (value) async {
                    //               setState(() {
                    //                 isLocationEnabled = value ?? false;
                    //                 _isGettingLocation = true;
                    //               });

                    //               if (isLocationEnabled) {
                    //                 await _getCurrentLocation();
                    //               } else {
                    //                 currentLatitude = null;
                    //                 currentLongitude = null;
                    //               }

                    //               setState(() {
                    //                 _isGettingLocation = false;
                    //               });
                    //             },
                    //     ),
                    //     Text(
                    //       'Update Location',
                    //       style: TextStyle(
                    //         fontSize: 14,
                    //         color: Colors.grey.shade800,
                    //       ),
                    //     ),
                    //     if (_isGettingLocation) ...[
                    //       const SizedBox(width: 8),
                    //       const SizedBox(
                    //         width: 16,
                    //         height: 16,
                    //         child: CircularProgressIndicator(strokeWidth: 2),
                    //       ),
                    //     ],
                    //   ],
                    // ),
                  ),
                ),

                const SizedBox(height: 12),

              
                if (widget.existingWork != null &&
                    widget.isPaused != 1 &&
                    widget.Restart != 1) ...[
                  if (tasks.any((task) => task.isChecked && task.status == '3'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: _isStoppingWork ? null : _submitWork,
                          child: const Text(
                            'STOP WORK',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: _isSavingWork ? null : _savework,
                          child: const Text(
                            'SAVE WORK',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                ] else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isPaused == 1
                            ? Colors.orange.shade600
                            : (widget.Restart == 1
                                ? Colors.green.shade600
                                : Colors.green.shade600),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: widget.isPaused == 1 && widget.Restart != 1
                          ? _pauseWork
                          : (widget.Restart == 1
                              ? (_isRestartingWork ? null : _restartWork)
                              : (_isStartingWork ? null : _submitWork)),
                      child: Text(
                        widget.isPaused == 1
                            ? "PAUSE WORK"
                            : (widget.Restart == 1
                                ? "RESTART WORK"
                                : 'START WORK'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Methods
  Future<dynamic> dropDialogExisting(BuildContext context, String title) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select $title',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            search.clear();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: search,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (title == "Projects") {
                            filterProjectsDialog(value);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            title == "Projects" ? filteredProjects.length : 0,
                        itemBuilder: (context, index) {
                          final project = filteredProjects[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                project.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            title: Text(
                              project.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                            onTap: () {
                              Navigator.pop(context, {
                                'id': project.id,
                                'name': project.name,
                              });
                              search.clear();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, String>?> dropTitleDialog(
      BuildContext context, List<TitleListDet> titleList) async {
    TextEditingController searchController = TextEditingController();
    List<TitleListDet> filteredTitles = List.from(titleList);

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Stage',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Stages...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredTitles = titleList
                              .where((t) => t.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredTitles.length,
                        itemBuilder: (context, index) {
                          final title = filteredTitles[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                title.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            title: Text(
                              title.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                            onTap: () {
                              Navigator.pop(context, {
                                'id': title.id,
                                'name': title.name,
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<TitleListDet?> showProjectTitleDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController projectController = TextEditingController();
    projectController.text = selectedProjectName ?? '';

    return showDialog<TitleListDet>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Add New Stage',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        await dropDialogExisting(context, "Projects");
                        setState(() {
                          projectController.text = selectedProjectName ?? '';
                        });
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Project',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          projectController.text.isEmpty
                              ? 'Select Project'
                              : projectController.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Stage Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (selectedProjectId == null ||
                                  titleController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Please select a project and enter module name'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.red.shade400,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                return;
                              }

                              final newTitle = await HttpService.submitTitle(
                                context: context,
                                projectId: selectedProjectId!,
                                title: titleController.text.trim(),
                              );

                              if (newTitle != null) {
                                Navigator.pop(context, newTitle);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
