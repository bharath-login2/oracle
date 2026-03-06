import 'dart:io';
import 'dart:math' as math;
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/leadDetailsModel.dart';
import 'package:login2/models/lead_management/leadDetailsModelAdd.dart';
import 'package:login2/models/lead_management/leadMileStoneListModel.dart';
import 'package:login2/models/lead_management/listFolderName.dart';
import 'package:login2/models/lead_management/addLeadCommonDataModel.dart';
import 'package:login2/models/lead_management/leadFollowupAdd.dart' as af;
import 'package:login2/models/lead_management/leadProductsModel.dart';
import 'package:login2/models/expense/account_dashboard.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/screens/accounts/clients/clientList.dart';
import 'package:login2/screens/complaints/complaint_list_screen.dart';
import 'package:login2/screens/fileManager/fileManagerList.dart';
import 'package:login2/screens/leadManagement/add_leads_new.dart';
import 'package:login2/screens/leadManagement/allReport.dart';
import 'package:login2/screens/leadManagement/quotationDashboard.dart';
import 'package:login2/screens/leadManagement/transferLeadReport.dart';
import 'package:login2/screens/leadManagement/viewLeadsNew.dart';
import 'package:login2/screens/leadManagement/viewallcompanyworks.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import 'package:login2/screens/officialWhatsapp/chat_home_screen.dart';
import 'package:login2/screens/product_mannagement/product_list.dart';
import 'package:login2/screens/roombooking/hotelDashboard.dart';
import 'package:login2/screens/serviceman/dashboard_page.dart';
import 'package:login2/screens/settings/whatsappSettings.dart';
import 'package:login2/screens/sidebarscreens/leadSidebarScreen.dart';
import 'package:login2/screens/staff_reports/staff_dashboard.dart';
import 'package:login2/screens/userManagement/viewUsers.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/common.dart';
import '../../service/service.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/dashboardModel.dart';
import 'package:login2/models/lead_management/dashboardLeadsCountsModel.dart';
import 'package:login2/models/lead_management/leadDashboardCountNewModel.dart';
import 'package:login2/models/expense/staffListModel.dart' as sl;
import '../../models/lead_management/leadDashboardModel.dart' as ld;
import '../../models/lead_management/viewLeadsModel.dart';
import '../../models/lead_management/leadProgressbarModel.dart' as lp;
import '../../models/lead_management/leadProgressBarStaffModel.dart' as lps;
import '../../models/lead_management/categoryWiseLeadBarModel.dart' as clb;
import '../../models/lead_management/leadProgressBarStatusWise.dart' as lpbsw;
import '../../models/lead_management/leadCategoryStaffWiseModel.dart';
import '../../models/lead_management/projectList_model.dart';
import '../../models/lead_management/workstatus_model.dart';
import '../../models/loginCheckModel.dart';
import '../../models/renewal/renewal_dashboard_model.dart';
import '../../models/clients/customerListModel.dart';
import '../authentication/login.dart';
import '../authentication/deep_link_handler.dart';
import '../bottom_navigation_bar.dart';
import '../homePage.dart';
import '../search/search.dart';
import '../leadManagement/notification_page.dart';
import '../leadManagement/lead_details_popup.dart';
import '../leadManagement/product_details_popup.dart';
import '../leadManagement/callHistoryPage.dart';
import '../leadManagement/projectDashboard.dart';
import '../leadManagement/minimalDashboard.dart';
import '../accounts/renewal_mannagement/renewal_dashboard.dart';
import '../accounts/dashboard/accounts_dashboard.dart';
import '../../widgets/viewLeadsFilterWidget.dart';
import '../../widgets/togglebutton_start.dart';
import '../drawerScreen.dart';
import '../../models/lead_management/BulkTransferLeadModel.dart';

class DashboardLeadNewUpdated extends StatefulWidget {
  String? token;
  final GlobalKey<_DashboardLeadNewUpdatedState>? dashboardKey;

  DashboardLeadNewUpdated(this.token, {super.key, this.dashboardKey});

  @override
  State<DashboardLeadNewUpdated> createState() =>
      _DashboardLeadNewUpdatedState();
}

