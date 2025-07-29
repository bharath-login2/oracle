import 'dart:convert';

class GetWorkMessageModel {
    String message;
    List<Message> data;
    bool status;

    GetWorkMessageModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory GetWorkMessageModel.fromRawJson(String str) => GetWorkMessageModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory GetWorkMessageModel.fromJson(Map<String, dynamic> json) => GetWorkMessageModel(
        message: json["message"],
        data: List<Message>.from(json["data"].map((x) => Message.fromJson(x))),
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
    };
}

class Message {
    String assignedWorkId;
    String userId;
     String sendBy;
    String message;
    String isRead;
    DateTime createdAt;
    String added;

    Message({
        required this.assignedWorkId,
        required this.userId,
          required this.sendBy,
        required this.message,
        required this.isRead,
        required this.createdAt,
        required this.added,
    });

    factory Message.fromRawJson(String str) => Message.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        assignedWorkId: json["assigned_work_id"],
        userId: json["user_id"],
           sendBy: json["staff_name"],
        message: json["message"],
        isRead: json["is_read"],
        createdAt: DateTime.parse(json["created_at"]),
        added: json["added"],
    );

    Map<String, dynamic> toJson() => {
        "assigned_work_id": assignedWorkId,
        "user_id": userId,
           "staff_name": sendBy,
        "message": message,
        "is_read": isRead,
        "created_at": createdAt.toIso8601String(),
        "added": added,
    };
}
