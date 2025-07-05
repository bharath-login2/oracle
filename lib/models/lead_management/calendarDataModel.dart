import 'dart:convert';

CalendarDataAllModel calendarDataAllModelFromJson(String str) =>
    CalendarDataAllModel.fromJson(json.decode(str));

String calendarDataAllModelToJson(CalendarDataAllModel data) =>
    json.encode(data.toJson());

class CalendarDataAllModel {
  final bool status;
  final String message;
  final Data data;

  CalendarDataAllModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CalendarDataAllModel.fromJson(Map<String, dynamic> json) =>
      CalendarDataAllModel(
        status: json["status"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null
            ? Data.fromJson(json["data"])
            : Data(holiday: [], attendance: [], leave: []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  final List<Holiday> holiday;
  final List<Attendance> attendance;
  final List<Attendance> leave;

  Data({
    required this.holiday,
    required this.attendance,
    required this.leave,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        holiday: (json["holiday"] as List<dynamic>?)
                ?.map((x) => Holiday.fromJson(x))
                .toList() ??
            [],
        attendance: (json["attendance"] as List<dynamic>?)
                ?.map((x) => Attendance.fromJson(x))
                .toList() ??
            [],
        leave: (json["leave"] as List<dynamic>?)
                ?.map((x) => Attendance.fromJson(x))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        "holiday": holiday.map((x) => x.toJson()).toList(),
        "attendance": attendance.map((x) => x.toJson()).toList(),
        "leave": leave.map((x) => x.toJson()).toList(),
      };
}

class Attendance {
  final String date;

  Attendance({
    required this.date,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
        date: json["date"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "date": date,
      };
}

class Holiday {
  final String date;
  final String holidayName;

  Holiday({
    required this.date,
    required this.holidayName,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) => Holiday(
        date: json["date"] ?? '',
        holidayName: json["holiday_name"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "holiday_name": holidayName,
      };
}
