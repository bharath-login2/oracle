import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/roomManagement/roomDashboardModel.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/bottom_navigation_bar.dart';
import 'package:login2/screens/drawerScreen.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/minimalDashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/roombooking/bookingListPage.dart';
import 'package:login2/service/service.dart';

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
  int _calendarMonthOffset = 0;
  Map<String, double> _pieChartData = {
    'Available': 0,
    'Booked': 0,
    'Not Available': 0,
  };

  final List<Color> _pieChartColors = [
    const Color.fromARGB(255, 78, 180, 83),
    const Color.fromARGB(255, 230, 63, 51),
    const Color.fromARGB(255, 241, 174, 74),
  ];

  final DateTime _selectedDate = DateTime.now();
  RoomDashboardResponse? _dashboardData;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String? token;
  String? name;
  String? userId;
  String? phoneCallLogPermission;
  final ScrollController _scrollController = ScrollController();
  
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
    _loadUserData();
    _fetchDashboardData();
  }

  void _navigateToNewBookings() {
    print('Navigate to New Bookings list');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingListPage(status: "New")));
  }

  void _navigateToCheckIns() {
    print('Navigate to Check-ins list');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingListPage(status: "Checkin")));
  }

  void _navigateToCheckOuts() {
    print('Navigate to Check-outs list');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingListPage(status: "Checkout")));
  }

  void _navigateToCancelled() {
    print('Navigate to Cancelled bookings list');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingListPage(status: "Cancelled")));
  }

  Future<void> _loadUserData() async {
    token = await Common.getSharedPref("token");
    name = await Common.getSharedPref("name");
    userId = await Common.getSharedPref("userId");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard") as String?;
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    NewleadDashboardPermission =
        await Common.getSharedPref("NewleadDashboardPermission");
    adminCheckPermission = await Common.getSharedPref("adminCheckPermission");
    setState(() {});
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await HttpService.getRoomDashboard();

      if (response != null && response.status == true) {
        _dashboardData = response;
        _updatePieChartDataFromApi();
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = response?.message ?? 'Failed to load dashboard data';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error: $e';
      });
      print('Error fetching dashboard data: $e');
    }
  }

  void _updatePieChartDataFromApi() {
    if (_dashboardData != null) {
      final overview = _dashboardData!.data.roomStatusOverview;
      setState(() {
        _pieChartData = {
          'Available': overview.availableRoomsToday.toDouble(),
          'Booked': overview.bookedRooms.toDouble(),
          'Not Available': overview.notAvailableRooms.toDouble(),
        };
      });
    }
  }

  void _showBookingDetailsForDate(DateTime date) {
    if (_dashboardData == null) return;
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final bookings = _getBookingsForDate(dateKey);
    final calendar = _dashboardData!.data.calendar;
    int checkInCount = int.tryParse(calendar.checkInCount) ?? 0;
    int checkOutCount = int.tryParse(calendar.checkoutCount) ?? 0;
    int bookedCount = int.tryParse(calendar.bookedCount) ?? 0;
    int cancelledCount = int.tryParse(calendar.cancelledCount) ?? 0;
    int unavailableCount =
        _dashboardData!.data.roomStatusOverview.notAvailableRooms;
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
                          title: 'Cancelled',
                          count: cancelledCount,
                          color: Colors.orange,
                          icon: Icons.cancel_rounded,
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
                          title: 'Total Bookings',
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

  List<RecentBooking> _getBookingsForDate(String dateKey) {
    if (_dashboardData == null) return [];
    return _dashboardData!.data.recentBookingList;
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

  bool _hasBookings(DateTime date) {
    if (_dashboardData == null ||
        _dashboardData!.data.recentBookingList.isEmpty) {
      return false;
    }
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return _dashboardData!.data.recentBookingList.any((booking) {
      try {
        final checkInDate = DateFormat('dd-MM-yyyy').parse(booking.checkInDate);
        return DateFormat('yyyy-MM-dd').format(checkInDate) == dateKey;
      } catch (e) {
        return false;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
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
        endDrawer: DraweScreen(token ?? ''),
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
            child: _isLoading
                ? _buildLoadingView()
                : _hasError
                    ? _buildErrorView()
                    : _buildDashboardView(currentMonth),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color.fromARGB(255, 22, 145, 216),
          ),
          SizedBox(height: 20),
          Text(
            'Loading dashboard...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          SizedBox(height: 20),
          Text(
            'Failed to load dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: _fetchDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 22, 145, 216),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView(DateTime currentMonth) {
    final dashboardCount = _dashboardData!.data.dashboardCount;
    final floorStatusList = _dashboardData!.data.floorStatus;

    return Column(
      children: [
        AppBar(
          backgroundColor: const Color.fromARGB(255, 22, 145, 216),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 4,
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
              onPressed: _fetchDashboardData,
            ),
            const SizedBox(width: 8),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        'value': dashboardCount.newBookingCount.toString(),
                        'icon': Icons.bookmark_add_rounded,
                        'color': const Color.fromARGB(255, 161, 42, 182),
                        'trend': '+0%',
                        'onTap': _navigateToNewBookings,
                      },
                      {
                        'title': 'Check In',
                        'value': dashboardCount.checkinCount.toString(),
                        'icon': Icons.login_rounded,
                        'color': const Color.fromARGB(255, 241, 146, 2),
                        'trend': '+0%',
                        'onTap': _navigateToCheckIns,
                      },
                      {
                        'title': 'Check Out',
                        'value': dashboardCount.checkoutCount.toString(),
                        'icon': Icons.logout_rounded,
                        'color': const Color.fromARGB(255, 80, 185, 85),
                        'trend': '+0%',
                        'onTap': _navigateToCheckOuts,
                      },
                      {
                        'title': 'Cancelled',
                        'value': dashboardCount.cancelledCount.toString(),
                        'icon': Icons.cancel_rounded,
                        'color': const Color.fromARGB(255, 214, 60, 49),
                        'trend': '+0%',
                        'onTap': _navigateToCancelled,
                      },
                    ];
                    return _buildKPICard(kpiData[index]);
                  },
                ),
                const SizedBox(height: 24),
                _buildPieChartSection(),
                const SizedBox(height: 24),
                _buildFloorStatusSection(floorStatusList),
                const SizedBox(height: 24),
                _buildRecentBookingsSection(),
                const SizedBox(height: 24),
                _buildCalendarSection(currentMonth),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildPieChartSection() {
    final totalRooms =
        _pieChartData.values.fold(0.0, (sum, value) => sum + value);

    return _buildSectionCard(
      title: 'Room Status Overview',
      subtitle: 'Real-time room availability',
      child: Column(
        children: [
          GestureDetector(
            onTap: _showPieChartDetails,
            child: SizedBox(
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
              _buildLegendItem('Available', _pieChartColors[0],
                  _pieChartData['Available']!.toInt()),
              _buildLegendItem('Booked', _pieChartColors[1],
                  _pieChartData['Booked']!.toInt()),
              _buildLegendItem('Not Available', _pieChartColors[2],
                  _pieChartData['Not Available']!.toInt()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloorStatusSection(List<FloorStatus> floorStatusList) {
    final filteredFloors = floorStatusList
        .where((floor) => (int.tryParse(floor.totalRooms) ?? 0) > 0)
        .toList();
    bool isExpanded = false;
    final maxInitialItems = 3;
    return StatefulBuilder(
      builder: (context, setState) {
        final floorsToShow = isExpanded
            ? filteredFloors
            : filteredFloors.take(maxInitialItems).toList();
        return _buildSectionCard(
          title: 'Floor Status',
          subtitle: 'Current room availability by floor',
          child: Column(
            children: [
              if (filteredFloors.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No floor data available',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                Column(
                  children: [
                    ...floorsToShow.map((floor) {
                      final totalRooms = int.tryParse(floor.totalRooms) ?? 0;
                      final bookedRooms = int.tryParse(floor.bookedRooms) ?? 0;
                      final availableRooms = totalRooms - bookedRooms;
                      final occupancyRate =
                          totalRooms > 0 ? bookedRooms / totalRooms : 0.0;
                      Color floorColor;
                      if (occupancyRate < 0.3) {
                        floorColor = Colors.green;
                      } else if (occupancyRate < 0.7) {
                        floorColor = Colors.orange;
                      } else {
                        floorColor = Colors.red;
                      }
                      return Column(
                        children: [
                          _buildFloorStatusItem(
                            floor.floorType,
                            totalRooms,
                            bookedRooms,
                            availableRooms,
                            occupancyRate,
                            floorColor,
                          ),
                          if (filteredFloors.indexOf(floor) <
                              floorsToShow.length - 1)
                            const SizedBox(height: 16),
                        ],
                      );
                    }),
                    if (filteredFloors.length > maxInitialItems)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.shade100,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isExpanded ? 'Show Less' : 'Show More',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                              ],
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

  Widget _buildFloorStatusItem(
    String floorType,
    int totalRooms,
    int occupied,
    int available,
    double occupancyRate,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                floorType,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(occupancyRate * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
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
            SizedBox(
              height: 8,
              width: double.infinity,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: occupancyRate.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
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
            Text(
              'Total: $totalRooms',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentBookingsSection() {
    final recentBookings = _dashboardData!.data.recentBookingList;
    bool isExpanded = false;
    final maxInitialItems = 3;

    return StatefulBuilder(
      builder: (context, setState) {
        final bookingsToShow = isExpanded
            ? recentBookings
            : recentBookings.take(maxInitialItems).toList();

        return _buildSectionCard(
          title: 'Recent Bookings',
          subtitle: 'Latest ${recentBookings.length} bookings',
          child: Column(
            children: [
              if (recentBookings.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No recent bookings',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                Column(
                  children: [
                    ...bookingsToShow.map((booking) {
                      // Determine status based on check-in and check-out dates
                      final today = DateTime.now();
                      DateTime checkInDate;
                      DateTime checkOutDate;

                      try {
                        checkInDate =
                            DateFormat('dd-MM-yyyy').parse(booking.checkInDate);
                      } catch (e) {
                        checkInDate = today;
                      }

                      try {
                        checkOutDate = DateFormat('dd-MM-yyyy')
                            .parse(booking.checkOutDate);
                      } catch (e) {
                        // If no check-out date or invalid, assume it's a future date
                        checkOutDate = checkInDate.add(const Duration(days: 1));
                      }

                      Color statusColor;
                      String status;
                      Color currentColor;
                      String currentStatus;

                      // Determine current status (Active/Completed/Scheduled)
                      if (checkInDate.isAfter(today)) {
                        // Future check-in
                        currentStatus = 'Scheduled';
                        currentColor = Colors.blue;

                        // Calculate days until check-in
                        final daysUntilCheckIn =
                            checkInDate.difference(today).inDays;
                        if (daysUntilCheckIn == 0) {
                          status = 'Today';
                          statusColor = Colors.orange;
                        } else if (daysUntilCheckIn == 1) {
                          status = 'Tomorrow';
                          statusColor = Colors.blue;
                        } else {
                          status = '${daysUntilCheckIn}d left';
                          statusColor = Colors.blue;
                        }
                      } else if (checkInDate.isBefore(today) &&
                          checkOutDate.isAfter(today)) {
                        // Currently checked in
                        currentStatus = 'Active';
                        currentColor = Colors.green;

                        // Calculate days since check-in
                        final daysSinceCheckIn =
                            today.difference(checkInDate).inDays;
                        if (daysSinceCheckIn == 0) {
                          status = 'Checked In Today';
                          statusColor = Colors.green;
                        } else {
                          status = 'Day $daysSinceCheckIn';
                          statusColor = Colors.green;
                        }
                      } else if (checkOutDate.isBefore(today) ||
                          checkOutDate.isAtSameMomentAs(today)) {
                        // Checked out
                        currentStatus = 'Completed';
                        currentColor = Colors.grey;

                        // Calculate days since check-out
                        final daysSinceCheckOut =
                            today.difference(checkOutDate).inDays;
                        if (daysSinceCheckOut == 0) {
                          status = 'Checked Out Today';
                          statusColor = Colors.red;
                        } else if (daysSinceCheckOut == 1) {
                          status = 'Yesterday';
                          statusColor = Colors.red;
                        } else {
                          status = '${daysSinceCheckOut}d ago';
                          statusColor = Colors.red;
                        }
                      } else {
                        // Default case
                        currentStatus = 'Active';
                        currentColor = Colors.green;
                        status = 'Ongoing';
                        statusColor = Colors.green;
                      }

                      return Column(
                        children: [
                          _buildBookingCard(
                            booking: booking,
                            guestName: booking.guestName,
                            status: status,
                            statusColor: statusColor,
                            currentStatus: currentStatus,
                            currentColor: currentColor,
                          ),
                          if (recentBookings.indexOf(booking) <
                              bookingsToShow.length - 1)
                            const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),

                    // Show More/Less button
                    if (recentBookings.length > maxInitialItems)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.shade100,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isExpanded ? 'Show Less' : 'Show More',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                              ],
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

  Widget _buildBookingCard({
    required RecentBooking booking,
    required String guestName,
    required String status,
    required Color statusColor,
    required String currentStatus,
    required Color currentColor,
  }) {
    // Get initials from guest name (fallback to booking ID if no name)
    final displayName = guestName.isNotEmpty ? guestName : booking.bookingId;
    final initials = _getInitials(displayName);

    return GestureDetector(
      onTap: () => _showBookingDetailsPopup(booking, statusColor, currentColor),
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
            // Avatar with guest initials
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
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
                  // Guest Name
                  Text(
                    guestName.isNotEmpty ? guestName : 'No Name Provided',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),

                  // Booking ID
                  Text(
                    'ID: ${booking.bookingId}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Date info
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Check-in: ${booking.checkInDate}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (booking.checkOutDate.isNotEmpty)
                        Expanded(
                          child: Text(
                            'Out: ${booking.checkOutDate}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Status chips in a row
                  Row(
                    children: [
                      // Current Status Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: currentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: currentColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          currentStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: currentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Status Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
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
    if (name.isEmpty) return '??';

    List<String> names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.length > 1
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  void _showBookingDetailsPopup(
    RecentBooking booking,
    Color statusColor,
    Color currentColor,
  ) {
    // Calculate status for the popup (similar logic as above)
    final today = DateTime.now();
    DateTime checkInDate;
    DateTime checkOutDate;

    try {
      checkInDate = DateFormat('dd-MM-yyyy').parse(booking.checkInDate);
    } catch (e) {
      checkInDate = today;
    }

    try {
      checkOutDate = DateFormat('dd-MM-yyyy').parse(booking.checkOutDate);
    } catch (e) {
      checkOutDate = checkInDate.add(const Duration(days: 1));
    }

    String currentStatus;
    Color statusColorForPopup;

    if (checkInDate.isAfter(today)) {
      currentStatus = 'Scheduled';
      statusColorForPopup = Colors.blue;
    } else if (checkInDate.isBefore(today) && checkOutDate.isAfter(today)) {
      currentStatus = 'Currently Checked In';
      statusColorForPopup = Colors.green;
    } else if (checkOutDate.isBefore(today) ||
        checkOutDate.isAtSameMomentAs(today)) {
      currentStatus = 'Checked Out';
      statusColorForPopup = Colors.red;
    } else {
      currentStatus = 'Active';
      statusColorForPopup = Colors.green;
    }

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
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: statusColorForPopup.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColorForPopup.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColorForPopup.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              currentStatus,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColorForPopup,
                              ),
                            ),
                          ),
                        ],
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

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Guest Info Section
                      _buildDetailSection(
                        title: 'Guest Information',
                        icon: Icons.person,
                        iconColor: Colors.purple,
                        children: [
                          _buildDetailItem(
                            label: 'Guest Name',
                            value: booking.guestName.isNotEmpty
                                ? booking.guestName
                                : 'Not Provided',
                            valueStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          _buildDetailItem(
                            label: 'Phone Number',
                            value: booking.contactNo.isNotEmpty
                                ? booking.contactNo
                                : 'Not Provided',
                            icon: Icons.phone,
                          ),
                          _buildDetailItem(
                            label: 'Booking ID',
                            value: booking.bookingId,
                            icon: Icons.confirmation_number,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Booking Dates Section
                      _buildDetailSection(
                        title: 'Booking Dates',
                        icon: Icons.calendar_month,
                        iconColor: Colors.blue,
                        children: [
                          _buildDetailItem(
                            label: 'Booking Date',
                            value: booking.bookingDate,
                            icon: Icons.date_range,
                          ),
                          _buildDetailItem(
                            label: 'Check-in Date',
                            value: booking.checkInDate,
                            icon: Icons.login,
                          ),
                          _buildDetailItem(
                            label: 'Check-out Date',
                            value: booking.checkOutDate.isNotEmpty
                                ? booking.checkOutDate
                                : 'Not specified',
                            icon: Icons.logout,
                          ),
                          _buildDetailItem(
                            label: 'Duration',
                            value: _calculateDuration(
                                booking.checkInDate, booking.checkOutDate),
                            icon: Icons.timer,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Room Information Section
                      _buildDetailSection(
                        title: 'Room Information',
                        icon: Icons.room_service,
                        iconColor: Colors.green,
                        children: [
                          _buildDetailItem(
                            label: 'Room Numbers',
                            value: booking.roomNumbers,
                            icon: Icons.meeting_room,
                            valueStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      // Status Timeline Section
                      const SizedBox(height: 20),
                      _buildDetailSection(
                        title: 'Booking Timeline',
                        icon: Icons.timeline,
                        iconColor: Colors.orange,
                        children: [
                          _buildTimelineItem(
                            date: booking.bookingDate,
                            label: 'Booked',
                            isCompleted: true,
                          ),
                          _buildTimelineItem(
                            date: booking.checkInDate,
                            label: 'Check-in',
                            isCompleted: checkInDate.isBefore(today) ||
                                checkInDate.isAtSameMomentAs(today),
                            isCurrent: checkInDate.isBefore(today) &&
                                checkOutDate.isAfter(today),
                          ),
                          _buildTimelineItem(
                            date: booking.checkOutDate.isNotEmpty
                                ? booking.checkOutDate
                                : 'Not set',
                            label: 'Check-out',
                            isCompleted: checkOutDate.isBefore(today),
                            isCurrent: checkOutDate.isAtSameMomentAs(today),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Action Buttons
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
                          // Add check-in/check-out logic here based on current status
                          if (currentStatus == 'Scheduled') {
                            // Check-in logic
                          } else if (currentStatus == 'Currently Checked In') {
                            // Check-out logic
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              currentStatus == 'Currently Checked In'
                                  ? Colors.orange
                                  : Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          currentStatus == 'Currently Checked In'
                              ? 'Check-out'
                              : 'Check-in',
                          style: const TextStyle(color: Colors.white),
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

// Helper method to build detail sections
  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

// Helper method to build detail items
  Widget _buildDetailItem({
    required String label,
    required String value,
    IconData? icon,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: Icon(
                icon,
                color: Colors.grey.shade500,
                size: 16,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: valueStyle ??
                      TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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

// Helper method to build timeline items
  Widget _buildTimelineItem({
    required String date,
    required String label,
    bool isCompleted = false,
    bool isCurrent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent
                  ? Colors.orange
                  : isCompleted
                      ? Colors.green
                      : Colors.grey.shade300,
              border: Border.all(
                color: isCurrent
                    ? Colors.orange.shade400
                    : isCompleted
                        ? Colors.green.shade400
                        : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCurrent ? Colors.orange : Colors.grey.shade800,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Helper method to calculate duration between dates
  String _calculateDuration(String checkInDate, String checkOutDate) {
    try {
      final checkIn = DateFormat('dd-MM-yyyy').parse(checkInDate);
      final checkOut = checkOutDate.isNotEmpty
          ? DateFormat('dd-MM-yyyy').parse(checkOutDate)
          : DateTime.now();

      final difference = checkOut.difference(checkIn).inDays;

      if (difference == 0) {
        return 'Same day';
      } else if (difference == 1) {
        return '1 day';
      } else {
        return '$difference days';
      }
    } catch (e) {
      return 'Not specified';
    }
  }

  String _getInitialsFromBookingId(String bookingId) {
    if (bookingId.length >= 4) {
      return bookingId.substring(bookingId.length - 4).toUpperCase();
    }
    return bookingId.toUpperCase();
  }

  Widget _buildCalendarSection(DateTime currentMonth) {
    final displayMonth = DateTime(
        currentMonth.year, currentMonth.month + _calendarMonthOffset, 1);

    return _buildSectionCard(
      title: 'Calendar',
      subtitle: 'Navigate months to view bookings',
      child: _buildMonthCalendar(displayMonth),
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
              IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.blue.shade700),
                onPressed: () {
                  setState(() {
                    _calendarMonthOffset--;
                  });
                },
                tooltip: 'Previous month',
              ),
              Column(
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(month),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    _calendarMonthOffset == 0 ? '(Current Month)' : '',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: Colors.blue.shade700),
                onPressed: () {
                  setState(() {
                    _calendarMonthOffset++;
                  });
                },
                tooltip: 'Next month',
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
            return Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
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
            final isCurrentMonth = _calendarMonthOffset == 0;

            return GestureDetector(
              onTap:
                  hasBookings ? () => _showBookingDetailsForDate(date) : null,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isToday
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isToday ? Colors.blue : Colors.grey.shade200,
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
                          color: isToday
                              ? Colors.blue
                              : !isCurrentMonth
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (hasBookings)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 2,
                                spreadRadius: 1,
                              ),
                            ],
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
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
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
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Has Bookings',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_calendarMonthOffset != 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _calendarMonthOffset = 0;
                });
              },
              child: Text(
                'Back to Current Month',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                ),
              ),
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
                'Available', _pieChartData['Available']!, _pieChartColors[0]),
            _buildStatusDetailItem(
                'Booked', _pieChartData['Booked']!, _pieChartColors[1]),
            _buildStatusDetailItem('Not Available',
                _pieChartData['Not Available']!, _pieChartColors[2]),
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
    return GestureDetector(
      onTap: () {
        if (data['onTap'] != null) {
          (data['onTap'] as VoidCallback)();
        }
      },
      child: Container(
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