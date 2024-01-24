class LeadDashboardModel {
  Data? data;
  bool? status;
  String? message;

  LeadDashboardModel({this.data, this.status, this.message});

  LeadDashboardModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  int? newLeads;
  int? followupLeads;
  int? closedLeads;
  int? totalCalled;
  int? missedLeads;
  int? transferLeads;
  String? totalStaffLeads;
  int? unreadNotification;

  Data(
      {this.newLeads,
      this.followupLeads,
      this.closedLeads,
      this.totalCalled,
      this.missedLeads,
      this.transferLeads,
      this.totalStaffLeads,
      this.unreadNotification});

  Data.fromJson(Map<String, dynamic> json) {
    newLeads = json['newLeads'];
    followupLeads = json['followupLeads'];
    closedLeads = json['closedLeads'];
    totalCalled = json['totalCalled'];
    missedLeads = json['missedLeads'];
    transferLeads = json['transferLeads'];
    totalStaffLeads = json['total_staff_leads'];
    unreadNotification = json['unread_notification'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['newLeads'] = newLeads;
    data['followupLeads'] = followupLeads;
    data['closedLeads'] = closedLeads;
    data['totalCalled'] = totalCalled;
    data['missedLeads'] = missedLeads;
    data['transferLeads'] = transferLeads;
    data['total_staff_leads'] = totalStaffLeads;
    data['unread_notification'] = unreadNotification;
    return data;
  }
}
