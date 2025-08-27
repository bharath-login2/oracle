import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/attendanceAllmodel.dart';
import 'package:login2/models/lead_management/calendarDataModel.dart';
import 'package:login2/models/lead_management/dailyAllCountModel.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import 'package:login2/service/service.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/expense/staffListModel.dart';

class ViewCalendarPage extends StatefulWidget {
  const ViewCalendarPage({super.key});

  @override
  State<ViewCalendarPage> createState() => _ViewCalendarPageState();
}

class _ViewCalendarPageState extends State<ViewCalendarPage>
    with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? selected_day;
  List<Staff> _staffList = [];
  final Map<DateTime, String> _holidays = {};
  final Set<DateTime> _markedDates = {};
  List<AttendanceItem> _attendanceList = [];
  List<LeaveItem> _leaveList = [];
  CalendarDataAllModel? CalendarDetails;
  List<DailyItem> _dailyList = [];
  final bool _showHolidays = true;
  String? isFutureDate;

  @override
  void initState() {
    super.initState();
    _fetchStaffs();
    _fetchAttendanceData(_focusedDay);
    fetchWorkCalendar(_focusedDay);
    fetchDailyCount(_focusedDay);
  }

  Future<void> _fetchStaffs() async {
    final staffData = await HttpService.getStaffs();
    if (staffData != null && staffData.data.isNotEmpty) {
      setState(() {
        _staffList = staffData.data;
      });
    }
  }

  Future<void> _fetchAttendanceData(DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final attendanceData =
        await HttpService.getAttendanceAllData(date: formattedDate);
    if (attendanceData != null &&
        (attendanceData.data.attendance.isNotEmpty ||
            attendanceData.data.leave.isNotEmpty)) {
      setState(() {
        _attendanceList = attendanceData.data.attendance;
        _leaveList = attendanceData.data.leave;
      });
    } else {
      setState(() {
        _attendanceList = [];
        _leaveList = [];
      });
    }
  }

  Future<void> fetchDailyCount(DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final dailyData = await HttpService.getDailyCount(date: formattedDate);

    if (dailyData != null && dailyData.data.isNotEmpty) {
      setState(() {
        _dailyList = dailyData.data;
      });
    } else {
      setState(() {
        _dailyList = [];
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    await _fetchAttendanceData(selectedDay);
    await fetchDailyCount(selectedDay);
    // final isHoliday = _holidays.containsKey(
    //     DateTime(selectedDay.year, selectedDay.month, selectedDay.day));
    // if (isHoliday) {
    //   _showDayActionDialog(context, selectedDay, showHolidayInitially: true);
    // } else if (_attendanceList.isNotEmpty || _leaveList.isNotEmpty) {
    //   _showAttendanceLeaveViewDialog(context, selectedDay);
    // } else {
    //   _showDayActionDialog(context, selectedDay);
    // }
  }

  void _showDayActionDialog(BuildContext context, DateTime date,
      {bool showHolidayInitially = false}) {
    final holidayNameController = TextEditingController();
    final holidayDescController = TextEditingController();
    final reasonController = TextEditingController();
    final today = DateTime.now();
    final selectedDateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final isFutureDate = selectedDateOnly.isAfter(todayOnly);

    if (showHolidayInitially) {
      final holidayKey = DateTime(date.year, date.month, date.day);
      holidayNameController.text = _holidays[holidayKey] ?? '';
    }
    String selectedLeaveType = '';
    bool isHalfDayLeave = false;
    bool isAttendanceHalfDay = false;
    bool isMarkingAttendance = true;
    bool showHolidaySection = showHolidayInitially;
    Set<String> attendanceSelectedIds = {};
    Set<String> leaveSelectedIds = {};

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: StatefulBuilder(builder: (context, setStateDialog) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            width: MediaQuery.of(context).size.width * 0.95,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_calendar, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(date),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!showHolidayInitially) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => setStateDialog(() {
                                showHolidaySection = !showHolidaySection;
                              }),
                              icon: const Icon(Icons.celebration,
                                  color: Colors.deepPurple),
                              label: Text(
                                showHolidaySection
                                    ? "Hide Holiday"
                                    : "Mark Holiday",
                                style:
                                    const TextStyle(color: Colors.deepPurple),
                              ),
                            ),
                          ),
                        ],
                        // if ( showHolidaySection) ...[
                        //   TextField(
                        //     controller: holidayNameController,
                        //     decoration: const InputDecoration(
                        //       labelText: 'Holiday Name',
                        //       prefixIcon: Icon(Icons.celebration),
                        //     ),
                        //   ),
                        //   const SizedBox(height: 10),
                        //   TextField(
                        //     controller: holidayDescController,
                        //     maxLines: 3,
                        //     decoration: const InputDecoration(
                        //       labelText: 'Description',
                        //       prefixIcon: Icon(Icons.description),
                        //     ),
                        //   ),
                        //   const SizedBox(height: 10),
                        //   Align(
                        //     alignment: Alignment.centerRight,
                        //     child: ElevatedButton.icon(
                        //       onPressed: () async {
                        //         await HttpService.markHoliday(
                        //           date: DateFormat('yyyy-MM-dd').format(date),
                        //           name: holidayNameController.text,
                        //           description: holidayDescController.text,
                        //         );
                        //         setState(() {
                        //           _holidays[DateTime(
                        //                   date.year, date.month, date.day)] =
                        //               holidayNameController.text;
                        //         });
                        //         Navigator.pop(context);
                        //       },
                        //       icon: const Icon(Icons.save),
                        //       label: const Text('Save Holiday'),
                        //     ),
                        //   ),
                        //   const Divider(thickness: 1),
                        // ],

                        if (showHolidaySection) ...[
                          TextField(
                            controller: holidayNameController,
                            decoration: const InputDecoration(
                              labelText: 'Holiday Name',
                              prefixIcon: Icon(Icons.celebration),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              ActionChip(
                                label: const Text("Saturday"),
                                onPressed: () {
                                  holidayNameController.text = "Saturday";
                                },
                              ),
                              ActionChip(
                                label: const Text("Sunday"),
                                onPressed: () {
                                  holidayNameController.text = "Sunday";
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: holidayDescController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              prefixIcon: Icon(Icons.description),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await HttpService.markHoliday(
                                  date: DateFormat('yyyy-MM-dd').format(date),
                                  name: holidayNameController.text,
                                  description: holidayDescController.text,
                                );
                                setState(() {
                                  _holidays[DateTime(
                                          date.year, date.month, date.day)] =
                                      holidayNameController.text;
                                });
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.save),
                              label: const Text('Save Holiday'),
                            ),
                          ),
                          const Divider(thickness: 1),
                        ],

                        if (isFutureDate != true && !showHolidaySection) ...[
                          const Text(
                            "Select Typesss",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          RadioListTile<bool>(
                            title: const Text('Mark Attendance'),
                            value: true,
                            groupValue: isMarkingAttendance,
                            onChanged: (val) => setStateDialog(() {
                              isMarkingAttendance = val!;
                            }),
                          ),
                          RadioListTile<bool>(
                            title: const Text('Mark Leave'),
                            value: false,
                            groupValue: isMarkingAttendance,
                            onChanged: (val) => setStateDialog(() {
                              isMarkingAttendance = val!;
                            }),
                          ),
                          const SizedBox(height: 10),
                          if (isMarkingAttendance) ...[
                            CheckboxListTile(
                              title: const Text('Half Day Attendance'),
                              value: isAttendanceHalfDay,
                              onChanged: (val) => setStateDialog(
                                  () => isAttendanceHalfDay = val ?? false),
                            ),
                            SizedBox(
                              height: 300,
                              child: _buildStaffSelector(
                                context,
                                setStateDialog,
                                attendanceSelectedIds,
                                "Attendance",
                              ),
                            ),
                          ] else ...[
                            DropdownButton<String>(
                              isExpanded: true,
                              value: selectedLeaveType.isEmpty
                                  ? null
                                  : selectedLeaveType,
                              hint: const Text("Select Leave Type"),
                              items: ["Casual Leave", "Sick Leave", "Other"]
                                  .map((type) => DropdownMenuItem(
                                      value: type, child: Text(type)))
                                  .toList(),
                              onChanged: (val) => setStateDialog(
                                  () => selectedLeaveType = val ?? ''),
                            ),
                            TextField(
                              controller: reasonController,
                              decoration:
                                  const InputDecoration(hintText: 'Reason'),
                            ),
                            CheckboxListTile(
                              title: const Text("Half Day Leave"),
                              value: isHalfDayLeave,
                              onChanged: (val) => setStateDialog(
                                  () => isHalfDayLeave = val ?? false),
                            ),
                            SizedBox(
                              height: 300,
                              child: _buildStaffSelector(
                                context,
                                setStateDialog,
                                leaveSelectedIds,
                                "Leave",
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 10),
                      if (!showHolidaySection)
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (isMarkingAttendance) {
                              await HttpService.markAttendance(
                                date: DateFormat('yyyy-MM-dd').format(date),
                                staffIds: attendanceSelectedIds.toList(),
                                isHalfDay: isAttendanceHalfDay,
                              );
                            } else {
                              await HttpService.markLeave(
                                date: DateFormat('yyyy-MM-dd').format(date),
                                staffIds: leaveSelectedIds.toList(),
                                leaveType: selectedLeaveType,
                                reason: reasonController.text,
                                isHalfDay: isHalfDayLeave,
                              );
                            }
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.save),
                          label: const Text("Save"),
                        ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showAttendanceLeaveViewDialog(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          constraints: const BoxConstraints(maxHeight: 500),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month,
                      color: Colors.blue, size: 26),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, MMM d, yyyy').format(date),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.pop(context);
                      _showDayActionDialog(context, date);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_leaveList.isNotEmpty)
                        ListView.builder(
                          itemCount: _leaveList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final item = _leaveList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 3,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      const Color.fromARGB(255, 231, 161, 161),
                                  child: const Icon(Icons.beach_access,
                                      color: Color.fromARGB(255, 245, 19, 11)),
                                ),
                                title: Text(item.staffName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Type: ${item.leaveType}",
                                        style: const TextStyle(fontSize: 12)),
                                    Text("Reason: ${item.reason}",
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(child: Text("No leave marked.")),
                        ),
                      const SizedBox(height: 10),
                      if (_attendanceList.isNotEmpty)
                        ListView.builder(
                          itemCount: _attendanceList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final item = _attendanceList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 3,
                              child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ViewWorkPage(
                                        staffId: item.staffId,
                                        selectedDate: _selectedDay,
                                      ),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade100,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: item.status == "Full Day"
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  item.staffName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Status: ${item.status}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Login: ${item.loginTime} - ${item.logoutTime} (${item.workingHours})",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Work time: ${item.workTime}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(child: Text("No attendance marked.")),
                        ),
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

  String calculateWorkingHours(String loginTime, String logoutTime) {
    try {
      final format = DateFormat("HH:mm");

      final login = format.parse(loginTime);
      final logout = format.parse(logoutTime);

      final diff = logout.difference(login);

      // Format difference as hours:minutes
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;

      return "${hours}h ${minutes}m";
    } catch (e) {
      return "";
    }
  }

  Future<void> fetchWorkCalendar(DateTime date) async {
    final monthyear = DateFormat('yyyy-MM').format(date);
    final response = await HttpService.getMonthyearWork(monthyear: monthyear);
    if (response != null) {
      setState(() {
        CalendarDetails = response;
        _holidays.clear();
        _markedDates.clear();

        for (var h in response.data.holiday) {
          final parts = h.date.split('-');
          final date = DateTime.parse('${parts[2]}-${parts[1]}-${parts[0]}');
          _holidays[date] = h.holidayName;
        }

        for (var a in response.data.attendance) {
          final parts = a.date.split('-');
          _markedDates
              .add(DateTime.parse('${parts[2]}-${parts[1]}-${parts[0]}'));
        }

        for (var l in response.data.leave) {
          final parts = l.date.split('-');
          _markedDates
              .add(DateTime.parse('${parts[2]}-${parts[1]}-${parts[0]}'));
        }
      });
    }
  }

  Widget _buildStaffSelector(
      BuildContext context,
      void Function(void Function()) setModalState,
      Set<String> selectedIds,
      String label) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Select Staffs "),
            TextButton(
              onPressed: () => setModalState(() {
                if (selectedIds.length == _staffList.length) {
                  selectedIds.clear();
                } else {
                  selectedIds.addAll(_staffList.map((e) => e.id));
                }
              }),
              child: Text(selectedIds.length == _staffList.length
                  ? "Deselect All"
                  : "Select All"),
            )
          ],
        ),
        Expanded(
          child: ListView(
            children: _staffList
                .map((staff) => CheckboxListTile(
                      title: Text(staff.name),
                      value: selectedIds.contains(staff.id),
                      onChanged: (checked) => setModalState(() {
                        if (checked ?? false) {
                          selectedIds.add(staff.id);
                        } else {
                          selectedIds.remove(staff.id);
                        }
                      }),
                    ))
                .toList(),
          ),
        )
      ],
    );
  }

  void _showDeleteHolidayDialog(BuildContext context, DateTime date) {
    final formattedDate = DateFormat('EEE, MMM d, yyyy').format(date);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Holiday"),
        content: Text(
            "Are you sure you want to delete the holiday on $formattedDate?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await HttpService.deleteHoliday(
                  date: DateFormat('yyyy-MM-dd').format(date));
              Navigator.pop(context);
              if (mounted) {
                setState(() {
                  _holidays.remove(DateTime(date.year, date.month, date.day));
                  fetchWorkCalendar(_focusedDay);
                });
              }
            },
            icon: const Icon(Icons.delete, size: 16),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 252, 252, 252),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                fetchWorkCalendar(focusedDay);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  shape: BoxShape.circle,
                ),
                holidayDecoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                holidayTextStyle: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              holidayPredicate: (day) =>
                  _holidays.containsKey(DateTime(day.year, day.month, day.day)),
              calendarBuilders:
                  CalendarBuilders(markerBuilder: (context, day, events) {
                final key = DateTime(day.year, day.month, day.day);

                if (_holidays.containsKey(key)) {
                  return Stack(
                    children: [
                      Positioned(
                        bottom: 1,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 233, 104, 104),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _holidays[key] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () {
                            _showDeleteHolidayDialog(context, key);
                          },
                          child: const Icon(
                            Icons.cancel,
                            size: 16,
                            color: Color.fromARGB(255, 233, 100, 100),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (_markedDates.contains(key)) {
                  return const Positioned(
                    bottom: 1,
                    child:
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                  );
                }

                return null;
              }),
              headerStyle: const HeaderStyle(
                  formatButtonVisible: false, titleCentered: true),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LegendDot(color: Colors.orange, label: "Today"),
                  LegendDot(color: Colors.blue, label: "Selected"),
                  LegendDot(
                      color: Color.fromARGB(255, 238, 51, 38),
                      label: "Holiday"),
                  LegendDot(color: Colors.green, label: "Attendance/Leave"),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month,
                      size: 18, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, MMM d, yyyy')
                        .format(_selectedDay ?? _focusedDay),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  //const SizedBox(width: 6),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton.icon(
                  //     onPressed: () {
                  //       final selectedDay = _selectedDay ?? _focusedDay;
                  //       final isHoliday = _holidays.containsKey(DateTime(
                  //           selectedDay.year,
                  //           selectedDay.month,
                  //           selectedDay.day));
                  //       if (isHoliday) {
                  //         _showDayActionDialog(context, selectedDay,
                  //             showHolidayInitially: true);
                  //       } else if (_attendanceList.isNotEmpty ||
                  //           _leaveList.isNotEmpty) {
                  //         _showAttendanceLeaveViewDialog(context, selectedDay);
                  //       } else {
                  //         _showDayActionDialog(context, selectedDay);
                  //       }
                  //     },
                  //     icon: const Icon(Icons.remove_red_eye, size: 18),
                  //     label: const Text("View & Add"),
                  //     style: TextButton.styleFrom(
                  //       foregroundColor: Colors.blue,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       _enhancedLegendCard(
            //         icon: Icons.check_circle,
            //         label: "Present Today",
            //         count:
            //             _dailyList.isNotEmpty ? _dailyList.first.presentCount : 0,
            //         color: Colors.green.shade600,
            //       ),
            //       _enhancedLegendCard(
            //         icon: Icons.beach_access,
            //         label: "Leave Today",
            //         count:
            //             _dailyList.isNotEmpty ? _dailyList.first.absentCount : 0,
            //         color: Colors.redAccent,
            //       ),
            //     ],
            //   ),
            // ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton.icon(
                  //     onPressed: () {
                  //       final selectedDay = _selectedDay ?? _focusedDay;
                  //       final isHoliday = _holidays.containsKey(DateTime(
                  //           selectedDay.year,
                  //           selectedDay.month,
                  //           selectedDay.day));
                  //       if (isHoliday) {
                  //         _showDayActionDialog(context, selectedDay,
                  //             showHolidayInitially: true);
                  //       } else if (_attendanceList.isNotEmpty ||
                  //           _leaveList.isNotEmpty) {
                  //         _showAttendanceLeaveViewDialog(context, selectedDay);
                  //       } else {
                  //         _showDayActionDialog(context, selectedDay);
                  //       }
                  //     },
                  //     icon: const Icon(Icons.remove_red_eye, size: 18),
                  //     label: const Text("View Details"),
                  //     style: TextButton.styleFrom(
                  //       foregroundColor: Colors.blue,
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  Stack(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _enhancedLegendCard(
                              icon: Icons.check_circle,
                              label: "Present Today",
                              count: _dailyList.isNotEmpty
                                  ? _dailyList.first.presentCount
                                  : 0,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 12),
                            _enhancedLegendCard(
                              icon: Icons.beach_access,
                              label: "Leave Today",
                              count: _dailyList.isNotEmpty
                                  ? _dailyList.first.halfDayCount
                                  : 0,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 12),
                            _enhancedLegendCard(
                              icon: Icons.access_time,
                              label: "Half Day",
                              count: 0,
                              color: Colors.orange.shade600,
                            ),
                            const SizedBox(
                                width:
                                    40), // extra space so arrow doesn’t overlap
                          ],
                        ),
                      ),

                      // Arrow indicator
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white
                                    .withOpacity(0.0), // transparent left side
                                Colors.white, // solid right side
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     _enhancedLegendCard(
                  //       icon: Icons.check_circle,
                  //       label: "Present Today",
                  //       count: _dailyList.isNotEmpty
                  //           ? _dailyList.first.presentCount
                  //           : 0,
                  //       color: Colors.green.shade600,
                  //     ),

                  //   ],
                  // ),
                  const SizedBox(height: 15),
                  _attendanceList.isNotEmpty
                      ? Column(
                          children: [
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  final selectedDay =
                                      _selectedDay ?? _focusedDay;
                                  final isHoliday = _holidays.containsKey(
                                      DateTime(selectedDay.year,
                                          selectedDay.month, selectedDay.day));
                                  if (isHoliday) {
                                    _showDayActionDialog(context, selectedDay,
                                        showHolidayInitially: true);
                                  } else if (_attendanceList.isNotEmpty ||
                                      _leaveList.isNotEmpty) {
                                    _showAttendanceLeaveViewDialog(
                                        context, selectedDay);
                                  } else {
                                    _showDayActionDialog(context, selectedDay);
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "View Details",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  final selectedDay =
                                      _selectedDay ?? _focusedDay;
                                  final isHoliday = _holidays.containsKey(
                                      DateTime(selectedDay.year,
                                          selectedDay.month, selectedDay.day));
                                  if (isHoliday) {
                                    _showDayActionDialog(context, selectedDay,
                                        showHolidayInitially: true);
                                  } else if (_attendanceList.isNotEmpty ||
                                      _leaveList.isNotEmpty) {
                                    _showAttendanceLeaveViewDialog(
                                        context, selectedDay);
                                  } else {
                                    _showDayActionDialog(context, selectedDay);
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Add Attendance",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
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
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final IconData? icon;

  const LegendDot({
    super.key,
    required this.color,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon != null
            ? Icon(icon, size: 16, color: color)
            : Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

Widget _enhancedLegendCard({
  required IconData icon,
  required String label,
  required int count,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    width: 160,
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$count Staff",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    ),
  );
}
