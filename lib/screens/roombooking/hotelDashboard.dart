import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart'; // Add this import
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/bottom_navigation_bar.dart'; // Add this import
import 'package:login2/screens/drawerScreen.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/minimalDashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class RoomDashboard extends StatefulWidget {
  const RoomDashboard({super.key});

  @override
  State<RoomDashboard> createState() => _RoomDashboardState();
}

class _RoomDashboardState extends State<RoomDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
   String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  String? NewleadDashboardPermission;
      String? adminCheckPermission;
  Map<String, double> _pieChartData = {
    'Available': 24,
    'Booked': 12,
    'Maintenance': 4,
  };
  List<Color> _pieChartColors = [
    const Color.fromARGB(255, 78, 180, 83),
    const Color.fromARGB(255, 230, 63, 51),
    const Color.fromARGB(255, 241, 174, 74),
  ];
  DateTime _selectedDate = DateTime.now();
  final Map<String, List<Map<String, dynamic>>> _dailyBookings = {
    '2024-01-15': [
      {'room': '101', 'guest': 'John Doe', 'status': 'Paid'},
      {'room': '203', 'guest': 'Jane Smith', 'status': 'Pending'},
    ],
    '2024-01-16': [
      {'room': '105', 'guest': 'Robert Brown', 'status': 'Paid'},
      {'room': '301', 'guest': 'Alice Johnson', 'status': 'Paid'},
      {'room': '208', 'guest': 'Michael Chen', 'status': 'Pending'},
    ],
    '2024-01-17': [
      {'room': '102', 'guest': 'Sarah Wilson', 'status': 'Paid'},
      {'room': '304', 'guest': 'David Lee', 'status': 'Paid'},
    ],
    '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}':
        [
      {'room': '103', 'guest': 'Emily Davis', 'status': 'Paid'},
      {'room': '205', 'guest': 'Thomas Clark', 'status': 'Pending'},
    ],
  };
  
  // Add variables for BottomNavigation
  String? token;
  String? name;
  String? userId;
  String? phoneCallLogPermission;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    _updatePieChartData();
    _loadUserData(); // Load user data for bottom navigation
  }

  Future<void> _loadUserData() async {
    token = await Common.getSharedPref("token");
    name = await Common.getSharedPref("name");
    userId = await Common.getSharedPref("userId");
    phoneCallLogPermission = await Common.getSharedPref("phoneCallLogPermission");
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
    setState(() {});
  }

  void _updatePieChartData() {
    setState(() {
      _pieChartData = {
        'Available': 24.0,
        'Booked': 12.0,
        'Maintenance': 4.0,
      };
    });
  }

  void _showBookingDetailsForDate(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final bookings = _dailyBookings[dateKey] ?? [];
    int checkInCount = bookings.length;
    int checkOutCount = _getCheckOutCount(dateKey);
    int bookedCount = bookings.where((b) => b['status'] == 'Paid').length;
    int unpaidCount = bookings.where((b) => b['status'] == 'Pending').length;
    int unavailableCount = _getUnavailableCount(dateKey);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Daily Booking Summary',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildRowCountCard(
                          title: 'Check-in',
                          count: checkInCount,
                          color: Colors.green,
                          icon: Icons.login_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildRowCountCard(
                          title: 'Check-out',
                          count: checkOutCount,
                          color: Colors.blue,
                          icon: Icons.logout_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRowCountCard(
                          title: 'Booked',
                          count: bookedCount,
                          color: Colors.purple,
                          icon: Icons.bookmark_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildRowCountCard(
                          title: 'Unpaid',
                          count: unpaidCount,
                          color: Colors.orange,
                          icon: Icons.money_off_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRowCountCard(
                          title: 'Unavailable',
                          count: unavailableCount,
                          color: Colors.red,
                          icon: Icons.block_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildRowCountCard(
                          title: 'Total',
                          count: bookings.length,
                          color: Colors.indigo,
                          icon: Icons.summarize_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowCountCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 15,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getCheckOutCount(String dateKey) {
    return 2;
  }

  int _getUnavailableCount(String dateKey) {
    return 1;
  }

  bool _hasBookings(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return _dailyBookings.containsKey(dateKey) &&
        _dailyBookings[dateKey]!.isNotEmpty;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: const Color.fromARGB(255, 22, 145, 216),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: const Color(0xFFF8FAFC),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
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
                                        builder: (context) => Dashboard(token)),
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
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: const Color.fromARGB(255, 22, 145, 216),
                  foregroundColor: Colors.white, // affects default icons
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  pinned: true,

                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Room Dashboard',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _updatePieChartData();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          final List<Map<String, dynamic>> kpiData = [
                            {
                              'title': 'New Booking',
                              'value': '1',
                              'icon': Icons.bookmark_add_rounded,
                              'color': const Color.fromARGB(255, 161, 42, 182),
                              'trend': '+12%',
                            },
                            {
                              'title': 'Check In',
                              'value': '7',
                              'icon': Icons.login_rounded,
                              'color': const Color.fromARGB(255, 241, 146, 2),
                              'trend': '+8%',
                            },
                            {
                              'title': 'Check Out',
                              'value': '7',
                              'icon': Icons.logout_rounded,
                              'color': const Color.fromARGB(255, 80, 185, 85),
                              'trend': '+15%',
                            },
                            {
                              'title': 'Cancelled',
                              'value': '0',
                              'icon': Icons.cancel_rounded,
                              'color': const Color.fromARGB(255, 214, 60, 49),
                              'trend': '-5%',
                            },
                          ];

                          return _buildKPICard(kpiData[index]);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildPieChartSection(),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        title: 'Floor Status',
                        subtitle: 'Current room availability',
                        child: Column(
                          children: [
                            _buildFloorStatus(
                                'First Floor', 10, 4, Colors.blue),
                            const SizedBox(height: 16),
                            _buildFloorStatus(
                                'Second Floor', 8, 6, Colors.green),
                            const SizedBox(height: 16),
                            _buildFloorStatus(
                                'Third Floor', 12, 9, Colors.orange),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        title: 'Recent Bookings',
                        subtitle: 'Tap cards for details',
                        child: Column(
                          children: [
                            _buildBookingCard(
                                name: 'Unnimaya',
                                phone: '7458963210',
                                status: 'Paid',
                                current: 'Checked In',
                                room: '101',
                                time: '2 hours ago',
                                color: Colors.green,
                                current_color: Colors.green),
                            const SizedBox(height: 12),
                            _buildBookingCard(
                                name: 'Athira',
                                phone: '9807654321',
                                status: 'Unpaid',
                                current: 'Checked In',
                                room: '205',
                                time: '4 hours ago',
                                color: Colors.orange,
                                current_color: Colors.green),
                            const SizedBox(height: 12),
                            _buildBookingCard(
                                name: 'Nita',
                                phone: '9090989898',
                                status: 'Unpaid',
                                current: 'Checked Out',
                                room: '312',
                                time: '6 hours ago',
                                color: Colors.red,
                                current_color: Colors.red),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        title: 'Current Month Calendar',
                        subtitle: 'Red dots indicate dates with bookings',
                        child: _buildMonthCalendar(currentMonth),
                      ),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChartSection() {
    final totalRooms =
        _pieChartData.values.fold(0.0, (sum, value) => sum + value);

    return _buildSectionCard(
      title: 'Room Status Overview',
      subtitle: 'Tap segments for details',
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              _showPieChartDetails();
            },
            child: Container(
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    painter: _RoomPieChartPainter(
                      data: _pieChartData,
                      colors: _pieChartColors,
                      total: totalRooms,
                    ),
                    size: const Size(200, 200),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        totalRooms.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Total Rooms',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Available', Colors.green,
                  _pieChartData['Available']!.toInt()),
              _buildLegendItem(
                  'Booked', Colors.red, _pieChartData['Booked']!.toInt()),
              _buildLegendItem('Maintenance', Colors.orange,
                  _pieChartData['Maintenance']!.toInt()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;
    final today = DateTime.now();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(month),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: Colors.blue.shade700),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.chevron_right, color: Colors.blue.shade700),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 7,
          itemBuilder: (context, index) {
            final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
            return Center(
              child: Text(
                weekdays[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: daysInMonth + firstWeekday - 1,
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) {
              return const SizedBox();
            }

            final day = index - firstWeekday + 2;
            final date = DateTime(month.year, month.month, day);
            final hasBookings = _hasBookings(date);
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;

            return GestureDetector(
              onTap:
                  hasBookings ? () => _showBookingDetailsForDate(date) : null,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isToday ? Colors.blue.shade200 : Colors.grey.shade200,
                    width: isToday ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isToday ? Colors.blue : Colors.grey.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (hasBookings)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Today indicator
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Today',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Booking indicator
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Bookings',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPieChartDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Room Status Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusDetailItem(
                'Available', _pieChartData['Available']!, Colors.green),
            _buildStatusDetailItem(
                'Booked', _pieChartData['Booked']!, Colors.red),
            _buildStatusDetailItem(
                'Maintenance', _pieChartData['Maintenance']!, Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Total: ${_pieChartData.values.fold(0.0, (sum, value) => sum + value).toInt()} rooms',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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

  Widget _buildStatusDetailItem(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${value.toInt()} rooms',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            data['color'].withOpacity(0.9),
            data['color'].withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: data['color'].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data['icon'],
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['trend'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['value'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['title'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildFloorStatus(
      String floor, int totalRooms, int occupied, Color color) {
    final available = totalRooms - occupied;
    final occupancyRate = occupied / totalRooms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              floor,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              '${(occupancyRate * 100).toInt()}% occupied',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 8,
              width: MediaQuery.of(context).size.width * occupancyRate,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$occupied Occupied',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$available Available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingCard(
      {required String name,
      required String phone,
      required String status,
      required String current,
      required String room,
      required String time,
      required Color color,
      required Color current_color}) {
    return GestureDetector(
      onTap: () {
        _showBookingDetailsPopup(name, phone, status, room, time, color);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getInitials(name),
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: current_color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: current_color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          current,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: current_color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
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

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.length > 1
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  void _showBookingDetailsPopup(
    String name,
    String phone,
    String status,
    String room,
    String time,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _getInitials(name),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: color.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Booking Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              icon: Icons.phone_rounded,
                              title: 'Phone Number',
                              value: phone,
                              iconColor: Colors.blue,
                              isFirst: true,
                            ),
                            _buildDetailRow(
                              icon: Icons.meeting_room_rounded,
                              title: 'Room Number',
                              value: room,
                              iconColor: Colors.green,
                            ),
                            _buildDetailRow(
                              icon: Icons.access_time_rounded,
                              title: 'Check-in Time',
                              value: time,
                              iconColor: Colors.orange,
                            ),
                            _buildDetailRow(
                              icon: Icons.calendar_month_rounded,
                              title: 'Booking Date',
                              value: DateFormat('MMM dd, yyyy')
                                  .format(DateTime.now()),
                              iconColor: Colors.purple,
                            ),
                            _buildDetailRow(
                              icon: Icons.receipt_rounded,
                              title: 'Booking ID',
                              value:
                                  'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              iconColor: Colors.indigo,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Additional Notes',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Guest has requested early check-in at 12:00 PM. Special requests: Extra towels and non-smoking room.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Check-in',
                          style: TextStyle(color: Colors.white),
                        ),
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

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
        borderRadius: isFirst
            ? const BorderRadius.vertical(top: Radius.circular(12))
            : isLast
                ? const BorderRadius.vertical(bottom: Radius.circular(12))
                : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomPieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;
  final double total;
  _RoomPieChartPainter({
    required this.data,
    required this.colors,
    required this.total,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final double startAngle = -90 * (3.141592653589793 / 180);
    double totalValue = 0;
    data.forEach((key, value) {
      totalValue += value;
    });
    if (totalValue == 0) return;
    double startRadian = startAngle;
    int colorIndex = 0;
    data.forEach((key, value) {
      final sweepRadian = (value / totalValue) * 2 * 3.141592653589793;
      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startRadian, sweepRadian, true, paint);
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(rect, startRadian, sweepRadian, true, borderPaint);

      startRadian += sweepRadian;
      colorIndex++;
    });
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.6, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}