import 'package:flutter/material.dart';
import 'package:login2/screens/accounts/renewal_mannagement/getDeletedInvoiceList.dart';
import 'package:login2/screens/accounts/renewal_mannagement/restoreInvoicesModel.dart';
import 'package:login2/service/service.dart';

class DeletedInvoiceListPage extends StatefulWidget {
  final String token;
  const DeletedInvoiceListPage(this.token, {super.key});

  @override
  State<DeletedInvoiceListPage> createState() => _DeletedInvoiceListPageState();
}

class _DeletedInvoiceListPageState extends State<DeletedInvoiceListPage> {
  GetDeletedInvoiceList? deletedInvoiceList;
  List<DeletedInvoice> filteredList = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() => isLoading = true);
    deletedInvoiceList = await HttpService.getDeletedInvoiceList();
    if (deletedInvoiceList != null) {
      filteredList = List.from(deletedInvoiceList!.data);
    }
    setState(() => isLoading = false);
  }

  void filterList(String value) {
    setState(() {
      if (deletedInvoiceList != null) {
        if (value.isEmpty) {
          filteredList = List.from(deletedInvoiceList!.data);
        } else {
          filteredList = deletedInvoiceList!.data
              .where((item) =>
                  item.customerName
                      .toLowerCase()
                      .contains(value.toLowerCase()) ||
                  item.invoiceNo.toLowerCase().contains(value.toLowerCase()))
              .toList();
        }
      }
    });
  }

  void restoreItem(String id) async {
    RestoreInvoices? response = await HttpService.restoreDeletedInvoice(id);
    if (response != null && response.status == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      getData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response?.message ?? "Restore failed"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2a86c9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Deleted Invoices',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterList,
                decoration: InputDecoration(
                  hintText: 'Search invoice or customer...',
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF2a86c9)),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.customerName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      _buildStatusBadge(item.paymentStatus),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDetailRow(Icons.receipt_long,
                                      "Invoice No", item.invoiceNo),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: _buildDetailRow(
                                              Icons.currency_rupee,
                                              "Total",
                                              "₹ ${item.totalAmount}")),
                                      Expanded(
                                          child: _buildDetailRow(
                                              Icons.check_circle_outline,
                                              "Paid",
                                              "₹ ${item.paidAmount}")),
                                    ],
                                  ),
                                  _buildDetailRow(
                                      Icons.account_balance_wallet_outlined,
                                      "Balance",
                                      "₹ ${item.balance}"),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Deleted by: ${item.deletedBy}",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600]),
                                          ),
                                          Text(
                                            item.deletedAt,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _showRestoreDialog(item),
                                        icon: const Icon(Icons.restore_page,
                                            size: 18),
                                        label: const Text("Restore"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade50,
                                          foregroundColor: Colors.blue.shade700,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isPaid = status.toLowerCase() == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: isPaid ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No deleted invoices found",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(DeletedInvoice item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Restore Invoice"),
        content:
            Text("Are you sure you want to restore invoice ${item.invoiceNo}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              restoreItem(item.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2a86c9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Restore"),
          ),
        ],
      ),
    );
  }
}
