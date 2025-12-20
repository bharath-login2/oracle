class QuotationDashboardResponse {
  final String status;
  final String message;
  final QuotationDashboardData data;

  QuotationDashboardResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory QuotationDashboardResponse.fromJson(Map<String, dynamic> json) {
    return QuotationDashboardResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: QuotationDashboardData.fromJson(json['data'] ?? {}),
    );
  }
}

class QuotationDashboardData {
  final int totalRequest;
  final int newRequests;
  final int pendingRequest;
  final int completedRequest;
  final int totalQuotations;
  final int totalApproved;
  final int totalRejected;
  final int totalSent;
 final int totalonHold;
  QuotationDashboardData({
    required this.totalRequest,
    required this.newRequests,
    required this.pendingRequest,
    required this.completedRequest,
    required this.totalQuotations,
    required this.totalApproved,
    required this.totalRejected,
    required this.totalSent,
      required this.totalonHold,
  });

  factory QuotationDashboardData.fromJson(Map<String, dynamic> json) {
    return QuotationDashboardData(
      totalRequest: _toInt(json['total_request']),
      newRequests: _toInt(json['new_requests']),
      pendingRequest: _toInt(json['pending_request']),
      completedRequest: _toInt(json['completed_request']),
      totalQuotations: _toInt(json['total_quotations']),
      totalApproved: _toInt(json['total_approved']),
      totalRejected: _toInt(json['total_rejected']),
      totalSent: _toInt(json['total_send']),
       totalonHold: _toInt(json['total_onhold']),
    );
  }

  /// Helper to safely convert string/int/null → int
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

