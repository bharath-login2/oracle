// To parse this JSON data, do
//
//     final getModel = getModelFromJson(jsonString);

import 'dart:convert';

GetModel getModelFromJson(String str) => GetModel.fromJson(json.decode(str));

String getModelToJson(GetModel data) => json.encode(data.toJson());

class GetModel {
    Data data;
    bool status;
    String message;

    GetModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory GetModel.fromJson(Map<String, dynamic> json) => GetModel(
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
    List<ComplaintType> complaintType;
    List<ComplaintReporter> complaintReporter;
    List<ComplaintNature> complaintNature;
    List<ComplaintStatus> complaintStatus;
    List<StaffList> staffLists;
    List<BranchList> branchLists;
    bool isBranch;

    Data({
        required this.complaintType,
        required this.complaintReporter,
        required this.complaintNature,
        required this.complaintStatus,
        required this.staffLists,
        required this.branchLists,
        required this.isBranch,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        complaintType: List<ComplaintType>.from(json["complaint_type"].map((x) => ComplaintType.fromJson(x))),
        complaintReporter: List<ComplaintReporter>.from(json["complaint_reporter"].map((x) => ComplaintReporter.fromJson(x))),
        complaintNature: List<ComplaintNature>.from(json["complaint_nature"].map((x) => ComplaintNature.fromJson(x))),
        complaintStatus: List<ComplaintStatus>.from(json["complaint_status"].map((x) => ComplaintStatus.fromJson(x))),
        staffLists: List<StaffList>.from(json["staff_lists"].map((x) => StaffList.fromJson(x))),
        branchLists: List<BranchList>.from(json["branch_lists"].map((x) => BranchList.fromJson(x))),
        isBranch: json["is_branch"],
    );

    Map<String, dynamic> toJson() => {
        "complaint_type": List<dynamic>.from(complaintType.map((x) => x.toJson())),
        "complaint_reporter": List<dynamic>.from(complaintReporter.map((x) => x.toJson())),
        "complaint_nature": List<dynamic>.from(complaintNature.map((x) => x.toJson())),
        "complaint_status": List<dynamic>.from(complaintStatus.map((x) => x.toJson())),
        "staff_lists": List<dynamic>.from(staffLists.map((x) => x.toJson())),
        "branch_lists": List<dynamic>.from(branchLists.map((x) => x.toJson())),
        "is_branch": isBranch,
    };
}

class BranchList {
    String branchId;
    String branchName;

    BranchList({
        required this.branchId,
        required this.branchName,
    });

    factory BranchList.fromJson(Map<String, dynamic> json) => BranchList(
        branchId: json["branch_id"],
        branchName: json["branch_name"],
    );

    Map<String, dynamic> toJson() => {
        "branch_id": branchId,
        "branch_name": branchName,
    };
}

class ComplaintNature {
    String natureId;
    String natureName;

    ComplaintNature({
        required this.natureId,
        required this.natureName,
    });

    factory ComplaintNature.fromJson(Map<String, dynamic> json) => ComplaintNature(
        natureId: json["nature_id"],
        natureName: json["nature_name"],
    );

    Map<String, dynamic> toJson() => {
        "nature_id": natureId,
        "nature_name": natureName,
    };
}

class ComplaintReporter {
    String reporterId;
    String reporterName;

    ComplaintReporter({
        required this.reporterId,
        required this.reporterName,
    });

    factory ComplaintReporter.fromJson(Map<String, dynamic> json) => ComplaintReporter(
        reporterId: json["reporter_id"],
        reporterName: json["reporter_name"],
    );

    Map<String, dynamic> toJson() => {
        "reporter_id": reporterId,
        "reporter_name": reporterName,
    };
}

class ComplaintStatus {
    String statusId;
    String statusName;

    ComplaintStatus({
        required this.statusId,
        required this.statusName,
    });

    factory ComplaintStatus.fromJson(Map<String, dynamic> json) => ComplaintStatus(
        statusId: json["status_id"],
        statusName: json["status_name"],
    );

    Map<String, dynamic> toJson() => {
        "status_id": statusId,
        "status_name": statusName,
    };
}

class ComplaintType {
    String typeId;
    String type;

    ComplaintType({
        required this.typeId,
        required this.type,
    });

    factory ComplaintType.fromJson(Map<String, dynamic> json) => ComplaintType(
        typeId: json["type_id"],
        type: json["type"],
    );

    Map<String, dynamic> toJson() => {
        "type_id": typeId,
        "type": type,
    };
}

class StaffList {
    String userId;
    String staffName;

    StaffList({
        required this.userId,
        required this.staffName,
    });

    factory StaffList.fromJson(Map<String, dynamic> json) => StaffList(
        userId: json["user_id"],
        staffName: json["staff_name"],
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "staff_name": staffName,
    };
}
