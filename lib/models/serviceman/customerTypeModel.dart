import 'package:meta/meta.dart';
import 'dart:convert';

class CustomerTypeModel {
    String status;
    List<CustType> data;

    CustomerTypeModel({
        required this.status,
        required this.data,
    });

    factory CustomerTypeModel.fromRawJson(String str) => CustomerTypeModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CustomerTypeModel.fromJson(Map<String, dynamic> json) => CustomerTypeModel(
        status: json["status"],
        data: List<CustType>.from(json["data"].map((x) => CustType.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class CustType {
    String customerTypeId;
    String customerType;

    CustType({
        required this.customerTypeId,
        required this.customerType,
    });

    factory CustType.fromRawJson(String str) => CustType.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CustType.fromJson(Map<String, dynamic> json) => CustType(
        customerTypeId: json["customer_type_id"],
        customerType: json["customer_type"],
    );

    Map<String, dynamic> toJson() => {
        "customer_type_id": customerTypeId,
        "customer_type": customerType,
    };
}
