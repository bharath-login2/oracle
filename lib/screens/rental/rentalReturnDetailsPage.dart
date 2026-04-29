import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/getRentalViewModel.dart';
import 'package:login2/screens/rental/addRentalReturnPage.dart';
import 'package:login2/service/service.dart';

class RentalReturnDetailsPage extends StatefulWidget {
  final String returnId;
  const RentalReturnDetailsPage({super.key, required this.returnId});

  @override
  State<RentalReturnDetailsPage> createState() => _RentalReturnDetailsPageState();
}

class _RentalReturnDetailsPageState extends State<RentalReturnDetailsPage> {
  bool _isLoading = true;
  GetRentalViewModel? _details;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    final response = await HttpService.getRentalReturnView(widget.returnId);
    setState(() {
      _details = response;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Rental Return Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_details != null && _details!.data?.rentReturn != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddRentalReturnPage(
                      returnId: _details!.data!.rentReturn!.id,
                      customerName: _details!.data!.rentReturn!.customerName,
                    ),
                  ),
                ).then((value) {
                  _fetchDetails();
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _details == null || _details!.status != true || _details!.data?.rentReturn == null
              ? _buildErrorView()
              : _buildDetailsContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(_details?.message ?? "Failed to load details"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchDetails,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr, {bool includeTime = false}) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      DateTime dateTime;
      if (dateStr.contains(" ")) {
        dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateStr);
      } else {
        dateTime = DateFormat("yyyy-MM-dd").parse(dateStr);
      }
      return DateFormat(includeTime ? "dd-MM-yyyy HH:mm" : "dd-MM-yyyy")
          .format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildDetailsContent() {
    final rentReturn = _details!.data!.rentReturn!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: "Return Information",
            icon: Icons.receipt_long_outlined,
            children: [
              _buildDetailRow("Return No", rentReturn.returnNo ?? ""),
              _buildDetailRow("Invoice No", rentReturn.invoiceNo ?? ""),
              _buildDetailRow("Return Date", _formatDate(rentReturn.returnDate)),
              _buildDetailRow("Issued Date", _formatDate(rentReturn.issuedDate)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: "Customer & Site Details",
            icon: Icons.person_outline,
            children: [
              _buildDetailRow("Customer", rentReturn.customerName ?? ""),
              _buildDetailRow("Work Site", rentReturn.locationName ?? ""),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: "Financial Summary",
            icon: Icons.account_balance_wallet_outlined,
            children: [
              _buildDetailRow("Sub Total", "₹ ${rentReturn.subTotal ?? '0.00'}"),
              _buildDetailRow("Discount", "₹ ${rentReturn.discount ?? '0.00'}",
                  color: Colors.orange),
              _buildDetailRow("Other Expenses", "₹ ${rentReturn.otherExpenses ?? '0.00'}"),
              _buildDetailRow("Advance Amount", "₹ ${rentReturn.advanceAmount ?? '0.00'}"),
              const Divider(height: 24),
              _buildDetailRow("Grand Total", "₹ ${rentReturn.grandTotal ?? '0.00'}",
                  isBold: true, color: const Color(0xFF2a86c9)),
            ],
          ),
          const SizedBox(height: 16),
          if (_details!.data!.items != null && _details!.data!.items!.isNotEmpty)
            _buildProductsSection(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2a86c9), size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142))),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? const Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    final items = _details!.data!.items!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text("Returned Products",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142))),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index] as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.inventory_2_outlined,
                            color: Colors.blue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['product_name'] ?? "Product ID: ${item['product_id'] ?? 'N/A'}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("Returned Qty: ${item['returned_qty'] ?? '0'} | Rate: ₹${item['rate_per_day'] ?? '0.00'}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      Text("₹ ${item['total'] ?? '0.00'}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF2a86c9))),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
