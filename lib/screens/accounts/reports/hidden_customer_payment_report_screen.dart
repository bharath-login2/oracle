import 'package:flutter/material.dart';
import 'package:login2/models/customers/customerHiddenPaymentReport.dart';
import 'package:login2/service/service.dart';

class HiddenCustomerPaymentReportScreen extends StatefulWidget {
  const HiddenCustomerPaymentReportScreen({super.key});

  @override
  State<HiddenCustomerPaymentReportScreen> createState() =>
      _HiddenCustomerPaymentReportScreenState();
}

class _HiddenCustomerPaymentReportScreenState
    extends State<HiddenCustomerPaymentReportScreen> {
  bool isLoading = true;
  List<CustomerHiddenPaymentData> reportList = [];
  List<CustomerHiddenPaymentData> filteredList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    final response = await HttpService.hiddenCustomerPaymentReport();
    if (response != null && response.status == true) {
      setState(() {
        reportList = response.data ?? [];
        filteredList = reportList;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void filterSearch(String query) {
    setState(() {
      filteredList = reportList
          .where((element) => (element.accountName ?? '')
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> unhideReport(String accountId) async {
    final response =
        await HttpService.unhideHiddencustomerPaymentReport(accountId);
    if (!mounted) return;
    if (response != null && response.status == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Report restored successfully'),
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
          content: Text(response?.message ?? 'Failed to restore report'),
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
          'Hidden Reports',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Section
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
            child: TextField(
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
                  borderSide:
                      const BorderSide(color: Color(0xFF2a86c9), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
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
                      '${filteredList.length} hidden ${filteredList.length == 1 ? 'record' : 'records'}',
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
                                Icons.visibility_off_outlined,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hidden reports found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
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
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Main Info Row
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Avatar
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

                                      // Name and Info
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
                                            const SizedBox(height: 4),
                                            Text(
                                              'ID: ${item.accountId ?? "N/A"}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                            Text(
                                              'Hidden by: ${item.hiddenByName ?? "N/A"}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Amount
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: amountColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '$amountPrefix ₹ ${absAmount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: amountColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),

                                  // Action Button
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildActionButton(
                                          icon: Icons.visibility_outlined,
                                          label: 'Restore to List',
                                          color: Colors.green,
                                          onTap: () {
                                            _showUnhideConfirmationDialog(item);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnhideConfirmationDialog(CustomerHiddenPaymentData item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.visibility, color: Colors.green, size: 24),
            ),
            const SizedBox(width: 10),
            const Text(
              'Unhide Report',
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
              'Are you sure you want to Restore the report?',
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
              unhideReport(item.accountId ?? '');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2a86c9),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Unhide Report'),
          ),
        ],
      ),
    );
  }
}
