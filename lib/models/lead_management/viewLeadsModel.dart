class ViewLeadsModel {
  Data? data;
  bool? status;
  String? message;

  ViewLeadsModel({this.data, this.status, this.message});

  ViewLeadsModel.fromJson(Map<String, dynamic> json) {
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
  String? fromdate;
  String? todate;
  bool? callPermission;
  String? warningMessage;
  String? callLeadId;

  Data(
      {this.details,
        this.totalLeads,
        this.fromdate,
        this.todate,
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
    fromdate = json['fromdate'];
    todate = json['todate'];
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
    data['fromdate'] = this.fromdate;
    data['todate'] = this.todate;
    data['callPermission'] = this.callPermission;
    data['warningMessage'] = this.warningMessage;
    data['callLeadId'] = this.callLeadId;
    return data;
  }
}

class Details {
  String? callDetailsId;
  String? callMasterId;
  String? calledDate;
  String? createdDate;
  String? lastCalledDate;
  int? callResultId;
  String? callStatusId;
  bool? isNewCall;
  String? followupDate;
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
  bool? isSelected;

  Details(
      {this.callDetailsId,
        this.callMasterId,
        this.calledDate,
        this.createdDate,
        this.lastCalledDate,
        this.callResultId,
        this.callStatusId,
        this.isNewCall,
        this.followupDate,
        this.scheduledDate,
        this.clientName,
        this.contactNumber1,
        this.callResult,
        this.proPicThumb,
        this.staffName,
        this.leadCategory,
        this.priority,
        this.profilePic,
        this.isCalled,
        this.isSelected});

  Details.fromJson(Map<String, dynamic> json) {
    callDetailsId = json['call_details_id'];
    callMasterId = json['call_master_id'];
    calledDate = json['called_date'];
    createdDate = json['created_date'];
    lastCalledDate = json['last_called_date'];
    callResultId = json['call_result_id'];
    callStatusId = json['call_status_id'];
    isNewCall = json['is_new_call'];
    followupDate = json['followup_date'];
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
    isSelected = json['is_selected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['call_details_id'] = this.callDetailsId;
    data['call_master_id'] = this.callMasterId;
    data['called_date'] = this.calledDate;
    data['created_date'] = this.createdDate;
    data['last_called_date'] = this.lastCalledDate;
    data['call_result_id'] = this.callResultId;
    data['call_status_id'] = this.callStatusId;
    data['is_new_call'] = this.isNewCall;
    data['followup_date'] = this.followupDate;
    data['scheduled_date'] = this.scheduledDate;
    data['client_name'] = this.clientName;
    data['contact_number1'] = this.contactNumber1;
    data['call_result'] = this.callResult;
    data['pro_pic_thumb'] = this.proPicThumb;
    data['staff_name'] = this.staffName;
    data['lead_category'] = this.leadCategory;
    data['priority'] = this.priority;
    data['profile_pic'] = this.profilePic;
    data['is_called'] = this.isCalled;
    data['is_selected'] = this.isSelected;
    return data;
  }
}