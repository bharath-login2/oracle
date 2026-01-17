import 'dart:convert';

class CustomerModelService {
    String status;
    List<CustomerDetails> data;

    CustomerModelService({
        required this.status,
        required this.data,
    });

    factory CustomerModelService.fromRawJson(String str) => CustomerModelService.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CustomerModelService.fromJson(Map<String, dynamic> json) => CustomerModelService(
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
