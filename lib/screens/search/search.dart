// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/search/search.dart';
import 'package:login2/screens/accounts/clients/clientDetails.dart';
import 'package:login2/screens/customer/customerDasboard.dart';
import 'package:login2/screens/leadManagement/viewLeadsNew.dart';
import 'package:login2/service/service.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/lead_management/cloudCallModel.dart';
import '../../models/lead_management/viewLeadsModel.dart';
import '../leadManagement/add_followup.dart';

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

  final List<Color> _statusColors = const [
    Color(0xFFEF4444), // Red
    Color(0xFFF59E0B), // Orange
    Color(0xFF10B981), // Green
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF6366F1), // Indigo
    Color(0xFF14B8A6), // Teal
    Color(0xFF6B7280), // Gray
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
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
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
          if (newResponse != null &&
              (newResponse.data.customers.isNotEmpty ||
                  newResponse.data.leadData.isNotEmpty)) {
            response!.data.customers.addAll(newResponse.data.customers);
            response!.data.leadData.addAll(newResponse.data.leadData);
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
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // SliverAppBar replaced by Scaffold AppBar
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSearchBar(),
              const SizedBox(height: 16),
              if (isLoading) _buildLoadingIndicator(),
              if (searchController.text.isEmpty)
                (viewLeads != null && viewLeads!.data.details.isNotEmpty)
                    ? _buildViewLeadsResults()
                    : _buildEmptyState()
              else if (response != null &&
                  (response!.data.customers.isNotEmpty ||
                      response!.data.leadData.isNotEmpty))
                _buildResults()
              else if (!isLoading)
                _buildEmptyState(),
            ]),
          ),
        ),
        if (isLoadingMore)
          SliverToBoxAdapter(
            child: _buildShimmerLoading(),
          ),
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

  Widget _buildViewLeadsResults() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          _buildSectionHeader(
            title: 'Leads',
            icon: Icons.leaderboard_rounded,
            color: const Color(0xFF10B981),
            count: viewLeads!.data.details.length,
            isExpanded: leadSwitch,
            onToggle: () => setState(() => leadSwitch = !leadSwitch),
          ),
          if (leadSwitch && viewLeads!.data.details.isNotEmpty)
            ...viewLeads!.data.details
                .asMap()
                .entries
                .map((entry) => _buildLeadCard(entry.value, entry.key))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        key: ValueKey(response?.data.customers.length),
        children: [
          if (response!.data.customers.isNotEmpty)
            _buildSectionHeader(
              title: 'Customers',
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF2a86c9),
              count: response!.data.customers.length,
              isExpanded: custSwitch,
              onToggle: () => setState(() => custSwitch = !custSwitch),
            ),
          if (custSwitch && response!.data.customers.isNotEmpty)
            ...response!.data.customers
                .map((customer) => _buildCustomerCard(customer))
                .toList(),
          const SizedBox(height: 16),
          if (response!.data.leadData.isNotEmpty)
            _buildSectionHeader(
              title: 'Leads',
              icon: Icons.leaderboard_rounded,
              color: const Color(0xFF10B981),
              count: response!.data.leadData.length,
              isExpanded: leadSwitch,
              onToggle: () => setState(() => leadSwitch = !leadSwitch),
            ),
          if (leadSwitch && response!.data.leadData.isNotEmpty)
            ...response!.data.leadData
                .asMap()
                .entries
                .map((entry) => _buildLeadCard(entry.value, entry.key))
                .toList(),
        ],
      ),
    );
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
        color: const Color(0xFF10B981),
        icon: Icons.call_rounded,
        label: "Call",
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: const Color(0xFF2a86c9),
        icon: Icons.add_rounded,
        label: "Follow-up",
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          if (lead.callResult != "Confirmed") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddFollowup(
                  widget.token,
                  widget.editLead,
                  widget.deleteLead,
                  widget.cloudCall,
                  lead.callMasterId.toString(),
                  pageName: widget.pageName,
                  status: widget.status,
                  staff: widget.staff,
                  isCalled: widget.isCalled,
                  fromDate: widget.fromDate?.toIso8601String(),
                  toDate: widget.toDate?.toIso8601String(),
                  category: widget.category,
                  leadType: lead.leadCategory,
                  leadTypeId: lead.leadCategoryId,
                  leadSubType: lead.leadSubCategory,
                  leadSubTypeId: lead.leadSubCategoryId,
                  priorityId: lead.priority,
                  priority: lead.priorityName,
                  cost: lead.cost,
                  address: lead.address,
                  leadType1: widget.leadType,
                ),
              ),
            );
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
            color:
                isSelected ? const Color(0xFF2a86c9) : const Color(0xFFF1F5F9),
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
                                      color: const Color(0xFF1E293B),
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
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            _buildDateColumn(
                              label: "Next Follow-up",
                              date: lead.scheduledDate,
                              color: const Color(0xFF2a86c9),
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
                              color: const Color(0xFF64748B),
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
    final int safeId = (statusId ?? 0) % _statusColors.length;
    final Color color = _statusColors[safeId];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status ?? "Unknown",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
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
      color: const Color(0xFF10B981),
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
}
