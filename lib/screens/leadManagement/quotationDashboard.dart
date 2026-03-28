import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/dashboardModel.dart';
import 'package:login2/models/lead_management/quotation_dashboard_model.dart';
import 'package:login2/models/loginCheckModel.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/authentication/login.dart';
import 'package:login2/screens/bottom_navigation_bar.dart';
import 'package:login2/screens/drawerScreen.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/addQuotationPage.dart';
import 'package:login2/screens/leadManagement/add_quotation_request_sheet.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/minimalDashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/leadManagement/quotationPage.dart';
import 'package:login2/screens/leadManagement/quotationRequestPage.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/togglebutton_start.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class QuotationDashboard extends StatefulWidget {
  const QuotationDashboard({super.key});

  @override
  State<QuotationDashboard> createState() => _QuotationDashboardState();
}

class _QuotationDashboardState extends State<QuotationDashboard>
    with TickerProviderStateMixin {
  bool isLoading = false;
  bool _isFabExpanded = false;
  QuotationDashboardData? dashboardData;
  String? quotationPermission;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  String? userId;
  String? token;
  String? name;
  String? role;
  bool isWorkStarted = false;
  String? startAndStopWorkPermission;
  int notificationCount = 0; // Add notification count
  String? phoneCallLogPermission; // Add phone call log permission
  DashboardModel? userDashboard; // Add user dashboard data
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  String? NewleadDashboardPermission;
  String? adminCheckPermission;
  String? firebaseToken;
  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _blinkAnimation =
        Tween<double>(begin: 0.3, end: 1.0).animate(_blinkController);
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );
    _loadData();
    _loadDashboard();
    _loadUserData();
    loadPrefs();
  }

  Future<void> loadPrefs() async {
    firebaseToken = await FirebaseMessaging.instance.getToken();
    LoginCheckModel? loginCheck =
        await HttpService.loginCheck(token, firebaseToken!);
    log(firebaseToken.toString());
    if (loginCheck == null || loginCheck.data == false) {
      if (mounted) {
        Common.toastMessaage('Session Expired', Colors.red);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false);
      }
      return;
    }
    final value = await Common.getSharedPref("multipleWorks");
    userId = await Common.getSharedPref("userId");
    token = await Common.getSharedPref("token");
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    NewleadDashboardPermission =
        await Common.getSharedPref("NewleadDashboardPermission");
    adminCheckPermission = await Common.getSharedPref("adminCheckPermission");
  }

  Future<void> _loadDashboard() async {
    quotationPermission =
        await Common.getSharedPref("QuotationDashboardPermission");
  }

  Future<void> _loadUserData() async {
    token = await Common.getSharedPref("token");
    userId = await Common.getSharedPref("userId");
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");
    startAndStopWorkPermission =
        await Common.getSharedPref("startAndStopWorkPermission");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    if (token != null) {
      await _loadNotificationCount();
      await _loadUserDashboard();
    }
  }

  Future<void> _loadNotificationCount() async {
    setState(() {
      notificationCount = 0;
    });
  }

  Future<void> _loadUserDashboard() async {
    try {
      if (token != null) {}
    } catch (e) {
      print("Error loading user dashboard: $e");
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  void _navigateToCreateQuotation() {
    _toggleFab();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddQuotationPage(),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToCreateRequest() {
    _toggleFab();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddQuotationRequestSheet(
        onSuccess: () => _loadData(),
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    final response = await HttpService().getQuotationDashboard();

    if (response != null && response.status == "success") {
      setState(() {
        dashboardData = response.data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      Common.toastMessaage("Failed to load dashboard", Colors.red);
    }
  }

  Future<bool> _showExitConfirmation() async {
    return (await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit the application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        )) ??
        false;
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
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()),
                            (Route<dynamic> route) => false,
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 22, 145, 216),
      foregroundColor: Colors.white,
      title: const Text('Quotation Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          )),
      automaticallyImplyLeading: quotationPermission != "true",
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
        ),
        quotationPermission == "true"
            ? IconButton(
                icon: const Icon(Icons.logout_outlined),
                onPressed: () => logout(context),
              )
            : const SizedBox(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (quotationPermission == "true") {
          final shouldExit = await _showExitConfirmation();
          if (!shouldExit) {
            return false;
          }
          exit(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadData,
              color: const Color.fromARGB(255, 22, 145, 216),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : dashboardData == null
                      ? const Center(child: Text("No data available"))
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Add user profile section
                              //  _buildUserProfileSection(),
                              const SizedBox(height: 10),
                              _summaryHeader(),
                              const SizedBox(height: 20),
                              _sectionTitle('Quotations'),
                              const SizedBox(height: 12),
                              _quotationsGrid(),
                              const SizedBox(height: 24),
                              _sectionTitle('Quotation Requests'),
                              const SizedBox(height: 12),
                              _requestsGrid(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
            ),
            // FAB Overlay - Tap outside to close
            if (_isFabExpanded)
              GestureDetector(
                onTap: _toggleFab,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),

            // Fixed position FAB at bottom-right
            Positioned(
              bottom: 80, // Adjusted to accommodate bottom navigation
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Expanded options
                  if (_isFabExpanded)
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(_fabAnimation),
                      child: FadeTransition(
                        opacity: _fabAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Close button at top of expanded menu
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: _toggleFab,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildActionButton(
                              icon: Icons.description,
                              label: 'Create Quotation',
                              color: Colors.indigo,
                              onTap: _navigateToCreateQuotation,
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              icon: Icons.request_quote,
                              label: 'Create Request',
                              color: Colors.blue,
                              onTap: _navigateToCreateRequest,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                  // Main FAB Button
                  GestureDetector(
                    onTap: _toggleFab,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(222, 31, 87, 160),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _fabAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _fabAnimation.value * 0.785398,
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        endDrawer: DraweScreen(token!),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => ProjectDashboard()),
            // );
            ProjectDashboardPermission == "true"
                ? Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ProjectDashboard()),
                  )
                : AccountsDashboardPermission == "true"
                    ? Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AccountsDashboard(token: token!)),
                      )
                    : MenuDashboard == "true"
                        ? Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage(token)),
                          )
                        : RenewalDashboardPermission == "true"
                            ? Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RenewalDashboard()),
                              )
                            : NewleadDashboardPermission == "true"
                                ? Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MinimalDashboard(token)),
                                  )
                                : Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DashboardLeadNewUpdatedTwo(token)),
                                  );
          },
          child: Image.asset("assets/icons/menu.png", width: 25),
        ),
        bottomNavigationBar: token != null && name != null && userId != null
            ? BottomNavigation(
                token!,
                phoneCallLogPermission: phoneCallLogPermission ?? "",
                name: name!,
                userId: userId!,
              )
            : null,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 22, 145, 216),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _summaryItem(
            value: dashboardData!.totalRequest.toString(),
            label: 'Total Requests',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuotationRequestPage(
                    requestType: "All",
                  ),
                ),
              );
            },
          ),
          Container(
            height: 40,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white24,
          ),
          _summaryItem(
            value: dashboardData!.totalQuotations.toString(),
            label: 'Total Quotations',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuotationPage(
                    status: "All",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _totalRequestsCard({VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.request_quote,
                      color: Colors.blue, size: 20),
                ),
                const Spacer(),
                Text(
                  dashboardData!.totalRequest.toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Total Requests',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            if (dashboardData!.newRequests > 0) const SizedBox(height: 4),
            if (dashboardData!.newRequests > 0)
              FadeTransition(
                opacity: _blinkAnimation,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'NEW • ${dashboardData!.newRequests}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToQuotationList(dynamic status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuotationPage(status: status),
      ),
    );
  }

  void _navigateToRequests(dynamic type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuotationRequestPage(
          requestType: type,
        ),
      ),
    );
  }

  Widget _requestsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _totalRequestsCard(
          onTap: () => _navigateToRequests("All"),
        ),
        _miniCard(
          Icons.pending,
          'Pending Requests',
          dashboardData!.pendingRequest.toString(),
          Colors.orange,
          onTap: () => _navigateToRequests("7"),
        ),
        _miniCard(
          Icons.check_circle,
          'Completed Requests',
          dashboardData!.completedRequest.toString(),
          Colors.green,
          onTap: () => _navigateToRequests("4"),
        ),
        _miniCard(
          Icons.send,
          'Sent',
          dashboardData!.totalSent.toString(),
          const Color.fromARGB(255, 48, 106, 153),
          onTap: () => _navigateToRequests("2"),
        ),
        // _miniCard(
        //   Icons.trending_up,
        //   'Completion Rate',
        //   dashboardData!.totalRequest == 0
        //       ? '0%'
        //       : '${((dashboardData!.completedRequest / dashboardData!.totalRequest) * 100).toStringAsFixed(1)}%',
        //   Colors.purple,
        //   onTap: () => _navigateToRequests("All"),
        // ),
      ],
    );
  }

  Widget _quotationsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _miniCard(
          Icons.description,
          'Total Quotations',
          dashboardData!.totalQuotations.toString(),
          Colors.indigo,
          onTap: () {
            _navigateToQuotationList("All");
          },
        ),
        _miniCard(
          Icons.hourglass_bottom,
          'On-Hold',
          dashboardData!.totalonHold.toString(),
          Colors.blue,
          onTap: () {
            _navigateToQuotationList(3);
          },
        ),
        _miniCard(
          Icons.thumb_up,
          'Approved',
          dashboardData!.totalApproved.toString(),
          Colors.green,
          onTap: () {
            _navigateToQuotationList(2);
          },
        ),
        _miniCard(
          Icons.thumb_down,
          'Rejected',
          dashboardData!.totalRejected.toString(),
          Colors.red,
          onTap: () {
            _navigateToQuotationList(0);
          },
        ),
        // _miniCard(
        //   Icons.pending,
        //   'Pending',
        //   dashboardData!.pendingRequest.toString(),
        //   const Color.fromARGB(255, 218, 216, 144),
        //   onTap: () {
        //     _navigateToQuotationList(1);
        //   },
        // ),
        // _miniCard(
        //   Icons.send,
        //   'Send',
        //   dashboardData!.totalSent.toString(),
        //   const Color.fromARGB(255, 48, 106, 153),
        //   onTap: () => _navigateToRequests("2"),
        // ),
      ],
    );
  }

  Widget _miniCard(
    IconData icon,
    String title,
    String value,
    Color color, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
