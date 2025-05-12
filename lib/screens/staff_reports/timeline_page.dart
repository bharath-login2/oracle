import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  StaffCallDuration? staffCallDuration;
  Map<String, List<Call>> groupedItems = {};
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      staffId = args["staffId"]!;
      currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      getCallDuration();
    });
  }

  getCallDuration() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text("Timeline")),
      appBar: AppBar(
        title: const Text("Timeline"),
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              // Expanded(child: Container(height: 2, color: Colors.grey.shade400)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ...entries.map(buildTimelineItem),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  buildBottomSummarySection(staffCallDuration!),
                ],
              ),
            ),
    );
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
                  Row(
                    children: [
                      _tagBox(call.calledTime, Colors.blue,
                          icon: Icons.fiber_manual_record),
                      const SizedBox(width: 8),
                      _tagBox(
                        call.duration == "0" ? "00:00:00" : call.duration,
                        Colors.green,
                        icon: Icons.timer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
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
                      _tagBox("Ideal Time", Colors.red),
                      const SizedBox(width: 8),
                      _tagBox(call.idealTime, Colors.red.shade100),
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

  Widget buildBottomSummarySection(StaffCallDuration staffCallDuration) {
    final summary = staffCallDuration.data.summary;
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
              "INCOMING : ${summary.totalIncomingDuration}\nOUTGOING : ${summary.totalOutgoingDuration}\nTOTAL: ${summary.totalIncomingDuration + summary.totalOutgoingDuration}",
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
}
