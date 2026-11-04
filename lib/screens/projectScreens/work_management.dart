import 'package:flutter/material.dart';
import 'package:login2/service/service.dart';

import '../../models/projectdetails/work_management/work_management_model.dart';
import '../../service/service.dart';

class WorkManagementScreen extends StatefulWidget {
  final String projectId;

  const WorkManagementScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  State<WorkManagementScreen> createState() => _WorkManagementScreenState();
}

class _WorkManagementScreenState extends State<WorkManagementScreen> {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  bool _isLoading = true;
  String _errorMessage = '';
  List<WorkRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _fetchWorkData();
  }

  Future<void> _fetchWorkData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Calls your exact service method
      final response =
          await HttpService.getWorkManagement(projectId: widget.projectId);

      if (response != null && response.status) {
        setState(() {
          _records = response.data?.records ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response?.message.isNotEmpty == true
              ? response!.message
              : 'Failed to load work management records.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in-progress':
      case 'in progress':
        return Colors.orange;
      case 'to-do':
      case 'todo':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 42,
                color: _primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No work items found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No work management records are available for this project.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ERROR STATE
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _fetchWorkData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WORK MANAGEMENT CARD UI

  // One detail item: logo + name (label) + value
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = _primary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkCard(WorkRecord record) {
    final statusColor = _getStatusColor(record.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkDetailsScreen(
                  record: record,
                  statusColor: statusColor,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER: logo + small status indicator + title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.assignment_rounded,
                            size: 20,
                            color: _primary,
                          ),
                        ),
                        Positioned(
                          right: -1,
                          bottom: -1,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Work',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            record.displayTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                // Project Name
                _buildDetailItem(
                  icon: Icons.business_center_rounded,
                  label: 'Project',
                  value: record.projectName,
                ),
                const SizedBox(height: 12),

                // ROW: Customer + Assigned To
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.person_rounded,
                        label: 'Customer',
                        value: record.customerName,
                        iconColor: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.assignment_ind_rounded,
                        label: 'Assigned To',
                        value: record.assignedName,
                        iconColor: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ROW: Unit / Lift + Due Date
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.apartment_rounded,
                        label: 'Unit / Lift',
                        value: '${record.unitNo} / ${record.siteLiftName}',
                        iconColor: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.event_rounded,
                        label: 'Due Date',
                        value: record.formattedDueDate,
                        iconColor: Colors.orange,
                      ),
                    ),
                  ],
                ),

                // Attachments indicator
                if (record.hasAttachments) ...[
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    icon: Icons.attach_file_rounded,
                    label: 'Attachments',
                    value: 'Has attachments',
                    iconColor: Colors.blueGrey,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _fetchWorkData,
      child: _records.isEmpty
          ? ListView(
              // Allows pull-to-refresh even when list is empty
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: _buildEmptyState(),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                return _buildWorkCard(_records[index]);
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        title: const Text(
          'Work management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 26,
              ),
              onPressed: _fetchWorkData,
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _primary,
                _primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }
}


// WORK DETAILS SCREEN (opens when a card is tapped)

class WorkDetailsScreen extends StatelessWidget {
  static const Color _primary = Color(0xFF2A86C9);
  static const Color _primaryDark = Color(0xFF1A6CA8);

  final WorkRecord record;
  final Color statusColor;

  const WorkDetailsScreen({
    super.key,
    required this.record,
    required this.statusColor,
  });

  // One row: logo + label + value (value can be a custom widget)
  Widget _buildRow({
    required IconData icon,
    required String label,
    String? value,
    Widget? valueWidget,
    Color iconColor = _primary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 7),
              child: valueWidget ??
                  Text(
                    (value == null || value.isEmpty) ? '-' : value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200);

  @override
  Widget build(BuildContext context) {
    final status = record.status;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        title: const Text(
          'Work Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, _primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // NOTE: id, assignedByName, description and priority are assumed
              // field names on WorkRecord. Rename them to match your model.
              _buildRow(
                icon: Icons.tag_rounded,
                label: 'ID',
                value: '#${record.id}',
              ),
              _divider(),
              _buildRow(
                icon: Icons.business_center_rounded,
                label: 'Project Name',
                value: record.projectName,
              ),
              _divider(),
              _buildRow(
                icon: Icons.assignment_rounded,
                label: 'Task',
                value: record.displayTitle,
                iconColor: Colors.indigo,
              ),
              _divider(),
              _buildRow(
                icon: Icons.person_rounded,
                label: 'Assigned By',
                // value: record.assignedByName,
                iconColor: Colors.purple,
              ),
              _divider(),
              _buildRow(
                icon: Icons.event_rounded,
                label: 'Due Date',
                value: record.formattedDueDate,
                iconColor: Colors.orange,
              ),
              _divider(),
              _buildRow(
                icon: Icons.notes_rounded,
                label: 'Description',
                // value: record.,
                iconColor: Colors.blueGrey,
              ),
              _divider(),
              _buildRow(
                icon: Icons.flag_rounded,
                label: 'Status',
                iconColor: statusColor,
                valueWidget: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.isNotEmpty ? status : 'N/A',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ),
              _divider(),
              _buildRow(
                icon: Icons.priority_high_rounded,
                label: 'Priority',
                value: record.priority,
                iconColor: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}