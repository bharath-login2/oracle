class CallStatusReportOntapModel {
  final Data? data;
  final bool? status;
  final String? message;

  CallStatusReportOntapModel({
    this.data,
    this.status,
    this.message,
  });

  factory CallStatusReportOntapModel.fromJson(Map<String, dynamic> json) {
    return CallStatusReportOntapModel(
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
  final List<StaffDetail>? details;
  final String? totalCount;

  Data({
    this.details,
    this.totalCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      details: json['details'] != null
          ? List<StaffDetail>.from(
              json['details'].map((x) => StaffDetail.fromJson(x)))
          : null,
      totalCount: json['total_count']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details?.map((x) => x.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}

class StaffDetail {
  final String? userId;
  final String? staffName;
  final String? total;

  StaffDetail({
    this.userId,
    this.staffName,
    this.total,
  });

  factory StaffDetail.fromJson(Map<String, dynamic> json) {
    return StaffDetail(
      userId: json['user_id']?.toString(),
      staffName: json['staff_name']?.toString(),
      total: json['total']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'staff_name': staffName,
      'total': total,
    };
  }
}
