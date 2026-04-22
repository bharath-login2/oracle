import 'package:flutter/material.dart';
import 'package:login2/models/lead_management/expiredListModel.dart';
import 'package:login2/screens/rental/addRentalReturnPage.dart';
import 'package:login2/screens/rental/rentIssueDetailsPage.dart';
import 'package:login2/service/service.dart';

class ExpiredListPage extends StatefulWidget {
  final String token;
  const ExpiredListPage({super.key, required this.token});

  @override
  State<ExpiredListPage> createState() => _ExpiredListPageState();
}

class _ExpiredListPageState extends State<ExpiredListPage> {
  ExpiredListModel? _expiredData;
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExpiredList();
  }

  Future<void> _loadExpiredList() async {
    setState(() => _isLoading = true);
    try {
      final data = await HttpService.expiredList();
      setState(() {
        _expiredData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading expired list: $e')),
      );
    }
  }

  List<ExpiredItem> _getFilteredList() {
    if (_expiredData == null || _expiredData!.data == null || _expiredData!.data!.list == null) {
      return [];
    }

    List<ExpiredItem> list = _expiredData!.data!.list!;

    if (_searchQuery.isNotEmpty) {
      list = list.where((item) {
        return (item.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (item.rentId?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (item.products?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Expired List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadExpiredList,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return _buildExpiredCard(filteredList[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF2a86c9),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
          decoration: InputDecoration(
            hintText: 'Search by customer, rent ID...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildExpiredCard(ExpiredItem item) {
    return InkWell(
      onTap: () {
        if (item.rentId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RentIssueDetailsPage(rentId: item.rentId!),
            ),
          ).then((_) => _loadExpiredList());
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF2a86c9).withOpacity(0.15),
                    radius: 26,
                    child: const Icon(
                      Icons.history_toggle_off,
                      color: Color(0xFF2a86c9),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.customerName ?? 'Unknown Customer',
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rent Id: ${item.rentId ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Products: ${item.products ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${item.totalAmount ?? 0}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade700.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning, size: 14, color: Colors.red.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Expired',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 4),
                      // PopupMenuButton<String>(
                      //   icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                      //   padding: EdgeInsets.zero,
                      //   constraints: const BoxConstraints(),
                      //   onSelected: (value) {
                      //     if (value == 'details' && item.rentId != null) {
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (_) => RentIssueDetailsPage(rentId: item.rentId!),
                      //         ),
                      //       ).then((_) => _loadExpiredList());
                      //     }
                      //   },
                      //   itemBuilder: (context) => [
                      //     const PopupMenuItem(
                      //       value: 'details',
                      //       child: Row(
                      //         children: [
                      //           Icon(Icons.visibility_outlined, size: 18, color: Colors.blue),
                      //           SizedBox(width: 8),
                      //           Text('View Details'),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 0.6, color: Colors.black12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.orange.shade700, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Expired: ${item.daysExpired ?? 0} days ago',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddRentalReturnPage(
                            customerId: item.customerId,
                            customerName: item.customerName,
                            rentId: item.rentId,
                          ),
                        ),
                      ).then((value) {
                        if (value == true) {
                          _loadExpiredList();
                        }
                      });
                    },
                    icon: const Icon(Icons.reset_tv_rounded, size: 14),
                    label: const Text('Return', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No expired items found',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ? 'Try adjusting your search' : 'All caught up!',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Text('Clear Search', style: TextStyle(color: Color(0xFF2a86c9))),
            ),
          ],
        ],
      ),
    );
  }
}
