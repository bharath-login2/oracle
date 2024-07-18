// To parse this JSON data, do
//
//     final templateContentModel = templateContentModelFromJson(jsonString);

import 'dart:convert';

TemplateContentModel templateContentModelFromJson(String str) =>
    TemplateContentModel.fromJson(json.decode(str));

class TemplateContentModel {
  bool message;
  bool status;
  Data data;

  TemplateContentModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory TemplateContentModel.fromJson(Map<String, dynamic> json) =>
      TemplateContentModel(
        message: json["message"],
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );
}

class Data {
  String format;
  String header;
  String language;
  String footer;
  List<Button> buttons;
  String messageBody;
  int paramCount;

  Data({
    required this.format,
    required this.header,
    required this.language,
    required this.footer,
    required this.buttons,
    required this.messageBody,
    required this.paramCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        format: json["format"],
        header: json["header"],
        language: json["language"],
        footer: json["footer"],
        buttons:
            List<Button>.from(json["buttons"].map((x) => Button.fromJson(x))),
        messageBody: json["messageBody"],
        paramCount: json["paramCount"],
      );
}

class Button {
  String type;
  String text;
  String btnUrl;

  Button({
    required this.type,
    required this.text,
    required this.btnUrl,
  });

  factory Button.fromJson(Map<String, dynamic> json) => Button(
        type: json["type"],
        text: json["text"],
        btnUrl: json["btn_url"],
      );
}
