import 'dart:convert';

class StaffReportModel {
  bool status;
  String message;
  List<StaffReportModels> data;

  StaffReportModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StaffReportModel.fromRawJson(String str) =>
      StaffReportModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StaffReportModel.fromJson(Map<String, dynamic> json) =>
      StaffReportModel(
        status: json["status"],
        message: json["message"],
        data: List<StaffReportModels>.from(
            json["data"].map((x) => StaffReportModels.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class StaffReportModels {
  String userId;
  String staffName;
  String phoneNo;
  String email;
  String des;
  String branchName;
  String joiningDate;

  StaffReportModels({
    required this.userId,
    required this.staffName,
    required this.phoneNo,
    required this.email,
    required this.des,
    required this.branchName,
    required this.joiningDate,
  });

  factory StaffReportModels.fromRawJson(String str) =>
      StaffReportModels.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StaffReportModels.fromJson(Map<String, dynamic> json) => StaffReportModels(
        userId: json["user_id"] ?? "",
        staffName: json["staff_name"] ?? "",
        phoneNo: json["phone_no"] ?? "",
        email: json["email"] ?? "",
        des: json["des"] ?? "",
        branchName: json["branch_name"] ?? "",
        joiningDate: json["joining_date"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "staff_name": staffName,
        "phone_no": phoneNo,
        "email": email,
        "des": des,
        "branch_name": branchName,
        "joining_date": joiningDate,
      };
}
