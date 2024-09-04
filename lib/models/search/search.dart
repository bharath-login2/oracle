// To parse this JSON data, do
//
//     final searchDataModel = searchDataModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

SearchDataModel searchDataModelFromJson(String str) => SearchDataModel.fromJson(json.decode(str));

String searchDataModelToJson(SearchDataModel data) => json.encode(data.toJson());

class SearchDataModel {
    Data data;
    bool status;
    String message;

    SearchDataModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory SearchDataModel.fromJson(Map<String, dynamic> json) => SearchDataModel(
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
    List<Customer> customers;
    List<LeadDatum> leadData;

    Data({
        required this.customers,
        required this.leadData,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        customers: List<Customer>.from(json["customers"].map((x) => Customer.fromJson(x))),
        leadData: List<LeadDatum>.from(json["leadData"].map((x) => LeadDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "customers": List<dynamic>.from(customers.map((x) => x.toJson())),
        "leadData": List<dynamic>.from(leadData.map((x) => x.toJson())),
    };
}

class Customer {
    String id;
    String name;
    String contactNo;

    Customer({
        required this.id,
        required this.name,
        required this.contactNo,
    });

    factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        name: json["name"],
        contactNo: json["contact_no"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "contact_no": contactNo,
    };
}

class LeadDatum {
    String callMasterId;
    String clientName;
    String contactNumber1;

    LeadDatum({
        required this.callMasterId,
        required this.clientName,
        required this.contactNumber1,
    });

    factory LeadDatum.fromJson(Map<String, dynamic> json) => LeadDatum(
        callMasterId: json["call_master_id"],
        clientName: json["client_name"],
        contactNumber1: json["contact_number1"],
    );

    Map<String, dynamic> toJson() => {
        "call_master_id": callMasterId,
        "client_name": clientName,
        "contact_number1": contactNumber1,
    };
}
