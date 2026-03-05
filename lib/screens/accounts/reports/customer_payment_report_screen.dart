import 'package:flutter/material.dart';
import 'package:login2/models/customers/customerPaymentReportModel.dart';
import 'package:login2/screens/accounts/reports/hidden_customer_payment_report_screen.dart';
import 'package:login2/screens/accounts/dashboard/bank_account.dart';
import 'package:login2/service/service.dart';

class CustomerPaymentReportScreen extends StatefulWidget {
  final String? fDate;
  final String? tDate;
  const CustomerPaymentReportScreen({super.key, this.fDate, this.tDate});

  @override
  State<CustomerPaymentReportScreen> createState() =>
      _CustomerPaymentReportScreenState();
}

class _CustomerPaymentReportScreenState
    extends State<CustomerPaymentReportScreen> {
  bool isLoading = true;
  List<CustomerPaymentData> reportList = [];
  List<CustomerPaymentData> filteredList = [];
  TextEditingController searchController = TextEditingController();
  String selectedFilter = 'All';

  final List<String> filterOptions = [
    'All',
    'With Pending',
    'Zero Balance',
    'Negative Balance'
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    final response = await HttpService.customerPaymentReport(
      fromDate: widget.fDate,
      toDate: widget.tDate,
    );
    if (response != null && response.status == true) {
      setState(() {
        reportList = response.data ?? [];
        applyFilter();
        isLoading = false;
      });
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

    // Apply category filter
    // switch (selectedFilter) {
    //   case 'With Pending':
    //     temp = temp.where((item) {
    //       final amount =
    //           num.tryParse(item.pendingAmount?.toString() ?? '0') ?? 0;
    //       return amount > 0;
    //     }).toList();
    //     break;
    //   case 'Zero Balance':
    //     temp = temp.where((item) {
    //       final amount =
    //           num.tryParse(item.pendingAmount?.toString() ?? '0') ?? 0;
    //       return amount == 0;
    //     }).toList();
    //     break;
    //   case 'Negative Balance':
    //     temp = temp.where((item) {
    //       final amount =
    //           num.tryParse(item.pendingAmount?.toString() ?? '0') ?? 0;
    //       return amount < 0;
    //     }).toList();
    //     break;
    // }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Report hidden successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response?.message ?? 'Failed to hide report'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Color _getAmountColor(num? amount) {
    if (amount == null) return Colors.grey;
    if (amount > 0) return Colors.green;
    if (amount < 0) return Colors.red;
    return Colors.grey;
  }

  String _getAmountPrefix(num? amount) {
    if (amount == null) return '';
    if (amount > 0) return '+';
    if (amount < 0) return '-';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2a86c9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Reports',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
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
                    Icon(Icons.visibility_off,
                        color: Color(0xFF2a86c9), size: 20),
                    SizedBox(width: 10),
                    Text('Hidden Reports'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: searchController,
                  onChanged: filterSearch,
                  decoration: InputDecoration(
                    hintText: 'Search by customer name...',
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF2a86c9), size: 22),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                size: 20, color: Colors.grey),
                            onPressed: () {
                              searchController.clear();
                              filterSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF2a86c9), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                // const SizedBox(height: 12),
                // Filter Chips
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: filterOptions.map((filter) {
                //       bool isSelected = selectedFilter == filter;
                //       return Padding(
                //         padding: const EdgeInsets.only(right: 8),
                //         child: FilterChip(
                //           selected: isSelected,
                //           label: Text(filter),
                //           labelStyle: TextStyle(
                //             color: isSelected
                //                 ? Colors.white
                //                 : const Color(0xFF2D3142),
                //             fontSize: 13,
                //             fontWeight: isSelected
                //                 ? FontWeight.w600
                //                 : FontWeight.normal,
                //           ),
                //           backgroundColor: Colors.grey[100],
                //           selectedColor: const Color(0xFF2a86c9),
                //           checkmarkColor: Colors.white,
                //           padding: const EdgeInsets.symmetric(
                //               horizontal: 10, vertical: 8),
                //           onSelected: (selected) {
                //             setState(() {
                //               selectedFilter = filter;
                //               applyFilter();
                //             });
                //           },
                //         ),
                //       );
                //     }).toList(),
                //   ),
                // ),
              ],
            ),
          ),

          // Stats Summary
          if (!isLoading && filteredList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a86c9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${filteredList.length} ${filteredList.length == 1 ? 'record' : 'records'}',
                      style: const TextStyle(
                        color: Color(0xFF2a86c9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main Content
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2a86c9)),
                    ),
                  )
                : filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[100],
                              ),
                              child: Icon(
                                Icons.payment_outlined,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No reports found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filter',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          final amount = num.tryParse(
                                  item.pendingAmount?.toString() ?? '0') ??
                              0;
                          final amountColor = _getAmountColor(amount);
                          final amountPrefix = _getAmountPrefix(amount);
                          final absAmount = amount.abs();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
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
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Main Info Row
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Avatar/Initial
                                        Container(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF2a86c9)
                                                    .withOpacity(0.8),
                                                const Color(0xFF406dbe)
                                                    .withOpacity(0.8),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              (item.accountName ?? '?')
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.accountName ?? 'N/A',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF2D3142),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      'Last Payment Date: ${item.lastPaymentDate ?? "N/A"}',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  if (item.paymentHidden == '1')
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: const Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .visibility_off,
                                                            size: 10,
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                          SizedBox(width: 2),
                                                          Text(
                                                            'Hidden',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.orange,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Amount & Actions
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: amountColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '$amountPrefix ₹ ${absAmount.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  color: amountColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_vert,
                                                  color: Colors.grey, size: 20),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onSelected: (value) {
                                                if (value == 'details') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          BankAccount(
                                                        accId: item.accountId ??
                                                            '',
                                                        accName:
                                                            item.accountName ??
                                                                '',
                                                      ),
                                                    ),
                                                  );
                                                } else if (value == 'hide') {
                                                  _showHideConfirmationDialog(
                                                      item);
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'details',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.list_alt,
                                                          size: 18,
                                                          color: Color(
                                                              0xFF2a86c9)),
                                                      SizedBox(width: 10),
                                                      Text('Statement'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'hide',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.visibility_off,
                                                          size: 18,
                                                          color: Colors.orange),
                                                      SizedBox(width: 10),
                                                      Text('Hide Report'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showHideConfirmationDialog(CustomerPaymentData item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.visibility_off,
                  color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 10),
            const Text(
              'Hide Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to hide the report?',
              style: TextStyle(color: Colors.grey[600]),
            ),
            // const SizedBox(height: 8),
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     color: Colors.grey[50],
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         item.accountName ?? 'N/A',
            //         style: const TextStyle(
            //           fontWeight: FontWeight.w600,
            //           fontSize: 15,
            //         ),
            //       ),
            //       const SizedBox(height: 4),
            //       Text(
            //         'ID: ${item.accountId}',
            //         style: TextStyle(
            //           fontSize: 13,
            //           color: Colors.grey[500],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              hideReport(item.accountId ?? '');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Hide Report'),
          ),
        ],
      ),
    );
  }
}
