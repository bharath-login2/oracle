// To parse this JSON data, do
//
//     final customerLogModel = customerLogModelFromJson(jsonString);

import 'dart:convert';

CustomerLogModel customerLogModelFromJson(String str) => CustomerLogModel.fromJson(json.decode(str));

String customerLogModelToJson(CustomerLogModel data) => json.encode(data.toJson());

class CustomerLogModel {
    Data data;
    bool status;
    String message;

    CustomerLogModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory CustomerLogModel.fromJson(Map<String, dynamic> json) => CustomerLogModel(
        data: Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
        "message": message,
    };
}

class Data {
    String customerName;
    String contactNo;
    List<ActivityLog> activityLog;

    Data({
        required this.customerName,
        required this.contactNo,
        required this.activityLog,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        customerName: json["customer_name"],
        contactNo: json["contact_no"],
        activityLog: List<ActivityLog>.from(json["activity_log"].map((x) => ActivityLog.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "customer_name": customerName,
        "contact_no": contactNo,
        "activity_log": List<dynamic>.from(activityLog.map((x) => x.toJson())),
    };
}

class ActivityLog {
    String logData;
    String createdAt;
    String staffName;
    String proPicThumb;
    String profilePic;

    ActivityLog({
        required this.logData,
        required this.createdAt,
        required this.staffName,
        required this.proPicThumb,
        required this.profilePic,
    });

    factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
        logData: json["log_data"],
        createdAt: json["created_at"],
        staffName: json["staff_name"],
        proPicThumb: json["pro_pic_thumb"],
        profilePic: json["profile_pic"],
    );

    Map<String, dynamic> toJson() => {
        "log_data": logData,
        "created_at": createdAt,
        "staff_name": staffName,
        "pro_pic_thumb": proPicThumb,
        "profile_pic": profilePic,
    };
}
