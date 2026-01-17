import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/quotationRequestListModel.dart';
import 'package:login2/models/lead_management/requestDetailsModel.dart';
import 'package:login2/screens/leadManagement/addQuotationPage.dart';
import 'package:login2/screens/leadManagement/add_quotation_request_sheet.dart';
import 'package:login2/screens/leadManagement/editQuotationSheetRequest.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/requestStatusChange.dart';

class QuotationRequestPage extends StatefulWidget {
  final String requestType;

  const QuotationRequestPage({super.key, required this.requestType});

  @override
  State<QuotationRequestPage> createState() => _QuotationRequestPageState();
}

class _QuotationRequestPageState extends State<QuotationRequestPage> {
  late Future<QuotationRequestList?> _futureRequests;
  List<QuotationRequestData> _allRequests = [];
  List<QuotationRequestData> _filteredRequests = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  bool _isLoading = true;
  bool _isDeleting = false;

  String userId = "";
  final List<Map<String, dynamic>> _filterChips = [
    {'label': 'All', 'color': Colors.blue},
    {'label': 'Pending', 'color': Colors.orange},
    {'label': 'In Progress', 'color': Colors.yellow.shade700},
    {'label': 'Completed', 'color': Colors.green},
    {'label': 'On Hold', 'color': Colors.grey},
    {'label': 'Sent', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _setInitialFilter();
    _loadUserId();
    _futureRequests = _loadRequests();
  }

  void _setInitialFilter() {
    // Direct mapping from status value to filter name
    if (widget.requestType == null || widget.requestType == 'All') {
      _selectedFilter = 'All';
    } else {
      final statusString = widget.requestType.toString();
      switch (statusString) {
        case '2':
          _selectedFilter = 'Sent';
          break;
        case '4':
          _selectedFilter = 'Completed';
          break;
        case '7':
          _selectedFilter = 'Pending';
          break;
        default:
          _selectedFilter = 'All';
      }
    }
  }

  Future<void> _loadUserId() async {
    userId = await Common.getSharedPref("userId");
  }

  Future<QuotationRequestList?> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await HttpService().getQuotationRequestList(widget.requestType);

      if (response != null && response.data.isNotEmpty) {
        setState(() {
          _allRequests = response.data;
          _filteredRequests = _allRequests;
        });
      }
      return response;
    } catch (e) {
      return null;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterRequests(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredRequests = _allRequests;
      });
    } else {
      final lowerCaseQuery = query.toLowerCase();
      setState(() {
        _filteredRequests = _allRequests.where((request) {
          final customerName = request.customerName.toLowerCase();
          final assignedTo = request.assignedTo.toLowerCase();
          final createdBy = request.createdBy.toLowerCase();
          final status = request.status.toLowerCase();
          final priority = request.priority.toLowerCase();

          return customerName.contains(lowerCaseQuery) ||
              assignedTo.contains(lowerCaseQuery) ||
              createdBy.contains(lowerCaseQuery) ||
              status.contains(lowerCaseQuery) ||
              priority.contains(lowerCaseQuery);
        }).toList();
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredRequests = _allRequests;
      } else {
        _filteredRequests = _allRequests.where((request) {
          final status = request.status.toLowerCase();
          if (filter == 'Pending') {
            return status.contains('pending') || status.contains('requested');
          } else if (filter == 'In Progress') {
            return status.contains('progress');
          } else if (filter == 'Completed') {
            return status.contains('completed');
          } else if (filter == 'On Hold') {
            return status.contains('hold');
          } else if (filter == 'Sent') {
            return status.contains('sent');
          }
          return false;
        }).toList();
      }
      if (_searchController.text.isNotEmpty) {
        _filterRequests(_searchController.text);
      }
    });
  }

  Color _statusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('requested') || statusLower.contains('pending')) {
      return Colors.orange;
    } else if (statusLower.contains('send') || statusLower.contains('sent')) {
      return Colors.purple;
    } else if (statusLower.contains('completed') ||
        statusLower.contains('approved')) {
      return Colors.green;
    } else if (statusLower.contains('progress')) {
      return Colors.yellow.shade700;
    } else if (statusLower.contains('hold') || statusLower.contains('cancel')) {
      return Colors.grey;
    }
    return Colors.blue;
  }

  String _statusIcon(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('requested') || statusLower.contains('pending')) {
      return "⏳";
    } else if (statusLower.contains('send') || statusLower.contains('sent')) {
      return "📤";
    } else if (statusLower.contains('completed') ||
        statusLower.contains('approved')) {
      return "✅";
    } else if (statusLower.contains('progress')) {
      return "📈";
    } else if (statusLower.contains('hold') || statusLower.contains('cancel')) {
      return "⏸️";
    }
    return "📄";
  }

  String _getStatusText(String status) {
    switch (status) {
      case "1":
        return "Requested";
      case "2":
        return "In Progress";
      case "3":
        return "On Hold";
      case "4":
        return "Completed";
      case "5":
        return "Completed and Sent";
      default:
        return "Send";
    }
  }

  Widget _buildRequestCard(QuotationRequestData request) {
    final daysLeft = _calculateDaysLeft(request.dueDate);
    final isUrgent = daysLeft <= 2;
    final isOverdue = daysLeft < 0;

    return InkWell(
      onTap: () => _showRequestDetails(request),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1C1A79).withOpacity(0.15),
                    radius: 26,
                    child: const Icon(
                      Icons.request_quote_outlined,
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
                          request.customerName,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created By: ${request.createdBy}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Colors.black87,
                          ),
                        ),
                        // Text(
                        //   'Due: ${_formatDate(request.dueDate)}',
                        //   style: TextStyle(
                        //     fontSize: 13.5,
                        //     color: isUrgent
                        //         ? Colors.orange.shade700
                        //         : isOverdue
                        //             ? Colors.red
                        //             : Colors.black87,
                        //     fontWeight: isUrgent || isOverdue
                        //         ? FontWeight.w600
                        //         : FontWeight.normal,
                        //   ),
                        // ),
                        // if (daysLeft <= 5)
                        //   Container(
                        //     margin: const EdgeInsets.only(top: 4),
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 8,
                        //       vertical: 2,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: isOverdue
                        //           ? Colors.red.shade50
                        //           : Colors.orange.shade50,
                        //       borderRadius: BorderRadius.circular(12),
                        //       border: Border.all(
                        //         color: isOverdue
                        //             ? Colors.red.shade200
                        //             : Colors.orange.shade200,
                        //       ),
                        //     ),
                        //     child: Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Icon(
                        //           isOverdue
                        //               ? Icons.warning
                        //               : Icons.access_time,
                        //           size: 12,
                        //           color: isOverdue
                        //               ? Colors.red.shade700
                        //               : Colors.orange.shade700,
                        //         ),
                        //         const SizedBox(width: 4),
                        //         Text(
                        //           isOverdue
                        //               ? 'Overdue by ${daysLeft.abs()} days'
                        //               : '$daysLeft days left',
                        //           style: TextStyle(
                        //             fontSize: 11,
                        //             color: isOverdue
                        //                 ? Colors.red.shade700
                        //                 : Colors.orange.shade700,
                        //             fontWeight: FontWeight.w600,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildPriorityBadge(request.priority),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(request.status.toString())
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _statusColor(request.status.toString())
                                  .withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _statusIcon(request.status.toString()),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusText(request.status.toString()),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _statusColor(request.status.toString()),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigned To',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            request.assignedTo,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (request.assignedToId == userId &&
                          request.isSend == "0" &&
                          request.quotationCreated != "1")
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _actionButton(
                            color: const Color.fromARGB(255, 166, 124, 221),
                            icon: Icons.upload_outlined,
                            tooltip: 'Upload Quotation',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddQuotationPage(requestId: request.Id),
                              ),
                            ),
                          ),
                        ),
                      // _actionButton(
                      //   color: const Color.fromARGB(255, 50, 151, 218),
                      //   icon: Icons.remove_red_eye,
                      //   tooltip: 'View Details',
                      //   onTap: () => _showRequestDetails(request),
                      // ),
                      Tooltip(
                        message: 'View PDF',
                        child: InkWell(
                          // onTap: () {
                          onTap: () => _showRequestDetails(request),
                          //},
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
                      const SizedBox(width: 8),
                      _actionButton(
                        color: const Color.fromARGB(255, 50, 151, 218),
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onTap: () => _editRequest(request),
                      ),
                      const SizedBox(width: 8),
                      _isDeleting
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
                              onTap: () => _deleteRequest(request),
                            ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    String label;
    IconData icon;

    switch (priority.toLowerCase()) {
      case 'critical':
        color = Colors.red;
        label = 'Critical';
        icon = Icons.warning;
        break;
      case 'high':
        color = Colors.orange;
        label = 'High';
        icon = Icons.arrow_upward;
        break;
      case 'medium':
        color = Colors.yellow.shade700;
        label = 'Medium';
        icon = Icons.horizontal_rule;
        break;
      case 'low':
        color = Colors.green;
        label = 'Low';
        icon = Icons.arrow_downward;
        break;
      default:
        color = Colors.grey;
        label = priority;
        icon = Icons.flag;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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

  Widget _buildFilterChip(Map<String, dynamic> chip) {
    final isSelected = _selectedFilter == chip['label'];
    final color = chip['color'] as Color;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(chip['label']),
        selected: isSelected,
        onSelected: (selected) {
          _applyFilter(selected ? chip['label'] : 'All');
        },
        backgroundColor: isSelected ? color : Colors.grey[200],
        selectedColor: color,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'No date';
    try {
      final inputFormat = DateFormat('dd-MM-yyyy');
      final outputFormat = DateFormat('MMM dd, yyyy');
      return outputFormat.format(inputFormat.parse(date));
    } catch (e) {
      return date;
    }
  }

  int _calculateDaysLeft(String? dueDate) {
    if (dueDate == null || dueDate.isEmpty) return 999;
    try {
      final format = DateFormat('yyyy-MM-dd');
      final due = format.parse(dueDate);
      final now = DateTime.now();
      final difference = due.difference(now);
      return difference.inDays;
    } catch (e) {
      return 999;
    }
  }

  void _showRequestDetails(QuotationRequestData data) {
    Future<RequestDetailsResponseModel?> requestDetailsFuture =
        HttpService.requestDetails(data.Id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FutureBuilder<RequestDetailsResponseModel?>(
        future: requestDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingDetailSheet();
          } else if (snapshot.hasError) {
            return _buildErrorDetailSheet(snapshot.error.toString(), data);
          } else if (!snapshot.hasData ||
              snapshot.data?.data?.request == null) {
            return _buildNoDataDetailSheet(data);
          }
          return _buildDetailedSheetWithData(
              snapshot.data!.data!.request!, data);
        },
      ),
    );
  }

  Widget _buildLoadingDetailSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading request details...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDetailSheet(String error, QuotationRequestData data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 32,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Error: $error',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Close'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataDetailSheet(QuotationRequestData data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber,
              size: 32,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No detailed information available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Showing basic information only',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildBasicInfoSection(data),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Close'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(QuotationRequestData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.customerName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        _buildBasicInfoRow('Status', _getStatusText(data.status.toString()),
            color: _statusColor(data.status.toString())),
        _buildBasicInfoRow('Priority', data.priority),
        _buildBasicInfoRow('Assigned To', data.assignedTo),
        _buildBasicInfoRow('Due Date', _formatDate(data.dueDate)),
      ],
    );
  }

  Widget _buildBasicInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color ?? const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedSheetWithData(
      RequestDetails requestDetails, QuotationRequestData listData) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header Section
                  _buildHeaderSection(requestDetails),

                  const SizedBox(height: 24),

                  // Status & Priority Cards
                  _buildStatusPriorityCards(requestDetails),

                  const SizedBox(height: 24),

                  // Request Info Section
                  _buildRequestInfoSection(requestDetails),

                  const SizedBox(height: 24),

                  // Products Section
                  _buildProductsSection(requestDetails),

                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(requestDetails, listData),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(RequestDetails requestDetails) {
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: _statusColor(requestDetails.status ?? 'Pending')
                .withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              requestDetails.customerName?.substring(0, 1).toUpperCase() ?? 'C',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _statusColor(requestDetails.status ?? 'Pending'),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                requestDetails.customerName ?? 'Unknown Customer',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Request ID: #${requestDetails.id}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Created: ${_formatDate(requestDetails.createdAt)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPriorityCards(RequestDetails requestDetails) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _statusColor(requestDetails.status ?? 'Pending')
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _statusColor(requestDetails.status ?? 'Pending')
                    .withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _statusColor(requestDetails.status ?? 'Pending')
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _statusIcon(requestDetails.status ?? 'Pending'),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusText(requestDetails.status ?? '1'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(requestDetails.status ?? 'Pending'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getPriorityColor(requestDetails.priority ?? 'Medium')
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getPriorityColor(requestDetails.priority ?? 'Medium')
                    .withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 20,
                      color: _getPriorityColor(
                          requestDetails.priority ?? 'Medium'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  requestDetails.priority ?? 'Medium',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color:
                        _getPriorityColor(requestDetails.priority ?? 'Medium'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow.shade700;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRequestInfoSection(RequestDetails requestDetails) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
              Icons.person, 'Assigned To', requestDetails.assignedTo ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person_add, 'Created By',
              requestDetails.createdBy ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, 'Due Date',
              _formatDate(requestDetails.dueDate)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_month, 'Created Date',
              _formatDate(requestDetails.createdAt)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection(RequestDetails requestDetails) {
    final products = requestDetails.products ?? [];

    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No products listed',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory,
                  size: 24,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${products.length} items',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...products.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;

            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName ?? 'Unnamed Product',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantity: ${product.quantity ?? 0}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Qty: ${product.quantity ?? 0}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      RequestDetails requestDetails, QuotationRequestData listData) {
    return Column(
      children: [
        // Update Status Button (if assigned to current user)
        if (userId == listData.assignedToId.toString())
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showUpdateStatusSheet(listData);
              },
              icon: const Icon(Icons.update, size: 18),
              label: const Text('Update Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        if (userId == listData.assignedToId.toString())
          const SizedBox(height: 12),

        // Create Quotation Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddQuotationPage(requestId: listData.Id),
                ),
              );
            },
            icon: const Icon(Icons.add_chart, size: 18),
            label: const Text('Create Quotation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 166, 124, 221),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Close Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Close'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showUpdateStatusSheet(QuotationRequestData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpdateStatusSheet(
        requestId: data.Id,
        currentStatus: data.status.toString(),
        onSuccess: () {
          Navigator.pop(context);
          setState(() {
            _futureRequests = _loadRequests();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Status updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, dynamic value,
      {Color? color, bool isUrgent = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isUrgent ? Colors.orange : color ?? const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editRequest(QuotationRequestData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditQuotationRequestSheet(
        requestId: data.Id,
        onSuccess: () {
          setState(() {
            _futureRequests = _loadRequests();
          });
        },
      ),
    );
  }

  void _deleteRequest(QuotationRequestData data) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Request'),
        content: const Text('Are you sure you want to delete this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isDeleting = true);

              try {
                final response =
                    await HttpService.deleteRequestQuotation(data.Id);
                if (!mounted) return;

                if (response.status) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                  setState(() {
                    _futureRequests = _loadRequests();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message),
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
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              } finally {
                setState(() => _isDeleting = false);
              }
            },
          ),
        ],
      ),
    );
  }

  void _openAddQuotationRequest() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddQuotationRequestSheet(
        onSuccess: () {
          setState(() {
            _futureRequests = _loadRequests();
          });
        },
      ),
    );
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
        title: Text(
          widget.requestType == "2"
              ? 'Sent Requests'
              : widget.requestType == "4"
                  ? "Completed Requests"
                  : widget.requestType == "7"
                      ? "Pending Requets"
                      : "Total Requests",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 22, 145, 216),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 26, color: Colors.white),
            tooltip: 'Add Request',
            onPressed: _openAddQuotationRequest,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
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
                      onChanged: _filterRequests,
                      decoration: InputDecoration(
                        hintText: 'Search by customer, assigned to, status...',
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
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
                                  _filterRequests('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

                // Filter Chips
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filterChips.map(_buildFilterChip).toList(),
                    ),
                  ),
                ),

                // Results count
                if (_searchController.text.isNotEmpty ||
                    _selectedFilter != 'All')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          'Found ${_filteredRequests.length} result(s)',
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
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _futureRequests = _loadRequests();
                      });
                    },
                    child: _filteredRequests.isEmpty
                        ? _buildEmptyState()
                        : ListView(
                            padding: const EdgeInsets.all(12),
                            children: [
                              if (_allRequests.isNotEmpty)
                                _buildStatsSummary(_filteredRequests),
                              ..._filteredRequests
                                  .map((request) => _buildRequestCard(request)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
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
                  Icons.request_quote_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
              const SizedBox(height: 16),
              Text(
                _searchController.text.isNotEmpty
                    ? "No results for '${_searchController.text}'"
                    : "No quotation requests found",
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
                    : "Create your first quotation request",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openAddQuotationRequest,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 22, 145, 216),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      _applyFilter('All');
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear Search & Filters'),
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
    );
  }

  Widget _buildStatsSummary(List<QuotationRequestData> requests) {
    final total = requests.length;
    final pending = requests
        .where((r) =>
            r.status.toLowerCase().contains('pending') ||
            r.status.toLowerCase().contains('requested'))
        .length;
    final inProgress = requests
        .where((r) => r.status.toLowerCase().contains('progress'))
        .length;
    final completed = requests
        .where((r) => r.status.toLowerCase().contains('completed'))
        .length;
    final urgent =
        requests.where((r) => _calculateDaysLeft(r.dueDate) <= 2).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
