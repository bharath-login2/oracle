import 'dart:convert';

class CompanyLocationModel {
  final String message;
  final Data data;
  final bool status;

  CompanyLocationModel({
    required this.message,
    required this.data,
    required this.status,
  });

  factory CompanyLocationModel.fromRawJson(String str) => 
      CompanyLocationModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CompanyLocationModel.fromJson(Map<String, dynamic> json) => 
      CompanyLocationModel(
        message: json["message"],
        data: Data.fromJson(json["data"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
        "status": status,
      };
}

class Data {
  final String companyId;
  final String location;
  final List<String?> nicknames;
  final String company;

  Data({
    required this.companyId,
    required this.location,
    required this.nicknames,
    required this.company,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        companyId: json["company_id"],
        location: json["location"],
        nicknames: json["nicknames"] == null 
            ? [] 
            : List<String?>.from(json["nicknames"].map((x) => x)),
        company: json["company"],
      );

  Map<String, dynamic> toJson() => {
        "company_id": companyId,
        "location": location,
        "nicknames": nicknames == null 
            ? [] 
            : List<dynamic>.from(nicknames.map((x) => x)),
        "company": company,
      };
}