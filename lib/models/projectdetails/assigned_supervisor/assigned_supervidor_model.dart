class AssignedStaffResponse {
  final bool status;
  final String message;
  final List<AssignedStaff> data;

  AssignedStaffResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AssignedStaffResponse.fromJson(Map<String, dynamic> json) {
    return AssignedStaffResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => AssignedStaff.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class AssignedStaff {
  final String id;
  final String staffName;
  final String designation;
  final String proPic;

  AssignedStaff({
    required this.id,
    required this.staffName,
    required this.designation,
    required this.proPic,
  });

  factory AssignedStaff.fromJson(Map<String, dynamic> json) {
    return AssignedStaff(
      id: json['id']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      proPic: json['pro_pic']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'staff_name': staffName,
        'designation': designation,
        'pro_pic': proPic,
      };
}
