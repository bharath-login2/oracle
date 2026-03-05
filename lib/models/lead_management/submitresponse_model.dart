// To parse this JSON data, do
//
//     final submitResponse = submitResponseFromJson(jsonString);

import 'dart:convert';

SubmitResponse submitResponseFromJson(String str) =>
    SubmitResponse.fromJson(json.decode(str));

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

  factory SubmitResponse.fromJson(Map<String, dynamic> json) {
    var rawStatus = json["status"];
    bool finalStatus = false;
    if (rawStatus is bool) {
      finalStatus = rawStatus;
    } else if (rawStatus is String) {
      finalStatus = (rawStatus.toLowerCase() == "success" ||
          rawStatus.toLowerCase() == "true" ||
          rawStatus == "1");
    } else if (rawStatus is int) {
      finalStatus = (rawStatus == 1);
    }

    return SubmitResponse(
      message: json["message"]?.toString() ?? "",
      data: json["data"],
      status: finalStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data,
        "status": status,
      };
}
