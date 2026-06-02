import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/getArchievedInvoiceModel.dart';
import 'package:login2/service/service.dart';
import 'package:lottie/lottie.dart';

class ArchivedInvoicePage extends StatefulWidget {
  final String token;
  const ArchivedInvoicePage({super.key, required this.token});

  @override
  State<ArchivedInvoicePage> createState() => _ArchivedInvoicePageState();
}

class _ArchivedInvoicePageState extends State<ArchivedInvoicePage> {
  GetArchievedInvoiceModel? archivedInvoiceModel;
  bool isLoading = true;
  int page = 1;
  final int pageSize = 50;

  @override
  void initState() {
    super.initState();
    _fetchArchivedInvoices();
  }

  _fetchArchivedInvoices() async {
    setState(() => isLoading = true);
    archivedInvoiceModel = await HttpService.getArchievedInvoice(
      page.toString(),
      pageSize.toString(),
    );
    setState(() => isLoading = false);
  }

  _unhideInvoice(String invoiceId) async {
    final result = await HttpService.unhideInvoice(invoiceId);
    if (result != null && result.status == true) {
      Common.toastMessaage(
          result.message ?? "Invoice Unarchived", Colors.green);
      _fetchArchivedInvoices();
    } else {
      Common.toastMessaage(
          result?.message ?? "Error unarchiving invoice", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ArchievedInvoiceItem> invoiceList = [];
    if (archivedInvoiceModel?.data?.invoices != null) {
      invoiceList = archivedInvoiceModel!.data!.invoices!.values.toList();
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Archived Invoices',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchArchivedInvoices,
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: Lottie.asset('assets/main/loading.json', height: 100))
          : invoiceList.isEmpty
              ? const Center(child: Text("No Archived Invoices Found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: invoiceList.length,
                  itemBuilder: (context, index) {
                    final item = invoiceList[index];
                    return _buildArchivedInvoiceCard(item);
                  },
                ),
    );
  }

  Widget _buildArchivedInvoiceCard(ArchievedInvoiceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.customerName ?? "Unknown Customer",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2a86c9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.paymentStatus ?? "",
                  style: TextStyle(
                    color: item.paymentStatus == "Paid"
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.receipt_long_rounded, "Invoice No",
              '${item.invoiceNumber ?? ""}'),
          _buildInfoRow(Icons.calendar_month_rounded, "Invoice Date",
              item.invoiceDate ?? ""),
          _buildInfoRow(Icons.person_pin_rounded, "Hidden By",
              item.hiddenStaffName ?? ""),
          _buildInfoRow(
              Icons.history_rounded, "Hidden Date", item.hiddenDate ?? ""),
          _buildInfoRow(
              Icons.currency_rupee, "Total Paid", item.totalPaid ?? ""),
          _buildInfoRow(
              Icons.currency_rupee, "Balance", item.balance ?? ""),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Amount",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("₹ ${item.totalPaidAmount ?? '0'}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2a86c9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () => _showUnhideConfirmation(item),
                icon: const Icon(Icons.unarchive_rounded, size: 18),
                label: const Text("Unhide"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text("$label: ",
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showUnhideConfirmation(ArchievedInvoiceItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Unhide"),
        content: Text(
            "Are you sure you want to unhide invoice ${item.invoiceNumber}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2a86c9)),
            onPressed: () {
              Navigator.pop(context);
              _unhideInvoice(item.id ?? "");
            },
            child: const Text("Unhide", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
