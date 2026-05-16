import 'dart:convert';

ContentIdModel contentIdModelFromJson(String str) =>
    ContentIdModel.fromJson(json.decode(str));

String contentIdModelToJson(ContentIdModel data) => json.encode(data.toJson());

class ContentIdModel {
  String message;
  String data;
  bool status;

  ContentIdModel({
    required this.message,
    required this.data,
    required this.status,
  });

  factory ContentIdModel.fromJson(Map<String, dynamic> json) => ContentIdModel(
        message: json["message"] ?? "",
        data: json["data"] ?? "",
        status: json["status"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data,
        "status": status,
      };
}
