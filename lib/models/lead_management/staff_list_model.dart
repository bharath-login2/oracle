class StaffListResponse {
  final List<StaffListData> data;
  final bool status;
  final String message;

  StaffListResponse({
    required this.data,
    required this.status,
    required this.message,
  });

  factory StaffListResponse.fromJson(Map<String, dynamic> json) {
    return StaffListResponse(
      data: (json['data'] as List? ?? [])
          .map((e) => StaffListData.fromJson(e))
          .toList(),
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class StaffListData {
  final String userId;
  final String staffName;
  final String role;
  final String? branchName;

  StaffListData({
    required this.userId,
    required this.staffName,
    required this.role,
    this.branchName,
  });

  factory StaffListData.fromJson(Map<String, dynamic> json) {
    return StaffListData(
      userId: json['user_id']?.toString() ?? '',
      staffName: json['staff_name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      branchName: json['branch_name']?.toString(),
    );
  }
}
