import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';

import '../../core/common.dart';
import '../../models/lead_management/projectList_model.dart';
import '../../models/lead_management/titleListModel.dart';
import '../../models/lead_management/workstatus_model.dart';
import '../../service/service.dart';

class TaskForm {
  TextEditingController controller;
  String? status;
  String? taskId;
  DateTime createdAt;
  List<TextEditingController> remarksControllers;

  TaskForm({
    required this.controller,
    this.status,
    this.taskId,
    DateTime? createdAt,
    List<TextEditingController>? remarks,
  })  : createdAt = createdAt ?? DateTime.now(),
        remarksControllers = remarks ?? [TextEditingController()];
}

class AddWorkPage extends StatefulWidget {
  final WorkStatus? existingWork;
  final Function() onSuccess;
  final int isPaused;
  final int Restart;
  const AddWorkPage({
    super.key,
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
                  remarks: task.remarks
                      .map((remark) => TextEditingController(text: remark))
                      .toList(),
                ))
            .toList()
        : [
            TaskForm(
              controller: TextEditingController(),
              status: null,
              taskId: null,
              remarks: [TextEditingController()],
            )
          ];

    if (widget.existingWork != null) {
      selectedProjectId = widget.existingWork!.projectId;
      selectedTitleId = widget.existingWork!.title;
      if (selectedProjectId == "0") {
        selectedProjectId = null;
      }
    }

    _initAsync();
  }

  void _initAsync() async {
    token = await Common.getSharedPref("token") ?? "";
    await _loadProjects();
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
        SnackBar(
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

    DateTime workTime =
        tasks.isNotEmpty ? tasks.first.createdAt : DateTime.now();
    final workData = {
      'work_id': widget.existingWork?.id,
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text,
      'title_id': selectedTitleId,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'work_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(workTime),
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'description': task.controller.text,
          'status': task.status,
          'created_at':
              DateFormat('yyyy-MM-dd HH:mm:ss').format(task.createdAt),
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

  Future<void> _savework() async {
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
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'description': task.controller.text,
          'status': task.status,
          'created_at':
              DateFormat('yyyy-MM-dd HH:mm:ss').format(task.createdAt),
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
    if (selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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

    DateTime workTime =
        tasks.isNotEmpty ? tasks.first.createdAt : DateTime.now();
    final workData = {
      'work_id': widget.existingWork?.id,
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text,
      'title_id': selectedTitleId,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'work_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(workTime),
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'description': task.controller.text,
          'status': task.status,
          'created_at':
              DateFormat('yyyy-MM-dd HH:mm:ss').format(task.createdAt),
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

  Future<void> _restartWork() async {
    if (selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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

    DateTime workTime =
        tasks.isNotEmpty ? tasks.first.createdAt : DateTime.now();
    final workData = {
      'work_id': widget.existingWork?.id,
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text,
      'title_id': selectedTitleId,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'work_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(workTime),
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'description': task.controller.text,
          'status': task.status,
          'created_at':
              DateFormat('yyyy-MM-dd HH:mm:ss').format(task.createdAt),
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
            ? Text(widget.existingWork != null ? 'Stop Work' : 'Start Work')
            : widget.Restart != 1
                ? Text('Pause Work')
                : Text('Restart Work'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
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
                  SizedBox(height: 20),
                  ...List.generate(tasks.length, (taskIndex) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
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
                              SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: tasks[taskIndex].status ?? 'New',
                                  items: ['New', 'Pending', 'Complete']
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(
                                              status,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ))
                                      .toList(),
                                  selectedItemBuilder: (context) {
                                    return ['New', 'Pending', 'Complete']
                                        .map((status) {
                                      return Text(
                                        status,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      );
                                    }).toList();
                                  },
                                  onChanged: (value) => setState(() {
                                    tasks[taskIndex].status = value;
                                  }),
                                  decoration: InputDecoration(
                                    labelText: 'Status',
                                    border: OutlineInputBorder(),
                                  ),
                                  icon: SizedBox.shrink(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                        taskIndex == 0
                                            ? Icons.add
                                            : Icons.close,
                                        color: taskIndex == 0
                                            ? Colors.green
                                            : Colors.red),
                                    onPressed: () {
                                      if (taskIndex == 0) {
                                        setState(() {
                                          tasks.add(TaskForm(
                                            controller: TextEditingController(),
                                            status: null,
                                            taskId: null,
                                            createdAt: DateTime.now(),
                                            remarks: [TextEditingController()],
                                          ));
                                        });
                                      } else {
                                        setState(() {
                                          tasks.removeAt(taskIndex);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              DateFormat('hh:mm a')
                                  .format(tasks[taskIndex].createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),

                           SizedBox(height: 8),
                          ...List.generate(
                              tasks[taskIndex].remarksControllers.length,
                              (remarkIndex) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.all(8),
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
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
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
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.existingWork != null
                          ? Colors.green
                          : Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: _savework,
                    child: Text(
                      widget.existingWork != null ? 'SAVE WORK' : '',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : SizedBox(),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.existingWork != null && widget.Restart != 1
                        ? Colors.red
                        : Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: widget.isPaused == 1 && widget.Restart != 1
                  ? _pauseWork
                  : widget.Restart == 1
                      ? _restartWork
                      : _submitWork,
              child: widget.isPaused == 1
                  ? Text(
                      "Pause Work",
                      style: TextStyle(fontSize: 16),
                    )
                  : widget.Restart == 1
                      ? Text(
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
                          style: TextStyle(
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
                                ? Center(child: Text('No items found'))
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
}
