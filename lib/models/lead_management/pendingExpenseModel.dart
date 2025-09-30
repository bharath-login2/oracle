import 'dart:convert';

class PendingResponse {
    bool data;
    bool status;
    String message;

    PendingResponse({
        required this.data,
        required this.status,
        required this.message,
    });

    factory PendingResponse.fromRawJson(String str) => PendingResponse.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory PendingResponse.fromJson(Map<String, dynamic> json) => PendingResponse(
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
