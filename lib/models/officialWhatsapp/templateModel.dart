// To parse this JSON data, do
//
//     final templateModel = templateModelFromJson(jsonString);

import 'dart:convert';

TemplateModel templateModelFromJson(String str) => TemplateModel.fromJson(json.decode(str));

String templateModelToJson(TemplateModel data) => json.encode(data.toJson());

class TemplateModel {
  bool message;
  bool status;
  List<Datum> data;

  TemplateModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) => TemplateModel(
    message: json["message"],
    status: json["status"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String id;
  String name;

  Datum({
    required this.id,
    required this.name,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
