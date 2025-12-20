import 'dart:convert';

class QuotationTemplateModel {
  final String status;
  final String message;
  final List<TemplateData> data;

  QuotationTemplateModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory QuotationTemplateModel.fromRawJson(String str) =>
      QuotationTemplateModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory QuotationTemplateModel.fromJson(Map<String, dynamic> json) =>
      QuotationTemplateModel(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: json["data"] == null
            ? []
            : List<TemplateData>.from(
                json["data"].map((x) => TemplateData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class TemplateData {
  final String id;
  final String templateName;

  TemplateData({
    required this.id,
    required this.templateName,
  });

  factory TemplateData.fromRawJson(String str) =>
      TemplateData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TemplateData.fromJson(Map<String, dynamic> json) => TemplateData(
        id: json["id"].toString(),
        templateName: json["template_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "template_name": templateName,
      };
}
