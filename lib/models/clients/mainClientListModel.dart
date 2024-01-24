class MainClientListModel {
  bool? status;
  String? message;
  List<Data>? data;

  MainClientListModel({this.status, this.message, this.data});

  MainClientListModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? clientName;
  String? phoneNumber;
  String? location;
  String? pincode;
  String? postOffice;
  String? createdBy;
  String? createdAt;
  String? totalDue;
  String? totalInvoiceCount;

  Data(
      {this.id,
        this.clientName,
        this.phoneNumber,
        this.location,
        this.pincode,
        this.postOffice,
        this.createdBy,
        this.createdAt,
        this.totalDue,
        this.totalInvoiceCount});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientName = json['clientName'];
    phoneNumber = json['phoneNumber'];
    location = json['location'];
    pincode = json['pincode'];
    postOffice = json['post_office'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    totalDue = json['total_due'];
    totalInvoiceCount = json['total_invoice_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['clientName'] = clientName;
    data['phoneNumber'] = phoneNumber;
    data['location'] = location;
    data['pincode'] = pincode;
    data['post_office'] = postOffice;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    data['total_due'] = totalDue;
    data['total_invoice_count'] = totalInvoiceCount;
    return data;
  }
}