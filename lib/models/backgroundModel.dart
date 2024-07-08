// To parse this JSON data, do
//
//     final backgroundModel = backgroundModelFromJson(jsonString);

import 'dart:convert';

BackgroundModel backgroundModelFromJson(String str) =>
    BackgroundModel.fromJson(json.decode(str));

class BackgroundModel {
  bool status;
  Data data;
  String message;

  BackgroundModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory BackgroundModel.fromJson(Map<String, dynamic> json) =>
      BackgroundModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
        message: json["message"],
      );
}

class Data {
  String clientName;
  String callMasterId;
  String leadCategory;
  String createdDate;
  String status;
  String lastCalledDate;
  String remark;

  Data({
    required this.clientName,
    required this.callMasterId,
    required this.leadCategory,
    required this.createdDate,
    required this.status,
    required this.lastCalledDate,
    required this.remark,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        clientName: json["clientName"],
        callMasterId: json["callMasterId"],
        leadCategory: json["leadCategory"],
        createdDate: json["createdDate"],
        status: json["status"],
        lastCalledDate: json["lastCalledDate"],
        remark: json["remark"],
      );
}
