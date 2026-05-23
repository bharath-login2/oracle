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
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0, right: 10),
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
                            content: const Text(
                              "Are you sure you want to log out?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    145,
                                    141,
                                    141,
                                  ),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text("Logout"),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true) {
                          final prefs =
                              await SharedPreferences.getInstance();
                          await prefs.remove('token');
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Login(),
                              ),
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
                            color: const Color(0xFF2191ce)),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: (profilePic.isNotEmpty)
                              ? NetworkImage(profilePic)
                              : const AssetImage("assets/icons/profile_placeholder.png") as ImageProvider,
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
                            Image.asset(
                                "assets/icons/notification.png",
                                width: 20,
                                color: Colors.white),
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
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
                        child: Image.asset("assets/icons/menu.png", width: 20, color: Colors.white),
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
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
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
                  hintText: "Search....",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 1.1,
                  children: [
                    WorkCard(
                      title: "New Work",
                      color: const Color.fromARGB(255, 195, 221, 241),
                      imagePath: "assets/icons/suiticon.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkListPage(
                              pageTitle: "New Work",
                              typeId: "1",
                            ),
                          ),
                        );
                      },
                    ),
                    WorkCard(
                      title: "Pending Work",
                      color: const Color.fromARGB(255, 247, 212, 224),
                      imagePath: "assets/icons/suiticon.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkListPage(
                              pageTitle: "Pending Work",
                              typeId: "2",
                            ),
                          ),
                        );
                      },
                    ),
                    WorkCard(
                      title: "Ongoing Work",
                      color: const Color.fromARGB(255, 215, 245, 216),
                      imagePath: "assets/icons/suiticon.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkListPage(
                              pageTitle: "Ongoing Work",
                              typeId: "3",
                            ),
                          ),
                        );
                      },
                    ),
                    WorkCard(
                      title: "Completed Work",
                      color: const Color.fromARGB(255, 101, 148, 104),
                      imagePath: "assets/icons/suiticon.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkListPage(
                              pageTitle: "Completed Work",
                              typeId: "4",
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const WorkCategoryCard(),

              // const SizedBox(height: 20),
              // DashboardCard(
              //   title: "Work Category",
              //   onTap: () => Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (_) => const WorkCategoryPage()),
              //   ),
              //   child: SizedBox(
              //     height: 200,
              //     child: Row(
              //       children: [
              //         Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: const [
              //             LegendItem(color: Colors.green, text: "Test1 (24%)"),
              //             LegendItem(color: Colors.yellow, text: "Test2 (7%)"),
              //             LegendItem(color: Colors.red, text: "Test3 (12%)"),
              //             LegendItem(color: Colors.purple, text: "Test4 (17%)"),
              //             LegendItem(color: Colors.blue, text: "Test5 (37%)"),
              //           ],
              //         ),
              //         const SizedBox(width: 16),
              //         Expanded(
              //           child: Stack(
              //             alignment: Alignment.center,
              //             children: [
              //               PieChart(
              //                 PieChartData(
              //                   sectionsSpace: 2,
              //                   centerSpaceRadius: 40,
              //                   sections: [
              //                     PieChartSectionData(
              //                       value: 24,
              //                       color: Colors.green,
              //                       title: '24%',
              //                       titleStyle: TextStyle(
              //                         fontSize: 12,
              //                         color: Colors.white,
              //                       ),
              //                     ),
              //                     PieChartSectionData(
              //                       value: 7,
              //                       color: Colors.yellow,
              //                       title: '7%',
              //                       titleStyle: TextStyle(
              //                         fontSize: 12,
              //                         color: Colors.white,
              //                       ),
              //                     ),
              //                     PieChartSectionData(
              //                       value: 12,
              //                       color: Colors.red,
              //                       title: '12%',
              //                       titleStyle: TextStyle(
              //                         fontSize: 12,
              //                         color: Colors.white,
              //                       ),
              //                     ),
              //                     PieChartSectionData(
              //                       value: 17,
              //                       color: Colors.purple,
              //                       title: '17%',
              //                       titleStyle: TextStyle(
              //                         fontSize: 12,
              //                         color: Colors.white,
              //                       ),
              //                     ),
              //                     PieChartSectionData(
              //                       value: 37,
              //                       color: Colors.blue,
              //                       title: '37%',
              //                       titleStyle: TextStyle(
              //                         fontSize: 12,
              //                         color: Colors.white,
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //               const Text(
              //                 '816457',
              //                 style: TextStyle(
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold,
              //                   color: Color.fromARGB(255, 100, 98, 98),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              DashboardCard(
                title: "Expense/Income",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExpenseIncomePage()),
                ),
                child: SizedBox(
                  height: 240,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 25000,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      const days = [
                                        'Mon',
                                        'Tue',
                                        'Wed',
                                        'Thu',
                                        'Fri',
                                        'Sat',
                                        'Sun',
                                      ];
                                      if (value.toInt() >= 0 &&
                                          value.toInt() < days.length) {
                                        return Text(days[value.toInt()]);
                                      }
                                      return const Text('');
                                    },
                                    reservedSize: 32,
                                  ),
                                ),
                              ),
                              gridData: FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 20000,
                                      color: Colors.orange,
                                      width: 8,
                                    ),
                                    BarChartRodData(
                                      toY: 10000,
                                      color: Colors.purple,
                                      width: 8,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 18000,
                                      color: Colors.orange,
                                      width: 8,
                                    ),
                                    BarChartRodData(
                                      toY: 12000,
                                      color: Colors.purple,
                                      width: 8,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 2,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 15000,
                                      color: Colors.orange,
                                      width: 8,
                                    ),
                                    BarChartRodData(
                                      toY: 9000,
                                      color: Colors.purple,
                                      width: 8,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 3,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 22000,
                                      color: Colors.orange,
                                      width: 8,
                                    ),
                                    BarChartRodData(
                                      toY: 11000,
                                      color: Colors.purple,
                                      width: 8,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 4,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 21000,
                                      color: Colors.orange,
                                      width: 8,
                                    ),
                                    BarChartRodData(
                                      toY: 10000,
                                      color: Colors.purple,
                                      width: 8,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 5,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 17000,
                                      color: Colors.orange,
                                      width: 8,
                                    ),
                                    BarChartRodData(
                                      toY: 8000,
                                      color: Colors.purple,
                                      width: 8,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 6,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 23000,
                                      color: Colors.orange,
                                      width: 8,
                                    ),
                                    BarChartRodData(
                                      toY: 12000,
                                      color: Colors.purple,
                                      width: 8,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.circle,
                                  color: Colors.orange,
                                  size: 12,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Income",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "₹20,000",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: const [
                                Icon(
                                  Icons.circle,
                                  color: Colors.purple,
                                  size: 12,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Expense",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "₹10,000",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              DashboardCard(
                title: "Work Progress",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkProgressPage()),
                ),
                child: SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "Ongoing",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "Completed",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "Pending",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const weeks = ['W1', 'W2', 'W3', 'W4'];
                                      if (value >= 0 && value < weeks.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(weeks[value.toInt()]),
                                        );
                                      }
                                      return const Text('');
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text('${value.toInt()}%');
                                    },
                                    reservedSize: 35,
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: const Color(0xff37434d),
                                  width: 1,
                                ),
                              ),
                              minX: 0,
                              maxX: 3,
                              minY: 0,
                              maxY: 100,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 30),
                                    FlSpot(1, 45),
                                    FlSpot(2, 60),
                                    FlSpot(3, 40),
                                  ],
                                  isCurved: true,
                                  color: Colors.orange,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.orange.withOpacity(0.2),
                                  ),
                                ),
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 20),
                                    FlSpot(1, 45),
                                    FlSpot(2, 60),
                                    FlSpot(3, 85),
                                  ],
                                  isCurved: true,
                                  color: Colors.green,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.green.withOpacity(0.2),
                                  ),
                                ),
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 80),
                                    FlSpot(1, 55),
                                    FlSpot(2, 40),
                                    FlSpot(3, 15),
                                  ],
                                  isCurved: true,
                                  color: Colors.red,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.red.withOpacity(0.2),
                                  ),
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

              const SizedBox(height: 30),
            ],
          ),
        ),

      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color(0xFF2a86c9),
      //   onPressed: _refreshPage,
      //   child: const Icon(Icons.window_sharp, color: Colors.white),
      // ),

      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // bottomNavigationBar: BottomNavBar(
      //   selectedIndex: _selectedIndex,
      //   onItemTapped: _onItemTapped,
      // ),
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
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

