import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/StaffCalendarPage.dart';
import 'package:login2/screens/leadManagement/ViewAllTargetReportPage.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/minimalDashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/staff_reports/staffDashboardNew.dart';

import 'package:login2/screens/staff_reports/staff_dashboard.dart';
import 'package:login2/screens/userManagement/branches.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/userManagement/viewStaffModel.dart';
import '../bottom_navigation_bar.dart';
import '../../screens/drawerScreen.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../screens/userManagement/addDesignationPage.dart';
import '../../screens/userManagement/addUserManagement.dart';
import '../../screens/userManagement/designationList.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../authentication/login.dart';

// ignore: must_be_immutable
class ViewUsers extends StatefulWidget {
  String? token;
  ViewUsers(this.token, {super.key});
  @override
  State<ViewUsers> createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers> {
  ViewStaffModel? viewStaff;
  CommonConfigureModel? configure;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool? result = true;
  bool? result1 = true;
  String name = '';
  String role = '';
  String roleId = '';
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  String? NewleadDashboardPermission;
  String LeadDashboard = '';
  String? createStaffPermission;
  String? viewStaffPermission;
  String? updateStaffPermission;
  String? deleteStaffPermission;
  String? viewStaffReportPermission;
  String? createStaffDesignationPermission;
  String? viewStaffDesignationPermission;
  String? updateStaffDesignationPermission;
  String? deleteStaffDesignationPermission;
  String? updateStaffPasswordPermission;
  String phoneCallLogPermission = '';
  String viewAttendanceSection = '';
  String multiBranch = '';
  String userId = '';
  List<StaffList> filteredStaffs = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");
    roleId = await Common.getSharedPref("roleId");
    userId = await Common.getSharedPref("userId");
    multiBranch = await Common.getSharedPref("multiBranch");
    createStaffPermission = await Common.getSharedPref("createStaffPermission");
    viewStaffPermission = await Common.getSharedPref("viewStaffPermission");
    updateStaffPermission = await Common.getSharedPref("updateStaffPermission");
    deleteStaffPermission = await Common.getSharedPref("deleteStaffPermission");
    viewStaffReportPermission =
        await Common.getSharedPref("viewStaffReportPermission");
    createStaffDesignationPermission =
        await Common.getSharedPref("createStaffDesignationPermission");
    viewStaffDesignationPermission =
        await Common.getSharedPref("viewStaffDesignationPermission");
    updateStaffDesignationPermission =
        await Common.getSharedPref("updateStaffDesignationPermission");
    deleteStaffDesignationPermission =
        await Common.getSharedPref("deleteStaffDesignationPermission");
    updateStaffPasswordPermission =
        await Common.getSharedPref("updateStaffPasswordPermission");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    LeadDashboard = await Common.getSharedPref("LeadDashboard");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    NewleadDashboardPermission =
        await Common.getSharedPref("NewleadDashboardPermission");
    viewAttendanceSection = await Common.getSharedPref("viewAttendanceSection");
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult is List<ConnectivityResult>) {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        setState(() {
          result = true;
        });
      }
    } else {
      setState(() {
        result = false;
      });
    }

    viewStaff = await HttpService.viewStaffs(widget.token);
    if (viewStaff != null) {
      filteredStaffs.clear();
      filteredStaffs.addAll(viewStaff!.data.staffList);
      setState(() {});
      configure = await HttpService.configure(widget.token);
      if (configure != null) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: () async {
        getData();
        return;
      },
      child: result == true
          ? Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.grey.shade200,
              appBar: PreferredSize(
                preferredSize:
                    Size.fromHeight(MediaQuery.of(context).size.height * 0.28),
                child: Container(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, top: 10.0, bottom: 10.0, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => logout(context),
                              child: Container(
                                width: 43,
                                height: 43,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 2,
                                        color: Colors.grey.shade800,
                                        offset: const Offset(0, 2.0),
                                      )
                                    ],
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF2191ce)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    "assets/icons/user.png",
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  role,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                onSelected: (value) {
                                  if (value == 'view_target_report') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ViewAllTargetReportPage(id: userId),
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'view_target_report',
                                    child: Text('View Target Report'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: viewStaff != null && configure != null
                  ? _buildModernBody(size)
                  : Center(
                      child: Lottie.asset('assets/main/loading.json',
                          width: 150, height: 150, fit: BoxFit.fill),
                    ),
              endDrawer: DraweScreen(widget.token!),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  ProjectDashboardPermission == "true"
                      ? Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProjectDashboard()),
                        )
                      : AccountsDashboardPermission == "true"
                          ? Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccountsDashboard(
                                    token: widget.token ?? ""),
                              ),
                            )
                          : MenuDashboard == "true"
                              ? Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HomePage(widget.token)),
                                )
                              : RenewalDashboardPermission == "true"
                                  ? Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RenewalDashboard()),
                                    )
                                  : NewleadDashboardPermission == "true"
                                      ? Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MinimalDashboard(
                                                      widget.token)),
                                        )
                                      : Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DashboardLeadNewUpdatedTwo(
                                                      widget.token)),
                                        );
                },
                child: Image.asset("assets/icons/menu.png",
                    width: 25), //icon inside button
              ),
              bottomNavigationBar: configure != null
                  ? BottomNavigation(
                      widget.token!,
                      phoneCallLogPermission: phoneCallLogPermission,
                      name: name,
                      userId: userId,
                    )
                  : const SizedBox())
          : Scaffold(
              backgroundColor: Colors.white,
              body: SizedBox(
                width: MediaQuery.of(context).size.width * 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/icons/noNetwork.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Text(
                      'No Network Found !',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: () {
                        getData();
                      },
                      child: SizedBox(
                        width: 120,
                        height: 35,
                        child: Padding(
                          padding: const EdgeInsets.all(1.5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: Text(
                                'Try Again',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
    );
  }

  Widget _buildModernBody(Size size) {
    if (configure?.data?.isExpired == true) {
      return _buildExpiredBody();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildSearchAndSettingsHeader(),
          Padding(
            padding:
                const EdgeInsets.only(bottom: 100), // Space for FAB/BottomNav
            child: filteredStaffs.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredStaffs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, i) =>
                        _buildModernStaffCard(filteredStaffs[i], i),
                  )
                : _buildNoResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSettingsHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                autocorrect: false,
                onChanged: (value) {
                  setState(() {
                    filteredStaffs = viewStaff!.data.staffList
                        .where((item) => item.name
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search staff by name...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon:
                      Icon(Icons.search_rounded, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
          // const SizedBox(width: 12),
          // _buildSettingsButton(),
        ],
      ),
    );
  }

  Widget _buildSettingsButton() {
    return PopupMenuButton<int>(
      offset: const Offset(0, 65),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 47, 131, 180),
              Color.fromARGB(255, 47, 131, 180),
              Color.fromARGB(255, 47, 131, 180)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.15),
            ),
            child: const Icon(
              Icons.add_chart_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
      itemBuilder: (context) => [
        _buildModernMenuItem(
          1,
          Icons.add_circle_outline,
          'Add Designation',
          const Color(0xFF43e97b),
          'Create new designation for staff members',
        ),
        _buildModernMenuItem(
          2,
          Icons.format_list_bulleted_rounded,
          'List Designation',
          const Color(0xFF667eea),
          'View all existing designations',
        ),
        _buildModernMenuItem(
          3,
          Icons.person_add_alt_1_rounded,
          'Add Staff',
          const Color(0xFFf093fb),
          'Add new staff member to the system',
        ),
        if (multiBranch == 'true' && roleId == "2")
          _buildModernMenuItem(
            4,
            Icons.business_center_rounded,
            'Branches',
            const Color(0xFFfa709a),
            'Manage branch locations',
          ),
      ],
      onSelected: (value) {
        if (value == 1) {
          createStaffDesignationPermission == 'true'
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddDesignationPage(widget.token!)))
              : _permissionDialogue(context, 'Create Designation');
        } else if (value == 2) {
          viewStaffDesignationPermission == 'true'
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DesignationList(widget.token!)))
              : _permissionDialogue(context, 'Designation List');
        } else if (value == 3) {
          createStaffPermission == 'true'
              ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddUser(widget.token!)))
                  .then((r) => getData())
              : _permissionDialogue(context, 'Add User');
        } else if (value == 4) {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Branches()))
              .then((r) => getData());
        }
      },
    );
  }

  PopupMenuItem<int> _buildModernMenuItem(
    int value,
    IconData icon,
    String title,
    Color iconColor,
    String subtitle,
  ) {
    return PopupMenuItem<int>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.2),
                  iconColor.withOpacity(0.1)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildModernStaffCard(StaffList staff, int index) {
    final double targetPercent = double.tryParse(staff.targetPercentage) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              viewStaffReportPermission == 'true'
                  ? Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => StaffReportDashboardNew(
                          id: staff.staffId.toString())))
                  : _permissionDialogue(context, 'Staff Report');
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.blue.shade50, width: 2),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(staff.imageUrl.toString()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staff.name.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2a86c9).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                staff.designation.toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF2a86c9),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStaffCardMenu(staff),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStaffDetailsRow(staff),
                  const SizedBox(height: 20),
                  _buildStatsGrid(staff),
                  const SizedBox(height: 20),
                  _buildTargetProgress(staff, targetPercent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffDetailsRow(StaffList staff) {
    return Row(
      children: [
        _buildIconInfo(Icons.phone_iphone_rounded, staff.phoneNo.toString()),
        if (staff.branchName != '') ...[
          const SizedBox(width: 16),
          _buildIconInfo(Icons.location_on_rounded, staff.branchName),
        ],
      ],
    );
  }

  Widget _buildIconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(StaffList staff) {
    return Row(
      children: [
        Expanded(
            child: _buildStatItem(
                "Leads", staff.totalLeadsCount, const Color(0xFF6366F1))),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatItem(
                "Closed", staff.totalClosedLeadCount, const Color(0xFF10B981))),
        const SizedBox(width: 12),
        Expanded(child: _buildCallStatItem(staff)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.6),
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 16, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCallStatItem(StaffList staff) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text(
            "Calls (Ph/Cl)",
            style: TextStyle(
                fontSize: 10,
                color: Colors.orange,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              "${staff.totalCallDuration} / ${staff.totalCloudCallDuration}",
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetProgress(StaffList staff, double percent) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Achieved: ₹ ${staff.targetAmountAchieved}",
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569)),
            ),
            Text(
              "Target: ₹ ${staff.targetAmount}",
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              height: 10,
              width: (percent / 100) * (MediaQuery.of(context).size.width - 64),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade300, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${percent.toStringAsFixed(1)}%",
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700),
          ),
        ),
      ],
    );
  }

  Widget _buildStaffCardMenu(StaffList staff) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded, color: Colors.grey.shade400),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (value) async {
        if (value == 'disable') {
          _showDisableDialog(staff);
        } else if (value == 'attendance') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StaffCalendarPage(
                staffId: staff.staffId,
                selectedDate: DateTime.now(),
                staffName: staff.name,
              ),
            ),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'disable',
          child: Row(
            children: [
              Icon(Icons.person_off_rounded, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('Disable Staff'),
            ],
          ),
        ),
        if (viewAttendanceSection.toString() == "true")
          const PopupMenuItem(
            value: 'attendance',
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    color: Colors.blue, size: 20),
                SizedBox(width: 12),
                Text('Attendance'),
              ],
            ),
          ),
      ],
    );
  }

  void _showDisableDialog(StaffList staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Disable Staff'),
        content: Text('Are you sure you want to disable ${staff.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final disableStaff =
                  await HttpService.addStaffDisable(staffId: staff.staffId);
              if (disableStaff != null && disableStaff.data == true) {
                Common.premiumToast(
                    context, "Staff disabled successfully", Icons.check_circle,
                    color: Colors.green);
                getData();
              } else {
                Common.premiumToast(
                    context, "Failed to disable staff", Icons.error,
                    color: Colors.red);
              }
            },
            child: const Text('Disable', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Lottie.asset('assets/main/empty_state.json', width: 200, height: 200),
          const Text(
            "No staff found",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                child: Image.asset(
                  'assets/main/packageimage.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Package Expired',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please contact our support team to upgrade your plan and continue using the staff management features.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _upgrade(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('UPGRADE NOW',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget noResultWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }

  void logout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 48,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Confirm Logout',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to logout?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Common.saveSharedPref("isLogin", "false");
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()),
                            (route) => false,
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Logout'),
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

  void _permissionDialogue(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline_rounded, color: Colors.orange),
            const SizedBox(width: 10),
            Text('Access Denied',
                style: TextStyle(color: Colors.grey.shade800)),
          ],
        ),
        content: Text(
            'You do not have permission to $title. Please contact your administrator for access.',
            style: TextStyle(color: Colors.grey.shade600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _upgrade(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Upgrade Required'),
        content: const Text(
            'This feature requires a premium plan. Please contact our support team to upgrade.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          TextButton(
            onPressed: () async {
              String url = 'tel:${configure!.data!.supportTeamNumber}';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
            },
            child: const Text('Call Support',
                style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

class MessageViewWidget extends StatelessWidget {
  const MessageViewWidget({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: const BorderRadius.all(
            Radius.circular(
              10.0,
            ),
          ),
        ),
        child: Text(label));
  }
}
