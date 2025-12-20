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

  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _futureRequests = _loadRequests();
  }

  Future<void> _loadUserId() async {
    userId = await Common.getSharedPref("userId");
  }

  Future<QuotationRequestList?> _loadRequests() async {
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
      return const Color(0xFF3B82F6); // Blue
    } else if (statusLower.contains('send') || statusLower.contains('sent')) {
      return const Color(0xFF8B5CF6); // Purple
    } else if (statusLower.contains('completed') ||
        statusLower.contains('approved')) {
      return const Color(0xFF10B981); // Green
    } else if (statusLower.contains('progress')) {
      return const Color(0xFFF59E0B); // Orange
    } else if (statusLower.contains('hold') || statusLower.contains('cancel')) {
      return const Color(0xFFEF4444); // Red
    }
    return const Color(0xFF6B7280); // Gray
  }

  IconData _statusIcon(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('requested') || statusLower.contains('pending')) {
      return Icons.access_time;
    } else if (statusLower.contains('send') || statusLower.contains('sent')) {
      return Icons.send;
    } else if (statusLower.contains('completed') ||
        statusLower.contains('approved')) {
      return Icons.check_circle;
    } else if (statusLower.contains('progress')) {
      return Icons.trending_up;
    } else if (statusLower.contains('hold') || statusLower.contains('cancel')) {
      return Icons.pause_circle;
    }
    return Icons.info;
  }

  Widget _buildRequestCard(QuotationRequestData request) {
    final daysLeft = _calculateDaysLeft(request.dueDate);
    final isUrgent = daysLeft <= 2;
    final isOverdue = daysLeft < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showRequestDetails(request),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _statusColor(request.status.toString())
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          request.customerName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _statusColor(request.status.toString()),
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
                            request.customerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Created by ${request.createdBy}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPriorityBadge(request.priority),
                  ],
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(request.status.toString())
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _statusIcon(request.status.toString()),
                            size: 14,
                            color: _statusColor(request.status.toString()),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            request.status == "1"
                                ? "Requested"
                                : request.status == "2"
                                    ? "In Progress"
                                    : request.status == "3"
                                        ? "On Hold"
                                        : request.status == "4"
                                            ? "Completed"
                                            : request.status == "5"
                                                ? "Completed and Send"
                                                : "Send",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _statusColor(request.status.toString()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _buildActionButton(
                      icon: Icons.add,
                      color: const Color.fromARGB(255, 166, 124, 221),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddQuotationPage(requestId: request.Id),
                        ),
                      ),
                      tooltip: 'Upload',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Assigned and Actions Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigned to',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
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
                              Expanded(
                                child: Text(
                                  request.assignedTo,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1F2937),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.remove_red_eye_outlined,
                          color: Colors.blue,
                          onPressed: () => _showRequestDetails(request),
                          tooltip: 'View Details',
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.edit_outlined,
                          color: Colors.orange,
                          onPressed: () => _editRequest(request),
                          tooltip: 'Edit',
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          onPressed: () => _deleteRequest(request),
                          tooltip: 'Delete',
                        ),
                      ],
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

  Widget _buildPriorityBadge(String priority) {
    Color color;
    String label;

    switch (priority.toLowerCase()) {
      case 'critical':
        color = Colors.red;
        label = 'Critical';
        break;
      case 'high':
        color = Colors.orange;
        label = 'High';
        break;
      case 'medium':
        color = Colors.yellow[700]!;
        label = 'Medium';
        break;
      case 'low':
        color = Colors.green;
        label = 'Low';
        break;
      default:
        color = Colors.grey;
        label = priority;
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
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 18,
                color: color,
              ),
            ),
          ),
        ),
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

  // ============================ UPDATED SHOW REQUEST DETAILS ============================
  void _showRequestDetails(QuotationRequestData data) {
    // Create a future for the API call
    Future<RequestDetailsResponseModel?> requestDetailsFuture =
        HttpService.requestDetails(data.Id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FutureBuilder<RequestDetailsResponseModel?>(
        future: requestDetailsFuture,
        builder: (context, snapshot) {
          // Handle different states of the Future
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingDetailSheet();
          } else if (snapshot.hasError) {
            return _buildErrorDetailSheet(snapshot.error.toString(), data);
          } else if (!snapshot.hasData ||
              snapshot.data?.data?.request == null) {
            return _buildNoDataDetailSheet(data);
          }

          // We have data - build the detailed sheet
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
          // Show basic info from the list data
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
        _buildBasicInfoRow('Status', data.status,
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
                    Icon(
                      _statusIcon(requestDetails.status ?? 'Pending'),
                      size: 20,
                      color: _statusColor(requestDetails.status ?? 'Pending'),
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
                  requestDetails.status ?? 'Unknown',
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
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      case 'medium':
        return Colors.orange;
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
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                final response =
                    await HttpService.deleteRequestQuotation(data.Id);
                Navigator.of(context, rootNavigator: true).pop();
                if (!mounted) return;
                if (response.status) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message),
                      backgroundColor: Colors.green,
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
                    ),
                  );
                }
              } catch (e) {
                Navigator.of(context, rootNavigator: true).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Quotation Requests',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 22, 145, 216),
        foregroundColor: const Color.fromARGB(255, 252, 252, 252),
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 20, color: Colors.blue),
            ),
            onPressed: _openAddQuotationRequest,
            tooltip: "ADD",
          ),
        ],
      ),
      body: FutureBuilder<QuotationRequestList?>(
        future: _futureRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState();
          } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
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
                                _filterRequests('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', _selectedFilter == 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', _selectedFilter == 'Pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          'In Progress', _selectedFilter == 'In Progress'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          'Completed', _selectedFilter == 'Completed'),
                      const SizedBox(width: 8),
                      _buildFilterChip('On Hold', _selectedFilter == 'On Hold'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Sent', _selectedFilter == 'Sent'),
                    ],
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty || _selectedFilter != 'All')
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Showing ${_filteredRequests.length} of ${_allRequests.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const Spacer(),
                      if (_searchController.text.isNotEmpty ||
                          _selectedFilter != 'All')
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
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _futureRequests = _loadRequests();
                    });
                  },
                  child: _filteredRequests.isEmpty
                      ? _buildNoResultsState()
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _buildStatsSummary(_filteredRequests),
                            const SizedBox(height: 24),
                            ..._filteredRequests
                                .map((request) => _buildRequestCard(request)),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _applyFilter(selected ? label : 'All');
      },
      backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
      ),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildNoResultsState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchController.text.isNotEmpty
                    ? "No results for '${_searchController.text}'"
                    : "No requests match the selected filter",
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
                    : "Try selecting a different filter",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: 120,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 80,
                          color: Colors.grey[200],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Failed to load requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your connection and try again',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _futureRequests = _loadRequests();
              });
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.request_quote_outlined,
              size: 48,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No requests found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first quotation request',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openAddQuotationRequest,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Request'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(List<QuotationRequestData> requests) {
    final total = requests.length;
    final pending = requests
        .where((r) => r.status.toLowerCase().contains('pending'))
        .length;
    final completed = requests
        .where((r) => r.status.toLowerCase().contains('completed'))
        .length;
    final urgent =
        requests.where((r) => _calculateDaysLeft(r.dueDate) <= 2).length;

    return Row(
      children: [
        _buildStatItem('Total', total, Colors.blue),
        const SizedBox(width: 12),
        _buildStatItem('Pending', pending, Colors.orange),
        const SizedBox(width: 12),
        _buildStatItem('Completed', completed, Colors.green),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
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
        ),
      ),
    );
  }
}
