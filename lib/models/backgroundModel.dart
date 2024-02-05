class BackgroundModel {
  bool? status;
  Data? data;
  String? message;

  BackgroundModel({this.status, this.data, this.message});

  BackgroundModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  String? clientName;
  String? callMasterId;
  String? leadCategory;
  String? createdDate;
  String? status;
  String? lastCalledDate;
  String? remark;

  Data(
      {this.clientName,
        this.callMasterId,
        this.leadCategory,
        this.createdDate,
        this.status,
        this.lastCalledDate,
        this.remark});

  Data.fromJson(Map<String, dynamic> json) {
    clientName = json['client_name'];
    callMasterId = json['call_master_id'];
    leadCategory = json['lead_category'];
    createdDate = json['created_date'];
    status = json['status'];
    lastCalledDate = json['last_called_date'];
    remark = json['Remark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['client_name'] = this.clientName;
    data['call_master_id'] = this.callMasterId;
    data['lead_category'] = this.leadCategory;
    data['created_date'] = this.createdDate;
    data['status'] = this.status;
    data['last_called_date'] = this.lastCalledDate;
    data['Remark'] = this.remark;
    return data;
  }
}