class _DashboardLeadNewUpdatedState extends State<DashboardLeadNewUpdated>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ld.LeadDashboardModel? leadDashboard;
  CommonConfigureModel? configure;
  LeadCategoryStaffWiseModel? staffWise;
  DashboardModel? userDashboard;
  RenewalDashboardModel? renewalDashboard;
  ProjectList? projectList;
  WorkStatusModel? workStatus;
  CommonResponse? loginOrNot;
  List<String> selectedIUsers = [];
  List<String> selectedUserNumbers = [];
  String transferStaffToggleName = "Staff";
  String transferStaffToggleId = "";
  List<TransferStaff> filteredTransferStaff = [];
  String transferPermission = "false";
  AccountDashboardModel? accountDashboard;
  AddLeadCommonDataModel? commonDetails;
  lp.LeadProgressbarModel? object1;
  lps.LeadProgressBarStaffModel? staffProgressData;
  clb.CategoryWiseLeadBarModel? categoryProgressData;
  lpbsw.LeadProgressBarStatusWise? statusProgressData;
  String? firebaseToken;
  bool isLoading = true;
  bool timeOut = false;
  bool isExpired = false;
  bool isWorkStarted = false;
  bool loadmore = false;
  bool moreloading = false;
  List<Detail> listTabLeads = [];
  bool _isListTabLoading = false;
  bool isVisible = true;
  bool toggle = false;
  bool _isTabControllerInitialized = false;
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  DateTime fromDate1 = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime toDate1 = DateTime.now();
  DateTime targetFromDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime targetToDate =
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  String name = '';
  String role = '';
  String userId = '';
  String staffId = '';
  String notificationCount = '0';
  String accPermission = "";
  String renewalPermission = "false";
  String createLeadPermission = '';
  String viewLeadPermission = '';
  String viewAllWorkPermission = '';
  String viewTargetReportPermission = '';
  String addWorkPermission = '';
  String startAndStopWorkPermission = '';
  String workWithoutLogin = '';
  String adminCheckPermission = '';
  String viewAttendanceSection = '';
  String multipleUsersCheck = '';
  String multipleWorksCheck = '';
  String viewWorkReportPermission = '';
  String hasPhonecallAccess = '';
  String updateLeadPermission = '';
  String deleteLeadPermission = '';
  String phoneCallLogPermission = '';
  String accessCallHistoryPermission = '';
  String viewLeadCategoryPermission = '';
  String cloudCallPermission = '';
  String createLeadCategory = '';
  String updateLeadCategory = '';
  String deleteLeadCategory = '';
  String startAndStopWork = '';
  String accessCallRecordingPermission = '';
  String visibleP = '';
  String assignWork = "";
  String updateDashboard = "";
  String viewPendingWorks = "";
  String approvePayroll = "";
  String proformaInvoiceMenu = "";
  String gstInvoiceMenu = "";
  String pendingInvoiceMenu = "";
  String receiptMenu = "";
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  String? NewleadDashboardPermission;
  bool updateLeadPermission1 = false;
  bool deleteLeadPermission1 = false;
  bool cloudCallPermission1 = false;
  bool createLeadCategory1 = false;
  bool updateLeadCategory1 = false;
  bool deleteLeadCategory1 = false;
  bool accessCallRecordingPermission1 = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DashboardLeadsCountsModel? dashboardCounts;
  DashboardLeadCounts? dashboardMainCounts;
  bool isDashboardCountsLoading = false;
  String? targetStaffId;
  List<sl.Staff> staffList = [];
  TextEditingController searchController = TextEditingController();
  final Color primaryBlue = const Color(0xFF2a86c9);
  final Color darkBlue = const Color(0xFF1a5a8c);
  final Color lightBlue = const Color(0xFF64b5f6);
  final Color veryLightBlue = const Color(0xFFe3f2fd);
  bool _isCompactView = false;
  String _listTabFilter = 'New';
  int _listTabPage = 1;
  bool _hasMoreListTabLeads = true;
  bool _isListTabLoadingMore = false;
  int _totalLeads = 0;
  String? _listTabCurrentStatus = '1';
  String? _listTabCurrentLeadType;
  String? _listTabCurrentCallStatus;
  bool? _listTabCurrentIsCalled;
  bool _listTabCallPermission = true;
  final Set<String> _expandedLeadIds = {};
  List<String> _listTabSelectedStatusIds = [];
  List<String> _listTabSelectedStaffIds = [];
  List<String> _listTabSelectedCategoryIds = [];
  List<String> _listTabSelectedPriorityIds = [];
  List<String> _listTabSelectedProductIds = [];
  bool _isListTabFilterApplied = false;
  static const Color appBarStart = Color(0xFF2a86c9);
  static const Color callGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentRed = Color(0xFFF44336);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color borderLight = Color(0xFFECF0F1);
  static const Color backgroundLight = Color.fromARGB(255, 247, 249, 252);

  final List<Color> _colors = [
    Colors.black,
    Colors.teal,
    Colors.orange.shade800,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
    Colors.black,
    Colors.teal,
    Colors.orange.shade800,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
    Colors.black,
    Colors.teal,
    Colors.orange.shade800,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
    Colors.black,
    Colors.teal,
    Colors.orange.shade800,
    Colors.redAccent,
    Colors.green.shade800,
    Colors.blueAccent,
  ];

  Map<String, double> reportDataMap = {};
  int catNew = 0,
      catPending = 0,
      catFollowup = 0,
      catRejected = 0,
      catClosed = 0;

  DateTime? callStatusFromDate;
  DateTime? callStatusToDate;
  List<String> callStatusStaffs = [];
  bool isCallStatusLoading = false;
  lp.LeadProgressbarModel? callStatusData;

  DateTime? stageWiseFromDate;
  DateTime? stageWiseToDate;
  List<String> stageWiseStaffs = [];
  bool isStageWiseLoading = false;
  LeadCategoryStaffWiseModel? stageWiseData;

  DateTime? leadSourceFromDate;
  DateTime? leadSourceToDate;
  List<String> leadSourceStaffs = [];
  bool isLeadSourceLoading = false;

  DateTime? categoryFromDate;
  DateTime? categoryToDate;
  List<String> categoryStaffs = [];
  bool isCategoryLoading = false;
  LeadCategoryStaffWiseModel? categoryData;

  LeadProductSectionModel? productSectionModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    _tabController.addListener(_handleTabSelection);
    _isTabControllerInitialized = true;
    _initializeData();
  }

  void _handleTabSelection() {
    if (mounted) {
      setState(() {});
    }
    if (_tabController.index == 2 && !moreloading) {
      getStaffwise();
    }
  }

  int _getTabCount() {
    return 3;
  }

  void _updateTabController() {
    if (!mounted) return;

    final newLength = _getTabCount();
    if (_tabController.length != newLength) {
      final oldIndex = _tabController.index;
      _tabController.dispose();
      _tabController = TabController(
        length: newLength,
        vsync: this,
        initialIndex: oldIndex < newLength ? oldIndex : 0,
      );
      _tabController.addListener(_handleTabSelection);
      setState(() {});
    }
  }

  Future<void> _initializeData() async {
    productSectionModel = await HttpService.leadProductSection();
    await getData(widget.token, fromDate, toDate);
    _loadWorkStatus();
    _checkDashboardPermission();
    _updateTabController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      deepLinkHandler.getPendingDeepLink().then((data) {
        if (data != null && mounted) {
          deepLinkHandler.validateAndNavigate(context, data);
        }
      });
    });
  }

  void _checkDashboardPermission() async {
    proformaInvoiceMenu =
        await Common.getSharedPref("proformaInvoiceMenu") ?? "";
    gstInvoiceMenu = await Common.getSharedPref("gstInvoiceMenu") ?? "";
    pendingInvoiceMenu = await Common.getSharedPref("pendingInvoiceMenu") ?? "";
    receiptMenu = await Common.getSharedPref("receiptMenu") ?? "";
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    NewleadDashboardPermission =
        await Common.getSharedPref("NewleadDashboardPermission");

    setState(() {});
  }

  void _loadWorkStatus() async {
    String? status = await Common.getSharedPref("is_work_started");
    setState(() {
      isWorkStarted = status == "true";
    });
  }

  Future<void> getData(String? token, DateTime fromDate, DateTime toDate,
      {bool isRefresh = false}) async {
    setState(() {
      if (!isRefresh) isLoading = true;
      timeOut = false;
    });

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (!connectivityResult.contains(ConnectivityResult.mobile) &&
          !connectivityResult.contains(ConnectivityResult.wifi)) {
        setState(() {
          isLoading = false;
          timeOut = true;
        });
        return;
      }
      await _loadUserPermissions();
      _updateTabController();
      firebaseToken = await FirebaseMessaging.instance.getToken();
      LoginCheckModel? loginCheck =
          await HttpService.loginCheck(token, firebaseToken!);
      if (loginCheck?.data == false) {
        Common.toastMessaage('Session Expired', Colors.red);
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false,
          );
        }
        return;
      }
      configure = await HttpService.configure(token);
      if (configure != null) {
        isExpired = configure!.data!.isExpired!;
      }

      // Get new dashboard counts
      setState(() => isDashboardCountsLoading = true);
      try {
        final fDate = DateFormat('dd-MM-yyyy').format(fromDate);
        final tDate = DateFormat('dd-MM-yyyy').format(toDate);
        final targetFDate = DateFormat('dd-MM-yyyy').format(targetFromDate);
        final targetTDate = DateFormat('dd-MM-yyyy').format(targetToDate);
        final countsData = await HttpService.dashboardLeadsCounts(
            fromDate: fDate,
            toDate: tDate,
            userId: targetStaffId ?? userId,
            targetFromDate: targetFDate,
            targetToDate: targetTDate);

        final staffResponse = await HttpService.getStaffs();
        if (staffResponse != null && staffResponse.status) {
          staffList = staffResponse.data;
        }

        if (countsData != null && countsData.status == true) {
          setState(() {
            dashboardCounts = countsData;
          });
        }
      } catch (e) {
        log("Error fetching dashboard counts: $e");
      } finally {
        setState(() => isDashboardCountsLoading = false);
      }

      leadDashboard = await HttpService.leadDashboard(
          token, fromDate, toDate, fromDate1.toString(), toDate1.toString());

      final mainCounts = await HttpService.dashboardCountsMain();
      if (mainCounts != null) {
        setState(() {
          dashboardMainCounts = mainCounts;
        });
      }

      userDashboard = await HttpService.mainDashboard(widget.token);
      loginOrNot = await HttpService.getLoginorNot(widget.token);
      if (userDashboard != null) {
        await Common.saveSharedPref(
            "profile_pic", userDashboard!.data.profilePic);
        await Common.saveSharedPref(
            "whatsapp", userDashboard!.data.isWhatsappConfigured.toString());
        notificationCount =
            leadDashboard?.data.unreadNotification.toString() ?? '0';
      }
      await Future.wait([
        getAccountDash(),
        getRenewalDashboard(),
        getCustomerList(),
        HttpService.addLeadCommonData(token).then((val) => commonDetails = val),
      ]);
      await _checkLoginPrompt();
      await _checkLoginPrompt();

      // Always refresh tab leads when getData is called (including for filters)
      _fetchTabLeads();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      log("Error loading data: $e");
      setState(() {
        isLoading = false;
        timeOut = true;
      });
    }
  }

  Future<void> _loadUserPermissions() async {
    name = await Common.getSharedPref("name") ?? '';
    role = await Common.getSharedPref("role") ?? '';
    userId = await Common.getSharedPref("userId") ?? '';
    staffId = await Common.getSharedPref("staffId") ?? '';
    createLeadPermission =
        await Common.getSharedPref("createLeadPermission") ?? '';
    viewLeadPermission = await Common.getSharedPref("viewLeadPermission") ?? '';
    viewAllWorkPermission =
        await Common.getSharedPref("viewAllWorkPermission") ?? '';
    viewTargetReportPermission =
        await Common.getSharedPref("viewTargetReportPermission") ?? '';
    addWorkPermission = await Common.getSharedPref("addWorkPermission") ?? '';
    startAndStopWorkPermission =
        await Common.getSharedPref("startAndStopWorkPermission") ?? '';
    workWithoutLogin = await Common.getSharedPref("workWithoutLogin") ?? '';
    adminCheckPermission =
        await Common.getSharedPref("adminCheckPermission") ?? '';
    viewAttendanceSection =
        await Common.getSharedPref("viewAttendanceSection") ?? '';
    multipleUsersCheck = await Common.getSharedPref("multipleUsers") ?? '';
    multipleWorksCheck = await Common.getSharedPref("multipleWorks") ?? '';
    hasPhonecallAccess = await Common.getSharedPref("hasPhonecallAccess") ?? '';
    updateLeadPermission =
        await Common.getSharedPref("updateLeadPermission") ?? '';
    deleteLeadPermission =
        await Common.getSharedPref("deleteLeadPermission") ?? '';
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission") ?? '';
    accessCallHistoryPermission =
        await Common.getSharedPref("accessCallHistoryPermission") ?? '';
    transferPermission = await Common.getSharedPref("transferLeads") ?? '';
    viewLeadCategoryPermission =
        await Common.getSharedPref("viewLeadCategoryPermission") ?? '';
    cloudCallPermission =
        await Common.getSharedPref("cloudCallPermission") ?? '';
    createLeadCategory = await Common.getSharedPref("createLeadCategory") ?? '';
    updateLeadCategory = await Common.getSharedPref("updateLeadCategory") ?? '';
    deleteLeadCategory = await Common.getSharedPref("deleteLeadCategory") ?? '';
    assignWork = await Common.getSharedPref("assignWork") ?? '';
    viewPendingWorks = await Common.getSharedPref("viewPendingWorks") ?? '';
    approvePayroll = await Common.getSharedPref("approvePayroll") ?? '';
    updateDashboard = await Common.getSharedPref("updateDashboard") ?? '';
    accessCallRecordingPermission =
        await Common.getSharedPref("accessCallRecordingPermission") ?? '';
    visibleP = await Common.getSharedPref("isVisible") ?? '';
    updateLeadPermission1 = updateLeadPermission == 'true';
    deleteLeadPermission1 = deleteLeadPermission == 'true';
    cloudCallPermission1 = cloudCallPermission == 'true';
    createLeadCategory1 = createLeadCategory == 'true';
    updateLeadCategory1 = updateLeadCategory == 'true';
    deleteLeadCategory1 = deleteLeadCategory == 'true';
    accessCallRecordingPermission1 = accessCallRecordingPermission == 'true';
    isVisible = visibleP != 'true';
    renewalPermission =
        await Common.getSharedPref("renewalPermission") ?? "false";
    accPermission = await Common.getSharedPref("accPermission") ?? "";
    String tog = await Common.getSharedPref("acc_toggle") ?? "";
    toggle = tog == "true";
    if (targetStaffId == null) {
      targetStaffId = userId;
    }
  }

  Future<void> _checkLoginPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedDate = prefs.getString('loginPromptDismissedDate');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (dismissedDate != today && startAndStopWorkPermission == "true") {
      if (loginOrNot?.data != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showLoginPrompt(context);
        });
      }
    }
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Start Your Day",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/morning_login.json',
                height: 120,
                repeat: true,
              ),
              const SizedBox(height: 16),
              const Text(
                "You haven't logged in today. Start your work session now?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final today = DateTime.now().toIso8601String().substring(0, 10);
                await prefs.setString('loginPromptDismissedDate', today);
                if (!mounted) return;
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                "Later",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                _handleLogin();
              },
              child: const Text("Start Work"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: Lottie.asset(
                  'assets/lottie/location_loader.json',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Logging in...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final position = await _getLocation();
      if (position == null) return;
      final now = DateTime.now();
      final res = await HttpService.startWork(
        now,
        latitude: position.latitude,
        longitude: position.longitude,
        faceData: null,
      );
      if (!mounted) return;
      Navigator.of(context).pop();

      if (res?.status == true) {
        await Common.saveSharedPref("is_work_started", "true");
        setState(() => isWorkStarted = true);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Started at ${DateFormat('hh:mm a').format(now)}"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        getData(widget.token, fromDate, toDate);
      } else {
        _showError(res?.message ?? "Failed to start work");
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showError("Error: $e");
    }
  }

  Future<Position?> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError("Location permission required");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError("Location permission permanently denied");
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> getAccountDash() async {
    String fDate = DateFormat('dd-MM-yyyy').format(fromDate1);
    String tDate = DateFormat('dd-MM-yyyy').format(toDate1);
    accountDashboard = await HttpService.accountsDashboard(fDate, tDate);
    setState(() {});
  }

  Future<void> getRenewalDashboard() async {
    renewalDashboard = await HttpService.renewalDashboard();
    setState(() {});
  }

  Future<void> getCustomerList() async {
    try {
      CustomerListModel? customerData =
          await HttpService.customerList(widget.token);
      if (customerData?.status == true) {}
    } catch (e) {
      print("Error loading customers: $e");
    }
  }

  Future<void> getStaffwise() async {
    setState(() => moreloading = true);
    staffWise = await HttpService.leadDashboard1(widget.token, fromDate, toDate,
        fromDate1.toString(), toDate1.toString());
    await getLeadProgressbar(widget.token!, fromDate, toDate, "");
    if (staffWise != null) {
      _processReportData();
    }
    setState(() => moreloading = false);
  }

  void _processReportData() {
    reportDataMap.clear();
    for (int i = 0; i < (staffWise?.data?.categoryGraph?.length ?? 0); i++) {
      reportDataMap.addAll({
        staffWise!.data!.categoryGraph![i].categoryName.toString():
            staffWise!.data!.categoryGraph![i].categoryCount!.toDouble(),
      });
    }
    catNew = 0;
    catPending = 0;
    catFollowup = 0;
    catRejected = 0;
    catClosed = 0;
    for (int i = 0; i < (staffWise?.data?.categoryLeads?.length ?? 0); i++) {
      catNew += int.tryParse(
              staffWise!.data!.categoryLeads![i].newCount.toString()) ??
          0;
      catPending += int.tryParse(
              staffWise!.data!.categoryLeads![i].pendingCount.toString()) ??
          0;
      catFollowup += int.tryParse(
              staffWise!.data!.categoryLeads![i].followupCount.toString()) ??
          0;
      catRejected += int.tryParse(
              staffWise!.data!.categoryLeads![i].rejectedCount.toString()) ??
          0;
      catClosed += int.tryParse(
              staffWise!.data!.categoryLeads![i].confirmedCount.toString()) ??
          0;
    }
  }

  Future<void> getLeadProgressbar(String token, DateTime fromDate,
      DateTime toDate, String callStatus) async {
    final now = DateTime.now();
    object1 = await HttpService.leadProgressbar(
        token, now.toString(), now.toString(), callStatus);
  }

  Future<void> getLeadProgressBarStaffData({
    required String leadStatus,
    required String selectedType,
  }) async {
    final now = DateTime.now();
    staffProgressData = await HttpService.leadProgressBarStaff(
      fromDate: now.toString(),
      toDate: now.toString(),
      leadStatus: leadStatus,
      selectedType: selectedType,
    );
  }

  Future<void> getLeadProgressBarCategoryData({
    required String leadStatus,
  }) async {
    final now = DateTime.now();
    categoryProgressData = await HttpService.leadProgressBarCategory(
      fromDate: now.toString(),
      toDate: now.toString(),
      leadStatus: leadStatus,
    );
  }

  Future<void> getLeadProgressBarStatusData({
    required String leadStatus,
  }) async {
    final now = DateTime.now();
    statusProgressData = await HttpService.leadProgressBarStatus(
      fromDate: now.toString(),
      toDate: now.toString(),
      leadStatus: leadStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: veryLightBlue,
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        endDrawer: DraweScreen(widget.token!),
        bottomNavigationBar: configure != null
            ? BottomNavigation(
                widget.token!,
                phoneCallLogPermission: phoneCallLogPermission,
                name: name,
                userId: userId,
                scaffoldKey: _scaffoldKey,
              )
            : const SizedBox(),
      ),
    );
  }

  Future<bool> _exitApp(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Warning"),
        content: const Text("Are you sure to exit app?"),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              exit(0);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildBody() {
    if (timeOut) {
      return _buildErrorWidget();
    }

    return RefreshIndicator(
      onRefresh: () => getData(widget.token, fromDate, toDate, isRefresh: true),
      color: primaryBlue,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
            // Top Tabs (List, Dashboard, Report) - Now Scrolling
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: _buildTabBar(),
              ),
            ),
            // "New, Followup, Missed, Called, Transferred" Section - Now Sticky
            // Only visible on List tab as requested
            if (_tabController.index == 0 && leadDashboard?.data != null)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  minHeight: 100,
                  maxHeight: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _buildSummaryRowSection(leadDashboard!.data),
                  ),
                ),
              ),
          ];
        },
        body: _buildDashboardContent(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 65,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryBlue,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryBlue, darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          _buildProfileSection(),
          const Spacer(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return InkWell(
      onTap: () async {
        try {
          final result = await HttpService.getWorkStatus();
          if (result != null && result.data.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout Blocked'),
                content: const Text(
                    'Work is in progress. Please close all work before logging out.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            logout(context);
          }
        } catch (e) {
          log('Error checking work status: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to check work status')),
          );
        }
      },
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              backgroundImage: userDashboard != null
                  ? NetworkImage(userDashboard!.data.profilePic)
                  : null,
              child: userDashboard == null
                  ? const Icon(Icons.person, color: Color(0xFF2a86c9))
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (startAndStopWorkPermission == "true" && userDashboard != null)
          StartStopToggle(
            initialStatus: userDashboard!.data.loginCheck,
            onToggle: (bool started) {
              setState(() {
                userDashboard!.data.loginCheck = started;
              });
            },
            setDashboardLoading: (bool loading) {
              setState(() => isLoading = loading);
            },
          ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                if (notificationCount != '0')
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPage(
                    widget.token,
                    createLeadCategory1,
                    updateLeadCategory1,
                    deleteLeadCategory1,
                  ),
                ),
              ).then((_) => getData(widget.token, fromDate, toDate));
            },
          ),
        ),
        const SizedBox(width: 8),
        SettingsMenuWidget(
          token: widget.token!,
          name: name,
          userId: userId,
          staffId: staffId,
          isExpired: isExpired,
          configure: configure,
          leadDashboard: leadDashboard,
          fromdate: fromDate.toString(),
          todate: toDate.toString(),
          loadmore: loadmore,
          onDataRefresh: () => getData(widget.token, fromDate, toDate),
          onStaffwiseRefresh: getStaffwise,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
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
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: primaryBlue,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        tabs: [
          _buildAnimatedTab('LIST', 0),
          _buildAnimatedTab('DASHBOARD', 1),
          _buildAnimatedTab('REPORT', 2),
        ],
      ),
    );
  }

  Widget _buildAnimatedTab(String text, int index) {
    return Tab(
      child: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, child) {
          double offset = _tabController.animation!.value - index;
          double scale = 1.0 + (0.15 * (1.0 - offset.abs().clamp(0.0, 1.0)));
          return Transform.scale(
            scale: scale,
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent() {
    if (isLoading) {
      return _buildShimmerLoading();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // LIST Tab
        RefreshIndicator(
          onRefresh: () =>
              getData(widget.token, fromDate, toDate, isRefresh: true),
          displacement: 40,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!_isListTabLoadingMore &&
                  _hasMoreListTabLeads &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200) {
                _fetchTabLeads(isLoadMore: true);
                return true;
              }
              return false;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _buildListTab(),
            ),
          ),
        ),

        // DASHBOARD Tab
        RefreshIndicator(
          onRefresh: () =>
              getData(widget.token, fromDate, toDate, isRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: _buildDashboardTab(),
          ),
        ),

        // REPORT Tab
        RefreshIndicator(
          onRefresh: () =>
              getData(widget.token, fromDate, toDate, isRefresh: true),
          child: _buildReportTab(),
        ),
      ],
    );
  }

  Widget _buildDashboardTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuickActions(),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16, // Increased spacing
          crossAxisSpacing: 16, // Increased spacing
          childAspectRatio: 1.05, // Slightly adjusted
          padding: const EdgeInsets.symmetric(horizontal: 4),
          children: [
            // New Box
            _buildDashboardBox(
              title: 'New',
              mainValue:
                  (dashboardCounts?.data?.leads?.newLeads ?? 0).toString(),
              color: const Color(0xFF2a86c9),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Today's",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (dashboardCounts?.data?.leads?.newToday ?? 0)
                                .toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 24, color: Colors.white54),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Missed",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (dashboardCounts?.data?.leads?.newMissed ?? 0)
                                .toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _buildDashboardBox(
              title: 'Active',
              mainValue:
                  (dashboardCounts?.data?.leads?.activeLeads ?? 0).toString(),
              color: Colors.orange,
              child: _buildBoxIcons('Active', '2', 'Active Leads'),
            ),
            _buildDashboardBox(
              title: 'Closed',
              mainValue:
                  (dashboardCounts?.data?.leads?.closedLeads ?? 0).toString(),
              color: callGreen,
              child: _buildBoxIcons('Closed', '4', 'Closed Leads'),
            ),
            _buildDashboardBox(
              title: 'Lost',
              mainValue:
                  (dashboardCounts?.data?.leads?.rejectedLeads ?? 0).toString(),
              color: accentRed,
              child: _buildBoxIcons('Lost', '3', 'Lost Leads'),
            ),
            // Transferred Box
            // _buildDashboardBox(
            //   title: 'Transferred',
            //   mainValue: dashboardCounts != null
            //       ? "0"
            //       : (leadDashboard?.data.transferLeads.toString() ?? '0'),
            //   color: Colors.teal,
            //   child: Container(),
            // ),
          ],
        ),
        const SizedBox(height: 24),
        _buildTargetSection(),
        if (isVisible) ...[
          const SizedBox(height: 24),
          _buildModuleCarousel(),
        ],
        const SizedBox(height: 100), // Spacing for bottom nav
      ],
    );
  }

  Widget _buildTargetSection() {
    List<Target> targets = dashboardCounts?.data?.target ?? [];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Targets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            _buildTargetCalendar(),
            const Spacer(),
            GestureDetector(
              onTap: _showStaffSelectionModal,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: appBarStart.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_pin_rounded,
                        color: appBarStart, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      targetStaffId != null
                          ? (staffList
                              .firstWhere(
                                (s) =>
                                    s.userIdStaff.toString() == targetStaffId,
                                orElse: () => sl.Staff(
                                    id: '',
                                    name: 'Selected User',
                                    userIdStaff: ''),
                              )
                              .name)
                          : "Select Staff",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: appBarStart),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: appBarStart, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (targets.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No targets available"),
          )
        else
          ...targets.map((target) => _buildTargetItem(target)).toList(),
      ],
    );
  }

  Widget _buildTargetItem(Target target) {
    final double progress =
        double.tryParse(target.progressPercentage ?? "0.0") ?? 0.0;
    final double progressFraction = (progress / 100).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.track_changes_rounded,
                        color: primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        target.groupName ?? 'Target',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const Text(
                        'Performance tracker',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: borderLight,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    height: 10,
                    width: constraints.maxWidth * progressFraction,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, primaryBlue.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTargetStat('Target Amount', '₹${target.maxAmount ?? "0"}',
                  Icons.outlined_flag),
              _buildTargetStat('Total Achieved', '₹${target.achieved ?? "0"}',
                  Icons.check_circle_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: textSecondary,
                    fontWeight: FontWeight.w500)),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardBox({
    required String title,
    required String mainValue,
    required Color color,
    required Widget child,
  }) {
    return InkWell(
      onTap: () {
        if (title.contains('New')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'New Leads',
                fromDate: fromDate.toString(),
                toDate: toDate.toString(),
                status: '1',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate);
          });
        } else if (title.contains('Followup') || title.contains('Active')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Active Leads',
                fromDate: fromDate.toString(),
                toDate: toDate.toString(),
                status: '2',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate);
          });
        } else if (title.contains('Closed')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Closed Leads',
                fromDate: fromDate.toString(),
                toDate: toDate.toString(),
                status: '4',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate);
          });
        } else if (title.contains('Lost')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Lost Leads',
                fromDate: fromDate.toString(),
                toDate: toDate.toString(),
                status: '3',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate);
          });
        } else if (title.contains('Missed')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Missed Leads',
                fromDate: fromDate.toString(),
                toDate: toDate.toString(),
                status: '0',
                leadType: '1',
                callStatus: '-1',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate);
          });
        } else if (title.contains('Called')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Called Leads',
                fromDate: fromDate.toString(),
                toDate: toDate.toString(),
                status: '0',
                leadType: '-1',
                callStatus: '1',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate);
          });
        } else if (title.contains('Transferred')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Transferred Leads',
                fromDate: fromDate.toString(),
                toDate: toDate.toString(),
                status: '0',
                leadType: '2',
                callStatus: '-2',
              ),
            ),
          ).then((_) {
            getData(widget.token, fromDate, toDate);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative icon in background
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                _getBoxIcon(title),
                size: 50,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (title == 'Closed' || title == 'Lost')
                        GestureDetector(
                          onTap: _showGlobalDateRangePickerDialog,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Main Value
                  Text(
                    mainValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Additional content
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBoxIcon(String title) {
    if (title.contains('New')) return Icons.person_add_alt_1_rounded;
    if (title.contains('Active')) return Icons.bolt_rounded;
    if (title.contains('Closed')) return Icons.check_circle_rounded;
    if (title.contains('Lost')) return Icons.do_not_disturb_on_rounded;
    if (title.contains('Target')) return Icons.track_changes_rounded;
    return Icons.apps_rounded;
  }

  Widget _buildModuleCarousel() {
    if (userDashboard == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Quick Modules',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: userDashboard!.data.modules.length,
            itemBuilder: (context, index) {
              final module = userDashboard!.data.modules[index];
              return _buildModernModuleItem(module);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernModuleItem(dynamic module) {
    return GestureDetector(
      onTap: () => _handleModuleNavigation(module.menuName),
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryBlue.withOpacity(0.8),
                    darkBlue,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: module.image != null &&
                        module.image.toString().isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: module.image.toString(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          _getModuleIcon(module.menuName),
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                    : Icon(
                        _getModuleIcon(module.menuName),
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              module.categoryName ?? '',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getModuleIcon(String? menuName) {
    switch (menuName) {
      case 'call_management':
        return Icons.call_rounded;
      case 'Staff_management':
        return Icons.people_rounded;
      case 'Service':
        return Icons.build_rounded;
      case 'whatsapp':
        return FontAwesomeIcons.whatsapp;
      case 'room_management':
        return Icons.hotel_rounded;
      case 'Settings':
        return Icons.settings_rounded;
      case 'file_manager':
        return Icons.folder_rounded;
      case 'customers':
        return Icons.people_alt_rounded;
      case 'invoices':
        return Icons.receipt_rounded;
      case 'quotation':
        return Icons.description_rounded;
      case 'reports':
        return Icons.bar_chart_rounded;
      case 'renewal':
        return Icons.autorenew_rounded;
      case 'Work':
        return Icons.work_rounded;
      case 'complaints':
        return Icons.report_problem_rounded;
      case 'products':
        return Icons.inventory_2_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  Widget _buildListTab() {
    if (_isListTabLoading) {
      return _buildListShimmer();
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Header with total count, Filter, and Search
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _listTabFilter == 'New'
                              ? 'New Leads'
                              : _listTabFilter == 'Followup'
                                  ? 'Followup Leads'
                                  : _listTabFilter == 'Missed'
                                      ? 'Missed Leads'
                                      : _listTabFilter == 'Called'
                                          ? 'Called Leads'
                                          : _listTabFilter == 'Transferred'
                                              ? 'Transferred Leads'
                                              : 'Total Leads',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_totalLeads Leads',
                          style: const TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Add Leads / Bulk Transfer Button
                        InkWell(
                          onTap: () {
                            if (selectedIUsers.isNotEmpty) {
                              if (transferPermission == 'true') {
                                _transferLeads(context);
                              } else {
                                Common.toastMessaage(
                                    "No Permission for Transfer", Colors.red);
                              }
                            } else {
                              if (createLeadPermission == 'true') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddLeadsNew(widget.token),
                                  ),
                                ).then((_) =>
                                    getData(widget.token, fromDate, toDate));
                              } else {
                                _showPermissionDialog();
                              }
                            }
                          },
                          onLongPress: () {
                            if (selectedIUsers.isNotEmpty) {
                              _transferLeads(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedIUsers.isNotEmpty
                                  ? appBarStart.withOpacity(0.1)
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: selectedIUsers.isNotEmpty
                                      ? appBarStart.withOpacity(0.2)
                                      : Colors.green.shade100),
                            ),
                            child: Icon(
                                selectedIUsers.isNotEmpty
                                    ? Icons.compare_arrows_rounded
                                    : Icons.add_rounded,
                                color: selectedIUsers.isNotEmpty
                                    ? appBarStart
                                    : Colors.green,
                                size: 20),
                          ),
                        ),
                        //if (selectedIUsers.isNotEmpty) ...[
                        // const SizedBox(width: 8),
                        // // Selection Count
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 10, vertical: 8),
                        //   decoration: BoxDecoration(
                        //     color: appBarStart.withOpacity(0.1),
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   child: Text(
                        //     "${selectedIUsers.length}",
                        //     style: const TextStyle(
                        //       color: appBarStart,
                        //       fontWeight: FontWeight.bold,
                        //       fontSize: 13,
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(width: 8),
                        // // Clear Selection
                        // InkWell(
                        //   onTap: () {
                        //     setState(() {
                        //       selectedIUsers.clear();
                        //       selectedUserNumbers.clear();
                        //       for (var lead in listTabLeads) {
                        //         lead.isSelected = false;
                        //       }
                        //     });
                        //   },
                        //   child: Container(
                        //     padding: const EdgeInsets.all(8),
                        //     decoration: BoxDecoration(
                        //       color: Colors.grey.shade100,
                        //       borderRadius: BorderRadius.circular(10),
                        //       border: Border.all(color: Colors.grey.shade200),
                        //     ),
                        //     child: const Icon(Icons.close_rounded,
                        //         color: Colors.grey, size: 20),
                        //   ),
                        // ),
                        // ],
                        const SizedBox(width: 8),
                        // Minimize/Expand Toggle
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isCompactView = !_isCompactView;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isCompactView
                                  ? appBarStart.withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isCompactView
                                    ? appBarStart.withOpacity(0.2)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Icon(
                              _isCompactView
                                  ? Icons.view_agenda_rounded
                                  : Icons.view_headline_rounded,
                              color: _isCompactView ? appBarStart : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Filter Button (Same as viewLeadsNew.dart)
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ViewLeadsFilterWidget(
                                commonDetails: commonDetails,
                                productSectionModel: productSectionModel,
                                currentTab: _listTabFilter,
                                initialFilters: {
                                  'fromDate': fromDate,
                                  'toDate': toDate,
                                  'statusIds': _listTabSelectedStatusIds,
                                  'staffIds': _listTabSelectedStaffIds,
                                  'categoryIds': _listTabSelectedCategoryIds,
                                  'priorityIds': _listTabSelectedPriorityIds,
                                  'productIds': _listTabSelectedProductIds,
                                },
                                onApplyFilters: (filters) {
                                  setState(() {
                                    fromDate = filters['fromDate'];
                                    toDate = filters['toDate'];
                                    _listTabSelectedStatusIds =
                                        List<String>.from(filters['statusIds']);
                                    _listTabSelectedStaffIds =
                                        List<String>.from(filters['staffIds']);
                                    _listTabSelectedCategoryIds =
                                        List<String>.from(
                                            filters['categoryIds']);
                                    _listTabSelectedPriorityIds =
                                        List<String>.from(
                                            filters['priorityIds']);
                                    _listTabSelectedProductIds =
                                        List<String>.from(
                                            filters['productIds']);
                                    _isListTabFilterApplied = true;
                                  });
                                  getData(widget.token, fromDate, toDate);
                                  _fetchTabLeads();
                                },
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Icon(Icons.filter_alt_outlined,
                                color: Colors.grey, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Search Button (Redirect to Search)
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Search(
                                  token: widget.token!,
                                  editLead: updateLeadPermission1,
                                  deleteLead: deleteLeadPermission1,
                                  cloudCall: cloudCallPermission1,
                                  leadType: '',
                                ),
                              ),
                            ).then(
                                (_) => getData(widget.token, fromDate, toDate));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: appBarStart,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: appBarStart.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.search_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (listTabLeads.isEmpty && !_isListTabLoading)
                Column(
                  children: [
                    const SizedBox(height: 50),
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No leads found for this category',
                      style: TextStyle(color: textSecondary),
                    ),
                  ],
                )
              else
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listTabLeads.length,
                  itemBuilder: (context, index) {
                    final lead = listTabLeads[index];
                    return _buildLeadListItem(lead, index);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showLeadDetailsPopup(int index) async {
    if (index >= listTabLeads.length) return;

    final displayItem = listTabLeads[index];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: appBarStart,
              strokeWidth: 3,
            ),
          ),
        );
      },
    );

    try {
      final results = await Future.wait([
        HttpService.leadDetails(widget.token!, displayItem.callMasterId),
        HttpService.listAddonDet(widget.token!, displayItem.callMasterId),
        HttpService.listFolderAndFiles(
            widget.token!, displayItem.callMasterId, ''),
        HttpService.leadMileStone(widget.token!, displayItem.callMasterId),
        HttpService.leadFollowupData(widget.token!, displayItem.callMasterId),
        if (commonDetails == null) HttpService.addLeadCommonData(widget.token!),
      ]);

      if (!mounted) return;
      Navigator.pop(context);

      final leadDetails = results[0] as LeadDeatailsModel?;
      if (leadDetails == null) {
        Common.toastMessaage("Failed to load lead details", accentRed);
        return;
      }

      final leadDetailsAdditional = results[1] as LeadDeatailsModelAdd?;
      final listFolder = results[2] as ListFolderNameModel?;
      final mileStone = results[3] as LeadMileStoneListModel?;
      final leadDetailsFollowup = results[4] as af.LeadFollowupData?;
      if (commonDetails == null && results.length > 5) {
        commonDetails = results[5] as AddLeadCommonDataModel?;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => LeadDetailsPopup(
          token: widget.token!,
          editLead: updateLeadPermission1,
          deleteLead: deleteLeadPermission1,
          cloudCall: cloudCallPermission1,
          callMasterId: displayItem.callMasterId,
          leadDetails: leadDetails,
          leadDetailsAdditional: leadDetailsAdditional,
          listFolder: listFolder,
          mileStone: mileStone,
          leadDetailsFollowup: leadDetailsFollowup,
          commonDetails: commonDetails,
          pageName: 'Dashboard',
          onDataChanged: () {
            _fetchTabLeads();
          },
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      log("Error loading lead details: $e");
      Common.toastMessaage("Error loading details", accentRed);
    }
  }

  Future<dynamic> chooseCallDialog(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final item = listTabLeads[index];
        return AlertDialog(
          title: const Text('Choose Call Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                leading:
                    const Icon(Icons.cloud_circle_rounded, color: appBarStart),
                title: const Text('Cloud Call'),
                onTap: () async {
                  Common.showProgressDialog(context, "Loading..");
                  var object1 = await HttpService.addCloudCall(
                      widget.token, item.callMasterId, item.contactNumber1);
                  if (object1.data == true) {
                    if (context.mounted) {
                      Common.toastMessaage(object1.message, callGreen);
                      Navigator.pop(context); // popup
                      Navigator.pop(context); // dialog
                    }
                  } else {
                    Common.toastMessaage(object1.message, accentRed);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                dense: true,
                leading:
                    const Icon(Icons.phone_android_rounded, color: callGreen),
                title: const Text('Phone Call'),
                onTap: () async {
                  Navigator.pop(context);
                  Common.dialPad(item.contactNumber1);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showCallPermissionDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Permission Denied'),
        content: const Text('You do not have permission to make calls.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchTabLeads({
    String? status,
    String? leadType,
    String? callStatus,
    bool? isCalled,
    bool isLoadMore = false,
  }) async {
    if (isLoadMore) {
      if (_isListTabLoadingMore || !_hasMoreListTabLeads) return;
      setState(() {
        _isListTabLoadingMore = true;
      });
      _listTabPage++;
    } else {
      setState(() {
        _isListTabLoading = true;
        _listTabPage = 1;
        _hasMoreListTabLeads = true;
        if (status != null) _listTabCurrentStatus = status;
        if (leadType != null) _listTabCurrentLeadType = leadType;
        if (callStatus != null) _listTabCurrentCallStatus = callStatus;
        if (isCalled != null) _listTabCurrentIsCalled = isCalled;
      });
    }

    Map<String, dynamic> body = {
      "token": widget.token,
      "callResultId":
          _listTabCurrentStatus == "0" ? "" : (_listTabCurrentStatus ?? ""),
      "leadCategoryId": _listTabSelectedCategoryIds,
      "leadSubcategoryId": [],
      "callResponseId": _listTabSelectedStatusIds,
      "callStatus": _listTabCurrentCallStatus ?? "",
      "staffId":
          (_listTabSelectedStaffIds.isNotEmpty) ? _listTabSelectedStaffIds : "",
      "isCalled": _listTabCurrentIsCalled ?? true,
      "priority": _listTabSelectedPriorityIds,
      "productId": _listTabSelectedProductIds,
      "sort": "desc",
      "page": _listTabPage,
      "pageSize": 10,
      "isFirst": !isLoadMore,
      "leadType": _listTabCurrentLeadType ?? "",
    };

    bool shouldSendDates = _isListTabFilterApplied ||
        (_listTabCurrentLeadType == "-1" ||
            _listTabCurrentLeadType == "1" ||
            _listTabCurrentLeadType == "2" ||
            _listTabCurrentStatus == "4");
    body["filterStatus"] = shouldSendDates ? 1 : 0;
    body["fromDate"] =
        shouldSendDates ? DateFormat('yyyy-MM-dd').format(fromDate) : "";
    body["toDate"] =
        shouldSendDates ? DateFormat('yyyy-MM-dd').format(toDate) : "";

    try {
      final response = await HttpService.leadReport(body);
      if (response != null && response.data != null) {
        final newLeads = response.data.details;
        setState(() {
          if (isLoadMore) {
            listTabLeads.addAll(newLeads);
          } else {
            listTabLeads = newLeads;
          }
          _listTabCallPermission = response.data.callPermission ?? true;
          _totalLeads = response.data.totalLeads;
          _hasMoreListTabLeads = newLeads.length >= 10;
          _isListTabLoading = false;
          _isListTabLoadingMore = false;
        });
      } else {
        setState(() {
          if (!isLoadMore) {
            listTabLeads = [];
            _totalLeads = 0;
          }
          _hasMoreListTabLeads = false;
          _isListTabLoading = false;
          _isListTabLoadingMore = false;
        });
      }
    } catch (e) {
      log("Error fetching tab leads: $e");
      setState(() {
        if (!isLoadMore) listTabLeads = [];
        _isListTabLoading = false;
        _isListTabLoadingMore = false;
      });
    }
  }

  Widget _buildLeadListItem(Detail lead, int index) {
    bool isDetailed = _isCompactView
        ? _expandedLeadIds.contains(lead.callMasterId)
        : !_expandedLeadIds.contains(lead.callMasterId);
    if (!isDetailed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
                color: lead.isSelected ? appBarStart : borderLight,
                width: lead.isSelected ? 2 : 1),
          ),
          child: InkWell(
            onTap: () {
              if (selectedIUsers.isNotEmpty) {
                _handleLongPress(index);
              } else {
                _showLeadDetailsPopup(index);
              }
            },
            onLongPress: () => _handleLongPress(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 75,
                    color: lead.priority == '1'
                        ? Colors.grey.shade300
                        : lead.priority == '2'
                            ? callGreen
                            : lead.priority == '3'
                                ? accentRed
                                : lead.priority == '4'
                                    ? textSecondary
                                    : Colors.grey.shade300,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showLeadDetailsPopup(index),
                                  child: Text(
                                    lead.clientName.isEmpty ||
                                            lead.clientName == "null"
                                        ? "Unknown"
                                        : lead.clientName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: lead.isCustomer
                                          ? callGreen
                                          : textPrimary,
                                      decoration: lead.priority == '4'
                                          ? TextDecoration.lineThrough
                                          : null,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accentRed.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: accentRed.withOpacity(0.2)),
                                ),
                                child: Text(
                                  lead.leadCategory,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: accentRed,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              if (int.parse(lead.categoryCount) > 1)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: InkWell(
                                    onTap: () => _showCategoryPopup(lead),
                                    child: Container(
                                      height: 18,
                                      width: 18,
                                      decoration: const BoxDecoration(
                                        color: accentOrange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          lead.categoryCount,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    String id = lead.callMasterId;
                                    if (_expandedLeadIds.contains(id)) {
                                      _expandedLeadIds.remove(id);
                                    } else {
                                      _expandedLeadIds.add(id);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: backgroundLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.keyboard_arrow_down_rounded,
                                      color: textSecondary, size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: lead.callResultId >= 0 &&
                                          lead.callResultId < _colors.length
                                      ? _colors[lead.callResultId]
                                          .withOpacity(0.1)
                                      : accentOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: lead.callResultId >= 0 &&
                                                lead.callResultId <
                                                    _colors.length
                                            ? _colors[lead.callResultId]
                                            : accentOrange,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      lead.callResult,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: lead.callResultId >= 0 &&
                                                lead.callResultId <
                                                    _colors.length
                                            ? _colors[lead.callResultId]
                                            : accentOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _buildMiniActionButton(
                                    icon: Icons.call,
                                    color: callGreen,
                                    onTap: () {
                                      if (_listTabCallPermission == false) {
                                        _showCallPermissionDialog(index);
                                      } else {
                                        chooseCallDialog(context, index);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildMiniActionButton(
                                    icon: FontAwesomeIcons.whatsapp,
                                    color: const Color(0xFF25D366),
                                    onTap: () {
                                      if (lead.contactNumber1.isNotEmpty) {
                                        Common.openWhatsApp(
                                            lead.contactNumber1);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildMiniActionButton(
                                    icon: Icons.inventory_2_rounded,
                                    color: Colors.blue,
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            const ProductDetailsPopup(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } // This `}` closes the `if (_expandedLeadIds.contains(lead.callMasterId))` block.

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (selectedIUsers.isNotEmpty) {
            _handleLongPress(index);
          } else {
            _showLeadDetailsPopup(index);
          }
        },
        onLongPress: () => _handleLongPress(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
                color: lead.isSelected ? appBarStart : borderLight,
                width: lead.isSelected ? 2 : 1.5),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: borderLight, width: 1.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: lead.priority == '1'
                            ? Colors.grey
                            : lead.priority == '2'
                                ? callGreen
                                : lead.priority == '3'
                                    ? accentRed
                                    : lead.priority == '4'
                                        ? textSecondary
                                        : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lead.clientName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          decoration: lead.priority == '4'
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: accentRed,
                          color: lead.isCustomer ? callGreen : textPrimary,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        lead.leadCategory,
                        style: const TextStyle(
                          fontSize: 12,
                          color: accentRed,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (int.parse(lead.categoryCount) > 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: InkWell(
                          onTap: () => _showCategoryPopup(lead),
                          child: Container(
                            height: 18,
                            width: 18,
                            decoration: const BoxDecoration(
                              color: accentOrange,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                lead.categoryCount,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          String id = lead.callMasterId;
                          if (_expandedLeadIds.contains(id)) {
                            _expandedLeadIds.remove(id);
                          } else {
                            _expandedLeadIds.add(id);
                          }
                        });
                      },
                      child: Icon(Icons.keyboard_arrow_up_rounded,
                          color: textSecondary, size: 22),
                    ),
                  ],
                ),
              ),

              // Content section
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Date section at top
                    if (lead.callResultId == 1)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: backgroundLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Image.asset("assets/icons/calendar.png",
                                width: 14, color: appBarStart),
                            const SizedBox(width: 4),
                            const Text(
                              'Created: ',
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              lead.createdDate.isEmpty
                                  ? "--"
                                  : lead.createdDate,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: backgroundLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: borderLight.withOpacity(0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset("assets/icons/calendar.png",
                                        width: 14, color: appBarStart),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Called: ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        lead.isCalled == false
                                            ? '--'
                                            : (lead.calledDate.isEmpty
                                                ? "--"
                                                : lead.calledDate),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: backgroundLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: borderLight.withOpacity(0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset("assets/icons/calendar.png",
                                        width: 14, color: appBarStart),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Next: ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        lead.scheduledDate.isEmpty
                                            ? "--"
                                            : lead.scheduledDate,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.phone_rounded,
                                size: 16, color: primaryBlue.withOpacity(0.8)),
                            const SizedBox(width: 6),
                            Text(
                              lead.contactNumber1,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textPrimary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 16, color: primaryBlue.withOpacity(0.8)),
                            const SizedBox(width: 6),
                            Text(
                              lead.staffName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: textPrimary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: lead.callResultId >= 0 &&
                                    lead.callResultId < _colors.length
                                ? _colors[lead.callResultId].withOpacity(0.12)
                                : accentOrange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: lead.callResultId >= 0 &&
                                        lead.callResultId < _colors.length
                                    ? _colors[lead.callResultId]
                                        .withOpacity(0.3)
                                    : accentOrange.withOpacity(0.3)),
                          ),
                          child: Text(
                            lead.callResult,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: lead.callResultId >= 0 &&
                                      lead.callResultId < _colors.length
                                  ? _colors[lead.callResultId]
                                  : accentOrange,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            _buildMiniActionButton(
                              icon: Icons.call,
                              color: callGreen,
                              onTap: () {
                                if (_listTabCallPermission == false) {
                                  _showCallPermissionDialog(index);
                                } else {
                                  chooseCallDialog(context, index);
                                }
                              },
                            ),
                            const SizedBox(width: 10),
                            _buildMiniActionButton(
                              icon: FontAwesomeIcons.whatsapp,
                              color: const Color(0xFF25D366),
                              onTap: () {
                                if (lead.contactNumber1.isNotEmpty) {
                                  Common.openWhatsApp(lead.contactNumber1);
                                }
                              },
                            ),
                            const SizedBox(width: 10),
                            _buildMiniActionButton(
                              icon: Icons.inventory_2_rounded,
                              color: Colors.blue,
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      const ProductDetailsPopup(),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
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

  Future<void> _showCategoryPopup(Detail lead) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final leadDetails =
          await HttpService.leadDetails(widget.token!, lead.callMasterId);

      if (mounted) Navigator.pop(context);

      if (leadDetails != null && leadDetails.data?.leadCategories != null) {
        final categories = leadDetails.data!.leadCategories!;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (_, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Lead Categories",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: appBarStart,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: categories.length,
                        separatorBuilder: (context, _) =>
                            const Divider(color: borderLight, height: 8),
                        itemBuilder: (context, i) {
                          final category = categories[i];
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _fetchTabLeads();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: borderLight),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        category.isSelected == true
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        size: 18,
                                        color: category.isSelected == true
                                            ? callGreen
                                            : textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          category.leadCategory ?? "-",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (category.leadStatus ?? "") ==
                                                  "New"
                                              ? appBarStart.withOpacity(0.1)
                                              : (category.leadStatus ?? "") ==
                                                      "Follow Up"
                                                  ? accentOrange
                                                      .withOpacity(0.1)
                                                  : (category.leadStatus ??
                                                              "") ==
                                                          "Rejected"
                                                      ? accentRed
                                                          .withOpacity(0.1)
                                                      : accentOrange
                                                          .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          category.leadStatus ?? "-",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: (category.leadStatus ??
                                                        "") ==
                                                    "New"
                                                ? appBarStart
                                                : (category.leadStatus ?? "") ==
                                                        "Follow Up"
                                                    ? accentOrange
                                                    : (category.leadStatus ??
                                                                "") ==
                                                            "Rejected"
                                                        ? accentRed
                                                        : accentOrange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "👤 ${category.staffName ?? "-"}",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: textSecondary,
                                        ),
                                      ),
                                      Text(
                                        "📅 ${category.createdDate ?? "-"}",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (error) {
      if (mounted) Navigator.pop(context);
      Common.toastMessaage("Failed to load categories", accentRed);
    }
  }

  Widget _buildMiniActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildReportTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportSectionHeader(
              'Call Status Report', Icons.phone_callback_rounded),
          _buildCallStatusReport(),
          const SizedBox(height: 24),

          _buildReportSectionHeader(
              'Stage-wise Report', Icons.stacked_bar_chart_rounded),
          _buildStageWiseReport(),
          const SizedBox(height: 24),

          _buildReportSectionHeader('Lead Source Report', Icons.source_rounded),
          _buildLeadSourceReport(),
          const SizedBox(height: 24),

          _buildReportSectionHeader('Category Report', Icons.category_rounded),
          _buildCategoryReport(),
          const SizedBox(height: 40),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 4),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(16),
          //       gradient: LinearGradient(
          //         colors: [appBarStart, appBarStart.withOpacity(0.8)],
          //       ),
          //       boxShadow: [
          //         BoxShadow(
          //           color: appBarStart.withOpacity(0.3),
          //           blurRadius: 12,
          //           offset: const Offset(0, 6),
          //         ),
          //       ],
          //     ),
          //     child: ElevatedButton.icon(
          //       onPressed: () {
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => DetailedReportsPage(
          //               token: widget.token!,
          //               fromDate: fromDate,
          //               toDate: toDate,
          //               fromDate1: fromDate1.toString(),
          //               toDate1: toDate1,
          //               updateLeadPermission1: updateLeadPermission1,
          //               deleteLeadPermission1: deleteLeadPermission1,
          //               cloudCallPermission1: cloudCallPermission1,
          //               viewLeadPermission: viewLeadPermission,
          //             ),
          //           ),
          //         );
          //       },
          //       icon: const Icon(Icons.insert_chart_outlined_rounded,
          //           color: Colors.white),
          //       label: const Text(
          //         'View Full Detailed Reports',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //           fontSize: 15,
          //         ),
          //       ),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.transparent,
          //         shadowColor: Colors.transparent,
          //         minimumSize: const Size(double.infinity, 56),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(16),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildReportSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: appBarStart.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: appBarStart, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: appBarStart),
            onPressed: () => _openFilterForSection(title),
          ),
        ],
      ),
    );
  }

  void _openFilterForSection(String title) {
    DateTime initialFrom;
    DateTime initialTo;
    List<String> initialStaffs;

    if (title.contains('Call Status')) {
      initialFrom = callStatusFromDate ?? fromDate1;
      initialTo = callStatusToDate ?? toDate1;
      initialStaffs = callStatusStaffs;
    } else if (title.contains('Stage-wise')) {
      initialFrom = stageWiseFromDate ?? fromDate1;
      initialTo = stageWiseToDate ?? toDate1;
      initialStaffs = stageWiseStaffs;
    } else if (title.contains('Lead Source')) {
      initialFrom = leadSourceFromDate ?? fromDate1;
      initialTo = leadSourceToDate ?? toDate1;
      initialStaffs = leadSourceStaffs;
    } else {
      initialFrom = categoryFromDate ?? fromDate1;
      initialTo = categoryToDate ?? toDate1;
      initialStaffs = categoryStaffs;
    }

    _showReportFilterDialog(
      title: title,
      initialFromDate: initialFrom,
      initialToDate: initialTo,
      initialStaffIds: initialStaffs,
      onApply: (from, to, staffIds) async {
        if (title.contains('Call Status')) {
          setState(() {
            callStatusFromDate = from;
            callStatusToDate = to;
            callStatusStaffs = staffIds;
            isCallStatusLoading = true;
          });
          var data = await HttpService.leadProgressbar(
              widget.token,
              DateFormat('dd-MM-yyyy').format(from),
              DateFormat('dd-MM-yyyy').format(to),
              "",
              staffIds: staffIds);
          setState(() {
            callStatusData = data;
            isCallStatusLoading = false;
          });
        } else if (title.contains('Stage-wise')) {
          setState(() {
            stageWiseFromDate = from;
            stageWiseToDate = to;
            stageWiseStaffs = staffIds;
            isStageWiseLoading = true;
          });
          var data = await HttpService.leadDashboard1(
              widget.token, from, to, from.toString(), to.toString(),
              staffIds: staffIds);
          setState(() {
            stageWiseData = data;
            isStageWiseLoading = false;
          });
        } else if (title.contains('Lead Source')) {
          setState(() {
            leadSourceFromDate = from;
            leadSourceToDate = to;
            leadSourceStaffs = staffIds;
            // Fake loading since dummy data
          });
        } else {
          setState(() {
            categoryFromDate = from;
            categoryToDate = to;
            categoryStaffs = staffIds;
            isCategoryLoading = true;
          });
          var data = await HttpService.leadDashboard1(
              widget.token, from, to, from.toString(), to.toString(),
              staffIds: staffIds);
          setState(() {
            categoryData = data;
            isCategoryLoading = false;
          });
        }
      },
    );
  }

  void _showReportFilterDialog({
    required String title,
    required DateTime initialFromDate,
    required DateTime initialToDate,
    required List<String> initialStaffIds,
    required Function(DateTime from, DateTime to, List<String> staffIds)
        onApply,
  }) {
    DateTime tempFrom = initialFromDate;
    DateTime tempTo = initialToDate;
    List<String> tempStaffIds = List.from(initialStaffIds);
    final staffs = commonDetails?.data.staff ?? [];

    String selectedCategory = 'Date Range';
    final DateFormat _formatter = DateFormat('dd-MM-yyyy');
    TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          Widget buildCategoryItem(String categoryName, IconData icon) {
            final isSelected = selectedCategory == categoryName;
            final hasFilters =
                (categoryName == 'Date Range') ? true : tempStaffIds.isNotEmpty;

            return GestureDetector(
              onTap: () => setModalState(() => selectedCategory = categoryName),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  border: isSelected
                      ? const Border(
                          left: BorderSide(color: Colors.blue, width: 3))
                      : null,
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Icon(icon,
                            color: isSelected
                                ? Colors.blue
                                : const Color(0xFF8F9BB3),
                            size: 24),
                        if (hasFilters)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      categoryName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color:
                            isSelected ? Colors.blue : const Color(0xFF8F9BB3),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          Widget buildDateField(
              String label, DateTime? value, Function(DateTime) onSelect) {
            return InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: value ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) onSelect(picked);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE4E9F2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF8F9BB3))),
                        Text(
                            value != null
                                ? _formatter.format(value)
                                : 'Select Date',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const Icon(Icons.calendar_today,
                        size: 18, color: Colors.blue),
                  ],
                ),
              ),
            );
          }

          Widget buildQuickDateFilters({
            required VoidCallback onToday,
            required VoidCallback onThisMonth,
          }) {
            return Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onToday,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE3F2FD),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text(
                      "Today",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onThisMonth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE3F2FD),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text(
                      "This Month",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              ],
            );
          }

          Widget buildDateOptions() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Date Range',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 16),
                buildDateField('From Date', tempFrom,
                    (date) => setModalState(() => tempFrom = date)),
                const SizedBox(height: 12),
                buildDateField('To Date', tempTo,
                    (date) => setModalState(() => tempTo = date)),
                const SizedBox(height: 16),
                buildQuickDateFilters(
                  onToday: () {
                    final now = DateTime.now();
                    setModalState(() {
                      tempFrom = now;
                      tempTo = now;
                    });
                  },
                  onThisMonth: () {
                    final now = DateTime.now();
                    setModalState(() {
                      tempFrom = DateTime(now.year, now.month, 1);
                      tempTo = DateTime(now.year, now.month + 1, 0);
                    });
                  },
                ),
              ],
            );
          }

          Widget buildStaffOptions() {
            return Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search Staff...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE4E9F2)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: staffs.length,
                    itemBuilder: (context, index) {
                      final item = staffs[index];
                      final name = item.staffName;
                      final id = item.userId.toString();

                      if (searchController.text.isNotEmpty &&
                          !name
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase())) {
                        return const SizedBox.shrink();
                      }

                      final isSelected = tempStaffIds.contains(id);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) => setModalState(() {
                          if (isSelected) {
                            tempStaffIds.remove(id);
                          } else {
                            tempStaffIds.add(id);
                          }
                        }),
                        title: Text(name, style: const TextStyle(fontSize: 13)),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        visualDensity: VisualDensity.compact,
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return Container(
            margin: EdgeInsets.only(top: AppBar().preferredSize.height),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$title Filters',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3A59),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF2E3A59)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 350,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        decoration: const BoxDecoration(
                          border: Border(
                              right: BorderSide(color: Color(0xFFE4E9F2))),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              buildCategoryItem(
                                  'Date Range', Icons.calendar_today),
                              buildCategoryItem('Staff', Icons.people_outline),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: selectedCategory == 'Date Range'
                              ? buildDateOptions()
                              : buildStaffOptions(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              tempStaffIds.clear();
                              tempFrom = DateTime.now()
                                  .subtract(const Duration(days: 30));
                              tempTo = DateTime.now();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFFE4E9F2)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Clear All',
                              style: TextStyle(color: Color(0xFF2E3A59))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onApply(tempFrom, tempTo, tempStaffIds);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Apply Filters',
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
          );
        });
      },
    );
  }

  Widget _buildCallStatusReport() {
    if (isCallStatusLoading)
      return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()));
    var currentData = callStatusData ?? object1;
    var statusLeads = currentData?.data?.statusLeads ?? [];
    if (statusLeads.isEmpty) {
      statusLeads = [
        lp.StatusLeads(
            statusName: 'Connected', statusCount: '24', statusPercentage: '45'),
        lp.StatusLeads(
            statusName: 'Pending', statusCount: '15', statusPercentage: '28'),
        lp.StatusLeads(
            statusName: 'N/A', statusCount: '8', statusPercentage: '15'),
        lp.StatusLeads(
            statusName: 'Interested', statusCount: '6', statusPercentage: '12'),
      ];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: statusLeads.map((item) {
          int index = statusLeads.indexOf(item);
          final color = _colors[index % _colors.length];
          final percentageStr = item.statusPercentage?.toString() ?? '0';
          final percentage = (double.tryParse(percentageStr) ?? 0) / 100;

          return InkWell(
            onTap: () {
              final staffList = staffWise?.data?.staffLeads ?? [];
              final details = staffList.map((s) {
                String? count;
                if (item.statusName == 'Pending') {
                  count = s.pendingCount;
                } else if (item.statusName == 'Connected' ||
                    item.statusName == 'Confirmed') {
                  count = s.confirmedCount;
                } else if (item.statusName == 'New') {
                  count = s.newCount;
                } else {
                  count = s.staffCount;
                }
                return {
                  'name': s.staffName ?? 'Unknown',
                  'count': count ?? '0',
                };
              }).toList();
              _showReportDetailsDialog(
                  item.statusName ?? 'Report', details, color);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.statusName ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        item.statusCount ?? '0',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 1000),
                        height: 10,
                        width: (MediaQuery.of(context).size.width - 72) *
                            (percentage > 1 ? 1 : percentage),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 2. Stage-wise Report - Modern Circular Progress
  Widget _buildStageWiseReport() {
    if (isStageWiseLoading)
      return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()));
    var currentData = stageWiseData ?? staffWise;
    int locNew = 0, locFollowup = 0, locRejected = 0, locClosed = 0;
    for (int i = 0; i < (currentData?.data?.categoryLeads?.length ?? 0); i++) {
      locNew += int.tryParse(
              currentData!.data!.categoryLeads![i].newCount.toString()) ??
          0;
      locFollowup += int.tryParse(
              currentData.data!.categoryLeads![i].followupCount.toString()) ??
          0;
      locRejected += int.tryParse(
              currentData.data!.categoryLeads![i].rejectedCount.toString()) ??
          0;
      locClosed += int.tryParse(
              currentData.data!.categoryLeads![i].confirmedCount.toString()) ??
          0;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStageItem('New', locNew, Colors.blue, 0, currentData),
          _buildStageItem('Follow', locFollowup, Colors.orange, 1, currentData),
          _buildStageItem('Reject', locRejected, Colors.red, 2, currentData),
          _buildStageItem('Closed', locClosed, Colors.green, 3, currentData),
        ],
      ),
    );
  }

  Widget _buildStageItem(String title, int count, Color color, int index,
      LeadCategoryStaffWiseModel? currentData) {
    return InkWell(
      onTap: () {
        final staffList = currentData?.data?.staffLeads ?? [];
        final details = staffList.map((s) {
          String? staffCount;
          if (title == 'New') staffCount = s.newCount;
          if (title == 'Follow') staffCount = s.followupCount;
          if (title == 'Reject') staffCount = s.rejectedCount;
          if (title == 'Closed') staffCount = s.confirmedCount;

          return {
            'name': s.staffName ?? 'Unknown',
            'count': staffCount ?? '0',
          };
        }).toList();
        _showReportDetailsDialog('$title Stage', details, color);
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: (count / 100).clamp(0.1, 1.0),
                  strokeWidth: 6,
                  color: color,
                  backgroundColor: color.withOpacity(0.1),
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Lead Source Report - Neon Dark Style
  Widget _buildLeadSourceReport() {
    final sources = [
      {'name': 'Google Ads', 'count': 145, 'color': Colors.cyanAccent},
      {'name': 'Facebook', 'count': 98, 'color': Colors.blueAccent},
      {'name': 'WhatsApp', 'count': 167, 'color': Colors.greenAccent},
      {'name': 'Referral', 'count': 42, 'color': Colors.amberAccent},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: sources.map((source) {
          final color = source['color'] as Color;
          final count = source['count'] as int;
          final percent = (count / 200).clamp(0.0, 1.0);

          return InkWell(
            onTap: () {
              final staffList = staffWise?.data?.staffLeads ?? [];
              final details = staffList.map((s) {
                return {
                  'name': s.staffName ?? 'Unknown',
                  'count': s.staffCount ?? '0',
                };
              }).toList();
              _showReportDetailsDialog(
                  source['name'] as String, details, color);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        source['name'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        count.toString(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                                color: color.withOpacity(0.5), blurRadius: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryReport() {
    if (isCategoryLoading)
      return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()));
    var currentData = categoryData ?? staffWise;
    final catLeads = currentData?.data?.categoryLeads ?? [];
    if (catLeads.isEmpty) return _buildEmptyReport();

    return Column(
      children: catLeads.take(5).map((cat) {
        final count = int.tryParse(cat.categoryCount ?? '0') ?? 0;
        final percent = (count / 500).clamp(0.0, 1.0);

        return InkWell(
          onTap: () {
            final staffList = currentData?.data?.staffLeads ?? [];
            final details = staffList.map((s) {
              return {
                'name': s.staffName ?? 'Unknown',
                'count': s.staffCount ?? '0',
              };
            }).toList();
            _showReportDetailsDialog(
                cat.categoryName ?? 'Category', details, appBarStart);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appBarStart.withOpacity(0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: appBarStart.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appBarStart.withOpacity(0.1),
                        appBarStart.withOpacity(0.05)
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      cat.categoryName?.substring(0, 1).toUpperCase() ?? 'C',
                      style: TextStyle(
                        color: appBarStart,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cat.categoryName ?? 'Category',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            cat.categoryCount ?? '0',
                            style: TextStyle(
                              color: appBarStart,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(appBarStart),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showReportDetailsDialog(
    String title,
    List<Map<String, dynamic>> details,
    Color primaryColor,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (details.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: Text(
                      "No data found",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: details.length,
                      itemBuilder: (context, index) {
                        final item = details[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        primaryColor.withOpacity(0.1),
                                    child: Text(
                                      item['name'][0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item['count'].toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyReport() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, color: Colors.grey.shade300, size: 48),
          const SizedBox(height: 12),
          const Text(
            'No report data available',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, size: 14, color: primaryBlue),
                    const SizedBox(width: 4),
                    Text(
                      'Period',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionChip(
                icon: Icons.person_add_rounded,
                label: 'Add Lead',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  if (createLeadPermission == 'true') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddLeadsNew(widget.token),
                      ),
                    ).then((_) => getData(widget.token, fromDate, toDate));
                  } else {
                    _showPermissionDialog();
                  }
                },
              ),
              const SizedBox(width: 12),
              _buildActionChip(
                icon: Icons.search_rounded,
                label: 'Search',
                color: primaryBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Search(
                        token: widget.token!,
                        editLead: updateLeadPermission1,
                        deleteLead: deleteLeadPermission1,
                        cloudCall: cloudCallPermission1,
                        leadType: '',
                      ),
                    ),
                  ).then((_) => getData(widget.token, fromDate, toDate));
                },
              ),
              const SizedBox(width: 12),
              _buildActionChip(
                icon: Icons.history_rounded,
                label: 'Call History',
                color: const Color(0xFFFF9800),
                onTap: () {
                  if (accessCallHistoryPermission == 'true') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CallHistoryPage(
                          widget.token!,
                          name,
                          userId,
                          accessCallRecordingPermission1,
                        ),
                      ),
                    );
                  } else {
                    _showPermissionDialog();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                _buildCompactDateChip(
                  label: DateFormat('dd MMM').format(fromDate),
                  onTap: () => _showDatePicker(isFrom: true),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 14, color: Colors.grey.shade400),
                ),
                _buildCompactDateChip(
                  label: DateFormat('dd MMM').format(toDate),
                  onTap: () => _showDatePicker(isFrom: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDateChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: primaryBlue),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStaffSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredStaff = staffList
                .where((s) =>
                    s.name.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Select Staff",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search staff...",
                          hintStyle:
                              TextStyle(color: Colors.grey[500], fontSize: 15),
                          prefixIcon:
                              Icon(Icons.search, color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredStaff.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildStaffItem(
                            context,
                            id: null,
                            name: "All Staff",
                            isSelected: targetStaffId == null,
                            onTap: () {
                              setState(() {
                                targetStaffId = null;
                              });
                              getData(widget.token, fromDate, toDate);
                              Navigator.pop(context);
                            },
                          );
                        }
                        final staff = filteredStaff[index - 1];
                        return _buildStaffItem(
                          context,
                          id: staff.userIdStaff.toString(),
                          name: staff.name,
                          isSelected:
                              targetStaffId == staff.userIdStaff.toString(),
                          onTap: () {
                            setState(() {
                              targetStaffId = staff.userIdStaff.toString();
                            });
                            getData(widget.token, fromDate, toDate);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStaffItem(BuildContext context,
      {required String? id,
      required String name,
      required bool isSelected,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected ? appBarStart.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? appBarStart.withOpacity(0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [appBarStart, appBarStart.withOpacity(0.7)]
                        : [Colors.grey[300]!, Colors.grey[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? appBarStart : Colors.grey[800],
                      ),
                    ),
                    if (isSelected)
                      Text(
                        "Current Selection",
                        style: TextStyle(
                          fontSize: 11,
                          color: appBarStart.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: appBarStart, size: 24)
              else
                Icon(Icons.circle_outlined, color: Colors.grey[300], size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker({required bool isFrom}) async {
    final DateTime initial = isFrom ? fromDate : toDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
      getData(widget.token, fromDate, toDate);
    }
  }

  void _handleModuleNavigation(String? menuName) {
    if (menuName == null) return;

    if (menuName == 'call_management') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardLeadNewUpdated(widget.token),
        ),
      );
    } else if (menuName == 'Staff_management') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewUsers(widget.token),
        ),
      );
    } else if (menuName == 'Service') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(),
        ),
      );
    } else if (menuName == 'whatsapp') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatHomeScreen(),
        ),
      );
    } else if (menuName == 'room_management') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RoomDashboard(),
        ),
      );
    } else if (menuName == 'Settings') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WhatsappSettings(widget.token),
        ),
      );
    } else if (menuName == 'file_manager') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileMangerList(widget.token),
        ),
      );
    } else if (menuName == 'customers') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientList(widget.token!, _scaffoldKey),
        ),
      );
    } else if (menuName == 'invoices') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AccountsDashboard(
            token: widget.token.toString(),
          ),
        ),
      ).then((_) {
        getData(widget.token, fromDate, toDate);
        if (loadmore) getStaffwise();
      });
    } else if (menuName == 'quotation') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuotationDashboard(),
        ),
      ).then((_) {
        getData(widget.token, fromDate, toDate);
        if (loadmore) getStaffwise();
      });
    } else if (menuName == 'reports') {
      _showReportsDialog();
    } else if (menuName == 'renewal') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RenewalDashboard(),
        ),
      );
    } else if (menuName == 'Work') {
      if (adminCheckPermission == "true") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ViewCompanyWorkPage(),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ViewWorkPage(staffId: ''),
            settings: RouteSettings(arguments: {"staffId": staffId}),
          ),
        );
      }
    } else if (menuName == 'complaints') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ComplaintListScreen(),
        ),
      );
    } else if (menuName == 'products') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductList(
            catId: "widget.catId",
            subCatId: "11",
            title: "",
            subCat: " widget.title",
          ),
        ),
      );
    } else {
      _showComingSoonDialog(menuName);
    }
  }

  void _showReportsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description, color: Color(0xFF2a86c9)),
              title: const Text('Lead Report'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllReport(
                      widget.token!,
                      true,
                      true,
                      true,
                      pageName: 'AllLeads',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Color(0xFF2a86c9)),
              title: const Text('Transfer Report'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransferLeadReport(
                      widget.token!,
                      true,
                      true,
                      true,
                      pageName: 'transferLeads',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF2a86c9)),
              title: const Text('Staff Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StaffReportDashboard(
                      id: userId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(feature),
        content: const Text('This feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _navigateToAppropriateDashboard,
      backgroundColor: primaryBlue,
      child: Image.asset(
        "assets/icons/menu.png",
        width: 24,
        color: Colors.white,
      ),
    );
  }

  void _navigateToAppropriateDashboard() {
    if (ProjectDashboardPermission == "true") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProjectDashboard()),
      );
    } else if (AccountsDashboardPermission == "true") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AccountsDashboard(token: widget.token!),
        ),
      );
    } else if (MenuDashboard == "true") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(widget.token)),
      );
    } else if (RenewalDashboardPermission == "true") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RenewalDashboard()),
      );
    } else if (NewleadDashboardPermission == "true") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MinimalDashboard(widget.token),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardLeadNewUpdated(widget.token),
        ),
      );
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/no_network.json',
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            'Connection Error',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timeOut
                ? 'Temporary issue. Please try again.'
                : 'No internet connection',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => getData(widget.token, fromDate, toDate),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
            5,
            (index) => Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                )),
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Access Denied'),
        content: const Text(
          'You do not have permission to access this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRowSection(ld.Data data) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildListSummaryItem(
              'New',
              dashboardMainCounts != null
                  ? (dashboardMainCounts?.data.leads.newLeads ?? 0).toString()
                  : data.newLeads.toString(),
              Icons.person_add_rounded,
              const Color(0xFF2a86c9),
              '1',
              isCalled: true,
            ),
            _buildSeparator(),
            _buildListSummaryItem(
              'Followup',
              dashboardMainCounts != null
                  ? (dashboardMainCounts?.data.leads.followupLeads ?? 0)
                      .toString()
                  : data.followupLeads.toString(),
              Icons.schedule_rounded,
              Colors.orange,
              '2',
              isCalled: false,
            ),
            _buildSeparator(),
            _buildListSummaryItem(
              'Missed',
              dashboardMainCounts != null
                  ? (dashboardMainCounts?.data.leads.missedLeads ?? 0)
                      .toString()
                  : data.missedLeads.toString(),
              Icons.event_busy_rounded,
              const Color(0xFFF44336),
              '0',
              leadType: '1',
              callStatus: '-1',
              isCalled: true,
              graphId: '-3',
            ),
            _buildSeparator(),
            _buildListSummaryItem(
              'Called',
              dashboardMainCounts != null
                  ? (dashboardMainCounts?.data.leads.calledCount ?? 0)
                      .toString()
                  : data.totalCalled.toString(),
              Icons.phone_in_talk_rounded,
              Colors.purple,
              '0',
              leadType: '-1',
              callStatus: '1',
              isCalled: true,
              graphId: '-1',
            ),
            _buildSeparator(),
            _buildListSummaryItem(
              'Transferred',
              dashboardMainCounts != null
                  ? (dashboardMainCounts?.data.leads.transferLeads ?? 0)
                      .toString()
                  : data.transferLeads.toString(),
              Icons.swap_horiz_rounded,
              Colors.teal,
              '0',
              leadType: '2',
              callStatus: '-2',
              isCalled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      height: 16,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildListSummaryItem(
    String label,
    String count,
    IconData icon,
    Color color,
    String status, {
    String? leadType,
    String? callStatus,
    bool? isCalled,
    String? graphId,
  }) {
    bool isSelected = _listTabFilter == label;

    return Container(
      width: 72,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: () {
              bool labelChanged = _listTabFilter != label;
              setState(() {
                _listTabFilter = label;
                if (labelChanged) {
                  _listTabSelectedStatusIds.clear();
                  _listTabSelectedStaffIds.clear();
                  _listTabSelectedCategoryIds.clear();
                  _listTabSelectedPriorityIds.clear();
                  _isListTabFilterApplied = false;
                }
              });
              _fetchTabLeads(
                status: status,
                leadType: leadType ?? "",
                callStatus: callStatus ?? "",
                isCalled: isCalled,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              padding: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.12) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color.withOpacity(0.4) : borderLight,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 12,
                        color: isSelected ? color : textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          count,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? color : textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () async {
                Common.showProgressDialog(context, "Loading Analytics..");
                Common.saveSharedPref("statusWise", 'no');
                String effectiveGraphStatus = graphId ??
                    ((status == '0' && callStatus != null)
                        ? callStatus!
                        : status);
                await getLeadProgressbar(
                    widget.token!, fromDate, toDate, effectiveGraphStatus);
                if (object1!.status == true) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    leadProgressbarDialog(
                      context,
                      label,
                      "$label Insights",
                      status,
                      leadType ?? "",
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Object?> leadProgressBarStaffDialog(
      BuildContext context, String title, String status) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.people_alt_rounded,
                        color: primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Staff-wise distribution",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.groups_rounded,
                              size: 100,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Count",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    staffProgressData?.data?.staffTotal
                                            ?.toString() ??
                                        "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Leads",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (staffProgressData?.data?.staffLeads?.isNotEmpty ??
                        false) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Staff Performance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${staffProgressData!.data!.staffLeads!.length} Staffs',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: staffProgressData!.data!.staffLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final staff = staffProgressData!.data!.staffLeads![i];
                          double total = double.tryParse(staffProgressData
                                      ?.data?.staffTotal
                                      ?.toString() ??
                                  "0") ??
                              0;
                          double count =
                              double.tryParse(staff.staffCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewLeadsNew(
                                          widget.token,
                                          updateLeadPermission1,
                                          deleteLeadPermission1,
                                          cloudCallPermission1,
                                          pageName: title,
                                          fromDate: fromDate.toString(),
                                          toDate: toDate.toString(),
                                          status: status,
                                          staffName: staff.staffName,
                                          staff: staff.staffId)),
                                ).then((r) =>
                                    getData(widget.token, fromDate, toDate));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1)
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (staff.staffName?.isNotEmpty ==
                                                      true)
                                                  ? staff.staffName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                staff.staffName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Contribution Progress",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              staff.staffCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Object?> leadProgressBarCategoryDialog(
      BuildContext context, String title, String status) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.category_rounded,
                        color: primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Category-wise distribution",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.pie_chart_rounded,
                              size: 100,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Count",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    categoryProgressData?.data?.categoryTotal
                                            ?.toString() ??
                                        "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Leads",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (categoryProgressData?.data?.categoryLeads?.isNotEmpty ??
                        false) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Category Distribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${categoryProgressData!.data!.categoryLeads!.length} Categories',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount:
                            categoryProgressData!.data!.categoryLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final cat =
                              categoryProgressData!.data!.categoryLeads![i];
                          double total = double.tryParse(categoryProgressData
                                      ?.data?.categoryTotal
                                      ?.toString() ??
                                  "0") ??
                              0;
                          double count =
                              double.tryParse(cat.categoryCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewLeadsNew(
                                          widget.token,
                                          updateLeadPermission1,
                                          deleteLeadPermission1,
                                          cloudCallPermission1,
                                          pageName: title,
                                          fromDate: fromDate.toString(),
                                          toDate: toDate.toString(),
                                          status: status,
                                          categoryName: cat.categoryName,
                                          category: cat.categoryId)),
                                ).then((r) =>
                                    getData(widget.token, fromDate, toDate));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1)
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (cat.categoryName?.isNotEmpty ==
                                                      true)
                                                  ? cat.categoryName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cat.categoryName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Category Performance",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              cat.categoryCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Object?> leadProgressBarStatusDialog(
      BuildContext context, String title, String status) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.assignment_rounded,
                        color: primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Stage-wise distribution",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.analytics_rounded,
                              size: 100,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Count",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    statusProgressData?.data?.statusTotal
                                            ?.toString() ??
                                        "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Leads",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (statusProgressData?.data?.statusLeads?.isNotEmpty ??
                        false) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Stage Performance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${statusProgressData!.data!.statusLeads!.length} Stages',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount:
                            statusProgressData!.data!.statusLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final st = statusProgressData!.data!.statusLeads![i];
                          double total = double.tryParse(statusProgressData
                                      ?.data?.statusTotal
                                      ?.toString() ??
                                  "0") ??
                              0;
                          double count =
                              double.tryParse(st.statusCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewLeadsNew(
                                          widget.token,
                                          updateLeadPermission1,
                                          deleteLeadPermission1,
                                          cloudCallPermission1,
                                          pageName: title,
                                          fromDate: fromDate.toString(),
                                          toDate: toDate.toString(),
                                          status: status,
                                          callResName: st.statusName,
                                          callResId: st.statusId)),
                                ).then((r) =>
                                    getData(widget.token, fromDate, toDate));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1)
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (st.statusName?.isNotEmpty ==
                                                      true)
                                                  ? st.statusName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                st.statusName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Stage Progression",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              st.statusCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Object?> leadProgressbarDialog(BuildContext context, String label,
      String title, String status, String type) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.analytics_rounded,
                        color: primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Detailed analytics and distribution",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.trending_up_rounded,
                              size: 100,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Generated ${label}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    object1?.data?.totalCount?.toString() ??
                                        "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Leads",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (object1?.data?.staffLeads?.isNotEmpty ?? false) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Staff Contribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${object1!.data!.staffLeads!.length} Agents',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: object1!.data!.staffLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final staff = object1!.data!.staffLeads![i];
                          double total = double.tryParse(
                                  object1?.data?.totalCount?.toString() ??
                                      "0") ??
                              0;
                          double count =
                              double.tryParse(staff.staffCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewLeadsNew(
                                          widget.token,
                                          updateLeadPermission1,
                                          deleteLeadPermission1,
                                          cloudCallPermission1,
                                          pageName: title,
                                          fromDate: fromDate.toString(),
                                          toDate: toDate.toString(),
                                          status: status,
                                          leadType: type,
                                          staffName: staff.staffName,
                                          staff: staff.staffId)),
                                ).then((r) =>
                                    getData(widget.token, fromDate, toDate));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1)
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (staff.staffName?.isNotEmpty ==
                                                      true)
                                                  ? staff.staffName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                staff.staffName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Active Performance",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              staff.staffCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (object1?.data?.categoryLeads?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Category Distribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${object1!.data!.categoryLeads!.length} Categories',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: object1!.data!.categoryLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final cat = object1!.data!.categoryLeads![i];
                          double total = double.tryParse(
                                  object1?.data?.totalCount?.toString() ??
                                      "0") ??
                              0;
                          double count =
                              double.tryParse(cat.categoryCount ?? "0") ?? 0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i + 3); // Offset color
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewLeadsNew(
                                          widget.token,
                                          updateLeadPermission1,
                                          deleteLeadPermission1,
                                          cloudCallPermission1,
                                          pageName: title,
                                          fromDate: fromDate.toString(),
                                          toDate: toDate.toString(),
                                          status: status,
                                          leadType: type,
                                          categoryName: cat.categoryName,
                                          category: cat.categoryId)),
                                ).then((r) =>
                                    getData(widget.token, fromDate, toDate));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1)
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (cat.categoryName?.isNotEmpty ==
                                                      true)
                                                  ? cat.categoryName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cat.categoryName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Category Performance",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              cat.categoryCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (object1?.data?.missedLeads?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Missed Leads Distribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${object1!.data!.missedLeads!.length} Staffs',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: object1!.data!.missedLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final missed = object1!.data!.missedLeads![i];
                          double total = double.tryParse(
                                  object1?.data?.totalCount?.toString() ??
                                      "0") ??
                              0;
                          double count =
                              double.tryParse(missed.missedstaffCount ?? "0") ??
                                  0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i + 5); // Offset color
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewLeadsNew(
                                          widget.token,
                                          updateLeadPermission1,
                                          deleteLeadPermission1,
                                          cloudCallPermission1,
                                          pageName: title,
                                          fromDate: fromDate.toString(),
                                          toDate: toDate.toString(),
                                          status: status,
                                          leadType: type,
                                          staffName: missed.missedstaffName,
                                          staff: missed.missedstaffId)),
                                ).then((r) =>
                                    getData(widget.token, fromDate, toDate));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1)
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (missed.missedstaffName
                                                          ?.isNotEmpty ==
                                                      true)
                                                  ? missed.missedstaffName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                missed.missedstaffName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Staff Missed Leads",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              missed.missedstaffCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (object1?.data?.statusLeads?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status Distribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${object1!.data!.statusLeads!.length} Stages',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: object1!.data!.statusLeads!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          final statusLead = object1!.data!.statusLeads![i];
                          double total = double.tryParse(
                                  object1?.data?.totalCount?.toString() ??
                                      "0") ??
                              0;
                          double count =
                              double.tryParse(statusLead.statusCount ?? "0") ??
                                  0;
                          final double percentage =
                              total > 0 ? count / total : 0;
                          final color = _getStaffColor(i + 7); // Offset color
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewLeadsNew(
                                          widget.token,
                                          updateLeadPermission1,
                                          deleteLeadPermission1,
                                          cloudCallPermission1,
                                          pageName: title,
                                          fromDate: fromDate.toString(),
                                          toDate: toDate.toString(),
                                          status: statusLead.statusId,
                                          leadType: type)),
                                ).then((r) =>
                                    getData(widget.token, fromDate, toDate));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
                                                color.withOpacity(0.1)
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (statusLead.statusName
                                                          ?.isNotEmpty ==
                                                      true)
                                                  ? statusLead.statusName![0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                statusLead.statusName ?? "N/A",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Status Progress",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              statusLead.statusCount ?? "0",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              "Leads",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      animation: true,
                                      lineHeight: 8.0,
                                      animationDuration: 1200,
                                      percent: percentage.clamp(0.0, 1.0),
                                      barRadius: const Radius.circular(4),
                                      progressColor: color,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      trailing: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12),
                                        child: Text(
                                          "${(percentage * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStaffColor(int index) {
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
    ];
    return colors[index % colors.length];
  }

  Widget _buildListShimmer() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: 75,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTargetCalendar() {
    return GestureDetector(
      onTap: () => _showTargetDateRangePicker(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: appBarStart.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_outlined, color: appBarStart, size: 16),
            //const SizedBox(width: 6),
            // Text(
            //   "${DateFormat('dd/MM').format(targetFromDate)} -> ${DateFormat('dd/MM').format(targetToDate)}",
            //   style: TextStyle(
            //     fontSize: 12,
            //     fontWeight: FontWeight.w600,
            //     color: appBarStart,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTargetDateRangePicker() async {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Select Target Period"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.calendar_today, color: appBarStart),
                title: const Text("From Date"),
                subtitle: Text(DateFormat('dd-MM-yyyy').format(targetFromDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: targetFromDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() => targetFromDate = picked);
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.event, color: appBarStart),
                title: const Text("To Date"),
                subtitle: Text(DateFormat('dd-MM-yyyy').format(targetToDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: targetToDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() => targetToDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appBarStart,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
                _refreshTargetCounts();
              },
              child: const Text("Apply", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshTargetCounts() async {
    setState(() => isDashboardCountsLoading = true);
    try {
      final fDate = DateFormat('dd-MM-yyyy').format(fromDate);
      final tDate = DateFormat('dd-MM-yyyy').format(toDate);
      final targetFDate = DateFormat('dd-MM-yyyy').format(targetFromDate);
      final targetTDate = DateFormat('dd-MM-yyyy').format(targetToDate);
      final countsData = await HttpService.dashboardLeadsCounts(
          fromDate: fDate,
          toDate: tDate,
          userId: targetStaffId ?? userId,
          targetFromDate: targetFDate,
          targetToDate: targetTDate);

      if (countsData != null && countsData.status == true) {
        setState(() {
          dashboardCounts = countsData;
        });
      }
    } catch (e) {
      log("Error fetching dashboard counts: $e");
    } finally {
      setState(() => isDashboardCountsLoading = false);
    }
  }

  void _handleLongPress(int index) {
    setState(() {
      final lead = listTabLeads[index];
      lead.isSelected = !lead.isSelected;
      if (lead.isSelected) {
        selectedIUsers.add(lead.callMasterId);
        selectedUserNumbers.add(lead.contactNumber1);
      } else {
        selectedIUsers.remove(lead.callMasterId);
        selectedUserNumbers.remove(lead.contactNumber1);
      }
    });
  }

  void _nuclearReset() {
    setState(() {
      selectedIUsers.clear();
      selectedUserNumbers.clear();
      transferStaffToggleName = "Staff";
      transferStaffToggleId = "";
      for (var item in listTabLeads) {
        item.isSelected = false;
      }
    });
    _fetchTabLeads();
  }

  Future<dynamic> _transferLeads(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Transfer'),
              content: FormField<String>(
                builder: (FormFieldState<String> state) {
                  return Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                        border: Border.all(color: borderLight),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4)),
                    child: GestureDetector(
                      onTap: () {
                        _collectedStaffDialog(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                transferStaffToggleName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: textSecondary,
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No')),
                TextButton(
                  onPressed: () async {
                    if (transferStaffToggleId.isEmpty) {
                      Common.toastMessaage("Please select a staff", accentRed);
                      return;
                    }

                    Common.showProgressDialog(context, "Transferring leads...");

                    try {
                      Map<String, dynamic> body = {
                        "token": widget.token,
                        'leadMasterIds': selectedIUsers,
                        'staffId': transferStaffToggleId
                      };

                      BulkTransferLeadModel bulkTransfer =
                          await HttpService.bulkTransferLead(body);

                      if (bulkTransfer.status == true) {
                        Common.toastMessaage(bulkTransfer.message, callGreen);

                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          _nuclearReset();
                        }
                      } else {
                        Common.toastMessaage(bulkTransfer.message, accentRed);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        Common.toastMessaage("Transfer failed: $e", accentRed);
                      }
                    }
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<dynamic> _collectedStaffDialog(BuildContext context) {
    if (commonDetails == null) return Future.value();
    filteredTransferStaff = List.from(commonDetails!.data.transferStaffs);

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autocorrect: false,
                      autofocus: true,
                      onChanged: (value) {
                        setState(() {
                          filteredTransferStaff = commonDetails!
                              .data.transferStaffs
                              .where((item) => item.tranStaffName
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(8),
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .3,
                    width: MediaQuery.of(context).size.width * .7,
                    child: ListView.builder(
                      itemCount: filteredTransferStaff.length,
                      physics: const ScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          dense: true,
                          onTap: () {
                            transferStaffToggleName =
                                filteredTransferStaff[index].tranStaffName;
                            transferStaffToggleId =
                                filteredTransferStaff[index].tranStaffId;
                            filteredTransferStaff.clear();
                            filteredTransferStaff
                                .addAll(commonDetails!.data.transferStaffs);
                            this.setState(() {});
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(
                              filteredTransferStaff[index].tranStaffName,
                              style: const TextStyle(fontSize: 13)),
                        );
                      },
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      filteredTransferStaff.clear();
                      filteredTransferStaff
                          .addAll(commonDetails!.data.transferStaffs);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Close")),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showGlobalDateRangePickerDialog() async {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Select Period"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.calendar_today, color: appBarStart),
                title: const Text("From Date"),
                subtitle: Text(DateFormat('dd-MM-yyyy').format(fromDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: fromDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() => fromDate = picked);
                    setState(() {});
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.calendar_today, color: appBarStart),
                title: const Text("To Date"),
                subtitle: Text(DateFormat('dd-MM-yyyy').format(toDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: toDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() => toDate = picked);
                    setState(() {});
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appBarStart,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                getData(widget.token, fromDate, toDate);
              },
              child: const Text("Apply", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStaffIconTap(String status, String pageName) async {
    Common.showProgressDialog(context, "Loading Staff Analytics..");
    await getLeadProgressBarStaffData(
      leadStatus: status,
      selectedType: "1",
    );
    if (staffProgressData?.status == true) {
      if (context.mounted) {
        Navigator.pop(context);
        leadProgressBarStaffDialog(context, "$pageName", status);
      }
    } else {
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _handleCategoryIconTap(String status, String pageName) async {
    Common.showProgressDialog(context, "Loading Category Analytics..");
    await getLeadProgressBarCategoryData(
      leadStatus: status,
    );
    if (categoryProgressData?.status == true) {
      if (context.mounted) {
        Navigator.pop(context);
        leadProgressBarCategoryDialog(context, "$pageName", status);
      }
    } else {
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _handleStageIconTap(String status, String pageName) async {
    Common.showProgressDialog(context, "Loading Stage Analytics..");
    await getLeadProgressBarStatusData(
      leadStatus: status,
    );
    if (statusProgressData?.status == true) {
      if (context.mounted) {
        Navigator.pop(context);
        leadProgressBarStatusDialog(context, "$pageName", status);
      }
    } else {
      if (context.mounted) Navigator.pop(context);
    }
  }

  Widget _buildBoxIcons(String boxType, String status, String pageName) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBoxActionIcon(
            icon: Icons.people_outline,
            onTap: () => _handleStaffIconTap(status, pageName),
          ),
          _buildBoxActionIcon(
            icon: Icons.category_outlined,
            onTap: () => _handleCategoryIconTap(status, pageName),
          ),
          if (boxType == 'Active')
            _buildBoxActionIcon(
              icon: Icons.assignment_outlined,
              onTap: () => _handleStageIconTap(status, pageName),
            ),
        ],
      ),
    );
  }

  Widget _buildBoxActionIcon(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
