import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/rental/paymentReportRentalModel.dart';
import 'package:login2/screens/rental/rentalHistoryPage.dart';
import 'package:login2/service/service.dart';

class PaymentReportListPage extends StatefulWidget {
  final String? initialDate;
  const PaymentReportListPage({super.key, this.initialDate});

  @override
  State<PaymentReportListPage> createState() => _PaymentReportListPageState();
}

class _PaymentReportListPageState extends State<PaymentReportListPage> {
  final HttpService _httpService = HttpService();
  PaymentReportRentalModel? _reportData;
  List<CustomerExp> _customers = [];
  List<MaterialData> _materials = [];
  bool _isLoading = true;

  // Filter variables
  String _selectedCustomerId = '0';
  String _selectedPaymentStatus = '0';
  String _selectedPaymentMethod = '0';
  String _selectedProductId = '0';
  DateTime? _fromDate;
  DateTime? _endDate;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      try {
        _fromDate = DateFormat('yyyy-MM-dd').parse(widget.initialDate!);
        _endDate = _fromDate;
      } catch (e) {
        _fromDate = DateTime.now();
        _endDate = DateTime.now();
      }
    } else {
      _fromDate = DateTime.now();
      _endDate = DateTime.now();
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadReports(),
      _loadCustomers(),
      _loadMaterials(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadReports() async {
    final from =
        _fromDate != null ? DateFormat('dd-MM-yyyy').format(_fromDate!) : '';
    final end =
        _endDate != null ? DateFormat('dd-MM-yyyy').format(_endDate!) : '';

    final data = await HttpService.getRentalPaymentReport(
      _selectedCustomerId,
      _selectedPaymentStatus,
      _selectedPaymentMethod,
      from,
      end,
      _selectedProductId,
    );

    setState(() {
      _reportData = data;
    });
  }

  Future<void> _loadCustomers() async {
    final data = await HttpService.getCustomers();
    if (data != null && data.status == true) {
      setState(() {
        _customers = data.data;
      });
    }
  }

  Future<void> _loadMaterials() async {
    final data = await HttpService.getMaterials();
    if (data != null && data.status == true) {
      setState(() {
        _materials = data.data ?? [];
      });
    }
  }

  List<PaymentReportItem> _getFilteredList() {
    if (_reportData == null || _reportData!.data == null) return [];
    List<PaymentReportItem> list = _reportData!.data!.list;

    if (_searchQuery.isNotEmpty) {
      list = list.where((item) {
        return item.customerName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            item.invoiceNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.products.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Payment Report',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await _loadReports();
                    },
                    child: _buildReportList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: const InputDecoration(
            hintText: 'Search by Customer or Invoice...',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.grey, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildReportList() {
    final list = _getFilteredList();
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No payment records found',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildReportCard(list[index]);
      },
    );
  }

  Widget _buildReportCard(PaymentReportItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
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
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    _buildStatusChip(item.paymentStatus),
                  ],
                ),
                const SizedBox(height: 12),
                _infoRow(
                    Icons.receipt_long_outlined, 'Invoice', item.invoiceNo),
                _infoRow(
                    Icons.calendar_today_outlined, 'Date', item.paymentDate),
                _infoRow(Icons.payments_outlined, 'Method', item.paymentMethod),
                _infoRow(Icons.inventory_2_outlined, 'Items', item.products),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    item.balanceAmount != 0.0
                        ? _amountCol(
                            'Balance',
                            '₹${item.balanceAmount.toStringAsFixed(2)}',
                            Colors.red.shade700)
                        : SizedBox(),
                    _amountCol(
                        'Total Amount',
                        '₹${item.totalAmount.toStringAsFixed(2)}',
                        Colors.black),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withOpacity(0.3),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RentalHistoryPage(
                      rentIssueId: item.rentIssueId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.history, size: 18),
              label: const Text('Rent History',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2a86c9),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountCol(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        Text(value,
            style: TextStyle(
                color: valueColor, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        break;
      case 'partial':
        color = Colors.orange;
        break;
      case 'unpaid':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5),
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return _FilterBottomSheet(
          customers: _customers,
          materials: _materials,
          selectedCustomerId: _selectedCustomerId,
          selectedStatus: _selectedPaymentStatus,
          selectedMethod: _selectedPaymentMethod,
          selectedProductId: _selectedProductId,
          fromDate: _fromDate,
          endDate: _endDate,
          onApply: (custId, status, method, productId, from, end) {
            setState(() {
              _selectedCustomerId = custId;
              _selectedPaymentStatus = status;
              _selectedPaymentMethod = method;
              _selectedProductId = productId;
              _fromDate = from;
              _endDate = end;
            });
            _loadReports();
          },
        );
      },
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final List<CustomerExp> customers;
  final List<MaterialData> materials;
  final String selectedCustomerId;
  final String selectedStatus;
  final String selectedMethod;
  final String selectedProductId;
  final DateTime? fromDate;
  final DateTime? endDate;
  final Function(String, String, String, String, DateTime?, DateTime?) onApply;

  const _FilterBottomSheet({
    required this.customers,
    required this.materials,
    required this.selectedCustomerId,
    required this.selectedStatus,
    required this.selectedMethod,
    required this.selectedProductId,
    required this.fromDate,
    required this.endDate,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _custId;
  late String _status;
  late String _method;
  late String _productId;
  DateTime? _from;
  DateTime? _end;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _custId = widget.selectedCustomerId;
    _status = widget.selectedStatus;
    _method = widget.selectedMethod;
    _productId = widget.selectedProductId;
    _from = widget.fromDate;
    _end = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                _buildTabs(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Filter Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final items = [
      ('Customer', Icons.person_outline),
      ('Material', Icons.inventory_2_outlined),
      ('Date Range', Icons.date_range_outlined),
      ('Status/Method', Icons.tune_outlined),
    ];

    return Container(
      width: 120,
      color: Colors.grey.shade50,
      child: Column(
        children: List.generate(items.length, (index) {
          final isSelected = _tabIndex == index;
          return InkWell(
            onTap: () => setState(() => _tabIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border(
                    left: BorderSide(
                        color: isSelected
                            ? const Color(0xFF2a86c9)
                            : Colors.transparent,
                        width: 4)),
              ),
              child: Column(
                children: [
                  Icon(items[index].$2,
                      size: 20,
                      color:
                          isSelected ? const Color(0xFF2a86c9) : Colors.grey),
                  const SizedBox(height: 6),
                  Text(items[index].$1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF2a86c9)
                              : Colors.grey)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    if (_tabIndex == 0) return _customerFilter();
    if (_tabIndex == 1) return _materialFilter();
    if (_tabIndex == 2) return _dateRangePicker();
    return _otherFilters();
  }

  Widget _customerFilter() {
    String currentName = 'All Customers';
    if (_custId != '0') {
      final cust = widget.customers.firstWhere((c) => c.id == _custId,
          orElse: () => CustomerExp(id: '0', name: 'Unknown'));
      currentName = cust.name;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selected Customer',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showCustomerPopup(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(currentName,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          if (_custId != '0')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: () => setState(() => _custId = '0'),
                icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                label: const Text('Clear Selection',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  void _showCustomerPopup() {
    showDialog(
      context: context,
      builder: (context) {
        String query = '';
        return StatefulBuilder(builder: (context, setInner) {
          final filtered = widget.customers
              .where((c) => c.name.toLowerCase().contains(query))
              .toList();
          return AlertDialog(
            title: const Text('Select Customer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    onChanged: (v) => setInner(() => query = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            title: const Text('All Customers'),
                            onTap: () {
                              setState(() => _custId = '0');
                              Navigator.pop(context);
                            },
                          );
                        }
                        final customer = filtered[index - 1];
                        return ListTile(
                          title: Text(customer.name),
                          onTap: () {
                            setState(() => _custId = customer.id);
                            Navigator.pop(context);
                          },
                          trailing: _custId == customer.id
                              ? const Icon(Icons.check_circle,
                                  color: Color(0xFF2a86c9))
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _materialFilter() {
    String currentName = 'All Products';
    if (_productId != '0') {
      final mat = widget.materials.firstWhere((m) => m.materialId == _productId,
          orElse: () => MaterialData(materialId: '0', materialName: 'Unknown'));
      currentName = mat.materialName ?? "Unknown";
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selected Product',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showMaterialPopup(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(currentName,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          if (_productId != '0')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: () => setState(() => _productId = '0'),
                icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                label: const Text('Clear Selection',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  void _showMaterialPopup() {
    showDialog(
      context: context,
      builder: (context) {
        String query = '';
        return StatefulBuilder(builder: (context, setInner) {
          final filtered = widget.materials
              .where(
                  (m) => (m.materialName ?? "").toLowerCase().contains(query))
              .toList();
          return AlertDialog(
            title: const Text('Select Product',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    onChanged: (v) => setInner(() => query = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            title: const Text('All Products'),
                            onTap: () {
                              setState(() => _productId = '0');
                              Navigator.pop(context);
                            },
                          );
                        }
                        final material = filtered[index - 1];
                        return ListTile(
                          title: Text(material.materialName ?? ""),
                          onTap: () {
                            setState(
                                () => _productId = material.materialId ?? '0');
                            Navigator.pop(context);
                          },
                          trailing: _productId == material.materialId
                              ? const Icon(Icons.check_circle,
                                  color: Color(0xFF2a86c9))
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _dateRangePicker() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _dateTile('From Date', _from, (d) => setState(() => _from = d)),
          const SizedBox(height: 12),
          _dateTile('End Date', _end, (d) => setState(() => _end = d)),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() {
              _from = null;
              _end = null;
            }),
            child:
                const Text('Clear Dates', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _dateTile(String label, DateTime? date, Function(DateTime) onPick) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(
                    date == null
                        ? 'Select Date'
                        : DateFormat('dd-MM-yyyy').format(date),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const Icon(Icons.calendar_month,
                color: Color(0xFF2a86c9), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _otherFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ['0', 'Paid', 'Partial', 'Unpaid'].map((s) {
              final isSelected = _status == s;
              return ChoiceChip(
                label: Text(s == '0' ? 'All' : s,
                    style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: (val) => setState(() => _status = s),
                selectedColor: const Color(0xFF2a86c9),
                labelStyle:
                    TextStyle(color: isSelected ? Colors.white : Colors.black),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Payment Method',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ['0', 'Cash', 'Bank'].map((m) {
              final isSelected = _method == m;
              return ChoiceChip(
                label: Text(m == '0' ? 'All' : m,
                    style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: (val) => setState(() => _method = m),
                selectedColor: const Color(0xFF2a86c9),
                labelStyle:
                    TextStyle(color: isSelected ? Colors.white : Colors.black),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4))
      ]),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            widget.onApply(_custId, _status, _method, _productId, _from, _end);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2a86c9),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Apply Filters',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
