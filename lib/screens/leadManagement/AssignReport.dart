import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/AssignedWorkModel.dart';
import 'package:login2/models/lead_management/assignedWorkStatusModel.dart';
import 'package:login2/models/lead_management/workDetailsCompanyModel.dart';
import 'package:login2/models/lead_management/workstatus_model.dart'
    as workStatus;
import 'package:login2/screens/leadManagement/addWork_page.dart';
import 'package:login2/screens/leadManagement/assignWorkPage.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/filterWidget.dart';

class AssignReport extends StatefulWidget {
  final String workId;
  const AssignReport({Key? key, required this.workId}) : super(key: key);

  @override
  State<AssignReport> createState() => _AssignReportState();
}

class _AssignReportState extends State<AssignReport> {
  late String currentDate;
  late Future<List<AssignedWork>> assignedWorkFuture;
  Map<String, dynamic> currentFilters = {};
  bool get isFiltered => currentFilters.isNotEmpty;
  workStatus.WorkStatus? existingWork;
  AssignedWorkStatus? assignedWorks;
  bool _showAllTasks = false;
  bool _showAllDescriptions = false;
  WorkCompanyDetailsModel? workStatusDetails;
  String? name;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadData();
    checkAssignedWorks();
    _loadName();
    currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _loadName() async {
    name = await Common.getSharedPref("name");
    setState(() {});
  }

  void _loadData() {
    setState(() {
      assignedWorkFuture =
          HttpService.getAssignedWorks(filters: currentFilters);
    });
  }

  void _clearFilters() {
    setState(() {
      currentFilters.clear();
      _loadData();
    });
  }

