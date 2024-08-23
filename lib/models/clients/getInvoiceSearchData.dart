// To parse this JSON data, do
//
//     final getInvoiceSearchData = getInvoiceSearchDataFromJson(jsonString);

import 'dart:convert';

GetInvoiceSearchData getInvoiceSearchDataFromJson(String str) => GetInvoiceSearchData.fromJson(json.decode(str));

String getInvoiceSearchDataToJson(GetInvoiceSearchData data) => json.encode(data.toJson());

class GetInvoiceSearchData {
    Data data;
    bool status;
    String message;

    GetInvoiceSearchData({
        required this.data,
        required this.status,
        required this.message,
    });

    factory GetInvoiceSearchData.fromJson(Map<String, dynamic> json) => GetInvoiceSearchData(
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
    List<Type> types;
    List<PaymentStatus> paymentStatus;
    List<Customer> paymentMethods;
    List<Staff> staff;
    List<Customer> customers;

    Data({
        required this.types,
        required this.paymentStatus,
        required this.paymentMethods,
        required this.staff,
        required this.customers,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        types: List<Type>.from(json["types"].map((x) => Type.fromJson(x))),
        paymentStatus: List<PaymentStatus>.from(json["payment_status"].map((x) => PaymentStatus.fromJson(x))),
        paymentMethods: List<Customer>.from(json["payment_methods"].map((x) => Customer.fromJson(x))),
        staff: List<Staff>.from(json["staff"].map((x) => Staff.fromJson(x))),
        customers: List<Customer>.from(json["customers"].map((x) => Customer.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "types": List<dynamic>.from(types.map((x) => x.toJson())),
        "payment_status": List<dynamic>.from(paymentStatus.map((x) => x.toJson())),
        "payment_methods": List<dynamic>.from(paymentMethods.map((x) => x.toJson())),
        "staff": List<dynamic>.from(staff.map((x) => x.toJson())),
        "customers": List<dynamic>.from(customers.map((x) => x.toJson())),
    };
}

class Customer {
    String id;
    String name;

    Customer({
        required this.id,
        required this.name,
    });

    factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

class PaymentStatus {
    String paymentStatus;
    String displaySts;

    PaymentStatus({
        required this.paymentStatus,
        required this.displaySts,
    });

    factory PaymentStatus.fromJson(Map<String, dynamic> json) => PaymentStatus(
        paymentStatus: json["payment_status"],
        displaySts: json["display_sts"],
    );

    Map<String, dynamic> toJson() => {
        "payment_status": paymentStatus,
        "display_sts": displaySts,
    };
}

class Staff {
    String accountId;
    String accountName;

    Staff({
        required this.accountId,
        required this.accountName,
    });

    factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        accountId: json["account_id"],
        accountName: json["account_name"],
    );

    Map<String, dynamic> toJson() => {
        "account_id": accountId,
        "account_name": accountName,
    };
}

class Type {
    int id;
    String typeName;

    Type({
        required this.id,
        required this.typeName,
    });

    factory Type.fromJson(Map<String, dynamic> json) => Type(
        id: json["id"],
        typeName: json["type_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "type_name": typeName,
    };
}
