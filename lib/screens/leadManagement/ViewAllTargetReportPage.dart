import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/targetGroupModel.dart';
import 'package:login2/models/staff_report/staff_details_model.dart';
import 'package:login2/screens/leadManagement/setTargetPage.dart';
import 'package:login2/screens/staff_reports/achievementDetailspage.dart';
import 'package:login2/service/service.dart';

// ignore: must_be_immutable
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

  // @override
  // void initState() {
  //   super.initState();
  //   _initializeDates();
  //   _fetchTargetReportData();
  //   getStaffDetails();
  // }
  @override
  void initState() {
    super.initState();
    _initializeDates();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTargetReportData();
      getStaffDetails();
    });
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
      await _fetchTargetReportData();
      await getStaffDetails();
    }
  }

  List<TargetGroupAll> getIndividualReports() {
    return filteredReports
        .where((report) => report.isGroup == "N" && report.isCompany != "1")
        .toList();
  }

  List<TargetGroupAll> getGroupReports() {
    return filteredReports
        .where((report) => report.isGroup == "Y" && report.isCompany != "1")
        .toList();
  }

  List<TargetGroupAll> getCompanyReports() {
    return filteredReports.where((report) => report.isCompany == "1").toList();
  }

  double _parseAmount(String amount) {
    return double.tryParse(amount.replaceAll(',', '')) ?? 0.0;
  }

  double _calculateProgress(String target, String achieved) {
    final targetAmount = _parseAmount(target);
    final achievedAmount = _parseAmount(achieved);
    if (targetAmount <= 0) return 0.0;
    return (achievedAmount / targetAmount).clamp(0.0, 1.0);
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
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Company Reports Section
                              if (getCompanyReports().isNotEmpty) ...[
                                _buildSectionHeader(
                                    "Company  Target", Icons.business),
                                const SizedBox(height: 8),
                                ...getCompanyReports().map((report) =>
                                    _buildCompanyReportCard(report)),
                                const SizedBox(height: 20),
                              ],
                              if (getIndividualReports().isNotEmpty) ...[
                                _buildSectionHeader(
                                    "Individual Reports", Icons.person),
                                const SizedBox(height: 8),
                                ...getIndividualReports().map((report) =>
                                    _buildIndividualReportCard(report)),
                                const SizedBox(height: 20),
                              ],
                              if (getGroupReports().isNotEmpty) ...[
                                _buildSectionHeader(
                                    "Group Reports", Icons.groups),
                                const SizedBox(height: 8),
                                ...getGroupReports().map(
                                    (report) => _buildGroupReportCard(report)),
                                const SizedBox(height: 20),
                              ],
                            ],
                          ),
                        ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const Spacer(),
        title == "Company  Target"
            ? SizedBox()
            : Text(
                "(${title == "Individual Reports" ? getIndividualReports().length : title == "Group Reports" ? getGroupReports().length : ""})",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
      ],
    );
  }

  Widget _buildCompanyReportCard(TargetGroupAll report) {
    final targetAmount = _parseAmount(report.targetAmount);
    final achievedAmount = _parseAmount(report.totalAchieved);
    final pendingAmount = targetAmount - achievedAmount;
    final progress =
        _calculateProgress(report.targetAmount, report.totalAchieved);
    final progressPercent = (progress * 100).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100, width: 1),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.business, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.groupName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                      if (report.staffName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Managed by: ${report.staffName}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: progress >= 1.0
                        ? Colors.green.shade100
                        : progress >= 0.7
                            ? Colors.blue.shade100
                            : progress >= 0.4
                                ? Colors.orange.shade100
                                : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$progressPercent%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: progress >= 1.0
                          ? Colors.green
                          : progress >= 0.7
                              ? Colors.blue
                              : progress >= 0.4
                                  ? Colors.orange
                                  : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0
                      ? Colors.green
                      : progress >= 0.7
                          ? Colors.blue
                          : progress >= 0.4
                              ? Colors.orange
                              : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountColumn(
                  "Target",
                  "₹${NumberFormat("#,##0.00").format(targetAmount)}",
                  Colors.blue,
                ),
                _buildAmountColumn(
                  "Achieved",
                  "₹${NumberFormat("#,##0.00").format(achievedAmount)}",
                  Colors.green,
                ),
                _buildAmountColumn(
                  "Pending",
                  "₹${NumberFormat("#,##0.00").format(pendingAmount)}",
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    _navigateToDetails(report);
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.blue.shade50,
                  ),
                  child: const Row(
                    children: [
                      Text(
                        "View Details",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 12, color: Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountColumn(String label, String amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualReportCard(TargetGroupAll report) {
    final targetAmount = _parseAmount(report.targetAmount);
    final achievedAmount = _parseAmount(report.totalAchieved);
    final pendingAmount = targetAmount - achievedAmount;
    final progress =
        _calculateProgress(report.targetAmount, report.totalAchieved);
    final progressPercent = (progress * 100).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetails(report),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        const Icon(Icons.person, color: Colors.blue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      report.groupName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: progress >= 1.0
                          ? Colors.green.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$progressPercent%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: progress >= 1.0 ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? Colors.green : Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAmountColumn(
                    "Target",
                    "₹${NumberFormat("#,##0").format(targetAmount)}",
                    const Color(0xFF2D3142),
                  ),
                  _buildAmountColumn(
                    "Achieved",
                    "₹${NumberFormat("#,##0").format(achievedAmount)}",
                    Colors.green,
                  ),
                  _buildAmountColumn(
                    "Pending",
                    "₹${NumberFormat("#,##0").format(pendingAmount)}",
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupReportCard(TargetGroupAll report) {
    final targetAmount = _parseAmount(report.targetAmount);
    final achievedAmount = _parseAmount(report.totalAchieved);
    final pendingAmount = targetAmount - achievedAmount;
    final progress =
        _calculateProgress(report.targetAmount, report.totalAchieved);
    final progressPercent = (progress * 100).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetails(report),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        const Icon(Icons.groups, color: Colors.green, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.groupName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        Text(
                          "Staff: ${report.staffName}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: progress >= 1.0
                          ? Colors.green.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$progressPercent%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: progress >= 1.0 ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? Colors.green : Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAmountColumn(
                    "Target",
                    "₹${NumberFormat("#,##0").format(targetAmount)}",
                    const Color(0xFF2D3142),
                  ),
                  _buildAmountColumn(
                    "Achieved",
                    "₹${NumberFormat("#,##0").format(achievedAmount)}",
                    Colors.green,
                  ),
                  _buildAmountColumn(
                    "Pending",
                    "₹${NumberFormat("#,##0").format(pendingAmount)}",
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(TargetGroupAll report) {
    final matchingTarget = staffDetails?.data.userTarget
        .where((t) => t.groupId == report.id)
        .cast<UserTarget?>()
        .firstWhere(
          (t) => t != null,
          orElse: () => null,
        );
    if (matchingTarget != null) {
      final fromStr = _fromDate != null
          ? _fromDate!.toIso8601String().split('T').first
          : '';
      final toStr =
          _toDate != null ? _toDate!.toIso8601String().split('T').first : '';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AchievementDetailsPage(
            targetData: matchingTarget,
            targetFromDate: DateTime.tryParse(fromStr),
            targetToDate: DateTime.tryParse(toStr),
          ),
        ),
      );
    } else {
      debugPrint("❌ No matching target found for group ID: ${report.id}");
    }
  }
}
