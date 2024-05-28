// To parse this JSON data, do
//
//     final leadDashboardModel = leadDashboardModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

LeadDashboardModel leadDashboardModelFromJson(String str) => LeadDashboardModel.fromJson(json.decode(str));

String leadDashboardModelToJson(LeadDashboardModel data) => json.encode(data.toJson());

class LeadDashboardModel {
    Data data;
    bool status;
    String message;

    LeadDashboardModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory LeadDashboardModel.fromJson(Map<String, dynamic> json) => LeadDashboardModel(
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
    int newLeads;
    int followupLeads;
    int closedLeads;
    int totalCalled;
    int missedLeads;
    int transferLeads;
    LeadsCount currentLeadsCount;
    LeadsCount previousLeadsCount;
    int unreadNotification;

    Data({
        required this.newLeads,
        required this.followupLeads,
        required this.closedLeads,
        required this.totalCalled,
        required this.missedLeads,
        required this.transferLeads,
        required this.currentLeadsCount,
        required this.previousLeadsCount,
        required this.unreadNotification,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        newLeads: json["newLeads"],
        followupLeads: json["followupLeads"],
        closedLeads: json["closedLeads"],
        totalCalled: json["totalCalled"],
        missedLeads: json["missedLeads"],
        transferLeads: json["transferLeads"],
        currentLeadsCount: LeadsCount.fromJson(json["current_leads_count"]),
        previousLeadsCount: LeadsCount.fromJson(json["previous_leads_count"]),
        unreadNotification: json["unread_notification"],
    );

    Map<String, dynamic> toJson() => {
        "newLeads": newLeads,
        "followupLeads": followupLeads,
        "closedLeads": closedLeads,
        "totalCalled": totalCalled,
        "missedLeads": missedLeads,
        "transferLeads": transferLeads,
        "current_leads_count": currentLeadsCount.toJson(),
        "previous_leads_count": previousLeadsCount.toJson(),
        "unread_notification": unreadNotification,
    };
}

class LeadsCount {
    String total;
    String month;
    String date;

    LeadsCount({
        required this.total,
        required this.month,
        required this.date,
    });

    factory LeadsCount.fromJson(Map<String, dynamic> json) => LeadsCount(
        total: json["total"],
        month: json["month"],
        date: json["date"],
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "month": month,
        "date": date,
    };
}
