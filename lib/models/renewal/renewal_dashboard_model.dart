// To parse this JSON data, do
//
//     final renewalDashboardModel = renewalDashboardModelFromJson(jsonString);

import 'dart:convert';

RenewalDashboardModel renewalDashboardModelFromJson(String str) => RenewalDashboardModel.fromJson(json.decode(str));

String renewalDashboardModelToJson(RenewalDashboardModel data) => json.encode(data.toJson());

class RenewalDashboardModel {
    Data data;
    bool status;
    String message;

    RenewalDashboardModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory RenewalDashboardModel.fromJson(Map<String, dynamic> json) => RenewalDashboardModel(
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
    AllDataClass currentMonthData;
    AllDataClass nextMonthData;
    AllDataClass expiredData;
    AllDataClass allData;
    List<MonthReport> monthReport;

    Data({
        required this.currentMonthData,
        required this.nextMonthData,
        required this.expiredData,
        required this.allData,
        required this.monthReport,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        currentMonthData: AllDataClass.fromJson(json["current_month_data"]),
        nextMonthData: AllDataClass.fromJson(json["next_month_data"]),
        expiredData: AllDataClass.fromJson(json["expired_data"]),
        allData: AllDataClass.fromJson(json["all_data"]),
        monthReport: List<MonthReport>.from(json["month_report"].map((x) => MonthReport.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "current_month_data": currentMonthData.toJson(),
        "next_month_data": nextMonthData.toJson(),
        "expired_data": expiredData.toJson(),
        "all_data": allData.toJson(),
        "month_report": List<dynamic>.from(monthReport.map((x) => x.toJson())),
    };
}

class AllDataClass {
    String totalCount;
    String paidCount;
    String totalAmount;
    String paidAmount;

    AllDataClass({
        required this.totalCount,
        required this.paidCount,
        required this.totalAmount,
        required this.paidAmount,
    });

    factory AllDataClass.fromJson(Map<String, dynamic> json) => AllDataClass(
        totalCount: json["total_count"],
        paidCount: json["paid_count"],
        totalAmount: json["total_amount"],
        paidAmount: json["paid_amount"],
    );

    Map<String, dynamic> toJson() => {
        "total_count": totalCount,
        "paid_count": paidCount,
        "total_amount": totalAmount,
        "paid_amount": paidAmount,
    };
}

class MonthReport {
    String label;
    String amount;
    DateTime searchMonth;
    int percentage;

    MonthReport({
        required this.label,
        required this.amount,
        required this.searchMonth,
        required this.percentage,
    });

    factory MonthReport.fromJson(Map<String, dynamic> json) => MonthReport(
        label: json["label"],
        amount: json["amount"],
        searchMonth: DateTime.parse(json["search_month"]),
        percentage: json["percentage"],
    );

    Map<String, dynamic> toJson() => {
        "label": label,
        "amount": amount,
        "search_month": "${searchMonth.year.toString().padLeft(4, '0')}-${searchMonth.month.toString().padLeft(2, '0')}-${searchMonth.day.toString().padLeft(2, '0')}",
        "percentage": percentage,
    };
}
