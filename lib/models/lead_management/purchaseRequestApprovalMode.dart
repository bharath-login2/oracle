class PurchaseRequestApprovalModel {
  final bool status;
  final String message;
  final List<dynamic> data;

  PurchaseRequestApprovalModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PurchaseRequestApprovalModel.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestApprovalModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }

  PurchaseRequestApprovalModel copyWith({
    bool? status,
    String? message,
    List<dynamic>? data,
  }) {
    return PurchaseRequestApprovalModel(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'PurchaseRequestApprovalModel(status: $status, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseRequestApprovalModel &&
        other.status == status &&
        other.message == message &&
        other.data == data;
  }

  @override
  int get hashCode => status.hashCode ^ message.hashCode ^ data.hashCode;
}