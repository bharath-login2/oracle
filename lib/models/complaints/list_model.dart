// To parse this JSON data, do
//
//     final listModel = listModelFromJson(jsonString);

import 'dart:convert';

ListModel listModelFromJson(String str) => ListModel.fromJson(json.decode(str));

String listModelToJson(ListModel data) => json.encode(data.toJson());

class ListModel {
    Data data;
    bool status;
    String message;

    ListModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory ListModel.fromJson(Map<String, dynamic> json) => ListModel(
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
    List<ListElement> lists;
    bool createComplaintPermission;

    Data({
        required this.lists,
        required this.createComplaintPermission,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        lists: List<ListElement>.from(json["lists"].map((x) => ListElement.fromJson(x))),
        createComplaintPermission: json["create_complaint_permission"],
    );

    Map<String, dynamic> toJson() => {
        "lists": List<dynamic>.from(lists.map((x) => x.toJson())),
        "create_complaint_permission": createComplaintPermission,
    };
}

class ListElement {
    String id;
    String complaintId;
    String createdDate;
    String incidentDate;
    String customerName;
    String contactNumber;
    String complaintReportedBy;
    String complaintStatus;
    bool isSent;
    String complaintRegisteredUser;
    bool viewRemarksPermission;
    bool updateComplaintPermission;
    bool deleteComplaintPermission;
    List<ReceiverList> receiverLists;
    List<ComplaintTypeList> complaintTypeLists;

    ListElement({
        required this.id,
        required this.complaintId,
        required this.createdDate,
        required this.incidentDate,
        required this.customerName,
        required this.contactNumber,
        required this.complaintReportedBy,
        required this.complaintStatus,
        required this.isSent,
        required this.complaintRegisteredUser,
        required this.viewRemarksPermission,
        required this.updateComplaintPermission,
        required this.deleteComplaintPermission,
        required this.receiverLists,
        required this.complaintTypeLists,
    });

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["id"],
        complaintId: json["complaint_id"],
        createdDate: json["created_date"],
        incidentDate: json["incident_date"],
        customerName: json["customer_name"],
        contactNumber: json["contact_number"],
        complaintReportedBy: json["complaint_reported_by"],
        complaintStatus: json["complaint_status"],
        isSent: json["is_sent"],
        complaintRegisteredUser: json["complaint_registered_user"],
        viewRemarksPermission: json["view_remarks_permission"],
        updateComplaintPermission: json["update_complaint_permission"],
        deleteComplaintPermission: json["delete_complaint_permission"],
        receiverLists: List<ReceiverList>.from(json["receiver_lists"].map((x) => ReceiverList.fromJson(x))),
        complaintTypeLists: List<ComplaintTypeList>.from(json["complaint_type_lists"].map((x) => ComplaintTypeList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "complaint_id": complaintId,
        "created_date": createdDate,
        "incident_date": incidentDate,
        "customer_name": customerName,
        "contact_number": contactNumber,
        "complaint_reported_by": complaintReportedBy,
        "complaint_status": complaintStatus,
        "is_sent": isSent,
        "complaint_registered_user": complaintRegisteredUser,
        "view_remarks_permission": viewRemarksPermission,
        "update_complaint_permission": updateComplaintPermission,
        "delete_complaint_permission": deleteComplaintPermission,
        "receiver_lists": List<dynamic>.from(receiverLists.map((x) => x.toJson())),
        "complaint_type_lists": List<dynamic>.from(complaintTypeLists.map((x) => x.toJson())),
    };
}

class ComplaintTypeList {
    String id;
    String complaintType;

    ComplaintTypeList({
        required this.id,
        required this.complaintType,
    });

    factory ComplaintTypeList.fromJson(Map<String, dynamic> json) => ComplaintTypeList(
        id: json["id"],
        complaintType: json["complaint_type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "complaint_type": complaintType,
    };
}

class ReceiverList {
    String receiverId;
    String staffName;

    ReceiverList({
        required this.receiverId,
        required this.staffName,
    });

    factory ReceiverList.fromJson(Map<String, dynamic> json) => ReceiverList(
        receiverId: json["receiver_id"],
        staffName: json["staff_name"],
    );

    Map<String, dynamic> toJson() => {
        "receiver_id": receiverId,
        "staff_name": staffName,
    };
}
