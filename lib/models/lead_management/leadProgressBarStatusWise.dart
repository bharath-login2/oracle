import 'dart:convert';

LeadProgressBarStatusWise leadProgressBarStatusWiseFromJson(String str) =>
    LeadProgressBarStatusWise.fromJson(json.decode(str));

String leadProgressBarStatusWiseToJson(LeadProgressBarStatusWise data) =>
    json.encode(data.toJson());

class LeadProgressBarStatusWise {
  final Data? data;
  final bool? status;
  final String? message;

  LeadProgressBarStatusWise({
    this.data,
    this.status,
    this.message,
  });

  factory LeadProgressBarStatusWise.fromJson(Map<String, dynamic> json) =>
      LeadProgressBarStatusWise(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "status": status,
        "message": message,
      };
}

class Data {
  final List<StatusLead>? statusLeads;
  final int? statusTotal;

  Data({
    this.statusLeads,
    this.statusTotal,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        statusLeads: json["status_leads"] == null
            ? []
            : List<StatusLead>.from(
                json["status_leads"]!.map((x) => StatusLead.fromJson(x))),
        statusTotal: json["status_total"],
      );

  Map<String, dynamic> toJson() => {
        "status_leads": statusLeads == null
            ? []
            : List<dynamic>.from(statusLeads!.map((x) => x.toJson())),
        "status_total": statusTotal,
      };
}

class StatusLead {
  final String? statusName;
  final String? statusId;
  final String? statusCount;
  final String? statusPercentage;

  StatusLead({
    this.statusName,
    this.statusId,
    this.statusCount,
    this.statusPercentage,
  });

  factory StatusLead.fromJson(Map<String, dynamic> json) => StatusLead(
        statusName: json["statusName"],
        statusId: json["statusId"],
        statusCount: json["statusCount"],
        statusPercentage: json["statusPercentage"],
      );

  Map<String, dynamic> toJson() => {
        "statusName": statusName,
        "statusId": statusId,
        "statusCount": statusCount,
        "statusPercentage": statusPercentage,
      };
}
