import 'dart:convert';

class UpdatePendingData {
    bool data;
    bool status;
    String message;

    UpdatePendingData({
        required this.data,
        required this.status,
        required this.message,
    });

    factory UpdatePendingData.fromRawJson(String str) => UpdatePendingData.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory UpdatePendingData.fromJson(Map<String, dynamic> json) => UpdatePendingData(
        data: json["data"],
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": data,
        "status": status,
        "message": message,
    };
}
