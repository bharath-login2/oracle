import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/commonConfigureModel.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/authentication/login.dart';
import 'package:login2/screens/bottom_navigation_bar.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/minimalDashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/serviceman/bottomNavBar.dart';
import 'package:login2/screens/serviceman/dashboard_card.dart';
import 'package:login2/screens/serviceman/notificationPage.dart';
import 'package:login2/screens/serviceman/sideBar.dart';
import 'package:login2/screens/serviceman/workCategoryWidget.dart';
import 'package:login2/screens/serviceman/workList.dart';
import 'package:login2/screens/serviceman/work_card.dart';
import 'package:login2/service/service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'work_status_page.dart';
import 'work_category_page.dart';
import 'expense_income_page.dart';
import 'work_progress_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSwitched = false;
  int _selectedIndex = 0;
  String staffName = "";
  String phoneCallLogPermission = '';
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  String? NewleadDashboardPermission;
  String name = '';
  String role = '';
  String userId = '';
  String token = '';
  int notificationCount = 0;
  String profilePic = '';
  CommonConfigureModel? configure;

  @override
  void initState() {
    super.initState();
    _loadStaffName();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() async {
    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
    String? token = await messaging.getToken();
    print('FCM Token: $token');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked: ${message.data}');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NotificationPageService()),
      );
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    final snackBar = SnackBar(
      content: Text(
        message.notification?.title ?? "New Notification",
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF2a86c9),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      debugPrint("Home clicked");
    } else if (index == 1) {
      debugPrint("Expense clicked");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExpenseIncomePage()),
      );
    }
  }

  void _refreshPage() {
    debugPrint("Page Refreshed!");
    setState(() {});
  }

  Future<void> _loadStaffName() async {
    final prefs = await SharedPreferences.getInstance();
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");
    userId = await Common.getSharedPref("userId");
    token = await Common.getSharedPref("token");
    final String pPic = await Common.getSharedPref("profile_pic") ?? "";
    configure = await HttpService.configure(token);
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    NewleadDashboardPermission =
        await Common.getSharedPref("NewleadDashboardPermission");
    setState(() {
      staffName = prefs.getString('staff_name') ?? "Staff";
      profilePic = pPic;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF2a86c9),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const SideBar(),
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, top: 10.0, bottom: 10.0, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Logout"),
                            content:
                                const Text("Are you sure you want to log out?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 145, 141, 141),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Logout"),
                              ),
                            ],
                          ),
                        );
                        if (shouldLogout == true) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('token');
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const Login()),
                              (route) => false,
                            );
                          }
                        }
                      },
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
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: (profilePic.isNotEmpty)
                              ? NetworkImage(profilePic)
                              : const AssetImage(
                                      "assets/icons/profile_placeholder.png")
                                  as ImageProvider,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isNotEmpty ? name : staffName,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          role.isNotEmpty ? role : "Serviceman",
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
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationPageService()),
                        ).then((r) {
                          _loadStaffName();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Stack(
                          children: [
                            Image.asset("assets/icons/notification.png",
                                width: 20, color: Colors.white),
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: const BoxConstraints(
                                    minWidth: 12, minHeight: 12),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _scaffoldKey.currentState!.openEndDrawer();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Image.asset("assets/icons/menu.png",
                            width: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome Back!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          name.isNotEmpty ? name : staffName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.work,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 5),
                              Text(
                                role.isNotEmpty ? role : "Serviceman",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.engineering,
                        color: Colors.white, size: 40),
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search work, tasks...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Color(0xFF2a86c9)),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Work Categories Grid - Redesigned
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.0,
                children: [
                  _buildModernWorkCard(
                    title: "New Work",
                    icon: Icons.fiber_new,
                    color: const Color(0xFF4A90E2),
                    gradientColors: [
                      const Color(0xFF4A90E2),
                      const Color(0xFF357ABD)
                    ],
                    typeId: "1",
                  ),
                  _buildModernWorkCard(
                    title: "Pending Work",
                    icon: Icons.hourglass_empty,
                    color: const Color(0xFFF39C12),
                    gradientColors: [
                      const Color(0xFFF39C12),
                      const Color(0xFFE67E22)
                    ],
                    typeId: "2",
                  ),
                  _buildModernWorkCard(
                    title: "Ongoing Work",
                    icon: Icons.build,
                    color: const Color(0xFF27AE60),
                    gradientColors: [
                      const Color(0xFF27AE60),
                      const Color(0xFF229954)
                    ],
                    typeId: "3",
                  ),
                  _buildModernWorkCard(
                    title: "Completed Work",
                    icon: Icons.check_circle,
                    color: const Color(0xFF8E44AD),
                    gradientColors: [
                      const Color(0xFF8E44AD),
                      const Color(0xFF6C3483)
                    ],
                    typeId: "4",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const WorkCategoryCard(),
            // const SizedBox(height: 20),
            // DashboardCard(
            //   title: "Expense/Income Overview",
            //   onTap: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => const ExpenseIncomePage()),
            //   ),
            //   child: SizedBox(
            //     height: 280,
            //     child: Padding(
            //       padding: const EdgeInsets.all(12.0),
            //       child: Column(
            //         children: [
            //           Expanded(
            //             child: BarChart(
            //               BarChartData(
            //                 alignment: BarChartAlignment.spaceAround,
            //                 maxY: 25000,
            //                 barTouchData: BarTouchData(enabled: false),
            //                 titlesData: FlTitlesData(
            //                   leftTitles: AxisTitles(
            //                     sideTitles: SideTitles(
            //                       showTitles: true,
            //                       reservedSize: 40,
            //                       getTitlesWidget: (value, meta) {
            //                         return Text(
            //                           '${(value / 1000).toInt()}k',
            //                           style: const TextStyle(fontSize: 10),
            //                         );
            //                       },
            //                     ),
            //                   ),
            //                   bottomTitles: AxisTitles(
            //                     sideTitles: SideTitles(
            //                       showTitles: true,
            //                       getTitlesWidget:
            //                           (double value, TitleMeta meta) {
            //                         const days = [
            //                           'Mon',
            //                           'Tue',
            //                           'Wed',
            //                           'Thu',
            //                           'Fri',
            //                           'Sat',
            //                           'Sun'
            //                         ];
            //                         if (value.toInt() >= 0 &&
            //                             value.toInt() < days.length) {
            //                           return Text(days[value.toInt()],
            //                               style: const TextStyle(fontSize: 10));
            //                         }
            //                         return const Text('');
            //                       },
            //                       reservedSize: 32,
            //                     ),
            //                   ),
            //                 ),
            //                 gridData: FlGridData(
            //                     show: true,
            //                     drawHorizontalLine: true,
            //                     drawVerticalLine: false),
            //                 borderData: FlBorderData(show: false),
            //                 barGroups: [
            //                   BarChartGroupData(x: 0, barRods: [
            //                     BarChartRodData(
            //                         toY: 20000,
            //                         color: Colors.orange,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                     BarChartRodData(
            //                         toY: 10000,
            //                         color: Colors.purple,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                   ]),
            //                   BarChartGroupData(x: 1, barRods: [
            //                     BarChartRodData(
            //                         toY: 18000,
            //                         color: Colors.orange,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                     BarChartRodData(
            //                         toY: 12000,
            //                         color: Colors.purple,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                   ]),
            //                   BarChartGroupData(x: 2, barRods: [
            //                     BarChartRodData(
            //                         toY: 15000,
            //                         color: Colors.orange,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                     BarChartRodData(
            //                         toY: 9000,
            //                         color: Colors.purple,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                   ]),
            //                   BarChartGroupData(x: 3, barRods: [
            //                     BarChartRodData(
            //                         toY: 22000,
            //                         color: Colors.orange,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                     BarChartRodData(
            //                         toY: 11000,
            //                         color: Colors.purple,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                   ]),
            //                   BarChartGroupData(x: 4, barRods: [
            //                     BarChartRodData(
            //                         toY: 21000,
            //                         color: Colors.orange,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                     BarChartRodData(
            //                         toY: 10000,
            //                         color: Colors.purple,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                   ]),
            //                   BarChartGroupData(x: 5, barRods: [
            //                     BarChartRodData(
            //                         toY: 17000,
            //                         color: Colors.orange,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                     BarChartRodData(
            //                         toY: 8000,
            //                         color: Colors.purple,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                   ]),
            //                   BarChartGroupData(x: 6, barRods: [
            //                     BarChartRodData(
            //                         toY: 23000,
            //                         color: Colors.orange,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                     BarChartRodData(
            //                         toY: 12000,
            //                         color: Colors.purple,
            //                         width: 8,
            //                         borderRadius: BorderRadius.circular(4)),
            //                   ]),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           const SizedBox(height: 16),
            //           Container(
            //             padding: const EdgeInsets.all(12),
            //             decoration: BoxDecoration(
            //               color: Colors.grey.shade50,
            //               borderRadius: BorderRadius.circular(12),
            //             ),
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceAround,
            //               children: [
            //                 _buildLegendItem(Icons.trending_up, "Income",
            //                     "₹20,000", Colors.orange),
            //                 _buildLegendItem(Icons.trending_down, "Expense",
            //                     "₹10,000", Colors.purple),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            // const SizedBox(height: 20),

            // // Work Progress Dashboard Card
            // DashboardCard(
            //   title: "Work Progress Tracker",
            //   onTap: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => const WorkProgressPage()),
            //   ),
            //   child: SizedBox(
            //     height: 240,
            //     child: Padding(
            //       padding: const EdgeInsets.all(12.0),
            //       child: Column(
            //         children: [
            //           // Legend
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               _buildLegendDot(Colors.orange, "Ongoing"),
            //               const SizedBox(width: 20),
            //               _buildLegendDot(Colors.green, "Completed"),
            //               const SizedBox(width: 20),
            //               _buildLegendDot(Colors.red, "Pending"),
            //             ],
            //           ),
            //           const SizedBox(height: 10),
            //           Expanded(
            //             child: LineChart(
            //               LineChartData(
            //                 gridData: FlGridData(
            //                     show: true,
            //                     drawHorizontalLine: true,
            //                     drawVerticalLine: false),
            //                 titlesData: FlTitlesData(
            //                   bottomTitles: AxisTitles(
            //                     sideTitles: SideTitles(
            //                       showTitles: true,
            //                       getTitlesWidget: (value, meta) {
            //                         const weeks = [
            //                           'Week 1',
            //                           'Week 2',
            //                           'Week 3',
            //                           'Week 4'
            //                         ];
            //                         if (value >= 0 && value < weeks.length) {
            //                           return Padding(
            //                             padding:
            //                                 const EdgeInsets.only(top: 8.0),
            //                             child: Text(weeks[value.toInt()],
            //                                 style:
            //                                     const TextStyle(fontSize: 10)),
            //                           );
            //                         }
            //                         return const Text('');
            //                       },
            //                       reservedSize: 40,
            //                     ),
            //                   ),
            //                   leftTitles: AxisTitles(
            //                     sideTitles: SideTitles(
            //                       showTitles: true,
            //                       getTitlesWidget: (value, meta) {
            //                         return Text('${value.toInt()}%',
            //                             style: const TextStyle(fontSize: 10));
            //                       },
            //                       reservedSize: 35,
            //                     ),
            //                   ),
            //                   rightTitles: const AxisTitles(
            //                       sideTitles: SideTitles(showTitles: false)),
            //                   topTitles: const AxisTitles(
            //                       sideTitles: SideTitles(showTitles: false)),
            //                 ),
            //                 borderData: FlBorderData(
            //                     show: true,
            //                     border: Border.all(
            //                         color: const Color(0xffE0E0E0), width: 1)),
            //                 minX: 0,
            //                 maxX: 3,
            //                 minY: 0,
            //                 maxY: 100,
            //                 lineBarsData: [
            //                   LineChartBarData(
            //                     spots: const [
            //                       FlSpot(0, 30),
            //                       FlSpot(1, 45),
            //                       FlSpot(2, 60),
            //                       FlSpot(3, 40)
            //                     ],
            //                     isCurved: true,
            //                     color: Colors.orange,
            //                     barWidth: 3,
            //                     isStrokeCapRound: true,
            //                     dotData: FlDotData(show: true),
            //                     belowBarData: BarAreaData(
            //                         show: true,
            //                         color: Colors.orange.withOpacity(0.2)),
            //                   ),
            //                   LineChartBarData(
            //                     spots: const [
            //                       FlSpot(0, 20),
            //                       FlSpot(1, 45),
            //                       FlSpot(2, 60),
            //                       FlSpot(3, 85)
            //                     ],
            //                     isCurved: true,
            //                     color: Colors.green,
            //                     barWidth: 3,
            //                     isStrokeCapRound: true,
            //                     dotData: FlDotData(show: true),
            //                     belowBarData: BarAreaData(
            //                         show: true,
            //                         color: Colors.green.withOpacity(0.2)),
            //                   ),
            //                   LineChartBarData(
            //                     spots: const [
            //                       FlSpot(0, 80),
            //                       FlSpot(1, 55),
            //                       FlSpot(2, 40),
            //                       FlSpot(3, 15)
            //                     ],
            //                     isCurved: true,
            //                     color: Colors.red,
            //                     barWidth: 3,
            //                     isStrokeCapRound: true,
            //                     dotData: FlDotData(show: true),
            //                     belowBarData: BarAreaData(
            //                         show: true,
            //                         color: Colors.red.withOpacity(0.2)),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2a86c9),
        onPressed: () {
          ProjectDashboardPermission == "true"
              ? Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ProjectDashboard()))
              : AccountsDashboardPermission == "true"
                  ? Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AccountsDashboard(token: token!)))
                  : MenuDashboard == "true"
                      ? Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(token)))
                      : RenewalDashboardPermission == "true"
                          ? Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RenewalDashboard()))
                          : NewleadDashboardPermission == "true"
                              ? Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MinimalDashboard(token)))
                              : Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DashboardLeadNewUpdatedTwo(token)));
        },
        child: const Icon(Icons.dashboard, color: Colors.white),
      ),
      bottomNavigationBar: configure != null
          ? BottomNavigation(
              token,
              phoneCallLogPermission: phoneCallLogPermission,
              name: name,
              userId: userId,
            )
          : const SizedBox(),
    );
  }

  Widget _buildModernWorkCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Color> gradientColors,
    required String typeId,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkListPage(
              pageTitle: title,
              typeId: typeId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: color,
                fontFamily: "MontserratBold",
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: 3,
              decoration: BoxDecoration(
                color: color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(width: 6),
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
