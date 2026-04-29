import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/account_dashboard.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/screens/accounts/clients/clientList.dart';
import 'package:login2/screens/complaints/complaint_list_screen.dart';
import 'package:login2/screens/fileManager/fileManagerList.dart';
import 'package:login2/screens/leadManagement/allReport.dart';
import 'package:login2/screens/leadManagement/quotationDashboard.dart';
import 'package:login2/screens/leadManagement/transferLeadReport.dart';
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
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Core imports
import '../../core/common.dart';
import '../../service/service.dart';

// Model imports
import '../../models/commonConfigureModel.dart';
import '../../models/dashboardModel.dart';
import '../../models/lead_management/leadDashboardModel.dart';
import '../../models/lead_management/leadProgressbarModel.dart';
import '../../models/lead_management/leadCategoryStaffWiseModel.dart';
import '../../models/lead_management/projectList_model.dart';
import '../../models/lead_management/workstatus_model.dart';
import '../../models/loginCheckModel.dart';
import '../../models/renewal/renewal_dashboard_model.dart';
import '../../models/clients/customerListModel.dart';

// Screen imports
import '../authentication/login.dart';
import '../authentication/deep_link_handler.dart';
import '../bottom_navigation_bar.dart';
import '../homePage.dart';
import '../search/search.dart';
import '../leadManagement/notification_page.dart';

// Lead Management Screens
import '../leadManagement/add_leads.dart';
import '../leadManagement/viewLeadsNew.dart';
import '../leadManagement/callHistoryPage.dart';
import '../leadManagement/projectDashboard.dart';
import '../leadManagement/minimalDashboard.dart';
import '../leadManagement/detailed_reports_page.dart';

// Account Management Screens
import '../accounts/expense/advance&expense.dart';
import '../accounts/expense/expense_list.dart';
import '../accounts/renewal_mannagement/custom_renewal.dart';
import '../accounts/renewal_mannagement/renewal_dashboard.dart';
import '../accounts/clients/pendingInvoice.dart';
import '../accounts/clients/receiptList.dart';
import '../accounts/dashboard/accounts_dashboard.dart';
import '../accounts/dashboard/bank_account.dart';

// Widgets
import '../../widgets/togglebutton_start.dart';

class DashboardLeadNew extends StatefulWidget {
  String? token;
  final GlobalKey<_DashboardLeadNewState>? dashboardKey;

  DashboardLeadNew(this.token, {super.key, this.dashboardKey});

  @override
  State<DashboardLeadNew> createState() => _DashboardLeadNewState();
}

