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
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/lead_management/documentListModel.dart';
import '../../models/lead_management/salaryDetailsModel.dart';
import '../authentication/googleDriveAccountsModel.dart';
import '../authentication/googleDriveFilesModel.dart';
import 'package:path/path.dart' as p;

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
  bool isLoading = true;

  // File Manager State
  String selectedDocumentType = 's3';
  List<DocumentData> documentTypes = [];
  String? selectedDocumentTypeId;
  String selectedDocumentTypeName = 'Select Document';

  List<DriveAccount> googleDriveAccounts = [];
  List<GoogleDriveFile> googleDriveFiles = [];
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
    if (mounted) setState(() {});
  }

  getDocumentTypes() async {
    DocumentListModel? documentList = await HttpService.getDocumentType();
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
      googleDriveAccounts = response.data;
      try {
        final defaultAccount =
            googleDriveAccounts.firstWhere((a) => a.isActive == "1");
        selectedDriveAccount = defaultAccount;
        _fetchGoogleDriveFiles(defaultAccount.id);
      } catch (_) {}
    }
    if (mounted) setState(() => isDriveAccountsLoading = false);
  }

  Future<void> _fetchGoogleDriveFiles(String accountId,
      {String parentId = ""}) async {
    if (!mounted) return;
    setState(() {
      isDriveFilesLoading = true;
      googleDriveFiles = [];
    });
    final response = await HttpService.getGoogleDriveFiles(
        "", accountId, parentId,
        refFunction: "Media");
    if (mounted && response != null && response.status) {
      googleDriveFiles = response.data;
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
      _fetchGoogleDriveFiles(selectedDriveAccount!.id,
          parentId: selectedFolderId ?? "");
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
    // Basic S3 view, can be expanded like in FileManagerList
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
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleDriveFileItem(GoogleDriveFile file) {
    IconData icon =
        file.isFolder == 'Y' ? Icons.folder : Icons.insert_drive_file;
    Color color = file.isFolder == 'Y' ? Colors.blue : Colors.grey;

    return InkWell(
      onTap: () {
        if (file.isFolder == 'Y') {
          setState(() {
            selectedFolderId = file.fileId ?? file.id;
            currentFolderName = file.fileName;
          });
          _updateBreadcrumbs(selectedFolderId!, currentFolderName!);
          _fetchGoogleDriveFiles(selectedDriveAccount!.id,
              parentId: selectedFolderId!);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 4),
          Text(
            file.fileName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryTab() {
    if (salaryDetails == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.banknote,
                  size: 64, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Salary Data Found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add salary details for this staff member to get started.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            _buildAddSalaryButton(),
          ],
        ),
      );
    }

    final data = salaryDetails!.data;
    final salary = data.salaryDetails;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSalaryTotalCard(salary.netSalary.toStringAsFixed(2)),
          const SizedBox(height: 20),
          _buildSalaryDetailCard("Monthly Salary", "₹${salary.monthlySalary}",
              LucideIcons.banknote, Colors.blue),
          _buildSalaryDetailCard("Per Day Salary", "₹${salary.perDaySalary}",
              LucideIcons.calendarDays, Colors.green),
          _buildSalaryDetailCard("Incentives", "₹${salary.incentives}",
              LucideIcons.plusCircle, Colors.orange),
          _buildSalaryDetailCard("Deductions", "₹${salary.deductions}",
              LucideIcons.minusCircle, Colors.red),
          const SizedBox(height: 30),
          _buildAddSalaryButton(),
        ],
      ),
    );
  }

  Widget _buildSalaryTotalCard(String netSalary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Current Net Salary",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "₹ $netSalary",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
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

  Widget _buildAddSalaryButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          _showSalaryAddDialog();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Salary Add",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 47, 131, 180),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
      ),
    );
  }

  void _showSalaryAddDialog() {
    final TextEditingController salaryAmountController =
        TextEditingController();
    final TextEditingController openingBalanceController =
        TextEditingController();
    String salaryType = "Advance";
    bool isPettyCash = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 0,
              backgroundColor: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.blueAccent],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(LucideIcons.banknote,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Add Salary Details",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Salary Amount Field
                    TextField(
                      controller: salaryAmountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: "Salary Amount",
                        hintText: "Enter salary amount",
                        prefixIcon: const Icon(Icons.currency_rupee,
                            size: 20, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Opening Balance Field
                    TextField(
                      controller: openingBalanceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: "Opening Balance",
                        hintText: "Enter opening balance",
                        prefixIcon: const Icon(LucideIcons.wallet,
                            size: 20, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Salary Type",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  setDialogState(() => salaryType = "Advance"),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: salaryType == "Advance"
                                      ? Colors.blue.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Radio<String>(
                                      value: "Advance",
                                      groupValue: salaryType,
                                      onChanged: (val) => setDialogState(
                                          () => salaryType = val!),
                                      activeColor: Colors.blue,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    const Text("Advance",
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  setDialogState(() => salaryType = "Pending"),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: salaryType == "Pending"
                                      ? Colors.blue.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Radio<String>(
                                      value: "Pending",
                                      groupValue: salaryType,
                                      onChanged: (val) => setDialogState(
                                          () => salaryType = val!),
                                      activeColor: Colors.blue,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    const Text("Pending",
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            setDialogState(() => isPettyCash = !isPettyCash),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isPettyCash,
                                onChanged: (val) =>
                                    setDialogState(() => isPettyCash = val!),
                                activeColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                              const Text(
                                "Petty Cash Transaction",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Cancel",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (salaryAmountController.text.isEmpty) {
                                Common.toastMessaage(
                                    "Please enter salary amount", Colors.red);
                                return;
                              }

                              Common.showProgressDialog(
                                  context, "Adding Salary...");

                              final success =
                                  await HttpService.addSalaryDetails(
                                userId: widget.id,
                                salary: salaryAmountController.text,
                                openingBalance: openingBalanceController.text,
                                type: salaryType,
                                isPettyCash: isPettyCash ? "1" : "0",
                              );
                              Navigator.pop(context);

                              if (success) {
                                Navigator.pop(context);
                                Common.premiumToast(
                                  context,
                                  "Salary details added successfully",
                                  Icons.check_circle,
                                  color: Colors.green,
                                );
                                getSalaryDetails();
                              } else {
                                Common.toastMessaage(
                                    "Failed to add salary details", Colors.red);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Add Salary",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
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
      },
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
