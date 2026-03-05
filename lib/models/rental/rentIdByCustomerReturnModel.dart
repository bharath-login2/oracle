class RentIdByCustomerReturnModel {
  final bool status;
  final String message;
  final List<RentIssueItem> data;

  RentIdByCustomerReturnModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RentIdByCustomerReturnModel.fromJson(Map<String, dynamic> json) {
    return RentIdByCustomerReturnModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => RentIssueItem.fromJson(item))
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

class RentIssueItem {
  final String id;
  final String rentNo;
  final String invoiceNo;
  final String fromDate;
  final String toDate;

  RentIssueItem({
    required this.id,
    required this.rentNo,
    required this.invoiceNo,
    required this.fromDate,
    required this.toDate,
  });

  factory RentIssueItem.fromJson(Map<String, dynamic> json) {
    return RentIssueItem(
      id: json['id']?.toString() ?? '',
      rentNo: json['rent_no']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rent_no': rentNo,
      'invoice_no': invoiceNo,
      'from_date': fromDate,
      'to_date': toDate,
    };
  }
}
