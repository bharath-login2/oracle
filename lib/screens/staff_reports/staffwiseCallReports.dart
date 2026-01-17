import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StaffWiseCallReport extends StatefulWidget {
  const StaffWiseCallReport({Key? key}) : super(key: key);

  @override
  _StaffWiseCallReportState createState() => _StaffWiseCallReportState();
}

class _StaffWiseCallReportState extends State<StaffWiseCallReport> {
  List<String> staffList = [
    'Sarath Krishnan',
    'Abina CB',
    'Anju Kurian',
    'Adithya ',
    'Mariya',
    'Bharath ',
    'Surya',
    'Drishya'
  ];
  List<DateTime> dateList = [];
  Map<String, Map<DateTime, Map<String, int>>> staffCallData = {};
  DateTime _selectedMonth = DateTime.now();
  ScrollController _horizontalScrollController = ScrollController();
  ScrollController _verticalScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _generateDateList();
    _generateSampleData();
  }

  void _generateDateList() {
    dateList.clear();
    DateTime firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    DateTime lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    for (DateTime date = firstDay; 
         date.isBefore(lastDay.add(const Duration(days: 1))); 
         date = date.add(const Duration(days: 1))) {
      dateList.add(date);
    }
  }

  void _generateSampleData() {
    staffCallData.clear();
    for (var staff in staffList) {
      staffCallData[staff] = {};
      for (var date in dateList) {
        staffCallData[staff]![date] = {
          'called': (date.day + staff.hashCode) % 15 + 1, 
          'missed': (date.day * staff.hashCode) % 8 + 1,  
        };
      }
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
      _generateDateList();
      _generateSampleData();
    });
  }

  Widget _buildMonthYearFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left, size: 30),
            style: IconButton.styleFrom(
              backgroundColor: Colors.green.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.green.shade300),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              DateFormat('MMMM yyyy').format(_selectedMonth),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right, size: 30),
            style: IconButton.styleFrom(
              backgroundColor: Colors.green.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.green.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        color: Colors.grey.shade200,
      ),
      child: Row(
        children: [
          // Fixed Date column header
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade400, width: 1.5),
                bottom: BorderSide(color: Colors.grey.shade400, width: 1.5),
              ),
              color: Colors.blue.shade50,
            ),
            child: const Center(
              child: Text(
                'Date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          
          // Scrollable Staff headers
          Expanded(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                itemCount: staffList.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade400, width: 1.5),
                        bottom: BorderSide(color: Colors.grey.shade400, width: 1.5),
                      ),
                      color: Colors.green.shade50,
                    ),
                    child: Center(
                      child: Text(
                        staffList[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(DateTime date, int rowIndex) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: rowIndex == dateList.length - 1 
                ? Colors.grey.shade400 
                : Colors.grey.shade300,
            width: rowIndex == dateList.length - 1 ? 1.5 : 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Fixed Date column
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade400, width: 1.5),
              ),
              color: rowIndex % 2 == 0 ? Colors.blue.shade50 : Colors.white,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    DateFormat('EEE').format(date),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Scrollable Staff data columns
          Expanded(
            child: SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                itemCount: staffList.length,
                itemBuilder: (context, staffIndex) {
                  final staffName = staffList[staffIndex];
                  final callData = staffCallData[staffName]?[date] ?? {'called': 0, 'missed': 0};
                  final totalCalls = callData['called']! + callData['missed']!;
                  
                  return Container(
                    width: 150,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: staffIndex == staffList.length - 1 
                              ? Colors.grey.shade400 
                              : Colors.grey.shade300,
                          width: staffIndex == staffList.length - 1 ? 1.5 : 1,
                        ),
                      ),
                      color: rowIndex % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Called and Missed in a row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.call_made, size: 14, color: Colors.green),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Text(
                                    '${callData['called']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(Icons.call_missed, size: 14, color: Colors.red),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Text(
                                    '${callData['missed']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Total calls
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: totalCalls > 15 ? Colors.orange.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: totalCalls > 15 ? Colors.orange.shade300 : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.call, size: 10, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Total: $totalCalls',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: totalCalls > 15 ? Colors.orange.shade800 : Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Table Header
          _buildTableHeader(),
          
          // Table Body
          Expanded(
            child: ListView.builder(
              controller: _verticalScrollController,
              itemCount: dateList.length,
              itemBuilder: (context, index) {
                return _buildDateRow(dateList[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Wise Call Report'),
        backgroundColor: const Color.fromARGB(255, 60, 136, 207),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildMonthYearFilter(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.info, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Scroll horizontally to view all staff members →',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 20,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem(Icons.call_made, 'Called', Colors.green),
                _buildLegendItem(Icons.call_missed, 'Missed', Colors.red),
                _buildLegendItem(Icons.calendar_today, 'Date', Colors.blue),
                _buildLegendItem(Icons.call, 'Total Calls', Colors.grey),
              ],
            ),
          ),
          
          // Main Table
          Expanded(
            child: _buildTable(),
          ),
          
          // Summary Section
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                const Text(
                  'Monthly Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryCard('Total Called', _calculateTotal('called'), Icons.call_made, Colors.green),
                    _buildSummaryCard('Total Missed', _calculateTotal('missed'), Icons.call_missed, Colors.red),
                    _buildSummaryCard('Overall Total', _calculateTotal('called') + _calculateTotal('missed'), Icons.call, Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Scroll to top/bottom buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            onPressed: () {
              _verticalScrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.arrow_upward, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            onPressed: () {
              _horizontalScrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.arrow_back, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotal(String type) {
    int total = 0;
    for (var staff in staffList) {
      for (var date in dateList) {
        final data = staffCallData[staff]?[date];
        if (data != null && data.containsKey(type)) {
          total += data[type]!;
        }
      }
    }
    return total;
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }
}