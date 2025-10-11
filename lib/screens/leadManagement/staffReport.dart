import 'package:flutter/material.dart';
import 'package:login2/models/lead_management/staffReportModel.dart';
import 'package:login2/screens/staff_reports/staffDashboardNew.dart';
import 'package:login2/screens/staff_reports/staff_dashboard.dart';
import 'package:login2/service/service.dart';
import 'staff_details.dart';

class StaffReport extends StatefulWidget {
  const StaffReport({super.key});

  @override
  State<StaffReport> createState() => _StaffReportState();
}

class _StaffReportState extends State<StaffReport> {
  late Future<List<StaffReportModels>> staffFuture;

  @override
  void initState() {
    super.initState();
    staffFuture = fetchStaff();
  }

  Future<List<StaffReportModels>> fetchStaff() async {
    final result = await HttpService.get_staff_list();
    return result?.data ?? <StaffReportModels>[];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 36, 159, 230),
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Staff Report",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<StaffReportModels>>(
        future: staffFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No staff data available."));
          } else {
            final staffList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final staff = staffList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StaffReportDashboardNew(id: staff.userId.toString()),

                        // StaffDetails(
                        //   staff: {
                        //     "name": staff.staffName,
                        //     "designation": staff.des,
                        //     "address": staff.branchName,
                        //     "phone": staff.phoneNo,
                        //     "joined_date": staff.joiningDate,
                        //     "email": staff.email,
                        //   },
                        // ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 90,
                          width: 10,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF24A0E6),
                                Color(0xFF3BC8E0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            radius: 28,
                            child: Text(
                              staff.staffName.isNotEmpty
                                  ? staff.staffName[0]
                                  : "?",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E88E5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  staff.staffName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  staff.des,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_android,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(staff.phoneNo,
                                        style: const TextStyle(
                                            color: Colors.black54)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Joined: ${staff.joiningDate}",
                                      style: const TextStyle(
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: Colors.grey, size: 26),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
