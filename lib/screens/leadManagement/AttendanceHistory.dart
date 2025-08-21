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
                    final color = item.action == "create"
                        ? Colors.green
                        : Colors.orange;
                    final icon = item.action == "create"
                        ? Icons.login
                        : Icons.update;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 20,
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: color,
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 60,
                                color: Colors.grey.shade400,
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.15),
                                child: Icon(icon, color: color),
                              ),
                              title: Text(
                                item.action.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text("Updated by: ${item.updatedBy}"),
                              trailing: Text(
                                "At: ${item.updatedTime}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
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
