import 'dart:convert';
import 'package:intl/intl.dart';

CustomerwiseProjectModel customerwiseProjectModelFromJson(String str) =>
    CustomerwiseProjectModel.fromJson(json.decode(str));

String customerwiseProjectModelToJson(CustomerwiseProjectModel data) =>
    json.encode(data.toJson());

DateTime _parseDDMMYYYY(String? date) {
  if (date == null || date.isEmpty) {
    return DateTime(1970);
  }
  try {
    return DateFormat('dd-MM-yyyy').parse(date);
  } catch (_) {
    return DateTime(1970);
  }
}

String _formatDDMMYYYY(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}

class CustomerwiseProjectModel {
  final bool status;
  final String message;
  final CustomerProjectListData data;

  CustomerwiseProjectModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CustomerwiseProjectModel.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"];
    CustomerProjectListData parsedData;

    if (rawData is List) {
      parsedData = CustomerProjectListData(
        list: List<ProjectData>.from(
          rawData.map((x) => ProjectData.fromJson(x)),
        ),
      );
    } else if (rawData is Map<String, dynamic>) {
      parsedData = CustomerProjectListData.fromJson(rawData);
    } else {
      parsedData = CustomerProjectListData(list: []);
    }

    return CustomerwiseProjectModel(
      status: json["status"] == true,
      message: json["message"]?.toString() ?? "",
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class CustomerProjectListData {
  final List<ProjectData> list;
  // Permissions are usually included in the new structure
  final CustomerProjectPermissions? permissions;

  CustomerProjectListData({required this.list, this.permissions});

  factory CustomerProjectListData.fromJson(Map<String, dynamic> json) {
    return CustomerProjectListData(
      list: json["list"] != null && json["list"] is List
          ? List<ProjectData>.from(
              json["list"].map((x) => ProjectData.fromJson(x)),
            )
          : (json["data"] != null && json["data"] is List // Fallback for old structure if needed, but the user said it changed
              ? List<ProjectData>.from(
                  json["data"].map((x) => ProjectData.fromJson(x)),
                )
              : []),
      permissions: json["permissions"] != null ? CustomerProjectPermissions.fromJson(json["permissions"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "list": List<dynamic>.from(list.map((x) => x.toJson())),
        "permissions": permissions?.toJson(),
      };
}

class CustomerProjectPermissions {
  final bool addProject;
  final bool addWorkModule;

  CustomerProjectPermissions({required this.addProject, required this.addWorkModule});

  factory CustomerProjectPermissions.fromJson(Map<String, dynamic> json) {
    return CustomerProjectPermissions(
      addProject: json['add_project'] == "true",
      addWorkModule: json['add_work_module'] == "true",
    );
  }

  Map<String, dynamic> toJson() => {
    "add_project": addProject.toString(),
    "add_work_module": addWorkModule.toString(),
  };
}

class ProjectData {
  final String id;
  final String custId;
  final String projectName;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final String companyId;
  final String isDeleted;
  final DateTime updatedAt;
  final String staffName;

  ProjectData({
    required this.id,
    required this.custId,
    required this.projectName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.companyId,
    required this.isDeleted,
    required this.updatedAt,
    required this.staffName,
  });

  factory ProjectData.fromJson(Map<String, dynamic> json) {
    return ProjectData(
      id: json["id"]?.toString() ?? "",
      custId: json["cust_id"]?.toString() ?? "",
      projectName: json["project_name"]?.toString() ?? "",
      startDate: _parseDDMMYYYY(json["start_date"]),
      endDate: _parseDDMMYYYY(json["end_date"]),
      status: json["status"]?.toString() ?? "",
      createdBy: json["created_by"]?.toString() ?? "",
      updatedBy: json["updated_by"]?.toString() ?? "",
      createdAt: _parseDDMMYYYY(json["created_at"]),
      companyId: json["company_id"]?.toString() ?? "",
      isDeleted: json["is_deleted"]?.toString() ?? "",
      updatedAt: _parseDDMMYYYY(json["updated_at"]),
      staffName: json["staff_name"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "cust_id": custId,
        "project_name": projectName,
        "start_date": _formatDDMMYYYY(startDate),
        "end_date": _formatDDMMYYYY(endDate),
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "created_at": _formatDDMMYYYY(createdAt),
        "company_id": companyId,
        "is_deleted": isDeleted,
        "updated_at": _formatDDMMYYYY(updatedAt),
        "staff_name": staffName,
      };
}
