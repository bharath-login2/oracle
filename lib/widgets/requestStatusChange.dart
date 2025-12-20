import 'package:flutter/material.dart';
import 'package:login2/service/service.dart';

class UpdateStatusSheet extends StatefulWidget {
  final String requestId;
  final String currentStatus;
  final Function()? onSuccess;

  const UpdateStatusSheet({
    super.key,
    required this.requestId,
    required this.currentStatus,
    this.onSuccess,
  });

  @override
  State<UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends State<UpdateStatusSheet> {
  String? _selectedStatus;
  bool _isLoading = false;

  final Map<String, String> _statusMap = {
    '1': 'Requested',
    '2': 'In Progress',
    '3': 'On Hold',
    '4': 'Completed',
    '5': 'Completed and Sent',
    '6': 'Sent',
  };

  @override
  void initState() {
    super.initState();
    // Set initial status based on current status
    final statusEntry = _statusMap.entries.firstWhere(
      (entry) => entry.value.toLowerCase() == widget.currentStatus.toLowerCase(),
      orElse: () => _statusMap.entries.first,
    );
    _selectedStatus = statusEntry.key;
  }

  void _updateStatus() async {
    if (_selectedStatus == null) return;

    setState(() => _isLoading = true);

    try {
      final result = await HttpService.updateRequestStatus(
        requestId: widget.requestId,
        status: _selectedStatus!,
      );

      if (result != null && result['status'] == "success") {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess?.call();
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['message'] ?? "Failed to update status"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("🔥 Error in updateStatus: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Server error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 5,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Update Status",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select New Status",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Current Status: ${_statusMap.entries.firstWhere((e) => e.key == _selectedStatus, orElse: () => _statusMap.entries.first).value}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Status Options
                  ..._statusMap.entries.map((entry) {
                    final isSelected = _selectedStatus == entry.key;
                    return _buildStatusOption(
                      entry.key,
                      entry.value,
                      isSelected,
                    );
                  }).toList(),
                  
                  const SizedBox(height: 30),
                  
                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 33, 91, 129),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text(
                              "Update Status",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(String statusId, String statusName, bool isSelected) {
    Color statusColor;
    IconData statusIcon;
    
    switch (statusId) {
      case '1': // Requested
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.access_time;
        break;
      case '2': // In Progress
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.trending_up;
        break;
      case '3': // On Hold
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.pause_circle;
        break;
      case '4': // Completed
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        break;
      case '5': // Completed and Sent
        statusColor = const Color(0xFF8B5CF6);
        statusIcon = Icons.check_circle;
        break;
      case '6': // Sent
        statusColor = const Color(0xFF8B5CF6);
        statusIcon = Icons.send;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? statusColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => setState(() => _selectedStatus = statusId),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              statusIcon,
              size: 20,
              color: statusColor,
            ),
          ),
        ),
        title: Text(
          statusName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected ? statusColor : Colors.black87,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: statusColor,
              )
            : null,
        tileColor: isSelected ? statusColor.withOpacity(0.05) : null,
      ),
    );
  }
}