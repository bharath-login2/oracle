import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import '../../models/lead_management/workDetailsCompanyModel.dart';
import '../../service/service.dart';

class ViewCompanyWorkPage extends StatefulWidget {
  const ViewCompanyWorkPage({super.key});

  @override
  State<ViewCompanyWorkPage> createState() => _ViewCompanyWorkPageState();
}

class _ViewCompanyWorkPageState extends State<ViewCompanyWorkPage> {
  late String currentDate;
  WorkCompanyDetailsModel? workStatusDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getWorkDuration(currentDate);
    });
  }

  Future<void> getWorkDuration(String date) async {
    final response = await HttpService.getWorkCompanyStatusDetails(date);
    setState(() {
      workStatusDetails = response;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View All Works"),
      
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (workStatusDetails == null || workStatusDetails!.data.isEmpty)
              ? const Center(child: Text("No work data available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: workStatusDetails!.data.length,
                  itemBuilder: (context, index) {
                    final staff = workStatusDetails!.data[index];
                    return GestureDetector(
                        onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ViewWorkPage(staffId: staff.staffId),
                                ),
                              );
                            },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.blue,
                              child: Text(
                                staff.name.isNotEmpty
                                    ? staff.name[0].toUpperCase()
                                    : "?",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    staff.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.play_arrow,
                                          size: 16, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Start: ${_formatTime(staff.firstStartTime)}",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.stop,
                                          size: 16, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text(
                                        "End: ${_formatTime(staff.lastEndTime)}",
                                        style: const TextStyle(fontSize: 14),
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
                  },
                ),
    );
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return "--";
    try {
      final dt = DateTime.parse(time);
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return time;
    }
  }
}
