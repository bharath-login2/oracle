// To parse this JSON data, do
//
//     final detailsModel = detailsModelFromJson(jsonString);

import 'dart:convert';

DetailsModel detailsModelFromJson(String str) => DetailsModel.fromJson(json.decode(str));

String detailsModelToJson(DetailsModel data) => json.encode(data.toJson());

class DetailsModel {
    Data data;
    bool status;
    String message;

    DetailsModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory DetailsModel.fromJson(Map<String, dynamic> json) => DetailsModel(
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
    String id;
    String reportedById;
    String reportedBy;
    String customerName;
    String contactNumber;
    String contactEmail;
    String incidentDate;
    String complaintDescription;
    String complaintStatusId;
    String complaintStatus;
    String complaintCreatedBy;
    List<ComplaintType> complaintType;
    List<ComplaintNature> complaintNature;
    List<ComplaintAgainstList> complaintAgainstLists;
    List<RemarksList> remarksList;

    Data({
        required this.id,
        required this.reportedById,
        required this.reportedBy,
        required this.customerName,
        required this.contactNumber,
        required this.contactEmail,
        required this.incidentDate,
        required this.complaintDescription,
        required this.complaintStatusId,
        required this.complaintStatus,
        required this.complaintCreatedBy,
        required this.complaintType,
        required this.complaintNature,
        required this.complaintAgainstLists,
        required this.remarksList,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        reportedById: json["reported_by_id"],
        reportedBy: json["reported_by"],
        customerName: json["customer_name"],
        contactNumber: json["contact_number"],
        contactEmail: json["contact_email"],
        incidentDate: json["incident_date"],
        complaintDescription: json["complaint_description"],
        complaintStatusId: json["complaint_status_id"],
        complaintStatus: json["complaint_status"],
        complaintCreatedBy: json["complaint_created_by"],
        complaintType: List<ComplaintType>.from(json["complaint_type"].map((x) => ComplaintType.fromJson(x))),
        complaintNature: List<ComplaintNature>.from(json["complaint_nature"].map((x) => ComplaintNature.fromJson(x))),
        complaintAgainstLists: List<ComplaintAgainstList>.from(json["complaint_against_lists"].map((x) => ComplaintAgainstList.fromJson(x))),
        remarksList: List<RemarksList>.from(json["remarks_list"].map((x) => RemarksList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "reported_by_id": reportedById,
        "reported_by": reportedBy,
        "customer_name": customerName,
        "contact_number": contactNumber,
        "contact_email": contactEmail,
        "incident_date": incidentDate,
        "complaint_description": complaintDescription,
        "complaint_status_id": complaintStatusId,
        "complaint_status": complaintStatus,
        "complaint_created_by": complaintCreatedBy,
        "complaint_type": List<dynamic>.from(complaintType.map((x) => x.toJson())),
        "complaint_nature": List<dynamic>.from(complaintNature.map((x) => x.toJson())),
        "complaint_against_lists": List<dynamic>.from(complaintAgainstLists.map((x) => x.toJson())),
        "remarks_list": List<dynamic>.from(remarksList.map((x) => x.toJson())),
    };
}

class ComplaintAgainstList {
    String receiverId;
    String staffName;
    String senderRemarks;

    ComplaintAgainstList({
        required this.receiverId,
        required this.staffName,
        required this.senderRemarks,
    });

    factory ComplaintAgainstList.fromJson(Map<String, dynamic> json) => ComplaintAgainstList(
        receiverId: json["receiver_id"],
        staffName: json["staff_name"],
        senderRemarks: json["sender_remarks"],
    );

    Map<String, dynamic> toJson() => {
        "receiver_id": receiverId,
        "staff_name": staffName,
        "sender_remarks": senderRemarks,
    };
}

class ComplaintNature {
    String id;
    String complaintNature;

    ComplaintNature({
        required this.id,
        required this.complaintNature,
    });

    factory ComplaintNature.fromJson(Map<String, dynamic> json) => ComplaintNature(
        id: json["id"],
        complaintNature: json["complaint_nature"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "complaint_nature": complaintNature,
    };
}

class ComplaintType {
    String id;
    String complaintType;

    ComplaintType({
        required this.id,
        required this.complaintType,
    });

    factory ComplaintType.fromJson(Map<String, dynamic> json) => ComplaintType(
        id: json["id"],
        complaintType: json["complaint_type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "complaint_type": complaintType,
    };
}

class RemarksList {
    String createdDate;
    String userid;
    String staffName;
    String receiverId;
    String receiverName;
    String receiverRemarks;
    bool isSent;

    RemarksList({
        required this.createdDate,
        required this.userid,
        required this.staffName,
        required this.receiverId,
        required this.receiverName,
        required this.receiverRemarks,
        required this.isSent,
    });

    factory RemarksList.fromJson(Map<String, dynamic> json) => RemarksList(
        createdDate: json["created_date"],
        userid: json["userid"],
        staffName: json["staff_name"],
        receiverId: json["receiver_id"],
        receiverName: json["receiver_name"],
        receiverRemarks: json["receiver_remarks"],
        isSent: json["is_sent"],
    );

    Map<String, dynamic> toJson() => {
        "created_date": createdDate,
        "userid": userid,
        "staff_name": staffName,
        "receiver_id": receiverId,
        "receiver_name": receiverName,
        "receiver_remarks": receiverRemarks,
        "is_sent": isSent,
    };
}
