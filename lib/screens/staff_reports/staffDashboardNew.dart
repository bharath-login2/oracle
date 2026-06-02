// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'dart:developer';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shimmer/shimmer.dart';
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
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/lead_management/documentListModel.dart';
import '../../models/lead_management/salaryDetailsModel.dart';
import '../authentication/googleDriveAccountsModel.dart';
import '../../models/lead_management/getStaffDocumentListModel.dart';
import '../../models/lead_management/getStaffSalaryDetailsModel.dart';
import '../../models/lead_management/staffAccountDetailsModel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffReportDashboardNew extends StatefulWidget {
  String id;
  StaffReportDashboardNew({super.key, required this.id});

  @override
  State<StaffReportDashboardNew> createState() =>
      _StaffReportDashboardNewState();
}

class _StaffReportDashboardNewState extends State<StaffReportDashboardNew>
    with SingleTickerProviderStateMixin {
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
  SalaryDetailsModel? salaryDetails;
  GetStaffSalaryDetailsModel? staffSalaryDetails;
  bool isLoading = true;
  String selectedDocumentType = 's3';
  List<DocumentData> documentTypes = [];
  String? selectedDocumentTypeId;
  String selectedDocumentTypeName = 'Select Document';
  List<DriveAccount> googleDriveAccounts = [];
  List<StaffDocument> googleDriveFiles = [];
  DriveAccount? selectedDriveAccount;
  bool isDriveAccountsLoading = false;
  bool isDriveFilesLoading = false;
  String? selectedFolderId;
  String? currentFolderName;
  List<Map<String, String>> driveBreadcrumbs = [
    {'id': 'root', 'name': 'Drive'}
  ];
  String path = '';
  TabController? _tabController;
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
    _tabController = TabController(length: 3, vsync: this);
    await getDocumentTypes();
    await _fetchGoogleDriveAccounts();
    await getSalaryDetails();

    setState(() {
      isLoading = false;
    });
  }

  getSalaryDetails() async {
    salaryDetails = await HttpService.getSalaryDetails(widget.id);
    staffSalaryDetails = await HttpService.getStaffSalaryDetails(widget.id);
    if (mounted) setState(() {});
  }

  getDocumentTypes() async {
    DocumentListModel? documentList =
        await HttpService.getDocumentType(widget.id);
    if (documentList != null && documentList.status == true) {
      documentTypes = documentList.data;
      if (documentTypes.isNotEmpty) {
        selectedDocumentTypeId = documentTypes.first.id;
        selectedDocumentTypeName = documentTypes.first.documentName;
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _fetchGoogleDriveAccounts() async {
    if (!mounted) return;
    setState(() => isDriveAccountsLoading = true);
    final response = await HttpService.getGoogleDriveAccounts();
    if (mounted && response != null && response.status) {
      googleDriveAccounts =
          response.data.where((a) => a.isActive == "1").toList();
      try {
        final defaultAccount =
            googleDriveAccounts.firstWhere((a) => a.isActive == "1");
        selectedDriveAccount = defaultAccount;
        _fetchGoogleDriveFiles(defaultAccount.id);
      } catch (_) {}
    }
    if (mounted) setState(() => isDriveAccountsLoading = false);
  }

  Future<void> _fetchGoogleDriveFiles(String accountId) async {
    if (!mounted) return;
    setState(() {
      isDriveFilesLoading = true;
      googleDriveFiles = [];
    });
    final response =
        await HttpService.getStaffDocumentList("Staff", accountId, widget.id);
    if (mounted && response != null && response.status == true) {
      googleDriveFiles = response.data ?? [];
    }
    if (mounted) setState(() => isDriveFilesLoading = false);
  }

  void _updateBreadcrumbs(String id, String name) {
    setState(() => driveBreadcrumbs.add({'id': id, 'name': name}));
  }

  void _popBreadcrumb() {
    if (driveBreadcrumbs.length > 1) {
      setState(() {
        driveBreadcrumbs.removeLast();
        final last = driveBreadcrumbs.last;
        selectedFolderId = last['id'] == 'root' ? null : last['id'];
        currentFolderName = last['id'] == 'root' ? null : last['name'];
      });
      _fetchGoogleDriveFiles(selectedDriveAccount!.id);
    } else {
      setState(() {
        selectedDriveAccount = null;
        selectedFolderId = null;
        currentFolderName = null;
        driveBreadcrumbs = [
          {'id': 'root', 'name': 'Drive'}
        ];
      });
    }
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
              child: Column(
                children: [
                  _buildModernAppBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDashboardTab(),
                        _buildDocumentTab(),
                        _buildSalaryTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2a86c9),
            Color(0xFF406dbe),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                _buildBackButton(),
                const SizedBox(width: 16),
                _buildStaffAvatar(),
                const SizedBox(width: 16),
                Expanded(child: _buildStaffInfo()),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: "Staff Dashboard"),
              Tab(text: "Staff Document"),
              Tab(text: "Salary"),
            ],
          ),
          const SizedBox(height: 8),
        ],
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
        final progressValue = double.parse(target.progressPercentage) / 100;

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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Name
                Text(
                  target.groupName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Target and Achieved values on left and right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Target on Left
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "TARGET",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${target.targetAmount}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    // Achieved on Right
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "ACHIEVED",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${target.achieved}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Progress Bar
                Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressValue >= 1 ? Colors.green : Colors.blue,
                            ),
                            minHeight: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "0%",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          "${target.progressPercentage}%",
                          style: TextStyle(
                            color:
                                progressValue >= 1 ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "100%",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                      ],
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

  // Widget _buildTargetList() {
  //   if (staffDetails!.data.userTarget.isEmpty) {
  //     return _buildEmptyState("No target data available");
  //   }

  //   return ListView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemCount: staffDetails!.data.userTarget.length,
  //     itemBuilder: (context, index) {
  //       final target = staffDetails!.data.userTarget[index];
  //       return GestureDetector(
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => AchievementDetailsPage(
  //                 targetData: target,
  //                 targetFromDate: DateTime.tryParse(targetFromDate),
  //                 targetToDate: DateTime.tryParse(targetToDate),
  //               ),
  //             ),
  //           );
  //         },
  //         child: Container(
  //           margin: const EdgeInsets.only(bottom: 16),
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //               colors: [
  //                 const Color(0xFF667eea).withOpacity(0.9),
  //                 const Color(0xFF764ba2).withOpacity(0.9),
  //               ],
  //             ),
  //             borderRadius: BorderRadius.circular(16),
  //           ),
  //           child: Column(
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Expanded(
  //                     child: Text(
  //                       target.groupName,
  //                       style: const TextStyle(
  //                         color: Colors.white,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 16,
  //                       ),
  //                     ),
  //                   ),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.end,
  //                     children: [
  //                       Text(
  //                         "Target: ₹${target.targetAmount}",
  //                         style: const TextStyle(
  //                           color: Colors.white70,
  //                           fontSize: 12,
  //                         ),
  //                       ),
  //                       Text(
  //                         "Achieved: ₹${target.achieved}",
  //                         style: const TextStyle(
  //                           color: Colors.white,
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 14,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 12),
  //               Stack(
  //                 children: [
  //                   ClipRRect(
  //                     borderRadius: BorderRadius.circular(12),
  //                     child: LinearProgressIndicator(
  //                       value: double.parse(target.progressPercentage) / 100,
  //                       backgroundColor: Colors.white.withOpacity(0.3),
  //                       valueColor:
  //                           const AlwaysStoppedAnimation<Color>(Colors.white),
  //                       minHeight: 24,
  //                     ),
  //                   ),
  //                   Positioned.fill(
  //                     child: Center(
  //                       child: Text(
  //                         "${target.progressPercentage}%",
  //                         style: const TextStyle(
  //                           color: Colors.white,
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 12,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

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
              // Expanded(
              //   child: _buildMetricCard(
              //     icon: Icons.timeline,
              //     label: "Call Timeline",
              //     value: "View Details",
              //     color: const Color(0xFF4facfe),
              //     onTap: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => const TimelinePage(),
              //           settings: RouteSettings(
              //             arguments: {
              //               "staffId": staffDetails!.data.userData.userId
              //             },
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
              //  const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.call_end,
                  label: "Total Call Duration",
                  value: callDetails!.data.callDetails.totDurationSum,
                  color: const Color(0xFF43e97b),
                  onTap: null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
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
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF4facfe).withOpacity(0.1),
                    foregroundColor: const Color(0xFF4facfe),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timeline, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "View Call Timeline",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTargetReportCard(),
          const SizedBox(height: 20),
          _buildCallStatusCard(),
          const SizedBox(height: 20),
          _buildLeadStatusSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDocumentTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Upload Files",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a237e),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          _buildDocumentTypeSelector(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Select Storage Provider",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 8),
          _buildStorageProviderSelection(),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Documents",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 166, 168, 180),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text("Upload"),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 400, // Fixed height for scrollable file list
            child: selectedDocumentType == 's3'
                ? _buildS3Documents()
                : _buildDriveDocuments(),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Document Name",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedDocumentTypeId,
                isExpanded: true,
                hint: const Text("-- Select Document --"),
                onChanged: (value) {
                  setState(() {
                    selectedDocumentTypeId = value;
                    selectedDocumentTypeName = documentTypes
                        .firstWhere((e) => e.id == value)
                        .documentName;
                  });
                },
                items: documentTypes.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc.id.toString(),
                    child: Text(doc.documentName),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageProviderSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStorageCard(
              label: "Google Drive",
              assetPath: 'assets/icons/drive.png',
              isSelected: selectedDocumentType == 'drive',
              colors: [const Color(0xFF4285F4), const Color(0xFF34A853)],
              onTap: () {
                setState(() => selectedDocumentType = 'drive');
                if (googleDriveAccounts.isEmpty) _fetchGoogleDriveAccounts();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStorageCard(
              label: "S3 Bucket",
              assetPath: 'assets/icons/cloud2.jpg',
              isSelected: selectedDocumentType == 's3',
              colors: [const Color(0xFF2a86c9), const Color(0xFF406dbe)],
              onTap: () => setState(() => selectedDocumentType = 's3'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard({
    required String label,
    required String assetPath,
    required bool isSelected,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.first.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.first : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Image.asset(assetPath, height: 32, width: 32, fit: BoxFit.contain),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colors.first : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildS3Documents() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("S3 Storage content will appear here"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Upload to S3"),
          ),
        ],
      ),
    );
  }

  Widget _buildDriveDocuments() {
    if (isDriveAccountsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedDriveAccount == null) {
      if (googleDriveAccounts.isEmpty) {
        return const Center(child: Text("No Drive Accounts Found"));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: googleDriveAccounts.length,
        itemBuilder: (context, index) =>
            _buildDriveEmailCard(googleDriveAccounts[index]),
      );
    }

    return Column(
      children: [
        _buildDriveHeader(),
        Expanded(
          child: isDriveFilesLoading
              ? const Center(child: CircularProgressIndicator())
              : googleDriveFiles.isEmpty
                  ? const Center(child: Text("No Files Found"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: googleDriveFiles.length,
                      itemBuilder: (context, index) =>
                          _buildGoogleDriveFileItem(googleDriveFiles[index]),
                    ),
        ),
      ],
    );
  }

  Widget _buildDriveEmailCard(DriveAccount account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(Icons.email, color: Colors.blue),
        ),
        title: Text(account.accountEmail),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          setState(() => selectedDriveAccount = account);
          _fetchGoogleDriveFiles(account.id);
        },
      ),
    );
  }

  Widget _buildDriveHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _popBreadcrumb,
          ),
          Expanded(
            child: Text(
              currentFolderName ?? "Root",
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.blue),
            onPressed: () => _uploadStaffDocuments(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleDriveFileItem(StaffDocument file) {
    return InkWell(
      onLongPress: () => _showFileOptions(file),
      onTap: () async {
        String? linkToOpen = file.thumbnailLink ?? file.webViewLink;
        if (linkToOpen != null && linkToOpen.isNotEmpty) {
          final Uri url = Uri.parse(linkToOpen);
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            Common.toastMessaage("Could not launch $linkToOpen", Colors.red);
          }
        } else {
          Common.toastMessaage(
              "No link available for this file", Colors.orange);
        }
      },
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (file.thumbnailLink != null &&
                    file.thumbnailLink!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      file.thumbnailLink!,
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.insert_drive_file,
                          color: Colors.grey,
                          size: 40),
                    ),
                  )
                else
                  const Icon(Icons.insert_drive_file,
                      color: Colors.grey, size: 40),
                const SizedBox(height: 4),
                Text(
                  file.fileName ?? "Unknown",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Updated At:${file.uploadedAt ?? ""}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 8),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
              onPressed: () => _confirmDeleteFile(file),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadStaffDocuments() async {
    if (selectedDriveAccount == null) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() => isDriveFilesLoading = true);
      try {
        List<MultipartFile> multipartFiles = [];
        List<String> docTypes = [];

        for (var file in result.files) {
          if (file.path != null) {
            multipartFiles.add(
                await MultipartFile.fromFile(file.path!, filename: file.name));
            docTypes.add(selectedDocumentTypeId ?? "");
          }
        }

        final staffName = staffDetails?.data.userData.staffName ?? "";

        final response = await HttpService.staffDocumentUpload(
          selectedDriveAccount!.id,
          docTypes,
          multipartFiles,
          staffName,
          staffDetails!.data.userData.userId,
        );

        if (response != null && response.status == true) {
          Common.toastMessaage(
              response.message ?? "Uploaded successfully", Colors.green);
          _fetchGoogleDriveFiles(selectedDriveAccount!.id);
        } else {
          Common.toastMessaage(
              response?.message ?? "Upload failed", Colors.red);
        }
      } catch (e) {
        log("Upload error: $e");
        Common.toastMessaage("Error during upload", Colors.red);
      } finally {
        setState(() => isDriveFilesLoading = false);
      }
    }
  }

  void _confirmDeleteFile(StaffDocument file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete File"),
        content: Text("Are you sure you want to delete '${file.fileName}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStaffDocument(file);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStaffDocument(StaffDocument file) async {
    if (file.fileId == null || selectedDriveAccount == null) return;

    setState(() => isDriveFilesLoading = true);
    try {
      final response = await HttpService.deleteGoogleDriveFilesndFolders(
          file.fileId!, selectedDriveAccount!.id);
      if (response != null && response.status == true) {
        Common.toastMessaage(
            response.message ?? "Deleted successfully", Colors.green);
        _fetchGoogleDriveFiles(selectedDriveAccount!.id);
      } else {
        Common.toastMessaage(response?.message ?? "Delete failed", Colors.red);
      }
    } catch (e) {
      log("Delete error: $e");
      Common.toastMessaage("Error during deletion", Colors.red);
    } finally {
      setState(() => isDriveFilesLoading = false);
    }
  }

  void _showFileOptions(StaffDocument file) {
    // Optional: show more options on long press
  }

  Widget _buildSalaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  "Add Salary",
                  Icons.add_circle_outline,
                  const Color(0xFF2a86c9),
                  () => _showAddSalaryDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  "Add Staff A/C",
                  Icons.account_balance_wallet_outlined,
                  const Color(0xFF406dbe),
                  () => _showAddStaffAccountDialog(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Current Salary Highlight
          if (staffSalaryDetails != null)
            _buildCurrentSalaryCard(staffSalaryDetails!.data.currentSalary),

          const SizedBox(height: 24),

          // Salary History Section
          const Text(
            "Salary History",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          if (staffSalaryDetails == null ||
              staffSalaryDetails!.data.history.isEmpty)
            _buildEmptyHistory()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: staffSalaryDetails!.data.history.length,
              itemBuilder: (context, index) {
                return _buildSalaryHistoryCard(
                    staffSalaryDetails!.data.history[index]);
              },
            ),

          // const SizedBox(height: 20),
          // if (salaryDetails != null) ...[
          //   const Divider(),
          //   const SizedBox(height: 12),
          //   const Text(
          //     "Monthly Breakdown",
          //     style: TextStyle(
          //       fontSize: 18,
          //       fontWeight: FontWeight.bold,
          //       color: Colors.black87,
          //     ),
          //   ),
          //   const SizedBox(height: 12),
          //   _buildSalaryDetailCard(
          //       "Monthly Salary",
          //       "₹${salaryDetails!.data.salaryDetails.monthlySalary}",
          //       LucideIcons.banknote,
          //       Colors.blue),
          //   _buildSalaryDetailCard(
          //       "Incentives",
          //       "₹${salaryDetails!.data.salaryDetails.incentives}",
          //       LucideIcons.plusCircle,
          //       Colors.orange),
          //   _buildSalaryDetailCard(
          //       "Deductions",
          //       "₹${salaryDetails!.data.salaryDetails.deductions}",
          //       LucideIcons.minusCircle,
          //       Colors.red),
          //   _buildSalaryDetailCard(
          //       "Net Salary",
          //       "₹${salaryDetails!.data.salaryDetails.netSalary}",
          //       LucideIcons.wallet,
          //       Colors.green),
          // ]
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSalaryCard(String salary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2a86c9).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Staff Current Salary",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₹ $salary",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.history, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            "No salary history found",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryHistoryCard(SalaryHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹ ${history.amount}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2a86c9),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.blue, size: 20),
                    onPressed: () => _showAddSalaryDialog(history: history),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    onPressed: () => _deleteSalaryDialog(history.id),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                "${history.fromDate}  -  ${history.toDate.isEmpty ? 'Present' : history.toDate}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person,
                  size: 14, color: Color.fromARGB(255, 8, 8, 8)),
              const SizedBox(width: 6),
              Text(
                "Created By: ${history.createdByName}",
                style: TextStyle(
                    color: const Color.fromARGB(255, 19, 18, 18), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Color.fromARGB(255, 27, 27, 27)),
              const SizedBox(width: 6),
              Text(
                "Created At: ${history.createdAt}",
                style: TextStyle(
                    color: const Color.fromARGB(255, 36, 35, 35), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.credit_card,
                  size: 14, color: Color.fromARGB(255, 27, 27, 27)),
              const SizedBox(width: 6),
              Text(
                "Remark: ${history.remark}",
                style: TextStyle(
                    color: const Color.fromARGB(255, 36, 35, 35), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddSalaryDialog({SalaryHistory? history}) {
    final TextEditingController amountController =
        TextEditingController(text: history?.amount ?? "");
    final TextEditingController fromDateController =
        TextEditingController(text: history?.fromDate ?? "");
    final TextEditingController toDateController =
        TextEditingController(text: history?.toDate ?? "");
    final TextEditingController remarkController =
        TextEditingController(text: history?.remark ?? "");

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(history == null ? "Add Salary" : "Edit Salary",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogLabel("Amount *"),
                _buildDialogTextField(
                  controller: amountController,
                  hint: "Enter Amount",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDialogLabel("From Date *"),
                _buildDatePickerField(
                  context,
                  fromDateController,
                  "Select From Date",
                ),
                const SizedBox(height: 16),
                _buildDialogLabel("To Date"),
                _buildDatePickerField(
                  context,
                  toDateController,
                  "Select To Date",
                ),
                const SizedBox(height: 16),
                _buildDialogLabel("Remark"),
                _buildDialogTextField(
                  controller: remarkController,
                  hint: "Enter Remark",
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF406dbe),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                 const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (amountController.text.isEmpty ||
                          fromDateController.text.isEmpty) {
                        Common.toastMessaage(
                            "Please fill required fields", Colors.red);
                        return;
                      }

                      Common.showProgressDialog(context, "Saving Salary...");
                      final success = await HttpService.saveSalary(
                        salaryId: history?.id,
                        staffId: widget.id,
                        amount: amountController.text,
                        fromDate: fromDateController.text,
                        toDate: toDateController.text,
                        remark: remarkController.text,
                      );
                      Navigator.pop(context); 
                      if (success) {
                        Navigator.pop(context); 
                        getSalaryDetails(); 
                        Common.toastMessaage(
                            "Salary saved successfully", Colors.green);
                      } else {
                        Common.toastMessaage(
                            "Failed to save salary", Colors.red);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00bfa5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStaffAccountDialog() async {
    Common.showProgressDialog(context, "Fetching account details...");
    final details = await HttpService.getStaffAccountDetails(widget.id);
    Navigator.pop(context);
    bool hasSalaryData = details?.data.salary.accountId.isNotEmpty ?? false;
    bool hasPettyData = details?.data.petty.accountId.isNotEmpty ?? false;
    bool isSalary = hasSalaryData;
    bool isPettyCash = hasPettyData;
    final TextEditingController openingBalanceController =
        TextEditingController(text: details?.data.salary.openingBalance ?? "0");
    final TextEditingController dateController = TextEditingController(
        text: details?.data.salary.openingDate ??
            DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final TextEditingController pettyOpeningBalanceController =
        TextEditingController(text: details?.data.petty.openingBalance ?? "0");
    final TextEditingController pettyDateController = TextEditingController(
        text: details?.data.petty.openingDate ??
            DateFormat('yyyy-MM-dd').format(DateTime.now()));
    String salaryType = "Advance";
    if (details != null && details.data.salary.debitOrCredit.isNotEmpty) {
      salaryType =
          details.data.salary.debitOrCredit == "Credit" ? "Advance" : "Pending";
    }
    String pettyType = "Advance";
    if (details != null && details.data.petty.debitOrCredit.isNotEmpty) {
      pettyType =
          details.data.petty.debitOrCredit == "Credit" ? "Advance" : "Pending";
    }
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Staff Accounts",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!hasSalaryData)
                      Checkbox(
                        value: isSalary,
                        onChanged: (val) =>
                            setDialogState(() => isSalary = val!),
                        activeColor: const Color(0xFF406dbe),
                      ),
                    const Text("Salary A/C",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                if (isSalary) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDialogLabel("Opening Balance"),
                            _buildDialogTextField(
                              controller: openingBalanceController,
                              hint: "0",
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDialogLabel("Date"),
                            _buildDatePickerField(
                                context, dateController, "Select Date"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: "Advance",
                            groupValue: salaryType,
                            onChanged: (val) =>
                                setDialogState(() => salaryType = val!),
                            activeColor: Colors.blue,
                          ),
                          const Text("Advance"),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Row(
                        children: [
                          Radio<String>(
                            value: "Pending",
                            groupValue: salaryType,
                            onChanged: (val) =>
                                setDialogState(() => salaryType = val!),
                            activeColor: Colors.blue,
                          ),
                          const Text("Pending"),
                        ],
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (!hasPettyData)
                      Checkbox(
                        value: isPettyCash,
                        onChanged: (val) =>
                            setDialogState(() => isPettyCash = val!),
                        activeColor: const Color(0xFF406dbe),
                      ),
                    const Text("Petty Cash A/C",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                if (isPettyCash) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDialogLabel("Opening Balance"),
                            _buildDialogTextField(
                              controller: pettyOpeningBalanceController,
                              hint: "0",
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDialogLabel("Date"),
                            _buildDatePickerField(
                                context, pettyDateController, "Select Date"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: "Advance",
                            groupValue: pettyType,
                            onChanged: (val) =>
                                setDialogState(() => pettyType = val!),
                            activeColor: Colors.blue,
                          ),
                          const Text("Advance"),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Row(
                        children: [
                          Radio<String>(
                            value: "Pending",
                            groupValue: pettyType,
                            onChanged: (val) =>
                                setDialogState(() => pettyType = val!),
                            activeColor: Colors.blue,
                          ),
                          const Text("Pending"),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text("Close"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Common.showProgressDialog(context, "Saving Account...");
                      final success = await HttpService.saveStaffAccounts(
                        userId: widget.id,
                        salary: "0",
                        isSalary: isSalary ? "1" : "0",
                        openingBalance: openingBalanceController.text,
                        openingDate: dateController.text,
                        type: salaryType == "Advance" ? "Credit" : "Debit",
                        isPettyCash: isPettyCash ? "1" : "0",
                        pettyOpeningBalance: pettyOpeningBalanceController.text,
                        pettyOpeningDate: pettyDateController.text,
                        pettyType: pettyType == "Advance" ? "Credit" : "Debit",
                      );
                      Navigator.pop(context);

                      if (success) {
                        Navigator.pop(context);
                        getSalaryDetails();
                        Common.toastMessaage("Account saved", Colors.green);
                      } else {
                        Common.toastMessaage(
                            "Failed to save account", Colors.red);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00bfa5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 18),
                        SizedBox(width: 8),
                        Text("Save"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildDatePickerField(
      BuildContext context, TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          controller.text = DateFormat('dd-MM-yyyy').format(date);
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        suffixIcon: const Icon(Icons.calendar_month, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  void _deleteSalaryDialog(String salaryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Salary"),
        content:
            const Text("Are you sure you want to delete this salary record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Common.showProgressDialog(context, "Deleting...");
              final success = await HttpService.deleteSalaryDetails(salaryId);
              Navigator.pop(context);
              if (success) {
                Navigator.pop(context);
                getSalaryDetails();
                Common.toastMessaage("Deleted successfully", Colors.green);
              } else {
                Common.toastMessaage("Failed to delete", Colors.red);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryDetailCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
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
