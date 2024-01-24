class PushNotificationModel {
  String? title;
  String? message;
  String? type;
  int? notificationId;
  int? detailId;
  int? detailParentId;
  bool? editLead;
  bool? deleteLead;
  bool? cloudcall;
  PushNotificationModel({this.title,this.message,this.type,this.detailId,this.detailParentId,this.notificationId,this.editLead,this.deleteLead,this.cloudcall});
  PushNotificationModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    message = json['message'];
    type = json['type'];
    notificationId = json['notificationId'];
    detailId = json['detailId'];
    detailParentId = json['detailParentId'];
    editLead = json['editLead'];
    editLead = json['deleteLead'];
    cloudcall = json['cloudcall'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    data['message'] = message;
    data['type'] = type;
    data['notificationId'] = notificationId;
    data['detailId'] = detailId;
    data['detailParentId'] = detailParentId;
    data['editLead'] = editLead;
    data['deleteLead'] = deleteLead;
    data['cloudcall'] = cloudcall;
    return data;
  }
}




