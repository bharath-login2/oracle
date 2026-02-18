// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/renewal/bulk_remind.dart';
import 'package:login2/models/renewal/hide_model.dart';
import 'package:login2/models/renewal/post_reminder.dart';
import 'package:login2/models/renewal/renewal_details.dart';
import 'package:login2/models/renewal/renewal_list.dart';
import 'package:login2/screens/accounts/clients/clientDetails.dart';
import 'package:login2/screens/accounts/renewal_mannagement/edit_custom_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/edit_quick_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renew_custom_renewal.dart';
import 'package:login2/models/renewal/renewal_template_model.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_details.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_followup.dart';
import 'package:login2/screens/accounts/renewal_mannagement/view_history.dart';
import 'package:login2/screens/customer/customerDasboard.dart';
import 'package:login2/service/service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';
import 'renew_quick_renewal.dart';

class SectionInfo {
  final bool isSectionHeader;
  final int sectionIndex;
  final int itemIndex;

  SectionInfo({
    required this.isSectionHeader,
    required this.sectionIndex,
    this.itemIndex = 0,
  });
}

class RenewalListCustomer extends StatefulWidget {
  String custId;
  String custName;
  String title;
  String searchKey;
  String searchMonth;
  int renewed;
  RenewalListCustomer(
      {super.key,
      required this.custId,
      required this.custName,
      required this.title,
      required this.renewed,
      required this.searchKey,
      required this.searchMonth});

  @override
  State<RenewalListCustomer> createState() => _RenewalListCustomerState();
}

class _RenewalListCustomerState extends State<RenewalListCustomer> {
  final formKey = GlobalKey<FormState>();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController projectCost = TextEditingController();
  TextEditingController remarks = TextEditingController();
  TextEditingController customer = TextEditingController();
  TextEditingController renewalstatus = TextEditingController();
  TextEditingController recieverName = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController expireIn = TextEditingController();
  TextEditingController search = TextEditingController();
  RenewalListModel? listResponse;
  HideModel? hideResponse;
  String clientId = "";
  bool isLoading = true;
  int page = 1;
  int add = 1;
  int pageSize = 10;
  String daysToExpire = "";
  List filteredNames = [];
  List selectedIds = [];
  List selectedNames = [];
  RenewalDetailslModel? detailsResponse;
  RenewalTemplateModel? template;
  PostReminderModel? postReminderRes;
  BulkRemindModel? bulkResponse;
  List products = [];
  List filteredProducts = [];
  String renClientId = "";
  List productName = [];
  double productCost = 0;
  List<ListElement> items = [];
  List<ListElement> upcomingItems = [];
  List<ListElement> expiredItems = [];
  List<ListElement> renewedItems = [];
  String fromDate = "";
  String toDate = "";
  bool isAllSelected = false;
  String multiBranch = "true";
  String? name = '';
  String? token = '';
  String? role = '';
  String? userId = '';
  String? phoneCallLogPermission = '';
  DateTime? selectedValue;
  String? selectedRenewalValue;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  bool _showSummaryDetails = false;
  double _summaryHeight = 60.0;
  double _expandedHeight = 280.0;

  // New variables for expandable sections
  bool isUpcomingExpanded = true;
  bool isExpiredExpanded = true;
  bool isRenewedExpanded = true;

  // Pagination control
  bool hasMore = true;
  bool isRefreshing = false;

