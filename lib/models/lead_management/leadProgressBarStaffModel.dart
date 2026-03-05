import 'dart:convert';

LeadProgressBarStaffModel leadProgressBarStaffModelFromJson(String str) =>
    LeadProgressBarStaffModel.fromJson(json.decode(str));

String leadProgressBarStaffModelToJson(LeadProgressBarStaffModel data) =>
    json.encode(data.toJson());

class LeadProgressBarStaffModel {
  final Data? data;
  final bool? status;
  final String? message;

  LeadProgressBarStaffModel({
    this.data,
    this.status,
    this.message,
  });

  factory LeadProgressBarStaffModel.fromJson(Map<String, dynamic> json) =>
      LeadProgressBarStaffModel(
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
  final List<StaffLead>? staffLeads;
  final int? staffTotal;

  Data({
    this.staffLeads,
    this.staffTotal,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        staffLeads: json["staff_leads"] == null
            ? []
            : List<StaffLead>.from(
                json["staff_leads"]!.map((x) => StaffLead.fromJson(x))),
        staffTotal: json["staff_total"],
      );

  Map<String, dynamic> toJson() => {
        "staff_leads": staffLeads == null
            ? []
            : List<dynamic>.from(staffLeads!.map((x) => x.toJson())),
        "staff_total": staffTotal,
      };
}

class StaffLead {
  final String? staffName;
  final String? staffId;
  final String? staffCount;
  final String? staffPercentage;

  StaffLead({
    this.staffName,
    this.staffId,
    this.staffCount,
    this.staffPercentage,
  });

  factory StaffLead.fromJson(Map<String, dynamic> json) => StaffLead(
        staffName: json["staffName"],
        staffId: json["staffId"],
        staffCount: json["staffCount"],
        staffPercentage: json["staffPercentage"],
      );

  Map<String, dynamic> toJson() => {
        "staffName": staffName,
        "staffId": staffId,
        "staffCount": staffCount,
        "staffPercentage": staffPercentage,
      };
}
