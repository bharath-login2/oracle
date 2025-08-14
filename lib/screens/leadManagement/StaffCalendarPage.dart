import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/attendnceListModel.dart';
import 'package:login2/models/lead_management/workDetailsCompanyModel.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import 'package:login2/screens/staff_reports/timeline_page.dart';
import 'package:login2/service/service.dart';
import 'package:table_calendar/table_calendar.dart';

class StaffCalendarPage extends StatefulWidget {
  final String staffId;
  final DateTime selectedDate;
  final String staffName;
  const StaffCalendarPage({
    super.key,
    required this.staffId,
    required this.selectedDate,
    required this.staffName,
  });

  @override
  State<StaffCalendarPage> createState() => _StaffCalendarPageState();
}

class _StaffCalendarPageState extends State<StaffCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, Map<String, String>> attendanceMap = {};
  bool isLoading = true;
  WorkCompanyDetailsModel? workStatusDetails;
  String searchText = '';
  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
    fetchWorkStatusDetails();
  }

  Future<void> fetchWorkStatusDetails() async {
    final currentDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    final response = await HttpService.getWorkCompanyStatusDetails(currentDate);
    setState(() {
      workStatusDetails = response;
      isLoading = false;
    });
  }

  Future<void> fetchAttendanceData([DateTime? selectedMonth]) async {
    try {
      final DateTime currentMonth = selectedMonth ?? _focusedDay;

      final String yearMonth =
          "${currentMonth.year.toString().padLeft(4, '0')}-${currentMonth.month.toString().padLeft(2, '0')}";
      final AttendanceDataModel? result = await HttpService.getAttendanceData(
          widget.staffId, yearMonth,
          monthYear: '');
      if (result != null) {
        Map<DateTime, Map<String, String>> parsedData = {};
        for (var item in result.data.calendarData) {
          final date =
              DateTime.utc(item.date.year, item.date.month, item.date.day);
          String status = "unknown";
          if (item.type == "holiday") {
            status = "holiday";
          } else if (item.type == "leave") {
            if (item.title.toLowerCase().contains("half")) {
              status = "half";
            } else {
              status = "leave";
            }
          } else if (item.title.toLowerCase().contains("full")) {
            status = "present";
          } else if (item.title.toLowerCase().contains("half")) {
            status = "half";
          } else {
            status = "present";
          }
          parsedData[date] = {
            "title": item.title,
            "status": status,
            "login": item.loginTime.isNotEmpty ? item.loginTime : "--",
            "logout": item.logoutTime.isNotEmpty ? item.logoutTime : "--",
          };
        }
        final firstDay = DateTime.utc(_focusedDay.year, _focusedDay.month, 1);
        final lastDay =
            DateTime.utc(_focusedDay.year, _focusedDay.month + 1, 0);
        final today = DateTime.now();

        for (DateTime date = firstDay;
            !date.isAfter(lastDay);
            date = date.add(const Duration(days: 1))) {
          if (!parsedData.containsKey(date)) {
            if (!date.isAfter(today)) {
              parsedData[date] = {
                "title": "Absent",
                "status": "absent",
                "login": "--",
                "logout": "--",
              };
            } else {
              parsedData[date] = {
                "title": "Not Added",
                "status": "not_added",
                "login": "--",
                "logout": "--",
              };
            }
          }
        }

        setState(() {
          attendanceMap = parsedData;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching attendance: $e");
      setState(() => isLoading = false);
    }
  }

  Color _getDayColor(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    final data = attendanceMap[key];
    if (data == null) return Colors.transparent;

    switch (data["status"]) {
      case "present":
        return Colors.green.shade400;
      case "half":
        return Colors.orange.shade400;
      case "holiday":
        return Colors.blue.shade400;
      case "absent":
      case "leave":
        return Colors.red.shade400;
      default:
        return Colors.transparent;
    }
  }

  void _showLoginLogoutPopup(DateTime day) {
    final now = DateTime.now();
    if (day.isAfter(now)) {
      return;
    }

    final key = DateTime.utc(day.year, day.month, day.day);
    final data = attendanceMap[key];

    final title = data?["title"] ?? "Not Added";
    final status = data?["status"] ?? "Not Added";
    final login = data?["login"] ?? "--";
    final logout = data?["logout"] ?? "--";

    bool isLeave = false;
    bool isHalfDay = false;
    bool isEditing = false;
    String selectedLeaveType = '';
    String selectedWorkStatus = 'Full Day';

    List<String> leaveTypes = ["Sick Leave", "Casual Leave", "Other"];
    List<String> workStatusOptions = ["Full Day", "Half Day"];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Attendance Action - ${day.day.toString().padLeft(2, '0')}-${day.month.toString().padLeft(2, '0')}-${day.year}",
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEditing || title == "Absent") ...[
                      const Text("Select Action",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 10,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => isLeave = true),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<bool>(
                                  value: true,
                                  groupValue: isLeave,
                                  onChanged: (val) =>
                                      setState(() => isLeave = true),
                                ),
                                const Text("Mark Leave"),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => isLeave = false),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<bool>(
                                  value: false,
                                  groupValue: isLeave,
                                  onChanged: (val) =>
                                      setState(() => isLeave = false),
                                ),
                                const Text("Mark Attendance"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (isLeave) ...[
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: "Leave Type",
                            border: OutlineInputBorder(),
                          ),
                          value: selectedLeaveType.isNotEmpty
                              ? selectedLeaveType
                              : null,
                          items: leaveTypes.map((type) {
                            return DropdownMenuItem(
                                value: type, child: Text(type));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => selectedLeaveType = value ?? ''),
                        ),
                        const SizedBox(height: 10),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Half Day Leave"),
                          value: isHalfDay,
                          onChanged: (val) =>
                              setState(() => isHalfDay = val ?? false),
                        ),
                      ] else ...[
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: "Work Status",
                            border: OutlineInputBorder(),
                          ),
                          value: selectedWorkStatus,
                          items: workStatusOptions.map((status) {
                            return DropdownMenuItem(
                                value: status, child: Text(status));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => selectedWorkStatus = value ?? ''),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            final dateStr =
                                "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                            final success = isLeave
                                ? await HttpService.saveLeave(
                                    staffId: widget.staffId,
                                    date: dateStr,
                                    leaveType: selectedLeaveType,
                                    isHalfDay: isHalfDay,
                                  )
                                : await HttpService.saveWork(
                                    staffId: widget.staffId,
                                    date: dateStr,
                                    workStatus: selectedWorkStatus,
                                  );

                            Navigator.pop(context);
                            fetchAttendanceData(_focusedDay);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? (isLeave
                                          ? "Leave Marked Successfully."
                                          : "Work status updated successfully.")
                                      : "Failed to save ${isLeave ? 'leave' : 'work status'}.",
                                ),
                                backgroundColor:
                                    success ? Colors.green : Colors.red,
                              ),
                            );
                          },
                          child:
                              Text(isLeave ? "Save Leave" : "Save Work Status"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                    ],
                    Row(
                      children: [
                        const Text("Existing Info",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                            if (!isEditing && title != "Absent")
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => setState(() => isEditing = true),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _infoRow("Title", title.toUpperCase()),
                    _infoRow("Status", status.toUpperCase()),
                    _infoRow("Login", login),
                    _infoRow("Logout", logout),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[800],
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            final filteredList = workStatusDetails?.data
                                    .where((staff) => staff.name
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()))
                                    .toList() ??
                                [];

                            if (filteredList.isNotEmpty) {
                              final staff = filteredList.firstWhere(
                                (s) => s.staffId == widget.staffId,
                                orElse: () => WorkCompany(
                                  staffId: widget.staffId,
                                  name: '',
                                  taskName: '',
                                  firstLoginTime: '',
                                  lastLogoutTime: '',
                                  status: '',
                                  multiple: 'false',
                                ),
                              );

                              if (staff.multiple == "true") {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Phone Call Log"),
                                      content:
                                          const Text("Choose an action below"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ViewWorkPage(
                                                  staffId: staff.staffId,
                                                  selectedDate: day,
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text("Works"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const TimelinePage(),
                                                settings: RouteSettings(
                                                  arguments: {
                                                    "staffId": staff.staffId,
                                                    "selectedDate": day,
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text("Call Log"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else if (staff.taskName.isEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ViewWorkPage(
                                      staffId: staff.staffId,
                                      selectedDate: day,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TimelinePage(),
                                    settings: RouteSettings(
                                      arguments: {
                                        "staffId": staff.staffId,
                                        "selectedDate": day,
                                      },
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text("View Works"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child:
                  Text("$label:", style: const TextStyle(color: Colors.grey))),
          Expanded(
              flex: 3,
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = workStatusDetails?.data
            .where((staff) =>
                staff.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList() ??
        [];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Calendar"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.person,
                                size: 24, color: Colors.blue),
                            const SizedBox(width: 10),
                            Text(
                              "Staff: ${widget.staffName}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2024, 1, 1),
                          lastDay: DateTime.utc(2026, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: CalendarFormat.month,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                          },
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            leftChevronIcon: const Icon(Icons.chevron_left),
                            rightChevronIcon: const Icon(Icons.chevron_right),
                            headerPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            formatButtonShowsNext: false,
                          ),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                            _showLoginLogoutPopup(selectedDay);
                          },
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                              isLoading = true;
                            });
                            fetchAttendanceData(focusedDay);
                          },
                          calendarStyle: CalendarStyle(
                            weekendTextStyle:
                                const TextStyle(color: Colors.red),
                            defaultTextStyle: const TextStyle(fontSize: 15),
                            todayDecoration: BoxDecoration(
                              color: Colors.teal.shade600,
                              shape: BoxShape.circle,
                            ),
                            defaultDecoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            outsideDaysVisible: false,
                          ),
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, _) {
                              final color = _getDayColor(day);
                              return Container(
                                margin: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: color == Colors.transparent
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              );
                            },
                            todayBuilder: (context, day, _) {
                              return Container(
                                margin: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 2.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Legend",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
                            LegendRow(
                                color: Colors.green,
                                text: "Present",
                                icon: Icons.check_circle),
                            LegendRow(
                                color: Colors.orange,
                                text: "Half Day",
                                icon: Icons.timelapse),
                            LegendRow(
                                color: Colors.blue,
                                text: "Holiday",
                                icon: Icons.beach_access),
                            LegendRow(
                                color: Colors.red,
                                text: "Absent/Leave",
                                icon: Icons.cancel),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class LegendRow extends StatelessWidget {
  final Color color;
  final String text;
  final IconData icon;

  const LegendRow({
    super.key,
    required this.color,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
