import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:login2/models/lead_management/staffCallSummaryModel.dart';
import 'package:login2/models/lead_management/staffWorkSummaryModel.dart';
import 'package:login2/service/service.dart';

class TotalSummeryPage extends StatefulWidget {
  const TotalSummeryPage({super.key});

  @override
  State<TotalSummeryPage> createState() => _TotalSummeryPageState();
}

class _TotalSummeryPageState extends State<TotalSummeryPage>
    with TickerProviderStateMixin {
  late DateTime selectedDate;
  late TabController _tabController;

  List<StaffWork> staffWorks = [];
  List<StaffCalls> staffCalls = [];
  String searchQuery = '';

  bool isLoadingWorks = true;
  bool isLoadingCalls = true;

  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _tabController = TabController(length: 2, vsync: this);
    _blinkController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    fetchDoneWorks(selectedDate);
    fetchDoneCalls(selectedDate);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  Future<void> fetchDoneWorks(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    setState(() => isLoadingWorks = true);
    try {
      final response = await HttpService.getAllDoneworks(formattedDate);
      if (response != null) {
        setState(() {
          staffWorks = response.data;
        });
      }
    } catch (e) {
      print("Error fetching done works: $e");
    } finally {
      setState(() => isLoadingWorks = false);
    }
  }

  Future<void> fetchDoneCalls(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    setState(() => isLoadingCalls = true);
    try {
      final response = await HttpService.getAllDonecalls(formattedDate);
      if (response != null) {
        setState(() {
          staffCalls = response.data;
        });
      }
    } catch (e) {
      print("Error fetching done calls: $e");
    } finally {
      setState(() => isLoadingCalls = false);
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchDoneWorks(selectedDate);
      fetchDoneCalls(selectedDate);
    }
  }

  String getFormattedDisplayDate() {
    return DateFormat('dd-MM-yyyy').format(selectedDate);
  }


/// Modified to handle isCompleted check
Widget buildStatusText(String status, String isCompleted) {
  // ✅ Custom condition: if isCompleted is 1
  if (isCompleted == "1") {
    // First resolve the status label from the status code
    String label;
    switch (status) {
      case '1':
        label = 'New';
        break;
      case '2':
        label = 'Pending';
        break;
      case '3':
        label = 'Completed';
        break;
      case '4':
        label = 'In-Progress';
        break;
      case '5':
        label = 'Cancelled';
        break;
      default:
        label = 'Unknown';
    }

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            decoration: TextDecoration.lineThrough, // 🔥 cut line
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Completed",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  // 🔽 Normal status handling if not completed
  Color color;
  String label;

  switch (status) {
    case '1':
      color = const Color.fromARGB(255, 56, 148, 235);
      label = 'New';
      break;
    case '2':
      color = const Color.fromARGB(255, 227, 143, 34);
      label = 'Pending';
      break;
    case '3':
      color = Colors.green;
      label = 'Completed';
      break;
    case '4':
      color = const Color.fromARGB(255, 200, 181, 37);
      label = 'In-Progress';
      break;
    case '5':
      color = const Color.fromARGB(255, 235, 69, 69);
      label = 'Cancelled';
      break;
    default:
      color = Colors.grey;
      label = 'Unknown';
  }

  if (status == '1' || status == '2') {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        return Opacity(
          opacity: _blinkController.value,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        );
      },
    );
  }

  return Text(
    label,
    style: TextStyle(fontWeight: FontWeight.bold, color: color),
  );
}


  Widget buildWorkTab() {
    final filteredWorks = staffWorks
        .where((staff) =>
            staff.staffName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (isLoadingWorks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredWorks.isEmpty) {
      return const Center(
        child: Text(
          "No work found",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredWorks.length,
      itemBuilder: (context, index) {
        final staff = filteredWorks[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.staffName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      backgroundColor: Colors.green.shade50,
                      label: Text("Login: ${staff.loginTime}",
                          style: const TextStyle(color: Colors.green)),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      backgroundColor: Colors.red.shade50,
                      label: Text("Logout: ${staff.logoutTime}",
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                ...staff.projects.map((project) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${project.customerName ?? "No title"} [${project.projectName}]",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Module: ${project.moduleName}",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: project.tasks.map((task) {
                          bool isExpanded = false;

                          return StatefulBuilder(
                            builder: (context, setInnerState) {
                              final isCompleted =
                                  task.status.toLowerCase() == "completed";
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 24,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          isCompleted
                                              ? Icons.check_circle
                                              : Icons.access_time,
                                          color: isCompleted
                                              ? Colors.green
                                              : const Color.fromARGB(
                                                  255, 238, 141, 31),
                                          size: 20,
                                        ),
                                      ),
                                      if (project.tasks.last != task)
                                        Container(
                                          width: 2,
                                          height: 60,
                                          color: Colors.grey.shade300,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setInnerState(() {
                                          isExpanded = !isExpanded;
                                        });
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    task.taskName,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                buildStatusText(task.status,
                                                    task.isCompleted ?? "0"),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${task.startTime} - ${task.endTime}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54),
                                            ),
                                            AnimatedCrossFade(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              crossFadeState: isExpanded
                                                  ? CrossFadeState.showSecond
                                                  : CrossFadeState.showFirst,
                                              firstChild: Container(),
                                              secondChild: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children:
                                                    task.remarks.map((remark) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 6.0),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text("• ",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54)),
                                                        Expanded(
                                                          child: Text(
                                                            remark,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .blueGrey
                                                                  .shade700,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }).toList(),
                      ),
                      const Divider(thickness: 1, color: Colors.grey),
                      const SizedBox(height: 12),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPhoneCallTab() {
    final filteredCalls = staffCalls
        .where((staff) =>
            staff.staffName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (isLoadingCalls) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredCalls.isEmpty) {
      return const Center(
        child: Text(
          "No calls found",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredCalls.length,
      itemBuilder: (context, index) {
        final staff = filteredCalls[index];
        final calls = staff.calls;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      staff.staffName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Chip(
                      label: Text("Total Called: ${staff.totalCalls}",
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.deepPurple,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text("Login: ${staff.loginTime}",
                          style: const TextStyle(color: Colors.green)),
                      backgroundColor: Colors.green.shade50,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text("Logout: ${staff.logoutTime}",
                          style: const TextStyle(color: Colors.red)),
                      backgroundColor: Colors.red.shade50,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...calls.map((call) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.teal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.phone,
                                size: 10, color: Colors.white),
                          ),
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.teal.shade200,
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                call.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("Duration: ${call.duration}",
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black54)),
                              if (call.startTime != null &&
                                  call.endTime != null)
                                Text(
                                  "Time: ${DateFormat('hh:mm a').format(call.startTime!)} - ${DateFormat('hh:mm a').format(call.endTime!)}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black45),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Summary'),
        backgroundColor: const Color.fromARGB(255, 77, 155, 228),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Work'),
            Tab(text: 'Phonecall'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by staff name...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    getFormattedDisplayDate(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildWorkTab(),
                  buildPhoneCallTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
