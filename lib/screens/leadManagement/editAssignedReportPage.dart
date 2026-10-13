import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/AssignedWorkModel.dart';
import 'package:login2/models/lead_management/priorityStatusModel.dart';
import 'package:login2/models/lead_management/projectList_model.dart';
import 'package:login2/models/lead_management/taskStatusModel.dart';
import 'package:login2/models/lead_management/titleListModel.dart';
import 'package:login2/service/service.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/models/lead_management/submitresponse_model.dart';

class EditTaskForm {
  TextEditingController controller;
  TextEditingController descriptionController;
  String? status;
  String? taskId;
  String? activityId;
  DateTime? startDate;
  DateTime? endDate;
  String? assignedStaffId;
  List<String> supportingStaffIds;
  List<TextEditingController> remarksControllers;
  bool isExisting;

  EditTaskForm({
    required this.controller,
    required this.descriptionController,
    this.status,
    this.taskId,
    this.activityId,
    this.startDate,
    this.endDate,
    this.assignedStaffId,
    List<String>? supportingStaffIds,
    List<TextEditingController>? remarks,
    this.isExisting = false,
  })  : supportingStaffIds = supportingStaffIds ?? [],
        remarksControllers = remarks ?? [TextEditingController()];
}

class EditWorkPage extends StatefulWidget {
  final AssignedWork assignedWork;
  final Function() onSuccess;

  const EditWorkPage({
    super.key,
    required this.assignedWork,
    required this.onSuccess,
  });

  @override
  _EditWorkPageState createState() => _EditWorkPageState();
}

class _EditWorkPageState extends State<EditWorkPage> {
  late TextEditingController titleController;
  late List<EditTaskForm> tasks = [];
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

  List<Projects> filteredProjects = [];
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
  bool _isUpdating = false;
  bool _hasChanges = false;
  late Map<String, dynamic> _originalData;

