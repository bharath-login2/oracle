class QuotationResponse {
  final List<QuotationItem> data;
  final bool status;
  final String message;

  QuotationResponse({
    required this.data,
    required this.status,
    required this.message,
  });

  factory QuotationResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? [];
    List<QuotationItem> dataList =
        list.map((i) => QuotationItem.fromJson(i)).toList();

    return QuotationResponse(
      data: dataList,
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class QuotationItem {
  final String id;
  final String quotationType;
  final String customerId;
  final String customerName;
  final String leadId;
  final String total;
  final String createdBy;
  final String createdDate;
  final String branchName;
  final String state;
  final String priority;
  final int status;
  final String statusLabel;
  final String requestId;
  final String assignedTo;
  final String revisionId;
  final String revisionComments;
  final String quotationDocument;

  QuotationItem({
    required this.id,
    required this.quotationType,
    required this.customerId,
    required this.customerName,
    required this.leadId,
    required this.total,
    required this.createdBy,
    required this.createdDate,
    required this.branchName,
    required this.state,
    required this.priority,
    required this.status,
    required this.statusLabel,
    required this.requestId,
    required this.assignedTo,
    required this.revisionId,
    required this.revisionComments,
    required this.quotationDocument,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      id: json['id']?.toString() ?? '',
      quotationType: json['quotation_type']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      leadId: json['lead_id']?.toString() ?? '',
      total: json['total']?.toString() ?? '0',
      createdBy: json['created_by']?.toString() ?? '',
      createdDate: json['created_date']?.toString() ?? '',
      branchName: json['branch_name']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'Low',
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '1') ?? 1,
      statusLabel: json['status_label']?.toString() ?? 'Pending',
      requestId: json['request_id']?.toString() ?? '',
      assignedTo: json['assigned_to']?.toString() ?? '',
      revisionId: json['revision_id']?.toString() ?? '',
      revisionComments: json['revision_comments']?.toString() ?? '',
      quotationDocument: json['quotation_document']?.toString() ?? '',
    );
  }
}
