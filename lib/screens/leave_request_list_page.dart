import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/pendingListLeaveModel.dart';
import 'package:login2/models/lead_management/approvedListLeaveModel.dart';
import 'package:login2/service/service.dart';
import 'package:login2/core/common.dart';
import 'package:login2/screens/leadManagement/StaffCalendarPage.dart';

class LeaveRequestListPage extends StatefulWidget {
  const LeaveRequestListPage({super.key});

  @override
  State<LeaveRequestListPage> createState() => _LeaveRequestListPageState();
}

class _LeaveRequestListPageState extends State<LeaveRequestListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<PendingLeaveData> _pendingLeaves = [];
  List<ApprovedLeaveData> _approvedLeaves = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _canApprove = false;
  bool _canReject = false;
  bool _canEdit = false;
  bool _canDelete = false;

  // Filter variables
  String? _selectedLeaveType;
  DateTime? _fromDate;
  DateTime? _toDate;

  final List<String> _leaveTypeFilters = [
    'Casual Leave',
    'Sick Leave',
    'Paid Leave',
    'Unpaid Leave',
    // 'Paternity Leave',
    // 'Loss of Pay (LOP)',
  ];

  // Color palette
  static const Color primaryBlue = Color(0xFF2a86c9);
  static const Color secondaryBlue = Color(0xFF4A9FE0);
  static const Color lightBlue = Color(0xFFE8F1FA);
  static const Color softOrange = Color(0xFFFFB74D);
  static const Color softGreen = Color(0xFF4CAF50);
  static const Color softRed = Color(0xFFF44336);
  static const Color lightPurple = Color(0xFF9C27B0);
  static const Color softTeal = Color(0xFF009688);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF757575);

  String _normalizeLeaveType(String? type) {
    if (type == null) return _leaveTypeFilters[0];
    String normalized = type.trim();
    if (_leaveTypeFilters.contains(normalized)) return normalized;

    // Case-insensitive check
    for (var f in _leaveTypeFilters) {
      if (f.toLowerCase() == normalized.toLowerCase()) return f;
      if (f.toLowerCase().startsWith(normalized.toLowerCase())) return f;
    }

    // Handle short codes if any
    if (normalized.toLowerCase() == 'casual') return 'Casual Leave';
    if (normalized.toLowerCase() == 'sick') return 'Sick Leave';
    if (normalized.toLowerCase() == 'earned') return 'Earned Leave';

    return _leaveTypeFilters[0];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchPendingLeaves(),
      _fetchApprovedLeaves(),
      _fetchPermissions(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchPermissions() async {
    try {
      final canApprove =
          await Common.getSharedPref("addApproveLeavePermission");
      final canReject =
          await Common.getSharedPref("rejectRequestLeavePermission");
      final canEdit = await Common.getSharedPref("editLeaveRequestPermission");
      final canDelete =
          await Common.getSharedPref("deleteLeaveRequestPermission");

      setState(() {
        _canApprove = canApprove?.toString() == "true";
        _canReject = canReject?.toString() == "true";
        _canEdit = canEdit?.toString() == "true";
        _canDelete = canDelete?.toString() == "true";
      });
    } catch (e) {
      debugPrint("Error fetching permissions from sharedPref: $e");
    }
  }

  Future<void> _fetchPendingLeaves() async {
    final data = await HttpService.pendingLeaveList(
      fromDate: _fromDate != null
          ? DateFormat('dd-MM-yyyy').format(_fromDate!)
          : null,
      toDate:
          _toDate != null ? DateFormat('dd-MM-yyyy').format(_toDate!) : null,
      leaveType: _selectedLeaveType,
      search: _searchQuery,
    );
    if (data != null) {
      setState(() {
        _pendingLeaves = data.data;
      });
    }
  }

  Future<void> _fetchApprovedLeaves() async {
    final data = await HttpService.approvedLeaveList(
      fromDate: _fromDate != null
          ? DateFormat('dd-MM-yyyy').format(_fromDate!)
          : null,
      toDate:
          _toDate != null ? DateFormat('dd-MM-yyyy').format(_toDate!) : null,
      leaveType: _selectedLeaveType,
      search: _searchQuery,
    );
    if (data != null) {
      setState(() {
        _approvedLeaves = data.data;
      });
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filter Leaves",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: darkGrey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Leave Type",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedLeaveType,
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Select Leave Type",
                                hintStyle: const TextStyle(color: darkGrey),
                                prefixIcon: const Icon(Icons.category_outlined,
                                    color: primaryBlue),
                              ),
                              items: _leaveTypeFilters
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) =>
                                  setSheetState(() => _selectedLeaveType = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Date Range",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _fromDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(
                                              primary: primaryBlue,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null)
                                      setSheetState(() => _fromDate = picked);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16, color: primaryBlue),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _fromDate == null
                                                ? "From Date"
                                                : DateFormat('dd MMM yyyy')
                                                    .format(_fromDate!),
                                            style: TextStyle(
                                              color: _fromDate == null
                                                  ? darkGrey
                                                  : Colors.black,
                                              fontWeight: _fromDate == null
                                                  ? FontWeight.normal
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _toDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(
                                              primary: primaryBlue,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null)
                                      setSheetState(() => _toDate = picked);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16, color: primaryBlue),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _toDate == null
                                                ? "To Date"
                                                : DateFormat('dd MMM yyyy')
                                                    .format(_toDate!),
                                            style: TextStyle(
                                              color: _toDate == null
                                                  ? darkGrey
                                                  : Colors.black,
                                              fontWeight: _toDate == null
                                                  ? FontWeight.normal
                                                  : FontWeight.w600,
                                            ),
                                          ),
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
                    ),
                    const SizedBox(height: 24),
                    if (_selectedLeaveType != null ||
                        _fromDate != null ||
                        _toDate != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: lightBlue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextButton.icon(
                                onPressed: () {
                                  setSheetState(() {
                                    _selectedLeaveType = null;
                                    _fromDate = null;
                                    _toDate = null;
                                  });
                                },
                                icon: const Icon(Icons.refresh,
                                    size: 16, color: primaryBlue),
                                label: const Text(
                                  "Reset All Filters",
                                  style: TextStyle(color: primaryBlue),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _loadData();
                        },
                        child: const Text(
                          "Apply Filters",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text(
          'Leave Requests',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 2,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadData,
              tooltip: 'Refresh',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              onPressed: _openFilterSheet,
              tooltip: 'Filter',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: mediumGrey.withOpacity(0.5)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                    },
                    onSubmitted: (_) => _loadData(),
                    decoration: InputDecoration(
                      hintText: 'Search by staff name...',
                      hintStyle: const TextStyle(color: darkGrey),
                      prefixIcon: const Icon(Icons.search, color: primaryBlue),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  size: 20, color: darkGrey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _loadData();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: primaryBlue,
                    unselectedLabelColor: darkGrey,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: softOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.pending_actions,
                                    size: 18, color: softOrange),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Pending",
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: softOrange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${_pendingLeaves.length}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: softGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.check_circle_outline,
                                    size: 18, color: softGreen),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Recent",
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: softGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${_approvedLeaves.length}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
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
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabList(_pendingLeaves, true),
                _buildTabList(_approvedLeaves, false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _openApplyLeaveDialog(),
          backgroundColor: primaryBlue,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Apply Leave",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildTabList(List<dynamic> list, bool isPending) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              "Loading leave requests...",
              style: TextStyle(color: darkGrey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPending ? Icons.pending_outlined : Icons.event_available,
                size: 60,
                color: primaryBlue.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPending ? "No pending requests" : "No approved requests",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Leave requests will appear here",
              style: TextStyle(
                fontSize: 14,
                color: darkGrey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return _buildLeaveCard(item, isPending);
        },
      ),
    );
  }

  Widget _buildLeaveCard(dynamic item, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDetails(item),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryBlue,
                              secondaryBlue,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 28,
                          child: Text(
                            item.staffName?[0].toUpperCase() ?? 'S',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
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
                              item.staffName ?? 'Staff Name',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Row(
                            //   children: [
                            //     Container(
                            //       padding: const EdgeInsets.all(4),
                            //       decoration: BoxDecoration(
                            //         color: lightBlue,
                            //         borderRadius: BorderRadius.circular(6),
                            //       ),
                            //       child: const Icon(Icons.calendar_today,
                            //           size: 12, color: primaryBlue),
                            //     ),
                            //     const SizedBox(width: 6),
                            //     Expanded(
                            //       child: Text(
                            //         'Applied: ${item.createdAt ?? 'N/A'}',
                            //         style: TextStyle(
                            //           color: darkGrey,
                            //           fontSize: 13,
                            //         ),
                            //         overflow: TextOverflow.ellipsis,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: softOrange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(Icons.access_time,
                                      size: 12, color: softOrange),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Day: ${item.dayType ?? 'Full Day'}',
                                  style: TextStyle(
                                    color: darkGrey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          _buildStatusChip(item.status ?? 'Pending'),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: lightBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert,
                                  size: 20, color: primaryBlue),
                              onSelected: (val) {
                                if (val == 'approve') _showApproveDialog(item);
                                if (val == 'reject') _confirmReject(item);
                                if (val == 'edit')
                                  _openApplyLeaveDialog(item: item);
                                if (val == 'delete') _confirmDelete(item);
                                if (val == 'details') _showDetails(item);
                                if (val == 'attendance') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StaffCalendarPage(
                                        staffId: item.userId,
                                        selectedDate: DateTime.now(),
                                        staffName: item.staffName,
                                      ),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'details',
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility_outlined,
                                          size: 18, color: primaryBlue),
                                      SizedBox(width: 8),
                                      Text("View Details"),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'attendance',
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_month_outlined,
                                          size: 18, color: primaryBlue),
                                      SizedBox(width: 8),
                                      Text("View Attendance"),
                                    ],
                                  ),
                                ),
                                if (isPending && _canApprove)
                                  const PopupMenuItem(
                                    value: 'approve',
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle_outline,
                                            size: 18, color: softGreen),
                                        SizedBox(width: 8),
                                        Text("Approve"),
                                      ],
                                    ),
                                  ),
                                if (isPending && _canReject)
                                  const PopupMenuItem(
                                    value: 'reject',
                                    child: Row(
                                      children: [
                                        Icon(Icons.cancel_outlined,
                                            size: 18, color: softRed),
                                        SizedBox(width: 8),
                                        Text("Reject"),
                                      ],
                                    ),
                                  ),
                                if (isPending && _canEdit)
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined,
                                            size: 18, color: softOrange),
                                        SizedBox(width: 8),
                                        Text("Edit"),
                                      ],
                                    ),
                                  ),
                                if (isPending && _canDelete)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline,
                                            size: 18, color: softRed),
                                        SizedBox(width: 8),
                                        Text("Delete"),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, thickness: 1, color: lightGrey),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.category_outlined,
                                      size: 14, color: primaryBlue),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "LEAVE TYPE",
                                    style: TextStyle(
                                      color: darkGrey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.leaveType ?? 'N/A',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: softOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 14, color: softOrange),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "DURATION",
                                    style: TextStyle(
                                      color: darkGrey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.noOfDays ?? '0'} Days',
                                style: TextStyle(
                                  color: softOrange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Builder(builder: (context) {
                    List<String> dateList = (item.leaveDates?.toString() ?? '')
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                    String displayText = '';
                    bool showViewMore = false;
                    if (dateList.length > 2) {
                      displayText =
                          'Leave Dates: ${dateList.take(2).join(", ")}...';
                      showViewMore = true;
                    } else if (dateList.isNotEmpty) {
                      displayText = 'Leave Dates: ${dateList.join(", ")}';
                    } else {
                      displayText = 'Leave Dates: N/A';
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.date_range_outlined,
                              size: 16, color: primaryBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              displayText,
                              style: const TextStyle(
                                color: primaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (showViewMore) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24)),
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white,
                                            lightBlue.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      primaryBlue,
                                                      secondaryBlue
                                                    ],
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                    Icons.calendar_month,
                                                    color: Colors.white,
                                                    size: 24),
                                              ),
                                              const SizedBox(width: 16),
                                              const Text(
                                                "Leave Dates",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryBlue,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(height: 24),
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border:
                                                  Border.all(color: lightBlue),
                                            ),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: dateList.length,
                                              itemBuilder: (context, i) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 6.0),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.check_circle,
                                                          size: 16,
                                                          color: softGreen),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        dateList[i],
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                    color: primaryBlue),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                              ),
                                              child: const Text(
                                                "Close",
                                                style: TextStyle(
                                                    color: primaryBlue,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "View More",
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.date_range_outlined,
                            size: 16, color: primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            // '${item.fromDate ?? ''}  →  ${item.toDate ?? ''}',
                            'Applied On:${item.createdAt}',
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.remarks != null && item.remarks!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryBlue.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.notes_rounded,
                              size: 16, color: primaryBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.remarks != ""
                                  ? 'Remarks :${item.remarks!}'
                                  : 'Reason :${item.reason!}',
                              style: TextStyle(
                                color: primaryBlue,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (item.reason != null && item.reason.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryBlue.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.notes_rounded,
                              size: 16, color: primaryBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Reason :${item.reason!}',
                              style: TextStyle(
                                color: primaryBlue,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    Color bgColor;
    String label = status.toUpperCase();

    if (status.toLowerCase().contains('pending')) {
      color = softOrange;
      bgColor = softOrange.withOpacity(0.1);
      icon = Icons.hourglass_empty;
    } else if (status.toLowerCase().contains('approved')) {
      color = softGreen;
      bgColor = softGreen.withOpacity(0.1);
      icon = Icons.check_circle;
    } else if (status.toLowerCase().contains('rejected')) {
      color = softRed;
      bgColor = softRed.withOpacity(0.1);
      icon = Icons.cancel;
    } else {
      color = primaryBlue;
      bgColor = lightBlue;
      icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(dynamic item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                lightBlue.withOpacity(0.3),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, secondaryBlue],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.description_outlined,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Leave Details",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: darkGrey),
                  ),
                ],
              ),
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                        Icons.person_outline, "Staff", item.staffName ?? 'N/A'),
                    _buildDetailRow(Icons.category_outlined, "Leave Type",
                        item.leaveType ?? 'N/A'),
                    _buildDetailRow(Icons.calendar_today_outlined, "Duration",
                        '${item.noOfDays ?? '0'} Days'),
                    // _buildDetailRow(
                    //     Icons.date_range, "From Date", item.fromDate ?? 'N/A'),
                    // _buildDetailRow(
                    //     Icons.date_range, "To Date", item.toDate ?? 'N/A'),
                    // _buildDetailRow(Icons.access_time, "Applied On",
                    //     item.createdAt ?? 'N/A'),
                    _buildDetailRow(
                        Icons.info_outline, "Status", item.status ?? 'Pending',
                        isStatus: true, status: item.status),
                    if (item.remarks != null)
                      _buildDetailRow(Icons.notes, "Remarks", item.remarks!,
                          isRemarks: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StaffCalendarPage(
                              staffId: item.userId,
                              selectedDate: DateTime.now(),
                              staffName: item.staffName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_month_outlined,
                          size: 18, color: primaryBlue),
                      label: const Text(
                        "View Attendance",
                        style: TextStyle(color: primaryBlue, fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryBlue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildDetailRow(IconData icon, String label, String value,
      {bool isStatus = false, String? status, bool isRemarks = false}) {
    Color valueColor = Colors.black87;
    if (isStatus) {
      if (status?.toLowerCase().contains('pending') ?? false) {
        valueColor = softOrange;
      } else if (status?.toLowerCase().contains('approved') ?? false) {
        valueColor = softGreen;
      } else if (status?.toLowerCase().contains('rejected') ?? false) {
        valueColor = softRed;
      } else {
        valueColor = primaryBlue;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            child: Icon(icon, size: 18, color: primaryBlue),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: darkGrey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isRemarks ? FontWeight.normal : FontWeight.w600,
                fontSize: isRemarks ? 13 : 14,
                color: isRemarks ? darkGrey : valueColor,
                fontStyle: isRemarks ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(dynamic item) {
    List<String> dates = (item.leaveDates as String)
        .split(',')
        .map((e) => e.trim())
        .toList()
        .cast<String>();
    List<String> selectedDates = List.from(dates);
    TextEditingController remarksCtrl = TextEditingController();

    bool isActionLoading = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    softGreen.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: softGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline,
                            color: softGreen, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Approve Leave",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: softGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Staff: ${item.staffName}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  const Text(
                    "Select Dates to Approve",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: lightGrey),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: const Text(
                            "Select All Dates",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          value: selectedDates.length == dates.length,
                          onChanged: (val) {
                            setState(() {
                              if (val == true)
                                selectedDates = List.from(dates);
                              else
                                selectedDates.clear();
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: softGreen,
                          checkColor: Colors.white,
                        ),
                        const Divider(height: 1),
                        ...dates.map((date) => CheckboxListTile(
                              title: Text(
                                date,
                                style: const TextStyle(fontSize: 14),
                              ),
                              value: selectedDates.contains(date),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true)
                                    selectedDates.add(date);
                                  else
                                    selectedDates.remove(date);
                                });
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              activeColor: softGreen,
                              checkColor: Colors.white,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Admin Remarks",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: remarksCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enter approval remarks...",
                      hintStyle: const TextStyle(color: darkGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: softGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          onPressed: isActionLoading
                              ? null
                              : () async {
                                  if (selectedDates.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            "Please select at least one date"),
                                        backgroundColor: softRed,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isActionLoading = true;
                                  });

                                  try {
                                    final res = await HttpService.approveLeave(
                                        item.id,
                                        selectedDates.join(','),
                                        remarksCtrl.text);
                                    if (res != null && res.status == true) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(res.message),
                                          backgroundColor: softGreen,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      );
                                      Navigator.pop(context);
                                      _loadData();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(res?.message ?? "Error"),
                                          backgroundColor: softRed,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      );
                                    }
                                  } finally {
                                    setState(() {
                                      isActionLoading = false;
                                    });
                                  }
                                },
                          child: isActionLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Approve",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmReject(dynamic item) {
    TextEditingController remarksCtrl = TextEditingController();
    bool isActionLoading = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  softRed.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: softRed.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cancel_outlined,
                          color: softRed, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Reject Leave",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: softRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Are you sure you want to reject this leave request?",
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: remarksCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Reason for rejection...",
                          hintStyle: const TextStyle(color: darkGrey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: lightGrey,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: softRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        onPressed: isActionLoading
                            ? null
                            : () async {
                                setState(() {
                                  isActionLoading = true;
                                });

                                try {
                                  final res = await HttpService.rejectLeave(
                                      item.id,
                                      remarks: remarksCtrl.text);
                                  if (res != null && res.status == true) {
                                    Navigator.pop(context);
                                    _loadData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            "Leave request rejected"),
                                        backgroundColor: softGreen,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            res?.message ?? "Failed to reject"),
                                        backgroundColor: softRed,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                  }
                                } finally {
                                  setState(() {
                                    isActionLoading = false;
                                  });
                                }
                              },
                        child: isActionLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Reject",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(dynamic item) {
    bool isActionLoading = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  softRed.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: softRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: softRed, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Delete Request",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: softRed,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Are you sure you want to delete this leave request permanently?",
                  style: TextStyle(fontSize: 15, color: darkGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: softRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        onPressed: isActionLoading
                            ? null
                            : () async {
                                setState(() {
                                  isActionLoading = true;
                                });

                                try {
                                  final res =
                                      await HttpService.deleteLeaveRequest(
                                          item.id);
                                  if (res != null && res.status == true) {
                                    Navigator.pop(context);
                                    _loadData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            const Text("Leave request deleted"),
                                        backgroundColor: softGreen,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            res?.message ?? "Failed to delete"),
                                        backgroundColor: softRed,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                  }
                                } finally {
                                  setState(() {
                                    isActionLoading = false;
                                  });
                                }
                              },
                        child: isActionLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Delete",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openApplyLeaveDialog({dynamic item}) {
    bool isEdit = item != null;
    String? leaveType =
        isEdit ? _normalizeLeaveType(item.leaveType) : _leaveTypeFilters[0];

    List<String> selectedDates = [];
    if (isEdit && item.leaveDates != null && item.leaveDates.isNotEmpty) {
      selectedDates = item.leaveDates
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList()
          .cast<String>();
    }

    TextEditingController remarkCtrl = TextEditingController(
        text: isEdit ? (item.remarks ?? item.reason) : "");
    bool isHalfDay =
        isEdit ? (item.dayType == "half" || item.dayType == "half_day") : false;

    bool isActionLoading = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setS) {
          return Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryBlue, secondaryBlue],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            isEdit ? Icons.edit_outlined : Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          isEdit ? "Edit Leave Request" : "Apply for Leave",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Leave Type",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<String>(
                              value: leaveType,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: const Icon(Icons.category_outlined,
                                    color: primaryBlue),
                              ),
                              items: _leaveTypeFilters
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setS(() => leaveType = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selected Dates",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (selectedDates.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 16, color: darkGrey),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "No dates selected",
                                    style: TextStyle(
                                        color: darkGrey, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: selectedDates
                                  .map((date) => Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Chip(
                                          label: Text(
                                            date,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          onDeleted: () {
                                            setS(() {
                                              selectedDates.remove(date);
                                            });
                                          },
                                          deleteIcon: const Icon(Icons.close,
                                              size: 16, color: softRed),
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final p = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: primaryBlue,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (p != null) {
                                String formatted =
                                    DateFormat('dd-MM-yyyy').format(p);
                                if (!selectedDates.contains(formatted)) {
                                  setS(() {
                                    selectedDates.add(formatted);
                                    selectedDates.sort((a, b) {
                                      DateTime dateA =
                                          DateFormat('dd-MM-yyyy').parse(a);
                                      DateTime dateB =
                                          DateFormat('dd-MM-yyyy').parse(b);
                                      return dateA.compareTo(dateB);
                                    });
                                  });
                                }
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Add Date"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primaryBlue,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Leave Type",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CheckboxListTile(
                              title: const Text(
                                "Is Half Day?",
                                style: TextStyle(fontSize: 14),
                              ),
                              value: isHalfDay,
                              onChanged: (v) =>
                                  setS(() => isHalfDay = v ?? false),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: primaryBlue,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Reason / Remarks",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: remarkCtrl,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "Enter your reason for leave...",
                              hintStyle: const TextStyle(color: darkGrey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: isActionLoading
                            ? null
                            : () async {
                                if (leaveType == null ||
                                    selectedDates.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Please select leave type and at least one date"),
                                      backgroundColor: softRed,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  );
                                  return;
                                }

                                setS(() {
                                  isActionLoading = true;
                                });

                                try {
                                  if (isEdit) {
                                    final res =
                                        await HttpService.editLeaveRequest(
                                      id: item.id,
                                      leaveType: leaveType!,
                                      date: selectedDates.join(','),
                                      remarks: remarkCtrl.text,
                                      isHalfDay: isHalfDay,
                                    );
                                    if (res != null && res.status) {
                                      Navigator.pop(context);
                                      _loadData();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              "Leave request updated"),
                                          backgroundColor: softGreen,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(res?.message ??
                                              "Failed to update"),
                                          backgroundColor: softRed,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      );
                                    }
                                  } else {
                                    final res =
                                        await HttpService.saveLeaveOfficial(
                                      leaveType: leaveType!,
                                      date: selectedDates.join(','),
                                      remarks: remarkCtrl.text,
                                      isHalfDay: isHalfDay,
                                    );
                                    if (res) {
                                      Navigator.pop(context);
                                      _loadData();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text("Leave request submitted"),
                                          backgroundColor: softGreen,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text("Failed to submit request"),
                                          backgroundColor: softRed,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      );
                                    }
                                  }
                                } finally {
                                  if (mounted) {
                                    setS(() {
                                      isActionLoading = false;
                                    });
                                  }
                                }
                              },
                        child: isActionLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEdit ? "Update Request" : "Submit Request",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
