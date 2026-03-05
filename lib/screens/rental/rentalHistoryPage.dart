import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/rental/rentalReportHistoryModel.dart';
import 'package:login2/service/service.dart';

class RentalHistoryPage extends StatefulWidget {
  final String rentIssueId;
  const RentalHistoryPage({super.key, required this.rentIssueId});

  @override
  State<RentalHistoryPage> createState() => _RentalHistoryPageState();
}

class _RentalHistoryPageState extends State<RentalHistoryPage> {
  RentalReportHistoryModel? _historyData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final data = await HttpService.getRentalReportHistory(widget.rentIssueId);
    setState(() {
      _historyData = data;
      _isLoading = false;
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Rental History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        //  centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A86C9)),
              ),
            )
          : _historyData == null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  color: const Color(0xFF2A86C9),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatusHeader(),
                        const SizedBox(height: 16),
                        _buildInfoSection(),
                        const SizedBox(height: 16),
                        _buildItemsSection(),
                        const SizedBox(height: 16),
                        if (_historyData!.data.rentReturn.isNotEmpty)
                          _buildReturnSection(),
                        if (_historyData!.data.rentReturn.isNotEmpty)
                          const SizedBox(height: 16),
                        _buildPaymentSection(),
                        // const SizedBox(height: 16),
                        // _buildFooter(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatusHeader() {
    final rentIssue = _historyData!.data.rentIssue;
    final payment = _historyData!.data.paymentSummary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A86C9), Color(0xFF1E5A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A86C9).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rent ${rentIssue.rentNo}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Invoice ${rentIssue.invoiceNo}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      payment.balanceAmount > 0
                          ? Icons.pending
                          : Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      payment.balanceAmount > 0 ? 'Pending' : 'Completed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusItem(
                'Total Amount',
                '₹${rentIssue.grandTotal}',
                Icons.currency_rupee,
              ),
              Container(
                  width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
              _buildStatusItem(
                'Paid',
                '₹${rentIssue.amountPaid}',
                Icons.payment,
              ),
              Container(
                  width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
              _buildStatusItem(
                'Balance',
                '₹${payment.balanceAmount.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                highlight: payment.balanceAmount > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon,
      {bool highlight = false}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: highlight ? Colors.amber : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final rentIssue = _historyData!.data.rentIssue;

    return _buildCard(
      title: 'Rent Information',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _buildInfoRow(
            Icons.person_outline,
            'Customer',
            rentIssue.customerName,
            Icons.location_on_outlined,
            'Location',
            rentIssue.locationName,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'From Date',
            _formatDate(rentIssue.fromDate),
            Icons.calendar_today_outlined,
            'To Date',
            _formatDate(rentIssue.toDate),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A86C9).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFF2A86C9).withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChip(
                    'Total Days', '${rentIssue.totalDays} Days', Icons.timer),
                _buildChip(
                    'Advance', '₹${rentIssue.advanceAmount}', Icons.money),
                _buildChip('Staff', rentIssue.collectedStaffName,
                    Icons.person_outline),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon1,
    String label1,
    String value1,
    IconData icon2,
    String label2,
    String value2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon1, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label1, style: _labelStyle),
                    const SizedBox(height: 2),
                    Text(value1, style: _valueStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Icon(icon2, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label2, style: _labelStyle),
                    const SizedBox(height: 2),
                    Text(value2, style: _valueStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2A86C9)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A86C9),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    final items = _historyData!.data.rentItems;
    final rentIssue = _historyData!.data.rentIssue;

    return _buildCard(
      title: 'Rented Items',
      icon: Icons.shopping_bag_outlined,
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A86C9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF2A86C9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildItemChip('Qty: ${item.qty}'),
                            const SizedBox(width: 8),
                            _buildItemChip('${item.days} days'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${item.total}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2A86C9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${item.unitPrice}/day',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildTotalRow('Sub Total', '₹${rentIssue.subTotal}'),
                const SizedBox(height: 8),
                _buildTotalRow('GST', '₹${rentIssue.gstTotal}'),
                const SizedBox(height: 8),
                _buildTotalRow('Discount', '-₹${rentIssue.discount}',
                    highlight: true),
                const SizedBox(height: 8),
                _buildTotalRow('Other Expenses', '₹${rentIssue.otherExpenses}'),
                const Divider(height: 16),
                _buildTotalRow('Grand Total', '₹${rentIssue.grandTotal}',
                    isBold: true, color: const Color(0xFF2A86C9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value,
      {bool isBold = false, bool highlight = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: highlight ? Colors.green : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? (highlight ? Colors.green : Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildItemChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildReturnSection() {
    return _buildCard(
      title: 'Return Details',
      icon: Icons.assignment_return_outlined,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              const SizedBox(height: 8),
              Text(
                'Items Returned Successfully',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    final invoices = _historyData!.data.invoice;
    final payment = _historyData!.data.paymentSummary;

    return _buildCard(
      title: 'Payment History',
      icon: Icons.payments_outlined,
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invoices.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.payment,
                          color: Colors.green, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice #${invoice.invoiceNo}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(invoice.paymentDate),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${invoice.amountPaid}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: invoice.paymentStatus == 'partial'
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            invoice.paymentStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              color: invoice.paymentStatus == 'partial'
                                  ? Colors.orange
                                  : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              children: [
                _buildTotalRow('Total Amount',
                    '₹${payment.totalAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                _buildTotalRow('Cash Received',
                    '₹${payment.cashReceived.toStringAsFixed(2)}',
                    color: Colors.green),
                const Divider(height: 16),
                _buildTotalRow('Balance Amount',
                    '₹${payment.balanceAmount.toStringAsFixed(2)}',
                    isBold: true,
                    color:
                        payment.balanceAmount > 0 ? Colors.red : Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildFooter() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 16),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.receipt_long, size: 14, color: Colors.grey[400]),
  //         const SizedBox(width: 4),
  //         Text(
  //           'Rental History Report',
  //           style: TextStyle(
  //             fontSize: 11,
  //             color: Colors.grey[400],
  //             letterSpacing: 0.5,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A86C9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF2A86C9), size: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No History Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load rental history',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A86C9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Styles
  final TextStyle _labelStyle = TextStyle(
    fontSize: 11,
    color: Colors.grey[600],
  );

  final TextStyle _valueStyle = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
}
