import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/assignedWorkStatusModel.dart';
import 'package:login2/models/lead_management/priorityStatusModel.dart';
import 'package:login2/models/lead_management/taskStatusModel.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';

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
  List<TextEditingController> remarksControllers;
  bool isChecked;

  TaskForm({
    required this.controller,
    this.status,
    this.taskId,
    List<TextEditingController>? remarks,
    this.isChecked = false,
  }) : remarksControllers = remarks ?? [TextEditingController()] {
    if (remarksControllers.isEmpty) {
      remarksControllers.add(TextEditingController());
    }
  }
}

class AddWorkPage extends StatefulWidget {
  final String workId;
  final WorkStatus? existingWork;
  final Function() onSuccess;
  final int isPaused;
  final int Restart;
  const AddWorkPage({
    super.key,
    required this.workId,
    this.existingWork,
    required this.onSuccess,
    this.isPaused = 0,
    this.Restart = 0,
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
                  isChecked: task.status == '4',
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

    _initAsync();
    _loadStaffs();
    _loadTaskState();
    _loadPrioState();
    checkAssignedWorks();
  }

  // void _initAsync() async {
  //   token = await Common.getSharedPref("token") ?? "";
  //     userId = await Common.getSharedPref("userId");
  //   await _loadProjects();
  // }
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

  bool _validateTasks() {
    bool atLeastOneChecked =
        tasks.any((task) => task.status == '4' || task.isChecked);
    if (tasks.isEmpty ||
        !tasks.any((task) => task.controller.text.trim().isNotEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one task to proceed'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (!atLeastOneChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check at least one task to proceed'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> checkAssignedWorks() async {
    if (widget.workId.isEmpty) return;

    final AssignedWorkModel =
        await HttpService.getAssinedWorkStatus(widget.workId, sectionId = "");
    setState(() {
      if (AssignedWorkModel != null && AssignedWorkModel.data.isNotEmpty) {
        assignedWorks = AssignedWorkModel.data.first;

        if (widget.existingWork == null) {
          titleController.text = assignedWorks?.titleName ?? '';
          selectedProjectId = assignedWorks?.projectId;
          selectedProjectName = assignedWorks?.projectName;
          selectedTitleId = assignedWorks?.title;
          dueDate = assignedWorks?.dueDate;
          priority = assignedWorks?.priority;
          assignedTo = assignedWorks?.assignedTo;

          if (selectedProjectName != null) {
            selectedProjectController.text = selectedProjectName!;
          }
          tasks = (assignedWorks?.tasks ?? [])
              .map((task) => TaskForm(
                    controller: TextEditingController(text: task.taskName),
                    status: task.status,
                    taskId: task.taskId,
                    isChecked: task.status == '4',
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
      setState(() {
        titleList = response!.data;
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

  // Future<void> _loadStaffs() async {
  //   final response = await HttpService.getStaffs();
  //   if (response != null && response.status == true) {
  //     staffList = response.data;
  //   }
  // }
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
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLatitude = position.latitude;
      currentLongitude = position.longitude;
    });
    debugPrint('Lat: ${position.latitude}, Long: ${position.longitude}');
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

  void _addRemarkField(int taskIndex) {
    setState(() {
      tasks[taskIndex].remarksControllers.add(TextEditingController());
    });
  }

  void _removeRemarkField(int taskIndex, int remarkIndex) {
    if (tasks[taskIndex].remarksControllers.length > 1) {
      setState(() {
        tasks[taskIndex].remarksControllers.removeAt(remarkIndex);
      });
    }
  }

  Future<void> _submitWork() async {
    if (!_validateTasks()) return;

    if (selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_isGettingLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, fetching location...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (isLocationEnabled &&
        (currentLatitude == null || currentLongitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available yet.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (selectedTitleId == null ||
        selectedTitleId!.isEmpty ||
        titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final workData = {
      'work_id': widget.existingWork?.id,
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text,
      'title_id': selectedTitleId,
      // 'due_date':
      //     dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : null,
      // 'priority': priority,
      // 'assigned_to': assignedTo,

      if (widget.workId != "") 'attendance_id': widget.workId,
      'assignedId': widget.existingWork?.assignedId,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'description': task.controller.text,
          'status': task.status,
          'is_checked': task.isChecked ? 1 : 0,
          'remarks': task.remarksControllers
              .map((controller) => controller.text)
              .where((remark) => remark.isNotEmpty)
              .toList(),
        };
      }).toList(),
    };
    try {
      final response = widget.existingWork != null
          ? await HttpService.updateWorkData(workData)
          : await HttpService.submitWorkData(workData);

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingWork != null
                ? 'Work stopped successfully!'
                : 'Work started successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        ProjectDashboardPermission == "true"
            ? Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  //  builder: (context) => ProjectDashboard(),
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
                (route) => false,
              )
            : Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  //  builder: (context) => Dashboard(token),
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
                (route) => false,
              );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Operation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _savework() async {
    if (!_validateTasks()) return;
    if (selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final workData = {
      'work_id': widget.existingWork?.id,
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text,
      'title_id': selectedTitleId,
      // 'due_date':
      //     dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : null,
      // 'priority': priority,
      // 'assigned_to': assignedTo,
      'assignedId': widget.existingWork?.assignedId,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'description': task.controller.text,
          'status': task.status,
          'is_checked': task.isChecked ? 1 : 0,
          'remarks': task.remarksControllers
              .map((controller) => controller.text)
              .where((remark) => remark.isNotEmpty)
              .toList(),
        };
      }).toList(),
    };
    try {
      final response = await HttpService.saveWorkData(workData);
      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Work saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to save work'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving work: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pauseWork() async {
    if (!_validateTasks()) return;
    if (selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_isGettingLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, fetching location...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (isLocationEnabled &&
        (currentLatitude == null || currentLongitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available yet.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (selectedTitleId == null ||
        selectedTitleId!.isEmpty ||
        titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final workData = {
      'work_id': widget.existingWork?.id,
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text,
      'title_id': selectedTitleId,
      // 'due_date':
      //     dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : null,
      // 'priority': priority,
      // 'assigned_to': assignedTo,
      'assignedId': widget.existingWork?.assignedId,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'description': task.controller.text,
          'status': task.status,
          'remarks': task.remarksControllers
              .map((controller) => controller.text)
              .where((remark) => remark.isNotEmpty)
              .toList(),
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
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));

        ProjectDashboardPermission == "true"
            ? Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  // builder: (context) => ProjectDashboard(),
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
                (route) => false,
              )
            : Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  // builder: (context) => Dashboard(token),
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
                (route) => false,
              );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Operation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restartWork() async {
    if (!_validateTasks()) return;
    if (selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_isGettingLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, fetching location...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (isLocationEnabled &&
        (currentLatitude == null || currentLongitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available yet.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (selectedTitleId == null ||
        selectedTitleId!.isEmpty ||
        titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final workData = {
      'work_id': widget.existingWork?.id,
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text,
      'title_id': selectedTitleId,
      // 'due_date':
      //     dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : null,
      // 'priority': priority,
      // 'assigned_to': assignedTo,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'description': task.controller.text,
          'status': task.status,
          'remarks': task.remarksControllers
              .map((controller) => controller.text)
              .where((remark) => remark.isNotEmpty)
              .toList(),
        };
      }).toList(),
    };
    try {
      final response = await HttpService.restartWork(workData);

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
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));

        ProjectDashboardPermission == "true"
            ? Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  //   builder: (context) => ProjectDashboard(),
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
                (route) => false,
              )
            : Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  //builder: (context) => Dashboard(token),
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
                (route) => false,
              );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Operation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isPaused != 1 && widget.Restart != 1
            ? Text(widget.existingWork != null ? 'Stop Work' : 'Start Work')
            : widget.Restart != 1
                ? const Text('Pause Work')
                : assignedWorks != ""
                    ? const Text('Start Work')
                    : const Text('Restart Work'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
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
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: selectedProjectController,
                          readOnly: true,
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
                          decoration: const InputDecoration(
                            labelText: 'Project',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.work_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a project';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // SizedBox(
                      //   width: 180,
                      //   child: TextFormField(
                      //     controller: titleController,
                      //     readOnly: true,
                      //     onTap: () async {
                      //       final selected =
                      //           await dropTitleDialog(context, titleList);
                      //       if (selected != null) {
                      //         setState(() {
                      //           selectedTitleId = selected['id'];
                      //           titleController.text = selected['name']!;
                      //         });
                      //       }
                      //     },
                      //     decoration: InputDecoration(
                      //       labelText: 'Module',
                      //       border: const OutlineInputBorder(),
                      //       prefixIcon: IconButton(
                      //         icon: const Icon(Icons.add),
                      //         onPressed: () async {
                      //           final newTitle =
                      //               await showProjectTitleDialog(context);
                      //           if (newTitle != null) {
                      //             setState(() {
                      //               titleList.add(newTitle);
                      //               selectedTitleId = newTitle.id;
                      //               titleController.text = newTitle.name;
                      //             });
                      //           }
                      //         },
                      //       ),
                      //     ),
                      //     validator: (value) {
                      //       if (value == null || value.isEmpty) {
                      //         return 'Please select a Module';
                      //       }
                      //       return null;
                      //     },
                      //   ),
                      // ),
                      SizedBox(
                        width: 180,
                        child: TextFormField(
                          controller: titleController,
                          readOnly: true,
                          onTap: () async {
                            final selected =
                                await dropTitleDialog(context, titleList);
                            if (selected != null) {
                              setState(() {
                                selectedTitleId = selected['id'];
                                titleController.text = selected['name']!;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Module',
                            border: const OutlineInputBorder(),
                            prefixIcon: addWorkModule.toString() == "true"
                                ? IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () async {
                                      final newTitle =
                                          await showProjectTitleDialog(context);
                                      if (newTitle != null) {
                                        setState(() {
                                          titleList.add(newTitle);
                                          selectedTitleId = newTitle.id;
                                          titleController.text = newTitle.name;
                                        });
                                      }
                                    },
                                  )
                                : null,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a Module';
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(tasks.length, (taskIndex) {
                    final now = DateTime.now();
                    final formattedTime = DateFormat('hh:mm a').format(now);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tasks[taskIndex].isChecked ||
                                tasks[taskIndex].status == '4'
                            ? Colors.lightBlue.shade50
                            : Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Checkbox(
                              //   value: tasks[taskIndex].status == '4'
                              //       ? true
                              //       : tasks[taskIndex].isChecked,
                              //   onChanged: (value) {
                              //     setState(() {
                              //       // for (var i = 0; i < tasks.length; i++) {
                              //       //   if (i != taskIndex) {
                              //       //     tasks[i].isChecked = false;
                              //       //     final toDoStatus =
                              //       //         allTaskStates.firstWhere(
                              //       //       (status) =>
                              //       //           status.status
                              //       //               .toLowerCase()
                              //       //               .contains('to-do') ||
                              //       //           status.status
                              //       //               .toLowerCase()
                              //       //               .contains('todo'),
                              //       //       orElse: () => allTaskStates.first,
                              //       //     );
                              //       //     tasks[i].status = toDoStatus.id;
                              //       //   }
                              //       // }

                              //       tasks[taskIndex].isChecked = value ?? false;
                              //       if (value == true) {
                              //         final targetStatus =
                              //             allTaskStates.firstWhere(
                              //           (status) =>
                              //               status.id == '4' ||
                              //               status.status
                              //                   .toLowerCase()
                              //                   .contains('progress'),
                              //           orElse: () => allTaskStates.first,
                              //         );
                              //         tasks[taskIndex].status = targetStatus.id;
                              //       }
                              //     });
                              //   },
                              // ),
                              Checkbox(
                                value: tasks[taskIndex].isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      for (var i = 0; i < tasks.length; i++) {
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
                                            orElse: () => allTaskStates.first,
                                          );
                                          tasks[i].status = toDoStatus.id;
                                        }
                                      }
                                      tasks[taskIndex].isChecked = true;
                                      final completedStatus =
                                          allTaskStates.firstWhere(
                                        (status) => status.id == '4',
                                        orElse: () => allTaskStates.firstWhere(
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

                              Expanded(
                                flex: 5,
                                child: TextField(
                                  controller: tasks[taskIndex].controller,
                                  minLines: 1,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    labelText: 'Task Title',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: tasks[taskIndex].status?.isNotEmpty ==
                                          true
                                      ? tasks[taskIndex].status
                                      : (allTaskStates.isNotEmpty
                                          ? allTaskStates.first.id
                                          : null),
                                  items: allTaskStates.isNotEmpty
                                      ? allTaskStates
                                          .map((status) => DropdownMenuItem(
                                                value: status.id,
                                                child: Text(
                                                  status.status,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ))
                                          .toList()
                                      : [], // Empty list if no task states
                                  selectedItemBuilder: (context) {
                                    return allTaskStates.map((status) {
                                      return Text(
                                        status.status,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      );
                                    }).toList();
                                  },
                                  onChanged: (value) => setState(() {
                                    tasks[taskIndex].status = value;
                                  }),
                                  decoration: const InputDecoration(
                                    labelText: 'Status',
                                    border: OutlineInputBorder(),
                                  ),
                                  icon: const SizedBox.shrink(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  if (taskIndex != 0)
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          tasks.removeAt(taskIndex);
                                        });
                                      },
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        ' $formattedTime',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(
                              tasks[taskIndex].remarksControllers.length,
                              (remarkIndex) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        TextField(
                                          controller: tasks[taskIndex]
                                              .remarksControllers[remarkIndex],
                                          minLines: 1,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Remark ${remarkIndex + 1}',
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      remarkIndex == 0
                                          ? Icons.add
                                          : Icons.remove,
                                      color: remarkIndex == 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    onPressed: () {
                                      if (remarkIndex == 0) {
                                        _addRemarkField(taskIndex);
                                      } else {
                                        _removeRemarkField(
                                            taskIndex, remarkIndex);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (taskIndex == 0)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(Icons.add_circle_outline,
                                    color: Colors.green),
                                label: const Text(
                                  "Add Task",
                                  style: TextStyle(color: Colors.green),
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
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: InkWell(
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
                      }

                      setState(() {
                        _isGettingLocation = false;
                      });
                    },
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Checkbox(
                    value: isLocationEnabled,
                    onChanged: _isGettingLocation
                        ? null
                        : (value) async {
                            setState(() {
                              isLocationEnabled = value ?? false;
                              _isGettingLocation = true;
                            });

                            if (isLocationEnabled) {
                              await _getCurrentLocation();
                            } else {
                              currentLatitude = null;
                              currentLongitude = null;
                            }

                            setState(() {
                              _isGettingLocation = false;
                            });
                          },
                  ),
                  const Text(
                    'Update Location',
                    style: TextStyle(fontSize: 16),
                  ),
                  if (_isGettingLocation) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
            ),
          ),
          widget.existingWork != null &&
                  widget.isPaused != 1 &&
                  widget.Restart != 1
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.existingWork != null
                          ? Colors.green
                          : Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _savework,
                    child: Text(
                      widget.existingWork != null ? 'SAVE WORK' : '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.existingWork != null && widget.Restart != 1
                        ? Colors.red
                        : Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: widget.isPaused == 1 && widget.Restart != 1
                  ? _pauseWork
                  : widget.Restart == 1
                      ? _restartWork
                      : _submitWork,
              child: widget.isPaused == 1
                  ? const Text(
                      "Pause Work",
                      style: TextStyle(fontSize: 16),
                    )
                  : widget.Restart == 1
                      ? const Text(
                          "Restart Work",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.existingWork != null
                              ? 'STOP WORK'
                              : 'START WORK',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
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
                          } else if (title == "Customers") {
                            filterCustomers(value);
                          } else if (title == "Template") {
                            filterTemplates(value);
                          } else {
                            filterProducts(value);
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 8),
                        labelStyle: TextStyle(color: Colors.grey),
                        labelText: 'Search...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ListView.builder(
                  itemCount: title == "Projects"
                      ? filteredProjects.length
                      : title == "Customers"
                          ? filteredNames.length
                          : title == "Template"
                              ? filteredTemplates.length
                              : filteredProducts.length,
                  itemBuilder: (context, index) {
                    final project =
                        title == "Projects" ? filteredProjects[index] : null;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFFCFBFA),
                        ),
                        child: ListTile(
                          onTap: () {
                            if (title == "Projects") {
                              final project = filteredProjects[index];
                              selectedProjectId = project.id;
                              selectedProjectName = project.name;
                              selectedProjectController.text = project.name;
                            } else if (title == "Customers") {
                              customerIdExisting = filteredNames[index].id;
                              customerNameExisting.text =
                                  filteredNames[index].name;
                            } else if (title == "Template") {
                              templateIdExisting = filteredTemplates[index].id;
                              remindMeExisting.text =
                                  filteredTemplates[index].templateName;
                            } else {
                              final p = filteredProducts[index];
                              productIdExisting = p.id;
                              productNameExisting.text = p.productName;
                              prodRateExisting.text = p.sellingPrice;
                              prodTaxExisting.text = p.taxPercent;
                              typeDuration = p.noOfDays;
                              calculateTotalExisting();
                            }
                            Navigator.pop(context, {
                              'id': project!.id,
                              'name': project.name,
                            });
                            setState(() {});
                            search.clear();
                            return;
                          },
                          title: Text(
                            title == "Projects"
                                ? filteredProjects[index].name
                                : title == "Customers"
                                    ? filteredNames[index].name
                                    : title == "Template"
                                        ? filteredTemplates[index].templateName
                                        : filteredProducts[index].productName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          leading: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: (title == "Projects" &&
                                        filteredProjects.isEmpty) ||
                                    (title == "Customers" &&
                                        filteredNames.isEmpty) ||
                                    (title == "Template" &&
                                        filteredTemplates.isEmpty) ||
                                    (title == "Products" &&
                                        filteredProducts.isEmpty)
                                ? const Center(child: Text('No items found'))
                                : ListView.builder(
                                    itemCount: title == "Projects"
                                        ? filteredProjects.length
                                        : title == "Customers"
                                            ? filteredNames.length
                                            : title == "Template"
                                                ? filteredTemplates.length
                                                : filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      return null;
                                    },
                                  ),
                          ),
                        ),
                      ),
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

  Future<Map<String, String>?> dropTitleDialog(
      BuildContext context, List<TitleListDet> titleList) async {
    TextEditingController searchController = TextEditingController();
    final FocusNode searchFocusNode = FocusNode();
    List<TitleListDet> filteredTitles = List.from(titleList);

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!searchFocusNode.hasFocus) {
                FocusScope.of(context).requestFocus(searchFocusNode);
              }
            });

            return AlertDialog(
              scrollable: true,
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    focusNode: searchFocusNode,
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Modules...',
                      border: OutlineInputBorder(),
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
                ],
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ListView.builder(
                  itemCount: filteredTitles.length,
                  itemBuilder: (context, index) {
                    final title = filteredTitles[index];
                    return ListTile(
                      title: Text(title.name),
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
            return AlertDialog(
              title: const Text('Add Module'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await dropDialogExisting(context, "Projects");
                        setState(() {
                          projectController.text = selectedProjectName ?? '';
                        });
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: projectController,
                          decoration: const InputDecoration(
                            labelText: 'Select Project',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Module',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedProjectId == null ||
                        titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please select a project and enter a title'),
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
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Add this method to your _AddWorkPageState class
  // Future<Map<String, String>?> _showStaffSearchDialog(
  //     BuildContext context) async {
  //   TextEditingController searchController = TextEditingController();
  //   List<Staff> filteredStaff = List.from(staffList);

  //   return showDialog<Map<String, String>>(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: const Text('Select Staff'),
  //             content: SizedBox(
  //               width: double.maxFinite,
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   TextField(
  //                     controller: searchController,
  //                     decoration: const InputDecoration(
  //                       labelText: 'Search Staff',
  //                       prefixIcon: Icon(Icons.search),
  //                     ),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         filteredStaff = staffList
  //                             .where((staff) => staff.name
  //                                 .toLowerCase()
  //                                 .contains(value.toLowerCase()))
  //                             .toList();
  //                       });
  //                     },
  //                   ),
  //                   const SizedBox(height: 16),
  //                   Expanded(
  //                     child: ListView.builder(
  //                       shrinkWrap: true,
  //                       itemCount: filteredStaff.length,
  //                       itemBuilder: (context, index) {
  //                         final staff = filteredStaff[index];
  //                         return ListTile(
  //                           title: Text(staff.name),
  //                           onTap: () {
  //                             Navigator.pop(context, {
  //                               'id': staff.id,
  //                               'name': staff.name,
  //                             });
  //                           },
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  Future<Map<String, String>?> _showStaffSearchDialog(
      BuildContext context) async {
    TextEditingController searchController = TextEditingController();
    List<Staff> filteredStaff = List.from(staffList);

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Staff'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Staff',
                        prefixIcon: Icon(Icons.search),
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
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredStaff.length,
                        itemBuilder: (context, index) {
                          final staff = filteredStaff[index];
                          return ListTile(
                            title: Text(staff.name),
                            onTap: () {
                              Navigator.pop(context, {
                                'id': staff
                                    .userIdStaff, // Use userIdStaff instead of id
                                'name': staff.name,
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
}
