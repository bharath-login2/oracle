import 'dart:convert';

class StateModel {
    bool status;
    String message;
    List<StateList> data;

    StateModel({
        required this.status,
        required this.message,
        required this.data,
    });

    factory StateModel.fromRawJson(String str) => StateModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
        status: json["status"],
        message: json["message"],
        data: List<StateList>.from(json["data"].map((x) => StateList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class StateList {
    String id;
    String name;

    StateList({
        required this.id,
        required this.name,
    });

    factory StateList.fromRawJson(String str) => StateList.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory StateList.fromJson(Map<String, dynamic> json) => StateList(
        id: json["id"]??"",
        name: json["name"]??"",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
