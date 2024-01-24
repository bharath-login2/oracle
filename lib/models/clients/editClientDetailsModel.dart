class EditClientDetailsModel {
  Data? data;
  bool? status;
  String? message;

  EditClientDetailsModel({this.data, this.status, this.message});

  EditClientDetailsModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? name;
  String? countryCode;
  String? contactNo;
  String? address1;
  String? address2;
  String? address3;
  String? pincode;
  String? gstNum;
  String? remarks;
  String? postOffice;
  String? branchId;
  List<AdditionalFields>? additionalFields;

  Data(
      {this.id,
        this.name,
        this.countryCode,
        this.contactNo,
        this.address1,
        this.address2,
        this.address3,
        this.pincode,
        this.gstNum,
        this.remarks,
        this.postOffice,
        this.branchId,
        this.additionalFields});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    countryCode = json['country_code'];
    contactNo = json['contact_no'];
    address1 = json['address1'];
    address2 = json['address2'];
    address3 = json['address3'];
    pincode = json['pincode'];
    gstNum = json['gst_num'];
    remarks = json['remarks'];
    postOffice = json['post_office'];
    branchId = json['branch_id'];
    if (json['additional_fields'] != null) {
      additionalFields = <AdditionalFields>[];
      json['additional_fields'].forEach((v) {
        additionalFields!.add(AdditionalFields.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['country_code'] = countryCode;
    data['contact_no'] = contactNo;
    data['address1'] = address1;
    data['address2'] = address2;
    data['address3'] = address3;
    data['pincode'] = pincode;
    data['gst_num'] = gstNum;
    data['remarks'] = remarks;
    data['post_office'] = postOffice;
    data['branch_id'] = branchId;
    if (additionalFields != null) {
      data['additional_fields'] =
          additionalFields!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AdditionalFields {
  String? fieldId;
  String? fieldName;
  String? fieldValue;

  AdditionalFields({this.fieldId, this.fieldName, this.fieldValue});

  AdditionalFields.fromJson(Map<String, dynamic> json) {
    fieldId = json['field_id'];
    fieldName = json['field_name'];
    fieldValue = json['field_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['field_id'] = fieldId;
    data['field_name'] = fieldName;
    data['field_value'] = fieldValue;
    return data;
  }
}