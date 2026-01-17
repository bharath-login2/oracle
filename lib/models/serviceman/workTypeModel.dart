import 'package:meta/meta.dart';
import 'dart:convert';

class WorkTypeModel {
    String status;
    List<WorkType> data;

    WorkTypeModel({
        required this.status,
        required this.data,
    });

    factory WorkTypeModel.fromRawJson(String str) => WorkTypeModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory WorkTypeModel.fromJson(Map<String, dynamic> json) => WorkTypeModel(
        status: json["status"],
        data: List<WorkType>.from(json["data"].map((x) => WorkType.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class WorkType {
    String id;
    String productType;
    String productName;
    String pipelineName;

    WorkType({
        required this.id,
        required this.productType,
        required this.productName,
        required this.pipelineName,
    });

    factory WorkType.fromRawJson(String str) => WorkType.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory WorkType.fromJson(Map<String, dynamic> json) => WorkType(
        id: json["id"],
        productType: json["product_type"],
        productName: json["product_name"],
        pipelineName: json["pipeline_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_type": productType,
        "product_name": productName,
        "pipeline_name": pipelineName,
    };
}
