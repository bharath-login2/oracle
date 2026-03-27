// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../core/common.dart';
import '../../models/staff_report/staff_call_details_model.dart';
import '../../models/staff_report/staff_details_model.dart';
import '../../models/userManagement/deleteStaffModel.dart';
import '../../screens/callLogs/callLogs.dart';
import '../../screens/leadManagement/viewLeads.dart';
import '../../screens/staff_reports/achievementDetailspage.dart';
import '../../screens/userManagement/changePassword.dart';
import '../../screens/userManagement/editStaffPage.dart';
import '../../service/service.dart';
import 'timeline_page.dart';

class StaffReportDashboardNew extends StatefulWidget {
  String id;
  StaffReportDashboardNew({super.key, required this.id});

  @override
  State<StaffReportDashboardNew> createState() =>
      _StaffReportDashboardNewState();
}

class _StaffReportDashboardNewState extends State<StaffReportDashboardNew> {
  Map<String, double> data = {};
  final List<Color> _chartColors = [
    const Color(0xFF667eea),
    const Color(0xFFf093fb),
    const Color(0xFFf5576c),
    const Color(0xFF4facfe),
    const Color(0xFF00f2fe),
    const Color(0xFF43e97b),
    const Color(0xFF38f9d7),
    const Color(0xFFfa709a),
    const Color(0xFFfee140),
    const Color(0xFF30cfd0),
  ];

