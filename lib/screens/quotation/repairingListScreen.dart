import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../service/service.dart';
import '../../models/quotation/quotation_model.dart';
import '../../models/quotation/timeline_history_model.dart';
// import 'package:login2/models/lead_management/staff_list_model.dart';
import '../../models/lead_management/staff_list_model.dart';
import '../../models/quotation/branch_list_model.dart';
import 'widgets/Timeline_history.dart';

class RepairingListScreen extends StatefulWidget {
  const RepairingListScreen({super.key});

  @override
  State<RepairingListScreen> createState() => _RepairingListScreenState();
}

class _RepairingListScreenState extends State<RepairingListScreen> {
  // Layout constants
  static const double _maxContentWidth = 1000;
  static const double _twoColumnBreakpoint = 700;
  static const double _cardSpacing = 12;
  static const double _pagePadding = 16;
  static const double _filterMaxWidth = 520;

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  List<QuotationItem> _quotations = [];

  List<StaffListData> _staffList = [];
  List<Branch> _branches = [];

  // API filter variables
  String _apiSelectedStatus = 'All';
  DateTime? _apiFromDate;
  DateTime? _apiToDate;
  String _selectedCreatedBy = 'All';
  String _selectedBranch = 'All';
  bool _isLoadingBranches = false;

  @override
  void initState() {
    super.initState();
    _fetchQuotations();
    _fetchStaffList();
    _fetchBranches();
  }

  //fetch quotations from API
  Future<void> _fetchQuotations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Convert the selected status string to its corresponding ID (if not 'All')
      dynamic statusParam;
      if (_apiSelectedStatus != 'All') {
        statusParam = _statusToIdMap[_apiSelectedStatus];
      }
      dynamic branchParam = _selectedBranch != 'All' ? _selectedBranch : null;

      final response = await HttpService.getQuotations(
        status: statusParam, // Passes 1, 2, 3, 4, 5, 7 or null for 'All'
        fromDate: _apiFromDate != null ? _formatDate(_apiFromDate!) : null,
        toDate: _apiToDate != null ? _formatDate(_apiToDate!) : null,
        quotationType: 'repairing',
        createdBy: _selectedCreatedBy != 'All' ? _selectedCreatedBy : null,
        branchId: branchParam,
      );

      if (!mounted) return;

