// rentalCollectedByStaffList.dart

class RentalCollectedByStaffList {
  final bool status;
  final String message;
  final List<Staff> data;

  RentalCollectedByStaffList({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RentalCollectedByStaffList.fromJson(Map<String, dynamic> json) {
    return RentalCollectedByStaffList(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Staff.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((staff) => staff.toJson()).toList(),
    };
  }
}

class Staff {
  final String id;
  final String customerStaff;

  Staff({
    required this.id,
    required this.customerStaff,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id']?.toString() ?? '',
      customerStaff: json['customer_staff'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_staff': customerStaff,
    };
  }
}
