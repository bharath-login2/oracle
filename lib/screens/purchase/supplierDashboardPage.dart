import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/supplierDetailsModel.dart';
import 'package:login2/models/lead_management/purchaseBillModel.dart';
import 'package:login2/models/lead_management/getSupplierDashboardModel.dart';
import 'package:login2/models/lead_management/getSupplierLedgerModel.dart';
import 'package:login2/screens/purchase/purchaseBillPage.dart';
import 'package:login2/service/service.dart';

class SupplierDashboardPage extends StatefulWidget {
  final SupplierData supplier;
  const SupplierDashboardPage({
    super.key,
    required this.supplier,
  });

  @override
  State<SupplierDashboardPage> createState() => _SupplierDashboardPageState();
}

class _SupplierDashboardPageState extends State<SupplierDashboardPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isProfileExpanded = false;
  SupplierDashboardData? _dashboardData;
  SupplierLedgerData? _ledgerData;
  String _token = "";
  String _name = "";
  String _userId = "";

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchSupplierData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchUserDetails() async {
    _token = await Common.getSharedPref("token") ?? "";
    _name = await Common.getSharedPref("name") ?? "";
    _userId = await Common.getSharedPref("userId") ?? "";
  }

  Future<void> _fetchSupplierData() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await HttpService.getSupplierDashboard(widget.supplier.id ?? "");
      final ledgerResponse =
          await HttpService.getSupplierLedger(widget.supplier.id ?? "");

      if (mounted) {
        setState(() {
          if (response != null && response.data != null) {
            _dashboardData = response.data;
          }
          if (ledgerResponse != null && ledgerResponse.data != null) {
            _ledgerData = ledgerResponse.data;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Common.toastMessaage("Failed to load details", Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Supplier Dashboard",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          //centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2a86c9),
                  Color(0xFF1e5c8c),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildModernHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildOverviewTab(),
                    _buildLedgerTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 60, 197, 251),
                        Color.fromARGB(255, 26, 112, 170)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3C87C9).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.supplier.supplierName?.isNotEmpty == true
                          ? widget.supplier.supplierName![0].toUpperCase()
                          : "B",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.supplier.supplierName ?? "BABU",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isProfileExpanded = !_isProfileExpanded;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _isProfileExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 20,
                                color: const Color(0xFF6B7280),
                              ),
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
        // Collapsible Profile Details
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _isProfileExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileDetailRow(
                    Icons.person_outline,
                    "Contact Person",
                    widget.supplier.contactPerson ?? "N/A",
                    const Color(0xFF8B5CF6)),
                const SizedBox(height: 12),
                _buildProfileDetailRow(
                    Icons.phone_outlined,
                    "Phone Number",
                    widget.supplier.contactNo ?? "N/A",
                    const Color(0xFF10B981)),
                const SizedBox(height: 12),
                _buildProfileDetailRow(Icons.location_on_outlined, "Address",
                    widget.supplier.address ?? "N/A", const Color(0xFFF59E0B)),
                const SizedBox(height: 12),
                _buildProfileDetailRow(
                    Icons.account_balance_outlined,
                    "Bank Account",
                    "${widget.supplier.accNo ?? 'N/A'} (IFSC: ${widget.supplier.ifscCode ?? 'N/A'})",
                    const Color(0xFFEC4899)),
                const SizedBox(height: 12),
                _buildProfileDetailRow(
                    Icons.receipt_long_outlined,
                    "GST Number",
                    widget.supplier.gstNo ?? "N/A",
                    const Color(0xFF0EA5E9)),
                    const SizedBox(height: 12),
                _buildProfileDetailRow(
                    Icons.person_outline,
                    "Inter or Other state",
                    widget.supplier.supplierType ?? "N/A",
                    const Color(0xFF0EA5E9)),
              ],
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildProfileDetailRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: const TabBar(
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 60, 197, 251),
              Color.fromARGB(255, 26, 112, 170)
            ],
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xFF9CA3AF),
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: "  OVERVIEW  "),
          Tab(text: "  LEDGER  "),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  "Purchase Bill Payment",
                  "₹${_dashboardData?.totalPurchase ?? '0.00'}",
                  Icons.receipt,
                  const Color(0xFF8B5CF6),
                  const Color(0xFFEDE9FE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  "Total adv.paid",
                  "${_dashboardData?.totalAdvance ?? '0'}",
                  Icons.receipt_long,
                  const Color(0xFF10B981),
                  const Color(0xFFD1FAE5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            "Available to redeem",
            "₹${_dashboardData?.availableToRedeem ?? '0.00'}",
            Icons.account_balance_wallet,
            const Color(0xFFF59E0B),
            const Color(0xFFFEF3C7),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Purchases",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PurchaseBillPage(
                        token: _token,
                        name: _name,
                        userId: _userId,
                        initialSearchQuery: widget.supplier.supplierName,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecentPurchasesList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String amount, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPurchasesList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final recent = _dashboardData?.recentPurchases ?? [];

    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              "No purchases yet",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recent.length > 5 ? 5 : recent.length,
      itemBuilder: (context, index) {
        final bill = recent[index];
        return _buildRecentPurchaseItem(bill);
      },
    );
  }

  Widget _buildRecentPurchaseItem(RecentPurchase bill) {
    double payable = double.tryParse(bill.payableAmount ?? '0') ?? 0;
    double paid = double.tryParse(bill.totalPaid ?? '0') ?? 0;

    String status = 'unpaid';
    if (paid >= payable && payable > 0) {
      status = 'paid';
    } else if (paid > 0) {
      status = 'partial';
    }

    Color statusColor;
    Color statusBgColor;

    if (status == 'paid') {
      statusColor = const Color(0xFF10B981);
      statusBgColor = const Color(0xFFD1FAE5);
    } else if (status == 'unpaid') {
      statusColor = const Color(0xFFEF4444);
      statusBgColor = const Color(0xFFFEE2E2);
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusBgColor = const Color(0xFFFEF3C7);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt, size: 20, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bill ${bill.invoiceNo ?? 'N/A'}",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bill.billDate ?? 'Unknown Date',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${bill.totAmount ?? '0'}",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: statusColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn("Payable", "₹${bill.payableAmount ?? '0'}"),
                Container(width: 1, height: 30, color: Colors.grey.shade200),
                _buildDetailColumn("Paid", "₹${bill.totalPaid ?? '0'}"),
                Container(width: 1, height: 30, color: Colors.grey.shade200),
                _buildDetailColumn("Balance", "₹${bill.balanceAmount ?? '0'}",
                    isBalance: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value,
      {bool isBalance = false}) {
    bool hasBalance = isBalance &&
        value != '₹0' &&
        value != '₹0.0' &&
        value != '₹0.00' &&
        value != '₹0.000';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color:
                hasBalance ? const Color(0xFFEF4444) : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_ledgerData == null) {
      return const Center(
        child: Text("No ledger data available"),
      );
    }

    final ledger = _ledgerData!.ledger ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ledger Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Current Balance",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "₹${_ledgerData!.balance ?? '0.00'}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildLedgerSummaryColumn(
                        "Total Debit",
                        "₹${_ledgerData!.totalDebit ?? '0.00'}",
                        const Color(0xFFEF4444),
                      ),
                    ),
                    Container(
                        width: 1, height: 40, color: Colors.grey.shade200),
                    Expanded(
                      child: _buildLedgerSummaryColumn(
                        "Total Credit",
                        "₹${_ledgerData!.totalCredit ?? '0.00'}",
                        const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Transactions",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          if (ledger.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  "No transactions yet",
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ledger.length,
              itemBuilder: (context, index) {
                return _buildLedgerEntryItem(ledger[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLedgerSummaryColumn(
      String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerEntryItem(LedgerEntry entry) {
    double debit = double.tryParse(entry.debit ?? '0') ?? 0;
    double credit = double.tryParse(entry.credit ?? '0') ?? 0;

    bool isCredit = credit > 0;
    String amount = isCredit ? "+ ₹$credit" : "- ₹$debit";
    Color amountColor =
        isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    Color bgColor =
        isCredit ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
    IconData icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: amountColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title ??
                          (isCredit ? 'Payment Received' : 'Bill Generated'),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.date ?? 'Unknown Date',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: amountColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildDetailColumn(
                      "Created By", entry.createdByName ?? entry.createdByName ?? ''),
                ),
                Container(width: 1, height: 30, color: Colors.grey.shade200),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: _buildDetailColumn(
                        "Created At",
                        entry.createdDate ?? ''),
                  ),
                ),
              ],
            ),
          ),
          if (entry.remarks != null && entry.remarks!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Remarks",
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.remarks!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1F2937),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
