class RestoreInvoices {
  final String message;
  final bool data;
  final bool status;

  RestoreInvoices({
    required this.message,
    required this.data,
    required this.status,
  });

  factory RestoreInvoices.fromJson(Map<String, dynamic> json) {
    return RestoreInvoices(
      message: json['message']?.toString() ?? '',
      data: json['data'] ?? false,
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'RestoreInvoices{message: $message, data: $data, status: $status}';
  }
}
