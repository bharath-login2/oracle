import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/targetGroupModel.dart';
import 'package:login2/models/staff_report/staff_details_model.dart';
import 'package:login2/screens/leadManagement/setTargetPage.dart';
import 'package:login2/screens/staff_reports/achievementDetailspage.dart';
import 'package:login2/service/service.dart';

class ViewAllTargetReportPage extends StatefulWidget {
  String id;
  ViewAllTargetReportPage({super.key, required this.id});

  @override
  State<ViewAllTargetReportPage> createState() =>
      _ViewAllTargetReportPageState();
}

class _ViewAllTargetReportPageState extends State<ViewAllTargetReportPage> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;

  List<TargetGroupAll> allReports = [];
  List<TargetGroupAll> filteredReports = [];
  UserDashboardModel? staffDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _fetchTargetReportData();
    getStaffDetails();
  }

  void _initializeDates() {
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = now;
  }

  Future<void> _fetchTargetReportData() async {
    setState(() => isLoading = true);
    final fromStr =
        _fromDate != null ? _fromDate!.toIso8601String().split('T').first : '';
    final toStr =
        _toDate != null ? _toDate!.toIso8601String().split('T').first : '';

    final result = await HttpService.getAllTargetReport(fromStr, toStr);
    if (result != null && result.status) {
      setState(() {
        allReports = List<TargetGroupAll>.from(result.data);
        filteredReports = allReports;
        isLoading = false;
      });
    } else {
      setState(() {
        filteredReports = [];
        isLoading = false;
      });
    }
  }

  getStaffDetails() async {
    final fromStr =
        _fromDate != null ? _fromDate!.toIso8601String().split('T').first : '';
    final toStr =
        _toDate != null ? _toDate!.toIso8601String().split('T').first : '';

    staffDetails =
        await HttpService.getStaffDashboard(widget.id, fromStr, toStr);

    if (staffDetails != null && staffDetails!.status == true) {
      setState(() {});
    } else {}
  }

  void _filterReports() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredReports = allReports.where((report) {
        final name = report.groupName.toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate! : _toDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
      _fetchTargetReportData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Target Reports"),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SetTargetPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Group Name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (_) => _filterReports(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'From: ${DateFormat('dd-MM-yyyy').format(_fromDate!)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'To: ${DateFormat('dd-MM-yyyy').format(_toDate!)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredReports.isEmpty
                      ? const Center(child: Text("No target reports found"))
                      : ListView.builder(
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            final report = filteredReports[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: ListTile(
                                  leading: Icon(
                                    report.isGroup == "Y"
                                        ? Icons.groups_2
                                        : Icons.person,
                                    color: Colors.indigo,
                                    size: 28,
                                  ),
                                  title: Text(
                                    report.groupName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text("Staff: ${report.staffName}"),
                                      Text("Target: ₹${report.targetAmount}"),
                                      Text(
                                          "Achieved: ₹${report.totalAchieved}"),
                                    ],
                                  ),
                                  trailing: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 18),
                                  // onTap: () {
                                  //   final target =
                                  //       staffDetails?.data.userTarget[index];
                                  //   final fromStr = _fromDate != null
                                  //       ? _fromDate!
                                  //           .toIso8601String()
                                  //           .split('T')
                                  //           .first
                                  //       : '';
                                  //   final toStr = _toDate != null
                                  //       ? _toDate!
                                  //           .toIso8601String()
                                  //           .split('T')
                                  //           .first
                                  //       : '';

                                  //   if (target != null) {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             AchievementDetailsPage(
                                  //           targetData: target,
                                  //           targetFromDate:
                                  //               DateTime.tryParse(fromStr),
                                  //           targetToDate:
                                  //               DateTime.tryParse(toStr),
                                  //         ),
                                  //       ),
                                  //     );
                                  //   } else {
                                  //     debugPrint("Target data is null");
                                  //   }
                                  // },
                                  onTap: () {
                                    final report = filteredReports[
                                        index]; 
                                    final matchingTarget = staffDetails
                                        ?.data.userTarget
                                        .where((t) => t.groupId == report.id)
                                        .cast<UserTarget?>()
                                        .firstWhere(
                                          (t) => t != null,
                                          orElse: () => null,
                                        );

                                    if (matchingTarget != null) {
                                      final fromStr = _fromDate != null
                                          ? _fromDate!
                                              .toIso8601String()
                                              .split('T')
                                              .first
                                          : '';
                                      final toStr = _toDate != null
                                          ? _toDate!
                                              .toIso8601String()
                                              .split('T')
                                              .first
                                          : '';

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AchievementDetailsPage(
                                            targetData: matchingTarget,
                                            targetFromDate:
                                                DateTime.tryParse(fromStr),
                                            targetToDate:
                                                DateTime.tryParse(toStr),
                                          ),
                                        ),
                                      );
                                    } else {
                                      debugPrint(
                                          "❌ No matching target found for group ID: ${report.id}");
                                    }
                                  }),
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}