      if (response != null && response.status) {
        setState(() {
          _quotations = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response?.message.isNotEmpty == true
              ? response!.message
              : 'Failed to load Repair quotations';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('getQuotations error: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  //Status updating
  Future<void> _showStatusUpdateConfirmation(
    QuotationItem item,
    String newStatus,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Confirm Status Update',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to change the status to "$newStatus"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A86C9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final int? statusId = _statusToIdMap[newStatus];
      if (statusId == null) return;
      // Call the backend service
      final bool success = await HttpService.updateQuotationStatus(
        quotationId: item.id,
        statusId: statusId,
        quotationType: item.quotationType,
      );

      if (success) {
        setState(() {
          final index = _quotations.indexWhere((q) => q.id == item.id);
          if (index != -1) {
            _quotations[index] = QuotationItem(
              id: item.id,
              quotationType: item.quotationType,
              customerId: item.customerId,
              customerName: item.customerName,
              leadId: item.leadId,
              total: item.total,
              createdBy: item.createdBy,
              createdDate: item.createdDate,
              branchName: item.branchName,
              state: item.state,
              priority: item.priority,
              status: statusId, // Store the updated integer status ID
              statusLabel: newStatus, // Updated label string
              requestId: item.requestId,
              assignedTo: item.assignedTo,
              revisionId: item.revisionId,
              revisionComments: item.revisionComments,
              quotationDocument: item.quotationDocument,
            );
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status updated successfully')),
          );
        }
        // 🔍 CHECK HERE: If the newly updated status is Revision, trigger the popup form now!
        if (newStatus.toLowerCase() == 'revision') {
          // Pass the updated item to your revision dialog function
          _showRequestRevisionDialog(item);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  //history
  Future<void> _handleHistoryClick(QuotationItem item) async {
    // 1. Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF38C172), // Matches your theme color
        ),
      ),
    );

    try {
      // 2. Fetch the token from shared preferences

      // 3. Make the separate API function call
      final response = await HttpService.getQuotationHistory(
        quotationId: item.id,
        quotationType: item.quotationType,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (response != null && response['status'] == true) {
        final List<dynamic> rawData = response['data'] ?? [];

        // 4. Map the raw logs using your QuotationHistory model
        final List<QuotationHistoryItem> historyList = rawData.map((json) {
          return QuotationHistoryItem.fromJson(json);
        }).toList();

        // 5. Open the reusable timeline bottom sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: QuotationHistoryBottomSheet(
                title: 'Repair History',
                historyList: historyList,
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response?['message'] ?? 'Failed to fetch history logs',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog on exception
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while loading history'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // show quotation history model
  void showQuotationHistoryModal({
    required BuildContext context,
    required String title,
    required List<QuotationHistoryItem> historyList,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionalTranslation(
          translation: const Offset(0, 0),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: QuotationHistoryBottomSheet(
              title: title,
              historyList: historyList,
            ),
          ),
        );
      },
    );
  }

  //print pdf

  Future<void> _handlePrintClick(QuotationItem item) async {
    if (item.quotationDocument.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document link not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // 1. Sanitize the string to fix any escaped slashes from the backend
      final String cleanUrlString =
          item.quotationDocument.replaceAll(r'\/', '/');
      final Uri url = Uri.parse(cleanUrlString);

      // 2. Launch directly without canLaunchUrl check to avoid Android package visibility blocks
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching quotation document: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //staff list
  Future<void> _fetchStaffList() async {
    try {
      final response = await HttpService.getStaffList(); // Or your service name
      if (response != null && response.data != null) {
        setState(() {
          _staffList =
              response.data; // Adjust based on your StaffListResponse structure
        });
      }
    } catch (e) {
      print('Error fetching staff list for filter: $e');
    }
  }

  //branch list
  Future<void> _fetchBranches() async {
    try {
      setState(() {
        _isLoadingBranches = true;
      });

      final response =
          await HttpService.getBranchwiseList(); // Adjust method name if needed

      if (!mounted) return;
      if (response != null && response.status == true) {
        setState(() {
          _branches = (response.data as List<dynamic>?)
                  ?.map((item) => item as Branch)
                  .toList() ??
              [];
          _isLoadingBranches = false;
        });
      } else {
        setState(() {
          _isLoadingBranches = false;
        });
      }
    } catch (e) {
      print('getBranchwiseList error: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingBranches = false;
      });
    }
  }

  final List<String> _statusOptions = [
    'Pending',
    'Revision',
    'Under Review',
    'Client Approved',
    'Rejected',
    'Admin Approved',
  ];
  // Map Status String to ID
  final Map<String, int> _statusToIdMap = {
    'Pending': 1,
    'Revision': 2,
    'Under Review': 3,
    'Client Approved': 4,
    'Rejected': 5,
    'Admin Approved': 7,
  };

  // Map ID to Status String (useful if your API returns integer status)
  String _getStatusLabelFromId(int id) {
    switch (id) {
      case 1:
        return 'Pending';
      case 2:
        return 'Revision';
      case 3:
        return 'Under Review';
      case 4:
        return 'Client Approved';
      case 5:
        return 'Rejected';
      case 7:
        return 'Admin Approved';
      default:
        return 'Pending';
    }
  }

  final List<String> _filterStatusOptions = [
    'All',
    'Pending',
    'Revision',
    'Under Review',
    'Client Approved',
    'Rejected',
    'Admin Approved',
  ];

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  Future<void> _selectDate(
    BuildContext context,
    StateSetter setModalState,
    bool isFrom,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_apiFromDate ?? DateTime.now())
          : (_apiToDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setModalState(() {
        if (isFrom) {
          _apiFromDate = picked;
        } else {
          _apiToDate = picked;
        }
      });
      setState(() {});
    }
  }

  // ------------------------------------------------------------------
  // Filter dialog
  // ------------------------------------------------------------------

  void _openTopFilterSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filter',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _filterMaxWidth),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Filter Repair Quotations',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            const Divider(height: 12),
                            _filterLabel('Status'),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _apiSelectedStatus,
                                  isDense: true,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(0xFF64748B),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF0F172A),
                                  ),
                                  items: _filterStatusOptions.map((
                                    String status,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(status),
                                    );
                                  }).toList(),
                                  onChanged: (String? val) {
                                    if (val != null) {
                                      setModalState(() {
                                        _apiSelectedStatus = val;
                                      });
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _filterLabel('Branch'),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedBranch,
                                  isDense: true,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(0xFF64748B),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF0F172A),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: 'All',
                                      child: Text('All Branches'),
                                    ),
                                    ..._branches.map((branch) {
                                      return DropdownMenuItem<String>(
                                        value: branch.branchId
                                            .toString(), // Passes branch ID as value
                                        child: Text(
                                          branch.branchName ?? '',
                                        ), // Displays branch name
                                      );
                                    }),
                                  ],
                                  onChanged: (String? val) {
                                    if (val != null) {
                                      setModalState(() {
                                        _selectedBranch = val;
                                      });
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _filterLabel('Created By'),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCreatedBy,
                                  isDense: true,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(0xFF64748B),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF0F172A),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: 'All',
                                      child: Text('All Staff'),
                                    ),
                                    ..._staffList.map((staff) {
                                      return DropdownMenuItem<String>(
                                        value: staff
                                            .userId, // Passes the userId (e.g., "12", "45") as the value
                                        child: Text(
                                          staff.staffName,
                                        ), // Displays the staff name in the UI
                                      );
                                    }),
                                  ],
                                  onChanged: (String? val) {
                                    if (val != null) {
                                      setModalState(() {
                                        _selectedCreatedBy =
                                            val; // This will now hold the selected staff's userId
                                      });
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _dateField(
                                    label: 'From Date',
                                    value: _apiFromDate,
                                    onTap: () => _selectDate(
                                      context,
                                      setModalState,
                                      true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _dateField(
                                    label: 'To Date',
                                    value: _apiToDate,
                                    onTap: () => _selectDate(
                                      context,
                                      setModalState,
                                      false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setModalState(() {
                                        _apiSelectedStatus = 'All';
                                        _selectedCreatedBy = 'All';
                                        _selectedBranch = 'All';
                                        _apiFromDate = null;
                                        _apiToDate = null;
                                      });
                                      _fetchQuotations();
                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Clear',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _fetchQuotations();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2A86C9),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Apply',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
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
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(anim1),
          child: child,
        );
      },
    );
  }

  Widget _filterLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _filterLabel(label),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(
              Icons.calendar_today,
              size: 14,
              color: Color(0xFF2A86C9),
            ),
            label: Text(
              value == null ? label : _formatDate(value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
            ),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'admin approved':
      case 'completed':
      case 'client approved':
        return Colors.green;
      case 'under review':
      case 'revision':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return const Color(0xFF2A86C9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2A86C9), Color(0xFF406DBE)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          'Quotation List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _openTopFilterSheet,
            tooltip: 'Filter Repair Quotations',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading && _quotations.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _quotations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 48,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Repair quotations found.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _errorMessage ??
                                'Try changing your filters or search criteria.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _apiSelectedStatus = 'All';
                                _selectedCreatedBy = 'All';
                                _selectedBranch = 'All';
                                _apiFromDate = null;
                                _apiToDate = null;
                              });
                              _fetchQuotations();
                            },
                            icon: const Icon(
                              Icons.refresh,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Reset Filters',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A86C9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        // Keep a generic error view only if it's a true network/server exception
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    // Reset all filters back to default
                                    _apiSelectedStatus = 'All';
                                    _selectedCreatedBy = 'All';
                                    _selectedBranch = 'All';
                                    _apiFromDate = null;
                                    _apiToDate = null; // Clear the error
                                  });
                                  _fetchQuotations(); // Fetch with cleared filters
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2A86C9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Reset Filters & Retry',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final double width = constraints.maxWidth;
                          final int columns =
                              width >= _twoColumnBreakpoint ? 2 : 1;

                          final double extra = width > _maxContentWidth
                              ? (width - _maxContentWidth) / 2
                              : 0;
                          final double hPad = _pagePadding + extra;

                          final int rowCount =
                              (_quotations.length / columns).ceil();

                          return RefreshIndicator(
                            onRefresh: _fetchQuotations,
                            color: const Color(0xFF2A86C9),
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: hPad,
                                vertical: _pagePadding,
                              ),
                              itemCount: rowCount,
                              itemBuilder: (context, rowIndex) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: _cardSpacing),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (int c = 0; c < columns; c++) ...[
                                        if (c > 0)
                                          const SizedBox(width: _cardSpacing),
                                        Expanded(
                                          child: (rowIndex * columns + c) <
                                                  _quotations.length
                                              ? _buildQuotationCard(
                                                  _quotations[
                                                      rowIndex * columns + c],
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildQuotationCard(QuotationItem item) {
    final double textScale = MediaQuery.textScalerOf(context).scale(10) / 10;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final int detailCols = (w >= 280 && textScale <= 1.2) ? 3 : 2;
          final bool stackBottom = w < 260 || textScale > 1.3;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _circleAction(
                      Icons.print, 'Print', () => _handlePrintClick(item)),
                  const SizedBox(width: 8),
                  _circleAction(
                    Icons.history,
                    'History',
                    () => _handleHistoryClick(item),
                  ),
                ],
              ),
              const Divider(height: 16),
              _detailGrid([
                _detailItem('Amount', '₹${item.total}', isBold: true),
                _detailItem('Branch', item.branchName),
                _detailItem('State', item.state),
                _detailItem('Created By', item.createdBy),
                _detailItem('Created Date', item.createdDate),
                _priorityColumn('Priority', item.priority),
              ], detailCols),
              const SizedBox(height: 12),
              if (stackBottom) ...[
                _revisionBlock(item),
                const SizedBox(height: 12),
                _statusBlock(item),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _revisionBlock(item)),
                    const SizedBox(width: 12),
                    Expanded(child: _statusBlock(item)),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _circleAction(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFF2A86C9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _revisionBlock(QuotationItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Revision Request',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _showRevisionDetailsDialog(item),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.visibility, size: 14, color: Color(0xFFD97706)),
                SizedBox(width: 4),
                Text(
                  'View',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBlock(QuotationItem item) {
    final Color statusColor = _getStatusColor(item.statusLabel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _statusOptions.contains(item.statusLabel)
                  ? item.statusLabel
                  : _statusOptions.first,
              isDense: true,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: statusColor),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
              items: _statusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(status),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newStatus) {
                if (newStatus != null && newStatus != item.statusLabel) {
                  // Trigger the confirmation popup before saving
                  _showStatusUpdateConfirmation(item, newStatus);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailGrid(List<Widget> items, int cols) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += cols) {
      final end = (i + cols) > items.length ? items.length : i + cols;
      final slice = items.sublist(i, end);
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int j = 0; j < cols; j++)
              Expanded(
                child: j < slice.length ? slice[j] : const SizedBox.shrink(),
              ),
          ],
        ),
      );
      if (end < items.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  Widget _detailItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showRevisionDetailsDialog(QuotationItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(Icons.rate_review, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Revision Request',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer: ${item.customerName}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Revision / Change Instructions:',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  item.revisionComments?.isNotEmpty == true
                      ? item.revisionComments!
                      : 'No revision comments provided.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A86C9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  //add revision comments
  void _showRequestRevisionDialog(QuotationItem item) {
    final TextEditingController revisionController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // 1. Capture the true parent screen context BEFORE opening the dialog
    final BuildContext screenContext = context;

    showDialog(
      context: screenContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(Icons.edit_note, color: Color(0xFFD97706), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Request Quotation Revision',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quotation ID: #${item.id ?? "N/A"}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Revision / Change Instructions *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: revisionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Enter changes required, notes, or instructions...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2A86C9)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter revision instructions';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final String instructions = revisionController.text.trim();

                  // Close the revision dialog using its specific dialogContext
                  Navigator.of(dialogContext).pop();

                  // Show loading indicator
                  BuildContext? loadingContext;
                  showDialog(
                    context: screenContext,
                    barrierDismissible: false,
                    builder: (ctx) {
                      loadingContext = ctx;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2A86C9),
                        ),
                      );
                    },
                  );

                  bool success = false;
                  try {
                    success = await HttpService.requestQuotationRevision(
                      quotationId: item.id,
                      quotationType: item.quotationType,
                      comments: instructions,
                    ).timeout(const Duration(seconds: 30));
                  } catch (e) {
                    success = false;
                  } finally {
                    // Dismiss loading dialog safely
                    if (loadingContext != null &&
                        Navigator.canPop(loadingContext!)) {
                      Navigator.of(loadingContext!).pop();
                    }
                  }

                  // Ensure screenContext is still active
                  if (!screenContext.mounted) return;

                  if (success) {
                    // Show success SnackBar using the stable screenContext
                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Revision request sent to assigned staff successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // 1.5s delay to allow database commit
                    await Future.delayed(const Duration(milliseconds: 500));

                    if (screenContext.mounted) {
                      await _fetchQuotations();
                    }
                  } else {
                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Failed to submit revision request. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A86C9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Send to Assigned Staff',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _priorityColumn(String label, String priority) {
    final color = _getPriorityColor(priority);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            priority.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
