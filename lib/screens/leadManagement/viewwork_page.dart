import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/leadManagement/addWork_page.dart';
import '../../models/lead_management/workDetailsModel.dart' as workDetails;
import 'package:login2/models/lead_management/workstatus_model.dart'
    as workStatus;
import '../../service/service.dart';

class ViewWorkPage extends StatefulWidget {
  final String staffId;
  const ViewWorkPage({super.key, required this.staffId});

  @override
  State<ViewWorkPage> createState() => _ViewWorkPageState();
}

class _ViewWorkPageState extends State<ViewWorkPage> {
  late String currentDate;
  workDetails.WorkDetailsModel? workStatusDetails;
  workStatus.WorkStatus? existingWork;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getWorkDuration(currentDate);
      checkExistingWorkStatus();
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

  Future<void> getWorkDuration(String date) async {
    final response =
        await HttpService.getWorkStatusDetails(date, staffId: widget.staffId);
    setState(() {
      workStatusDetails = response;
      isLoading = false;
    });
  }

  String _formatDuration(String? duration) {
    if (duration == null || duration.isEmpty) return "0s";
    try {
      if (duration.contains(':')) {
        final parts = duration.split(':');
        if (parts.length == 3) {
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          final seconds = int.parse(parts[2]);
          if (hours > 0) return "${hours}h ${minutes}m";
          if (minutes > 0) return "${minutes}m ${seconds}s";
          return "${seconds}s";
        }
      }
      final seconds = int.tryParse(duration) ?? 0;
      return "${seconds}s";
    } catch (e) {
      return "0s";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Work Timeline"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  currentDate = DateFormat('yyyy-MM-dd').format(picked);
                  isLoading = true;
                });
                await getWorkDuration(currentDate);
              }
            },
          ),
        ],
      ),
      floatingActionButton: existingWork != null
          ? StreamBuilder<DateTime>(
              stream:
                  Stream.periodic(Duration(seconds: 1), (_) => DateTime.now()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();

                final now = snapshot.data!;
                final createdAt = DateTime.parse(existingWork!.createdAt);
                final diff = now.difference(createdAt);
                String timeSince =
                    "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}";

                return FloatingActionButton.extended(
                  onPressed: () async {
                    final workStatusModel = await HttpService.getWorkStatus();
                    workStatus.WorkStatus? newExistingWork;

                    if (workStatusModel != null &&
                        workStatusModel.data.isNotEmpty) {
                      newExistingWork = workStatusModel.data.first;
                    }

                    final paused = await showDialog(
                      context: context,
                      builder: (context) => AddWorkPage(
                        existingWork: newExistingWork,
                        onSuccess: () {
                          setState(() {
                            getWorkDuration(currentDate);
                            checkExistingWorkStatus();
                          });
                        },
                      ),
                    );

                    if (paused == true) {
                      setState(() {
                        existingWork = null;
                      });
                      getWorkDuration(currentDate);
                    }
                  },
                  backgroundColor: Colors.red,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeSince,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.pause, color: Colors.white),
                    ],
                  ),
                );
              },
            )
          : FloatingActionButton(
              onPressed: () async {
                final workStatusModel = await HttpService.getWorkStatus();
                workStatus.WorkStatus? newExistingWork;

                if (workStatusModel != null &&
                    workStatusModel.data.isNotEmpty) {
                  newExistingWork = workStatusModel.data.first;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddWorkPage(
                      existingWork: newExistingWork,
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
              backgroundColor: Colors.green,
              child: Icon(Icons.add, color: Colors.white),
            ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (workStatusDetails == null || workStatusDetails!.data.isEmpty)
              ? const Center(child: Text("No work data available"))
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  itemCount: workStatusDetails!.data.length,
                  itemBuilder: (context, index) {
                    final item = workStatusDetails!.data[index];
                    final isInProgress =
                        item.endTime == "00:00:00" || item.endTime.isEmpty;
                    final showDateHeader = index == 0 ||
                        _getDateFromTime(item.startTime) !=
                            _getDateFromTime(
                                workStatusDetails!.data[index - 1].startTime);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getDayFromTime(currentDate),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _getMonthYearFromTime(currentDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: isInProgress
                                        ? Colors.orange
                                        : Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                if (index != workStatusDetails!.data.length - 1)
                                  Container(
                                    width: 2,
                                     height: _calculateItemHeight(item.tasks) + 210, 
                                    color: Colors.grey.shade300,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8  ),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                item.title ?? "No title",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                softWrap: true,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              item.startTime,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Project: ${item.projectId}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              "Start: ${item.startTime}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              "End: ${isInProgress ? "In Progress" : item.endTime}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isInProgress
                                                    ? Colors.orange
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (item.tasks.isNotEmpty) ...[
                                          const Divider(height: 24),
                                          const Text(
                                            "Tasks :",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...item.tasks.map((task) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(
                                                            task.status),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            task.taskName,
                                                            style: const TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '${task.taskStart} - ${task.taskEnd}',
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey),
                                                              ),
                                                              const SizedBox(width: 15,),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            2),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: _getStatusColor(
                                                                          task
                                                                              .status)
                                                                      .withOpacity(
                                                                          0.2),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                ),
                                                                child: Text(
                                                                  task.status,
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: _getStatusColor(
                                                                        task.status),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ],
                                    ),
                                  ),
                              
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Ideal Time:",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(item.gapDuration),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                    const SizedBox(height: 10,),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  double _calculateItemHeight(List<workDetails.Task> tasks) {
    return 60 + (tasks.length * 28.0);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'new':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getDayFromTime(String? time) {
    final date = _parseDateTime(time);
    return date != null ? DateFormat('dd').format(date) : "--";
  }

  String _getMonthYearFromTime(String? time) {
    final date = _parseDateTime(time);
    return date != null ? DateFormat('MMM yyyy').format(date) : "--- ----";
  }

  String _getDateFromTime(String? time) {
    final date = _parseDateTime(time);
    return date != null ? DateFormat('yyyyMMdd').format(date) : "";
  }

  DateTime? _parseDateTime(String? time) {
    try {
      if (time == null) return null;
      if (time.contains('-') && time.length >= 10) {
        return DateTime.parse(time);
      }
      if (time.contains(':')) {
        final parts = time.split(':');
        if (parts.length == 3) {
          final now = DateTime.now();
          return DateTime(now.year, now.month, now.day, int.parse(parts[0]),
              int.parse(parts[1]), int.parse(parts[2]));
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}