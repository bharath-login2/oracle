class PushNotificationModel {
  final bool? status;
  final List<NotificationData>? data;
  final String? message;

  PushNotificationModel({
    this.status,
    this.data,
    this.message,
  });

  factory PushNotificationModel.fromJson(Map<String, dynamic> json) {
    return PushNotificationModel(
      status: json['status'],
      data: json['data'] != null
          ? List<NotificationData>.from(
              json['data'].map((x) => NotificationData.fromJson(x)))
          : [],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data != null
          ? List<dynamic>.from(data!.map((x) => x.toJson()))
          : [],
      'message': message,
    };
  }
}

class NotificationData {
  final String? notifictionId;
  final String? title;
  final String? message;
  final String? detailId;
  final String? sentDateTime;
  final String? assignedByCompany;
  final String? timeAgo;

  NotificationData({
    this.notifictionId,
    this.title,
    this.message,
    this.detailId,
    this.sentDateTime,
    this.assignedByCompany,
    this.timeAgo,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      notifictionId: json['notifiction_id'],
      title: json['title'],
      message: json['message'],
      detailId: json['detail_id'],
      sentDateTime: json['sent_date_time'],
      assignedByCompany: json['assigned_by_company'],
      timeAgo: json['time_ago'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifiction_id': notifictionId,
      'title': title,
      'message': message,
      'detail_id': detailId,
      'sent_date_time': sentDateTime,
      'assigned_by_company': assignedByCompany,
      'time_ago': timeAgo,
    };
  }
}
