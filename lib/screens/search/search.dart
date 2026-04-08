// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/search/search.dart';
import 'package:login2/screens/customer/customerDasboard.dart';
import 'package:login2/screens/leadManagement/viewLeadsNew.dart';
import 'package:login2/service/service.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/lead_management/cloudCallModel.dart';
import '../../models/lead_management/viewLeadsModel.dart';
import '../../models/lead_management/leadDetailsModel.dart';
import '../../models/lead_management/leadDetailsModelAdd.dart';
import '../../models/lead_management/leadMileStoneListModel.dart';
import '../../models/lead_management/listFolderName.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import 'package:login2/models/lead_management/leadFollowupAdd.dart' as af;
import '../leadManagement/lead_details_popup.dart';

class Search extends StatefulWidget {
  String token;
  bool editLead;
  bool deleteLead;
  bool cloudCall;
  String? leadType;
  String? pageName;
  dynamic status;
  dynamic staff;
  bool? isCalled;
  DateTime? fromDate;
  DateTime? toDate;
  dynamic category;

  Search({
    super.key,
    required this.cloudCall,
    required this.editLead,
    required this.deleteLead,
    required this.token,
    required this.leadType,
    this.pageName,
    this.status,
    this.staff,
    this.isCalled,
    this.fromDate,
    this.toDate,
    this.category,
  });

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with TickerProviderStateMixin {
  bool hasMoreData = true;
  bool isLoadingMore = false;
  late ScrollController scrollController;
  late TextEditingController searchController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  SearchDataModel? response;
  ViewLeadsModel? viewLeads;
  AddLeadCommonDataModel? commonDetails;
  bool result = true;
  bool isLoading = false;
  bool custSwitch = true;
  bool leadSwitch = true;
  String statusWise = '';
  String statusWiseId = '';
  String multiBranch = '';
  String roleId = '';
  String statusCatId = '';
  String type = '';
  DateTime? fromdate;
  DateTime? todate;
  bool isSort = true;
  int page = 1;
  int currentPage = 1;
  int pageSize = 10;
  String? branch;
  String? name = '';
  String? role = '';
  String? userId = '';
  String? phoneCallLogPermission = '';
  var outputFormat = DateFormat('dd-MM-yyyy');
  dynamic status;
  List checkedResponseItems = [];
  List checkedresponseItemsName = [];
  List checkedCategoryItems = [];
  List checkedCategoryItemsName = [];
  List checkedPriorityItems = [];
  List checkedPriorityItemsName = [];
  List checkedAssignedStaffItems = [];
  List checkedAssignedStaffItemsName = [];
  bool? isCalled = true;

  Timer? _debounceTimer;
  final FocusNode _searchFocusNode = FocusNode();

  static const Color appBarStart = Color(0xFF2a86c9);
  static const Color callGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color backgroundLight = Color(0xFFF8FAFC);

  final List<Color> _colors = [
    const Color(0xFF2196F3), // Vibrant Blue (index 0)
    const Color(0xFF2196F3), // Blue at index 1 for "New"
    const Color(0xFFFFC107), // Amber/Yellow for Followup (index 2)
    const Color.fromARGB(
        255, 255, 7, 7), // Amber/Yellow at index 3 for Followup
    const Color(0xFF4CAF50), // Green 500 (index 4) - Standardized for Closed
    const Color(0xFFF44336), // Red 500 (index 5) - Standardized for Rejected
    const Color(0xFF9C27B0), // Purple 500 (index 6)
    const Color(0xFF2a84c9), // Primary Blue (index 7)
    const Color(0xFF009688), // Teal (index 8)
    const Color(0xFFFF6F00), // Amber 900 (index 9)
    const Color(0xFFD32F2F), // Red 700 (index 10)
    const Color(0xFF1B5E20), // Green 900 (index 11)
    const Color(0xFF0D47A1), // Blue 900 (index 12)
    const Color(0xFF3F51B5), // Indigo (index 13)
  ];

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    searchController = TextEditingController();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();

    getData('desc', false, widget.status);

    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final threshold = scrollController.position.maxScrollExtent * 0.9;
    if (scrollController.position.pixels >= threshold) {
      if (hasMoreData && !isLoadingMore && searchController.text.isNotEmpty) {
        loadMoreData();
      }
    }
  }

