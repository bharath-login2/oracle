import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FollowupCalendarPage extends StatefulWidget {
  const FollowupCalendarPage({Key? key}) : super(key: key);

  @override
  State<FollowupCalendarPage> createState() => _FollowupCalendarPageState();
}

class _FollowupCalendarPageState extends State<FollowupCalendarPage> {
  late DateTime _currentMonth;
  final Map<DateTime, int> _followupData = {};

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    // Clear existing data
    _followupData.clear();
    
    // Current month data
    _followupData[DateTime(now.year, now.month, 1)] = 3;
    _followupData[DateTime(now.year, now.month, 5)] = 1;
    _followupData[DateTime(now.year, now.month, 10)] = 5;
    _followupData[DateTime(now.year, now.month, 15)] = 2;
    _followupData[DateTime(now.year, now.month, 20)] = 4;
    _followupData[DateTime(now.year, now.month, 25)] = 1;
    _followupData[DateTime(now.year, now.month, 27)] = 3;
    _followupData[DateTime(now.year, now.month, 28)] = 2;
    _followupData[DateTime(now.year, now.month, 29)] = 1;
    _followupData[DateTime(now.year, now.month, 30)] = 4;
    _followupData[DateTime(now.year, now.month, 31)] = 2;
    
    // Add data for next month - will NOT show in current month
    final nextMonth = DateTime(now.year, now.month + 1, 3);
    _followupData[nextMonth] = 2;
    
    // Add data for next month 5th
    final nextMonth5 = DateTime(now.year, now.month + 1, 5);
    _followupData[nextMonth5] = 4;
    
    // Today's date
    _followupData[DateTime(now.year, now.month, now.day)] = 3;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    setState(() {
      _currentMonth = DateTime.now();
    });
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;
    
    List<DateTime> days = [];
    
    // Get current month days
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    
    // Add leading days from previous month (empty cells)
    final firstWeekday = firstDay.weekday;
    for (int i = 1; i < firstWeekday; i++) {
      // Create dates from previous month but don't add followup data
      days.insert(0, DateTime(month.year, month.month, 1 - i));
    }
    
    // Add trailing days from next month (empty cells)
    int totalCells = (days.length / 7).ceil() * 7;
    int nextMonthDay = 1;
    while (days.length < totalCells) {
      days.add(DateTime(month.year, month.month + 1, nextMonthDay));
      nextMonthDay++;
    }
    
    return days;
  }

  Widget _buildDateCell(DateTime date) {
    final isCurrentMonth = date.month == _currentMonth.month;
    final isToday = _isSameDay(date, DateTime.now());
    final followupCount = isCurrentMonth ? (_followupData[_normalizeDate(date)] ?? 0) : 0;
    
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isToday ? const Color.fromARGB(255, 47, 144, 201).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isToday 
          ? Border.all(color: const Color.fromARGB(255, 47, 144, 201), width: 2)
          : null,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date.day.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isCurrentMonth ? Colors.black : Colors.grey.shade400,
                ),
              ),
              if (followupCount > 0 && isCurrentMonth) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getFollowupColor(followupCount),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    followupCount.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (!isCurrentMonth)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getFollowupColor(int count) {
    // Using shades of red as per your example
    if (count >= 5) return Colors.red.shade700;
    if (count >= 3) return Colors.red.shade500;
    return Colors.red.shade400;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);
    final todayFollowups = _followupData[_normalizeDate(DateTime.now())] ?? 0;
    final currentMonthFollowups = _getTotalCurrentMonthFollowups();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Followup Calendar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 1,
        backgroundColor: const Color.fromARGB(255, 47, 144, 201),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
       
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      monthName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentMonthFollowups followups this month',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Today's followup summary
          if (todayFollowups > 0)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 47, 144, 201).withOpacity(0.1),
                    const Color.fromARGB(255, 100, 181, 246).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color.fromARGB(255, 47, 144, 201).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: const Color.fromARGB(255, 47, 144, 201), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Followups',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '$todayFollowups followup${todayFollowups > 1 ? 's' : ''} scheduled',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 47, 144, 201),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 47, 144, 201).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 47, 144, 201),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Weekday headers
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: const Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((day) => Expanded(
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: day == 'Sun' || day == 'Sat' 
                              ? Colors.red.shade400 
                              : Colors.grey.shade700,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Calendar grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
              ),
              itemCount: daysInMonth.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    final date = daysInMonth[index];
                    if (date.month == _currentMonth.month) {
                      _showDateDetails(date);
                    }
                  },
                  child: _buildDateCell(daysInMonth[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalCurrentMonthFollowups() {
    int total = 0;
    for (var entry in _followupData.entries) {
      if (entry.key.year == _currentMonth.year && entry.key.month == _currentMonth.month) {
        total += entry.value;
      }
    }
    return total;
  }

  void _showDateDetails(DateTime date) {
    final followupCount = _followupData[_normalizeDate(date)] ?? 0;
    final dateFormatted = DateFormat('EEEE, MMMM d, yyyy').format(date);
    
    if (followupCount == 0) return;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 47, 144, 201).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 47, 144, 201),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormatted,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$followupCount Followup${followupCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: followupCount,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getFollowupColor(followupCount).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.person,
                            color: _getFollowupColor(followupCount),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Followup ${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Client ${index + 1} • ${index % 3 == 0 ? '10:00 AM' : index % 3 == 1 ? '2:00 PM' : '4:30 PM'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 47, 144, 201),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View All Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}