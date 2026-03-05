class RentalReturnNumberModel {
  final bool status;
  final String message;
  final ReturnNumberData? data;

  RentalReturnNumberModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory RentalReturnNumberModel.fromJson(Map<String, dynamic> json) {
    return RentalReturnNumberModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? ReturnNumberData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }

  @override
  String toString() {
    return 'RentalReturnNumberModel(status: $status, message: $message, data: $data)';
  }
}

class ReturnNumberData {
  final String returnNo;

  ReturnNumberData({
    required this.returnNo,
  });

  factory ReturnNumberData.fromJson(Map<String, dynamic> json) {
    return ReturnNumberData(
      returnNo: json['return_no'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'return_no': returnNo,
    };
  }

  @override
  String toString() {
    return 'ReturnNumberData(returnNo: $returnNo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReturnNumberData && other.returnNo == returnNo;
  }

  @override
  int get hashCode => returnNo.hashCode;
}
