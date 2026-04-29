import 'package:flutter/material.dart';
import 'package:login2/models/customers/customerPaymentReportModel.dart';
import 'package:login2/screens/accounts/clients/pendingInvoice.dart';
import 'package:login2/screens/accounts/reports/hidden_customer_payment_report_screen.dart';
import 'package:login2/screens/accounts/dashboard/bank_account.dart';
import 'package:login2/screens/customer/customerDasboard.dart';
import 'package:login2/service/service.dart';
import 'package:login2/core/common.dart';

class CustomerPaymentReportScreen extends StatefulWidget {
  final String? fDate;
  final String? tDate;
  const CustomerPaymentReportScreen({super.key, this.fDate, this.tDate});

  @override
  State<CustomerPaymentReportScreen> createState() =>
      _CustomerPaymentReportScreenState();
}

class _CustomerPaymentReportScreenState
    extends State<CustomerPaymentReportScreen> with TickerProviderStateMixin {
  bool isLoading = true;
  List<CustomerPaymentData> reportList = [];
  List<CustomerPaymentData> filteredList = [];
  TextEditingController searchController = TextEditingController();
  String selectedFilter = 'All';
  String selectedDayFilter = "";
  final Map<String, String> dayFilters = {
    "All": "",
    "0-30 Days": "1",
    "31-60 Days": "2",
    "61-90 Days": "3",
    "91-180 Days": "4",
    "180+ Days": "5",
    "1 Year +": "6",
  };
  final FocusNode _searchFocusNode = FocusNode();
  String? token;
  String? userId;
  String? name;
  String? phoneCallLogPermission;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _statsController;

  final List<String> filterOptions = [
    // 'All',
    // 'With Pending',
    // 'Zero Balance',
    // 'Negative Balance'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    );
    _animationController.forward();
    _loadSharedPrefs();
    fetchData();
  }

  Future<void> _loadSharedPrefs() async {
    token = await Common.getSharedPref("token");
    userId = await Common.getSharedPref("userId");
    name = await Common.getSharedPref("name");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    searchController.dispose();
    _animationController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    final response = await HttpService.customerPaymentReport(
      fromDate: widget.fDate,
      toDate: widget.tDate,
      lastPaymentDays: selectedDayFilter,
    );
    if (response != null && response.status == true) {
      setState(() {
        reportList = response.data ?? [];
        applyFilter();
        isLoading = false;
      });
      _statsController.forward(from: 0);
    } else {
      setState(() => isLoading = false);
    }
  }

  void applyFilter() {
    List<CustomerPaymentData> temp = reportList;

    // Apply search filter
    if (searchController.text.isNotEmpty) {
      temp = temp
          .where((element) => (element.accountName ?? '')
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    }

    // Apply filter option
    switch (selectedFilter) {
      case 'With Pending':
        temp = temp.where((item) {
          final amount =
              num.tryParse(item.pendingAmount?.toString() ?? '0') ?? 0;
          return amount > 0;
        }).toList();
        break;
      case 'Zero Balance':
        temp = temp.where((item) {
          final amount =
              num.tryParse(item.pendingAmount?.toString() ?? '0') ?? 0;
          return amount == 0;
        }).toList();
        break;
      case 'Negative Balance':
        temp = temp.where((item) {
          final amount =
              num.tryParse(item.pendingAmount?.toString() ?? '0') ?? 0;
          return amount < 0;
        }).toList();
        break;
    }

    setState(() {
      filteredList = temp;
    });
  }

  void filterSearch(String query) {
    applyFilter();
  }

  Future<void> hideReport(String accountId) async {
    final response = await HttpService.hideCustomerPaymentReport(accountId);
    if (!mounted) return;
    if (response != null && response.status == true) {
      _showCustomSnackBar(
        response.message ?? 'Report hidden successfully',
        isSuccess: true,
      );
      setState(() {
        reportList.removeWhere((item) => item.accountId == accountId);
        applyFilter();
      });
      // fetchData(); // Removed to maintain scroll position
    } else {
      _showCustomSnackBar(
        response?.message ?? 'Failed to hide report',
        isSuccess: false,
      );
    }
  }

  void _showCustomSnackBar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Map<String, dynamic> _calculateStats() {
    int totalCustomers = filteredList.length;
    num totalPending = 0;
    num totalReceivable = 0;
    num totalPayable = 0;

    for (var item in filteredList) {
      final amount = num.tryParse(item.pendingAmount?.toString() ?? '0') ?? 0;
      totalPending += amount;
      if (amount > 0) totalReceivable += amount;
      if (amount < 0) totalPayable += amount.abs();
    }

    return {
      'totalCustomers': totalCustomers,
      'totalPending': totalPending,
      'totalReceivable': totalReceivable,
      'totalPayable': totalPayable,
    };
  }

  Color _getAmountColor(num? amount) {
    if (amount == null) return const Color(0xFF94A3B8);
    if (amount > 0) return const Color(0xFF059669);
    if (amount < 0) return const Color(0xFFDC2626);
    return const Color(0xFF64748B);
  }

  Gradient _getAmountGradient(num? amount) {
    if (amount == null) {
      return const LinearGradient(
        colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
      );
    }
    if (amount > 0) {
      return const LinearGradient(
        colors: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (amount < 0) {
      return const LinearGradient(
        colors: [Color(0xFFFEE2E2), Color(0xFFFECACA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Reports',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              offset: const Offset(0, 40),
              onSelected: (value) {
                if (value == 'hidden') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const HiddenCustomerPaymentReportScreen(),
                    ),
                  ).then((value) => fetchData());
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'hidden',
                  child: Row(
                    children: [
                      Icon(Icons.visibility_off_outlined,
                          size: 18, color: Color(0xFF475569)),
                      SizedBox(width: 12),
                      Text('Hidden Reports'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Stats Cards
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Total Customers',
                            value: '${stats['totalCustomers']}',
                            icon: Icons.people_outline_rounded,
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.blue],
                            ),
                            delay: 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Total Balance',
                            value:
                                '₹ ${(stats['totalPending'] as num).abs().toStringAsFixed(0)}',
                            subtitle: (stats['totalPending'] as num) > 0
                                ? ''
                                : (stats['totalPending'] as num) < 0
                                    ? 'Payable'
                                    : 'Settled',
                            icon: Icons.account_balance_wallet_rounded,
                            gradient: LinearGradient(
                              colors: (stats['totalPending'] as num) > 0
                                  ? [
                                      const Color(0xFF059669),
                                      const Color(0xFF10B981)
                                    ]
                                  : (stats['totalPending'] as num) < 0
                                      ? [
                                          const Color(0xFFDC2626),
                                          const Color(0xFFEF4444)
                                        ]
                                      : [
                                          const Color(0xFF64748B),
                                          const Color(0xFF94A3B8)
                                        ],
                            ),
                            delay: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search and Filter Section
              SliverToBoxAdapter(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      // Search Bar
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 400),
                        tween: Tween<double>(begin: 0.95, end: 1.0),
                        curve: Curves.easeOutQuad,
                        builder: (context, double scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A)
                                        .withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: searchController,
                                focusNode: _searchFocusNode,
                                onChanged: filterSearch,
                                decoration: InputDecoration(
                                  hintText: 'Search by customer name...',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.search_rounded,
                                      color: const Color(0xFF0F172A)
                                          .withOpacity(0.5),
                                      size: 22,
                                    ),
                                  ),
                                  suffixIcon: searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF1F5F9),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close_rounded,
                                              size: 16,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                          onPressed: () {
                                            searchController.clear();
                                            filterSearch('');
                                            _searchFocusNode.unfocus();
                                          },
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF0F172A),
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Filter Chips
                      if (filterOptions.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: filterOptions.map((filter) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  selected: selectedFilter == filter,
                                  label: Text(filter),
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedFilter = filter;
                                      applyFilter();
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: const Color(0xFF0F172A),
                                  checkmarkColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: selectedFilter == filter
                                        ? Colors.white
                                        : const Color(0xFF475569),
                                    fontWeight: selectedFilter == filter
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                      color: selectedFilter == filter
                                          ? Colors.transparent
                                          : const Color(0xFFE2E8F0),
                                      width: 1,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Results count
              if (!isLoading && filteredList.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${filteredList.length} ${filteredList.length == 1 ? 'Record' : 'Records'}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            setState(() {
                              selectedDayFilter = value;
                            });
                            fetchData();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          offset: const Offset(0, 45),
                          itemBuilder: (context) => dayFilters.entries
                              .map((e) => PopupMenuItem<String>(
                                    value: e.value,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            selectedDayFilter == e.value
                                                ? Icons.check_circle_rounded
                                                : Icons.circle_outlined,
                                            size: 18,
                                            color: selectedDayFilter == e.value
                                                ? Colors.blue
                                                : const Color(0xFF94A3B8),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            e.key,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  selectedDayFilter == e.value
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                              color:
                                                  selectedDayFilter == e.value
                                                      ? const Color(0xFF1E293B)
                                                      : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  selectedDayFilter == ""
                                      ? "Days Filter"
                                      : dayFilters.entries
                                          .firstWhere((e) =>
                                              e.value == selectedDayFilter)
                                          .key,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Main Content
              isLoading
                  ? SliverFillRemaining(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF0F172A).withOpacity(0.08),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF0F172A)),
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    )
                  : filteredList.isEmpty
                      ? SliverFillRemaining(child: _buildEmptyState())
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = filteredList[index];
                                final amount = num.tryParse(
                                        item.pendingAmount?.toString() ??
                                            '0') ??
                                    0;

                                return TweenAnimationBuilder(
                                  duration: Duration(
                                      milliseconds: 500 + (index * 50)),
                                  tween: Tween<double>(begin: 0.0, end: 1.0),
                                  curve: Curves.easeOutQuad,
                                  builder: (context, double value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0F172A)
                                              .withOpacity(0.04),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BankAccount(
                                              accId: item.accountId ?? '',
                                              accName: item.accountName ?? '',
                                            ),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(24),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Avatar
                                            Hero(
                                              tag: 'avatar_${item.accountId}',
                                              child: Container(
                                                width: 56,
                                                height: 56,
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      Colors.blue,
                                                      Colors.blue,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    (item.accountName ?? '?')
                                                        .substring(0, 1)
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),

                                            // Info & Actions
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          item.accountName ??
                                                              'N/A',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                                0xFF0F172A),
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // Amount
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              _getAmountGradient(
                                                                  amount),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Text(
                                                          '₹ ${amount.abs().toStringAsFixed(0)}',
                                                          style: TextStyle(
                                                            color:
                                                                _getAmountColor(
                                                                    amount),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),

                                                      // Actions Row
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          // Menu
                                                          PopupMenuButton<
                                                              String>(
                                                            icon: const Icon(
                                                              Icons
                                                                  .more_horiz_rounded,
                                                              color: Color(
                                                                  0xFF64748B),
                                                              size: 22,
                                                            ),
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints(),
                                                            onSelected:
                                                                (value) {
                                                              if (value ==
                                                                  'details') {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            BankAccount(
                                                                      accId:
                                                                          item.accountId ??
                                                                              '',
                                                                      accName:
                                                                          item.accountName ??
                                                                              '',
                                                                    ),
                                                                  ),
                                                                );
                                                              } else if (value ==
                                                                  'hide') {
                                                                _showHideConfirmationDialog(
                                                                    item);
                                                              } else if (value ==
                                                                  'dashboard') {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            CustomerDashboard(
                                                                      token:
                                                                          token ??
                                                                              '',
                                                                      name: item
                                                                              .accountName ??
                                                                          '',
                                                                      userId:
                                                                          item.accountId ??
                                                                              '',
                                                                      phoneCallLogPermission:
                                                                          phoneCallLogPermission,
                                                                      custId: item
                                                                          .accountId,
                                                                    ),
                                                                  ),
                                                                );
                                                              } else if (value ==
                                                                  'pending_invoice') {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            PendingInvoice(
                                                                      token ??
                                                                          '',
                                                                      item.customerId ??
                                                                          '',
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            itemBuilder:
                                                                (context) => [
                                                              const PopupMenuItem(
                                                                value:
                                                                    'details',
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .description_outlined,
                                                                        size:
                                                                            18,
                                                                        color: Color(
                                                                            0xFF475569)),
                                                                    SizedBox(
                                                                        width:
                                                                            12),
                                                                    Text(
                                                                        'Statement'),
                                                                  ],
                                                                ),
                                                              ),
                                                              const PopupMenuItem(
                                                                value: 'hide',
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .visibility_off_outlined,
                                                                        size:
                                                                            18,
                                                                        color: Color(
                                                                            0xFFDC2626)),
                                                                    SizedBox(
                                                                        width:
                                                                            12),
                                                                    Text(
                                                                        'Hide'),
                                                                  ],
                                                                ),
                                                              ),
                                                              const PopupMenuItem(
                                                                value:
                                                                    'dashboard',
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .dashboard,
                                                                        size:
                                                                            18,
                                                                        color: Color(
                                                                            0xFF475569)),
                                                                    SizedBox(
                                                                        width:
                                                                            12),
                                                                    Text(
                                                                        'Customer Dashboard'),
                                                                  ],
                                                                ),
                                                              ),
                                                              const PopupMenuItem(
                                                                value:
                                                                    'pending_invoice',
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .money_off_outlined,
                                                                        size:
                                                                            18,
                                                                        color: Color(
                                                                            0xFF475569)),
                                                                    SizedBox(
                                                                        width:
                                                                            12),
                                                                    Text(
                                                                        'Pending Invoice'),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // Sub-info Row
                                                  Row(
                                                    children: [
                                                      if (item.paymentHidden ==
                                                          '1') ...[
                                                        _buildStatusBadge(
                                                          'Hidden',
                                                          Icons
                                                              .visibility_off_outlined,
                                                          const Color(
                                                              0xFFD97706),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                      ],
                                                      _buildStatusBadge(
                                                        item.lastPaymentDate ??
                                                            "N/A",
                                                        Icons
                                                            .calendar_today_rounded,
                                                        const Color(0xFF64748B),
                                                      ),
                                                      // if (item.daysAgo !=
                                                      //         null &&
                                                      //     item.daysAgo!
                                                      //         .isNotEmpty) ...[
                                                      //   const SizedBox(
                                                      //       width: 8),
                                                      //   _buildStatusBadge(
                                                      //     item.daysAgo,
                                                      //     _getUrgencyIcon(
                                                      //         item.daysAgo!),
                                                      //     _getUrgencyColor(
                                                      //         item.daysAgo!),
                                                      //   ),
                                                      // ],
                                                    ],
                                                  ),

                                                  const SizedBox(height: 8),
                                                  // Sub-info Row
                                                  Row(
                                                    children: [
                                                      // if (item.paymentHidden ==
                                                      //     '1') ...[
                                                      //   _buildStatusBadge(
                                                      //     'Hidden',
                                                      //     Icons
                                                      //         .visibility_off_outlined,
                                                      //     const Color(
                                                      //         0xFFD97706),
                                                      //   ),
                                                      //   const SizedBox(
                                                      //       width: 8),
                                                      // ],
                                                      // _buildStatusBadge(
                                                      //   item.lastPaymentDate ??
                                                      //       "N/A",
                                                      //   Icons
                                                      //       .calendar_today_rounded,
                                                      //   const Color(0xFF64748B),
                                                      // ),
                                                      if (item.daysAgo !=
                                                              null &&
                                                          item.daysAgo!
                                                              .isNotEmpty) ...[
                                                        _buildStatusBadge(
                                                          item.daysAgo,
                                                          _getUrgencyIcon(
                                                              item.daysAgo!),
                                                          _getUrgencyColor(
                                                              item.daysAgo!),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: filteredList.length,
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(String daysAgo) {
    final lower = daysAgo.toLowerCase();
    if (lower.contains('year') ||
        lower.contains('month') ||
        (lower.contains('day'))) {
      return const Color(0xFFEF4444);
    }
    if (lower.contains('week') || (lower.contains('day'))) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF10B981);
  }

  IconData _getUrgencyIcon(String daysAgo) {
    final lower = daysAgo.toLowerCase();
    if (lower.contains('year') || lower.contains('month')) {
      return Icons.error_outline_rounded;
    }
    if (lower.contains('week')) {
      return Icons.hourglass_bottom_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }

  String _formatDaysAgo(String daysAgo) {
    final lower = daysAgo.toLowerCase();
    if (lower.contains('year')) {
      final num = lower.replaceAll(RegExp(r'[^0-9]'), '');
      return '${num}y';
    }
    if (lower.contains('month')) {
      final num = lower.replaceAll(RegExp(r'[^0-9]'), '');
      return '${num}mo';
    }
    if (lower.contains('week')) {
      final num = lower.replaceAll(RegExp(r'[^0-9]'), '');
      return '${num}w';
    }
    if (lower.contains('day')) {
      final num = lower.replaceAll(RegExp(r'[^0-9]'), '');
      return '${num}d';
    }
    return daysAgo;
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Gradient gradient,
    required int delay,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500 + (delay * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuad,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            // if (subtitle != null) ...[
            //   const SizedBox(height: 4),
            //   Text(
            //     subtitle,
            //     style: TextStyle(
            //       color: Colors.white.withOpacity(0.7),
            //       fontSize: 11,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuad,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.04),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: 64,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 500),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  const Text(
                    'No reports found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Try adjusting your search or filters',
                    style: TextStyle(
                      fontSize: 15,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: fetchData,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
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

  void _showHideConfirmationDialog(CustomerPaymentData item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.visibility_off_rounded,
                    color: Color(0xFFD97706),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hide Report',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This report will be moved to hidden section',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            (item.accountName ?? '?')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
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
                              item.accountName ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Last payment: ${item.lastPaymentDate ?? "N/A"}',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          hideReport(item.accountId ?? '');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Hide',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
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
}
