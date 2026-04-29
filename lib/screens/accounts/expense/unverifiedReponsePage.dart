import 'package:flutter/material.dart';
import 'package:login2/models/lead_management/unverifiedTransactionModel.dart';
import 'package:login2/service/service.dart';

class UnverifiedTransactionsPage extends StatefulWidget {
  final String token;

  const UnverifiedTransactionsPage({Key? key, required this.token})
      : super(key: key);

  @override
  State<UnverifiedTransactionsPage> createState() =>
      _UnverifiedTransactionsPageState();
}

class _UnverifiedTransactionsPageState extends State<UnverifiedTransactionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<UnverifiedTransactionModel?> _transactionsFuture;
  bool _isLoading = false;
  String? _fromDate;
  String? _toDate;
  String? _createdBy;
  String? _accountHead;
  String? _month;
  String? _year;
  String? _status;
  bool _isFiltered = false;
  final Color _primaryColor = const Color.fromARGB(255, 41, 133, 219); 
  final Color _accentColor = const Color(0xFF3B82F6); 
  final Color _backgroundColor = const Color(0xFFF8FAFC);
  final Color _cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_isFiltered) {
        setState(() {
          _isFiltered = false;
          _fromDate = null;
          _toDate = null;
          _createdBy = null;
          _accountHead = null;
          _month = null;
          _year = null;
          _status = null;
        });
        _refreshData();
      }
      setState(() {}); 
    });
    _transactionsFuture = _fetchTransactions();
  }

  Future<UnverifiedTransactionModel?> _fetchTransactions() async {
    try {
      setState(() => _isLoading = true);
      String? type;
      if (_isFiltered) {
        switch (_tabController.index) {
          case 0:
            type = 'unverified_receipt';
            break;
          case 1:
            type = 'unverified_expense';
            break;
          case 2:
            type = 'verified_receipt';
            break;
          case 3:
            type = 'verified_expense';
            break;
          case 4:
            type = 'verified_salary';
            break;
        }
      }

      final transactions = await HttpService().getUnverifiedDetails(
        isFiltered: _isFiltered ? "1" : null,
        type: type,
        fromDate: _fromDate,
        toDate: _toDate,
        createdBy: _createdBy,
        accountHead: _accountHead,
        month: _month,
        year: _year,
        status: _status,
      );
      return transactions;
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
      return null;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _transactionsFuture = _fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Verify Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
       // centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _showBottomFilter();
            },
            icon: Icon(
              Icons.filter_alt,
              color: _isFiltered ? Colors.amber : Colors.white,
            ),
            tooltip: 'Filter',
          ),
          IconButton(
            onPressed: () {
              if (_isFiltered) {
                setState(() {
                  _isFiltered = false;
                  _fromDate = null;
                  _toDate = null;
                  _createdBy = null;
                  _accountHead = null;
                  _month = null;
                  _year = null;
                  _status = null;
                });
              }
              _refreshData();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorPadding: const EdgeInsets.only(bottom: 4),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.6),
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Unverified Receipt'),
                    Tab(text: 'Unverified Expense'),
                    Tab(text: 'Verified Receipt'),
                    Tab(text: 'Verified Expense'),
                    Tab(text: 'Verified Salary'),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<UnverifiedTransactionModel?>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (_isLoading &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return _buildEmptyState();
                }

                final data = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: _refreshData,
                  color: _primaryColor,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildReceiptList(
                          data.data.unverifiedReceipt, 'Unverified Receipt'),
                      _buildExpenseList(
                          data.data.unverifiedExpense, 'Unverified Expense'),
                      _buildReceiptList(
                          data.data.verifiedReceipt, 'Verified Receipt'),
                      _buildExpenseList(
                          data.data.verifiedExpense, 'Verified Expense'),
                      _buildSalaryList(
                          data.data.verifiedSalary ?? [], 'Verified Salary'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(_primaryColor),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Fetching Transactions...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Transactions Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no transactions to display at this moment.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptList(List<dynamic> receipts, String title) {
    if (receipts.isEmpty) {
      return _buildEmptyListState(title);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: receipts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final receipt = receipts[index];
        return _buildReceiptCard(receipt);
      },
    );
  }

  Widget _buildExpenseList(List<dynamic> expenses, String title) {
    if (expenses.isEmpty) {
      return _buildEmptyListState(title);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildExpenseCard(expense);
      },
    );
  }

  Widget _buildSalaryList(List<VerifiedSalary> salaries, String title) {
    if (salaries.isEmpty) {
      return _buildEmptyListState(title);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: salaries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final salary = salaries[index];
        return _buildSalaryCard(salary);
      },
    );
  }

  Widget _buildEmptyListState(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 12),
          Text(
            'No $title',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(dynamic receipt) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showReceiptDetails(receipt),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: _primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            receipt.customerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Receipt Number: ${receipt.receiptNumber}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${receipt.recieptAmount}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            receipt.receiptDate,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      icon: Icons.description_outlined,
                      label: 'Invoice Number: ${receipt.invoiceNumber}',
                    ),
                    _buildInfoChip(
                      icon: Icons.person_outline_rounded,
                      label: receipt.staffName,
                    ),
                    _buildInfoChip(
                      icon: Icons.create_rounded,
                      label: 'By ${receipt.createdName}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(dynamic expense) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showExpenseDetails(expense),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.orange.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          Text(
                            expense.expCatName,
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 26, 25, 25),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                            const SizedBox(height: 4),
                          Text(
                            expense.toAccountPerson,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            color: Color.fromARGB(255, 204, 191, 191),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${expense.amount}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            expense.trnDate,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (expense.remarks?.isNotEmpty == true) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      expense.remarks!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const Divider(height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      icon: Icons.account_circle_outlined,
                      label: expense.fromAccountPerson,
                    ),
                    _buildInfoChip(
                      icon: Icons.person_outline_rounded,
                      label: 'By ${expense.staffName}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryCard(VerifiedSalary salary) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showSalaryDetails(salary),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.payments_rounded,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salary.staffName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Month: ${salary.month}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${salary.netSalary}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Worked: ${salary.workedDays}d',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      icon: Icons.verified_user_outlined,
                      label: 'Verified by: ${salary.verifiedByName}',
                    ),
                    salary.lopDays !=""?
                      _buildInfoChip(
                      icon: Icons.location_searching_sharp,
                      label: 'LOP: ${salary.lopDays}',
                    ):SizedBox(),
                    _buildInfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: 'Created: ${salary.createdAt.split(' ')[0]}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _primaryColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showReceiptDetails(dynamic receipt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailsModal(
        title: 'Receipt Details',
        icon: Icons.receipt_long_rounded,
        iconColor: _primaryColor,
        amount: '₹${receipt.recieptAmount}',
        details: [
          {'label': 'Customer', 'value': receipt.customerName},
          {'label': 'Receipt Number', 'value': receipt.receiptNumber},
          {'label': 'Invoice Number', 'value': receipt.invoiceNumber},
          {'label': 'Receipt Date', 'value': receipt.receiptDate},
          {'label': 'Staff Name', 'value': receipt.staffName},
          {'label': 'Created By', 'value': receipt.createdName},
          {'label': 'Created At', 'value': receipt.createdAt},
        ],
      ),
    );
  }

  void _showExpenseDetails(dynamic expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailsModal(
        title: 'Expense Details',
        icon: Icons.account_balance_wallet_rounded,
        iconColor: Colors.orange,
        amount: '₹${expense.amount}',
        details: [
          {'label': 'From Account', 'value': expense.fromAccount},
          {'label': 'Category', 'value': expense.expCatName},
          {'label': 'Account Person', 'value': expense.fromAccountPerson},
          {'label': 'Transaction Date', 'value': expense.trnDate},
          {'label': 'Staff Name', 'value': expense.staffName},
          {'label': 'Remarks', 'value': expense.remarks ?? 'N/A'},
          {'label': 'Created At', 'value': expense.createdAt},
        ],
      ),
    );
  }

  void _showSalaryDetails(VerifiedSalary salary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailsModal(
        title: 'Salary Details',
        icon: Icons.payments_rounded,
        iconColor: Colors.green,
        amount: '₹${salary.netSalary}',
        details: [
          {'label': 'Staff Name', 'value': salary.staffName},
          {'label': 'Month', 'value': salary.month},
          {'label': 'Working Days', 'value': salary.workingDays},
          {'label': 'Worked Days', 'value': salary.workedDays},
          {'label': 'Full Days', 'value': salary.fullDays},
          {'label': 'Half Days', 'value': salary.halfDays},
          {'label': 'Total Salary', 'value': '₹${salary.totalSalary}'},
          {'label': 'Incentives', 'value': '₹${salary.incentives}'},
          {'label': 'Deductions', 'value': '₹${salary.deductions}'},
          {'label': 'Net Salary', 'value': '₹${salary.netSalary}'},
          {'label': 'Verified By', 'value': salary.verifiedByName},
          {'label': 'Created At', 'value': salary.createdAt},
        ],
      ),
    );
  }

  void _showBottomFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          int tabIndex = _tabController.index;
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter Transactions',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (tabIndex == 0 || tabIndex == 1 || tabIndex == 2 || tabIndex == 3) ...[
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              DateTime? dt = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100));
                              if (dt != null) {
                                setModalState(() => _fromDate =
                                    "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}");
                                setState(() {});
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: 'From Date',
                                  isDense: true,
                                  border: OutlineInputBorder()),
                              child: Text(_fromDate ?? 'Select Date',
                                  style: TextStyle(
                                      color: _fromDate == null
                                          ? Colors.grey
                                          : Colors.black87)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              DateTime? dt = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100));
                              if (dt != null) {
                                setModalState(() => _toDate =
                                    "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}");
                                setState(() {});
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: 'To Date',
                                  isDense: true,
                                  border: OutlineInputBorder()),
                              child: Text(_toDate ?? 'Select Date',
                                  style: TextStyle(
                                      color: _toDate == null
                                          ? Colors.grey
                                          : Colors.black87)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (tabIndex == 0 || tabIndex == 2) ...[
                    FutureBuilder(
                        future: HttpService().getStaffName(),
                        builder: (context, snapshot) {
                          String? staffName;
                          if (snapshot.hasData) {
                            final staffs = (snapshot.data as dynamic).data as List<dynamic>;
                            final selectedStaff = staffs.where((e) => e.staffId.toString() == _createdBy).toList();
                            if (selectedStaff.isNotEmpty) staffName = selectedStaff.first.staffName;
                          }
                          return InkWell(
                            onTap: () {
                              if (snapshot.hasData) {
                                final staffs = (snapshot.data as dynamic).data as List<dynamic>;
                                _showSearchableSelection(
                                  context: context,
                                  title: 'Select Staff',
                                  items: staffs.map<Map<String, String>>((e) => {'id': e.staffId.toString(), 'name': e.staffName}).toList(),
                                  onSelect: (val) {
                                    setModalState(() => _createdBy = val['id']);
                                    setState(() {});
                                  }
                                );
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: 'Created By',
                                  isDense: true,
                                  border: OutlineInputBorder()),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(staffName ?? '--select--',
                                      style: TextStyle(
                                          color: staffName == null
                                              ? Colors.grey
                                              : Colors.black87)),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          );
                        }),
                    const SizedBox(height: 16),
                    FutureBuilder(
                        future: HttpService.getAccountHead(),
                        builder: (context, snapshot) {
                          String? headName;
                          if (snapshot.hasData) {
                            final heads = (snapshot.data as dynamic).data.lists as List<dynamic>;
                            final selectedHead = heads.where((e) => e.accountId.toString() == _accountHead).toList();
                            if (selectedHead.isNotEmpty) headName = selectedHead.first.accountName;
                          }
                          return InkWell(
                            onTap: () {
                              if (snapshot.hasData) {
                                final heads = (snapshot.data as dynamic).data.lists as List<dynamic>;
                                _showSearchableSelection(
                                  context: context,
                                  title: 'Select Account Head',
                                  items: heads.map<Map<String, String>>((e) => {'id': e.accountId.toString(), 'name': e.accountName}).toList(),
                                  onSelect: (val) {
                                    setModalState(() => _accountHead = val['id']);
                                    setState(() {});
                                  }
                                );
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: 'Account Head',
                                  isDense: true,
                                  border: OutlineInputBorder()),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(headName ?? '--select--',
                                      style: TextStyle(
                                          color: headName == null
                                              ? Colors.grey
                                              : Colors.black87)),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          );
                        }),
                    const SizedBox(height: 16),
                  ],
                  if (tabIndex == 4) ...[
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                                labelText: 'Month',
                                isDense: true,
                                border: OutlineInputBorder()),
                            value: _month,
                            hint: const Text('--select--'),
                            items: [
                              {'name': 'Jan', 'value': '01'},
                              {'name': 'Feb', 'value': '02'},
                              {'name': 'Mar', 'value': '03'},
                              {'name': 'Apr', 'value': '04'},
                              {'name': 'May', 'value': '05'},
                              {'name': 'Jun', 'value': '06'},
                              {'name': 'Jul', 'value': '07'},
                              {'name': 'Aug', 'value': '08'},
                              {'name': 'Sep', 'value': '09'},
                              {'name': 'Oct', 'value': '10'},
                              {'name': 'Nov', 'value': '11'},
                              {'name': 'Dec', 'value': '12'},
                            ]
                                .map((e) => DropdownMenuItem(
                                    value: e['value'], child: Text(e['name']!)))
                                .toList(),
                            onChanged: (val) {
                              setModalState(() => _month = val);
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                                labelText: 'Year',
                                isDense: true,
                                border: OutlineInputBorder()),
                            value: _year,
                            hint: const Text('--select--'),
                            items: List.generate(
                                    10,
                                    (index) =>
                                        (DateTime.now().year - 5 + index)
                                            .toString())
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) {
                              setModalState(() => _year = val);
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'Status',
                          isDense: true,
                          border: OutlineInputBorder()),
                      value: _status,
                      hint: const Text('--select--'),
                      items: ['Active', 'Inactive']
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        setModalState(() => _status = val);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isFiltered = false;
                              _fromDate = null;
                              _toDate = null;
                              _createdBy = null;
                              _accountHead = null;
                              _month = null;
                              _year = null;
                              _status = null;
                            });
                            _refreshData();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: () {
                            setState(() {
                              _isFiltered = true;
                            });
                            _refreshData();
                            Navigator.pop(context);
                          },
                          child: const Text('Apply Filters'),
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
    );
  }

  void _showSearchableSelection({
    required BuildContext context,
    required String title,
    required List<Map<String, String>> items,
    required Function(Map<String, String>) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(builder: (context, setStateSB) {
          List<Map<String, String>> filteredItems = items
              .where((element) => element['name']!
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
              .toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) {
                      setStateSB(() {
                        searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredItems[index]['name']!),
                        onTap: () {
                          onSelect(filteredItems[index]);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

}

class _DetailsModal extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String amount;
  final List<Map<String, String>> details;

  const _DetailsModal({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.amount,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      amount,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: details.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade100,
                height: 24,
              ),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        details[index]['label']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        details[index]['value']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

}

