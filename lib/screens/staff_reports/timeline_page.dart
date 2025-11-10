import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/screens/leadManagement/login_summary_page.dart';
import '../../models/staff_report/staff_calls_model.dart';
import '../../service/service.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late String staffId;
  late String currentDate;
  late DateTime selectedDate;

  StaffCallDuration? staffCallDuration;
  Map<String, List<Call>> groupedItems = {};
  
  // Right panel variables
  bool _isPanelOpen = false;
  final double _panelWidth = 200.0;
  double _panelPosition = -200.0;
  
  // Left panel variables
  bool _isLeftPanelOpen = false;
  final double _leftPanelWidth = 200.0;
  double _leftPanelPosition = -200.0;
  String token ="";
  @override
  void initState() {
    super.initState();
    _initializeData();
    // Future.delayed(Duration.zero, () {
    //   final args =
    //       ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    //   staffId = args["staffId"] as String;

    //   selectedDate = args.containsKey("selectedDate")
    //       ? args["selectedDate"] as DateTime
    //       : DateTime.now();

    //   currentDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    //   getCallDuration();
    // });
  }

  Future<void> _initializeData() async {
  token = await Common.getSharedPref("token") ?? "";
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

  staffId = args["staffId"] as String;

  selectedDate = args.containsKey("selectedDate")
      ? args["selectedDate"] as DateTime
      : DateTime.now();

  currentDate = DateFormat('yyyy-MM-dd').format(selectedDate);
  await getCallDuration();
}

  Future<void> getCallDuration() async {
    staffCallDuration =
        await HttpService.getStaffCallDuration(staffId, currentDate);
    if (staffCallDuration != null && staffCallDuration!.status == true) {
      for (var call in staffCallDuration!.data.calls) {
        String dateStr = call.calledDate.split(' ')[0];
        groupedItems.putIfAbsent(dateStr, () => []).add(call);
      }
      setState(() {});
    }
  }

  void _togglePanel() {
    setState(() {
      _isPanelOpen = !_isPanelOpen;
      _panelPosition = _isPanelOpen ? 0 : -_panelWidth;
    });
  }

  void _toggleLeftPanel() {
    setState(() {
      _isLeftPanelOpen = !_isLeftPanelOpen;
      _leftPanelPosition = _isLeftPanelOpen ? 0 : -_leftPanelWidth;
    });
  }

  String formatDateHeader(String dateStr) {
    final date = DateFormat('dd-MM-yyyy').parse(dateStr);
    return DateFormat('dd MMM').format(date).toUpperCase();
  }

  Widget buildTimelineItem(Call call) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const CircleAvatar(radius: 6, backgroundColor: Colors.green),
                Container(width: 2, height: 90, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(
                              'assets/icons/profile_placeholder.png'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(call.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(call.phone),
                              Text("Called Date : ${call.calledDate}",
                                  style: const TextStyle(fontSize: 12)),
                              Text("Called Time : ${call.calledTime}",
                                  style: const TextStyle(fontSize: 12)),
                              Text("Called Duration : ${call.duration}",
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(call.callType,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _tagBox("Ideal Time", const Color.fromARGB(255, 8, 8, 8)),
                      const SizedBox(width: 8),
                      _tagBox(call.idealTime,
                          const Color.fromARGB(255, 228, 58, 58)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildLoginTimeBox() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF3DC721),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Login Time: ${staffCallDuration?.data.summary.startTime ?? "N/A"}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildLogoutTimeRow() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 219, 58, 29),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Logout Time: ${staffCallDuration?.data.summary.endTime ?? "N/A"}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _tagBox(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Duration parseDuration(String time) {
    final parts = time.split(':').map(int.parse).toList();
    if (parts.length != 3) return Duration.zero;
    return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes % 60)}:${twoDigits(duration.inSeconds % 60)}";
  }

  Widget buildBottomSummarySection(StaffCallDuration staffCallDuration) {
    final summary = staffCallDuration.data.summary;
    final incoming = parseDuration(summary.totalIncomingDuration);
    final outgoing = parseDuration(summary.totalOutgoingDuration);
    final totalDuration = incoming + outgoing;

    return Column(
      children: [
        Row(
          children: [
            buildInfoCard(
              "WORK TIME",
              "START TIME : ${summary.startTime}\nEND TIME : ${summary.endTime}",
              Icons.schedule,
            ),
            const SizedBox(width: 10),
            buildInfoCard(
              "TOTAL TIME DURATION",
              "INCOMING : ${summary.totalIncomingDuration}\n"
                  "OUTGOING : ${summary.totalOutgoingDuration}\n"
                  "TOTAL: ${formatDuration(totalDuration)}",
              Icons.timelapse,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            buildInfoCard(
                "TOTAL FREE TIME",
                "🛑 IDEAL : ${summary.totalIdealTime}\n☕BREAK :00min,0secs\nTOTAL: ${summary.totalIdealTime}",
                Icons.free_breakfast),
            const SizedBox(width: 10),
            buildInfoCard(
                "TOTAL CONNECTED CALLS",
                "TOTAL: ${summary.totalCalls}\nCONNECTED: ${summary.totalCalls}\nMISSED: 0",
                Icons.call),
          ],
        ),
      ],
    );
  }

  Widget buildInfoCard(String title, String content, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(title,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 8),
              Text(content, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildTimeSummaryItem(
  //     String label, String value, IconData icon, Color color) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //     margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade100,
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(icon, color: color),
  //         const SizedBox(width: 12),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               label,
  //               style: const TextStyle(
  //                 fontSize: 12,
  //                 color: Colors.black54,
  //               ),
  //             ),
  //             Text(
  //               value,
  //               style: const TextStyle(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
    Widget _buildTimeSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap, // only passed for "Login"
  }) {
    final isClickable = onTap != null;

    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (isClickable)
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.black45),
        ],
      ),
    );

    return isClickable ? InkWell(onTap: onTap, child: content) : content;
  }

  Duration parseDuration_build(String time) {
    final parts = time.split(':').map(int.parse).toList();
    if (parts.length == 3) {
      return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
    } else if (parts.length == 2) {
      return Duration(minutes: parts[0], seconds: parts[1]);
    }
    return Duration.zero;
  }

  String formatDuration_build(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:"
        "${twoDigits(duration.inMinutes.remainder(60))}:"
        "${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Widget _buildTimeSummaryPanel(String token) {
    final summary = staffCallDuration?.data.summary;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue,
          child: Row(
            children: [
              const Text(
                "Time Summary",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: _togglePanel,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // _buildTimeSummaryItem(
                //   "Login",
                //   summary?.startTime ?? "--",
                //   Icons.login,
                //   Colors.green,
                // ),
                  _buildTimeSummaryItem(
                  "Login",
                  summary?.startTime ?? "--",
                  Icons.login,
                  Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginSummaryPage(
                          staffId: staffId,
                          token: token,
                          date: selectedDate ?? DateTime.now(),
                        ),
                      ),
                    );
                  },
                ),
                 _buildTimeSummaryItem(
                  "Work Time",
                  summary != null
                      ? formatDuration_build(
                          parseDuration_build(summary.totalIncomingDuration) +
                              parseDuration_build(
                                  summary.totalOutgoingDuration),
                        )
                      : "--",
                  Icons.timer,
                  Colors.purple,
                ),
                _buildTimeSummaryItem(
                  "Ideal",
                  summary?.totalIdealTime ?? "--",
                  Icons.hourglass_empty,
                  Colors.orange,
                ),

                _buildTimeSummaryItem(
                  "Loggedin Time",
                  "--",
                  Icons.login,
                  Colors.orange,
                ),
                // _buildTimeSummaryItem(
                //   "Break",
                //   summary?.totalIdealTime ?? "--",
                //   Icons.free_breakfast,
                //   Colors.blue,
                // ),
                _buildTimeSummaryItem(
                  "Logout",
                  summary?.endTime ?? "--",
                  Icons.logout,
                  Colors.redAccent,
                ),
                // _buildTimeSummaryItem(
                //   "Total",
                //   summary != null
                //       ? formatDuration_build(
                //           parseDuration_build(summary.totalIncomingDuration) +
                //               parseDuration_build(
                //                   summary.totalOutgoingDuration),
                //         )
                //       : "--",
                //   Icons.timer,
                //   Colors.purple,
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _calculateAverageCallDuration() {
    if (staffCallDuration == null || 
        staffCallDuration!.data.calls.isEmpty || 
        staffCallDuration!.data.summary.totalCalls == 0) {
      return "--";
    }
    
    final totalDuration = parseDuration_build(staffCallDuration!.data.summary.totalIncomingDuration) +
        parseDuration_build(staffCallDuration!.data.summary.totalOutgoingDuration);
    
    final averageSeconds = totalDuration.inSeconds / staffCallDuration!.data.summary.totalCalls;
    final averageDuration = Duration(seconds: averageSeconds.round());
    
    return formatDuration_build(averageDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timeline"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final DateTime initial = selectedDate;

              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                  currentDate = DateFormat('yyyy-MM-dd').format(picked);
                  groupedItems.clear();
                });
                getCallDuration();
              }
            },
          ),
        ],
      ),
      body: staffCallDuration == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_isPanelOpen) _togglePanel();
                    if (_isLeftPanelOpen) _toggleLeftPanel();
                  },
                  child: AbsorbPointer(
                    absorbing: _isPanelOpen || _isLeftPanelOpen,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                       
                          buildBottomSummarySection(staffCallDuration!),
                          const SizedBox(height: 16),
                          
                          buildLogoutTimeRow(),
                          
                          ListView.builder(
                            itemCount: groupedItems.keys.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final date = groupedItems.keys.toList()[index];
                              final entries = groupedItems[date]!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.green,
                                        child: Text(
                                          formatDateHeader(date),
                                          style: const TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  ...entries.map(buildTimelineItem),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          buildLoginTimeBox(),
                        ],
                      ),
                    ),
                  ),
                ),
                
             
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  right: _panelPosition,
                  top: 0,
                  bottom: 0,
                  width: _panelWidth,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx < 0) {
                        setState(() {
                          _panelPosition = (_panelPosition - details.delta.dx)
                              .clamp(-_panelWidth, 0.0);
                        });
                      } else if (details.delta.dx > 0) {
                        setState(() {
                          _panelPosition = (_panelPosition - details.delta.dx)
                              .clamp(-_panelWidth, 0.0);
                        });
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! < 0) {
                        _togglePanel();
                      } else if (details.primaryVelocity! > 0) {
                        _togglePanel();
                      } else {
                        if (_panelPosition.abs() > _panelWidth / 2) {
                          _togglePanel();
                        } else {
                          _togglePanel();
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(-3, 0),
                          ),
                        ],
                      ),
                      child: _buildTimeSummaryPanel(token),
                    ),
                  ),
                ),
                
            
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _leftPanelPosition,
                  top: 0,
                  bottom: 0,
                  width: _leftPanelWidth,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx > 0) {
                        setState(() {
                          _leftPanelPosition = (_leftPanelPosition + details.delta.dx)
                              .clamp(-_leftPanelWidth, 0.0);
                        });
                      } else if (details.delta.dx < 0) {
                        setState(() {
                          _leftPanelPosition = (_leftPanelPosition + details.delta.dx)
                              .clamp(-_leftPanelWidth, 0.0);
                        });
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        _toggleLeftPanel();
                      } else if (details.primaryVelocity! < 0) {
                        _toggleLeftPanel();
                      } else {
                        if (_leftPanelPosition.abs() > _leftPanelWidth / 2) {
                          _toggleLeftPanel();
                        } else {
                          _toggleLeftPanel();
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(3, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!_isPanelOpen)
                  Positioned(
                    right: 0,
                    top: MediaQuery.of(context).size.height / 2 - 50,
                    child: GestureDetector(
                      onTap: _togglePanel,
                      child: Container(
                        width: 24,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(-2, 0),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}