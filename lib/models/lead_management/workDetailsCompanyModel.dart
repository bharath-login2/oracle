// To parse this JSON data, do
//
//     final workCompanyDetailsModel = workCompanyDetailsModelFromJson(jsonString);

import 'dart:convert';

WorkCompanyDetailsModel workCompanyDetailsModelFromJson(String str) => WorkCompanyDetailsModel.fromJson(json.decode(str));

String workCompanyDetailsModelToJson(WorkCompanyDetailsModel data) => json.encode(data.toJson());

class WorkCompanyDetailsModel {
    final List<WorkCompany> data;
    final bool status;
    final String message;

    WorkCompanyDetailsModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory WorkCompanyDetailsModel.fromJson(Map<String, dynamic> json) => WorkCompanyDetailsModel(
        data: List<WorkCompany>.from(json["data"].map((x) => WorkCompany.fromJson(x))),
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
    final String firstStartTime;
    final String lastEndTime;

    WorkCompany({
        required this.staffId,
        required this.name,
        required this.firstStartTime,
        required this.lastEndTime,
    });

    factory WorkCompany.fromJson(Map<String, dynamic> json) => WorkCompany(
        staffId: json["staff_id"],
        name: json["name"],
        firstStartTime: json["first_start_time"],
        lastEndTime: json["last_end_time"],
    );

    Map<String, dynamic> toJson() => {
        "staff_id": staffId,
        "name": name,
        "first_start_time": firstStartTime,
        "last_end_time": lastEndTime,
    };
}
