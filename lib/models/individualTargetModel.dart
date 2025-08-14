import 'dart:convert';

class IndividualTargetModel {
    String message;
    List<Individual> data;
    bool status;

    IndividualTargetModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory IndividualTargetModel.fromRawJson(String str) => IndividualTargetModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory IndividualTargetModel.fromJson(Map<String, dynamic> json) => IndividualTargetModel(
        message: json["message"],
        data: List<Individual>.from(json["data"].map((x) => Individual.fromJson(x))),
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
    };
}

class Individual {
    String id;
    String staffName;
    String targetAmount;
    String effectiveDate;
       String isActive;

    Individual({
        required this.id,
        required this.staffName,
        required this.targetAmount,
        required this.effectiveDate,
         required this.isActive,
    });

    factory Individual.fromRawJson(String str) => Individual.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Individual.fromJson(Map<String, dynamic> json) => Individual(
        id: json["id"],
        staffName: json["staff_name"],
        targetAmount: json["target_amount"],
        effectiveDate: json["effective_date"],
         isActive: json["is_active"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "staff_name": staffName,
        "target_amount": targetAmount,
        "effective_date": effectiveDate,
          "is_active": isActive,
    };
}
