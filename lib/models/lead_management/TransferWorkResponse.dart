class TransferWorkResponse {
  final String message;
  final Data? data;
  final bool status;

  TransferWorkResponse({
    required this.message,
    required this.data,
    required this.status,
  });

  factory TransferWorkResponse.fromJson(Map<String, dynamic> json) {
    return TransferWorkResponse(
      message: json['message'] ?? '',
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      status: json['status'] == true || json['status'] == "true",
    );
  }
}

class Data {
  final String workId;
  final dynamic assignedTo;

  Data({
    required this.workId,
    required this.assignedTo,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      workId: json['work_id']?.toString() ?? '',
      assignedTo: json['assigned_to'],
    );
  }
}
