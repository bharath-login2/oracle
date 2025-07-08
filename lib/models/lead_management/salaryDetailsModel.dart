// To parse this JSON data, do
//
//     final salaryDetailsModel = salaryDetailsModelFromJson(jsonString);

import 'dart:convert';

SalaryDetailsModel salaryDetailsModelFromJson(String str) => SalaryDetailsModel.fromJson(json.decode(str));

String salaryDetailsModelToJson(SalaryDetailsModel data) => json.encode(data.toJson());

class SalaryDetailsModel {
    bool status;
    Data data;

    SalaryDetailsModel({
        required this.status,
        required this.data,
    });

    factory SalaryDetailsModel.fromJson(Map<String, dynamic> json) => SalaryDetailsModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
    };
}

class Data {
    String staffName;
    WorkingDetails workingDetails;
    LeaveDetails leaveDetails;
    SalaryDetails salaryDetails;

    Data({
        required this.staffName,
        required this.workingDetails,
        required this.leaveDetails,
        required this.salaryDetails,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        staffName: json["staff_name"],
        workingDetails: WorkingDetails.fromJson(json["working_details"]),
        leaveDetails: LeaveDetails.fromJson(json["leave_details"]),
        salaryDetails: SalaryDetails.fromJson(json["salary_details"]),
    );

    Map<String, dynamic> toJson() => {
        "staff_name": staffName,
        "working_details": workingDetails.toJson(),
        "leave_details": leaveDetails.toJson(),
        "salary_details": salaryDetails.toJson(),
    };
}

class LeaveDetails {
    int availableLeave;
    int casualLeave;
    int saturdayLeave;
    double totalLeave;
    double lop;

    LeaveDetails({
        required this.availableLeave,
        required this.casualLeave,
        required this.saturdayLeave,
        required this.totalLeave,
        required this.lop,
    });

    factory LeaveDetails.fromJson(Map<String, dynamic> json) => LeaveDetails(
        availableLeave: json["available_leave"],
        casualLeave: json["casual_leave"],
        saturdayLeave: json["saturday_leave"],
        totalLeave: json["total_leave"]?.toDouble(),
        lop: json["lop"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "available_leave": availableLeave,
        "casual_leave": casualLeave,
        "saturday_leave": saturdayLeave,
        "total_leave": totalLeave,
        "lop": lop,
    };
}

class SalaryDetails {
    double salaryCreditDays;
    int monthlySalary;
    int perDaySalary;
    int incentives;
    int deductions;
    int netSalary;

    SalaryDetails({
        required this.salaryCreditDays,
        required this.monthlySalary,
        required this.perDaySalary,
        required this.incentives,
        required this.deductions,
        required this.netSalary,
    });

    factory SalaryDetails.fromJson(Map<String, dynamic> json) => SalaryDetails(
        salaryCreditDays: json["salary_credit_days"]?.toDouble(),
        monthlySalary: json["monthly_salary"],
        perDaySalary: json["per_day_salary"],
        incentives: json["incentives"],
        deductions: json["deductions"],
        netSalary: json["net_salary"],
    );

    Map<String, dynamic> toJson() => {
        "salary_credit_days": salaryCreditDays,
        "monthly_salary": monthlySalary,
        "per_day_salary": perDaySalary,
        "incentives": incentives,
        "deductions": deductions,
        "net_salary": netSalary,
    };
}

class WorkingDetails {
    int totalWorkingDays;
    int fullDays;
    int halfDays;
    double totalWorkedDays;

    WorkingDetails({
        required this.totalWorkingDays,
        required this.fullDays,
        required this.halfDays,
        required this.totalWorkedDays,
    });

    factory WorkingDetails.fromJson(Map<String, dynamic> json) => WorkingDetails(
        totalWorkingDays: json["total_working_days"],
        fullDays: json["full_days"],
        halfDays: json["half_days"],
        totalWorkedDays: json["total_worked_days"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "total_working_days": totalWorkingDays,
        "full_days": fullDays,
        "half_days": halfDays,
        "total_worked_days": totalWorkedDays,
    };
}
