import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/priorityStatusModel.dart';
import 'package:login2/models/lead_management/taskStatusModel.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';

import '../../core/common.dart';
import '../../models/lead_management/projectList_model.dart';
import '../../models/lead_management/titleListModel.dart';
import '../../models/lead_management/workstatus_model.dart';
import '../../service/service.dart';
import 'package:login2/models/expense/staffListModel.dart';

class TaskForm {
  TextEditingController controller; // Task Title
  TextEditingController descriptionController; // Task Description (NEW)
  String? status;
  String? taskId;
  List<TextEditingController> remarksControllers;

  TaskForm({
    required this.controller,
    required this.descriptionController, // NEW
    this.status,
    this.taskId,
    List<TextEditingController>? remarks,
  }) : remarksControllers = remarks ?? [TextEditingController()];
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
  List<Staff> staffList = [];
  List<TaskState> allTaskStates = [];
  List<PrioState> allPriorities = [];

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
                      TextEditingController(text: task.description ?? ''),
                  status: task.status,
                  taskId: task.taskId,
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
  }

  // void _initAsync() async {
  //   token = await Common.getSharedPref("token") ?? "";
  //     userId = await Common.getSharedPref("userId");
  //   await _loadProjects();
  // }
  void _initAsync() async {
    token = await Common.getSharedPref("token") ?? "";
    userId = await Common.getSharedPref("userId");
    await _loadProjects();

    if (assignedTo == null) {
      setState(() {
        assignedTo = userId;
      });
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
            (p) => p.priority.toLowerCase() == 'medium',
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

    final currentUserId = await Common.getSharedPref('user_id');
    if (assignedTo != currentUserId) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Assignment'),
          content: const Text(
            'Are you sure you want to assign this work to another staff?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    final workData = {
      'work_id': widget.existingWork?.id,
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text,
      'title_id': selectedTitleId,
      'due_date':
          dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : null,
      'priority': priority,
      'assigned_to': assignedTo,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'description': task.controller.text,
          'task_description': task.descriptionController.text,
          'status': (task.status != null && task.status.toString().isNotEmpty)
              ? task.status
              : 1,
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
          : await HttpService.assignWorkData(workData);

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingWork != null
                ? 'Work stopped successfully!'
                : 'Work Assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(token),
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
            ? Text(widget.existingWork != null ? 'Stop Work' : 'Assign Work')
            : widget.Restart != 1
                ? const Text('Pause Work')
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
                            prefixIcon: IconButton(
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
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a Module';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(
                                  text: dueDate != null
                                      ? DateFormat('dd-MM-yyyy')
                                          .format(dueDate!)
                                      : '',
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2022),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      dueDate = picked;
                                    });
                                  }
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Due Date',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_month),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: priority,
                                items: allPriorities.isNotEmpty
                                    ? allPriorities.map((prio) {
                                        return DropdownMenuItem(
                                          value: prio.id,
                                          child: Text(
                                            prio.priority,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        );
                                      }).toList()
                                    : [],
                                onChanged: (value) => setState(() {
                                  priority = value;
                                }),
                                decoration: const InputDecoration(
                                  labelText: 'Priority',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Assigned To:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final selected =
                                      await _showStaffSearchDialog(context);
                                  if (selected != null) {
                                    setState(() {
                                      assignedTo = selected['id'];
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    hintText: 'Select Staff',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Text(
                                      //   assignedTo != null &&
                                      //           staffList.isNotEmpty
                                      //       ? staffList
                                      //           .firstWhere(
                                      //             (s) => s.id == assignedTo,
                                      //             orElse: () => Staff(
                                      //                 id: '',
                                      //                 name: 'Not found'),
                                      //           )
                                      //           .name
                                      //       : 'Select Staff',
                                      //   style: const TextStyle(fontSize: 16),
                                      // ),
                                      Text(
                                        assignedTo != null &&
                                                staffList.isNotEmpty
                                            ? staffList
                                                .firstWhere(
                                                  (s) =>
                                                      s.userIdStaff ==
                                                      assignedTo,
                                                  orElse: () => Staff(
                                                      id: '',
                                                      name: 'Not found',
                                                      userIdStaff: ''),
                                                )
                                                .name
                                            : 'Select Staff',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(tasks.length, (taskIndex) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
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
                                  value: tasks[taskIndex].status ??
                                      (allTaskStates.isNotEmpty
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
                                      : [],
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
                              if (taskIndex > 0)
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      tasks.removeAt(taskIndex);
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: tasks[taskIndex].descriptionController,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Task Description',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
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
                                    child: TextField(
                                      controller: tasks[taskIndex]
                                          .remarksControllers[remarkIndex],
                                      minLines: 1,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        labelText: 'Remark ${remarkIndex + 1}',
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!(taskIndex == 0 && remarkIndex == 0))
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        if (tasks[taskIndex]
                                                .remarksControllers
                                                .length >
                                            1) {
                                          _removeRemarkField(
                                              taskIndex, remarkIndex);
                                        }
                                      },
                                    ),
                                  if (remarkIndex ==
                                      tasks[taskIndex]
                                              .remarksControllers
                                              .length -
                                          1)
                                    IconButton(
                                      icon: const Icon(Icons.add,
                                          color: Colors.green),
                                      onPressed: () {
                                        _addRemarkField(taskIndex);
                                      },
                                    ),
                                ],
                              ),
                            );
                          }),
                          if (taskIndex == tasks.length - 1)
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
                                      descriptionController:
                                          TextEditingController(),
                                      status: allTaskStates.isNotEmpty
                                          ? allTaskStates.first.id
                                          : null,
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
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: InkWell(
          //     onTap: _isGettingLocation
          //         ? null
          //         : () async {
          //             setState(() {
          //               isLocationEnabled = !isLocationEnabled;
          //               _isGettingLocation = true;
          //             });

          //             if (isLocationEnabled) {
          //               await _getCurrentLocation();
          //             } else {
          //               currentLatitude = null;
          //               currentLongitude = null;
          //             }

          //             setState(() {
          //               _isGettingLocation = false;
          //             });
          //           },
          //     borderRadius: BorderRadius.circular(4),
          //     child: Row(
          //       children: [
          //         Checkbox(
          //           value: isLocationEnabled,
          //           onChanged: _isGettingLocation
          //               ? null
          //               : (value) async {
          //                   setState(() {
          //                     isLocationEnabled = value ?? false;
          //                     _isGettingLocation = true;
          //                   });

          //                   if (isLocationEnabled) {
          //                     await _getCurrentLocation();
          //                   } else {
          //                     currentLatitude = null;
          //                     currentLongitude = null;
          //                   }

          //                   setState(() {
          //                     _isGettingLocation = false;
          //                   });
          //                 },
          //         ),
          //         const Text(
          //           'Update Location',
          //           style: TextStyle(fontSize: 16),
          //         ),
          //         if (_isGettingLocation) ...[
          //           const SizedBox(width: 8),
          //           const SizedBox(
          //             width: 16,
          //             height: 16,
          //             child: CircularProgressIndicator(strokeWidth: 2),
          //           ),
          //         ],
          //       ],
          //     ),
          //   ),
          // ),
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
              onPressed: _submitWork,
              child: Text(
                widget.existingWork != null ? 'STOP WORK' : 'ASSIGN WORK',
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

  Future<Map<String, String>?> _showStaffSearchDialog(
      BuildContext context) async {
    TextEditingController searchController = TextEditingController();
    FocusNode focusNode = FocusNode();
    List<Staff> filteredStaff = List.from(staffList);

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        // Delay focus request until after build
        Future.delayed(Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(focusNode);
        });

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
                      focusNode: focusNode,
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
                                'id': staff.userIdStaff,
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
