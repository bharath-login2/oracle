import 'dart:convert';

class ProjectCountModel {
    bool status;
    String message;
    List<ProCount> data;

    ProjectCountModel({
        required this.status,
        required this.message,
        required this.data,
    });

    factory ProjectCountModel.fromRawJson(String str) => ProjectCountModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ProjectCountModel.fromJson(Map<String, dynamic> json) => ProjectCountModel(
        status: json["status"],
        message: json["message"],
        data: List<ProCount>.from(json["data"].map((x) => ProCount.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class ProCount {
    int id;
    String label;
    int count;

    ProCount({
        required this.id,
        required this.label,
        required this.count,
    });

    factory ProCount.fromRawJson(String str) => ProCount.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ProCount.fromJson(Map<String, dynamic> json) => ProCount(
        id: json["id"],
        label: json["label"],
        count: json["count"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "label": label,
        "count": count,
    };
}
