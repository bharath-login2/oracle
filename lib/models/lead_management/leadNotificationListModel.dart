class LeadNotificationListModel {
  bool? status;
  bool? message;
  List<Data>? data;

  LeadNotificationListModel({this.status, this.message, this.data});

  LeadNotificationListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? notificationId;
  String? title;
  String? content;
  String? leadMasterId;
  String? dateTime;
  bool? isRead;

  Data(
      {this.notificationId,
        this.title,
        this.content,
        this.leadMasterId,
        this.dateTime,
        this.isRead});

  Data.fromJson(Map<String, dynamic> json) {
    notificationId = json['notification_id'];
    title = json['title'];
    content = json['content'];
    leadMasterId = json['lead_master_id'];
    dateTime = json['date_time'];
    isRead = json['is_read'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['notification_id'] = notificationId;
    data['title'] = title;
    data['content'] = content;
    data['lead_master_id'] = leadMasterId;
    data['date_time'] = dateTime;
    data['is_read'] = isRead;
    return data;
  }
}