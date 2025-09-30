import 'dart:convert';

class DistrictModel {
    bool status;
    String message;
    List<DistrictList> data;

    DistrictModel({
        required this.status,
        required this.message,
        required this.data,
    });

    factory DistrictModel.fromRawJson(String str) => DistrictModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory DistrictModel.fromJson(Map<String, dynamic> json) => DistrictModel(
        status: json["status"],
        message: json["message"],
        data: List<DistrictList>.from(json["data"].map((x) => DistrictList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class DistrictList {
    String id;
    String name;

    DistrictList({
        required this.id,
        required this.name,
    });

    factory DistrictList.fromRawJson(String str) => DistrictList.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory DistrictList.fromJson(Map<String, dynamic> json) => DistrictList(
        id: json["id"]??"",
        name: json["name"]??"",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
