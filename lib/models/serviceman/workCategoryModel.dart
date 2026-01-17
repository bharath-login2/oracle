import 'package:meta/meta.dart';
import 'dart:convert';

class WorkCategory {
    String status;
    List<Datum> data;

    WorkCategory({
        required this.status,
        required this.data,
    });

    factory WorkCategory.fromRawJson(String str) => WorkCategory.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory WorkCategory.fromJson(Map<String, dynamic> json) => WorkCategory(
        status: json["status"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String workCategoryId;
    String workCategory;

    Datum({
        required this.workCategoryId,
        required this.workCategory,
    });

    factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        workCategoryId: json["workCategory_id"],
        workCategory: json["work_category"],
    );

    Map<String, dynamic> toJson() => {
        "workCategory_id": workCategoryId,
        "work_category": workCategory,
    };
}