class _DashboardLeadNewState extends State<DashboardLeadNew>
    with TickerProviderStateMixin {
  // Tab Controller - Initialize with default values
  late TabController _tabController;

  // Data Models
  LeadDashboardModel? leadDashboard;
  CommonConfigureModel? configure;
  LeadCategoryStaffWiseModel? staffWise;
  DashboardModel? userDashboard;
  RenewalDashboardModel? renewalDashboard;
  ProjectList? projectList;
  WorkStatusModel? workStatus;
  CommonResponse? loginOrNot;
  AccountDashboardModel? accountDashboard;
  LeadProgressbarModel? object1;
  String? firebaseToken;

  // State Variables
  bool isLoading = true;
  bool timeOut = false;
  bool isExpired = false;
  bool isWorkStarted = false;
  bool loadmore = false;
  bool moreloading = false;
  bool isVisible = true;
  bool toggle = false;
  bool _isTabControllerInitialized = false;

  // Dates
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  DateTime fromDate1 = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime toDate1 = DateTime.now();

  // User Data
  String name = '';
  String role = '';
  String userId = '';
  String staffId = '';
  String notificationCount = '0';

  // Permissions
  String accPermission = "";
  String renewalPermission = "false"; // Default to false
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

  // Booleans from permissions
  bool updateLeadPermission1 = false;
  bool deleteLeadPermission1 = false;
  bool cloudCallPermission1 = false;
  bool createLeadCategory1 = false;
  bool updateLeadCategory1 = false;
  bool deleteLeadCategory1 = false;
  bool accessCallRecordingPermission1 = false;

  // UI State
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();

  // Blue color theme matching old design
  final Color primaryBlue = const Color(0xFF2a86c9);
  final Color darkBlue = const Color(0xFF1a5a8c);
  final Color lightBlue = const Color(0xFF64b5f6);
  final Color veryLightBlue = const Color(0xFFe3f2fd);

  @override
  void initState() {
    super.initState();

    // Initialize with single tab first
    _tabController = TabController(
      length: 1,
      vsync: this,
    );
    _isTabControllerInitialized = true;

    // Load initial data
    _initializeData();
  }

  int _getTabCount() {
    int count = 1; // Lead dashboard always present
    if (renewalPermission == "true") count++;
    if (accPermission == "true") count++;
    return count;
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
      setState(() {});
    }
  }

  Future<void> _initializeData() async {
    await getData(widget.token, fromDate, toDate);
    _loadWorkStatus();
    _checkDashboardPermission();

    // Handle deep links
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

  Future<void> getData(
      String? token, DateTime fromDate, DateTime toDate) async {
    setState(() {
      isLoading = true;
      timeOut = false;
    });

    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (!connectivityResult.contains(ConnectivityResult.mobile) &&
          !connectivityResult.contains(ConnectivityResult.wifi)) {
        setState(() {
          isLoading = false;
          timeOut = true;
        });
        return;
      }

      // Load permissions and user data
      await _loadUserPermissions();

      // Update TabController after permissions are loaded
      _updateTabController();

      // Check token validity
      firebaseToken = await FirebaseMessaging.instance.getToken();
      LoginCheckModel? loginCheck =
          await HttpService.loginCheck(token, firebaseToken!);

      if (loginCheck == null || loginCheck.data == false) {
        if (mounted) {
          Common.toastMessaage('Session Expired', Colors.red);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false,
          );
        }
        return;
      }

      // Load dashboard data
      configure = await HttpService.configure(token);
      if (configure != null) {
        isExpired = configure!.data!.isExpired!;
      }

      leadDashboard = await HttpService.leadDashboard(
          token, fromDate, toDate, fromDate1.toString(), toDate1.toString());

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

      // Load additional dashboards
      await Future.wait([
        getAccountDash(),
        getRenewalDashboard(),
        getCustomerList(),
      ]);

      // Check login prompt
      await _checkLoginPrompt();

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

    // Load all permissions
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

    // Set boolean flags
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
  }

  Future<void> _checkLoginPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedDate = prefs.getString('loginPromptDismissedDate');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (dismissedDate != today && startAndStopWorkPermission == "true") {
      if (loginOrNot?.data != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showLoginPrompt(context);
          }
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

        // Refresh data
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
      if (customerData?.status == true) {
        // Store customer data if needed
      }
    } catch (e) {
      print("Error loading customers: $e");
    }
  }

  Future<void> getStaffwise() async {
    setState(() => moreloading = true);
    staffWise = await HttpService.leadDashboard1(widget.token, fromDate, toDate,
        fromDate1.toString(), toDate1.toString());
    setState(() => moreloading = false);
  }

  Future<void> getLeadProgressbar(String token, DateTime fromDate,
      DateTime toDate, String callStatus) async {
    object1 = await HttpService.leadProgressbar(
        token,
        DateFormat('dd-MM-yyyy').format(fromDate),
        DateFormat('dd-MM-yyyy').format(toDate),
        callStatus);
  }

  String _formatCurrency(String amount) {
    try {
      double value = double.parse(amount);
      return '₹${NumberFormat('#,##,###').format(value.toInt())}';
    } catch (e) {
      return '₹0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: veryLightBlue,
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

  Widget _buildBody() {
    if (timeOut) {
      return _buildErrorWidget();
    }

    return RefreshIndicator(
      onRefresh: () => getData(widget.token, fromDate, toDate),
      color: primaryBlue,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
            if (_getTabCount() > 1)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _buildTabBar(),
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
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, darkBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildProfileSection(),
                  const Spacer(),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
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
          const Tab(text: 'Leads'),
          if (renewalPermission == "true") const Tab(text: 'Renewals'),
          if (accPermission == "true") const Tab(text: 'Accounts'),
        ],
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
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildLeadDashboard(),
        ),
        if (renewalPermission == "true")
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildRenewalDashboard(),
          ),
        if (accPermission == "true")
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildAccountDashboard(),
          ),
      ],
    );
  }

  Widget _buildLeadDashboard() {
    return Column(
      children: [
        _buildQuickActions(),
        //const SizedBox(height: 0),
        _buildLeadStatsGrid(),
        const SizedBox(height: 20),
        if (isVisible) _buildModuleCarousel(),
        // const SizedBox(height: 20),
        // _buildLeadAnalytics(),
      ],
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
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionChip(
                icon: Icons.add_circle_outline,
                label: 'Add Lead',
                color: primaryBlue,
                onTap: () {
                  if (createLeadPermission == 'true') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddLeads(widget.token),
                      ),
                    ).then((_) => getData(widget.token, fromDate, toDate));
                  } else {
                    _showPermissionDialog();
                  }
                },
              ),
              const SizedBox(width: 12),
              _buildActionChip(
                icon: Icons.search,
                label: 'Search',
                color: darkBlue,
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
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildActionChip(
                icon: Icons.history,
                label: 'Call History',
                color: lightBlue,
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
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDateFilterChip(
                label: DateFormat('dd MMM').format(fromDate),
                onTap: () => _showDatePicker(isFrom: true),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              _buildDateFilterChip(
                label: DateFormat('dd MMM').format(toDate),
                onTap: () => _showDatePicker(isFrom: false),
              ),
            ],
          ),
        ],
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilterChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
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

  Widget _buildLeadStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'New Leads',
          value: leadDashboard?.data.newLeads.toString() ?? '0',
          icon: Icons.person_add,
          color: primaryBlue,
          onTap: () => _navigateToLeads('New Leads', '1'),
          tooltip: 'The combined count of new leads and unattended leads',
        ),
        _buildStatCard(
          title: 'Followup',
          value: leadDashboard?.data.followupLeads.toString() ?? '0',
          icon: Icons.schedule,
          color: Colors.orange,
          onTap: () => _navigateToLeads('Followup Leads', '2'),
          tooltip: 'Leads assigned for today including missed followups',
        ),
        _buildStatCard(
          title: 'Closed',
          value: leadDashboard?.data.closedLeads.toString() ?? '0',
          icon: Icons.check_circle,
          color: Colors.green,
          onTap: () => _navigateToLeads('Closed Leads', '4'),
          tooltip: 'Successfully converted leads',
        ),
        _buildStatCard(
          title: 'Missed',
          value: leadDashboard?.data.missedLeads.toString() ?? '0',
          icon: Icons.missed_video_call,
          color: Colors.red,
          onTap: () => _navigateToLeads('Missed Leads', '-3', leadType: '1'),
          tooltip: 'Leads that were not attended',
        ),
        _buildStatCard(
          title: 'Transferred',
          value: leadDashboard?.data.transferLeads.toString() ?? '0',
          icon: Icons.swap_horiz,
          color: Colors.purple,
          onTap: () =>
              _navigateToLeads('Transferred Leads', '-2', leadType: '2'),
          tooltip: 'Leads transferred to other staff',
        ),
        _buildStatCard(
          title: 'Total Called',
          value: leadDashboard?.data.totalCalled.toString() ?? '0',
          icon: Icons.phone_in_talk,
          color: Colors.teal,
          onTap: () => _navigateToLeads('Total Called', '-1', callStatus: '1'),
          tooltip: 'Total leads contacted',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return InkWell(
      onTap: onTap,
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
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                icon,
                size: 60,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (tooltip != null)
                        Tooltip(
                          message: tooltip,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
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

  void _navigateToLeads(String pageName, String status,
      {String? leadType, String? callStatus}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewLeadsNew(
          widget.token,
          updateLeadPermission1,
          deleteLeadPermission1,
          cloudCallPermission1,
          pageName: pageName,
          fromDate: fromDate.toString(),
          toDate: toDate.toString(),
          status: status,
          leadType: leadType,
          callStatus: callStatus,
        ),
      ),
    ).then((_) => getData(widget.token, fromDate, toDate));
  }

  Widget _buildModuleCarousel() {
    if (userDashboard == null) return const SizedBox();

    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: userDashboard!.data.modules.length,
        itemBuilder: (context, index) {
          final module = userDashboard!.data.modules[index];
          return _buildModuleItem(module, index);
        },
      ),
    );
  }

  Widget _buildModuleItem(dynamic module, int index) {
    return GestureDetector(
      onTap: () {
        _handleModuleNavigation(module.menuName);
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: module.image.toString(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.apps,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              module.categoryName ?? '',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
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

  void _handleModuleNavigation(String? menuName) {
    if (menuName == null) return;

    if (menuName == 'call_management') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardLeadNew(widget.token),
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

  Widget _buildLeadAnalytics() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailedReportsPage(
                      token: widget.token!,
                      fromDate: fromDate,
                      toDate: toDate,
                      fromDate1: fromDate1.toString(),
                      toDate1: toDate1,
                      updateLeadPermission1: updateLeadPermission1,
                      deleteLeadPermission1: deleteLeadPermission1,
                      cloudCallPermission1: cloudCallPermission1,
                      viewLeadPermission: viewLeadPermission,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.insights, size: 16),
              label: const Text('View Details'),
              style: TextButton.styleFrom(
                foregroundColor: primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (staffWise?.data?.staffLeads != null &&
            staffWise!.data!.staffLeads!.isNotEmpty)
          _buildStaffProgressBars(),
      ],
    );
  }

  Widget _buildStaffProgressBars() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Staff Performance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            staffWise!.data!.staffLeads!.take(5).toList().length,
            (index) => _buildStaffProgressItem(
              staffWise!.data!.staffLeads![index],
              index,
            ),
          ),
          if (staffWise!.data!.staffLeads!.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton(
                onPressed: getStaffwise,
                style: TextButton.styleFrom(
                  foregroundColor: primaryBlue,
                ),
                child: const Text('Show More'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStaffProgressItem(dynamic staff, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                staff.staffName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${staff.staffPercentage ?? 0}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: (staff.staffPercentage ?? 0) / 100,
            progressColor: primaryBlue,
            backgroundColor: Colors.grey.shade200,
            barRadius: const Radius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalDashboard() {
    if (renewalDashboard == null) {
      return _buildShimmerLoading();
    }

    return Column(
      children: [
        _buildRenewalHeader(),
        const SizedBox(height: 20),
        _buildRenewalStats(),
        const SizedBox(height: 20),
        _buildRenewalReports(),
      ],
    );
  }

  Widget _buildRenewalHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upcoming Renewals',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                renewalDashboard!.data.upcomingRenewals,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomRenewal(),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Renewal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryBlue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildRenewalStatCard(
          title: 'Current Month',
          paid: renewalDashboard!.data.currentMonthData.paidCount,
          total: renewalDashboard!.data.currentMonthData.totalCount,
          amount: renewalDashboard!.data.currentMonthData.paidAmount,
          color: Colors.green,
        ),
        _buildRenewalStatCard(
          title: 'Next Month',
          paid: renewalDashboard!.data.nextMonthData.paidCount,
          total: renewalDashboard!.data.nextMonthData.totalCount,
          amount: renewalDashboard!.data.nextMonthData.paidAmount,
          color: Colors.orange,
        ),
        _buildRenewalStatCard(
          title: 'Current Year',
          paid: renewalDashboard!.data.allData.paidCount,
          total: renewalDashboard!.data.allData.totalCount,
          amount: renewalDashboard!.data.allData.paidAmount,
          color: primaryBlue,
        ),
        _buildRenewalStatCard(
          title: 'Expired',
          paid: renewalDashboard!.data.expiredData.paidCount,
          total: renewalDashboard!.data.expiredData.totalCount,
          amount: renewalDashboard!.data.expiredData.paidAmount,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildRenewalStatCard({
    required String title,
    required String paid,
    required String total,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatCurrency(amount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$paid/$total Paid',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.trending_up,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalReports() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Reports',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            renewalDashboard!.data.monthReport.length,
            (index) => _buildReportItem(
              renewalDashboard!.data.monthReport[index],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(dynamic report) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                report.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatCurrency(report.amount.toString()),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2a86c9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearPercentIndicator(
            lineHeight: 6,
            percent: (report.percentage ?? 0) / 100,
            progressColor: primaryBlue,
            backgroundColor: Colors.grey.shade200,
            barRadius: const Radius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDashboard() {
    if (accountDashboard == null) {
      return _buildShimmerLoading();
    }

    return Column(
      children: [
        _buildAccountHeader(),
        const SizedBox(height: 20),
        _buildAccountStats(),
        const SizedBox(height: 20),
        _buildAccountReports(),
      ],
    );
  }

  Widget _buildAccountHeader() {
    return GestureDetector(
      onTap: () {
        setState(() => toggle = !toggle);
        Common.saveSharedPref("acc_toggle", toggle.toString());
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Account Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              toggle ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStats() {
    List<Map<String, dynamic>> stats = [
      {
        'label': 'Bank Account',
        'value': accountDashboard!.data.bankAccount,
        'color': Colors.green,
        'onTap': () => _navigateToBankAccount(),
      },
      {
        'label': 'Pending Expense',
        'value': accountDashboard!.data.pendingExpense,
        'color': Colors.red,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PendingExpense(status: "2"),
            ),
          );
        },
      },
      {
        'label': "Today's Income",
        'value': accountDashboard!.data.todaysIncome,
        'color': primaryBlue,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptList(
                widget.token!,
                fdate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                tdate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
            ),
          );
        },
      },
      {
        'label': "Today's Expense",
        'value': accountDashboard!.data.todayExpense,
        'color': Colors.orange,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseList(
                fdate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                tdate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
            ),
          );
        },
      },
      {
        'label': 'Month Income',
        'value': accountDashboard!.data.monthlyIncome,
        'color': Colors.purple,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptList(
                widget.token!,
                fdate: DateFormat('dd-MM-yyyy').format(
                  DateTime(DateTime.now().year, DateTime.now().month, 1),
                ),
                tdate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
              ),
            ),
          );
        },
      },
      {
        'label': 'Month Expense',
        'value': accountDashboard!.data.monthlyExpense,
        'color': Colors.teal,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseList(
                fdate: DateFormat('yyyy-MM-dd').format(
                  DateTime(DateTime.now().year, DateTime.now().month, 1),
                ),
                tdate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
            ),
          );
        },
      },
      {
        'label': 'Pending Invoice',
        'value': accountDashboard!.data.pendingIncome,
        'color': Colors.brown,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PendingInvoice(widget.token!,''),
            ),
          );
        },
      },
      {
        'label': 'Advance Amount',
        'value': accountDashboard!.data.advanceAmount,
        'color': Colors.indigo,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PendingExpense(status: "3"),
            ),
          );
        },
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: stats.map((stat) => _buildAccountStatCard(stat)).toList(),
    );
  }

  Widget _buildAccountStatCard(Map<String, dynamic> stat) {
    return InkWell(
      onTap: stat['onTap'],
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              stat['label'],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            Text(
              _formatCurrency(stat['value'].toString()),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: stat['color'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBankAccount() {
    if (accountDashboard!.data.bankAccCount == "1") {
      if (accountDashboard!.data.isViewBankAcc) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BankAccount(
              accId: accountDashboard!.data.bankAccountId,
              accName: accountDashboard!.data.bankAccountName,
            ),
          ),
        );
      }
    } else if (accountDashboard!.data.bankAccCount == "0") {
      Common.toastMessaage("Please add a 'BANK ACCOUNT'", Colors.red);
    } else {
      if (accountDashboard!.data.isViewBankAcc &&
          accountDashboard!.data.isViewPendingExpense) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PendingExpense(status: "1"),
          ),
        );
      }
    }
  }

  Widget _buildAccountReports() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Income Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildIncomeReport(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expense Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildExpenseReport(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDateRangeSelector(
                  label: 'From',
                  date: fromDate1,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: fromDate1,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => fromDate1 = picked);
                      getAccountDash();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateRangeSelector(
                  label: 'To',
                  date: toDate1,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: toDate1,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => toDate1 = picked);
                      getAccountDash();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIncomeReport() {
    if (accountDashboard!.data.incomeGraph.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: const Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    return accountDashboard!.data.incomeGraph.take(3).map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatCurrency(item.totalExpense),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearPercentIndicator(
              lineHeight: 4,
              percent: (double.tryParse(item.perc.toString()) ?? 0.0) / 100,
              progressColor: Colors.green,
              backgroundColor: Colors.grey.shade200,
              barRadius: const Radius.circular(2),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildExpenseReport() {
    if (accountDashboard!.data.expenseGraph.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: const Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    return accountDashboard!.data.expenseGraph.take(3).map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.expCatName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatCurrency(item.totalExpense),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearPercentIndicator(
              lineHeight: 4,
              percent: (double.tryParse(item.perc.toString()) ?? 0.0) / 100,
              progressColor: Colors.red,
              backgroundColor: Colors.grey.shade200,
              barRadius: const Radius.circular(2),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDateRangeSelector({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              '$label: ${DateFormat('dd MMM yyyy').format(date)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
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
          builder: (context) => DashboardLeadNew(widget.token),
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

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
