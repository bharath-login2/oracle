import 'dart:convert';

DailyDataModel dailyDataModelFromJson(String str) =>
    DailyDataModel.fromJson(json.decode(str));

String dailyDataModelToJson(DailyDataModel data) =>
    json.encode(data.toJson());

class DailyDataModel {
  bool status;
  String message;
  List<DailyItem> data;

  DailyDataModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DailyDataModel.fromJson(Map<String, dynamic> json) =>
      DailyDataModel(
        status: json["status"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null
            ? List<DailyItem>.from(
                json["data"].map((x) => DailyItem.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DailyItem {
  String date;
  int presentCount;
    int halfDayCount;
  int absentCount;

  DailyItem({
    required this.date,
    required this.presentCount,
     required this.halfDayCount,
    required this.absentCount,
  });

  factory DailyItem.fromJson(Map<String, dynamic> json) => DailyItem(
        date: json["date"] ?? '',
        presentCount:
            int.tryParse(json["present_count"].toString()) ?? 0,
            halfDayCount:
            int.tryParse(json["halfday_count"].toString()) ?? 0,
        absentCount:
            int.tryParse(json["leave_count"].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "present_count": presentCount,
         "halfday_count": halfDayCount,
        "leave_count": absentCount,
      };
}
