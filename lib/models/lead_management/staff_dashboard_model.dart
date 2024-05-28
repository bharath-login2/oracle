// To parse this JSON data, do
//
//     final staffDashboardModel = staffDashboardModelFromJson(jsonString);

import 'dart:convert';

StaffDashboardModel staffDashboardModelFromJson(String str) => StaffDashboardModel.fromJson(json.decode(str));

String staffDashboardModelToJson(StaffDashboardModel data) => json.encode(data.toJson());

class StaffDashboardModel {
    Data data;
    bool status;
    String message;

    StaffDashboardModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory StaffDashboardModel.fromJson(Map<String, dynamic> json) => StaffDashboardModel(
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
    bool createLead;
    bool viewLead;
    bool updateLead;
    bool deleteLead;
    bool createLeadCategory;
    bool viewLeadCategory;
    bool updateLeadCategory;
    bool deleteLeadCategory;
    bool viewLeadReport;
    bool viewWhatsappSettings;
    bool updateWhatsappSettings;
    bool createFacebookSettings;
    bool updateFacebookSettings;
    bool deleteFacebookSettings;
    bool cloudCall;
    bool accessCallHistory;
    bool accessCallRecording;
    bool fileManager;
    bool phoneCallLog;
    LeadsCount currentLeadsCount;
    LeadsCount previousLeadsCount;

    Data({
        required this.newLeads,
        required this.followupLeads,
        required this.closedLeads,
        required this.totalCalled,
        required this.missedLeads,
        required this.transferLeads,
        required this.createLead,
        required this.viewLead,
        required this.updateLead,
        required this.deleteLead,
        required this.createLeadCategory,
        required this.viewLeadCategory,
        required this.updateLeadCategory,
        required this.deleteLeadCategory,
        required this.viewLeadReport,
        required this.viewWhatsappSettings,
        required this.updateWhatsappSettings,
        required this.createFacebookSettings,
        required this.updateFacebookSettings,
        required this.deleteFacebookSettings,
        required this.cloudCall,
        required this.accessCallHistory,
        required this.accessCallRecording,
        required this.fileManager,
        required this.phoneCallLog,
        required this.currentLeadsCount,
        required this.previousLeadsCount,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        newLeads: json["newLeads"],
        followupLeads: json["followupLeads"],
        closedLeads: json["closedLeads"],
        totalCalled: json["totalCalled"],
        missedLeads: json["missedLeads"],
        transferLeads: json["transferLeads"],
        createLead: json["create_lead"],
        viewLead: json["view_lead"],
        updateLead: json["update_lead"],
        deleteLead: json["delete_lead"],
        createLeadCategory: json["create_lead_category"],
        viewLeadCategory: json["view_lead_category"],
        updateLeadCategory: json["update_lead_category"],
        deleteLeadCategory: json["delete_lead_category"],
        viewLeadReport: json["view_lead_report"],
        viewWhatsappSettings: json["view_whatsapp_settings"],
        updateWhatsappSettings: json["update_whatsapp_settings"],
        createFacebookSettings: json["create_facebook_settings"],
        updateFacebookSettings: json["update_facebook_settings"],
        deleteFacebookSettings: json["delete_facebook_settings"],
        cloudCall: json["cloud_call"],
        accessCallHistory: json["access_call_history"],
        accessCallRecording: json["access_call_recording"],
        fileManager: json["file_manager"],
        phoneCallLog: json["phone_call_log"],
        currentLeadsCount: LeadsCount.fromJson(json["current_leads_count"]),
        previousLeadsCount: LeadsCount.fromJson(json["previous_leads_count"]),
    );

    Map<String, dynamic> toJson() => {
        "newLeads": newLeads,
        "followupLeads": followupLeads,
        "closedLeads": closedLeads,
        "totalCalled": totalCalled,
        "missedLeads": missedLeads,
        "transferLeads": transferLeads,
        "create_lead": createLead,
        "view_lead": viewLead,
        "update_lead": updateLead,
        "delete_lead": deleteLead,
        "create_lead_category": createLeadCategory,
        "view_lead_category": viewLeadCategory,
        "update_lead_category": updateLeadCategory,
        "delete_lead_category": deleteLeadCategory,
        "view_lead_report": viewLeadReport,
        "view_whatsapp_settings": viewWhatsappSettings,
        "update_whatsapp_settings": updateWhatsappSettings,
        "create_facebook_settings": createFacebookSettings,
        "update_facebook_settings": updateFacebookSettings,
        "delete_facebook_settings": deleteFacebookSettings,
        "cloud_call": cloudCall,
        "access_call_history": accessCallHistory,
        "access_call_recording": accessCallRecording,
        "file_manager": fileManager,
        "phone_call_log": phoneCallLog,
        "current_leads_count": currentLeadsCount.toJson(),
        "previous_leads_count": previousLeadsCount.toJson(),
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
