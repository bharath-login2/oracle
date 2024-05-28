// To parse this JSON data, do
//
//     final bulkRemindModel = bulkRemindModelFromJson(jsonString);

import 'dart:convert';

BulkRemindModel bulkRemindModelFromJson(String str) => BulkRemindModel.fromJson(json.decode(str));

String bulkRemindModelToJson(BulkRemindModel data) => json.encode(data.toJson());

class BulkRemindModel {
    String message;
    bool data;
    bool status;

    BulkRemindModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory BulkRemindModel.fromJson(Map<String, dynamic> json) => BulkRemindModel(
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
