import 'package:flutter/material.dart';
import 'package:login2/models/lead_management/getPurchaseRequestListModel.dart';
import 'package:login2/service/service.dart';
import 'package:login2/core/common.dart';

// Add this method to show the approval dialog
void showApprovalDialog(BuildContext context, PurchaseRequestData request, {VoidCallback? onRefresh}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ApprovalDialog(request: request, onRefresh: onRefresh);
    },
  );
}

class ApprovalDialog extends StatefulWidget {
  final PurchaseRequestData request;
  final VoidCallback? onRefresh;

  const ApprovalDialog({super.key, required this.request, this.onRefresh});

  @override
  State<ApprovalDialog> createState() => _ApprovalDialogState();
}

class _ApprovalDialogState extends State<ApprovalDialog> {
  String? _selectedAction; // 'Approved' or 'Rejected'
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a86c9).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.assignment_turned_in,
                      color: Color(0xFF2a86c9), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Approve Purchase Request',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Request Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request #${widget.request.requestId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requested by: ${widget.request.requestedBy}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Amount: ₹${widget.request.estimatedAmount}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Radio Buttons
            const Text(
              'Select Action',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.green.shade700, size: 22),
                        const SizedBox(width: 12),
                        const Text('Approved',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    value: 'Approved',
                    groupValue: _selectedAction,
                    onChanged: (value) {
                      setState(() {
                        _selectedAction = value;
                      });
                    },
                    activeColor: Colors.green,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.cancel_schedule_send,
                            color: Colors.red.shade700, size: 22),
                        const SizedBox(width: 12),
                        const Text('Rejected',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    value: 'Rejected',
                    groupValue: _selectedAction,
                    onChanged: (value) {
                      setState(() {
                        _selectedAction = value;
                      });
                    },
                    activeColor: Colors.red,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    child: const Text('Close',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading || _selectedAction == null
                        ? null
                        : () => _submitApproval(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2a86c9),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Submit',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitApproval(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    // Map selection to status code: 2 for Approved, 3 for Rejected
    String statusCode = _selectedAction == 'Approved' ? '2' : '3';
    
    final result = await HttpService.purchaseReqAprovalOrReject(
      widget.request.id ?? '', // Use id, not requestId
      statusCode,
    );

    setState(() {
      _isLoading = false;
    });

    if (result != null && result.status == true) {
      // Refresh the list first
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
      
      // Show success toast message
      Common.toastMessaage(
        result.message ?? 'Request ${_selectedAction?.toLowerCase()} successfully',
        Colors.green,
      );

      // Close both dialogs safely
      final navigator = Navigator.of(context);
      navigator.pop(); // Close approval dialog
      navigator.pop(); // Close details drawer
    } else {
      Common.toastMessaage(
        result?.message ?? 'Failed to update request status',
        Colors.red,
      );
    }
  }
}