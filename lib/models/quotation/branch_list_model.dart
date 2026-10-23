class BranchResponse {
  final List<Branch> data;
  final String message;
  final bool status;

  BranchResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory BranchResponse.fromJson(Map<String, dynamic> json) {
    return BranchResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Branch.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'] ?? '',
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((branch) => branch.toJson()).toList(),
      'message': message,
      'status': status,
    };
  }
}

class Branch {
  final String branchId;
  final String branchName;

  Branch({
    required this.branchId,
    required this.branchName,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      branchId: json['branch_id']?.toString() ?? '',
      branchName: json['branch_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_id': branchId,
      'branch_name': branchName,
    };
  }
}
