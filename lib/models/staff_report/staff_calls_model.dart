import 'dart:convert';

StaffCallDuration staffCallDurationFromJson(String str) => 
    StaffCallDuration.fromJson(json.decode(str));

String staffCallDurationToJson(StaffCallDuration data) => 
    json.encode(data.toJson());

class StaffCallDuration {
  final Data data;
  final String message;
  final bool status;

  StaffCallDuration({
    required this.data,
    required this.message,
    required this.status,
  });

  factory StaffCallDuration.fromJson(Map<String, dynamic> json) => StaffCallDuration(
        data: Data.fromJson(json["data"]),
        message: json["message"] ?? "",
        status: json["status"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "message": message,
        "status": status,
      };
}
class Data {
  final List<Call> calls;
  final Summary summary;

  Data({
    required this.calls,
    required this.summary,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    calls: (json["calls"] is List)
        ? List<Call>.from(json["calls"].map((x) => Call.fromJson(x)))
        : [], 
    summary: Summary.fromJson(json["summary"] ?? {}),
  );


  Map<String, dynamic> toJson() => {
        "calls": List<dynamic>.from(calls.map((x) => x.toJson())),
        "summary": summary.toJson(),
      };
}

class Call {
  final String id;
  final String name;
  final String phone;
  final String callType;
  final String duration;
  final String calledDate;
  final String calledTime;
  final String idealTime;

  Call({
    required this.id,
    required this.name,
    required this.phone,
    required this.callType,
    required this.duration,
    required this.calledDate,
    required this.calledTime,
    required this.idealTime,
  });

  factory Call.fromJson(Map<String, dynamic> json) => Call(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        phone: json["phone"]?.toString() ?? "",
        callType: json["callType"]?.toString() ?? "",
        duration: json["duration"]?.toString() ?? "0",
        calledDate: json["called_date"]?.toString() ?? "",
        calledTime: json["called_time"]?.toString() ?? "",
        idealTime: json["ideal_time"]?.toString() ?? "0s",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "callType": callType,
        "duration": duration,
        "called_date": calledDate,
        "called_time": calledTime,
        "ideal_time": idealTime,
      };
}

class Summary {
  final String startTime;
  final String endTime;
  final int totalCalls;
  final String totalIncomingDuration;
  final String totalOutgoingDuration;
  final String totalIdealTime;

  Summary({
    required this.startTime,
    required this.endTime,
    required this.totalCalls,
    required this.totalIncomingDuration,
    required this.totalOutgoingDuration,
    required this.totalIdealTime,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        startTime: json["start_time"]?.toString() ?? "",
        endTime: json["end_time"]?.toString() ?? "",
        totalCalls: json["total_calls"] as int? ?? 0,
        totalIncomingDuration: json["total_incoming_duration"]?.toString() ?? "00:00:00",
        totalOutgoingDuration: json["total_outgoing_duration"]?.toString() ?? "00:00:00",
        totalIdealTime: json["total_ideal_time"]?.toString() ?? "0s",
      );

  Map<String, dynamic> toJson() => {
        "start_time": startTime,
        "end_time": endTime,
        "total_calls": totalCalls,
        "total_incoming_duration": totalIncomingDuration,
        "total_outgoing_duration": totalOutgoingDuration,
        "total_ideal_time": totalIdealTime,
      };
}