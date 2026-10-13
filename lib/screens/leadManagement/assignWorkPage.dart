import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/priorityStatusModel.dart';
import 'package:login2/models/lead_management/taskStatusModel.dart';
import '../../core/common.dart';
import '../../models/lead_management/projectList_model.dart';
import '../../models/lead_management/titleListModel.dart';
import '../../models/lead_management/workstatus_model.dart';
import '../../service/service.dart';
import 'package:login2/models/expense/staffListModel.dart';

class TaskForm {
  TextEditingController controller;
  TextEditingController descriptionController;
  String? status;
  String? taskId;
  DateTime? startDate;
  DateTime? endDate;
  String? assignedStaffId;
  List<String> supportingStaffIds;
  List<TextEditingController> remarksControllers;

  TaskForm({
    required this.controller,
    required this.descriptionController,
    this.status,
    this.taskId,
    this.startDate,
    this.endDate,
    this.assignedStaffId,
    List<String>? supportingStaffIds,
    List<TextEditingController>? remarks,
  })  : supportingStaffIds = supportingStaffIds ?? [],
        remarksControllers = remarks ?? [TextEditingController()];
}

class AssignWorkPage extends StatefulWidget {
  final WorkStatus? existingWork;
  final Function() onSuccess;
  final int isPaused;
  final int Restart;
  const AssignWorkPage({
    super.key,
    this.existingWork,
    required this.onSuccess,
    this.isPaused = 0,
    this.Restart = 0,
  });

  @override
  _AssignWorkPageState createState() => _AssignWorkPageState();
}

