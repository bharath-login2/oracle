// To parse this JSON data, do
//
//     final editClientDetailsModel = editClientDetailsModelFromJson(jsonString);

import 'dart:convert';

EditClientDetailsModel editClientDetailsModelFromJson(String str) => EditClientDetailsModel.fromJson(json.decode(str));

String editClientDetailsModelToJson(EditClientDetailsModel data) => json.encode(data.toJson());

class EditClientDetailsModel {
    Data data;
    bool status;
    String message;

    EditClientDetailsModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory EditClientDetailsModel.fromJson(Map<String, dynamic> json) => EditClientDetailsModel(
        data: Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
        "message": message,
    };
}

class Data {
    String id;
    String name;
    String emailId;
    String countryCode;
    String contactNo;
    String address1;
    String address2;
    String address3;
    String pincode;
    String gstNum;
    String remarks;
    String postOffice;
    String branchId;
    List<AdditionalField> additionalFields;

    Data({
        required this.id,
        required this.name,
        required this.emailId,
        required this.countryCode,
        required this.contactNo,
        required this.address1,
        required this.address2,
        required this.address3,
        required this.pincode,
        required this.gstNum,
        required this.remarks,
        required this.postOffice,
        required this.branchId,
        required this.additionalFields,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        emailId: json["email_id"],
        countryCode: json["country_code"],
        contactNo: json["contact_no"],
        address1: json["address1"],
        address2: json["address2"],
        address3: json["address3"],
        pincode: json["pincode"],
        gstNum: json["gst_num"],
        remarks: json["remarks"],
        postOffice: json["post_office"],
        branchId: json["branch_id"],
        additionalFields: List<AdditionalField>.from(json["additional_fields"].map((x) => AdditionalField.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email_id": emailId,
        "country_code": countryCode,
        "contact_no": contactNo,
        "address1": address1,
        "address2": address2,
        "address3": address3,
        "pincode": pincode,
        "gst_num": gstNum,
        "remarks": remarks,
        "post_office": postOffice,
        "branch_id": branchId,
        "additional_fields": List<dynamic>.from(additionalFields.map((x) => x.toJson())),
    };
}

class AdditionalField {
    String fieldId;
    String fieldName;
    String fieldValue;

    AdditionalField({
        required this.fieldId,
        required this.fieldName,
        required this.fieldValue,
    });

    factory AdditionalField.fromJson(Map<String, dynamic> json) => AdditionalField(
        fieldId: json["field_id"],
        fieldName: json["field_name"],
        fieldValue: json["field_value"],
    );

    Map<String, dynamic> toJson() => {
        "field_id": fieldId,
        "field_name": fieldName,
        "field_value": fieldValue,
    };
}
