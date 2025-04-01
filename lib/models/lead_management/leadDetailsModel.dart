class LeadDeatailsModel {
  Data? data;
  bool? status;
  String? message;

  LeadDeatailsModel({this.data, this.status, this.message});

  LeadDeatailsModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }
}

class Data {
  String? callMasterId;
  String? leadCategoryId;
  String? leadSubCategoryId;
  String? clientName;
  String? address;
  String? cost;
  String? assignedUserId;
  String? callResultId;
  String? calledDate;
  String? createdDate;
  String? nextFollowupDate;
  String? remarks;
  String? leadMethod;
  String? leadCategory;
  String? leadSubCategory;
  String? callResult;
  String? staffName;
  String? priorityId;
  String? priority;
  String? countryCode;
  String? contactNumber1;
  String? branchId;
  bool? callHistoryPermission;
  bool? fileManagerPermission;
  List<LeadCategories>? leadCategories;
  List<Calleddata>? calleddata;
  bool? callPermission;
  String? warningMessage;
  String? callLeadId;
  String? leadSource;
  String? leadSourceId;

  Data(
      {this.callMasterId,
      this.leadCategoryId,
      this.leadSubCategoryId,
      this.clientName,
      this.address,
      this.cost,
      this.assignedUserId,
      this.callResultId,
      this.calledDate,
      this.createdDate,
      this.nextFollowupDate,
      this.remarks,
      this.leadMethod,
      this.leadCategory,
      this.leadSubCategory,
      this.callResult,
      this.staffName,
      this.priorityId,
      this.priority,
      this.countryCode,
      this.contactNumber1,
      this.branchId,
      this.callHistoryPermission,
      this.fileManagerPermission,
      this.leadCategories,
      this.callPermission,
      this.warningMessage,
      this.callLeadId,
      this.leadSource,
      this.leadSourceId});

  Data.fromJson(Map<String, dynamic> json) {
    callMasterId = json['call_master_id'] ?? "";
    leadCategoryId = json['lead_category_id'] ?? "";
    leadSubCategoryId = json['lead_sub_category_id'] ?? "";
    clientName = json['client_name'] ?? "";
    address = json['address'] ?? "";
    cost = json['cost'] ?? "";
    assignedUserId = json['assigned_user_id'] ?? "";
    callResultId = json['call_result_id'] ?? "";
    calledDate = json['called_date'] ?? "";
    createdDate = json['created_date'] ?? "";
    nextFollowupDate = json['next_followup_date'] ?? "";
    remarks = json['remarks'] ?? "";
    leadMethod = json['lead_method'] ?? "";
    leadCategory = json['lead_category'] ?? "";
    leadSubCategory = json['lead_sub_category'] ?? "";
    callResult = json['call_result'] ?? "";
    staffName = json['staff_name'] ?? "";
    priorityId = json['priority_id'] ?? "";
    priority = json['priority'] ?? "";
    countryCode = json['country_code'] ?? "";
    contactNumber1 = json['contact_number1'] ?? "";
    branchId = json['branch_id'] ?? "";
    callHistoryPermission = json['callHistoryPermission'];
    fileManagerPermission = json['fileManagerPermission'];
    if (json['leadCategories'] != null) {
      leadCategories = <LeadCategories>[];
      json['leadCategories'].forEach((v) {
        leadCategories!.add(LeadCategories.fromJson(v));
      });
    }
      if (json['calleddata'] != null) {
      calleddata = <Calleddata>[];
      json['calleddata'].forEach((v) {
        calleddata!.add(Calleddata.fromJson(v));
      });
    }

    callPermission = json['callPermission'];
    warningMessage = json['warningMessage'] ?? "";
    callLeadId = json['callLeadId'] ?? "";
    leadSource = json['lead_source'] ?? "";
    leadSourceId = json['lead_source-id'] ?? "";
  }
}

class LeadCategories {
  String? callMasterId;
  String? leadCategoryId;
  String? leadCategory;
  String? leadSubCategory;
  bool? isSelected;

  LeadCategories(
      {this.callMasterId,
      this.leadCategoryId,
      this.leadCategory,
      this.leadSubCategory,
      this.isSelected});

  LeadCategories.fromJson(Map<String, dynamic> json) {
    callMasterId = json['call_master_id'];
    leadCategoryId = json['lead_category_id'];
    leadCategory = json['lead_category'];
    leadSubCategory = json['lead_sub_category'];
    isSelected = json['is_selected'];
  }
}


class Calleddata {
  String? name;
  String? phoneNum;
  String? callType;
  String? durationTime;
 String? simName;
  String? dateTime;
   String? formatteddateTime;
   String? companyName;
   String? proPic;
    String? formattedDuration;


  Calleddata(
      {this.name,
      this.phoneNum,
      this.callType,
      this.durationTime,
      this.simName,
       this.dateTime,
       this.formatteddateTime,
       this.companyName,
       this.proPic,
       this.formattedDuration});
       

  Calleddata.fromJson(Map<String, dynamic> json) {
    name = json['name']??"";
    phoneNum = json['phone_number']??"";
    callType = json['callType']??"";
    durationTime = json['duration']??"";
    simName = json['SimName']??"";
     dateTime = json['date_time']??"";
        formatteddateTime = json['formatted_date_time']??"";
       companyName = json['company_name']??"";
        proPic = json['pro_pic'] ??"";
         formattedDuration = json['formatted_duration'] ??"";
  }
}
