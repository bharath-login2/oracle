class SearchModel {
  Data? data;
  bool? status;
  String? message;

  SearchModel({this.data, this.status, this.message});

  SearchModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  List<Details>? details;
  int? totalLeads;
  bool? callPermission;
  String? warningMessage;
  String? callLeadId;

  Data(
      {this.details,
        this.totalLeads,
        this.callPermission,
        this.warningMessage,
        this.callLeadId});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['details'] != null) {
      details = <Details>[];
      json['details'].forEach((v) {
        details!.add(new Details.fromJson(v));
      });
    }
    totalLeads = json['totalLeads'];
    callPermission = json['callPermission'];
    warningMessage = json['warningMessage'];
    callLeadId = json['callLeadId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.details != null) {
      data['details'] = this.details!.map((v) => v.toJson()).toList();
    }
    data['totalLeads'] = this.totalLeads;
    data['callPermission'] = this.callPermission;
    data['warningMessage'] = this.warningMessage;
    data['callLeadId'] = this.callLeadId;
    return data;
  }
}

class Details {
  String? callMasterId;
  String? calledDate;
  int? callResultId;
  String? callStatusId;
  String? scheduledDate;
  String? clientName;
  String? contactNumber1;
  String? callResult;
  String? proPicThumb;
  String? staffName;
  String? leadCategory;
  String? priority;
  String? profilePic;
  bool? isCalled;

  Details(
      {this.callMasterId,
        this.calledDate,
        this.callResultId,
        this.callStatusId,
        this.scheduledDate,
        this.clientName,
        this.contactNumber1,
        this.callResult,
        this.proPicThumb,
        this.staffName,
        this.leadCategory,
        this.priority,
        this.profilePic,
        this.isCalled});

  Details.fromJson(Map<String, dynamic> json) {
    callMasterId = json['call_master_id'];
    calledDate = json['called_date'];
    callResultId = json['call_result_id'];
    callStatusId = json['call_status_id'];
    scheduledDate = json['scheduled_date'];
    clientName = json['client_name'];
    contactNumber1 = json['contact_number1'];
    callResult = json['call_result'];
    proPicThumb = json['pro_pic_thumb'];
    staffName = json['staff_name'];
    leadCategory = json['lead_category'];
    priority = json['priority'];
    profilePic = json['profile_pic'];
    isCalled = json['is_called'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['call_master_id'] = this.callMasterId;
    data['called_date'] = this.calledDate;
    data['call_result_id'] = this.callResultId;
    data['call_status_id'] = this.callStatusId;
    data['scheduled_date'] = this.scheduledDate;
    data['client_name'] = this.clientName;
    data['contact_number1'] = this.contactNumber1;
    data['call_result'] = this.callResult;
    data['pro_pic_thumb'] = proPicThumb;
    data['staff_name'] = staffName;
    data['lead_category'] = leadCategory;
    data['priority'] = priority;
    data['profile_pic'] = profilePic;
    data['is_called'] = isCalled;
    return data;
  }
}