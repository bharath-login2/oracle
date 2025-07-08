import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/projectPendingModel.dart';
import 'package:login2/models/lead_management/staffWisePendingModel.dart';
import 'package:login2/service/service.dart';

class PendingWorkPage extends StatefulWidget {
  const PendingWorkPage({super.key});

  @override
  State<PendingWorkPage> createState() => _PendingWorkPageState();
}

class _PendingWorkPageState extends State<PendingWorkPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  StaffSummaryReport? staffData;
  ProjectPendingReport? projectData;

  String? selectedDate;
  String staffSearchText = '';
  String projectSearchText = '';

  final staffSearchController = TextEditingController();
  final projectSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchData();
  }

  void fetchData() {
    fetchStaffWork();
    fetchProjectWork();
  }

Future<void> fetchStaffWork() async {
  final result = await HttpService.pendingStaffWorks(date: selectedDate);

  debugPrint("🧪 Got result: $result");

  if (result == null) {
    debugPrint("🚫 Result is null – check API response or model parsing.");
  }

  setState(() {
    staffData = result;
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

  Widget buildTimelineItem({
    required String title,
    String? subtitle,
    required List<Widget> children,
    bool isFirst = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              borderRadius: BorderRadius.circular(12),
            ),
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
                      child: Text(
                        subtitle,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 12),
                  ...children,
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildStaffTab() {
    if (staffData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final staffList = filteredStaffList();

    if (staffList.isEmpty) {
      return const Center(child: Text("No Staff Data Available"));
    }

    return ListView.builder(
      itemCount: staffList.length,
      itemBuilder: (context, staffIndex) {
        final summary = staffList[staffIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                summary.staffName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
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
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ...project.tasks.asMap().entries.map((entry) {
                    final task = entry.value;
                    return buildTimelineItem(
                      title: task.taskName,
                      subtitle: 'Time: ${task.startTime} - ${task.endTime}',
                      isFirst: entry.key == 0,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month,
                                size: 16, color: Colors.indigo),
                            const SizedBox(width: 6),
                            Text(task.date),
                          ],
                        ),
                        if (task.remarks.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: task.remarks.map((remark) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle,
                                        size: 16, color: Colors.green),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        remark,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    );
                  })
                ],
              );
            }),
          ],
        );
      },
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

    return ListView.builder(
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
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
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
                                size: 16, color: Colors.deepPurple),
                            const SizedBox(width: 6),
                            Expanded(child: Text(task.taskName)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Time: ${task.startTime} - ${task.endTime}'),
                        if (task.remarks.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: task.remarks.map((remark) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle,
                                        size: 16, color: Colors.green),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        remark,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Works"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Staff Wise"),
            Tab(text: "Project Wise"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: pickDate,
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// STAFF WISE TAB
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

          /// PROJECT WISE TAB
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
