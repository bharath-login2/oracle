import 'dart:convert';

class CustomerModel {
    String status;
    List<CustomerDetails> data;

    CustomerModel({
        required this.status,
        required this.data,
    });

    factory CustomerModel.fromRawJson(String str) => CustomerModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        status: json["status"],
        data: List<CustomerDetails>.from(json["data"].map((x) => CustomerDetails.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class CustomerDetails {
    String id;
    String name;
    String contactNo;
    String address;
    String emailId;

    CustomerDetails({
        required this.id,
        required this.name,
        required this.contactNo,
        required this.address,
        required this.emailId,
    });

    factory CustomerDetails.fromRawJson(String str) => CustomerDetails.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CustomerDetails.fromJson(Map<String, dynamic> json) => CustomerDetails(
        id: json["id"]??"",
        name: json["name"]??"",
        contactNo: json["contact_no"]??"",
        address: json["address"]??"",
        emailId: json["email_id"]??"",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "contact_no": contactNo,
        "address": address,
        "email_id": emailId,
    };
}
