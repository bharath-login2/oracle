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
import 'package:login2/models/lead_management/getStockRegisterListModel.dart';
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
  List<StockRegisterData> recentRegisters = [];
  bool isRegistersLoading = true;

  @override
  void initState() {
    super.initState();
    _permissionsCheck();
    _loadConfiguration();
    _fetchRecentRegisters();
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

  Future<void> _fetchRecentRegisters() async {
    if (mounted) {
      setState(() => isRegistersLoading = true);
    }
    try {
      final response = await HttpService.getStockRegisterList("0");
      if (response != null && response.status == true) {
        if (mounted) {
          setState(() {
            recentRegisters = response.data.take(5).toList();
            isRegistersLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            recentRegisters = [];
            isRegistersLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching recent stock register: $e");
      if (mounted) {
        setState(() => isRegistersLoading = false);
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
            : RefreshIndicator(
                onRefresh: () async {
                  await _loadConfiguration();
                  await _fetchRecentRegisters();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                              ).then((_) => _fetchRecentRegisters());
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
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Register',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StockRegisterPage(
                                    token: widget.token,
                                    name: widget.name,
                                    userId: widget.userId,
                                  ),
                                ),
                              ).then((_) => _fetchRecentRegisters());
                            },
                            child: const Row(
                              children: [
                                Text(
                                  'View More',
                                  style: TextStyle(
                                    color: Color(0xFF667eea),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: Color(0xFF667eea),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      isRegistersLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : recentRegisters.isEmpty
                              ? _buildEmptyRegistersState()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: recentRegisters.length,
                                  itemBuilder: (context, index) {
                                    return _buildRecentRegisterCard(recentRegisters[index]);
                                  },
                                ),
                    ],
                  ),
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

  Widget _buildRecentRegisterCard(StockRegisterData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: InkWell(
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
          ).then((_) => _fetchRecentRegisters());
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF667eea).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: Color(0xFF667eea),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.materialName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.unit.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.unit,
                        style: const TextStyle(
                          color: Color(0xFF667eea),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRegisterStat('Available', item.currentQty, const Color(0xFF10B981)),
                  _buildRegisterStat('Purchased', item.purchasedQty, const Color(0xFF3B82F6)),
                  _buildRegisterStat('Consumed', item.consumedQty, const Color(0xFFF59E0B)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyRegistersState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 40,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          Text(
            'No Recent Registers',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