class _AssignWorkPageState extends State<AssignWorkPage> {
  late TextEditingController titleController;
  late List<TaskForm> tasks;
  String? selectedProjectId;
  String? selectedProjectName;
  String? selectedTitleId;
  DateTime? dueDate;
  String? priority;
  String? assignedTo;
  final TextEditingController _searchController = TextEditingController();
  List<Projects> projectList = [];
  List<TitleListDet> titleList = [];
  List<String> participantIds = [];
  String taskType = "Task";
  String category = "New Work";
  final List<String> taskTypes = ["Task", "Complaint"];
  final List<String> categories = ["New Work", "Re Work"];
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
  double? currentLatitude;
  double? currentLongitude;
  void filterCustomers(String value) {}
  void filterTemplates(String value) {}
  void filterProjects(String value) {}
  void filterProducts(String value) {}
  void calculateTotalExisting() {}
  late String token;
  late String userId;
  List<Staff> staffList = [];
  List<TaskState> allTaskStates = [];
  List<PrioState> allPriorities = [];
  bool whatsappNotification = false;
  bool pushNotification = false;
  bool notifyOnStart = false;
  bool notifyOnComplete = false;
  bool notifyToAssignedStaff = true;
  bool notifyOnStatusChange = false;
  bool notifyOtherPeople = false;
  List<String> selectedStaffIds = [];
  List<String> selectedAssignedStaffIds = [];
  bool _isAssigning = false;
  List<dynamic> unitList = [];
  List<dynamic> siteLiftList = [];
  List<dynamic> stageList = [];
  List<dynamic> unitTaskList = [];
  String? selectedUnitId;
  String? selectedUnitNo;
  String? selectedSiteLiftId;
  String? selectedSiteLiftNo;
  String? selectedStageId;
  String? selectedStageName;
  bool isLoadingUnits = false;
  bool isLoadingSiteLifts = false;
  bool isLoadingStages = false;
  bool isLoadingTasks = false;
  List<String> selectedSupportingStaffIds = [];

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
                  descriptionController:
                      TextEditingController(text: task.description),
                  status: task.status,
                  taskId: task.taskId,
                  startDate: null,
                  endDate: null,
                  assignedStaffId: null,
                  supportingStaffIds: [],
                  remarks: task.remarks
                      .map((remark) => TextEditingController(text: remark))
                      .toList(),
                ))
            .toList()
        : [
            TaskForm(
              controller: TextEditingController(),
              descriptionController: TextEditingController(),
              status: allTaskStates.isNotEmpty ? allTaskStates.first.id : null,
              taskId: null,
              startDate: null,
              endDate: null,
              assignedStaffId: null,
              supportingStaffIds: [],
              remarks: [TextEditingController()],
            )
          ];

    if (widget.existingWork != null) {
      selectedProjectId = widget.existingWork!.projectId;
      selectedTitleId = widget.existingWork!.title;
      dueDate = widget.existingWork!.dueDate;
      priority = widget.existingWork!.priority;
      assignedTo = widget.existingWork!.assignedTo;
      if (selectedProjectId == "0") {
        selectedProjectId = null;
      }
    }
    if (widget.existingWork != null &&
        widget.existingWork!.assignedTo != null) {
      selectedStaffIds = [widget.existingWork!.assignedTo!];
    } else if (assignedTo != null) {
      selectedStaffIds = [assignedTo!];
    }
    if (assignedTo != null && assignedTo!.isNotEmpty) {
      selectedAssignedStaffIds = assignedTo!.split(',').where((id) => id.trim().isNotEmpty && id.trim() != "0").toList();
    } else {
      selectedAssignedStaffIds = []; 
    }
    whatsappNotification = false;
    pushNotification = false;
    notifyOnStart = false;
    notifyOnComplete = false;
    selectedStaffIds = [];
    _initAsync();
    _loadStaffs();
    _loadTaskState();
    _loadPrioState();
    _loadStages();
  }

  void _initAsync() async {
    token = await Common.getSharedPref("token") ?? "";
    userId = await Common.getSharedPref("userId") ?? "";
    await _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final response = await HttpService.getProjectList();
      if (!mounted) return;
      setState(() {
        projectList = response?.data ?? [];

        final uniqueProjects = <String, Projects>{};
        for (var project in projectList) {
          uniqueProjects[project.id] = project;
        }
        projectList = uniqueProjects.values.toList();
        filteredProjects = List.from(projectList);
        if (selectedProjectId != null) {
          final exists = projectList.any((p) => p.id == selectedProjectId);
          if (!exists) {
            selectedProjectId = null;
          }
          _loadTitle();
        }
        if (widget.existingWork != null && selectedProjectId != null) {
          final selectedProject =
              projectList.firstWhere((p) => p.id == selectedProjectId);
          selectedProjectName = selectedProject.name;
          selectedProjectController.text = selectedProject.name;
        }
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        selectedProjectId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load projects: $e')),
      );
    }
  }

  Future<void> _loadTitle() async {
    if (selectedProjectId == null) return;
    try {
      final response = await HttpService.getTitleList(selectedProjectId!);
      if (!mounted) return;
      setState(() {
        titleList = response?.data ?? [];
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
    if (!mounted) return;
    if (response != null && response.status == true) {
      setState(() {
        staffList = response.data;
        notifyToAssignedStaff = true;
        notifyOnStatusChange = false;
        notifyOtherPeople = false;
        selectedStaffIds = [];
      });
    }
  }

  Future<void> _loadTaskState() async {
    final response = await HttpService.getTaskState();
    if (!mounted) return;
    if (response != null && response.status == true) {
      setState(() {
        allTaskStates = response.data;
      });
      log("✅ Task States Loaded: ${allTaskStates.length}");
    } else {
      log("❌ Failed to load task states or status is false");
    }
  }

  Future<void> _loadPrioState() async {
    final response = await HttpService.getPrioState();
    if (!mounted) return;
    if (response != null && response.status == true) {
      setState(() {
        allPriorities = response.data;
        if (priority == null && allPriorities.isNotEmpty) {
          final highPriority = allPriorities.firstWhere(
            (p) => p.priority.toLowerCase() == 'medium',
            orElse: () => allPriorities.first,
          );
          priority = highPriority.id;
        }
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var task in tasks) {
      task.controller.dispose();
      task.descriptionController.dispose();
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
      filteredProjects = projectList.where((project) {
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

  Future<void> _submitWork() async {
    if (_isAssigning) return;

    setState(() {
      _isAssigning = true;
    });

    try {
      if (selectedProjectId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a project'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (selectedStageId == null && (selectedStageName == null || selectedStageName!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a stage'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final workData = {
        'work_id': widget.existingWork?.id,
        'project_id': selectedProjectId,
        'project_name': selectedProjectName,
        'unit_id': selectedUnitId,
        'unit_no': selectedUnitNo,
        'site_lift_id': selectedSiteLiftId,
        'site_lift_no': selectedSiteLiftNo,
        'stage_id': selectedStageId,
        'stage_name': selectedStageName,
        'title': titleController.text.isNotEmpty ? titleController.text : 'Work Assignment',
        'title_id': selectedTitleId ?? '',
        'due_date':
            dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : null,
        'priority': priority,
        'assigned_to': assignedTo,
        'task_type': taskType,
        'category': category,
        'latitude': currentLatitude,
        'longitude': currentLongitude,
        'participant_ids': participantIds.join(','),
        'notification': {
          'whatsapp': whatsappNotification,
          'push': pushNotification,
          'notify_to_assigned': notifyToAssignedStaff,
          'notify_on_status_change': notifyOnStatusChange,
          'notify_other_people': notifyOtherPeople,
          'staff_ids': selectedStaffIds.join(','),
          'on_start': notifyOnStart,
          'on_complete': notifyOnComplete,
        },
        'tasks': tasks.asMap().entries.map((entry) {
          final task = entry.value;
          return {
            'activity_id': task.taskId,
            'task_id': task.taskId,
            'activity_name': task.controller.text,
            'task_name': task.controller.text,
            'description': task.descriptionController.text, 
            'task_description': task.descriptionController.text,
            'start_date': task.startDate != null
                ? DateFormat('yyyy-MM-dd').format(task.startDate!)
                : null,
            'end_date': task.endDate != null
                ? DateFormat('yyyy-MM-dd').format(task.endDate!)
                : null,
            'assigned_staff_id': task.assignedStaffId ?? '0',
            'assigned_to': task.assignedStaffId ?? '0',
            'supporting_staff_ids': task.supportingStaffIds.join(','),
            'status': (task.status != null && task.status.toString().isNotEmpty)
                ? task.status
                : 1,
          };
        }).toList(),
      };

      final response = widget.existingWork != null
          ? await HttpService.updateWorkData(workData)
          : await HttpService.assignWorkData(workData);

      if (!mounted) return;
      Navigator.of(context).pop();

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingWork != null
                ? 'Work updated successfully!'
                : 'Work Assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAssigning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingWork != null;

    return AbsorbPointer(
      absorbing: _isAssigning,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            isEditing ? 'Edit Work' : 'Assign Work',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF2a86c9),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Work Information
                    _buildSectionCard(
                      title: 'Work Details',
                      icon: Icons.assignment_outlined,
                      children: [
                        // Row 1: Project *, Unit No, Site Lift No
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Project *
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Project ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '*',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () async {
                                      final selected =
                                          await dropDialogExisting(context, "Projects");
                                      if (selected != null && mounted) {
                                        setState(() {
                                          selectedProjectId = selected['id'];
                                          selectedProjectController.text =
                                              selected['name'] ?? '';
                                        });
                                        await _loadUnitsByProject(selectedProjectId!);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              selectedProjectController.text.isEmpty
                                                  ? 'Select Project'
                                                  : selectedProjectController.text,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: selectedProjectController.text.isEmpty
                                                    ? Colors.grey[500]
                                                    : Colors.grey[800],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(Icons.keyboard_arrow_down,
                                              color: Colors.grey, size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Unit No
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Unit No',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () async {
                                      if (selectedProjectId == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('Please select a project first')),
                                        );
                                        return;
                                      }
                                      await _showUnitSelectionDialog(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              selectedUnitNo ?? 'Select Unit No',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: selectedUnitNo != null
                                                    ? Colors.grey[800]
                                                    : Colors.grey[500],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          isLoadingUnits
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(
                                                      strokeWidth: 2),
                                                )
                                              : const Icon(Icons.keyboard_arrow_down,
                                                  color: Colors.grey, size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Site Lift No
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Site Lift No',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () async {
                                      if (selectedUnitId == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('Please select a Unit No first')),
                                        );
                                        return;
                                      }
                                      await _showSiteLiftSelectionDialog(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              selectedSiteLiftNo ?? 'Select Site Lift No',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: selectedSiteLiftNo != null
                                                    ? Colors.grey[800]
                                                    : Colors.grey[500],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          isLoadingSiteLifts
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(
                                                      strokeWidth: 2),
                                                )
                                              : const Icon(Icons.keyboard_arrow_down,
                                                  color: Colors.grey, size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Stages *
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                text: 'Stages ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await _showStageSelectionDialog(context);
                                  },
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2a86c9).withOpacity(0.1),
                                      border: Border.all(color: const Color(0xFF2a86c9)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.add,
                                        color: Color(0xFF2a86c9), size: 22),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      await _showStageSelectionDialog(context);
                                    },
                                    child: Container(
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      alignment: Alignment.centerLeft,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              selectedStageName ?? 'Select Stage',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: selectedStageName != null
                                                    ? Colors.grey[800]
                                                    : Colors.grey[500],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          isLoadingStages
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(
                                                      strokeWidth: 2),
                                                )
                                              : const Icon(Icons.keyboard_arrow_down,
                                                  color: Colors.grey, size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Card 2: Tasks Section Card
                    _buildSectionCard(
                      title: 'Tasks',
                      icon: Icons.task_alt_rounded,
                      children: [
                        ...List.generate(tasks.length, (taskIndex) {
                          final task = tasks[taskIndex];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (tasks.length > 1)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          tasks.removeAt(taskIndex);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 16, color: Colors.grey),
                                      ),
                                    ),
                                  ),

                                // Task * field
                                RichText(
                                  text: const TextSpan(
                                    text: 'Activity ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '*',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () =>
                                      _showTaskSelectionDialog(context, taskIndex),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            task.controller.text.isEmpty
                                                ? 'Select Task'
                                                : task.controller.text,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: task.controller.text.isEmpty
                                                  ? Colors.grey[500]
                                                  : Colors.grey[800],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(Icons.keyboard_arrow_down,
                                            color: Colors.grey, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Row 2: Description, Start Date *, End Date *
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // =========================
    // DESCRIPTION
    // =========================
    const Text(
      'Description',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
    const SizedBox(height: 6),

    TextField(
      controller: task.descriptionController,
      minLines: 3,
      maxLines: 3,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Enter description',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 13,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF2a86c9),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    const SizedBox(height: 14),

    // =========================
    // START DATE + END DATE
    // =========================
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // START DATE
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  text: 'Start Date ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        task.startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null && mounted) {
                    setState(() {
                      task.startDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.startDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(task.startDate!)
                              : 'Start Date',
                          style: TextStyle(
                            fontSize: 13,
                            color: task.startDate != null
                                ? Colors.grey[800]
                                : Colors.grey[400],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFF2a86c9),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // END DATE
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  text: 'End Date ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        task.endDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null && mounted) {
                    setState(() {
                      task.endDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.endDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(task.endDate!)
                              : 'End Date',
                          style: TextStyle(
                            fontSize: 13,
                            color: task.endDate != null
                                ? Colors.grey[800]
                                : Colors.grey[400],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFF2a86c9),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ],
),

                                const SizedBox(height: 14),

                                // Row 3: Assigned Staff, Supporting Staffs
                  
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // =========================
    // ASSIGNED STAFF
    // =========================
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: Colors.black87,
            ),
            SizedBox(width: 4),
            Text(
              'Assigned Staff',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showSingleAssignedStaffSelectionDialog(
            context,
            taskIndex,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getTaskAssignedStaffName(taskIndex),
                    style: TextStyle(
                      fontSize: 13,
                      color: task.assignedStaffId != null &&
                              task.assignedStaffId != "0"
                          ? Colors.grey[800]
                          : Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (task.assignedStaffId != null &&
                    task.assignedStaffId != "0")
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        task.assignedStaffId = null;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    ),

    const SizedBox(height: 14),

    // =========================
    // SUPPORTING STAFFS
    // =========================
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 16,
              color: Colors.black87,
            ),
            SizedBox(width: 4),
            Text(
              'Supporting Staffs',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () =>
              _showMultiSupportingStaffSelectionDialogForTask(
            context,
            taskIndex,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getTaskSupportingStaffNames(taskIndex),
                    style: TextStyle(
                      fontSize: 13,
                      color: task.supportingStaffIds.isNotEmpty
                          ? Colors.grey[800]
                          : Colors.grey[400],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ],
)

                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),

                        // + Add Task Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                tasks.add(TaskForm(
                                  controller: TextEditingController(),
                                  descriptionController: TextEditingController(),
                                  status: allTaskStates.isNotEmpty
                                      ? allTaskStates.first.id
                                      : null,
                                  taskId: null,
                                  startDate: null,
                                  endDate: null,
                                  assignedStaffId: null,
                                  supportingStaffIds: [],
                                  remarks: [TextEditingController()],
                                ));
                              });
                            },
                            icon: const Icon(Icons.add, size: 18, color: Colors.white),
                            label: const Text(
                              'Add Task',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2a86c9),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Card 3: Notification Settings Card
                    _buildSectionCard(
                      title: 'Notification Settings',
                      icon: Icons.notifications_active_outlined,
                      children: [
                        _buildNotificationOption(
                          icon: FontAwesomeIcons.whatsapp,
                          iconColor: Colors.green,
                          title: 'WhatsApp Notification',
                          value: whatsappNotification,
                          onChanged: (value) => setState(() {
                            whatsappNotification = value;
                          }),
                        ),
                        const SizedBox(height: 10),
                        _buildNotificationOption(
                          icon: Icons.notifications_active_rounded,
                          iconColor: const Color(0xFF2a86c9),
                          title: 'Push Notification',
                          value: pushNotification,
                          onChanged: (value) => setState(() {
                            pushNotification = value;
                          }),
                        ),
                        const SizedBox(height: 10),
                        _buildNotificationOption(
                          icon: Icons.person_rounded,
                          iconColor: Colors.orange,
                          title: 'Notify to Assigned Staff',
                          value: notifyToAssignedStaff,
                          onChanged: (value) => setState(() {
                            notifyToAssignedStaff = value;
                          }),
                        ),
                        const SizedBox(height: 10),
                        _buildNotificationOption(
                          icon: Icons.change_circle_rounded,
                          iconColor: Colors.purple,
                          title: 'Notify on Status Change',
                          value: notifyOnStatusChange,
                          onChanged: (value) => setState(() {
                            notifyOnStatusChange = value;
                          }),
                        ),
                        const SizedBox(height: 10),
                        _buildNotificationOption(
                          icon: Icons.play_arrow_rounded,
                          iconColor: Colors.teal,
                          title: 'Notify When Work Starts',
                          value: notifyOnStart,
                          onChanged: (value) => setState(() {
                            notifyOnStart = value;
                          }),
                        ),
                        const SizedBox(height: 10),
                        _buildNotificationOption(
                          icon: Icons.check_circle_rounded,
                          iconColor: Colors.green,
                          title: 'Notify When Work Completes',
                          value: notifyOnComplete,
                          onChanged: (value) => setState(() {
                            notifyOnComplete = value;
                          }),
                        ),
                        const SizedBox(height: 10),
                        _buildNotificationOption(
                          icon: Icons.group_rounded,
                          iconColor: Colors.indigo,
                          title: 'Notify Other People',
                          value: notifyOtherPeople,
                          onChanged: (value) {
                            setState(() {
                              notifyOtherPeople = value;
                              if (!notifyOtherPeople) {
                                selectedStaffIds.clear();
                              }
                            });
                          },
                        ),
                        if (notifyOtherPeople) ...[
                          const SizedBox(height: 14),
                          Text(
                            'Select Staff to Notify:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _showMultiStaffSelectionDialog(
                                context, false),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.group_add_rounded,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        selectedStaffIds.isEmpty
                                            ? 'Select Staff to Notify'
                                            : '${selectedStaffIds.length} staff selected',
                                        style: TextStyle(
                                          color: selectedStaffIds.isEmpty
                                              ? Colors.grey[500]
                                              : Colors.grey[800],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey[600],
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Text(
                          'Participants in Chat',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () =>
                              _showMultiStaffSelectionDialog(context, true),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      participantIds.isEmpty
                                          ? 'Select Chat Participants'
                                          : '${participantIds.length} participants selected',
                                      style: TextStyle(
                                        color: participantIds.isEmpty
                                            ? Colors.grey[500]
                                            : Colors.grey[800],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey[600],
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.maxFinite,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isAssigning ? null : _submitWork,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2a86c9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isAssigning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isEditing ? 'UPDATE WORK' : 'ASSIGN WORK',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a86c9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF2a86c9), size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  String _getTaskAssignedStaffName(int taskIndex) {
    final id = tasks[taskIndex].assignedStaffId;
    if (id == null || id == "0" || id.isEmpty) {
      return 'Unassigned';
    }
    final staff = staffList.firstWhere(
      (s) => s.userIdStaff == id,
      orElse: () => Staff(id: '', name: '', userIdStaff: ''),
    );
    return staff.name.isNotEmpty ? staff.name : 'Unassigned';
  }

  String _getTaskSupportingStaffNames(int taskIndex) {
    final ids = tasks[taskIndex].supportingStaffIds;
    if (ids.isEmpty) {
      return 'Select Staff';
    }
    final names = ids
        .map((id) {
          final staff = staffList.firstWhere(
            (s) => s.userIdStaff == id,
            orElse: () => Staff(id: '', name: '', userIdStaff: ''),
          );
          return staff.name;
        })
        .where((name) => name.isNotEmpty)
        .toList();
    return names.isNotEmpty ? names.join(', ') : 'Select Staff';
  }

  Future<dynamic> dropDialogExisting(BuildContext context, String title) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          search.clear();
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      controller: search,
                      autocorrect: false,
                      keyboardType: TextInputType.text,
                      autofocus: true,
                      onChanged: (value) {
                        setState(() {
                          if (title == "Projects") {
                            filterProjectsDialog(value);
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 8),
                        labelText: 'Search...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ListView.builder(
                  itemCount: filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = filteredProjects[index];
                    return ListTile(
                      onTap: () {
                        selectedProjectId = project.id;
                        selectedProjectName = project.name;
                        selectedProjectController.text = project.name;
                        Navigator.pop(context, {
                          'id': project.id,
                          'name': project.name,
                        });
                        search.clear();
                      },
                      title: Text(project.name),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadStages() async {
    if (mounted) setState(() => isLoadingStages = true);
    try {
      final res = await HttpService.getAllStages();
      if (res != null && mounted) {
        List<dynamic> list = [];
        if (res is Map && res['data'] is List) {
          list = res['data'];
        } else if (res is List) {
          list = res;
        }
        setState(() {
          stageList = list;
        });
      }
    } catch (e) {
      debugPrint('Error loading stages: $e');
    } finally {
      if (mounted) setState(() => isLoadingStages = false);
    }
  }

  Future<void> _loadUnitsByProject(String projectId) async {
    if (mounted) {
      setState(() {
        isLoadingUnits = true;
        selectedUnitId = null;
        selectedUnitNo = null;
        unitList = [];
        selectedSiteLiftId = null;
        selectedSiteLiftNo = null;
        siteLiftList = [];
        unitTaskList = [];
      });
    }
    try {
      final res = await HttpService.getUnitsByProject(projectId);
      if (res != null && mounted) {
        List<dynamic> list = [];
        if (res is Map && res['data'] is List) {
          list = res['data'];
        } else if (res is List) {
          list = res;
        }
        setState(() {
          unitList = list;
        });
      }
    } catch (e) {
      debugPrint('Error loading units: $e');
    } finally {
      if (mounted) setState(() => isLoadingUnits = false);
    }
  }

  Future<void> _loadSiteLiftsAndTasks(String unitId, String projectId) async {
    if (mounted) {
      setState(() {
        isLoadingSiteLifts = true;
        isLoadingTasks = true;
        selectedSiteLiftId = null;
        selectedSiteLiftNo = null;
        siteLiftList = [];
        unitTaskList = [];
      });
    }

    try {
      final resLifts = await HttpService.getSiteLiftsByUnit(unitId, projectId);
      if (resLifts != null && mounted) {
        List<dynamic> list = [];
        if (resLifts is Map && resLifts['data'] is List) {
          list = resLifts['data'];
        } else if (resLifts is List) {
          list = resLifts;
        }
        setState(() {
          siteLiftList = list;
        });
      }
    } catch (e) {
      debugPrint('Error loading site lifts: $e');
    } finally {
      if (mounted) setState(() => isLoadingSiteLifts = false);
    }

    try {
      final resTasks = await HttpService.getTaskListByUnit(projectId, unitId);
      if (resTasks != null && mounted) {
        List<dynamic> list = [];
        if (resTasks is Map && resTasks['data'] is List) {
          list = resTasks['data'];
        } else if (resTasks is List) {
          list = resTasks;
        }
        setState(() {
          unitTaskList = list;
          if (tasks.isEmpty) {
            tasks = [
              TaskForm(
                controller: TextEditingController(),
                descriptionController: TextEditingController(),
                status: allTaskStates.isNotEmpty ? allTaskStates.first.id : null,
                taskId: null,
                startDate: null,
                endDate: null,
                assignedStaffId: null,
                supportingStaffIds: [],
                remarks: [TextEditingController()],
              )
            ];
          } else if (widget.existingWork == null) {
            tasks = [
              TaskForm(
                controller: TextEditingController(),
                descriptionController: TextEditingController(),
                status: allTaskStates.isNotEmpty ? allTaskStates.first.id : null,
                taskId: null,
                startDate: null,
                endDate: null,
                assignedStaffId: null,
                supportingStaffIds: [],
                remarks: [TextEditingController()],
              )
            ];
          } else {
            tasks.first.controller.clear();
            tasks.first.taskId = null;
            tasks.first.descriptionController.clear();
            tasks.first.startDate = null;
            tasks.first.endDate = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading task list by unit: $e');
    } finally {
      if (mounted) setState(() => isLoadingTasks = false);
    }
  }

  Future<void> _showUnitSelectionDialog(BuildContext context) async {
    TextEditingController searchController = TextEditingController();
    List<dynamic> filtered = List.from(unitList);

    final selected = await showDialog<dynamic>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Unit No'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Unit',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filtered = unitList.where((item) {
                            final name = (item['unit_no'] ??
                                    item['unit_name'] ??
                                    item['name'] ??
                                    item['id'] ??
                                    '')
                                .toString();
                            return name
                                .toLowerCase()
                                .contains(value.toLowerCase());
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No Units Found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final uNo = (item['unit_no'] ??
                                        item['unit_name'] ??
                                        item['name'] ??
                                        item['id'] ??
                                        '')
                                    .toString();
                                return ListTile(
                                  title: Text(uNo),
                                  onTap: () => Navigator.pop(context, item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      final uId = (selected['id'] ??
              selected['unit_id'] ??
              selected['unit_no'] ??
              '')
          .toString();
      final uNo = (selected['unit_no'] ??
              selected['unit_name'] ??
              selected['name'] ??
              selected['id'] ??
              '')
          .toString();
      setState(() {
        selectedUnitId = uId;
        selectedUnitNo = uNo;
      });
      if (selectedProjectId != null) {
        _loadSiteLiftsAndTasks(selectedUnitId!, selectedProjectId!);
      }
    }
  }

  Future<void> _showSiteLiftSelectionDialog(BuildContext context) async {
    TextEditingController searchController = TextEditingController();
    List<dynamic> filtered = List.from(siteLiftList);

    final selected = await showDialog<dynamic>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Site Lift No'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Site Lift',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filtered = siteLiftList.where((item) {
                            final name = (item['site_lift_name'] ??
                                    item['site_lift_no'] ??
                                    item['lift_no'] ??
                                    item['lift_name'] ??
                                    item['name'] ??
                                    item['id'] ??
                                    '')
                                .toString();
                            return name
                                .toLowerCase()
                                .contains(value.toLowerCase());
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No Site Lifts Found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final lNo = (item['site_lift_name'] ??
                                        item['site_lift_no'] ??
                                        item['lift_no'] ??
                                        item['lift_name'] ??
                                        item['name'] ??
                                        item['id'] ??
                                        '')
                                    .toString();
                                return ListTile(
                                  title: Text(lNo),
                                  onTap: () => Navigator.pop(context, item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      final lId = (selected['id'] ??
              selected['site_lift_id'] ??
              selected['lift_id'] ??
              selected['site_lift_no'] ??
              '')
          .toString();
      final lNo = (selected['site_lift_name'] ??
              selected['site_lift_no'] ??
              selected['lift_no'] ??
              selected['lift_name'] ??
              selected['name'] ??
              selected['id'] ??
              '')
          .toString();
      setState(() {
        selectedSiteLiftId = lId;
        selectedSiteLiftNo = lNo;
      });
    }
  }

  Future<void> _showStageSelectionDialog(BuildContext context) async {
    TextEditingController searchController = TextEditingController();
    List<dynamic> filtered = List.from(stageList);

    final selected = await showDialog<dynamic>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Stage'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Stage',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filtered = stageList.where((item) {
                            final name = (item['stage'] ??
                                    item['stage_name'] ??
                                    item['name'] ??
                                    item['title'] ??
                                    item['id'] ??
                                    '')
                                .toString();
                            return name
                                .toLowerCase()
                                .contains(value.toLowerCase());
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No Stages Found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final sName = (item['stage'] ??
                                        item['stage_name'] ??
                                        item['name'] ??
                                        item['title'] ??
                                        item['id'] ??
                                        '')
                                    .toString();
                                return ListTile(
                                  title: Text(sName),
                                  onTap: () => Navigator.pop(context, item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      final sId = (selected['id'] ?? selected['stage_id'] ?? '').toString();
      final sName = (selected['stage'] ??
              selected['stage_name'] ??
              selected['name'] ??
              selected['title'] ??
              selected['id'] ??
              '')
          .toString();
      setState(() {
        selectedStageId = sId;
        selectedStageName = sName;
      });
    }
  }

  Future<void> _showTaskSelectionDialog(
      BuildContext context, int taskIndex) async {
    TextEditingController searchController = TextEditingController();
    List<dynamic> filtered = List.from(unitTaskList);

    final selected = await showDialog<dynamic>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Task'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Task',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filtered = unitTaskList.where((item) {
                            final name = (item['activity_name'] ??
                                    item['task_name'] ??
                                    item['name'] ??
                                    item['activity_key'] ??
                                    '')
                                .toString();
                            return name
                                .toLowerCase()
                                .contains(value.toLowerCase());
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No tasks found for this Unit'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final tName = (item['activity_name'] ??
                                        item['task_name'] ??
                                        item['name'] ??
                                        item['activity_key'] ??
                                        '')
                                    .toString();
                                return ListTile(
                                  title: Text(tName),
                                  onTap: () => Navigator.pop(context, item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      final tName = (selected['activity_name'] ??
              selected['task_name'] ??
              selected['name'] ??
              selected['activity_key'] ??
              '')
          .toString();
      final tId = (selected['activity_id'] ??
              selected['id'] ??
              selected['task_id'] ??
              '')
          .toString();
      final tDesc = (selected['description'] ??
              selected['task_description'] ??
              '')
          .toString();

      DateTime? sDate;
      if (selected['start_date'] != null &&
          selected['start_date'].toString().isNotEmpty) {
        try {
          sDate = DateTime.parse(selected['start_date'].toString());
        } catch (_) {}
      }
      DateTime? eDate;
      if (selected['completed_date'] != null &&
          selected['completed_date'].toString().isNotEmpty) {
        try {
          eDate = DateTime.parse(selected['completed_date'].toString());
        } catch (_) {}
      } else if (selected['end_date'] != null &&
          selected['end_date'].toString().isNotEmpty) {
        try {
          eDate = DateTime.parse(selected['end_date'].toString());
        } catch (_) {}
      }

      setState(() {
        tasks[taskIndex].controller.text = tName;
        tasks[taskIndex].taskId = tId.isNotEmpty ? tId : null;
        if (tDesc.isNotEmpty) {
          tasks[taskIndex].descriptionController.text = tDesc;
        }
        if (sDate != null) {
          tasks[taskIndex].startDate = sDate;
        }
        if (eDate != null) {
          tasks[taskIndex].endDate = eDate;
        }
      });
    }
  }

  Future<void> _showSingleAssignedStaffSelectionDialog(
      BuildContext context, int taskIndex) async {
    List<Staff> filteredStaff = List.from(staffList);
    TextEditingController searchController = TextEditingController();

    final selected = await showDialog<dynamic>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Assigned Staff'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Staff',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredStaff = staffList
                              .where((staff) => staff.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredStaff.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return ListTile(
                              title: const Text('Unassigned'),
                              onTap: () => Navigator.pop(context, '0'),
                            );
                          }
                          final staff = filteredStaff[index - 1];
                          return ListTile(
                            title: Text(staff.name),
                            onTap: () =>
                                Navigator.pop(context, staff.userIdStaff),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        tasks[taskIndex].assignedStaffId =
            selected == '0' ? null : selected.toString();
      });
    }
  }

  Future<void> _showMultiSupportingStaffSelectionDialogForTask(
      BuildContext context, int taskIndex) async {
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        final tempSelected =
            List<String>.from(tasks[taskIndex].supportingStaffIds);
        List<Staff> filteredStaff = List.from(staffList);
        TextEditingController searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Supporting Staffs'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Staff',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredStaff = staffList
                              .where((staff) => staff.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredStaff.length,
                        itemBuilder: (context, index) {
                          final staff = filteredStaff[index];
                          return CheckboxListTile(
                            title: Text(staff.name),
                            value: tempSelected.contains(staff.userIdStaff),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  tempSelected.add(staff.userIdStaff);
                                } else {
                                  tempSelected.remove(staff.userIdStaff);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempSelected),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        tasks[taskIndex].supportingStaffIds = selected;
      });
    }
  }

  Widget _buildNotificationOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMultiStaffSelectionDialog(
      BuildContext context, bool isForParticipants) async {
    final currentSelection =
        isForParticipants ? participantIds : selectedStaffIds;
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        final tempSelected = List<String>.from(currentSelection);
        List<Staff> filteredStaff = List.from(staffList);
        TextEditingController searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isForParticipants
                  ? 'Select Chat Participants'
                  : 'Select Staff to Notify'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Staff',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredStaff = staffList
                              .where((staff) => staff.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredStaff.length,
                        itemBuilder: (context, index) {
                          final staff = filteredStaff[index];
                          return CheckboxListTile(
                            title: Text(staff.name),
                            value: tempSelected.contains(staff.userIdStaff),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  tempSelected.add(staff.userIdStaff);
                                } else {
                                  tempSelected.remove(staff.userIdStaff);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempSelected),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
    if (selected != null && mounted) {
      setState(() {
        if (isForParticipants) {
          participantIds = selected;
        } else {
          selectedStaffIds = selected;
        }
      });
    }
  }
}
