import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/attendanceHistoryModel.dart';
import 'package:login2/service/service.dart';

class AttendanceHistory extends StatefulWidget {
  final String staffId;
  final DateTime selectedDate;

  const AttendanceHistory({
    super.key,
    required this.staffId,
    required this.selectedDate,
  });

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  late DateTime selectedDate;
  AttendanceHistoryModel? historyData;
  bool isLoading = true;

  final timeFormat = DateFormat('hh:mm a');
  final dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);

    final res = await HttpService.getAttendanceHistory(
      staffId: widget.staffId,
      date: selectedDate,
    );

    setState(() {
      historyData = res;
      isLoading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateStr = DateFormat("dd MMM yyyy").format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(dateStr),
        backgroundColor: const Color.fromARGB(255, 21, 141, 221),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyData == null || historyData!.data.isEmpty
              ? const Center(child: Text("No history available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyData!.data.length,
                  itemBuilder: (context, index) {
                    final item = historyData!.data[index];
                    final isLast = index == historyData!.data.length - 1;

                    // Colors & icons based on action
                    final color = item.action == "create"
                        ? Colors.green
                        : Colors.orange;
                    final icon = item.action == "create"
                        ? Icons.login
                        : Icons.update;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline indicator
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: color.withOpacity(0.2),
                              child: Icon(icon, size: 14, color: color),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 70,
                                color: Colors.grey.shade300,
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Card
                        Expanded(
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.action.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.description,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Updated by: ${item.updatedBy}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Right content (time + date)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        timeFormat.format(item.updatedDate),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateFormat.format(item.updatedDate),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
