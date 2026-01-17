import 'dart:convert';

class CurrentStatus {
    bool status;
    bool isStarted;
    String message;

    CurrentStatus({
        required this.status,
        required this.isStarted,
        required this.message,
    });

    factory CurrentStatus.fromRawJson(String str) => CurrentStatus.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CurrentStatus.fromJson(Map<String, dynamic> json) => CurrentStatus(
        status: json["status"]??"",
        isStarted: json["is_started"]??"",
        message: json["message"]??"",
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "is_started": isStarted,
        "message": message,
    };
}
