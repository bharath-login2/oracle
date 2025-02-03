class TransferLeadModel {
  Data? data;
  bool? status;
  String? message;

  TransferLeadModel({this.data, this.status, this.message});

  TransferLeadModel.fromJson(Map<String, dynamic> json) {
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
        details!.add(Details.fromJson(v));
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
    final Map<String, dynamic> data = <String, dynamic>{};
    if (details != null) {
      data['details'] = details!.map((v) => v.toJson()).toList();
    }
    data['totalLeads'] = totalLeads;
    data['fromdate'] = fromdate;
    data['todate'] = todate;
    data['callPermission'] = callPermission;
    data['warningMessage'] = warningMessage;
    data['callLeadId'] = callLeadId;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transfer_date'] = transferDate;
    data['call_master_id'] = callMasterId;
    data['client_name'] = clientName;
    data['contact_number1'] = contactNumber1;
    data['last_called_date'] = lastCalledDate;
    data['from_staff'] = fromStaff;
    data['to_staff'] = toStaff;
    data['call_result'] = callResult;
    data['lead_category'] = leadCategory;
    data['lead_sub_category'] = leadSubCategory;
    data['call_result_id'] = callResultId;
    data['lead_method'] = leadMethod;
    return data;
  }
}