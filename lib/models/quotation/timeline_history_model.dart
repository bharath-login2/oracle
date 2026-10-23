class QuotationHistoryItem {
  final String status;
  final String timestamp;
  final String description;

  QuotationHistoryItem({
    required this.status,
    required this.timestamp,
    required this.description,
  });

  factory QuotationHistoryItem.fromJson(Map<String, dynamic> json) {
    final String remark = json['remark'] ?? '';

    // Extract a status badge title from the remark if possible (e.g., "Pending", "Approved", "Revision", "Created")
    String extractedStatus = 'Activity';
    if (remark.toLowerCase().contains('pending')) {
      extractedStatus = 'Pending';
    } else if (remark.toLowerCase().contains('approved')) {
      extractedStatus = 'Approved';
    } else if (remark.toLowerCase().contains('revision')) {
      extractedStatus = 'Revision';
    } else if (remark.toLowerCase().contains('created')) {
      extractedStatus = 'Created';
    } else if (remark.toLowerCase().contains('review')) {
      extractedStatus = 'Under Review';
    }

    return QuotationHistoryItem(
      status: extractedStatus,
      timestamp: json['created_at'] ?? '',
      description:
          remark, // Displays the full remark string like "Quotation Status Updated to Pending By Demo"
    );
  }
}