  Future<void> getWorkDuration(String date) async {
    final response = await HttpService.getWorkCompanyStatusDetails(date);
    setState(() {
      workStatusDetails = response;
      isLoading = false;
    });
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

  Future<void> checkAssignedWorks() async {
    final AssignedWorkModel =
        await HttpService.getAssinedWorkStatus(widget.workId);
    setState(() {
      if (AssignedWorkModel != null && AssignedWorkModel.data.isNotEmpty) {
        assignedWorks = AssignedWorkModel.data.first;
      } else {
        assignedWorks = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Report", style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          Stack(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignWorkPage(
                            onSuccess: () {
                              setState(() {
                                getWorkDuration(currentDate);
                                checkExistingWorkStatus();
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.filter_alt),
                    onPressed: _showFilters,
                  ),
                ],
              ),
              if (isFiltered)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (isFiltered)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.orange.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt,
                        size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      'Filters applied',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text(
                        'Clear all',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: FutureBuilder<List<AssignedWork>>(
                future: assignedWorkFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.assignment,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            isFiltered
                                ? 'No results match your filters'
                                : 'No assigned works found',
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (isFiltered) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _clearFilters,
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  final assignedItems = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: assignedItems.length,
                    itemBuilder: (context, index) {
                      final item = assignedItems[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.apartment,
                                          color: Colors.indigo, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        item.projectName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: item.priority == "1"
                                              ? const Color.fromARGB(
                                                  255, 225, 243, 255)
                                              : item.priority == "2"
                                                  ? const Color.fromARGB(
                                                      255, 255, 239, 210)
                                                  : const Color.fromARGB(
                                                      255, 255, 223, 223),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          item.priority == "1"
                                              ? "Low"
                                              : item.priority == "2"
                                                  ? "Medium"
                                                  : "High",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: item.priority == "1"
                                                ? const Color.fromARGB(
                                                    255, 25, 140, 247)
                                                : item.priority == "2"
                                                    ? const Color.fromARGB(
                                                        255, 232, 184, 51)
                                                    : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // _buildIconRow(Icons.task_alt, "Task",
                              //     item.taskName, Colors.blueAccent),
                              _buildExpandableIconRow(
                                icon: Icons.task_alt,
                                title: "Tasks",
                                value: item.taskName,
                                color: Colors.blueAccent,
                                isExpanded: _showAllTasks,
                                onTap: () {
                                  setState(() {
                                    _showAllTasks = !_showAllTasks;
                                  });
                                },
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildIconRow(
                                        Icons.person_outline,
                                        "Assigned To",
                                        item.assignedTo,
                                        Colors.deepPurple),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.flag_circle,
                                            size: 16, color: Colors.orange),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.status,
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              _buildIconRow(
                                  Icons.admin_panel_settings,
                                  "Assigned By",
                                  item.assignedBy,
                                  const Color.fromARGB(255, 0, 11, 20)),
                              _buildIconRow(Icons.date_range, "Due Date",
                                  item.dueDate, Colors.red),
                              _buildIconRow(
                                  Icons.date_range,
                                  "Created At",
                                  item.createdAt,
                                  const Color.fromARGB(255, 12, 59, 231)),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    final tasks = item.taskName
                                        .split(',')
                                        .map((e) => e.trim())
                                        .where((e) => e.isNotEmpty)
                                        .toList();

                                    final descriptions = item.taskDescription
                                        .split(',')
                                        .map((e) => e.trim())
                                        .where((e) => e.isNotEmpty)
                                        .toList();

                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Task Details'),
                                        content: SizedBox(
                                          width: double.maxFinite,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: tasks.length,
                                            itemBuilder: (context, index) {
                                              final task = tasks[index];
                                              final description =
                                                  index < descriptions.length
                                                      ? descriptions[index]
                                                      : 'No description';
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 12),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Icon(
                                                            Icons.task_alt,
                                                            size: 18,
                                                            color: Colors.blue),
                                                        const SizedBox(
                                                            width: 6),
                                                        Expanded(
                                                          child: Text(
                                                            'Task: $task',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 24),
                                                      child: Text(
                                                        'Description: $description',
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.visibility,
                                      color: Colors.teal),
                                  label: const Text(
                                    "View Description",
                                    style: TextStyle(color: Colors.teal),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  name?.toLowerCase() ==
                                      item.assignedBy.toLowerCase()
                                  ?
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {},
                                  ):SizedBox(),
                                   name?.toLowerCase() ==
                                      item.assignedBy.toLowerCase()
                                  ?
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {},
                                  ):SizedBox(),
                                  name?.toLowerCase() ==
                                          item.assignedTo.toLowerCase()
                                      ? ElevatedButton.icon(
                                          onPressed: () async {
                                            final result = await HttpService
                                                .getWorkStatus();
                                            if (result != null &&
                                                result.data.isNotEmpty) {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Start Blocked'),
                                                  content: const Text(
                                                      'You already have a work in progress. Please close it before starting a new one.'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddWorkPage(
                                                    workId: item.id,
                                                    existingWork: null,
                                                    isPaused: 0,
                                                    Restart: 0,
                                                    onSuccess: () {
                                                      setState(() {
                                                        final currentDate =
                                                            DateTime.now()
                                                                .toIso8601String();
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
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: const Icon(Icons.play_arrow,
                                              size: 18, color: Colors.white),
                                          label: const Text(
                                            "Start Work",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: FilterWidget(
                  pageId: 2,
                  initialFilters: currentFilters,
                  onApplyFilters: (filters) {
                    setState(() {
                      currentFilters = Map.from(filters);
                      _loadData();
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconRow(
      IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: iconColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableIconRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    final parts = value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final showMore = parts.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              '$title:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: showMore ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.only(left: 26, top: 4, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: !showMore
                  ? [
                      Text(
                        parts.firstOrNull ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      )
                    ]
                  : isExpanded
                      ? parts
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  '- $e',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ))
                          .toList()
                      : [
                          Text(
                            '${parts.first} +${parts.length - 1} more',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          )
                        ],
            ),
          ),
        ),
      ],
    );
  }
}
