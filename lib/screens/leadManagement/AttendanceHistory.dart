import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/attendanceHistoryModel.dart';
import 'package:login2/service/service.dart';

class AttendanceHistory extends StatefulWidget {
  final String staffName;
  final String staffId;
  final DateTime selectedDate;

  const AttendanceHistory({
    super.key,
    required this.staffName,
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
  bool isRefreshing = false;

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
    try {
      final res = await HttpService.getAttendanceHistory(
        staffId: widget.staffId,
        date: selectedDate,
      );
      setState(() {
        historyData = res;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() => isRefreshing = true);
    await _loadHistory();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1590DD),
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await _loadHistory();
    }
  }

  String _getTimeDifference(String time) {
    try {
      final dateTime = DateFormat('dd-MM-yyyy HH:mm:ss').parse(time);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateStr = DateFormat("dd MMM yyyy, EEEE").format(selectedDate);
    final today = DateTime.now();
    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.staffName,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  isToday ? 'Today, $dateStr' : dateStr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1590DD),
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 22,
                ),
              ),
              onPressed: _pickDate,
              tooltip: 'Select Date',
            ),
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingState()
          : historyData == null || historyData!.data.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: const Color(0xFF1590DD),
                  child: Stack(
                    children: [
                      ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        children: [
                          //  _buildSummaryCard(),
                          const SizedBox(height: 24),
                          _buildTimeline(),
                        ],
                      ),
                      if (isRefreshing)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 4,
                            color: const Color(0xFF1590DD),
                            child: const LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1590DD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1590DD)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading Attendance History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fetching records...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1590DD).withOpacity(0.08),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.history_toggle_off_rounded,
                size: 60,
                color: const Color(0xFF1590DD).withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Attendance History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              selectedDate.day == DateTime.now().day
                  ? 'No attendance records for today'
                  : 'No attendance records for selected date',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1590DD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Activity Timeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
        ),
        ...historyData!.data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == historyData!.data.length - 1;

          final isCheckIn = item.action.toLowerCase() == 'create';
          // final primaryColor = item.actionType == "login"
          //     ? const Color(0xFF4CAF50)
          //     : const Color(0xFFFF9800);
          final Color primaryColor = item.actionType == "login"
              ? const Color(0xFF4CAF50) // green
              : item.actionType == "logout"
                  ? const Color(0xFFF44336) // red
                  : item.actionType == "auto"
                      ? const Color(0xFF607D8B) // blue-grey
                      : const Color(0xFFFF9800); // orange
          //   final icon = isCheckIn ? Icons.login_rounded : Icons.update_rounded;
          final icon = item.actionType == "login"
              ? Icons.login_rounded
              : item.actionType == "logout"
                  ? Icons.logout_rounded
                  : item.actionType == "auto"
                      ? Icons.autorenew_rounded
                      : Icons.update_rounded;
          final statusText = isCheckIn ? 'CHECK-IN' : 'UPDATE';

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline indicator
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: primaryColor,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 60,
                        color: Colors.grey[300],
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Activity Card
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // color: primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.updatedBy!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item.description,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                                // const SizedBox(height: 12),
                                // Row(
                                //   children: [
                                //     Icon(
                                //       Icons.person_outline_rounded,
                                //       size: 14,
                                //       color: Colors.grey[500],
                                //     ),
                                //     const SizedBox(width: 6),
                                //     Text(
                                //       'Updated By:${item.updatedBy!}',
                                //       style: TextStyle(
                                //         fontSize: 13,
                                //         color: Colors.grey[600],
                                //         fontWeight: FontWeight.w500,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item.updatedTime,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (_getTimeDifference(item.updatedDate)
                                  .isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _getTimeDifference(item.updatedDate),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
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
            ),
          );
        }).toList(),
      ],
    );
  }
}
