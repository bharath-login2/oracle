import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/customers/customerQuotationModel.dart';
import 'package:login2/service/service.dart';
import 'package:login2/screens/leadManagement/editQuotationPage.dart';
import 'package:login2/screens/leadManagement/editUploadQuotation.dart';
import 'package:login2/screens/leadManagement/pdfViewPageQuotation.dart';

class CustomerQuotationPage extends StatefulWidget {
  final String customerId;
  final String customerName;
  
  const CustomerQuotationPage({
    Key? key,
    required this.customerId,
    required this.customerName,
  }) : super(key: key);

  @override
  State<CustomerQuotationPage> createState() => _CustomerQuotationPageState();
}

class _CustomerQuotationPageState extends State<CustomerQuotationPage> {
  bool isLoading = true;
  bool isDeleting = false;
  bool _isUpdatingStatus = false;
  bool _isSendingQuotation = false;
  
  List<QuotationData> quotations = [];
  List<QuotationData> _filteredQuotations = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  
  List<String> _statusFilters = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    fetchCustomerQuotations();
  }

  Future<void> fetchCustomerQuotations() async {
    setState(() => isLoading = true);
    
    final result = await HttpService.getCustomerQuotations(widget.customerId);
    
    if (result != null && result.status && result.data.isNotEmpty) {
      setState(() {
        quotations = result.data;
        _applyLocalFilters();
        isLoading = false;
      });
    } else {
      log("Failed to load customer quotations");
      setState(() => isLoading = false);
    }
  }

  void _applyLocalFilters() {
    List<QuotationData> tempList = _getBaseFilteredList();

    if (_searchController.text.isNotEmpty) {
      final lowerCaseQuery = _searchController.text.toLowerCase();
      tempList = tempList.where((quote) {
        final quoteId = quote.quoteId?.toLowerCase() ?? '';
        final createdBy = quote.createdby?.toLowerCase() ?? '';
        return quoteId.contains(lowerCaseQuery) || 
               createdBy.contains(lowerCaseQuery);
      }).toList();
    }

    setState(() {
      _filteredQuotations = tempList;
    });
  }

  void _filterQuotations(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredQuotations = _getBaseFilteredList();
      });
    } else {
      final lowerCaseQuery = query.toLowerCase();
      setState(() {
        _filteredQuotations = _getBaseFilteredList().where((quote) {
          final quoteId = quote.quoteId?.toLowerCase() ?? '';
          final createdBy = quote.createdby?.toLowerCase() ?? '';
          return quoteId.contains(lowerCaseQuery) || 
                 createdBy.contains(lowerCaseQuery);
        }).toList();
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filteredQuotations = _getBaseFilteredList();
      if (_searchController.text.isNotEmpty) {
        _filterQuotations(_searchController.text);
      }
    });
  }

  List<QuotationData> _getBaseFilteredList() {
    if (_selectedFilter == 'All') return quotations;
    
    switch (_selectedFilter) {
      case 'Pending':
        return quotations.where((quote) => quote.approvalStatus == "1").toList();
      case 'Approved':
        return quotations.where((quote) => quote.approvalStatus == "2").toList();
      case 'Rejected':
        return quotations.where((quote) => quote.approvalStatus == "0").toList();
      default:
        return quotations;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "1":
        return "Pending";
      case "0":
        return "Rejected";
      case "2":
        return "Approved";
      default:
        return "Unknown";
    }
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case "1":
        return "⏳";
      case "0":
        return "❌";
      case "2":
        return "✅";
      default:
        return "❓";
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "1":
        return Colors.orange;
      case "0":
        return Colors.red;
      case "2":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showStatusChangeDialog(QuotationData item) async {
    final currentStatus = item.approvalStatus ?? "1";
    String? selectedStatus = currentStatus;
    
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getStatusColor(currentStatus).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              _getStatusIcon(currentStatus),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Update Status",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Current Status:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(currentStatus).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getStatusIcon(currentStatus),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getStatusText(currentStatus),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(currentStatus),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Select New Status",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStatusOptionRow(
                              icon: "⏳",
                              label: "Pending",
                              description: "Quotation is waiting for approval",
                              value: "1",
                              color: Colors.orange,
                              isSelected: selectedStatus == "1",
                              onTap: () {
                                setDialogState(() => selectedStatus = "1");
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildStatusOptionRow(
                              icon: "✅",
                              label: "Approved",
                              description: "Quotation has been approved",
                              value: "2",
                              color: Colors.green,
                              isSelected: selectedStatus == "2",
                              onTap: () {
                                setDialogState(() => selectedStatus = "2");
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildStatusOptionRow(
                              icon: "❌",
                              label: "Rejected",
                              description: "Quotation has been rejected",
                              value: "0",
                              color: Colors.red,
                              isSelected: selectedStatus == "0",
                              onTap: () {
                                setDialogState(() => selectedStatus = "0");
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selectedStatus == currentStatus
                                ? null
                                : () async {
                                    Navigator.pop(context);
                                    await _updateQuotationStatus(
                                      item.workorderId,
                                      selectedStatus!,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getStatusColor(selectedStatus!),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isUpdatingStatus
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Update Status"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusOptionRow({
    required String icon,
    required String label,
    required String description,
    required String value,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.15)
                      : color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: TextStyle(
                      fontSize: 22,
                      color: isSelected ? color : color.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? color : Colors.grey[800],
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: color,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? color.withOpacity(0.8)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateQuotationStatus(String quotationId, String newStatus) async {
    setState(() => _isUpdatingStatus = true);

    try {
      final response = await HttpService.changeQuotationStatus(
        quotationId: quotationId,
        status: newStatus,
      );

      if (response != null && response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Status updated successfully',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        await fetchCustomerQuotations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response?['message'] ?? 'Failed to update status',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      log('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _sendQuotation(String workorderId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Quotation'),
        content: const Text(
          'Are you sure you want to send this quotation to the customer?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 74, 235, 227),
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isSendingQuotation = true;
    });

    try {
      final response = await HttpService.sendQuotation(
        workOrderId: workorderId,
      );

      if (response != null && response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Quotation sent successfully',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        await fetchCustomerQuotations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response?['message'] ?? 'Failed to send quotation',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      log('Error sending quotation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() {
        _isSendingQuotation = false;
      });
    }
  }

  Future<void> _deleteQuotation(String workorderId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this quotation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() {
          isDeleting = true;
        });

        final String response = await HttpService.deleteQuotation(workorderId);

        if (response == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quotation deleted successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          await fetchCustomerQuotations();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete quotation'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        log('Delete error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      // appBar: AppBar(
      //   title: Text(
      //     '${widget.customerName}\'s Quotations',
      //     style: TextStyle(
      //       fontSize: 18,
      //       fontWeight: FontWeight.bold,
      //       letterSpacing: 0.5,
      //     ),
      //   ),
      //   backgroundColor: const Color.fromARGB(255, 22, 145, 216),
      //   foregroundColor: Colors.white,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.refresh),
      //       onPressed: fetchCustomerQuotations,
      //     ),
      //   ],
      // ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.customerName != null && widget.customerName!.isNotEmpty)
              Text(
                widget.customerName!,
                //  "Customer Leads",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            SizedBox(height: 5),
            if (widget.customerName != null && widget.customerName!.isNotEmpty)
              Text(
                // widget.customerName!,
                "Customer Quotations",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchCustomerQuotations,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          
          // Search Bar
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  onChanged: _filterQuotations,
                  decoration: InputDecoration(
                    hintText: 'Search by quote ID or created by...',
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
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _filterQuotations('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

          // Results count
          if (!isLoading && _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Found ${_filteredQuotations.length} result(s)',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      _filterQuotations('');
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Filter chips
          if (!isLoading)
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

          // Results count with filters
          if (!isLoading &&
              (_searchController.text.isNotEmpty || _selectedFilter != 'All'))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Found ${_filteredQuotations.length} result(s)',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  if (_searchController.text.isNotEmpty || _selectedFilter != 'All')
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        _applyFilter('All');
                      },
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

          // Main Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredQuotations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: fetchCustomerQuotations,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredQuotations.length,
                          itemBuilder: (context, index) {
                            final item = _filteredQuotations[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PdfViewPage(
                                      quotationId: item.workorderId,
                                      type: item.type,
                                    ),
                                  ),
                                );
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
                                            backgroundColor:
                                                const Color(0xFF1C1A79).withOpacity(0.15),
                                            radius: 26,
                                            child: const Icon(
                                              Icons.description_outlined,
                                              color: Color(0xFF1C1A79),
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.quoteId,
                                                  style: const TextStyle(
                                                    fontSize: 16.5,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Created By: ${item.createdby}',
                                                  style: const TextStyle(
                                                    fontSize: 13.5,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  'Date: ${_formatDate(item.enquiryDate)}',
                                                  style: const TextStyle(
                                                    fontSize: 13.5,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Quotation ID: ${item.quoteId}',
                                                      style: const TextStyle(
                                                        fontSize: 13.5,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 25),
                                                    item.type == "Created"
                                                        ? Row(
                                                            children: const [
                                                              Icon(Icons.check_circle,
                                                                  size: 16, color: Colors.green),
                                                              SizedBox(width: 5),
                                                              Text(
                                                                'Created',
                                                                style: TextStyle(
                                                                  fontSize: 13.5,
                                                                  color: Colors.black87,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Row(
                                                            children: const [
                                                              Icon(Icons.cloud_upload,
                                                                  size: 16, color: Colors.blue),
                                                              SizedBox(width: 5),
                                                              Text(
                                                                'Uploaded',
                                                                style: TextStyle(
                                                                  fontSize: 13.5,
                                                                  color: Colors.black87,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                  ],
                                                ),
                                                if (item.isSend == "1" || item.isSend == "Y")
                                                  Container(
                                                    margin: const EdgeInsets.only(top: 4),
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.shade50,
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: Colors.green.shade200,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.check_circle,
                                                          size: 12,
                                                          color: Colors.green.shade700,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          'Sent',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.green.shade700,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Icon(
                                                          Icons.send,
                                                          size: 10,
                                                          color: Colors.green.shade700,
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
                                              Text(
                                                "₹${double.tryParse(item.totalAmount)?.toStringAsFixed(2) ?? '0.00'}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15.5,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              InkWell(
                                                onTap: () {
                                                  _showStatusChangeDialog(item);
                                                },
                                                borderRadius: BorderRadius.circular(20),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(item.approvalStatus).withOpacity(0.15),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(
                                                      color: _getStatusColor(item.approvalStatus).withOpacity(0.3),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        _getStatusIcon(item.approvalStatus),
                                                        style: const TextStyle(fontSize: 12),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        _getStatusText(item.approvalStatus),
                                                        style: TextStyle(
                                                          fontSize: 12.5,
                                                          fontWeight: FontWeight.w600,
                                                          color: _getStatusColor(item.approvalStatus),
                                                        ),
                                                      ),
                                                      if (_isUpdatingStatus)
                                                        const SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      const Divider(thickness: 0.6, color: Colors.black12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          const SizedBox(width: 10),
                                          // View PDF Button (Same as original)
                                          Tooltip(
                                            message: 'View PDF',
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => PdfViewPage(
                                                       quotationId:
                                                          item.id ??
                                                              '',
                                                      type: item.type ?? '',
                                                    ),
                                                  ),
                                                );
                                              },
                                              borderRadius: BorderRadius.circular(10),
                                              child: Container(
                                                width: 100,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      const Color.fromARGB(255, 50, 151, 218),
                                                      const Color.fromARGB(255, 50, 151, 218),
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.blue.withOpacity(0.3),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.picture_as_pdf,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'View',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // Edit Button
                                          _actionButton(
                                            color: const Color.fromARGB(255, 50, 151, 218),
                                            icon: Icons.edit_outlined,
                                            tooltip: 'Edit',
                                            onTap: () {
                                              item.type == "Uploaded"
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => EditUploadedQuotationPage(
                                                          quotationId: item.id,
                                                        ),
                                                      ),
                                                    ).then((_) => fetchCustomerQuotations())
                                                  : Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => EditQuotationPage(
                                                          item: item.id,
                                                        ),
                                                      ),
                                                    ).then((_) => fetchCustomerQuotations());
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          // Delete Button
                                          isDeleting
                                              ? Container(
                                                  width: 38,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        Colors.redAccent,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : _actionButton(
                                                  color: Colors.redAccent,
                                                  icon: Icons.delete_outline,
                                                  tooltip: 'Delete',
                                                  onTap: () => _deleteQuotation(item.id, index),
                                                ),
                                          const SizedBox(width: 10),
                                          // Send Button
                                          _isSendingQuotation
                                              ? Container(
                                                  width: 38,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        Color.fromARGB(255, 74, 235, 227),
                                                      ),
                                                    ),
                                                  ))
                                              : _actionButton(
                                                  color: const Color.fromARGB(255, 74, 235, 227),
                                                  icon: item.isSend == "1" || item.isSend == "Y"
                                                      ? Icons.check
                                                      : Icons.send,
                                                  tooltip: item.isSend == "1" || item.isSend == "Y"
                                                      ? 'Already Sent'
                                                      : 'Send Quotation',
                                                  onTap: item.isSend == "1" || item.isSend == "Y"
                                                      ? null
                                                      : () => _sendQuotation(item.id, index),
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: fetchCustomerQuotations,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_searchController.text.isNotEmpty || _selectedFilter != 'All')
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: Colors.grey[400],
                  )
                else
                  Icon(
                    Icons.description_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isNotEmpty || _selectedFilter != 'All'
                      ? "No matching quotations found"
                      : "No quotations found for this customer",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchController.text.isNotEmpty
                      ? "Try a different search term"
                      : _selectedFilter != 'All'
                          ? "Try adjusting your filters"
                          : "This customer has no quotations yet",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (_searchController.text.isNotEmpty || _selectedFilter != 'All')
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _applyFilter('All');
                      },
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Clear All Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required Color color,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: onTap == null ? Colors.grey[300] : color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: onTap == null ? Colors.grey : Colors.white, size: 18),
        ),
      ),
    );
  }
}

Color _getFilterColor(String filter) {
  switch (filter) {
    case 'Pending':
      return Colors.orange;
    case 'Approved':
      return Colors.green;
    case 'Rejected':
      return Colors.red;
    default:
      return Colors.blue;
  }
}