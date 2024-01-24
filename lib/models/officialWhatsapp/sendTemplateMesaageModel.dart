// To parse this JSON data, do
//
//     final sendTemplateMesaageModel = sendTemplateMesaageModelFromJson(jsonString);

import 'dart:convert';

SendTemplateMesaageModel sendTemplateMesaageModelFromJson(String str) => SendTemplateMesaageModel.fromJson(json.decode(str));

String sendTemplateMesaageModelToJson(SendTemplateMesaageModel data) => json.encode(data.toJson());

class SendTemplateMesaageModel {
  String message;
  bool status;
  bool data;

  SendTemplateMesaageModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory SendTemplateMesaageModel.fromJson(Map<String, dynamic> json) => SendTemplateMesaageModel(
    message: json["message"],
    status: json["status"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "data": data,
  };
}
