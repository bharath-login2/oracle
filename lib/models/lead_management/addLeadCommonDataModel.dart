class AddLeadCommonDataModel {
  Data? data;
  bool? status;
  String? message;

  AddLeadCommonDataModel({this.data, this.status, this.message});

  AddLeadCommonDataModel.fromJson(Map<String, dynamic> json) {
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
  List<LeadCategory>? leadCategory;
  List<CallResult>? callResult;
  List<CallResultNew>? callResultNew;
  List<Branch>? branch;
  List<Staff>? staff;
  List<TransferStaffs>? transferStaffs;
  List<Priority>? priority;
  List<CallResponseStatus>? callResponseStatus;
  List<String>? callResponse;
  List<AdditionalFields>? additionalFields;
  String? countryCode;
  bool? customerAddPermission;
  bool? customerAddInvoicePermission;

  Data(
      {this.leadCategory,
        this.callResult,
        this.callResultNew,
        this.branch,
        this.staff,
        this.transferStaffs,
        this.priority,
        this.callResponseStatus,
        this.callResponse,
        this.additionalFields,
        this.countryCode,
        this.customerAddPermission,
        this.customerAddInvoicePermission});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['lead_category'] != null) {
      leadCategory = <LeadCategory>[];
      json['lead_category'].forEach((v) {
        leadCategory!.add(LeadCategory.fromJson(v));
      });
    }
    if (json['call_result'] != null) {
      callResult = <CallResult>[];
      json['call_result'].forEach((v) {
        callResult!.add(CallResult.fromJson(v));
      });
    }
    if (json['call_result_new'] != null) {
      callResultNew = <CallResultNew>[];
      json['call_result_new'].forEach((v) {
        callResultNew!.add(CallResultNew.fromJson(v));
      });
    }
    if (json['branch'] != null) {
      branch = <Branch>[];
      json['branch'].forEach((v) {
        branch!.add(Branch.fromJson(v));
      });
    }
    if (json['staff'] != null) {
      staff = <Staff>[];
      json['staff'].forEach((v) {
        staff!.add(Staff.fromJson(v));
      });
    }
    if (json['transfer_staffs'] != null) {
      transferStaffs = <TransferStaffs>[];
      json['transfer_staffs'].forEach((v) {
        transferStaffs!.add(TransferStaffs.fromJson(v));
      });
    }
    if (json['priority'] != null) {
      priority = <Priority>[];
      json['priority'].forEach((v) {
        priority!.add(Priority.fromJson(v));
      });
    }
    if (json['call_response_status'] != null) {
      callResponseStatus = <CallResponseStatus>[];
      json['call_response_status'].forEach((v) {
        callResponseStatus!.add(CallResponseStatus.fromJson(v));
      });
    }
    callResponse = json['call_response'].cast<String>();
    if (json['additionalFields'] != null) {
      additionalFields = <AdditionalFields>[];
      json['additionalFields'].forEach((v) {
        additionalFields!.add(AdditionalFields.fromJson(v));
      });
    }
    countryCode = json['country_code'];
    customerAddPermission = json['customerAddPermission'];
    customerAddInvoicePermission = json['customerAddInvoicePermission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (leadCategory != null) {
      data['lead_category'] =
          leadCategory!.map((v) => v.toJson()).toList();
    }
    if (callResult != null) {
      data['call_result'] = callResult!.map((v) => v.toJson()).toList();
    }
    if (callResultNew != null) {
      data['call_result_new'] =
          callResultNew!.map((v) => v.toJson()).toList();
    }
    if (branch != null) {
      data['branch'] = branch!.map((v) => v.toJson()).toList();
    }
    if (staff != null) {
      data['staff'] = staff!.map((v) => v.toJson()).toList();
    }
    if (transferStaffs != null) {
      data['transfer_staffs'] =
          transferStaffs!.map((v) => v.toJson()).toList();
    }
    if (priority != null) {
      data['priority'] = priority!.map((v) => v.toJson()).toList();
    }
    if (callResponseStatus != null) {
      data['call_response_status'] =
          callResponseStatus!.map((v) => v.toJson()).toList();
    }
    data['call_response'] = callResponse;
    if (additionalFields != null) {
      data['additionalFields'] =
          additionalFields!.map((v) => v.toJson()).toList();
    }
    data['country_code'] = countryCode;
    data['customerAddPermission'] = customerAddPermission;
    data['customerAddInvoicePermission'] = customerAddInvoicePermission;
    return data;
  }
}

class LeadCategory {
  String? leadCategoryId;
  String? leadCategory;

  LeadCategory({this.leadCategoryId, this.leadCategory});

  LeadCategory.fromJson(Map<String, dynamic> json) {
    leadCategoryId = json['lead_category_id'];
    leadCategory = json['lead_category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lead_category_id'] = leadCategoryId;
    data['lead_category'] = leadCategory;
    return data;
  }
}

class CallResult {
  String? callResultId;
  String? callResult;

  CallResult({this.callResultId, this.callResult});

  CallResult.fromJson(Map<String, dynamic> json) {
    callResultId = json['call_result_id'];
    callResult = json['call_result'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['call_result_id'] = callResultId;
    data['call_result'] = callResult;
    return data;
  }
}

class CallResultNew {
  String? callResultIdNew;
  String? callResultNew;

  CallResultNew({this.callResultIdNew, this.callResultNew});

  CallResultNew.fromJson(Map<String, dynamic> json) {
    callResultIdNew = json['call_result_id_new'];
    callResultNew = json['call_result_new'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['call_result_id_new'] = callResultIdNew;
    data['call_result_new'] = callResultNew;
    return data;
  }
}

class Branch {
  String? branchId;
  String? branchName;

  Branch({this.branchId, this.branchName});

  Branch.fromJson(Map<String, dynamic> json) {
    branchId = json['branch_id'];
    branchName = json['branch_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['branch_id'] = branchId;
    data['branch_name'] = branchName;
    return data;
  }
}

class Staff {
  String? staffId;
  String? staffName;

  Staff({this.staffId, this.staffName});

  Staff.fromJson(Map<String, dynamic> json) {
    staffId = json['staff_id'];
    staffName = json['staff_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['staff_id'] = staffId;
    data['staff_name'] = staffName;
    return data;
  }
}

class TransferStaffs {
  String? tranStaffId;
  String? tranStaffName;

  TransferStaffs({this.tranStaffId, this.tranStaffName});

  TransferStaffs.fromJson(Map<String, dynamic> json) {
    tranStaffId = json['tran_staff_id'];
    tranStaffName = json['tran_staff_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tran_staff_id'] = tranStaffId;
    data['tran_staff_name'] = tranStaffName;
    return data;
  }
}

class Priority {
  String? priorityId;
  String? priority;

  Priority({this.priorityId, this.priority});

  Priority.fromJson(Map<String, dynamic> json) {
    priorityId = json['priority_id'];
    priority = json['priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['priority_id'] = priorityId;
    data['priority'] = priority;
    return data;
  }
}

class CallResponseStatus {
  String? callResponseId;
  String? callResponse;

  CallResponseStatus({this.callResponseId, this.callResponse});

  CallResponseStatus.fromJson(Map<String, dynamic> json) {
    callResponseId = json['call_response_id'];
    callResponse = json['call_response'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['call_response_id'] = callResponseId;
    data['call_response'] = callResponse;
    return data;
  }
}

class AdditionalFields {
  String? id;
  String? fieldName;

  AdditionalFields({this.id, this.fieldName});

  AdditionalFields.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fieldName = json['field_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['field_name'] = fieldName;
    return data;
  }
}