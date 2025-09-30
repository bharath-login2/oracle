import 'dart:convert';

class ActivityDetails {
    ActivityMode data;
    bool status;
    String message;

    ActivityDetails({
        required this.data,
        required this.status,
        required this.message,
    });

    factory ActivityDetails.fromRawJson(String str) => ActivityDetails.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ActivityDetails.fromJson(Map<String, dynamic> json) => ActivityDetails(
        data: ActivityMode.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
        "message": message,
    };
}

class ActivityMode {
    List<Activity> activities;

    ActivityMode({
        required this.activities,
    });

    factory ActivityMode.fromRawJson(String str) => ActivityMode.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ActivityMode.fromJson(Map<String, dynamic> json) => ActivityMode(
        activities: List<Activity>.from(json["activities"].map((x) => Activity.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "activities": List<dynamic>.from(activities.map((x) => x.toJson())),
    };
}

class Activity {
    String remark;
    String createdTime;
    String staffName;
    String proPicThumb;

    Activity({
        required this.remark,
        required this.createdTime,
        required this.staffName,
        required this.proPicThumb,
    });

    factory Activity.fromRawJson(String str) => Activity.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        remark: json["remark"]??"",
        createdTime: json["created_time"]??"",
        staffName: json["staff_name"]??"",
        proPicThumb: json["pro_pic_thumb"]??"",
    );

    Map<String, dynamic> toJson() => {
        "remark": remark,
        "created_time": createdTime,
        "staff_name": staffName,
        "pro_pic_thumb": proPicThumb,
    };
}
