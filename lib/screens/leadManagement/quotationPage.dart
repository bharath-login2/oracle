import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/models/lead_management/quotationListModel.dart';
import 'package:login2/screens/leadManagement/addQuotationPage.dart';
import 'package:login2/screens/leadManagement/editQuotationPage.dart';
import 'package:login2/screens/leadManagement/editUploadQuotation.dart';
import 'package:login2/screens/leadManagement/pdfViewPageQuotation.dart';
import 'package:login2/screens/leadManagement/uploadQuotation.dart';
import 'package:login2/service/service.dart';

class QuotationPage extends StatefulWidget {
  final dynamic status;
  const QuotationPage({Key? key, required this.status}) : super(key: key);

  @override
  State<QuotationPage> createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  bool isLoading = true;
  bool isDeleting = false;
  bool _isUpdatingStatus = false;
  int _selectedTabIndex = 0;

  DateTimeRange? _createdDateRange;
  Set<String> _selectedStaffIds = {};
  Set<String> _selectedStatuses = {};
  String _staffSearch = '';
  List<Staff> _staffList = [];
  bool _staffLoading = false;
  List<QuotationData> quotations = [];
  List<QuotationData> _filteredQuotations = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  List<String> _statusFilters = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
    'On Hold',
  ];
  
  @override
  void initState() {
    super.initState();
    fetchQuotations();
  }

  Future<void> fetchQuotations() async {
    setState(() => isLoading = true);
    final result =
        await HttpService.getQuotationList(widget.status, "", "", [], []);

    if (result != null && result.data != null) {
      setState(() {
        quotations = result.data!;
        _filteredQuotations = quotations;
        isLoading = false;
      });
    } else {
      log("Failed to load quotations");
      setState(() => isLoading = false);
    }
  }

  void _filterQuotations(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredQuotations = quotations;
      });
    } else {
      final lowerCaseQuery = query.toLowerCase();
      setState(() {
        _filteredQuotations = quotations.where((quote) {
          final customerName = quote.customerName?.toLowerCase() ?? '';
          return customerName.contains(lowerCaseQuery);
        }).toList();
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredQuotations = quotations;
      } else {
        _filteredQuotations = _getBaseFilteredList();
      }
      if (_searchController.text.isNotEmpty) {
        _filterQuotations(_searchController.text);
      }
    });
  }

  List<QuotationData> _getBaseFilteredList() {
    if (_selectedFilter == 'All') return quotations;

    switch (_selectedFilter) {
      case 'Pending':
        return quotations.where((quote) => quote.status == "1").toList();
      case 'Approved':
        return quotations.where((quote) => quote.status == "2").toList();
      case 'Rejected':
        return quotations.where((quote) => quote.status == "0").toList();
      case 'On Hold':
        return quotations.where((quote) => quote.status == "3").toList();
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
      case "3":
        return "On Hold";
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
      case "3":
        return "⏸️"; 
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
      case "3":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showStatusChangeDialog(QuotationData item) async {
    final currentStatus = item.status ?? "1";
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
                            const SizedBox(height: 12),
                            _buildStatusOptionRow(
                              icon: "⏸️",
                              label: "On Hold",
                              description: "Quotation is temporarily on hold",
                              value: "3",
                              color: Colors.grey,
                              isSelected: selectedStatus == "3",
                              onTap: () {
                                setDialogState(() => selectedStatus = "3");
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
                                      item.workorderId!,
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
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.15) : color.withOpacity(0.08),
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
              
              // Text Content
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
                        color: isSelected ? color.withOpacity(0.8) : Colors.grey[600],
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
      
        await fetchQuotations();
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

          await fetchQuotations();
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

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        // Local variables for the filter sheet
        bool staffLoadingLocal = _staffLoading;
        List<Staff> filteredStaffListLocal = [];
        
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Initialize filtered staff list
            filteredStaffListLocal = _staffList.where((staff) {
              return staff.name.toLowerCase().contains(_staffSearch.toLowerCase());
            }).toList();
            
            // Function to load staffs if needed
            Future<void> loadStaffsIfNeeded() async {
              if (_staffList.isEmpty && !staffLoadingLocal) {
                setSheetState(() => staffLoadingLocal = true);
                final result = await HttpService.getStaffs();
                if (result != null && mounted) {
                  setState(() {
                    _staffList = result.data;
                  });
                }
                setSheetState(() => staffLoadingLocal = false);
              }
            }
            
            // Load staffs when the sheet opens
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_selectedTabIndex == 1 && _staffList.isEmpty && !staffLoadingLocal) {
                loadStaffsIfNeeded();
              }
            });
            
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  _filterHeader(),
                  Expanded(
                    child: Row(
                      children: [
                        _filterTabs(setSheetState, loadStaffsIfNeeded),
                        Expanded(
                          child: _filterContent(
                            setSheetState, 
                            staffLoadingLocal, 
                            filteredStaffListLocal,
                            loadStaffsIfNeeded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _applyFilterButton(),
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
      )
    );
  }

  Widget _filterTabs(StateSetter setSheetState, Future<void> Function() loadStaffsIfNeeded) {
    final tabs = [
      ("Created Date", Icons.calendar_today),
      ("Created By", Icons.person_outline),
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
            onTap: () {
              setSheetState(() => _selectedTabIndex = index);
              if (index == 1 && _staffList.isEmpty) {
                loadStaffsIfNeeded();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.grey.shade100,
                border: Border(
                  left: BorderSide(
                    color: selected ? Colors.blue : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(tabs[index].$2,
                      size: 18, color: selected ? Colors.blue : Colors.black54),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tabs[index].$1,
                      style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                        color: selected ? Colors.blue : Colors.black87,
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

  Widget _createdDateFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dateField(
            label: "From",
            date: _createdDateRange?.start,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _createdDateRange?.start ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _createdDateRange = DateTimeRange(
                    start: picked,
                    end: _createdDateRange?.end ?? picked,
                  );
                });
              }
            },
          ),
          const SizedBox(height: 12),
          _dateField(
            label: "To",
            date: _createdDateRange?.end,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _createdDateRange?.end ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _createdDateRange = DateTimeRange(
                    start: _createdDateRange?.start ?? picked,
                    end: picked,
                  );
                });
              }
            },
          ),
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
            const Icon(Icons.calendar_month, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              "$label : ",
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

  Widget _filterContent(
    StateSetter setSheetState,
    bool staffLoadingLocal,
    List<Staff> filteredStaffListLocal,
    Future<void> Function() loadStaffsIfNeeded,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return _createdDateFilter();
      case 1:
        return _createdByFilter(
          setSheetState, 
          staffLoadingLocal, 
          filteredStaffListLocal,
          loadStaffsIfNeeded,
        );
      case 2:
        return _statusFilter(setSheetState);
      default:
        return const SizedBox();
    }
  }

  Future<void> _loadStaffs() async {
    setState(() => _staffLoading = true);
    final result = await HttpService.getStaffs();
    if (result != null) {
      setState(() => _staffList = result.data);
    }
    setState(() => _staffLoading = false);
  }

  Widget _createdByFilter(
    StateSetter setSheetState,
    bool staffLoadingLocal,
    List<Staff> filteredStaffListLocal,
    Future<void> Function() loadStaffsIfNeeded,
  ) {
    if (staffLoadingLocal) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search staff",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
            onChanged: (val) {
              setSheetState(() {
                _staffSearch = val.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: filteredStaffListLocal.isEmpty && _staffList.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_off, size: 50, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text("No staff found"),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        loadStaffsIfNeeded();
                      },
                      child: const Text("Load Staff"),
                    ),
                  ],
                )
              : ListView(
                  children: filteredStaffListLocal.map((staff) {
                    final selected = _selectedStaffIds.contains(staff.userIdStaff);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (val) {
                        setSheetState(() {
                          val!
                              ? _selectedStaffIds.add(staff.userIdStaff)
                              : _selectedStaffIds.remove(staff.userIdStaff);
                        });
                      },
                      title: Text(staff.name),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _statusFilter(StateSetter setSheetState) {
    final statuses = {
      "Pending": "1",
      "Approved": "2",
      "Rejected": "0",
      "On Hold": "3",
    };

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: statuses.entries.map((e) {
        return CheckboxListTile(
          title: Text(e.key),
          value: _selectedStatuses.contains(e.value),
          onChanged: (val) {
            setSheetState(() {
              val!
                  ? _selectedStatuses.add(e.value)
                  : _selectedStatuses.remove(e.value);
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        );
      }).toList(),
    );
  }

  Widget _applyFilterButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 56, 141, 211),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Apply Filters"),
          onPressed: () {
            Navigator.pop(context);
            _applyAdvancedFilters();
          },
        ),
      ),
    );
  }

  Future<void> _applyAdvancedFilters() async {
    setState(() => isLoading = true);
    final fromDate = _createdDateRange?.start != null
        ? DateFormat("yyyy-MM-dd").format(_createdDateRange!.start)
        : null;

    final toDate = _createdDateRange?.end != null
        ? DateFormat("yyyy-MM-dd").format(_createdDateRange!.end)
        : null;

    final result = await HttpService.getQuotationList(
      widget.status,
      fromDate,
      toDate,
      _selectedStaffIds.toList(),
      _selectedStatuses.toList(),
    );

    if (result != null && result.data != null) {
      setState(() {
        quotations = result.data!;
        _filteredQuotations = quotations;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Quotations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 22, 145, 216),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Filter',
            onPressed: _openFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 26, color: Colors.white),
            tooltip: 'Add Quotation',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddQuotationPage()),
              ).then((_) => fetchQuotations());
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload, size: 26, color: Colors.white),
            tooltip: 'Upload Quotation',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadQuotationPage()),
              ).then((_) => fetchQuotations());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                    hintText: 'Search by customer name...',
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

          // Results count
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
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      _applyFilter('All');
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

          // Main Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredQuotations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: fetchQuotations,
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
                                      quotationId: item.workorderId ?? '',
                                      type: item.type ?? '',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                const Color(0xFF1C1A79)
                                                    .withOpacity(0.15),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.customerName ?? "-",
                                                  style: const TextStyle(
                                                    fontSize: 16.5,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Created By: ${item.createdBy ?? "-"}',
                                                  style: const TextStyle(
                                                    fontSize: 13.5,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  'Date: ${item.date ?? "-"}',
                                                  style: const TextStyle(
                                                    fontSize: 13.5,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "₹${item.amount ?? "0.00"}",
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
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(
                                                      item.status ?? "0",
                                                    ).withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                      color: _getStatusColor(
                                                        item.status ?? "0",
                                                      ).withOpacity(0.3),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        _getStatusIcon(
                                                            item.status ?? ""),
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        _getStatusText(
                                                            item.status ?? ""),
                                                        style: TextStyle(
                                                          fontSize: 12.5,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              _getStatusColor(
                                                            item.status ?? "0",
                                                          ),
                                                        ),
                                                      ),
                                                      if (_isUpdatingStatus)
                                                        const SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child:
                                                              CircularProgressIndicator(
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
                                      const Divider(
                                          thickness: 0.6,
                                          color: Colors.black12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const SizedBox(width: 10),

                                          _actionButton(
                                            color: const Color.fromARGB(
                                                255, 106, 144, 214),
                                            icon: Icons.remove_red_eye,
                                            tooltip: 'view',
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => PdfViewPage(
                                                    quotationId:
                                                        item.workorderId ?? '',
                                                    type: item.type ?? '',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          _actionButton(
                                            color: const Color(0xFF425DF5),
                                            icon: Icons.edit_outlined,
                                            tooltip: 'Edit',
                                            onTap: () {
                                              item.type == "Uploaded"
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            EditUploadedQuotationPage(
                                                          quotationId:
                                                              item.workorderId!,
                                                        ),
                                                      ),
                                                    ).then(
                                                      (_) => fetchQuotations())
                                                  : Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            EditQuotationPage(
                                                          item:
                                                              item.workorderId!,
                                                        ),
                                                      ),
                                                    ).then(
                                                      (_) => fetchQuotations());
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          isDeleting
                                              ? Container(
                                                  width: 38,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        Colors.redAccent,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : _actionButton(
                                                  color: Colors.redAccent,
                                                  icon: Icons.delete_outline,
                                                  tooltip: 'Delete',
                                                  onTap: () => _deleteQuotation(
                                                      item.workorderId!, index),
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
      onRefresh: fetchQuotations,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_searchController.text.isNotEmpty)
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
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddQuotationPage()),
                    ).then((_) => fetchQuotations());
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create Quotation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchController.text.isNotEmpty
                      ? "Try a different search term"
                      : "Add or upload a quotation to get started",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _filterQuotations('');
                      },
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Clear Search'),
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
    required VoidCallback onTap,
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
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
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
    case 'On Hold':
      return Colors.grey;
    default:
      return Colors.blue;
  }
}

class QuotationDetailsPage extends StatelessWidget {
  final QuotationData item;
  const QuotationDetailsPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text("Quotation ${item.workorderId ?? ''}"),
        backgroundColor: const Color.fromARGB(255, 31, 145, 221),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailItem("Customer", item.customerName ?? "-"),
                _detailItem("Work Order", item.workorderId ?? "-"),
                _detailItem("Date", item.date ?? "-"),
                _detailItem("Created By", item.createdBy ?? "-"),
                _detailItem("Amount", "₹${item.amount ?? "0.00"}"),
                _detailItem("Status", item.status ?? "-"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ],
      )
    );
  }
}