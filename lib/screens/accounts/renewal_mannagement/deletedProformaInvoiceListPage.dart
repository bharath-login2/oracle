import 'package:flutter/material.dart';
import 'package:login2/screens/accounts/renewal_mannagement/deletedProformaInvoiceList.dart';
import 'package:login2/screens/accounts/renewal_mannagement/restoreInvoicesModel.dart';
import 'package:login2/service/service.dart';

class DeletedProformaInvoiceListPage extends StatefulWidget {
  final String token;
  const DeletedProformaInvoiceListPage(this.token, {super.key});

  @override
  State<DeletedProformaInvoiceListPage> createState() =>
      _DeletedProformaInvoiceListPageState();
}

class _DeletedProformaInvoiceListPageState
    extends State<DeletedProformaInvoiceListPage> {
  DeletedProformaInvoiceList? deletedProformaList;
  List<DeletedProformaInvoice> filteredList = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() => isLoading = true);
    deletedProformaList = await HttpService.getDeletedProformaInvoiceList();
    if (deletedProformaList != null) {
      filteredList = List.from(deletedProformaList!.data);
    }
    setState(() => isLoading = false);
  }

  void filterList(String value) {
    setState(() {
      if (deletedProformaList != null) {
        if (value.isEmpty) {
          filteredList = List.from(deletedProformaList!.data);
        } else {
          filteredList = deletedProformaList!.data
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
    RestoreInvoices? response = await HttpService.restoreDeletedProforma(id);
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
          'Deleted Proforma Invoices',
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
                  hintText: 'Search proforma or customer...',
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item.status.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDetailRow(Icons.receipt_long,
                                      "Proforma No", item.invoiceNo),
                                  _buildDetailRow(Icons.currency_rupee,
                                      "Amount", "₹ ${item.amount}"),
                                  _buildDetailRow(Icons.person_pin_outlined,
                                      "Staff", item.staffName),
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
            "No deleted proforma invoices found",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(DeletedProformaInvoice item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Restore Proforma"),
        content: Text(
            "Are you sure you want to restore proforma ${item.invoiceNo}?"),
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
