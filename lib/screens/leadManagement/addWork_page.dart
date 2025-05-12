import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/lead_management/projectList_model.dart';
import '../../models/lead_management/workstatus_model.dart';
import '../../service/service.dart';
import '../../widgets/textareawidget.dart';

class TaskForm {
  TextEditingController controller;
  String? status;
  String? taskId;
  DateTime createdAt;

  TaskForm({
    required this.controller,
    this.status,
    this.taskId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class AddWorkPage extends StatefulWidget {
  final WorkStatus? existingWork;
  final Function() onSuccess;

  const AddWorkPage({super.key, this.existingWork, required this.onSuccess});

  @override
  _AddWorkPageState createState() => _AddWorkPageState();
}

class _AddWorkPageState extends State<AddWorkPage> {
  late TextEditingController titleController;
  late List<TaskForm> tasks;
  String? selectedProjectId;
  String? selectedProjectName;
  final TextEditingController _searchController = TextEditingController();
  List<Projects> _filteredProjects = [];
  bool _isSearching = false;

  List<Projects> projectList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.existingWork?.title ?? '',
    );
    _searchController.addListener(_filterProjects);
    _filteredProjects = projectList;

    tasks = widget.existingWork != null
        ? widget.existingWork!.tasks
            .map((task) => TaskForm(
                  controller: TextEditingController(text: task.taskName),
                  status: task.status,
                  taskId: task.taskId,
                ))
            .toList()
        : [
            TaskForm(
              controller: TextEditingController(),
              status: null,
              taskId: null,
            )
          ];

    if (widget.existingWork != null) {
      selectedProjectId = widget.existingWork!.projectId;
    }
    _loadProjects();
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

        if (selectedProjectId != null) {
          final exists = projectList.any((p) => p.id == selectedProjectId);
          if (!exists) {
            selectedProjectId = null;
          }
        }
        if (widget.existingWork != null && selectedProjectId != null) {
          selectedProjectName =
              projectList.firstWhere((p) => p.id == selectedProjectId).name;
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

  @override
  void dispose() {
    titleController.dispose();
    for (var task in tasks) {
      task.controller.dispose();
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

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredProjects = projectList;
      }
    });
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

    final workData = {
      'work_id': widget.existingWork?.id,
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text,
      'tasks': tasks
          .map((task) => {
                'task_id': task.taskId,
                'description': task.controller.text,
                'status': task.status,
                'created_at':
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(task.createdAt),
              })
          .toList(),
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
        widget.onSuccess();
        Navigator.pop(context);
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
      'tasks': tasks
          .map((task) => {
                'task_id': task.taskId,
                'description': task.controller.text,
                'status': task.status,
                'created_at':
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(task.createdAt),
              })
          .toList(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingWork != null ? 'Stop Work' : 'Start Work'),
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
                    children: [
                      // Expanded(
                      //   child: DropdownButtonFormField<String>(
                      //     value: isLoading ? null : selectedProjectId,
                      //     items: [
                      //       DropdownMenuItem(
                      //         value: null,
                      //         child: Text(isLoading
                      //             ? 'Loading projects...'
                      //             : 'Select Project'),
                      //       ),
                      //       ...projectList.map((project) => DropdownMenuItem(
                      //             value: project.id,
                      //             child: Text(project.name),
                      //           ))
                      //     ],
                      //     onChanged: (value) {
                      //       setState(() {
                      //         selectedProjectId = value;
                      //         if (value != null) {
                      //           selectedProjectName = projectList
                      //               .firstWhere((p) => p.id == value)
                      //               .name;
                      //         }
                      //       });
                      //     },
                      //     decoration: InputDecoration(
                      //       labelText: 'Project',
                      //       border: OutlineInputBorder(),
                      //     ),
                      //     icon: SizedBox.shrink(),
                      //   ),
                      // ),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true, // ADD THIS!
                          value: isLoading ? null : selectedProjectId,
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text(isLoading
                                  ? 'Loading projects...'
                                  : 'Select Project'),
                            ),
                            ...projectList.map((project) => DropdownMenuItem(
                                  value: project.id,
                                  child: Text(project.name),
                                ))
                          ],
                          selectedItemBuilder: (context) {
                            return [
                              Text(
                                isLoading
                                    ? 'Loading projects...'
                                    : 'Select Project',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              ...projectList.map((project) => Text(
                                    project.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  )),
                            ];
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedProjectId = value;
                              if (value != null) {
                                selectedProjectName = projectList
                                    .firstWhere((p) => p.id == value)
                                    .name;
                              }
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Project',
                            border: OutlineInputBorder(),
                          ),
                          icon: SizedBox.shrink(),
                        ),
                      ),

                      SizedBox(width: 10),
                      SizedBox(
                        width: 180,
                        child: TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   width: 180,
                      //   child: TextField(
                      //     controller: titleController,
                      //     decoration: InputDecoration(
                      //       labelText: 'Title',
                      //       border: OutlineInputBorder(),
                      //       prefixIcon: IconButton(
                      //         icon: Icon(Icons.add),
                      //         onPressed: () {
                      //           // Add your action here
                      //         },
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ...List.generate(tasks.length, (i) {
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
                              // Expanded(
                              //   flex: 4,
                              //   child: TextField(
                              //     controller: tasks[i].controller,
                              //     decoration: InputDecoration(
                              //       labelText: 'Task Description',
                              //       border: OutlineInputBorder(),
                              //     ),
                              //   ),
                              // ),
                              Expanded(
                                flex: 5,
                                child: TextField(
                                  controller: tasks[i].controller,
                                  minLines: 1,
                                  maxLines: null, 
                                  decoration: const InputDecoration(
                                    labelText: 'Task Description',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),

                              SizedBox(width: 10),
                              // Expanded(
                              //   flex: 2,
                              //   child: DropdownButtonFormField<String>(
                              //     value: tasks[i].status,
                              //     items: ['New', 'Pending', 'Complete']
                              //         .map((status) => DropdownMenuItem(
                              //               value: status,
                              //               child: Text(status),
                              //             ))
                              //         .toList(),
                              //     onChanged: (value) => setState(() {
                              //       tasks[i].status = value;
                              //     }),
                              //     decoration: InputDecoration(
                              //       labelText: 'Status',
                              //       border: OutlineInputBorder(),
                              //     ),
                              //     icon: SizedBox.shrink(),
                              //   ),
                              // ),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: tasks[i].status,
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
                                    tasks[i].status = value;
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
                                    icon: Icon(i == 0 ? Icons.add : Icons.close,
                                        color:
                                            i == 0 ? Colors.green : Colors.red),
                                    onPressed: () {
                                      if (i == 0) {
                                        setState(() {
                                          tasks.add(TaskForm(
                                            controller: TextEditingController(),
                                            status: null,
                                            taskId: null,
                                            createdAt: DateTime.now(),
                                          ));
                                        });
                                      } else {
                                        setState(() {
                                          tasks.removeAt(i);
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
                              DateFormat('hh:mm a').format(tasks[i].createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
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
          widget.existingWork != null
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
                    widget.existingWork != null ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: _submitWork,
              child: Text(
                widget.existingWork != null ? 'STOP WORK' : 'START WORK',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
