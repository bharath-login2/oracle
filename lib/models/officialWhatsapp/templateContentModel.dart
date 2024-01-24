// To parse this JSON data, do
//
//     final templateContentModel = templateContentModelFromJson(jsonString);

import 'dart:convert';

TemplateContentModel templateContentModelFromJson(String str) => TemplateContentModel.fromJson(json.decode(str));

String templateContentModelToJson(TemplateContentModel data) => json.encode(data.toJson());

class TemplateContentModel {
  bool message;
  bool status;
  Data data;

  TemplateContentModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory TemplateContentModel.fromJson(Map<String, dynamic> json) => TemplateContentModel(
    message: json["message"],
    status: json["status"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "data": data.toJson(),
  };
}

class Data {
  String format;
  String header;
  String language;
  String footer;
  List<Button> buttons;
  String messageBody;

  Data({
    required this.format,
    required this.header,
    required this.language,
    required this.footer,
    required this.buttons,
    required this.messageBody,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    format: json["format"],
    header: json["header"],
    language: json["language"],
    footer: json["footer"],
    buttons: List<Button>.from(json["buttons"].map((x) => Button.fromJson(x))),
    messageBody: json["messageBody"],
  );

  Map<String, dynamic> toJson() => {
    "format": format,
    "header": header,
    "language": language,
    "footer": footer,
    "buttons": List<dynamic>.from(buttons.map((x) => x.toJson())),
    "messageBody": messageBody,
  };
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

  Map<String, dynamic> toJson() => {
    "type": type,
    "text": text,
    "btn_url": btnUrl,
  };
}
