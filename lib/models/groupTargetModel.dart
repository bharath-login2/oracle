import 'dart:convert';

class GroupTargetModel {
    String message;
    List<Group> data;
    bool status;

    GroupTargetModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory GroupTargetModel.fromRawJson(String str) => GroupTargetModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory GroupTargetModel.fromJson(Map<String, dynamic> json) => GroupTargetModel(
        message: json["message"],
        data: List<Group>.from(json["data"].map((x) => Group.fromJson(x))),
        status: json["status"],
    );
    Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
    };
}
class Group {
    String id;
    String groupName;
    String staffs;
    String targetAmount;
    String effectiveDate;
      String isActive;

    Group({
        required this.id,
        required this.groupName,
        required this.staffs,
        required this.targetAmount,
        required this.effectiveDate,
         required this.isActive,
    });

    factory Group.fromRawJson(String str) => Group.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json["id"],
        groupName: json["group_name"],
        staffs: json["staffs"],
        targetAmount: json["target_amount"],
        effectiveDate: json["effective_date"],
          isActive: json["is_active"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "group_name": groupName,
        "staffs": staffs,
        "target_amount": targetAmount,
        "effective_date": effectiveDate,
         "is_active": isActive,
    };
}
