import 'dart:convert';

class CompanyTargetModel {
    String message;
    List<Company> data;
    bool status;

    CompanyTargetModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory CompanyTargetModel.fromRawJson(String str) => CompanyTargetModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CompanyTargetModel.fromJson(Map<String, dynamic> json) => CompanyTargetModel(
        message: json["message"],
        data: List<Company>.from(json["data"].map((x) => Company.fromJson(x))),
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
    };
}

class Company {
    String id;
    String staffName;
    String targetAmount;
    String effectiveDate;
       String isActive;

    Company({
        required this.id,
        required this.staffName,
        required this.targetAmount,
        required this.effectiveDate,
         required this.isActive,
    });

    factory Company.fromRawJson(String str) => Company.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Company.fromJson(Map<String, dynamic> json) => Company(
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