  void filterCustomers(
    String query,
  ) {
    filteredNames = detailsResponse!.data.customer
        .where((map) => map.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  getDetails() async {
    token = await Common.getSharedPref("token");
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");
    userId = await Common.getSharedPref("userId");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    detailsResponse = await HttpService.getRenewalDetails();
    if (detailsResponse != null) {
      filteredNames = detailsResponse!.data.customer;
      filteredProducts = detailsResponse!.data.products;
    }
  }

  hide(id) async {
    hideResponse = await HttpService.hideRenewal(id);
    if (hideResponse != null && hideResponse!.status == true) {
      Common.toastMessaage(hideResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(hideResponse!.message, Colors.red);
    }
  }

  void filterProducts(
    String query,
  ) {
    filteredProducts = detailsResponse!.data.products
        .where((map) =>
            map.productName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  getRenewalReminderMessage(String renewalId, String contactId) async {
    template = await HttpService.getRenewalReminderMessage(renewalId);
    if (template != null && template!.status == true) {
      setState(() {
        Navigator.pop(context);
        reminderBottomSheet(renewalId, contactId);
      });
    } else {
      Common.toastMessaage(template!.message, Colors.red);
      Navigator.pop(context);
      setState(() {});
    }
  }

  Map<String, dynamic> _calculateSummary() {
    if (listResponse != null &&
        listResponse!.data.count.isNotEmpty &&
        listResponse!.data.count[0] != null) {
      final apiCount = listResponse!.data.count[0];
      return {
        'totalCount': int.tryParse(apiCount.totalCount) ?? 0,
        'totalAmount': double.tryParse(apiCount.totalAmount) ?? 0,
        'renewedCount': int.tryParse(apiCount.renewed.total) ?? 0,
        'renewedAmount': double.tryParse(apiCount.renewed.amount) ?? 0,
        'expiredCount': int.tryParse(apiCount.expired.total) ?? 0,
        'expiredAmount': double.tryParse(apiCount.expired.amount) ?? 0,
        'pendingCount': int.tryParse(apiCount.pending.total) ?? 0,
        'pendingAmount': double.tryParse(apiCount.pending.amount) ?? 0,
      };
    } else {
      // Fallback to local calculation if API data is not available
      int totalCount = items.length;
      double totalAmount = 0;
      int renewedCount = 0;
      double renewedAmount = 0;
      int expiredCount = 0;
      double expiredAmount = 0;
      int pendingCount = 0;
      double pendingAmount = 0;

      for (var item in items) {
        double cost =
            double.tryParse(item.cost.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        totalAmount += cost;

        if (item.isRenewed == true) {
          renewedCount++;
          renewedAmount += cost;
        } else if (item.isExpired == true) {
          expiredCount++;
          expiredAmount += cost;
        } else {
          pendingCount++;
          pendingAmount += cost;
        }
      }

      return {
        'totalCount': totalCount,
        'totalAmount': totalAmount,
        'renewedCount': renewedCount,
        'renewedAmount': renewedAmount,
        'expiredCount': expiredCount,
        'expiredAmount': expiredAmount,
        'pendingCount': pendingCount,
        'pendingAmount': pendingAmount,
      };
    }
  }

  postReminder(String renewalId, String contactNumber) async {
    postReminderRes = await HttpService.postReminder(
        renewalId,
        contactNumber,
        template!.data.templateType,
        template!.data.templateName,
        template!.data.templateId,
        template!.data.customerId,
        template!.data.message);
    if (postReminderRes != null && postReminderRes!.status == true) {
      Common.toastMessaage(postReminderRes!.message, Colors.green);
    } else {
      Common.toastMessaage(postReminderRes!.message, Colors.red);
    }
  }

  postBulkReminder() async {
    Common.showProgressDialog(context, "Loading..");
    bulkResponse = await HttpService.bulkReminder(selectedIds);
    if (bulkResponse != null) {
      Common.toastMessaage(bulkResponse!.message, Colors.green);
    } else {
      Common.toastMessaage(bulkResponse!.message, Colors.red);
    }
    Navigator.pop(context);
    setState(() {
      selectedIds.clear();
      selectedNames.clear();
    });
  }

  getList() async {
    //if (isLoading || (!hasMore && page > 1)) return;

    setState(() {
      isLoading = true;
    });

    listResponse = await HttpService.renewalList(
        widget.custId,
        page,
        pageSize,
        clientId,
        fromDate,
        toDate,
        daysToExpire,
        widget.searchKey,
        widget.searchMonth,
        expireIn.text,
        search.text,
        selectedRenewalValue ?? "");

    if (listResponse != null && listResponse!.status == true) {
      // If it's the first page, clear lists
      if (page == 1) {
        items.clear();
      }

      items.addAll(listResponse!.data.lists);
      _categorizeAllItems();

      // Check if there's more data
      hasMore = listResponse!.data.lists.length >= pageSize;
      page++;

      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    } else {
      setState(() {
        isLoading = false;
        hasMore = false;
        isRefreshing = false;
      });
    }
  }

  void _categorizeAllItems() {
    upcomingItems.clear();
    expiredItems.clear();
    renewedItems.clear();
    for (var item in items) {
      if (item.isRenewed == true) {
        renewedItems.add(item);
      } else if (item.isExpired == true) {
        expiredItems.add(item);
      } else {
        upcomingItems.add(item);
      }
    }
  }

  @override
  void initState() {
    isLoading = true;
    getList();
    getDetails();
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
    super.initState();
  }

  void _onLoadMore() {
    // Don't load more if already loading, refreshing, or no more data
    if (isLoading || isRefreshing || !hasMore) return;

    // Check if we're near the bottom
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      final lastPosition = positions.last;
      // Load more when we're within 5 items from the end
      if (lastPosition.index >= _getTotalItemCount() - 5) {
        getList();
      }
    }
  }

  void _resetAndLoadList() {
    setState(() {
      page = 1;
      add = 1;
      hasMore = true;
      isRefreshing = true;
      items.clear();
      upcomingItems.clear();
      expiredItems.clear();
      renewedItems.clear();
    });
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.076),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      selectedIds.isEmpty
                          ? InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    shape: BoxShape.circle),
                                child: const Icon(
                                  Icons.arrow_back_ios_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            )
                          : Checkbox(
                              fillColor:
                                  const WidgetStatePropertyAll(Colors.white),
                              checkColor: Colors.blue,
                              value: isAllSelected,
                              onChanged: (value) {
                                setState(() {
                                  isAllSelected = value!;
                                  if (isAllSelected == true) {
                                    for (int i = 0; i < items.length; i++) {
                                      if (items[i].isRenewed == false) {
                                        if (selectedIds.contains(items[i].id)) {
                                        } else {
                                          selectedIds.add(items[i].id);
                                          selectedNames
                                              .add(items[i].clientName);
                                        }
                                      }
                                    }
                                  } else {
                                    selectedNames.clear();
                                    selectedIds.clear();
                                  }
                                });
                              }),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.custName
                                .isNotEmpty) // Check if custName is not empty
                              Text(
                                widget.custName, // Customer name
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(
                                height: 2), // Small spacing between lines
                            Text(
                              "Renewal List", // Always show "Renewal List" below
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
          onRefresh: (() async {
            _resetAndLoadList();
          }),
          child: isLoading == true && page == 1
              ? buildLoaderListItem()
              : items.isNotEmpty
                  ? SafeArea(
                      child: listResponse == null
                          ? const Center(
                              child: Text("Something Went Wrong"),
                            )
                          : Column(
                              children: [
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       SizedBox(
                                //         width:
                                //             MediaQuery.of(context).size.width *
                                //                 0.6,
                                //         child: TextFormField(
                                //           style: const TextStyle(
                                //             color: Colors.black,
                                //           ),
                                //           controller: search,
                                //           decoration: InputDecoration(
                                //             contentPadding:
                                //                 const EdgeInsets.all(8),
                                //             hintStyle: const TextStyle(
                                //                 color: Colors.grey),
                                //             hintText: 'Search',
                                //             filled: true,
                                //             fillColor: Colors.white,
                                //             border: OutlineInputBorder(
                                //               borderRadius:
                                //                   BorderRadius.circular(5),
                                //               borderSide: BorderSide
                                //                   .none, // Set the border color to none
                                //             ),
                                //             prefixIcon: const Icon(
                                //               Icons.search,
                                //               color: Colors.grey,
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //       InkWell(
                                //         onTap: () {
                                //           _resetAndLoadList();
                                //         },
                                //         child: Container(
                                //           width: MediaQuery.of(context)
                                //                   .size
                                //                   .width *
                                //               0.31,
                                //           height: 45,
                                //           decoration: BoxDecoration(
                                //               borderRadius:
                                //                   BorderRadius.circular(4),
                                //               color: const Color(0xff2590cf)),
                                //           child: const Center(
                                //             child: Text("Submit",
                                //                 style: TextStyle(
                                //                   fontSize: 16,
                                //                   color: Colors.white,
                                //                   fontWeight: FontWeight.w600,
                                //                 )),
                                //           ),
                                //         ),
                                //       )
                                //     ],
                                //   ),
                                // ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: ScrollablePositionedList.builder(
                                      shrinkWrap: true,
                                      itemScrollController:
                                          itemScrollController,
                                      itemPositionsListener:
                                          itemPositionsListener,
                                      itemCount: _getTotalItemCount(),
                                      initialScrollIndex: 0,
                                      itemBuilder: (context, index) {
                                        // Check if this is the loading indicator
                                        if (index == _getTotalItemCount() - 1 &&
                                            hasMore &&
                                            !isRefreshing) {
                                          return _buildLoadingIndicator();
                                        }

                                        // Determine which section and item index we're at
                                        var sectionInfo =
                                            _getSectionForIndex(index);

                                        if (sectionInfo.isSectionHeader) {
                                          // This is a section header
                                          return _buildSectionHeader(
                                              sectionInfo.sectionIndex);
                                        } else {
                                          // This is a renewal item
                                          return _buildRenewalItem(
                                              context,
                                              sectionInfo.sectionIndex,
                                              sectionInfo.itemIndex);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                _buildSummarySection(),
                              ],
                            ))
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 150,
                              width: 150,
                              child:
                                  Image.asset("assets/icons/nodatafound.png")),
                          const Text("No Renewals")
                        ],
                      ),
                    )),
    );
  }

  Widget _buildLoadingIndicator() {
    return hasMore && !isRefreshing && items.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : SizedBox.shrink();
  }

  Widget _buildSummarySection() {
    final summaryData = _calculateSummary();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showSummaryDetails ? _expandedHeight : _summaryHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: _summaryHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 40), // Spacer for alignment
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Count: ${summaryData['totalCount']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Total: ₹ ${summaryData['totalAmount'].toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showSummaryDetails = !_showSummaryDetails;
                    });
                  },
                  icon: Icon(
                    _showSummaryDetails
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          if (_showSummaryDetails) ...[
            Divider(height: 1, color: Colors.grey.shade300),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Count',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(width: 55),
                              Text(
                                'Amount',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 10),

                      // Total Renewed
                      InkWell(
                        onTap: () {
                          // Filter to show only renewed items
                          print('Show renewed items');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Renewed',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    child: Text(
                                      '${summaryData['renewedCount']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  Container(
                                    width: 80,
                                    child: Text(
                                      '₹ ${summaryData['renewedAmount'].toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green.shade700,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Total Expired
                      InkWell(
                        onTap: () {
                          // Filter to show only expired items
                          print('Show expired items');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Expired',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    child: Text(
                                      '${summaryData['expiredCount']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  Container(
                                    width: 80,
                                    child: Text(
                                      '₹ ${summaryData['expiredAmount'].toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red.shade700,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Total Pending
                      InkWell(
                        onTap: () {
                          // Filter to show only pending items
                          print('Show pending items');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Pending',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    child: Text(
                                      '${summaryData['pendingCount']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.orange.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  Container(
                                    width: 80,
                                    child: Text(
                                      '₹ ${summaryData['pendingAmount'].toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.orange.shade700,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(height: 1, color: Colors.grey.shade400),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  child: Text(
                                    '${summaryData['totalCount']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 30),
                                Container(
                                  width: 80,
                                  child: Text(
                                    '₹ ${summaryData['totalAmount'].toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                    textAlign: TextAlign.right,
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
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int sectionIndex) {
    String title = "";
    int count = 0;
    bool isExpanded = false;
    Color headerColor = Colors.blue;

    switch (sectionIndex) {
      case 0: // Upcoming
        title = "UPCOMING RENEWALS";
        count = upcomingItems.length;
        isExpanded = isUpcomingExpanded;
        headerColor = Colors.blue;
        break;
      case 1: // Expired
        title = "EXPIRED RENEWALS";
        count = expiredItems.length;
        isExpanded = isExpiredExpanded;
        headerColor = Colors.red;
        break;
      case 2: // Renewed
        title = "RENEWED ITEMS";
        count = renewedItems.length;
        isExpanded = isRenewedExpanded;
        headerColor = Colors.green;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: headerColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$title ($count)",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    switch (sectionIndex) {
                      case 0:
                        isUpcomingExpanded = !isUpcomingExpanded;
                        break;
                      case 1:
                        isExpiredExpanded = !isExpiredExpanded;
                        break;
                      case 2:
                        isRenewedExpanded = !isRenewedExpanded;
                        break;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRenewalItem(
      BuildContext context, int sectionIndex, int itemIndex) {
    ListElement item;
    switch (sectionIndex) {
      case 0:
        if (!isUpcomingExpanded || itemIndex >= upcomingItems.length) {
          return const SizedBox.shrink();
        }
        item = upcomingItems[itemIndex];
        break;
      case 1:
        if (!isExpiredExpanded || itemIndex >= expiredItems.length) {
          return const SizedBox.shrink();
        }
        item = expiredItems[itemIndex];
        break;
      case 2:
        if (!isRenewedExpanded || itemIndex >= renewedItems.length) {
          return const SizedBox.shrink();
        }
        item = renewedItems[itemIndex];
        break;
      default:
        return const SizedBox.shrink();
    }

    Color statusColor = Colors.white;
    if (item.isRenewed == true) {
      statusColor = Colors.green.shade100.withOpacity(.8);
    } else if (item.isExpired == true) {
      statusColor = Colors.red.shade100.withOpacity(.5);
    }

    return Dismissible(
      key: Key('${item.id}_${sectionIndex}_$itemIndex'),
      background: Container(
        color: Colors.green,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 20,
              ),
              Icon(
                Icons.restart_alt,
                color: Colors.white,
              ),
              Text(
                " Renew",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.blue,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                Icons.add,
                color: Colors.white,
              ),
              Text(
                " Add Followup",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (item.renewalType == "quick") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RenewQuickRenewal(
                  id: item.id,
                ),
              ),
            ).then((_) {
              _resetAndLoadList();
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RenewCustomRenewal(
                  renId: item.id,
                  renewalType: item.renewalType,
                ),
              ),
            ).then((_) {
              _resetAndLoadList();
            });
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RenewalFollowup(item.id, DateTime.now()),
            ),
          ).then((_) {
            _resetAndLoadList();
          });
        }
        return null;
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: GestureDetector(
          onTap: () {
            if (item.isRenewed == false) {
              setState(() async {
                if (selectedIds.isNotEmpty) {
                  if (selectedIds.contains(item.id)) {
                    selectedIds.remove(item.id);
                    selectedNames.remove(item.clientName);
                  } else {
                    selectedIds.add(item.id);
                    selectedNames.add(item.clientName);
                  }
                } else {
                  if (selectedIds.isEmpty) {
                    String token = await Common.getSharedPref("token");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerDashboard(
                            name: name!,
                            token: token,
                            userId: userId!,
                            phoneCallLogPermission: phoneCallLogPermission,
                            custId: item.clientId),
                      ),
                    ).then((_) {
                      _resetAndLoadList();
                    });
                  }
                }
              });
              if ((items.length - widget.renewed) == selectedIds.length) {
                isAllSelected = true;
              } else {
                isAllSelected = false;
              }
            }
          },
          onLongPress: () {
            setState(() {
              if (item.isRenewed == false) {
                if (selectedIds.contains(item.id)) {
                  selectedIds.remove(item.id);
                  selectedNames.remove(item.clientName);
                } else {
                  selectedIds.add(item.id);
                  selectedNames.add(item.clientName);
                }
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color:
                  selectedIds.contains(item.id) ? Colors.blueGrey : statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (selectedIds.isEmpty) {
                                String token =
                                    await Common.getSharedPref("token");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomerDashboard(
                                        name: name!,
                                        token: token,
                                        userId: userId!,
                                        phoneCallLogPermission:
                                            phoneCallLogPermission,
                                        custId: item.clientId),
                                  ),
                                ).then((_) {
                                  _resetAndLoadList();
                                });
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 18,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .50,
                                  child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    " ${item.clientName}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          // Row(
                          //   children: [
                          //     const Icon(
                          //       Icons.phone,
                          //       size: 18,
                          //     ),
                          //     SizedBox(
                          //       width: MediaQuery.of(context).size.width * .50,
                          //       child: Text(
                          //         overflow: TextOverflow.ellipsis,
                          //         " ${item.contactNo}",
                          //         style: const TextStyle(fontSize: 14),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                size: 18,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .50,
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  " ${item.startDate} To ${item.endDate}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.shopping_basket,
                                size: 18,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .50,
                                child: Text(
                                  " ${item.products}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.currency_rupee,
                                size: 18,
                                color: Colors.black,
                              ),
                              Text(
                                overflow: TextOverflow.ellipsis,
                                " ${item.cost}/-",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                          //   item.isRenewed == true?
                          //    const SizedBox(
                          //   height: 10,
                          // ):SizedBox(),
                          //  item.isRenewed == true
                          //     ? Row(
                          //         children: [
                          //           Expanded(
                          //             child: Text(
                          //               overflow: TextOverflow.ellipsis,
                          //               "Renewed on ${item.renewedDate} by ${item.renewedBy}",
                          //               style: const TextStyle(fontSize: 14),
                          //             ),
                          //           ),
                          //         ],
                          //       )
                          //     : const SizedBox(),
                          item.isRenewed == true
                              ? const SizedBox(
                                  height: 10,
                                )
                              : SizedBox(),
                          item.isRenewed == true
                              ? Row(
                                  children: [
                                    // const Icon(
                                    //   Icons.currency_exchange_outlined,
                                    //   size: 18,
                                    //   color: Colors.black,
                                    // ),
                                    Text(
                                      overflow: TextOverflow.ellipsis,
                                      " Renewed on ${item.renewedDate} by ${item.renewedBy}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                )
                              : SizedBox(),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Container(
                          //   color: item.isRenewed == false
                          //       ? Colors.red
                          //       : Colors.teal,
                          //   child: Padding(
                          //     padding: const EdgeInsets.symmetric(
                          //         vertical: 4.0, horizontal: 8.0),
                          //     child: Text(
                          //       item.isRenewed == true
                          //           ? "Renewed"
                          //           : item.isExpired == true
                          //               ? "Expired"
                          //               : "Not Renewed",
                          //       style: const TextStyle(color: Colors.white),
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          item.isRenewed == true
                              ? const SizedBox.shrink()
                              : Container(
                                  color: Colors.yellow,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8.0),
                                    child: Text(
                                      overflow: TextOverflow.ellipsis,
                                      item.remainingDays,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color:
                                              Color.fromARGB(255, 54, 43, 43)),
                                    ),
                                  ),
                                ),
                          SizedBox(
                            height: 24,
                          ),
                          Visibility(
                            visible: selectedIds.isEmpty,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Visibility(
                                  visible: item.isRenewed == false,
                                  child: InkWell(
                                    onTap: () async {
                                      Common.showProgressDialog(
                                          context, "Loading..");
                                      getRenewalReminderMessage(
                                          item.id, item.contactNo);
                                      recieverName.text = item.clientName;
                                      contactNumber.text = item.contactNo;
                                    },
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: Colors.teal),
                                      child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.message,
                                            color: Colors.white,
                                          )),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Visibility(
                                  visible: item.isRenewed == false,
                                  child: InkWell(
                                    onTap: () {
                                      if (item.renewalType == "quick") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RenewQuickRenewal(
                                              id: item.id,
                                            ),
                                          ),
                                        ).then((_) {
                                          _resetAndLoadList();
                                          Future.delayed(
                                              const Duration(milliseconds: 300),
                                              () {
                                            if (itemScrollController
                                                .isAttached) {
                                              itemScrollController.jumpTo(
                                                  index: 0);
                                            }
                                          });
                                        });
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RenewCustomRenewal(
                                              renId: item.id,
                                              renewalType: item.renewalType,
                                            ),
                                          ),
                                        ).then((_) {
                                          _resetAndLoadList();
                                          Future.delayed(
                                              const Duration(milliseconds: 300),
                                              () {
                                            if (itemScrollController
                                                .isAttached) {
                                              itemScrollController.jumpTo(
                                                  index: 0);
                                            }
                                          });
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: Colors.green),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(Icons.restart_alt,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  padding: const EdgeInsets.only(left: 5),
                                  iconColor: Colors.black,
                                  color: Colors.white,
                                  onSelected: (value) {
                                    if (value == "0") {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RenewalFollowup(item.id,
                                                          DateTime.now())))
                                          .then((_) {
                                        _resetAndLoadList();
                                      });
                                    } else if (value == "1") {
                                      Common.showProgressDialog(
                                          context, "Loading..");
                                      getRenewalReminderMessage(
                                          item.id, item.contactNo);
                                      recieverName.text = item.clientName;
                                      contactNumber.text = item.contactNo;
                                    } else if (value == "2") {
                                      if (item.renewalType == "quick") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditQuickRenewalScreen(
                                                      id: item.id,
                                                    ))).then((r) {
                                          _resetAndLoadList();
                                        });
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditCustomRenewal(
                                                      renId: item.id,
                                                      renewalType:
                                                          item.renewalType,
                                                    ))).then((_) {
                                          _resetAndLoadList();
                                        });
                                      }
                                    } else if (value == "3") {
                                      if (item.renewalType == "quick") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RenewQuickRenewal(
                                                id: item.id,
                                              ),
                                            )).then((_) {
                                          _resetAndLoadList();
                                          Future.delayed(
                                              const Duration(milliseconds: 300),
                                              () {
                                            if (itemScrollController
                                                .isAttached) {
                                              itemScrollController.jumpTo(
                                                  index: 0);
                                            }
                                          });
                                        });
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RenewCustomRenewal(
                                                renId: item.id,
                                                renewalType: item.renewalType,
                                              ),
                                            )).then((_) {
                                          _resetAndLoadList();
                                          Future.delayed(
                                              const Duration(milliseconds: 300),
                                              () {
                                            if (itemScrollController
                                                .isAttached) {
                                              itemScrollController.jumpTo(
                                                  index: 0);
                                            }
                                          });
                                        });
                                      }
                                    } else if (value == "4") {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              scrollable: true,
                                              title:
                                                  const Text('Please Confirm'),
                                              content: const Text(
                                                  'Are you sure to Hide?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('No')),
                                                TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      await hide(item.id);
                                                      _resetAndLoadList();
                                                    },
                                                    child: const Text('Yes')),
                                              ],
                                            );
                                          });
                                    } else if (value == "5") {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ViewHistory(
                                              id: item.id,
                                              title: item.clientName,
                                            ),
                                          ));
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      if (item.isRenewed == false)
                                        const PopupMenuItem<String>(
                                          value: '0',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.add,
                                                color: Colors.green,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'Add Followup',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (item.isRenewed == false)
                                        const PopupMenuItem<String>(
                                          value: '2',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'Edit',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const PopupMenuItem<String>(
                                        value: '4',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.visibility_off,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Hide',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: '5',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.history,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Remind History',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      )
                                    ];
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
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

  // Helper method to determine which section/item we're at for a given index
  SectionInfo _getSectionForIndex(int index) {
    int currentIndex = 0;

    // Check Upcoming section
    if (currentIndex == index) {
      return SectionInfo(isSectionHeader: true, sectionIndex: 0);
    }
    currentIndex++;

    if (isUpcomingExpanded) {
      for (int i = 0; i < upcomingItems.length; i++) {
        if (currentIndex == index) {
          return SectionInfo(
              isSectionHeader: false, sectionIndex: 0, itemIndex: i);
        }
        currentIndex++;
      }
    }

    // Check Expired section header
    if (currentIndex == index) {
      return SectionInfo(isSectionHeader: true, sectionIndex: 1);
    }
    currentIndex++;

    if (isExpiredExpanded) {
      for (int i = 0; i < expiredItems.length; i++) {
        if (currentIndex == index) {
          return SectionInfo(
              isSectionHeader: false, sectionIndex: 1, itemIndex: i);
        }
        currentIndex++;
      }
    }

    // Check Renewed section header
    if (currentIndex == index) {
      return SectionInfo(isSectionHeader: true, sectionIndex: 2);
    }
    currentIndex++;

    if (isRenewedExpanded) {
      for (int i = 0; i < renewedItems.length; i++) {
        if (currentIndex == index) {
          return SectionInfo(
              isSectionHeader: false, sectionIndex: 2, itemIndex: i);
        }
        currentIndex++;
      }
    }

    // Should never reach here
    return SectionInfo(isSectionHeader: false, sectionIndex: 0, itemIndex: 0);
  }

  // Helper method to calculate total item count
  int _getTotalItemCount() {
    int count = 3; // For the 3 section headers

    if (isUpcomingExpanded) count += upcomingItems.length;
    if (isExpiredExpanded) count += expiredItems.length;
    if (isRenewedExpanded) count += renewedItems.length;

    // Add 1 for loading indicator if there's more data
    if (hasMore && !isRefreshing && items.isNotEmpty) {
      count += 1;
    }

    return count;
  }

  Future<dynamic> filtration(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  width: double.maxFinite,
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Material(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Filtration',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('From Date',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.43,
                                    child: Center(
                                      child: DateTimePicker(
                                        decoration: InputDecoration(
                                            filled: true,
                                            //<-- SEE HERE
                                            fillColor: Colors.white,
                                            prefixIcon: const Icon(
                                              Icons.arrow_right,
                                              color: Colors.grey,
                                            ),
                                            counterText: "",
                                            hintText: 'From Date',
                                            isDense: true,
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.purple.shade100),
                                                borderRadius:
                                                    BorderRadius.circular(5))),
                                        initialValue: fromDate.toString(),
                                        type: DateTimePickerType.date,

                                        //controller: fromDate,
                                        firstDate: DateTime(1995),
                                        lastDate: DateTime.now()
                                            .add(const Duration(days: 365)),
                                        // This will add one year from current date
                                        validator: (value) {
                                          return null;
                                        },
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            setState(() {
                                              String formattedDate = DateFormat(
                                                      'dd-MM-yyyy')
                                                  .format(
                                                      DateTime.parse(value));
                                              fromDate = formattedDate;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('To Date',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.43,
                                    child: Center(
                                      child: DateTimePicker(
                                        decoration: InputDecoration(
                                            filled: true,
                                            //<-- SEE HERE
                                            fillColor: Colors.white,
                                            prefixIcon: const Icon(
                                              Icons.arrow_right,
                                              color: Colors.grey,
                                            ),
                                            counterText: "",
                                            hintText: 'From Date',
                                            isDense: true,
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.purple.shade100),
                                                borderRadius:
                                                    BorderRadius.circular(5))),
                                        initialValue: toDate.toString(),
                                        type: DateTimePickerType.date,

                                        //controller: fromDate,
                                        firstDate: DateTime(1995),
                                        lastDate: DateTime.now()
                                            .add(const Duration(days: 365)),
                                        // This will add one year from current date
                                        validator: (value) {
                                          return null;
                                        },
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            setState(() {
                                              String formattedDate = DateFormat(
                                                      'dd-MM-yyyy')
                                                  .format(
                                                      DateTime.parse(value));
                                              toDate = formattedDate;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: customer,
                            readOnly: true,
                            onTap: (() {
                              dropDialog(context, "Customers");
                            }),
                            decoration: const InputDecoration(
                              labelText: 'Customer',
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.black),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: expireIn,
                            decoration: const InputDecoration(
                              labelText: 'Expiry in Days',
                              prefixIcon: Icon(Icons.calendar_today,
                                  color: Colors.black),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: renewalstatus,
                            readOnly: true,
                            onTap: (() {
                              renewalDropDialog(context, "Renewal Status");
                            }),
                            decoration: const InputDecoration(
                              labelText: 'Renewal Status',
                              prefixIcon: Icon(
                                  Icons.star_border_purple500_sharp,
                                  color: Colors.black),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          Container(
                            height: 40,
                            width: double.maxFinite,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3375e0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: RawMaterialButton(
                              onPressed: () {
                                _resetAndLoadList();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Continue",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  Future<dynamic> dropDialog(BuildContext context, String title) {
    return showDialog(
      context: context,
      builder: (context) {
        return Builder(builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                scrollable: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .6,
                      height: 40,
                      child: TextFormField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 8),
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          labelText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        onChanged: ((value) {
                          if (title == "Customers") {
                            setState(() {
                              filterCustomers(value);
                            });
                          } else {
                            setState(() {
                              filterProducts(value);
                            });
                          }
                        }),
                      ),
                    )
                  ],
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * .4,
                  width: MediaQuery.of(context).size.width * .8,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: title == "Customers"
                        ? filteredNames.length
                        : filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          if (title == "Customers") {
                            customer.text = filteredNames[index].name;
                            clientId = filteredNames[index].id;
                          } else {
                            if (productName.contains(
                                filteredProducts[index].productName)) {
                            } else {
                              products.add(ProductId(
                                prdId: filteredProducts[index].id,
                                prdCost: filteredProducts[index].totalAmount,
                                prdQty: "1",
                                prdName: filteredProducts[index].productName,
                              ));
                              productName
                                  .add(filteredProducts[index].productName);
                            }
                            productCost = 0;

                            for (int i = 0; i < products.length; i++) {
                              productCost += double.parse(products[i].prdCost);
                            }
                            projectCost.text = (productCost).toString();
                          }
                          Navigator.pop(context);
                          setState(() {});
                          filterCustomers("");
                          filterProducts("");
                        },
                        title: SizedBox(
                          width: 200,
                          child: Text(
                            title == "Customers"
                                ? filteredNames[index].name.toString()
                                : filteredProducts[index]
                                    .productName
                                    .toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ));
          });
        });
      },
    );
  }

  Future<void> renewalDropDialog(BuildContext context, String title) async {
    final Map<String, String> options = {
      "1": "Renewed",
      "2": "Not Renewed",
      "3": "Expired",
    };

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.entries.map((entry) {
              return ListTile(
                title: Text(entry.value),
                onTap: () {
                  renewalstatus.text = entry.value; // show label in textfield
                  selectedRenewalValue = entry.key; // store value (1,2,3)
                  Navigator.of(ctx).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  reminderBottomSheet(String id, String contactNo) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Form(
                  key: formKey,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Send Reminder",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          readOnly: true,
                          controller: recieverName,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please EnterName";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          readOnly: true,
                          controller: contactNumber,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Contact Number";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Contact No',
                              prefixIcon: Icon(Icons.phone, color: Colors.grey),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 4.0, bottom: 4.0),
                          child: Text("Reminder Message"),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(template!.data.message),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Container(
                          height: 40,
                          width: double.maxFinite,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3375e0),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: RawMaterialButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await postReminder(id, contactNo);
                            },
                            child: const Text("Send Reminder",
                                style: TextStyle(color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                  )),
            ),
          );
        });
      },
    );
  }

  bulkReminderSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Send Reminder To",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedNames.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 40,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .7,
                                    child: Text(
                                      selectedNames[index],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedIds
                                              .remove(selectedIds[index]);
                                          selectedNames
                                              .remove(selectedNames[index]);
                                        });
                                      },
                                      child: const Icon(Icons.close))
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      height: 40,
                      width: double.maxFinite,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3375e0),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: RawMaterialButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          postBulkReminder();
                        },
                        child: const Text("Send Reminder",
                            style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}

Widget buildLoaderListItem() {
  return Shimmer.fromColors(
      enabled: true,
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 12.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 12.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 96.0,
                    height: 72.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: 100.0,
                          height: 10.0,
                          color: Colors.white,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 12.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 12.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 96.0,
                    height: 72.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: 100.0,
                          height: 10.0,
                          color: Colors.white,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 12.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 12.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 96.0,
                    height: 72.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: 100.0,
                          height: 10.0,
                          color: Colors.white,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ));
}
