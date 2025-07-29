import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/AssignedWorkModel.dart';
import 'package:login2/models/lead_management/assignedWorkStatusModel.dart';
import 'package:login2/models/lead_management/workDetailsCompanyModel.dart';
import 'package:login2/models/lead_management/workstatus_model.dart'
    as workStatus;
import 'package:login2/screens/leadManagement/ChatScreenWork.dart';
import 'package:login2/screens/leadManagement/addWork_page.dart';
import 'package:login2/screens/leadManagement/assignWorkPage.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/filterWidget.dart';
import 'package:login2/models/expense/staffListModel.dart';

class AssignReport extends StatefulWidget {
  final String workId;
  const AssignReport({super.key, required this.workId});

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
  final bool _showAllTasks = false;
  WorkCompanyDetailsModel? workStatusDetails;
  String? name;
  bool isLoading = true;
  bool isRemarkExpanded = false;
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Assign Report",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: _showFilters,
            tooltip: 'Filter',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssignWorkPage(
                onSuccess: () {
                  setState(() {
                    checkExistingWorkStatus();
                  });
                },
              ),
            ),
          );
        },
      ),
      body: Column(
        children: [
          if (isFiltered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.orange.shade100, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text('Filters applied',
                      style: TextStyle(color: Colors.orange)),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear all',
                        style: TextStyle(color: Colors.orange)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<List<AssignedWork>>(
              future: assignedWorkFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text("Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment_outlined,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          isFiltered
                              ? 'No matching assignments found'
                              : 'No work assigned yet',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (isFiltered) ...[
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _clearFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Clear filters',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                final assignedItems = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: assignedItems.length,
                  itemBuilder: (context, index) {
                    final item = assignedItems[index];
                    return _buildAssignmentCard(item, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(AssignedWork item, BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTaskDetails(context, item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.projectName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.moduleName,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 15, 15, 15),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(item.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getPriorityColor(item.priority),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getPriorityText(item.priority),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getPriorityColor(item.priority),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                  Icons.person_outline, "Assigned to", item.assignedTo),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                        Icons.person, "Assigned by", item.assignedBy),
                  ),
                  _buildStatusChip(item.status),
                ],
              ),
              item.dueDate != ""
                  ? _buildInfoRow(
                      Icons.calendar_today, "Due date", item.dueDate)
                  : SizedBox(),
              _buildInfoRow(Icons.work, "Work Status", item.startStatus),
              const SizedBox(height: 12),
              Row(
                children: [
                  // OutlinedButton(
                  //   style: OutlinedButton.styleFrom(
                  //     side: BorderSide(color: Colors.blue.shade800),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: 16, vertical: 8),
                  //   ),
                  //   onPressed: () => _showTaskDetails(context, item),
                  //   child: const Text("View Details",
                  //       style: TextStyle(color: Colors.blue)),
                  // ),
                         if (name?.toLowerCase() == item.assignedTo.toLowerCase())
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.startStatus == "Started"
                            ? const Color.fromARGB(255, 122, 121, 121)
                            : const Color.fromARGB(255, 32, 179, 67),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onPressed: item.startStatus == "Started"
                          ? null
                          : () => _handleStartWork(item),
                      child: Row(
                        children: [
                          Icon(
                            item.startStatus == "Started"
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline,
                            size: 16,
                            color: item.startStatus == "Not Started"
                                ? Colors.white
                                : const Color.fromARGB(255, 179, 32, 32),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.startStatus == "Started"
                                ? "Work Started"
                                : "Start Work",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),   
                      const SizedBox(width: 8),
                      IconButton(
                    icon: Icon(Icons.remove_red_eye,
                        color: Colors.blue.shade800),
                     onPressed: () => _showTaskDetails(context, item),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.blue.shade800),
                      ),
                    ),
                  ),
                   const SizedBox(width: 8),
                      IconButton(
                    icon: Icon(Icons.message,
                        color: const Color.fromARGB(255, 28, 139, 236)),
                    onPressed: () =>   Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreenWork(
                              groupId: item.id
                                  .toString(),
                              nav: "",
                                assignedTo: item.assignedTo,
                                   project: item.projectName,
                                  assignedToId: item.assignedToId.toString(),
                            ),
                          ),
                        ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.blue.shade800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
             
                  // if (name?.toLowerCase() == item.assignedTo.toLowerCase())
                  //   ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: item.startStatus == "Started"
                  //           ? const Color.fromARGB(255, 122, 121, 121)
                  //           : const Color.fromARGB(255, 32, 179, 67),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       padding: const EdgeInsets.symmetric(
                  //           horizontal: 16, vertical: 8),
                  //     ),
                  //     onPressed: item.startStatus == "Started"
                  //         ? null
                  //         : () => _handleStartWork(item),
                  //     child: Row(
                  //       children: [
                  //         Icon(
                  //           item.startStatus == "Started"
                  //               ? Icons.stop_circle_outlined
                  //               : Icons.play_circle_outline,
                  //           size: 16,
                  //           color: item.startStatus == "Not Started"
                  //               ? Colors.white
                  //               : const Color.fromARGB(255, 179, 32, 32),
                  //         ),
                  //         const SizedBox(width: 4),
                  //         Text(
                  //           item.startStatus == "Started"
                  //               ? "Work Started"
                  //               : "Start Work",
                  //           style: const TextStyle(color: Colors.white),
                  //         ),
                  //       ],
                  //     ),
                  //   ),   
                  //     const SizedBox(width: 8),
                      IconButton(
                    icon: Icon(Icons.notification_add,
                        color: Colors.blue.shade800),
                    onPressed: () => _showShareDialog(context, item),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.blue.shade800),
                      ),
                    ),
                  ),

                 
                
                  // const SizedBox(width: 60),
                  // PopupMenuButton<String>(
                  //   onSelected: (value) {
                  //     if (value == 'view') {
                  //       _showTaskDetails(context, item);
                  //     } else if (value == 'chat') {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => ChatScreenWork(
                  //             groupId: item.id
                  //                 .toString(),
                  //             nav: "",
                  //               assignedTo: item.assignedTo,
                  //                  project: item.projectName,
                  //           ),
                  //         ),
                  //       );
                  //     }
                  //   },
                  //   itemBuilder: (context) => [
                  //     const PopupMenuItem(
                  //       value: 'view',
                  //       child: Text('View Details'),
                  //     ),
                  //     const PopupMenuItem(
                  //       value: 'chat',
                  //       child: Text('Chat'),
                  //     ),
                  //   ],
                  //   icon: const Icon(
                  //     Icons.more_vert,
                  //     size: 30,
                  //     color: Color.fromARGB(255, 10, 10, 10),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text("$label:",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: _getStatusColor(status)),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartWork(AssignedWork item) async {
    final result = await HttpService.getWorkStatus();
    if (result != null && result.data.isNotEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Work in Progress"),
          content: const Text(
              "You already have a work in progress. Please complete it before starting a new one."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddWorkPage(
            workId: item.id,
            existingWork: null,
            isPaused: 0,
            Restart: 0,
            onSuccess: () {
              setState(() {
                checkExistingWorkStatus();
              });
            },
          ),
        ),
      );
    }
  }

  void _showTaskDetails(BuildContext context, AssignedWork item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 53, 157, 237),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  color: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assignment, color: Colors.white),
                          const SizedBox(width: 12),
                          const Text(
                            "Assignment Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailHeader(item.projectName, item.moduleName),
                        const SizedBox(height: 24),
                        _buildDetailSection("Overview", [
                          _buildDetailItem("Client", item.clientName),
                          _buildDetailItem(
                              "Priority", _getPriorityText(item.priority)),
                          _buildDetailItem("Status", item.status),
                          _buildDetailItem("Due Date", item.dueDate),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection("Assignment", [
                          _buildDetailItem("Assigned To", item.assignedTo),
                          _buildDetailItem("Assigned By", item.assignedBy),
                          _buildDetailItem("Created At", item.createdAt),
                        ]),
                        const SizedBox(height: 24),
                        _buildWorkSessionsSection(item),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailHeader(String project, String module) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          module,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: items,
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    IconData icon = Icons.info_outline;
    Color iconColor = Colors.blue;

    switch (label.toLowerCase()) {
      case 'client':
        icon = Icons.business;
        iconColor = Colors.teal;
        break;
      case 'priority':
        icon = Icons.priority_high;
        iconColor = Colors.redAccent;
        break;
      case 'status':
        icon = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case 'due date':
        icon = Icons.calendar_today;
        iconColor = Colors.orange;
        break;
      case 'assigned to':
        icon = Icons.person;
        iconColor = Colors.purple;
        break;
      case 'assigned by':
        icon = Icons.supervisor_account;
        iconColor = Colors.indigo;
        break;
      case 'created at':
        icon = Icons.access_time;
        iconColor = Colors.brown;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkSessionsSection(AssignedWork item) {
    if (item.workSessions.isEmpty) {
      return _buildDetailSection("Work Sessions", [
        const Center(
          child: Column(
            children: [
              Icon(Icons.hourglass_empty, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text("No work sessions recorded yet",
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ]);
    }

    return _buildDetailSection("Work Sessions", [
      ...item.workSessions.map((session) {
        return _buildWorkSessionItem(session);
      }),
    ]);
  }

  Widget _buildWorkSessionItem(WorkSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.task_alt, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      session.taskName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if (session.description.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.description,
                          size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Description: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: session.description,
                                style: const TextStyle(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.remove_road_rounded,
                        size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final remarkList = session.remark
                              .split(',')
                              .map((e) => e.trim())
                              .toList();
                          if (remarkList.length > 1) {
                            setState(() {
                              isRemarkExpanded = !isRemarkExpanded;
                            });
                          }
                        },
                        child: Builder(
                          builder: (context) {
                            final remarkList = session.remark
                                .split(',')
                                .map((e) => e.trim())
                                .toList();
                            final hasMore = remarkList.length > 1;

                            final displayText = isRemarkExpanded
                                ? remarkList.join(', ')
                                : hasMore
                                    ? '${remarkList[0]} +${remarkList.length - 1} more'
                                    : remarkList[0];

                            return Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Remarks: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: displayText,
                                    style: const TextStyle(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (session.works.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Work Timeline",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...session.works.map((work) {
                    return _buildTimelineItem(work);
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Work work) {
    String formatDate(String datetime) {
      try {
        final dateTime = DateTime.tryParse(datetime);
        if (dateTime != null) {
          return DateFormat('dd-MM-yyyy').format(dateTime);
        }
        return datetime;
      } catch (e) {
        return datetime;
      }
    }

    String formatTime(String datetime) {
      try {
        final dateTime = DateTime.tryParse(datetime);
        if (dateTime != null) {
          return DateFormat('HH:mm').format(dateTime);
        }
        return datetime;
      } catch (e) {
        return datetime;
      }
    }

    String formatDuration(String duration) {
      if (duration.contains(':')) {
        final parts = duration.split(':');
        if (parts.length == 3) {
          return '${parts[0]}h ${parts[1]}m';
        }
        if (parts.length == 2) {
          return '${parts[0]}m ${parts[1]}s';
        }
      }
      return duration;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 60,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  formatDate(work.workedDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 30,
                  child: Row(
                    children: [
                      // Scrollable chips
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildTimeChip(
                                "Start: ${formatTime(work.startTime)}",
                                Colors.green),
                            const SizedBox(width: 6),
                            _buildTimeChip(
                                "End: ${formatTime(work.endTime)}", Colors.red),
                            const SizedBox(width: 6),
                            _buildTimeChip(
                                "Duration: ${formatDuration(work.duration)}",
                                Colors.blue),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),

                      const Icon(Icons.arrow_forward_ios,
                          size: 10, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            color == Colors.green
                ? Icons.play_arrow
                : color == Colors.red
                    ? Icons.stop
                    : Icons.timer,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePill(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context, AssignedWork item) {
    showDialog(
      context: context,
      builder: (context) {
        bool whatsappNotification = false;
        bool pushNotification = false;
        bool notifyToAssignedStaff = true;
        bool notifyOnStatusChange = false;
        bool notifyOtherPeople = false;
        bool notifyOnStart = false;
        bool notifyOnComplete = false;
        List<String> selectedStaffIds = [];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Notify Work"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Notification Settings",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: whatsappNotification,
                          onChanged: (value) {
                            setState(() {
                              whatsappNotification = value ?? false;
                            });
                          },
                        ),
                        const Text('WhatsApp Notification'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: pushNotification,
                          onChanged: (value) {
                            setState(() {
                              pushNotification = value ?? false;
                            });
                          },
                        ),
                        const Text('Push Notification'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    // New notification options
                    Row(
                      children: [
                        Checkbox(
                          value: notifyToAssignedStaff,
                          onChanged: (value) => setState(
                              () => notifyToAssignedStaff = value ?? false),
                        ),
                        const Text('Notify to Assigned Staff'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: notifyOnStatusChange,
                          onChanged: (value) => setState(
                              () => notifyOnStatusChange = value ?? false),
                        ),
                        const Text('Notify on status change'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: notifyOtherPeople,
                          onChanged: (value) {
                            setState(() {
                              notifyOtherPeople = value ?? false;
                              if (!notifyOtherPeople) {
                                selectedStaffIds.clear();
                              }
                            });
                          },
                        ),
                        const Text('Notify other people'),
                      ],
                    ),

                    if (notifyOtherPeople) ...[
                      const SizedBox(height: 8),
                      const Text('Select Staff to Notify:'),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () async {
                          final selected = await _showMultiStaffSelectionDialog(
                            context,
                            item.assignedTo,
                            selectedStaffIds,
                          );
                          if (selected != null) {
                            setState(() => selectedStaffIds = selected);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedStaffIds.isEmpty
                                    ? 'Select Staff'
                                    : '${selectedStaffIds.length} staff selected',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: notifyOnStart,
                          onChanged: (value) {
                            setState(() {
                              notifyOnStart = value ?? false;
                            });
                          },
                        ),
                        const Text('Notify when work starts'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: notifyOnComplete,
                          onChanged: (value) {
                            setState(() {
                              notifyOnComplete = value ?? false;
                            });
                          },
                        ),
                        const Text('Notify when work completes'),
                      ],
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
                  onPressed: () async {
                    final notificationData = {
                      'work_id': item.id.toString(),
                      'assigned_to': item.assignedToId,
                      'assigned_by': item.assignedBy,
                      'project_name': item.projectName,
                      'task_name': item.taskName,
                      'task_description': item.taskDescription,
                      'priority': item.priority,
                      'due_date': item.dueDate,
                      'whatsapp': whatsappNotification ? '1' : '0',
                      'push': pushNotification ? '1' : '0',
                      'notify_to_assigned': notifyToAssignedStaff ? '1' : '0',
                      'notify_on_status_change':
                          notifyOnStatusChange ? '1' : '0',
                      'notify_other_people': notifyOtherPeople ? '1' : '0',
                      'on_start': notifyOnStart ? '1' : '0',
                      'on_complete': notifyOnComplete ? '1' : '0',
                      'staff_ids': [
                        if (notifyToAssignedStaff) item.assignedToId,
                        if (notifyOtherPeople) ...selectedStaffIds,
                      ].join(','),
                    };

                    final isSuccess = await HttpService.alertWorkNotification(
                        notificationData);

                    if (isSuccess) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Notification sent successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Already Added Once!"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Notify'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<String>?> _showMultiStaffSelectionDialog(
    BuildContext context,
    String assignedTo,
    List<String> initiallySelected,
  ) async {
    List<String> tempSelected = List.from(initiallySelected);

    return await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.group, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Text(
                        "Select Staff to Notify",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search staff...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: FutureBuilder<List<Staff>>(
                    future: (() async {
                      final staffListModel = await HttpService.getStaffs();
                      return staffListModel?.data ?? <Staff>[];
                    })(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("No staff available"),
                          ),
                        );
                      }

                      final staffList = snapshot.data!;

                      final otherStaff = staffList
                          .where((s) => s.userIdStaff != assignedTo)
                          .toList();

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: otherStaff.length,
                                  itemBuilder: (context, index) {
                                    final staff = otherStaff[index];
                                    return CheckboxListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Text(staff.name),
                                      value: tempSelected
                                          .contains(staff.userIdStaff),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            tempSelected.add(staff.userIdStaff);
                                          } else {
                                            tempSelected
                                                .remove(staff.userIdStaff);
                                          }
                                        });
                                      },
                                      secondary:
                                          const Icon(Icons.person_outline),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),

                // Footer buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, tempSelected),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "1":
        return Colors.blue;
      case "2":
        return Colors.orange;
      case "3":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case "1":
        return "Low";
      case "2":
        return "Medium";
      case "3":
        return "High";
      default:
        return "__";
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'To Do':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
