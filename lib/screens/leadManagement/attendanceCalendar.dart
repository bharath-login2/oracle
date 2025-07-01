import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/service/service.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/expense/staffListModel.dart';

class ViewCalendarPage extends StatefulWidget {
  const ViewCalendarPage({super.key});

  @override
  State<ViewCalendarPage> createState() => _ViewCalendarPageState();
}

class _ViewCalendarPageState extends State<ViewCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Staff> _staffList = [];
  Set<String> _selectedStaffIds = {};
  final Map<DateTime, String> _holidays = {};

  @override
  void initState() {
    super.initState();
    _fetchStaffs();
  }

  Future<void> _fetchStaffs() async {
    final staffData = await HttpService.getStaffs();
    if (staffData != null && staffData.data.isNotEmpty) {
      setState(() {
        _staffList = staffData.data;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _showDayActionModal(context, selectedDay);
  }

  void _showDayActionModal(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Mark Holiday'),
                    Tab(text: 'Mark Attendance/Leave'),
                  ],
                ),
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    children: [
                      _buildHolidayForm(date),
                      _buildAttendanceForm(date),
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

  Widget _buildHolidayForm(DateTime date) {
    final TextEditingController holidayNameController = TextEditingController();
    final TextEditingController holidayDescController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Holiday Name", style: Theme.of(context).textTheme.labelLarge),
          TextField(controller: holidayNameController),
          const SizedBox(height: 10),
          const Text("Description (Optional)"),
          TextField(
            controller: holidayDescController,
            maxLines: 3,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  await HttpService.markHoliday(
                    date: DateFormat('yyyy-MM-dd').format(date),
                    name: holidayNameController.text,
                    description: holidayDescController.text,
                  );
                  setState(() {
                    _holidays[DateTime(date.year, date.month, date.day)] =
                        holidayNameController.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Save Holiday"),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAttendanceForm(DateTime date) {
    String selectedLeaveType = '';
    final TextEditingController reasonController = TextEditingController();
    bool isHalfDay = false;
    bool isMarkingAttendance = true;
    bool isAttendanceHalfDay = false;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text(
                        'Mark Attendance',
                      ),
                      value: true,
                      groupValue: isMarkingAttendance,
                      onChanged: (val) =>
                          setModalState(() => isMarkingAttendance = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Mark Leave'),
                      value: false,
                      groupValue: isMarkingAttendance,
                      onChanged:(val) =>
                          setModalState(() => isMarkingAttendance = val!),
                    ),
                  ),
                ],
              ),
              if (isMarkingAttendance) ...[
                CheckboxListTile(
                  title: const Text("Half Day Attendance"),
                  value: isAttendanceHalfDay,
                  onChanged: (val) =>
                      setModalState(() => isAttendanceHalfDay = val ?? false),
                ),
              ] else ...[
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedLeaveType.isEmpty ? null : selectedLeaveType,
                  hint: const Text("Select Leave Type"),
                  items: ["Casual Leave", "Sick Leave", "Other"]
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setModalState(() => selectedLeaveType = val ?? ''),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(hintText: 'Reason'),
                ),
                CheckboxListTile(
                  title: const Text("Half Day Leave"),
                  value: isHalfDay,
                  onChanged: (val) =>
                      setModalState(() => isHalfDay = val ?? false),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Select Staffs"),
                  TextButton(
                    onPressed: () => setModalState(() {
                      if (_selectedStaffIds.length == _staffList.length) {
                        _selectedStaffIds.clear();
                      } else {
                        _selectedStaffIds = _staffList.map((e) => e.id).toSet();
                      }
                    }),
                    child: Text(_selectedStaffIds.length == _staffList.length
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
                            value: _selectedStaffIds.contains(staff.id),
                            onChanged: (checked) => setModalState(() {
                              if (checked ?? false) {
                                _selectedStaffIds.add(staff.id);
                              } else {
                                _selectedStaffIds.remove(staff.id);
                              }
                            }),
                          ))
                      .toList(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")),
                  ElevatedButton(
                    onPressed: () async {
                      if (isMarkingAttendance) {
                        await HttpService.markAttendance(
                          date: DateFormat('yyyy-MM-dd').format(date),
                          staffIds: _selectedStaffIds.toList(),
                          isHalfDay: isAttendanceHalfDay,
                        );
                      } else {
                        await HttpService.markLeave(
                          date: DateFormat('yyyy-MM-dd').format(date),
                          staffIds: _selectedStaffIds.toList(),
                          leaveType: selectedLeaveType,
                          reason: reasonController.text,
                          isHalfDay: isHalfDay,
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            calendarStyle: CalendarStyle(
              todayDecoration:
                  const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              selectedDecoration:
                  const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              holidayTextStyle: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
            holidayPredicate: (day) =>
                _holidays.containsKey(DateTime(day.year, day.month, day.day)),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final key = DateTime(day.year, day.month, day.day);
                if (_holidays.containsKey(key)) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _holidays[key] ?? '',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            headerStyle: const HeaderStyle(
                formatButtonVisible: false, titleCentered: true),
          ),
        ],
      ),
    );
  }
}
