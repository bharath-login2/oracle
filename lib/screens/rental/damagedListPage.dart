import 'package:flutter/material.dart';
import 'package:login2/models/lead_management/damagedListApiModel.dart';
import 'package:login2/screens/rental/addRentalReturnPage.dart';
import 'package:login2/screens/rental/rentIssueListPage.dart';
import 'package:login2/service/service.dart';

class DamagedListPage extends StatefulWidget {
  final String token;
  const DamagedListPage({super.key, required this.token});

  @override
  State<DamagedListPage> createState() => _DamagedListPageState();
}

class _DamagedListPageState extends State<DamagedListPage> {
  bool _isLoading = true;
  List<DamagedReturnItem> _damagedItems = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDamagedList();
  }

  Future<void> _loadDamagedList() async {
    setState(() => _isLoading = true);
    try {
      final response = await HttpService.damagedListApi('', '');
      if (response != null && response.status) {
        setState(() {
          _damagedItems = response.data;
        });
      }
    } catch (e) {
      debugPrint('Error loading damaged list: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _damagedItems.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.customerName.toLowerCase().contains(query) ||
             item.products.toLowerCase().contains(query) ||
             item.returnId.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Damaged Items List', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildHeader(),
              Positioned(
                left: 0,
                right: 0,
                bottom: -25,
                child: _buildSearchBar(),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : filteredItems.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadDamagedList,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            return _buildDamagedCard(filteredItems[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRentalReturnPage()),
          ).then((_) => _loadDamagedList());
        },
        backgroundColor: const Color(0xFF2a86c9),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text('Add Damaged', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF2a86c9),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text(
          //   'Track and manage',
          //   style: TextStyle(color: Colors.white70, fontSize: 14),
          // ),
          // const SizedBox(height: 4),
          // Text(
          //   '${_damagedItems.length} Damaged Records',
          //   style: const TextStyle(
          //     color: Colors.white,
          //     fontSize: 22,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search by customer or product...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF2a86c9)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDamagedCard(DamagedReturnItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                color: Colors.redAccent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.customerName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          _buildStatusBadge('Damaged'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.inventory_2_outlined, 'Products', item.products),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              Icons.error_outline, 
                              'Damaged Count', 
                              item.damagedCount,
                              valueColor: Colors.red.shade700,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoRow(
                              Icons.payments_outlined, 
                              'Total Amount', 
                              '₹${item.totalAmount}',
                              valueColor: const Color(0xFF2a86c9),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddRentalReturnPage(),
                                ),
                              ).then((_) => _loadDamagedList());
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            icon: Icons.delete_outline,
                            label: 'Delete',
                            color: Colors.red,
                            onTap: () {
                              _showDeleteConfirmation(item);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$label: ',
              style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: valueColor ?? const Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Colors.red.shade700,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF2a86c9)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No damaged items found',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or add a new record',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(DamagedReturnItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Are you sure you want to delete the damaged record for ${item.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete functionality not yet implemented by API')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
