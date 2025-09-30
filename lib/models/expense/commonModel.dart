
import 'dart:convert';

CommonDataResponse expensePostModelFromJson(String str) => CommonDataResponse.fromJson(json.decode(str));

String expensePostDataToJson(CommonDataResponse data) => json.encode(data.toJson());

class CommonDataResponse {
  bool status;
  String message;
  bool data;

  CommonDataResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CommonDataResponse.fromJson(Map<String, dynamic> json) => CommonDataResponse(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: json["data"].toString().toLowerCase() == "true"
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data,
      };
}
