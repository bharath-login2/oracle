// To parse this JSON data, do
//
//     final sendMesaageModel = sendMesaageModelFromJson(jsonString);

import 'dart:convert';

SendMesaageModel sendMesaageModelFromJson(String str) => SendMesaageModel.fromJson(json.decode(str));

String sendMesaageModelToJson(SendMesaageModel data) => json.encode(data.toJson());

class SendMesaageModel {
  String message;
  bool status;
  bool data;

  SendMesaageModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory SendMesaageModel.fromJson(Map<String, dynamic> json) => SendMesaageModel(
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
