class ProjectDetailsResponse {
  final bool status;
  final String message;
  final ProjectData data;

  ProjectDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProjectDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProjectDetailsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ProjectData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ProjectData {
  final CustomerInfo getCustomerList;
  final String totalProjectHours;
  final List<StaffInfo> projectHandledStaffs;
  final List<StaffWorkInfo> staffWorkList;

  ProjectData({
    required this.getCustomerList,
    required this.totalProjectHours,
    required this.projectHandledStaffs,
    required this.staffWorkList,
  });

  factory ProjectData.fromJson(Map<String, dynamic> json) {
    return ProjectData(
      getCustomerList: CustomerInfo.fromJson(json['get_customer_list'] ?? {}),
      totalProjectHours: json['total_project_hours'] ?? '',
      projectHandledStaffs: (json['project_handled_staffs'] as List?)
          ?.map((e) => StaffInfo.fromJson(e))
          .toList() ?? [],
      staffWorkList: (json['staff_work_list'] as List?)
          ?.map((e) => StaffWorkInfo.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'get_customer_list': getCustomerList.toJson(),
      'total_project_hours': totalProjectHours,
      'project_handled_staffs': projectHandledStaffs.map((e) => e.toJson()).toList(),
      'staff_work_list': staffWorkList.map((e) => e.toJson()).toList(),
    };
  }
}

class CustomerInfo {
  final String id;
  final String projectName;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String name;
  final String contactNo;
  final String address;

  CustomerInfo({
    required this.id,
    required this.projectName,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.name,
    required this.contactNo,
    required this.address,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id']?.toString() ?? '',
      projectName: json['project_name'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      createdAt: json['created_at'] ?? '',
      name: json['name'] ?? '',
      contactNo: json['contact_no'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_name': projectName,
      'start_date': startDate,
      'end_date': endDate,
      'created_at': createdAt,
      'name': name,
      'contact_no': contactNo,
      'address': address,
    };
  }
}

class StaffInfo {
  final String userId;
  final String staffName;
  final String proPicThumb;
  final String totalHours;

  StaffInfo({
    required this.userId,
    required this.staffName,
    required this.proPicThumb,
    required this.totalHours,
  });

  factory StaffInfo.fromJson(Map<String, dynamic> json) {
    return StaffInfo(
      userId: json['user_id']?.toString() ?? '',
      staffName: json['staff_name'] ?? '',
      proPicThumb: json['pro_pic_thumb'] ?? '',
      totalHours: json['total_hours'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'staff_name': staffName,
      'pro_pic_thumb': proPicThumb,
      'total_hours': totalHours,
    };
  }
}

class StaffWorkInfo {
  final String userId;
  final String staffName;
  final String totalWorkTime;

  StaffWorkInfo({
    required this.userId,
    required this.staffName,
    required this.totalWorkTime,
  });

  factory StaffWorkInfo.fromJson(Map<String, dynamic> json) {
    return StaffWorkInfo(
      userId: json['user_id']?.toString() ?? '',
      staffName: json['staff_name'] ?? '',
      totalWorkTime: json['total_work_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'staff_name': staffName,
      'total_work_time': totalWorkTime,
    };
  }
}