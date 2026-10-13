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

  factory SubmitResponse.fromJson(dynamic json) {
    Map<String, dynamic> map = {};
    if (json is String) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is Map) {
          map = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    } else if (json is Map) {
      map = Map<String, dynamic>.from(json);
    }

    var rawStatus = map["status"];
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
      message: map["message"]?.toString() ?? "",
      data: map["data"],
      status: finalStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data,
        "status": status,
      };
}
