import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/rental/rentReturnModel.dart';
import 'package:login2/screens/rental/addRentalReturnPage.dart';
import 'package:login2/screens/rental/rentalReturnDetailsPage.dart';
import 'package:login2/service/service.dart';

class RentalReturnListPage extends StatefulWidget {
  const RentalReturnListPage({super.key});

  @override
  State<RentalReturnListPage> createState() => _RentalReturnListPageState();
}

class _RentalReturnListPageState extends State<RentalReturnListPage> {
  final HttpService _httpService = HttpService();
  RentalReturnModel? _rentalReturnData;
  List<CustomerExp> _customers = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  // Filter variables
  String? _selectedCustomerId;
  DateTime? _fromDate;
  DateTime? _toDate;
  final Set<String> _selectedStatuses = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // UI State
  int _selectedTabIndex = 0;
  final bool _showFilters = false;
  String _selectedFilter = 'All';
  final List<String> _statusFilters = ['All', 'Pending', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadRentalReturns(),
      _loadCustomers(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadRentalReturns() async {
    Map<String, dynamic> filters = {};

    if (_selectedCustomerId != null) {
      filters['customer_id'] = _selectedCustomerId;
    }
    if (_fromDate != null) {
      filters['fromdate'] = DateFormat('dd-MM-yyyy').format(_fromDate!);
    }
    if (_toDate != null) {
      filters['todate'] = DateFormat('dd-MM-yyyy').format(_toDate!);
    }
    if (_searchQuery.isNotEmpty) {
      filters['search'] = _searchQuery;
    }

    final data = await HttpService.getRentalReturnList(filters: filters);
    setState(() {
      _rentalReturnData = data;
      _isRefreshing = false;
    });
  }

  Future<void> _loadCustomers() async {
    final data = await HttpService.getCustomers();
    if (data != null && data.status) {
      setState(() {
        _customers = data.data;
      });
    }
  }

  Widget _buildStatusChip(RentalReturnItem item) {
    final backgroundColor = item.statusColor.withOpacity(0.1);
    final textColor = item.statusColor;
    final icon = item.statusIcon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            item.returnStatusText,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _addRentalReturns() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddRentalReturnPage(),
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  _filterHeader(),
                  Expanded(
                    child: Row(
                      children: [
                        _filterTabs(setSheetState),
                        Expanded(
                          child: _filterContent(setSheetState),
                        ),
                      ],
                    ),
                  ),
                  _applyFilterButton(setSheetState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Text(
            "Filters",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _filterTabs(StateSetter setSheetState) {
    final tabs = [
      ("Customer", Icons.person_outline),
      ("Date Range", Icons.calendar_today),
      ("Status", Icons.flag_outlined),
    ];

    return Container(
      width: 150,
      color: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: tabs.length,
        itemBuilder: (_, index) {
          final selected = _selectedTabIndex == index;
          return InkWell(
            onTap: () => setSheetState(() => _selectedTabIndex = index),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.grey.shade100,
                border: Border(
                  left: BorderSide(
                    color:
                        selected ? const Color(0xFF2a86c9) : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(tabs[index].$2,
                      size: 18,
                      color:
                          selected ? const Color(0xFF2a86c9) : Colors.black54),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tabs[index].$1,
                      style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                        color:
                            selected ? const Color(0xFF2a86c9) : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterContent(StateSetter setSheetState) {
    switch (_selectedTabIndex) {
      case 0:
        return _customerFilter(setSheetState);
      case 1:
        return _dateFilter(setSheetState);
      case 2:
        return _statusFilter(setSheetState);
      default:
        return const SizedBox();
    }
  }

  Widget _customerFilter(StateSetter setSheetState) {
    String searchQuery = '';
    List<CustomerExp> filteredCustomers = _customers;

    return StatefulBuilder(
      builder: (context, innerSetState) {
        filteredCustomers = _customers.where((customer) {
          return customer.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search customers",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  isDense: true,
                ),
                onChanged: (val) {
                  innerSetState(() {
                    searchQuery = val.toLowerCase();
                  });
                },
              ),
            ),
            CheckboxListTile(
              title: const Text(
                'All Customers',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              value: _selectedCustomerId == null,
              onChanged: (val) {
                setSheetState(() => _selectedCustomerId = null);
              },
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            const Divider(height: 1),
            if (_selectedCustomerId != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Chip(
                  label: Text(
                    _customers
                        .firstWhere((c) => c.id == _selectedCustomerId)
                        .name,
                  ),
                  deleteIcon: const Icon(Icons.clear, size: 16),
                  onDeleted: () {
                    setSheetState(() => _selectedCustomerId = null);
                  },
                  backgroundColor: const Color(0xFF2a86c9).withOpacity(0.1),
                  labelStyle: const TextStyle(
                    color: Color(0xFF2a86c9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Expanded(
              child: filteredCustomers.isEmpty && searchQuery.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_off,
                            size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          "No customers found for '$searchQuery'",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: filteredCustomers.length,
                      itemBuilder: (_, index) {
                        final customer = filteredCustomers[index];
                        final selected = _selectedCustomerId == customer.id;

                        return CheckboxListTile(
                          title: Text(customer.name),
                          value: selected,
                          onChanged: (val) {
                            setSheetState(
                                () => _selectedCustomerId = customer.id);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          secondary: selected
                              ? const Icon(Icons.check,
                                  color: Color(0xFF2a86c9))
                              : null,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _dateFilter(StateSetter setSheetState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Date Range",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _dateField(
            label: "From",
            date: _fromDate,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setSheetState(() => _fromDate = picked);
              }
            },
          ),
          const SizedBox(height: 12),
          _dateField(
            label: "To",
            date: _toDate,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _toDate ?? DateTime.now(),
                firstDate: _fromDate ?? DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setSheetState(() => _toDate = picked);
              }
            },
          ),
          if (_fromDate != null || _toDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2a86c9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: const Color(0xFF2a86c9).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month,
                      color: const Color(0xFF2a86c9), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${_fromDate != null ? DateFormat('dd MMM yyyy').format(_fromDate!) : 'Any'} - ${_toDate != null ? DateFormat('dd MMM yyyy').format(_toDate!) : 'Any'}",
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF2a86c9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Colors.red),
                    onPressed: () {
                      setSheetState(() {
                        _fromDate = null;
                        _toDate = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Color(0xFF2a86c9)),
            const SizedBox(width: 12),
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              date == null
                  ? "Select Date"
                  : DateFormat("dd-MM-yyyy").format(date),
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusFilter(StateSetter setSheetState) {
    final statuses = {
      "Pending": "pending",
      "Completed": "completed",
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Status",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statuses.entries.map((e) {
              final selected = _selectedStatuses.contains(e.value);
              return FilterChip(
                label: Text(e.key),
                selected: selected,
                onSelected: (bool value) {
                  setSheetState(() {
                    if (value) {
                      _selectedStatuses.add(e.value);
                    } else {
                      _selectedStatuses.remove(e.value);
                    }
                  });
                },
                backgroundColor:
                    selected ? _getFilterColor(e.key) : Colors.grey[200],
                selectedColor: _getFilterColor(e.key),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                ),
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _applyFilterButton(StateSetter setSheetState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2a86c9),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Apply Filters"),
          onPressed: () {
            Navigator.pop(context);
            _loadRentalReturns();
          },
        ),
      ),
    );
  }

  List<RentalReturnItem> _getFilteredList() {
    if (_rentalReturnData == null) return [];
    List<RentalReturnItem> filtered = _rentalReturnData!.data.list;
    if (_selectedFilter != 'All') {
      switch (_selectedFilter) {
        case 'Pending':
          filtered = filtered.where((item) => item.isPending).toList();
          break;
        case 'Completed':
          filtered = filtered.where((item) => item.isCompleted).toList();
          break;
      }
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.customerName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            item.returnNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.invoiceNo.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    return filtered;
  }
  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      default:
        return const Color(0xFF2a86c9);
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCustomerId = null;
      _fromDate = null;
      _toDate = null;
      _selectedStatuses.clear();
      _searchController.clear();
      _searchQuery = '';
      _selectedFilter = 'All';
    });
    _loadRentalReturns();
  }

  Widget _buildRentalReturnCard(RentalReturnItem item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RentalReturnDetailsPage(returnId: item.returnId.toString()),
          ),
        ).then((_) => _loadRentalReturns());
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
                      Icons.keyboard_return,
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
                          item.customerName,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Return No: ${item.returnNo}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Invoice: ${item.invoiceNo}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Return Date: ${item.returnDate}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Issued: ${item.issuedQty} items',
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              'Returned: ${item.returnedQty} items',
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        if (item.hasExcessReturn)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning,
                                  size: 12,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Excess Return: ${item.balanceQty.abs()} items',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            size: 20, color: Colors.grey),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => AddRentalReturnPage(
                                          customerId: item.customerId.toString(),
                                            returnId: item.returnId.toString(),
                                            customerName:
                                                item.customerName.toString(),
                                                 invoiceNumber: item.invoiceNo.toString(),
                                            customerStaffId:
                                                item.customerStaffId.toString(),
                                            customerStaffName: item
                                                .customerStaffName
                                                .toString())))
                                .then((_) => _loadRentalReturns());
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(item);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 18, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 4),
                      // Text(
                      //   "Balance: ${item.balanceQty}",
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 15.5,
                      //     color: item.hasExcessReturn
                      //         ? Colors.orange
                      //         : item.hasBalance
                      //             ? Colors.red
                      //             : Colors.green,
                      //   ),
                      // ),
                      const SizedBox(height: 6),
                      _buildStatusChip(item),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 0.6, color: Colors.black12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(
                    Icons.percent,
                    '${item.returnPercentage.toStringAsFixed(0)}% Returned',
                    item.isCompleted ? Colors.green : Colors.orange,
                  ),
                  _buildInfoChip(
                    Icons.balance,
                    'Balance: ${item.balanceQty}',
                    item.hasExcessReturn
                        ? Colors.orange
                        : item.hasBalance
                            ? Colors.red
                            : Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadRentalReturns,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.keyboard_return,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  "No rental returns found",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty ||
                          _selectedCustomerId != null ||
                          _fromDate != null ||
                          _toDate != null ||
                          _selectedStatuses.isNotEmpty
                      ? "Try adjusting your filters"
                      : "All rental returns will appear here",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                if (_searchQuery.isNotEmpty ||
                    _selectedCustomerId != null ||
                    _fromDate != null ||
                    _toDate != null ||
                    _selectedStatuses.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _clearAllFilters,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear All Filters'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Rental Returns', style: TextStyle(fontSize: 18)),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Filter',
            onPressed: _openFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 26, color: Colors.white),
            tooltip: 'Add Rental Return',
            onPressed: _addRentalReturns,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isLoading && _rentalReturnData != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem(
                    'Total',
                    _rentalReturnData!.data.recordsTotal.toString(),
                    Icons.list,
                  ),
                  _buildSummaryItem(
                    'Pending',
                    filteredList
                        .where((item) => item.isPending)
                        .length
                        .toString(),
                    Icons.pending,
                  ),
                  _buildSummaryItem(
                    'Completed',
                    filteredList
                        .where((item) => item.isCompleted)
                        .length
                        .toString(),
                    Icons.check_circle,
                  ),
                  _buildSummaryItem(
                    'Excess',
                    filteredList
                        .where((item) => item.hasExcessReturn)
                        .length
                        .toString(),
                    Icons.warning,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  onSubmitted: (_) => _loadRentalReturns(),
                  decoration: InputDecoration(
                    hintText: 'Search by customer, return no, invoice...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _loadRentalReturns();
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statusFilters.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          _applyFilter(selected ? filter : 'All');
                        },
                        backgroundColor: _selectedFilter == filter
                            ? _getFilterColor(filter)
                            : Colors.grey[200],
                        selectedColor: _getFilterColor(filter),
                        labelStyle: TextStyle(
                          color: _selectedFilter == filter
                              ? Colors.white
                              : Colors.black87,
                        ),
                        checkmarkColor: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Results count
          if (!_isLoading && _searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Found ${filteredList.length} result(s)',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadRentalReturns,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            return _buildRentalReturnCard(item);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF2a86c9)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2a86c9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(RentalReturnItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Return'),
        content: Text(
            'Are you sure you want to delete the rental return ${item.returnNo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                final response = await HttpService.deleteRentReturn(
                    item.returnId.toString());
                if (response != null && response.status) {
                  Common.toastMessaage(response.message, Colors.green);
                  _loadRentalReturns();
                } else {
                  Common.toastMessaage(
                      response?.message ?? 'Failed to delete rental return',
                      Colors.red);
                  setState(() => _isLoading = false);
                }
              } catch (e) {
                log('Error deleting rental return: $e');
                Common.toastMessaage('Error: $e', Colors.red);
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
