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
  List<StaffReportModels> _allStaffs = [];
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    staffFuture = fetchStaff();
  }

  Future<List<StaffReportModels>> fetchStaff() async {
    final result = await HttpService.get_staff_list();
    _allStaffs = result?.data ?? <StaffReportModels>[];
    return _allStaffs;
  }

  List<dynamic> _getDisplayList() {
    final filtered = _allStaffs.where((s) {
      final name = s.staffName.toLowerCase();
      final des = s.des.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || des.contains(query);
    }).toList();

    // Group by designation
    Map<String, List<StaffReportModels>> grouped = {};
    for (var s in filtered) {
      grouped.putIfAbsent(s.des, () => []).add(s);
    }

    // Flatten to a list of Headers and StaffModels
    List<dynamic> displayList = [];
    grouped.forEach((des, staffList) {
      displayList.add(des); // String header
      displayList.addAll(staffList); // Staff objects
    });

    return displayList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 36, 159, 230),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Staff Report",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search staff name or designation...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF24A0E6)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF24A0E6), width: 1),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StaffReportModels>>(
              future: staffFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No staff data available."));
                } else {
                  final displayList = _getDisplayList();

                  if (displayList.isEmpty) {
                    return const Center(
                        child: Text("No matching staff found."));
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final item = displayList[index];

                      if (item is String) {
                        // This is a Designation Header
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF24A0E6),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final staff = item as StaffReportModels;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StaffReportDashboardNew(
                                  id: staff.userId.toString()),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 90,
                                width: 8,
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: CircleAvatar(
                                  backgroundColor: Colors.blue.shade50,
                                  radius: 28,
                                  child: Text(
                                    staff.staffName.isNotEmpty
                                        ? staff.staffName[0]
                                        : "?",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF24A0E6),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        staff.staffName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        staff.phoneNo,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              size: 11,
                                              color: Colors.grey.shade400),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Joined: ${staff.joiningDate}",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: Colors.grey, size: 24),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
