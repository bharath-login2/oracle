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

  factory ProjectCountModel.fromRawJson(String str) =>
      ProjectCountModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProjectCountModel.fromJson(Map<String, dynamic> json) =>
      ProjectCountModel(
        status: json["status"],
        message: json["message"],
        data:
            List<ProCount>.from(json["data"].map((x) => ProCount.fromJson(x))),
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
  List<StaffWiseCount> staffWiseCounts;

  ProCount({
    required this.id,
    required this.label,
    required this.count,
    required this.staffWiseCounts,
  });

  factory ProCount.fromRawJson(String str) =>
      ProCount.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProCount.fromJson(Map<String, dynamic> json) => ProCount(
        id: json["id"],
        label: json["label"],
        count: json["count"],
        staffWiseCounts: json["staff_wise_counts"] != null
            ? List<StaffWiseCount>.from(json["staff_wise_counts"]
                .map((x) => StaffWiseCount.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "label": label,
        "count": count,
        "staff_wise_counts":
            List<dynamic>.from(staffWiseCounts.map((x) => x.toJson())),
      };
}

class StaffWiseCount {
  String staffId;
  String staffName;
  int count;

  StaffWiseCount({
    required this.staffId,
    required this.staffName,
    required this.count,
  });

  factory StaffWiseCount.fromRawJson(String str) =>
      StaffWiseCount.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StaffWiseCount.fromJson(Map<String, dynamic> json) => StaffWiseCount(
        staffId: json["staff_id"],
        staffName: json["staff_name"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "staff_id": staffId,
        "staff_name": staffName,
        "count": count,
      };
}
