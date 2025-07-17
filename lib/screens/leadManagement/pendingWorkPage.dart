import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/projectPendingModel.dart';
import 'package:login2/models/lead_management/staffWisePendingModel.dart';
import 'package:login2/screens/leadManagement/addWork_page.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/filterWidget.dart';
import '../../models/lead_management/workDetailsModel.dart' as workDetails;
import 'package:login2/models/lead_management/workstatus_model.dart'
    as workStatus;

class PendingWorkPage extends StatefulWidget {
  const PendingWorkPage({super.key});

  @override
  State<PendingWorkPage> createState() => _PendingWorkPageState();
}

class _PendingWorkPageState extends State<PendingWorkPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String currentDate;
  StaffSummaryReport? staffData;
  ProjectPendingReport? projectData;
  workDetails.WorkDetailsModel? workStatusDetails;
  String? selectedDate;
  String staffSearchText = '';
  String projectSearchText = '';
  String userIdSelf = '';
  String name = '';
  bool isLoading = true;
  workStatus.WorkStatus? existingWork;
  final staffSearchController = TextEditingController();
  final projectSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Set<int> expandedStaffIndices = {};
  Map<String, dynamic> currentFilters = {};
  bool get isFiltered => currentFilters.isNotEmpty;
  Map<String, dynamic> activeFilters = {};
  List<String> staffNames = [];
  List<String> _extractStaffNames() {
    final names = <String>{};
    if (staffData != null) {
      for (final summary in staffData!.summary) {
        names.add(summary.staffName);
      }
    }
    return names.toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    fetchData();
    getWorkDuration(currentDate);
    checkExistingWorkStatus();
    loadInitialData();
  }

  void fetchData() {
    fetchStaffWork();
    fetchProjectWork();
  }

  Future<void> loadInitialData() async {
    userIdSelf = await Common.getSharedPref("userId") ?? '';
    name = await Common.getSharedPref("name") ?? '';
    setState(() {});
  }

  void _clearFilters() {
    setState(() {
      currentFilters.clear();
      fetchStaffWork();
    });
  }

  Future<void> fetchStaffWork() async {
    final result = await HttpService.pendingStaffWorks(filters: currentFilters);

    if (result == null) {
      debugPrint("❌ Result is null – check API response or model parsing.");
    }

    setState(() {
      staffData = result;
      expandedStaffIndices.clear();
      for (int i = 0; i < (result?.summary.length ?? 0); i++) {
        expandedStaffIndices.add(i);
      }
    });
  }

  Future<void> getWorkDuration(String date) async {
    final userId = staffData?.summary.isNotEmpty == true
        ? staffData!.summary.first.userId
        : null;
    final response =
        await HttpService.getWorkStatusDetails(date, staffId: userId);
    setState(() {
      workStatusDetails = response;
      isLoading = false;
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: FilterWidget(
              pageId: 1,
              initialFilters: currentFilters,
              onApplyFilters: (filters) {
                print('✅ Applied filters: $filters');
                setState(() {
                  currentFilters = Map.from(filters);
                  fetchStaffWork();
                });
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> checkExistingWorkStatus() async {
    final workStatusModel = await HttpService.getWorkStatus();
    setState(() {
      if (workStatusModel != null && workStatusModel.data.isNotEmpty) {
        existingWork = workStatusModel.data.first;
      } else {
        existingWork = null;
      }
    });
  }

  Future<void> fetchProjectWork() async {
    final result = await HttpService.pendingProjectWorks(date: selectedDate);
    setState(() {
      projectData = result;
    });
  }

  void pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      fetchData();
    }
  }

  List<Summary> filteredStaffList() {
    if (staffData == null) return [];
    return staffData!.summary
        .where((s) =>
            s.staffName.toLowerCase().contains(staffSearchText.toLowerCase()))
        .toList();
  }

  List<ProjectSummary> filteredProjectList() {
    if (projectData == null) return [];
    return projectData!.projectSummary
        .where((p) => p.projectName
            .toLowerCase()
            .contains(projectSearchText.toLowerCase()))
        .toList();
  }

  Widget buildStaffTab() {
    if (staffData == null || workStatusDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final staffList = filteredStaffList();
    if (staffList.isEmpty) {
      return const Center(child: Text("No Staff Data Available"));
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: staffList.length,
        itemBuilder: (context, staffIndex) {
          final summary = staffList[staffIndex];
          final isExpanded = expandedStaffIndices.contains(staffIndex);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Header
              Container(
                color: Colors.white, // Match your background
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        expandedStaffIndices.remove(staffIndex);
                      } else {
                        expandedStaffIndices.add(staffIndex);
                      }
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            summary.staffName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          color: Colors.teal,
                          size: 24,
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // Scrollable Content
              if (isExpanded)
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.6, // 60% of screen height
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        ...summary.projects.map((project) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 8),
                                child: Text(
                                  '${project.projectName} [${project.customerName}]',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 4),
                                child: Text(
                                  'Module: ${project.module}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                              ),
                              ...project.tasks.asMap().entries.map((entry) {
                                final task = entry.value;
                                return buildTimelineItem(
                                  title: task.taskName,
                                  subtitle:
                                      'Time: ${task.startTime} - ${task.endTime}',
                                  isFirst: entry.key == 0,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month,
                                            size: 16, color: Colors.indigo),
                                        const SizedBox(width: 6),
                                        Text(task.date),
                                        const Spacer(),
                                        summary.userId == userIdSelf &&
                                                name.toLowerCase() ==
                                                    task.assignedTo
                                                        .toLowerCase()
                                            ? GestureDetector(
                                                onTap: () async {
                                                  final result =
                                                      await HttpService
                                                          .getWorkStatus();
                                                  if (result != null &&
                                                      result.data.isNotEmpty) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            'Logout Blocked'),
                                                        content: const Text(
                                                            'Work is in progress. Please close all work before restarting another.'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(),
                                                            child: const Text(
                                                                'OK'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  } else {
                                                    final workStatusModel =
                                                        await HttpService
                                                            .getWorkStatusPaused(
                                                                task.attendanceId);

                                                    workStatus.WorkStatus?
                                                        newExistingWork;
                                                    if (workStatusModel !=
                                                            null &&
                                                        workStatusModel
                                                            .data.isNotEmpty) {
                                                      newExistingWork =
                                                          workStatusModel
                                                              .data.first;
                                                    }

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddWorkPage(
                                                          workId: "",
                                                          existingWork:
                                                              newExistingWork,
                                                          isPaused: 0,
                                                          Restart: 1,
                                                          onSuccess: () {
                                                            setState(() {
                                                              getWorkDuration(
                                                                  currentDate);
                                                              checkExistingWorkStatus();
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.restart_alt,
                                                        size: 20,
                                                        color: Color.fromARGB(
                                                            255, 29, 183, 230)),
                                                    SizedBox(width: 4),
                                                    Text("Restart",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    29,
                                                                    183,
                                                                    230),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                  ],
                                                ),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text(
                                                  'Assigned By: ${task.assignedBy}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                    if (task.remarks.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: task.remarks.map((remark) {
                                            return Row(
                                              children: [
                                                const Icon(Icons.check_circle,
                                                    size: 16,
                                                    color: Colors.green),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                    child: Text(remark,
                                                        style: const TextStyle(
                                                            fontSize: 13)))
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      task.status == "1"
                                          ? 'Status: To Do'
                                          : task.status == "2"
                                              ? 'Status: Pending'
                                              : 'Status: Completed',
                                      style: TextStyle(
                                        color: task.status == "1"
                                            ? Colors.blue
                                            : task.status == "2"
                                                ? Colors.orange
                                                : Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      task.priority == "1"
                                          ? 'Priority: Low'
                                          : task.priority == "2"
                                              ? 'Priority: Medium'
                                              : 'Priority: High',
                                      style: TextStyle(
                                        color: task.priority == "1"
                                            ? Colors.blue
                                            : task.priority == "2"
                                                ? const Color.fromARGB(
                                                    240, 240, 170, 64)
                                                : const Color.fromARGB(
                                                    255, 248, 55, 7),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Due Date: ${task.dueDate}',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 248, 55, 7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Assigned To: ${task.assignedTo}',
                                      style: const TextStyle(
                                        color:
                                            Color.fromARGB(223, 31, 210, 216),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              })
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget buildProjectTab() {
    if (projectData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final projectList = filteredProjectList();
    if (projectList.isEmpty) {
      return const Center(child: Text("No Project Data Available"));
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ListView.builder(
        itemCount: projectList.length,
        itemBuilder: (context, index) {
          final project = projectList[index];
          return buildTimelineItem(
            title: '${project.projectName} [${project.customerName}]',
            isFirst: index == 0,
            children: project.staffs.map((staff) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: Text(
                      staff.staffName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  ...staff.tasks.map((task) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.task,
                                  size: 18, color: Colors.deepPurple),
                              const SizedBox(width: 6),
                              Expanded(
                                  child: Text(
                                'Task: ${task.taskName}',
                                style: TextStyle(fontSize: 16),
                              )),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 16, color: Colors.deepPurple),
                              const SizedBox(width: 6),
                              Text('Time: ${task.startTime} - ${task.endTime}'),
                            ],
                          ),
                          if (task.remarks.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: task.remarks.map((remark) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle,
                                          size: 16, color: Colors.green),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text('Remark: $remark',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87)),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          SizedBox(
                            height: 12,
                          )
                        ],
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget buildTimelineItem({
    required String title,
    String? subtitle,
    required List<Widget> children,
    bool isFirst = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isFirst ? Colors.orange : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 100,
                color: Colors.grey.shade300,
              )
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    if (subtitle != null && subtitle.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(subtitle,
                            style: const TextStyle(color: Colors.grey)),
                      ),
                    const SizedBox(height: 12),
                    ...children,
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Works"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "Staff Wise"), Tab(text: "Project Wise")],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: staffSearchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Staff',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => setState(() => staffSearchText = val),
                ),
              ),
              Expanded(child: buildStaffTab()),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: projectSearchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Project',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => setState(() => projectSearchText = val),
                ),
              ),
              Expanded(child: buildProjectTab()),
            ],
          ),
        ],
      ),
    );
  }
}
