// To parse this JSON data, do
//
//     final staffCallDuration = staffCallDurationFromJson(jsonString);
import 'dart:convert';

StaffCallDuration staffCallDurationFromJson(String str) => StaffCallDuration.fromJson(json.decode(str));

String staffCallDurationToJson(StaffCallDuration data) => json.encode(data.toJson());

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
        message: json["message"],
        status: json["status"],
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
        calls: List<Call>.from(json["calls"].map((x) => Call.fromJson(x))),
        summary: Summary.fromJson(json["summary"]),
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
        id: json["id"]??"",
        name: json["name"]??"",
         phone: json["phone"]??"",
        callType: json["callType"]??"",
        duration: json["duration"]??"",
        calledDate: json["called_date"]??"",
        calledTime: json["called_time"]??"",
        idealTime: json["ideal_time"]??"",
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
    final int totalIncomingDuration;
    final int totalOutgoingDuration;
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
        startTime: json["start_time"]??"",
        endTime: json["end_time"]??"",
        totalCalls: json["total_calls"]??"",
        totalIncomingDuration: json["total_incoming_duration"]??"",
        totalOutgoingDuration: json["total_outgoing_duration"]??"",
        totalIdealTime: json["total_ideal_time"]??"",
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
