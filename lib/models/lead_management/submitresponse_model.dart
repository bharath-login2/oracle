// To parse this JSON data, do
//
//     final submitResponse = submitResponseFromJson(jsonString);

import 'dart:convert';

SubmitResponse submitResponseFromJson(String str) => SubmitResponse.fromJson(json.decode(str));

String submitResponseToJson(SubmitResponse data) => json.encode(data.toJson());

class SubmitResponse {
  String message;
  dynamic data;
  bool status;

  SubmitResponse({
    required this.message,
    required this.data,
    required this.status,
  });

  factory SubmitResponse.fromJson(Map<String, dynamic> json) => SubmitResponse(
        message: json["message"] ?? "",
        data: json["data"],
        status: json["status"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data,
        "status": status,
      };
}

