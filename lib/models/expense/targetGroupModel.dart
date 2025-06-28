// To parse this JSON data, do
//
import 'dart:convert';

TargetGroupModel targetGroupModelFromJson(String str) => TargetGroupModel.fromJson(json.decode(str));

String targetGroupModelToJson(TargetGroupModel data) => json.encode(data.toJson());

class TargetGroupModel {
    bool status;
    String message;
    List<TargetGroupAll> data;

    TargetGroupModel({
        required this.status,
        required this.message,
        required this.data,
    });

    factory TargetGroupModel.fromJson(Map<String, dynamic> json) => TargetGroupModel(
        status: json["status"],
        message: json["message"],
        data: List<TargetGroupAll>.from(json["data"].map((x) => TargetGroupAll.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class TargetGroupAll {
    String id;
    String groupName;
    String isGroup;
    String targetAmount;
    String staffName;
    String totalAchieved;
    String taxInclude;

    TargetGroupAll({
        required this.id,
        required this.groupName,
        required this.isGroup,
        required this.targetAmount,
        required this.staffName,
        required this.totalAchieved,
        required this.taxInclude,
    });

    factory TargetGroupAll.fromJson(Map<String, dynamic> json) => TargetGroupAll(
        id: json["id"]??"",
        groupName: json["group_name"]??"",
        isGroup: json["is_group"]??"",
        targetAmount: json["target_amount"]??"",
        staffName: json["staff_name"]??"",
        totalAchieved: json["total_achieved"]??"",
        taxInclude: json["tax_include"]??"",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "group_name": groupName,
        "is_group": isGroup,
        "target_amount": targetAmount,
        "staff_name": staffName,
        "total_achieved": totalAchieved,
        "tax_include": taxInclude,
    };
}
