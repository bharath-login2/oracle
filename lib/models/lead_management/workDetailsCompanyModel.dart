import 'dart:convert';

WorkCompanyDetailsModel workCompanyDetailsModelFromJson(String str) =>
    WorkCompanyDetailsModel.fromJson(json.decode(str));

String workCompanyDetailsModelToJson(WorkCompanyDetailsModel data) =>
    json.encode(data.toJson());

class WorkCompanyDetailsModel {
  final List<WorkCompany> data;
  final bool status;
  final String message;

  WorkCompanyDetailsModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory WorkCompanyDetailsModel.fromJson(Map<String, dynamic> json) =>
      WorkCompanyDetailsModel(
        data: List<WorkCompany>.from(
            json["data"].map((x) => WorkCompany.fromJson(x))),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
        "message": message,
      };
}

class WorkCompany {
  final String staffId;
  final String name;
  final String taskName;
  final String firstLoginTime;
  final String lastLogoutTime;
  final String status;
  final String multiple;

  WorkCompany({
    required this.staffId,
    required this.name,
    required this.taskName,
    required this.firstLoginTime,
    required this.lastLogoutTime,
    required this.status,
    required this.multiple,
  });

  factory WorkCompany.fromJson(Map<String, dynamic> json) => WorkCompany(
        staffId: json["staff_id"] ?? "",
        name: json["name"] ?? "",
        taskName: json["task_name"] ?? "",
        firstLoginTime: json["first_login_time"] ?? "",
        lastLogoutTime: json["last_logout_time"] ?? "",
        status: json["status"] ?? "",
        multiple: json["multiple"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "staff_id": staffId,
        "name": name,
        "task_name": taskName,
        "first_login_time": firstLoginTime,
        "last_logout_time": lastLogoutTime,
        "status": status,
        "multiple": multiple,
      };
}
