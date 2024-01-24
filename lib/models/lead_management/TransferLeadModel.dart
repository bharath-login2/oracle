class TransferLeadModel {
  Data? data;
  bool? status;
  String? message;

  TransferLeadModel({this.data, this.status, this.message});

  TransferLeadModel.fromJson(Map<String, dynamic> json) {
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
  String? transferDate;
  String? callMasterId;
  String? clientName;
  String? contactNumber1;
  String? lastCalledDate;
  String? fromStaff;
  String? toStaff;
  String? callResult;
  String? leadCategory;
  String? leadSubCategory;
  String? callResultId;
  String? leadMethod;

  Details(
      {this.transferDate,
        this.callMasterId,
        this.clientName,
        this.contactNumber1,
        this.lastCalledDate,
        this.fromStaff,
        this.toStaff,
        this.callResult,
        this.leadCategory,
        this.leadSubCategory,
        this.callResultId,
        this.leadMethod});

  Details.fromJson(Map<String, dynamic> json) {
    transferDate = json['transfer_date'];
    callMasterId = json['call_master_id'];
    clientName = json['client_name'];
    contactNumber1 = json['contact_number1'];
    lastCalledDate = json['last_called_date'];
    fromStaff = json['from_staff'];
    toStaff = json['to_staff'];
    callResult = json['call_result'];
    leadCategory = json['lead_category'];
    leadSubCategory = json['lead_sub_category'];
    callResultId = json['call_result_id'];
    leadMethod = json['lead_method'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transfer_date'] = this.transferDate;
    data['call_master_id'] = this.callMasterId;
    data['client_name'] = this.clientName;
    data['contact_number1'] = this.contactNumber1;
    data['last_called_date'] = this.lastCalledDate;
    data['from_staff'] = this.fromStaff;
    data['to_staff'] = this.toStaff;
    data['call_result'] = this.callResult;
    data['lead_category'] = this.leadCategory;
    data['lead_sub_category'] = this.leadSubCategory;
    data['call_result_id'] = this.callResultId;
    data['lead_method'] = this.leadMethod;
    return data;
  }
}