  void _onSearchChanged() {
    // No full state rebuild on every keystroke.
    // The clear icon will be handled by a ValueListenableBuilder in _buildSearchBar.
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (searchController.text.isNotEmpty) {
        getList();
      } else {
        setState(() => response = null);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    _searchFocusNode.dispose();
    _slideController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> getData(sort, isFirst, status1) async {
    setState(() => isLoading = true);
    try {
      name = await Common.getSharedPref("name");
      role = await Common.getSharedPref("role");
      userId = await Common.getSharedPref("userId");
      phoneCallLogPermission =
          await Common.getSharedPref("phoneCallLogPermission");
      final connectivityResult = await Connectivity().checkConnectivity();
      setState(() {
        result = connectivityResult.isNotEmpty &&
            !connectivityResult.contains(ConnectivityResult.none);
      });
      statusWise = await Common.getSharedPref("statusWise");
      roleId = await Common.getSharedPref("roleId");
      multiBranch = await Common.getSharedPref("multiBranch");
      if (statusWise == 'yes') {
        statusWiseId = await Common.getSharedPref("statusWisId");
        statusCatId = await Common.getSharedPref("statusCatId");
        type = await Common.getSharedPref("type");
        final fetchedLeads = await HttpService.viewLeadsSts(
          widget.token,
          fromdate,
          todate,
          type,
          statusCatId,
          statusWiseId,
          sort,
          page,
          pageSize,
          isFirst,
          branch,
        );
        if (mounted) {
          setState(() {
            viewLeads = fetchedLeads;
          });
        }
      } else {
        Map<String, dynamic> body = {
          "token": widget.token,
          if (fromdate != null) "fromDate": outputFormat.format(fromdate!),
          if (todate != null) "toDate": outputFormat.format(todate!),
          "callResultId": status1 ?? "",
          "leadCategoryId": checkedCategoryItems,
          "callResponseId": checkedResponseItems,
          "staffId": checkedAssignedStaffItems,
          "isCalled": isCalled,
          "priority": checkedPriorityItems,
          "sort": sort,
          "page": page,
          "pageSize": pageSize,
          "isFirst": isFirst,
          "leadType": widget.leadType ?? "",
          "branchId": branch ?? ""
        };
        log(body.toString());
        final newViewLeads = await HttpService.viewLeads(body);
        if (mounted) {
          setState(() {
            viewLeads = newViewLeads;
          });
        }
      }
    } catch (e) {
      log('Error in getData: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> getList() async {
    if (searchController.text.isEmpty) {
      setState(() => response = null);
      return;
    }
    setState(() {
      isLoading = true;
      currentPage = 1;
      hasMoreData = true;
    });
    try {
      final newResponse = await HttpService.getSearchData(
        searchController.text,
        page: currentPage,
        pageSize: pageSize,
      );
      if (mounted) {
        setState(() {
          response = newResponse;
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error in getList: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          response = null;
        });
      }
    }
  }

  Future<void> loadMoreData() async {
    if (isLoadingMore || !hasMoreData || searchController.text.isEmpty) return;
    setState(() => isLoadingMore = true);
    try {
      currentPage++;
      final newResponse = await HttpService.getSearchData(
        searchController.text,
        page: currentPage,
        pageSize: pageSize,
      );
      if (mounted) {
        setState(() {
          if (newResponse != null && newResponse.data != null) {
            // deduplicate items
            final existingCustIds =
                response!.data.customers.map((c) => c.id).toSet();
            final newCusts = newResponse.data.customers
                .where((c) => !existingCustIds.contains(c.id))
                .toList();
            response!.data.customers.addAll(newCusts);

            final existingLeadIds =
                response!.data.leadData.map((l) => l.callMasterId).toSet();
            final newLeads = newResponse.data.leadData
                .where((l) => !existingLeadIds.contains(l.callMasterId))
                .toList();
            response!.data.leadData.addAll(newLeads);

            hasMoreData = newCusts.isNotEmpty || newLeads.isNotEmpty;
          } else {
            hasMoreData = false;
          }
          isLoadingMore = false;
        });
      }
    } catch (e) {
      log('Error loading more data: $e');
      if (mounted) {
        setState(() {
          hasMoreData = false;
          isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Search",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: const Color.fromARGB(255, 63, 139, 202),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: result ? _buildMainContent() : _buildNoInternetWidget(),
    );
  }

  Widget _buildMainContent() {
    final showViewLeads = searchController.text.isEmpty && viewLeads != null;
    final showSearchResults =
        searchController.text.isNotEmpty && response != null;
    final showEmpty = !isLoading &&
        !showViewLeads &&
        !showSearchResults &&
        searchController.text.isNotEmpty;

    return CustomScrollView(
      key: const PageStorageKey('search_scroll_view'),
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Index 0: Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSearchBar(),
          ),
        ),

        // Index 1: Loading Indicator
        SliverToBoxAdapter(
          child: isLoading
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildLoadingIndicator(),
                )
              : const SizedBox.shrink(),
        ),

        // Index 2: Leads (Initial View)
        if (showViewLeads) ..._buildViewLeadsResultsSlivers(),

        // Index 3+: Search Results (Customers then Leads)
        if (showSearchResults) ..._buildResultsSlivers(),

        // Empty State
        if (showEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildEmptyState(),
            ),
          ),

        // Index N: Shimmer Loading More
        SliverToBoxAdapter(
          child:
              isLoadingMore ? _buildShimmerLoading() : const SizedBox.shrink(),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: 'Search leads or customers...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF2a86c9),
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: searchController,
              builder: (context, value, child) {
                return value.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: Color(0xFF94A3B8)),
                        onPressed: () {
                          searchController.clear();
                          setState(() => response = null);
                        },
                      )
                    : const SizedBox.shrink();
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onSubmitted: (_) {
            _searchFocusNode.unfocus();
            getList();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation(Color(0xFF2a86c9)),
            backgroundColor: const Color(0xFF2a86c9).withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'Searching...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          Icon(
            searchController.text.isEmpty
                ? Icons.search_off_rounded
                : Icons.sentiment_dissatisfied_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            searchController.text.isEmpty
                ? 'Start typing to search'
                : 'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          if (searchController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildViewLeadsResultsSlivers() {
    if (viewLeads == null || viewLeads!.data.details.isEmpty) return [];
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSectionHeader(
            title: 'Leads',
            icon: Icons.leaderboard_rounded,
            color: const Color(0xFF10B981),
            count: viewLeads!.data.details.length,
            isExpanded: leadSwitch,
            onToggle: () => setState(() => leadSwitch = !leadSwitch),
          ),
        ),
      ),
      if (leadSwitch)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildLeadCard(viewLeads!.data.details[index], index),
              childCount: viewLeads!.data.details.length,
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildResultsSlivers() {
    if (response == null) return [];

    return [
      // Customers Section
      SliverToBoxAdapter(
        child: response!.data.customers.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSectionHeader(
                  title: 'Customers',
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF2a86c9),
                  count: response!.data.customers.length,
                  isExpanded: custSwitch,
                  onToggle: () => setState(() => custSwitch = !custSwitch),
                ),
              )
            : const SizedBox.shrink(),
      ),
      if (custSwitch && response!.data.customers.isNotEmpty)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildCustomerCard(response!.data.customers[index]),
              childCount: response!.data.customers.length,
            ),
          ),
        ),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // Leads Section
      SliverToBoxAdapter(
        child: response!.data.leadData.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSectionHeader(
                  title: 'Leads',
                  icon: Icons.leaderboard_rounded,
                  color: const Color(0xFF10B981),
                  count: response!.data.leadData.length,
                  isExpanded: leadSwitch,
                  onToggle: () => setState(() => leadSwitch = !leadSwitch),
                ),
              )
            : const SizedBox.shrink(),
      ),
      if (leadSwitch && response!.data.leadData.isNotEmpty)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildLeadCard(response!.data.leadData[index], index),
              childCount: response!.data.leadData.length,
            ),
          ),
        ),
    ];
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count record${count != 1 ? 's' : ''} found',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isExpanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(dynamic customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerDashboard(
                  name: name ?? "",
                  token: widget.token,
                  userId: userId ?? "",
                  phoneCallLogPermission: phoneCallLogPermission,
                  custId: customer.id,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'customer_${customer.id}',
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF2a86c9).withOpacity(0.1),
                    child: Text(
                      (customer.name ?? "?").isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        color: Color(0xFF2a86c9),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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
                        customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.phone_rounded,
                              size: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            customer.contactNo,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF2a86c9),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadCard(dynamic lead, int index) {
    bool isSelected = false;
    try {
      isSelected = lead.isSelected ?? false;
    } catch (_) {}

    return Dismissible(
      key: Key('lead_${lead.callMasterId}'),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(
        color: callGreen,
        icon: Icons.call_rounded,
        label: "Call",
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: appBarStart,
        icon: Icons.add_rounded,
        label: "Follow-up",
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          if (lead.callResult != "Confirmed") {
            _showLeadDetailsPopup(lead, index, autoExpandFollowup: true);
          } else {
            _showToast("Cannot follow up on confirmed leads");
          }
        } else {
          await _handleCallAction(lead, index);
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? appBarStart : borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewLeadsNew(
                    widget.token,
                    widget.editLead,
                    widget.deleteLead,
                    widget.cloudCall,
                    notificationLeadId: lead.callMasterId.toString(),
                    pageName: "All Report",
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatar(lead),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lead.clientName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                      decoration: lead.priority == "4"
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                                _buildCategoryBadge(lead.leadCategory),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone_rounded,
                                  size: 14,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  lead.contactNumber1,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.w500,
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
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.person_outline_rounded,
                            label: lead.staffName,
                          ),
                          const Spacer(),
                          _buildStatusBadge(lead.callResult,
                              int.tryParse(lead.callResultId.toString()) ?? 0),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: backgroundLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            _buildDateColumn(
                              label: "Next Follow-up",
                              date: lead.scheduledDate,
                              color: appBarStart,
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: const Color(0xFFE2E8F0),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            _buildDateColumn(
                              label: "Last Call",
                              date: lead.calledDate,
                              color: textSecondary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCallButton(lead, index),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(dynamic lead) {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: _getPriorityColor(lead.priority).withOpacity(0.1),
            backgroundImage:
                lead.profilePic != null && lead.profilePic!.isNotEmpty
                    ? NetworkImage(lead.profilePic!)
                    : null,
            child: lead.profilePic == null || lead.profilePic!.isEmpty
                ? Text(
                    (lead.clientName ?? "?").isNotEmpty
                        ? lead.clientName[0].toUpperCase()
                        : "?",
                    style: TextStyle(
                      color: _getPriorityColor(lead.priority),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _getPriorityColor(lead.priority),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(String? category) {
    if (category == null || category.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFDBEAFE),
            const Color(0xFFBFDBFE),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status, int? statusId) {
    final int id = statusId ?? 0;
    final bool isValidId = id >= 0 && id < _colors.length;
    final Color color = isValidId ? _colors[id] : accentOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            (status == null || status.isEmpty) ? "Pending" : status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateColumn(
      {required String label, required String date, required Color color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton(dynamic lead, int index) {
    return Material(
      color: callGreen,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _handleCallAction(lead, index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Contact Now",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCallAction(dynamic lead, int index) async {
    if (response?.data.callPermission == false) {
      _showCallPermissionDialog(lead);
    } else {
      if (widget.cloudCall) {
        _showCallTypeDialog(index);
      } else {
        Common.dialPad(lead.contactNumber1);
      }
    }
  }

  void _showCallPermissionDialog(dynamic lead) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFEF4444),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Access Restricted',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          response!.data.warningMessage.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewLeadsNew(
                    widget.token,
                    widget.editLead,
                    widget.deleteLead,
                    widget.cloudCall,
                    notificationLeadId: lead.callMasterId.toString(),
                    pageName: "All Report",
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2a86c9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  void _showCallTypeDialog(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Choose Call Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _buildCallOption(
              icon: Icons.cloud_rounded,
              title: 'Cloud Call',
              color: const Color(0xFF2a86c9),
              onTap: () async {
                Navigator.pop(context);
                Common.showProgressDialog(context, "Initiating call...");
                try {
                  CloudCallModel object1 = await HttpService.addCloudCall(
                    widget.token,
                    response!.data.leadData[index].callMasterId.toString(),
                    response!.data.leadData[index].contactNumber1,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    _showToast(
                      object1.message,
                      isSuccess: object1.data == true,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    _showToast('Failed to initiate call', isSuccess: false);
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            _buildCallOption(
              icon: Icons.phone_rounded,
              title: 'Phone Call',
              color: const Color(0xFF10B981),
              onTap: () {
                Navigator.pop(context);
                Common.dialPad(response!.data.leadData[index].contactNumber1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ] else ...[
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: Colors.white, size: 20),
          ]
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Internet Connection',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => getData('desc', true, status),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2a86c9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case '1':
        return const Color(0xFF94A3B8);
      case '2':
        return const Color(0xFF10B981);
      case '3':
        return const Color(0xFFEF4444);
      case '4':
        return const Color(0xFF1E293B);
      default:
        return const Color(0xFF64748B);
    }
  }

  void _showToast(String? message, {bool isSuccess = true}) {
    if (message == null || message.isEmpty) {
      if (!isSuccess) {
        message = "Something went wrong. Please try again.";
      } else {
        return; // Don't show empty success toasts
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _showLeadDetailsPopup(dynamic lead, int index,
      {bool autoExpandFollowup = false}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: Color(0xFF2a86c9),
              strokeWidth: 3,
            ),
          ),
        );
      },
    );

    try {
      final results = await Future.wait([
        HttpService.leadDetails(widget.token, lead.callMasterId.toString()),
        HttpService.listAddonDet(widget.token, lead.callMasterId.toString()),
        HttpService.listFolderAndFiles(
            widget.token, lead.callMasterId.toString(), ''),
        HttpService.leadMileStone(widget.token, lead.callMasterId.toString()),
        HttpService.leadFollowupData(
            widget.token, lead.callMasterId.toString()),
        if (commonDetails == null) HttpService.addLeadCommonData(widget.token),
      ]);

      if (!mounted) return;
      Navigator.pop(context);

      final leadDetails = results[0] as LeadDeatailsModel?;
      if (leadDetails == null) {
        Common.toastMessaage("Failed to load lead details", Colors.red);
        return;
      }

      final leadDetailsAdditional = results[1] as LeadDeatailsModelAdd?;
      final listFolder = results[2] as ListFolderNameModel?;
      final mileStone = results[3] as LeadMileStoneListModel?;
      final leadDetailsFollowup = results[4] as af.LeadFollowupData?;
      if (commonDetails == null && results.length > 5) {
        setState(() {
          commonDetails = results[5] as AddLeadCommonDataModel?;
        });
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => LeadDetailsPopup(
          token: widget.token,
          editLead: widget.editLead,
          deleteLead: widget.deleteLead,
          cloudCall: widget.cloudCall,
          callMasterId: lead.callMasterId.toString(),
          leadDetails: leadDetails,
          leadDetailsAdditional: leadDetailsAdditional,
          listFolder: listFolder,
          mileStone: mileStone,
          leadDetailsFollowup: leadDetailsFollowup,
          commonDetails: commonDetails,
          pageName: widget.pageName ?? 'Search',
          status: widget.status,
          staff: widget.staff,
          isCalled: widget.isCalled,
          fromDate: widget.fromDate?.toIso8601String(),
          toDate: widget.toDate?.toIso8601String(),
          category: widget.category,
          leadType: widget.leadType,
          onDataChanged: () => getList(),
          autoExpandFollowup: autoExpandFollowup,
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      log('Error showing lead details: $e');
      Common.toastMessaage("Error loading detailsV2", Colors.red);
    }
  }
}
