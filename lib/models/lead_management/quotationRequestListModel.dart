class QuotationRequestList {
  String status;
  String message;
  List<QuotationRequestData> data;

  QuotationRequestList({
    required this.status,
    required this.message,
    required this.data,
  });

  factory QuotationRequestList.fromJson(Map<String, dynamic> json) {
    return QuotationRequestList(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => QuotationRequestData.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class QuotationRequestData {
  final String Id;
  final String customerName;
  final String createdBy;
  final String dueDate;
  final String assignedTo;
    final String assignedToId;
  final String status;
  final String priority;
  final String createdDate;
 final String isSend;
 final String quotationCreated;
  final String quotePk;
  QuotationRequestData({
       required this.Id,
    required this.customerName,
    required this.createdBy,
    required this.dueDate,
    required this.assignedTo,
     required this.assignedToId,
    required this.status,
    required this.priority,
    required this.createdDate,
      required this.isSend,
        required this.quotationCreated,
        required this.quotePk,
  });

  factory QuotationRequestData.fromJson(Map<String, dynamic> json) {
    return QuotationRequestData(
         Id: json['id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      assignedTo: json['assigned_to']?.toString() ?? '',
        assignedToId: json['assigned_to_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '', 
      priority: json['priority']?.toString() ?? '',
      createdDate: json['created_date']?.toString() ?? '',
       isSend: json['is_send']?.toString() ?? '',
        quotationCreated: json['quotation_created']?.toString() ?? '',
         quotePk: json['quote_pk']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
        'id': Id,
      'customer_name': customerName,
      'created_by': createdBy,
      'due_date': dueDate,
      'assigned_to': assignedTo,
         'assigned_to_id': assignedToId,
      'status': status,
      'priority': priority,
      'created_date': createdDate,
       'is_send': isSend,
       'quotation_created': quotationCreated,
        'quote_pk': quotePk,
    };
  }
}