  // Unit, Site Lift, Stage, and Task selection lists
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

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_filterProjects);
    _initAsync();
    _loadStaffs();
    _loadTaskState();
    _loadPrioState();
    _loadProjectAndTitleData();
    _loadStages();
  }

  void _initializeData() {
    final work = widget.assignedWork;
    titleController = TextEditingController(text: work.moduleName);
    selectedProjectId = work.projectId.toString();
    selectedProjectName = work.projectName;
    selectedProjectController.text = work.projectName;
    selectedStageName = work.moduleName;
    selectedStageId = work.moduleName;
    assignedTo = work.assignedToId.isNotEmpty ? work.assignedToId : "23";

    if (work.unitId.isNotEmpty) {
      selectedUnitId = work.unitId;
      selectedUnitNo = work.unitNo.isNotEmpty ? work.unitNo : work.unitId;
    }
    if (work.siteLiftId.isNotEmpty || work.siteLiftNo.isNotEmpty || work.siteLiftName.isNotEmpty) {
      selectedSiteLiftId = work.siteLiftId.isNotEmpty ? work.siteLiftId : work.siteLiftNo;
      selectedSiteLiftNo = work.siteLiftName.isNotEmpty ? work.siteLiftName : work.siteLiftNo;
    }

    if (work.dueDate.isNotEmpty) {
      try {
        dueDate = DateFormat('dd-MM-yyyy').parse(work.dueDate);
      } catch (e) {
        try {
          dueDate = DateFormat('yyyy-MM-dd').parse(work.dueDate);
        } catch (_) {}
      }
    }

    DateTime? sDate;
    if (work.startDate.isNotEmpty) {
      try {
        sDate = DateFormat('dd-MM-yyyy').parse(work.startDate);
      } catch (e) {
        try {
          sDate = DateFormat('yyyy-MM-dd').parse(work.startDate);
        } catch (_) {}
      }
    }

    priority = _mapPriorityToId(work.priority);

    if (work.workSessions.isNotEmpty) {
      tasks = work.workSessions.map((session) {
        final remarkList = session.remark.isNotEmpty
            ? session.remark
                .split(',')
                .map((r) => TextEditingController(text: r.trim()))
                .toList()
            : [TextEditingController()];

        final supportingStaffIds = session.supportingStaff
            .map((staff) => staff.id)
            .where((id) => id.isNotEmpty)
            .toList();

        return EditTaskForm(
          controller: TextEditingController(text: session.taskName),
          descriptionController:
              TextEditingController(text: session.description),
          status: _mapStatusToId(session.status),
          taskId: session.taskId.isNotEmpty ? session.taskId : work.taskId,
          activityId: session.activityId.isNotEmpty
              ? session.activityId
              : (session.taskId.isNotEmpty ? session.taskId : work.taskId),
          startDate: sDate,
          endDate: dueDate,
          assignedStaffId: work.assignedToId.isNotEmpty ? work.assignedToId : "23",
          supportingStaffIds: supportingStaffIds,
          remarks: remarkList,
          isExisting: true,
        );
      }).toList();
    } else {
      tasks = [
        EditTaskForm(
          controller: TextEditingController(text: work.taskName),
          descriptionController:
              TextEditingController(text: work.taskDescription),
          status: _mapStatusToId(work.status),
          taskId: work.taskId,
          activityId: work.taskId,
          startDate: sDate,
          endDate: dueDate,
          assignedStaffId: work.assignedToId.isNotEmpty ? work.assignedToId : "23",
          supportingStaffIds: [],
          remarks: [TextEditingController()],
          isExisting: false,
        )
      ];
    }

    if (selectedProjectId != null && selectedProjectId!.isNotEmpty) {
      _loadUnitsByProject(selectedProjectId!);
      if (selectedUnitId != null && selectedUnitId!.isNotEmpty) {
        _loadSiteLiftsAndTasks(selectedUnitId!, selectedProjectId!);
      }
    }

    _originalData = _getCurrentData();
  }

  String _mapPriorityToId(String priorityText) {
    switch (priorityText.toLowerCase()) {
      case 'normal':
      case '1':
        return '1';
      case 'high':
      case '2':
        return '2';
      case 'critical':
      case '3':
        return '3';
      default:
        return '1';
    }
  }

  String _mapStatusToId(String statusText) {
    switch (statusText.toLowerCase()) {
      case 'to do':
      case 'todo':
        return '1';
      case 'in progress':
      case 'in-progress':
        return '4';
      case 'pending':
        return '2';
      case 'completed':
        return '3';
      default:
        return '1';
    }
  }

  void _initAsync() async {
    token = await Common.getSharedPref("token") ?? "";
    userId = await Common.getSharedPref("userId") ?? "";
  }

  Future<void> _loadProjectAndTitleData() async {
    try {
      final projectResponse = await HttpService.getProjectList();
      if (projectResponse != null) {
        setState(() {
          projectList = projectResponse.data;
          filteredProjects = List.from(projectList);
          if (selectedProjectId != null) {
            final project = projectList.firstWhere(
              (p) => p.id == selectedProjectId,
              orElse: () => Projects(
                id: selectedProjectId!,
                name: selectedProjectName ?? 'Unknown Project',
              ),
            );
            selectedProjectName = project.name;
            selectedProjectController.text = project.name;
            _loadTitle(selectedProjectId!);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading project data: $e');
    }
  }

  Future<void> _loadTitle(String projectId) async {
    try {
      final response = await HttpService.getTitleList(projectId);
      if (response != null) {
        setState(() {
          titleList = response.data;
          if (titleController.text.isNotEmpty) {
            final titleName = titleController.text;
            var foundTitle = titleList.firstWhere(
              (title) => title.name.toLowerCase() == titleName.toLowerCase(),
              orElse: () => TitleListDet(id: '', name: ''),
            );
            if (foundTitle.id.isEmpty) {
              foundTitle = titleList.firstWhere(
                (title) =>
                    title.name.toLowerCase().contains(titleName.toLowerCase()),
                orElse: () => TitleListDet(id: '', name: ''),
              );
            }
            if (foundTitle.id.isNotEmpty) {
              selectedTitleId = foundTitle.id;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading titles: $e');
    }
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
        unitList = [];
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
        });
      }
    } catch (e) {
      debugPrint('Error loading task list by unit: $e');
    } finally {
      if (mounted) setState(() => isLoadingTasks = false);
    }
  }

  Future<void> _loadStaffs() async {
    final response = await HttpService.getStaffs();
    if (response != null && response.status == true) {
      setState(() {
        staffList = response.data;
        if (widget.assignedWork.notification.staffIds is String) {
          final staffIdString =
              widget.assignedWork.notification.staffIds as String;
          selectedStaffIds =
              staffIdString.split(',').where((id) => id.isNotEmpty).toList();
        } else {
          selectedStaffIds = List<String>.from(
              widget.assignedWork.notification.staffIds);
        }

        if (widget.assignedWork.notification.participantIds is String) {
          final participantIdString =
              widget.assignedWork.notification.participantIds as String;
          participantIds = participantIdString
              .split(',')
              .where((id) => id.isNotEmpty)
              .toList();
        } else {
          participantIds = List<String>.from(
              widget.assignedWork.notification.participantIds);
        }

        whatsappNotification =
            widget.assignedWork.notification.whatsappNotification == "1";
        pushNotification =
            widget.assignedWork.notification.pushNotification == "1";
        notifyOnStart = widget.assignedWork.notification.onStart == "1";
        notifyOnStatusChange = widget.assignedWork.notification.onSave == "1";
        notifyOnComplete = widget.assignedWork.notification.onComplete == "1";
        final hasOtherStaff = selectedStaffIds.any((id) => id != assignedTo);
        notifyOtherPeople = hasOtherStaff;
        notifyToAssignedStaff = selectedStaffIds.contains(assignedTo);
      });
    }
  }

  Future<void> _loadTaskState() async {
    final response = await HttpService.getTaskState();
    if (response != null && response.status == true) {
      setState(() {
        allTaskStates = response.data;
      });
    }
  }

  Future<void> _loadPrioState() async {
    final response = await HttpService.getPrioState();
    if (response != null && response.status == true) {
      setState(() {
        allPriorities = response.data;
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

  Map<String, dynamic> _getCurrentData() {
    return {
      'projectId': selectedProjectId,
      'unitId': selectedUnitId,
      'unitNo': selectedUnitNo,
      'siteLiftId': selectedSiteLiftId,
      'siteLiftNo': selectedSiteLiftNo,
      'stageId': selectedStageId,
      'stageName': selectedStageName,
      'titleId': selectedTitleId,
      'titleName': titleController.text,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'assignedTo': assignedTo,
      'tasks': tasks.map((task) {
        return {
          'name': task.controller.text,
          'description': task.descriptionController.text,
          'status': task.status,
          'taskId': task.taskId,
          'startDate': task.startDate?.toIso8601String(),
          'endDate': task.endDate?.toIso8601String(),
          'assignedStaffId': task.assignedStaffId,
          'supportingStaffIds': task.supportingStaffIds,
          'remarks': task.remarksControllers.map((c) => c.text).toList(),
        };
      }).toList(),
      'whatsappNotification': whatsappNotification,
      'pushNotification': pushNotification,
      'notifyOnStart': notifyOnStart,
      'notifyOnComplete': notifyOnComplete,
      'notifyToAssignedStaff': notifyToAssignedStaff,
      'notifyOnStatusChange': notifyOnStatusChange,
      'notifyOtherPeople': notifyOtherPeople,
      'selectedStaffIds': selectedStaffIds,
      'participantIds': participantIds,
    };
  }

  void _checkForChanges() {
    final currentData = _getCurrentData();
    setState(() {
      _hasChanges = !_areMapsEqual(_originalData, currentData);
    });
  }

  bool _areMapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (map1[key] is List && map2[key] is List) {
        if (!_areListsEqual(map1[key], map2[key])) return false;
      } else if (map1[key] is Map && map2[key] is Map) {
        if (!_areMapsEqual(map1[key], map2[key])) return false;
      } else if (map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }

  bool _areListsEqual(List list1, List list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] is Map && list2[i] is Map) {
        if (!_areMapsEqual(list1[i], list2[i])) return false;
      } else if (list1[i] != list2[i]) {
        return false;
      }
    }
    return true;
  }

  Future<void> _updateWork() async {
    if (_isUpdating) return;
    setState(() {
      _isUpdating = true;
    });

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final workData = {
        'id': widget.assignedWork.id,
        'work_id': widget.assignedWork.id,
        'assignedId': widget.assignedWork.id,
        'project_id': selectedProjectId,
        'project_name': selectedProjectName,
        'unit_id': selectedUnitId,
        'unit_no': selectedUnitNo,
        'site_lift_id': selectedSiteLiftId,
        'site_lift_no': selectedSiteLiftNo,
        'site_lift_name': selectedSiteLiftNo,
        'stage_id': selectedStageId,
        'stage_name': selectedStageName ?? titleController.text,
        'supporting_staff_ids': tasks
            .expand((t) => t.supportingStaffIds)
            .toSet()
            .join(','),
        'title': titleController.text.isNotEmpty
            ? titleController.text
            : 'Work Assignment',
        'title_id': selectedStageId ?? '',
        'due_date':
            dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : null,
        'priority': priority,
        'assigned_to': assignedTo,
        'task_type': taskType,
        'category': category,
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
            'activity_id': (task.activityId != null && task.activityId!.isNotEmpty)
                ? task.activityId
                : (task.taskId ?? ''),
            'task_id': task.taskId,
            'task_name': task.controller.text,
            'activity_name': task.controller.text,
            'description': task.descriptionController.text,
            'task_description': task.descriptionController.text,
            'start_date': task.startDate != null
                ? DateFormat('yyyy-MM-dd').format(task.startDate!)
                : null,
            'end_date': task.endDate != null
                ? DateFormat('yyyy-MM-dd').format(task.endDate!)
                : null,
            'assigned_staff_id': task.assignedStaffId ?? assignedTo ?? '0',
            'assigned_to': task.assignedStaffId ?? assignedTo ?? '0',
            'supporting_staff_ids': task.supportingStaffIds.join(','),
            'status': task.status ?? '1',
            'remarks': task.remarksControllers
                .map((c) => c.text)
                .where((t) => t.isNotEmpty)
                .join(','),
          };
        }).toList(),
      };

      final response = await HttpService().updateAssignedWork(workData);

      if (!mounted) return;
      Navigator.of(context).pop();

      if (response != null && response.status == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                response.message.isNotEmpty ? response.message : 'Assigned work updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                response != null && response.message.isNotEmpty
                    ? response.message
                    : 'Failed to update assigned work'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DISCARD'),
          ),
        ],
      ),
    );
  }

  String _getTaskAssignedStaffName(int taskIndex) {
    final staffId = tasks[taskIndex].assignedStaffId ?? assignedTo;
    if (staffId == null || staffId == "0" || staffId.isEmpty) {
      return 'Select Assigned Staff';
    }
    final found = staffList.firstWhere(
      (s) => s.userIdStaff == staffId || s.id == staffId,
      orElse: () => Staff(id: '', name: '', userIdStaff: ''),
    );
    if (found.name.isNotEmpty) return found.name;
    if (widget.assignedWork.assignedTo.isNotEmpty) {
      return widget.assignedWork.assignedTo;
    }
    return 'Select Assigned Staff';
  }

  String _getTaskSupportingStaffNames(int taskIndex) {
    final ids = tasks[taskIndex].supportingStaffIds;
    if (ids.isEmpty) return 'Select Supporting Staffs';
    final names = ids.map((id) {
      final s = staffList.firstWhere(
        (st) => st.userIdStaff == id || st.id == id,
        orElse: () => Staff(id: '', name: id, userIdStaff: id),
      );
      return s.name.isNotEmpty ? s.name : id;
    }).toList();
    return names.join(', ');
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a86c9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2a86c9), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          _showDiscardDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Edit Assigned Work',
            style: TextStyle(
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
            onPressed: () {
              if (_hasChanges) {
                _showDiscardDialog();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            if (_hasChanges)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.amberAccent),
                      SizedBox(width: 6),
                      Text(
                        'Unsaved',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 22),
              onPressed: _showDiscardDialog,
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
                    // Card 1: Work Details (Project, Unit No, Site Lift No, Stages)
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
                                          await _showProjectSelectionDialog(
                                              context);
                                      if (selected != null) {
                                        setState(() {
                                          selectedProjectId = selected['id'];
                                          selectedProjectName = selected['name'];
                                          selectedProjectController.text =
                                              selected['name'] ?? '';
                                          _loadUnitsByProject(selectedProjectId!);
                                          _checkForChanges();
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              selectedProjectController
                                                      .text.isEmpty
                                                  ? 'Select Project'
                                                  : selectedProjectController
                                                      .text,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: selectedProjectController
                                                        .text.isEmpty
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
                                        border: Border.all(
                                            color: Colors.grey.shade300),
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
                                              : const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.grey,
                                                  size: 18),
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
                                        border: Border.all(
                                            color: Colors.grey.shade300),
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
                                              : const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.grey,
                                                  size: 18),
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

                        // Row 2: Stages *
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
                            InkWell(
                              onTap: () async {
                                await _showStageSelectionDialog(context);
                              },
                              child: Container(
                                height: 44,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedStageName ??
                                            (titleController.text.isNotEmpty
                                                ? titleController.text
                                                : 'Select Stage'),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: (selectedStageName != null ||
                                                  titleController.text.isNotEmpty)
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
                                          _checkForChanges();
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

                                // Activity * field
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
                                  onTap: () => _showTaskSelectionDialog(
                                      context, taskIndex),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
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

                                // Description
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
                                  onChanged: (_) => _checkForChanges(),
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

                                // Start Date & End Date Row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Start Date
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                      color: Colors.red),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          InkWell(
                                            onTap: () async {
                                              final picked =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: task.startDate ??
                                                    DateTime.now(),
                                                firstDate: DateTime(2020),
                                                lastDate: DateTime(2100),
                                              );
                                              if (picked != null) {
                                                setState(() {
                                                  task.startDate = picked;
                                                  _checkForChanges();
                                                });
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 12),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.white,
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      task.startDate != null
                                                          ? DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(
                                                                  task.startDate!)
                                                          : 'Start Date',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: task.startDate !=
                                                                null
                                                            ? Colors.grey[800]
                                                            : Colors.grey[400],
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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

                                    // End Date
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                      color: Colors.red),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          InkWell(
                                            onTap: () async {
                                              final picked =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: task.endDate ??
                                                    dueDate ??
                                                    DateTime.now(),
                                                firstDate: DateTime(2020),
                                                lastDate: DateTime(2100),
                                              );
                                              if (picked != null) {
                                                setState(() {
                                                  task.endDate = picked;
                                                  _checkForChanges();
                                                });
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 12),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.white,
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      task.endDate != null
                                                          ? DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(
                                                                  task.endDate!)
                                                          : 'End Date',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: task.endDate !=
                                                                null
                                                            ? Colors.grey[800]
                                                            : Colors.grey[400],
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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

                                const SizedBox(height: 14),

                                // Assigned Staff Section
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
                                      onTap: () =>
                                          _showSingleAssignedStaffSelectionDialog(
                                              context, taskIndex),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _getTaskAssignedStaffName(
                                                    taskIndex),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: task.assignedStaffId !=
                                                              null &&
                                                          task.assignedStaffId !=
                                                              "0"
                                                      ? Colors.grey[800]
                                                      : Colors.grey[800],
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
                                                    _checkForChanges();
                                                  });
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 4.0),
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

                                // Supporting Staffs Section
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
                                              context, taskIndex),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _getTaskSupportingStaffNames(
                                                    taskIndex),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: task
                                                          .supportingStaffIds
                                                          .isNotEmpty
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
                                tasks.add(EditTaskForm(
                                  controller: TextEditingController(),
                                  descriptionController:
                                      TextEditingController(),
                                  status: allTaskStates.isNotEmpty
                                      ? allTaskStates.first.id
                                      : null,
                                  taskId: null,
                                  startDate: null,
                                  endDate: null,
                                  assignedStaffId: assignedTo,
                                  supportingStaffIds: [],
                                  remarks: [TextEditingController()],
                                ));
                                _checkForChanges();
                              });
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Task'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2a86c9),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Card 3: Notification Settings
                    _buildSectionCard(
                      title: 'Notification Settings',
                      icon: Icons.notifications_active_outlined,
                      children: [
                        _buildNotificationOption(
                          icon: Icons.chat_rounded,
                          iconColor: const Color(0xFF25D366),
                          title: 'WhatsApp Notification',
                          value: whatsappNotification,
                          onChanged: (val) {
                            setState(() {
                              whatsappNotification = val;
                              _checkForChanges();
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildNotificationOption(
                          icon: Icons.notifications_rounded,
                          iconColor: const Color(0xFF2a86c9),
                          title: 'Push Notification',
                          value: pushNotification,
                          onChanged: (val) {
                            setState(() {
                              pushNotification = val;
                              _checkForChanges();
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildNotificationOption(
                          icon: Icons.play_arrow_rounded,
                          iconColor: Colors.amber.shade700,
                          title: 'Notify On Start',
                          value: notifyOnStart,
                          onChanged: (val) {
                            setState(() {
                              notifyOnStart = val;
                              _checkForChanges();
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildNotificationOption(
                          icon: Icons.check_circle_rounded,
                          iconColor: Colors.green,
                          title: 'Notify On Complete',
                          value: notifyOnComplete,
                          onChanged: (val) {
                            setState(() {
                              notifyOnComplete = val;
                              _checkForChanges();
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _showMultiStaffSelectionDialog(
                                    context, false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.people_outline,
                                          size: 16, color: Color(0xFF2a86c9)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          selectedStaffIds.isEmpty
                                              ? 'Staff to Notify'
                                              : '${selectedStaffIds.length} Staff Selected',
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    _showMultiStaffSelectionDialog(context, true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.chat_bubble_outline,
                                          size: 16, color: Color(0xFF2a86c9)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          participantIds.isEmpty
                                              ? 'Chat Participants'
                                              : '${participantIds.length} Selected',
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateWork,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a86c9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'SAVE CHANGES',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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
                fontSize: 13,
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

  Future<dynamic> _showProjectSelectionDialog(BuildContext context) async {
    TextEditingController searchController = TextEditingController();
    List<Projects> filtered = List.from(projectList);

    return showDialog<dynamic>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Project'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Project',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filtered = projectList
                              .where((p) => p.name
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
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final project = filtered[index];
                          return ListTile(
                            title: Text(project.name),
                            onTap: () => Navigator.pop(context, {
                              'id': project.id,
                              'name': project.name,
                            }),
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
        _checkForChanges();
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
        _checkForChanges();
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
        titleController.text = sName;
        _checkForChanges();
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
        tasks[taskIndex].activityId = tId.isNotEmpty ? tId : null;
        if (tDesc.isNotEmpty) {
          tasks[taskIndex].descriptionController.text = tDesc;
        }
        if (sDate != null) {
          tasks[taskIndex].startDate = sDate;
        }
        if (eDate != null) {
          tasks[taskIndex].endDate = eDate;
        }
        _checkForChanges();
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
        final sId = selected == '0' ? null : selected.toString();
        tasks[taskIndex].assignedStaffId = sId;
        assignedTo = sId;
        _checkForChanges();
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
        _checkForChanges();
      });
    }
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
        _checkForChanges();
      });
    }
  }
}
