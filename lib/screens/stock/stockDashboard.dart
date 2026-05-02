import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/commonConfigureModel.dart';
import 'package:login2/screens/bottom_navigation_bar.dart';
import 'package:login2/screens/drawerScreen.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/minimalDashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/stock/stockRegisterPage.dart';
import 'package:login2/screens/stock/openingStockPage.dart';
import 'package:login2/screens/stock/stockConsumptionPage.dart';
import 'package:login2/screens/stock/stockRequestPage.dart';
import 'package:login2/service/service.dart';

class StockDashboard extends StatefulWidget {
  final String token;
  final String name;
  final String userId;
  final String? phoneCallLogPermission;
  final String? custId;

  const StockDashboard({
    super.key,
    required this.token,
    required this.name,
    required this.userId,
    this.phoneCallLogPermission,
    this.custId,
  });

  @override
  State<StockDashboard> createState() => _StockDashboardState();
}

class _StockDashboardState extends State<StockDashboard> {
  CommonConfigureModel? configure;
  bool isLoading = true;
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  String? NewleadDashboardPermission;

  @override
  void initState() {
    super.initState();
    _permissionsCheck();
    _loadConfiguration();
  }

  Future<void> _permissionsCheck() async {
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    NewleadDashboardPermission =
        await Common.getSharedPref("NewleadDashboardPermission");
  }

  Future<void> _loadConfiguration() async {
    try {
      configure = await HttpService.configure(widget.token);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading configuration: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stock Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.1,
                      children: [
                        _buildDashboardBox(
                          context,
                          title: 'Stock Register',
                          icon: Icons.inventory_2_outlined,
                          color: const Color(0xFF667eea),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockRegisterPage(
                                  token: widget.token,
                                  name: widget.name,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildDashboardBox(
                          context,
                          title: 'Opening Stock',
                          icon: Icons.unarchive_outlined,
                          color: const Color(0xFF43e97b),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OpeningStockPage(),
                              ),
                            );
                          },
                        ),
                        _buildDashboardBox(
                          context,
                          title: 'Stock Consumption',
                          icon: Icons.shopping_cart_checkout_outlined,
                          color: const Color(0xFFf093fb),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StockConsumptionPage(),
                              ),
                            );
                          },
                        ),
                        _buildDashboardBox(
                          context,
                          title: 'Stock Request',
                          icon: Icons.request_quote_outlined,
                          color: const Color(0xFFf6d365),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StockRequestPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
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
                              AccountsDashboard(token: widget.token)),
                    )
                  : MenuDashboard == "true"
                      ? Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(widget.token)),
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
                                          MinimalDashboard(widget.token)),
                                )
                              : Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DashboardLeadNewUpdatedTwo(
                                              widget.token)),
                                );
        },
        child: Image.asset("assets/icons/menu.png", width: 25),
      ),
      bottomNavigationBar: configure != null
          ? BottomNavigation(
              widget.token,
              phoneCallLogPermission: widget.phoneCallLogPermission ?? 'false',
              name: widget.name,
              userId: widget.userId,
            )
          : const SizedBox(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          InkWell(
            onTap: () => logout(context),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    color: Colors.grey.shade800,
                    offset: const Offset(0, 2.0),
                  )
                ],
                shape: BoxShape.circle,
                color: const Color(0xFF2191ce),
              ),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Stock Dashboard',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardBox(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
