import 'dart:convert';
TitleList titleListFromJson(String str) => TitleList.fromJson(json.decode(str));
String titleListToJson(TitleList data) => json.encode(data.toJson());
class TitleList {
  final List<TitleListDet> data;
  final bool status;
  final String message;

  TitleList({
    required this.data,
    required this.status,
    required this.message,
  });

  factory TitleList.fromJson(Map<String, dynamic> json) => TitleList(
        data: List<TitleListDet>.from(
            json["data"].map((x) => TitleListDet.fromJson(x))),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
        "message": message,
      };
}

/// Item model
class TitleListDet {
  final String id;
  final String name;

  TitleListDet({
    required this.id,
    required this.name,
  });

  factory TitleListDet.fromJson(Map<String, dynamic> json) => TitleListDet(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
