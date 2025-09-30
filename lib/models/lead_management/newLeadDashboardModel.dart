class NewLeadDashboard {
  Data data;
  bool status;
  String message;

  NewLeadDashboard({
    required this.data,
    required this.status,
    required this.message,
  });

  factory NewLeadDashboard.fromJson(Map<String, dynamic> json) =>
      NewLeadDashboard(
        data: Data.fromJson(json["data"]),
        status: json["status"] ?? false,
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
        "message": message,
      };
}

class Data {
  int newLeads;
  int followupLeads;
  int closedLeads;
  int totalCalled;
  int missedLeads;
  String transferLeads;

  Data({
    required this.newLeads,
    required this.followupLeads,
    required this.closedLeads,
    required this.totalCalled,
    required this.missedLeads,
    required this.transferLeads,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        newLeads: int.tryParse(json["newLeads"].toString()) ?? 0,
        followupLeads: int.tryParse(json["followupLeads"].toString()) ?? 0,
        closedLeads: int.tryParse(json["closedLeads"].toString()) ?? 0,
        totalCalled: int.tryParse(json["totalCalled"].toString()) ?? 0,
        missedLeads: int.tryParse(json["missedLeads"].toString()) ?? 0,
        transferLeads: json["transferLeads"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "newLeads": newLeads,
        "followupLeads": followupLeads,
        "closedLeads": closedLeads,
        "totalCalled": totalCalled,
        "missedLeads": missedLeads,
        "transferLeads": transferLeads,
      };
}
