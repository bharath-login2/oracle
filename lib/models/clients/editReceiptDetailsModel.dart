// To parse this JSON data, do
//
//     final editReceiptModelDetailsModel = editReceiptModelDetailsModelFromJson(jsonString);

import 'dart:convert';

EditReceiptModelDetailsModel editReceiptModelDetailsModelFromJson(String str) =>
    EditReceiptModelDetailsModel.fromJson(json.decode(str));

String editReceiptModelDetailsModelToJson(EditReceiptModelDetailsModel data) =>
    json.encode(data.toJson());

class EditReceiptModelDetailsModel {
  Data data;
  bool status;
  String message;

  EditReceiptModelDetailsModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory EditReceiptModelDetailsModel.fromJson(Map<String, dynamic> json) =>
      EditReceiptModelDetailsModel(
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
  String receiptId;
  String displayRecNumber;
  String receiptNumber;
  String displayInvNumber;
  DateTime receiptDate;
  String collectedBy;
  String collectedStaff;
  String paymentMethod;
  String totalAmount;
  String amountDue;
  String paidAmount;
  String checkAmount;
  String clientName;
  String uploadedImg;
  String particulars;
  List<Staff> staff;
  List<PaymentMethod> paymentMethods;
  List<TargetGroup> targetGroups;
  List<SelectedGroup> selectedGroups;

  Data({
    required this.receiptId,
    required this.displayRecNumber,
    required this.receiptNumber,
    required this.displayInvNumber,
    required this.receiptDate,
    required this.collectedBy,
    required this.collectedStaff,
    required this.paymentMethod,
    required this.totalAmount,
    required this.amountDue,
    required this.paidAmount,
    required this.checkAmount,
    required this.clientName,
    required this.uploadedImg,
    required this.particulars,
    required this.staff,
    required this.paymentMethods,
    required this.targetGroups,
    required this.selectedGroups,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        receiptId: json["receipt_id"],
        displayRecNumber: json["display_rec_number"],
        receiptNumber: json["receipt_number"],
        displayInvNumber: json["display_inv_number"],
        receiptDate: DateTime.parse(json["receipt_date"]),
        collectedBy: json["collected_by"],
        collectedStaff: json["collected_staff"],
        paymentMethod: json["payment_method"],
        totalAmount: json["total_amount"],
        amountDue: json["amount_due"],
        paidAmount: json["paid_amount"],
        checkAmount: json["check_amount"],
        clientName: json["client_name"],
        uploadedImg: json["uploaded_img"],
        particulars: json["particulars"],
        staff: List<Staff>.from(json["staff"].map((x) => Staff.fromJson(x))),
        paymentMethods: List<PaymentMethod>.from(
            json["payment_methods"].map((x) => PaymentMethod.fromJson(x))),
        targetGroups: List<TargetGroup>.from(
            json["target_groups"].map((x) => TargetGroup.fromJson(x))),
        selectedGroups: List<SelectedGroup>.from(
            json["selected_groups"].map((x) => SelectedGroup.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "receipt_id": receiptId,
        "display_rec_number": displayRecNumber,
        "receipt_number": receiptNumber,
        "display_inv_number": displayInvNumber,
        "receipt_date":
            "${receiptDate.year.toString().padLeft(4, '0')}-${receiptDate.month.toString().padLeft(2, '0')}-${receiptDate.day.toString().padLeft(2, '0')}",
        "collected_by": collectedBy,
        "collected_staff": collectedStaff,
        "payment_method": paymentMethod,
        "total_amount": totalAmount,
        "amount_due": amountDue,
        "paid_amount": paidAmount,
        "check_amount": checkAmount,
        "client_name": clientName,
        "uploaded_img": uploadedImg,
        "particulars": particulars,
        "staff": List<dynamic>.from(staff.map((x) => x.toJson())),
        "payment_methods":
            List<dynamic>.from(paymentMethods.map((x) => x.toJson())),
        "target_groups":
            List<dynamic>.from(targetGroups.map((x) => x.toJson())),
      };
}

class PaymentMethod {
  String id;
  String name;

  PaymentMethod({
    required this.id,
    required this.name,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class Staff {
  String userId;
  String staffName;

  Staff({
    required this.userId,
    required this.staffName,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        userId: json["user_id"],
        staffName: json["staff_name"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "staff_name": staffName,
      };
}

class TargetGroup {
  String id;
  String groupName;

  TargetGroup({
    required this.id,
    required this.groupName,
  });

  factory TargetGroup.fromJson(Map<String, dynamic> json) => TargetGroup(
        id: json["id"],
        groupName: json["group_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "group_name": groupName,
      };
}

class SelectedGroup {
  String groupId;
  String groupName;

  SelectedGroup({
    required this.groupId,
    required this.groupName,
  });

  factory SelectedGroup.fromJson(Map<String, dynamic> json) => SelectedGroup(
        groupId: json["group_id"],
        groupName: json["group_name"],
      );

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "group_name": groupName,
      };
}
