// To parse this JSON data, do
//
//     final UpdateComplaintModel = UpdateComplaintModelFromJson(jsonString);

import 'dart:convert';

UpdateComplaintModel updateComplaintModelFromJson(String str) => UpdateComplaintModel.fromJson(json.decode(str));

String updateComplaintModelToJson(UpdateComplaintModel data) => json.encode(data.toJson());

class UpdateComplaintModel {
    String message;
    bool data;
    bool status;

    UpdateComplaintModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory UpdateComplaintModel.fromJson(Map<String, dynamic> json) => UpdateComplaintModel(
        message: json["message"],
        data: json["data"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data,
        "status": status,
    };
}
