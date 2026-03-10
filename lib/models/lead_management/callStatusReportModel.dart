class CallStatusReportModel {
  final Data? data;
  final bool? status;
  final String? message;

  CallStatusReportModel({
    this.data,
    this.status,
    this.message,
  });

  factory CallStatusReportModel.fromJson(Map<String, dynamic> json) {
    return CallStatusReportModel(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      status: json['status'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'status': status,
      'message': message,
    };
  }
}

class Data {
  final List<Detail>? details;
  final String? totalCount;

  Data({
    this.details,
    this.totalCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      details: json['details'] != null
          ? List<Detail>.from(json['details'].map((x) => Detail.fromJson(x)))
          : null,
      totalCount: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details?.map((x) => x.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}

class Detail {
  final String? callResponseId;
  final String? callResponse;
  final String? total;

  Detail({
    this.callResponseId,
    this.callResponse,
    this.total,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      callResponseId: json['call_response_id'],
      callResponse: json['call_response'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'call_response_id': callResponseId,
      'call_response': callResponse,
      'total': total,
    };
  }
}