  int selectedIndex = 0;
  var targetFromDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1).toString();
  var targetToDate = DateTime.now().toString();
  var fromDate = DateTime.now().toString();
  var toDate = DateTime.now().toString();

  String? updateStaffPermission;
  String? deleteStaffPermission;
  String? updateStaffPasswordPermission;
  String? token;
  String cloudCallPermission = '';
  String deleteLeadPermission = '';
  String viewLeadPermission = '';
  String updateLeadPermission = '';
  bool updateLeadPermission1 = false;
  bool deleteLeadPermission1 = false;
  bool cloudCallPermission1 = false;

  UserDashboardModel? staffDetails;
  StaffCalldetailsModel? callDetails;
  bool isLoading = true;

  getStaffDetails() async {
    staffDetails = await HttpService.getStaffDashboardNew(
        widget.id, targetFromDate, targetToDate);
    if (staffDetails != null && staffDetails!.status == true) {
      setState(() {});
    }
  }

  getCallDetails() async {
    callDetails =
        await HttpService.getStaffCallDetails(widget.id, fromDate, toDate);
    if (callDetails != null && callDetails!.status == true) {
      data.clear();
      for (int i = 0; i < callDetails!.data.leadStatusGraph.length; i++) {
        data.addAll({
          callDetails!.data.leadStatusGraph[i].callResult: double.parse(
              callDetails!.data.leadStatusGraph[i].resCount.toString())
        });
      }
      setState(() {});
    }
  }

  initData() async {
    setState(() {
      isLoading = true;
    });
    await getStaffDetails();
    await getCallDetails();
    token = await Common.getSharedPref("token");
    updateStaffPermission = await Common.getSharedPref("updateStaffPermission");
    deleteStaffPermission = await Common.getSharedPref("deleteStaffPermission");
    updateStaffPasswordPermission =
        await Common.getSharedPref("updateStaffPasswordPermission");
    viewLeadPermission = await Common.getSharedPref("viewLeadPermission");
    cloudCallPermission = await Common.getSharedPref("cloudCallPermission");
    updateLeadPermission = await Common.getSharedPref("updateLeadPermission");
    deleteLeadPermission = await Common.getSharedPref("deleteLeadPermission");

    updateLeadPermission1 = updateLeadPermission == 'true';
    deleteLeadPermission1 = deleteLeadPermission == 'true';
    cloudCallPermission1 = cloudCallPermission == 'true';

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isLoading == true
          ? _buildShimmerLoader()
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  _buildModernAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildTargetReportCard(),
                        const SizedBox(height: 20),
                        _buildCallStatusCard(),
                        const SizedBox(height: 20),
                        _buildLeadStatusSection(),
                        const SizedBox(height: 80),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 47, 131, 180),
                Color.fromARGB(255, 47, 131, 180),
                Color.fromARGB(255, 47, 131, 180),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  _buildBackButton(),
                  const SizedBox(width: 16),
                  _buildStaffAvatar(),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStaffInfo()),
                  //  _buildMenuButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildStaffAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.white,
        backgroundImage: staffDetails != null &&
                staffDetails!.data.userData.profilePic.isNotEmpty
            ? NetworkImage(staffDetails!.data.userData.profilePic)
            : null,
        child: staffDetails == null ||
                staffDetails!.data.userData.profilePic.isEmpty
            ? const Icon(Icons.person, size: 30, color: Color(0xFF667eea))
            : null,
      ),
    );
  }

  Widget _buildStaffInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (staffDetails != null)
          Text(
            staffDetails!.data.userData.staffName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (staffDetails != null)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              staffDetails!.data.userData.designation,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == "0") {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditProfilePage(
                    staffId: staffDetails!.data.userData.userId,
                  )));
        } else if (value == "1") {
          deleteDialog(context, staffDetails!.data.userData.userId);
        } else if (value == "2") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChangePassword(
                    token!, staffDetails!.data.userData.userId.toString())),
          );
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          if (updateStaffPermission == 'true')
            const PopupMenuItem<String>(
              value: '0',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Color(0xFF667eea), size: 20),
                  SizedBox(width: 12),
                  Text('Edit Profile',
                      style: TextStyle(color: Color(0xFF667eea))),
                ],
              ),
            ),
          if (deleteStaffPermission == 'true')
            const PopupMenuItem<String>(
              value: '1',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Text('Delete Staff', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          if (updateStaffPasswordPermission == 'true')
            const PopupMenuItem<String>(
              value: '2',
              child: Row(
                children: [
                  Icon(Icons.key, color: Colors.green, size: 20),
                  SizedBox(width: 12),
                  Text('Change Password',
                      style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
        ];
      },
    );
  }

  Widget _buildTargetReportCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.insights,
                        color: Color.fromARGB(255, 47, 131, 180), size: 24),
                    SizedBox(width: 10),
                    Text(
                      "Target Report",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                _buildDateFilterButton("target"),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTargetToggleButtons(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: selectedIndex == 0
                ? _buildTargetList()
                : _buildCallTargetList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? const Color.fromARGB(255, 47, 131, 180)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Cost Target",
                    style: TextStyle(
                      color: selectedIndex == 0
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? const Color.fromARGB(255, 47, 131, 180)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Call Target",
                    style: TextStyle(
                      color: selectedIndex == 1
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetList() {
    if (staffDetails!.data.userTarget.isEmpty) {
      return _buildEmptyState("No target data available");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: staffDetails!.data.userTarget.length,
      itemBuilder: (context, index) {
        final target = staffDetails!.data.userTarget[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AchievementDetailsPage(
                  targetData: target,
                  targetFromDate: DateTime.tryParse(targetFromDate),
                  targetToDate: DateTime.tryParse(targetToDate),
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667eea).withOpacity(0.9),
                  const Color(0xFF764ba2).withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        target.groupName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Target: ₹${target.targetAmount}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "Achieved: ₹${target.achieved}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: double.parse(target.progressPercentage) / 100,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 24,
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          "${target.progressPercentage}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallTargetList() {
    if (staffDetails!.data.staffCallTarget.isEmpty) {
      return _buildEmptyState("No call target data available");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: staffDetails!.data.staffCallTarget.length,
      itemBuilder: (context, index) {
        final target = staffDetails!.data.staffCallTarget[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFf093fb).withOpacity(0.9),
                const Color(0xFFf5576c).withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      target.groupName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Target: ${target.targetCall} calls",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Achieved: ${target.achieved}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: double.parse(target.progressPercentage) / 100,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 24,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        "${target.progressPercentage}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCallStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.phone_in_talk,
                        color: Color.fromARGB(255, 47, 131, 180), size: 24),
                    SizedBox(width: 10),
                    Text(
                      "Call Status",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                _buildDateFilterButton("call"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildCallMetricsGrid(),
          ),
          const SizedBox(height: 16),
          if (callDetails!.data.callDetails.closedCalls != 0)
            _buildClosedCallsCard(),
          if (callDetails!.data.callDetails.totalCost != "0") _buildCostCard(),
          const SizedBox(height: 16),
          _buildCallResponseList(),
        ],
      ),
    );
  }

  Widget _buildCallMetricsGrid() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.cloud_queue,
                  label: "Cloud Call",
                  value: callDetails!.data.callDetails.totDuration,
                  color: const Color(0xFF667eea),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CallLogs(
                          token,
                          staffDetails!.data.userData.staffName,
                          staffDetails!.data.userData.userId,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.phone,
                  label: "Phone Call",
                  value: callDetails!.data.callDetails.phoneCallDuration,
                  color: const Color(0xFFf093fb),
                  onTap: null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.timeline,
                  label: "Call Timeline",
                  value: "View Details",
                  color: const Color(0xFF4facfe),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimelinePage(),
                        settings: RouteSettings(
                          arguments: {
                            "staffId": staffDetails!.data.userData.userId
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // const SizedBox(width: 12),
              // Expanded(
              //   child: _buildMetricCard(
              //     icon: Icons.call_end,
              //     label: "Total Calls",
              //     value: callDetails!.data.callDetails.totalCalls.toString(),
              //     color: const Color(0xFF43e97b),
              //     onTap: null,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClosedCallsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Common.saveSharedPref("statusWise", 'no');
          if (viewLeadPermission == 'true') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewLeads(
                  token,
                  updateLeadPermission1,
                  deleteLeadPermission1,
                  cloudCallPermission1,
                  pageName: 'Closed Leads',
                  fromDate: DateTime.now().toString(),
                  toDate: DateTime.now().toString(),
                  status: '4',
                ),
              ),
            ).then((r) => initData());
          } else {
            _permissionDialogue(context, 'View Leads');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.done_all, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Closed Leads",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      callDetails!.data.callDetails.closedCalls.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFfa709a), Color(0xFFfee140)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.money, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Cost",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "₹ ${callDetails!.data.callDetails.totalCost}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallResponseList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Call Response Distribution",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: callDetails!.data.callCountByResponse.length,
            itemBuilder: (context, index) {
              final item = callDetails!.data.callCountByResponse[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.callResponse,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "${item.resCount} (${item.resPercentage}%)",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: double.parse(item.resPercentage) / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _chartColors[index % _chartColors.length],
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeadStatusSection() {
    if (data.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.pie_chart, color: Color(0xFF667eea), size: 24),
                SizedBox(width: 10),
                Text(
                  "Lead Status Distribution",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PieChart(
              dataMap: data,
              animationDuration: const Duration(milliseconds: 800),
              chartLegendSpacing: 20,
              chartRadius: MediaQuery.of(context).size.width / 2.5,
              colorList: _chartColors,
              initialAngleInDegree: 0,
              chartType: ChartType.ring,
              ringStrokeWidth: 40,
              centerText: "Leads",
              legendOptions: const LegendOptions(
                legendShape: BoxShape.circle,
                showLegendsInRow: false,
                legendPosition: LegendPosition.right,
                showLegends: true,
                legendTextStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              chartValuesOptions: const ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesOutside: true,
                decimalPlaces: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterButton(String type) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.calendar_today,
            color: Color.fromARGB(255, 47, 131, 180), size: 20),
        onPressed: () => filtrationSheet(context, type),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Object?> filtrationSheet(BuildContext context, String type) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Filter by Date',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDatePicker(
                    label: "From Date",
                    initialValue: type == "target" ? targetFromDate : fromDate,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (type == "target") {
                          targetFromDate = DateTime.parse(value).toString();
                        } else {
                          fromDate = DateTime.parse(value).toString();
                        }
                        setStateBottom(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDatePicker(
                    label: "To Date",
                    initialValue: type == "target" ? targetToDate : toDate,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (type == "target") {
                          targetToDate = DateTime.parse(value).toString();
                        } else {
                          toDate = DateTime.parse(value).toString();
                        }
                        setStateBottom(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        initData();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Filter',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDatePicker({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DateTimePicker(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: const Icon(Icons.calendar_today, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        initialValue: initialValue,
        type: DateTimePickerType.date,
        firstDate: DateTime(1995),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        onChanged: onChanged,
      ),
    );
  }

  void _permissionDialogue(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Access Denied'),
            ],
          ),
          content: const Text(
            'You do not have permission to access this feature. Please contact the support team.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close',
                  style: TextStyle(color: Color(0xFF667eea))),
            ),
          ],
        );
      },
    );
  }
}

Future<dynamic> deleteDialog(BuildContext context, String id) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Confirm Delete'),
          ],
        ),
        content:
            const Text('Are you sure you want to delete this staff member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              DeleteStaffModel delete = await HttpService.deleteStaff(id);
              if (delete.data == true) {
                Common.toastMessaage(delete.message, Colors.green);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              } else {
                Common.toastMessaage(delete.message, Colors.red);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
