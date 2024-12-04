// To parse this JSON data, do
//
//     final receiptAddCommonDetailsModel = receiptAddCommonDetailsModelFromJson(jsonString);

import 'dart:convert';

ReceiptAddCommonDetailsModel receiptAddCommonDetailsModelFromJson(String str) => ReceiptAddCommonDetailsModel.fromJson(json.decode(str));

String receiptAddCommonDetailsModelToJson(ReceiptAddCommonDetailsModel data) => json.encode(data.toJson());

class ReceiptAddCommonDetailsModel {
    Data data;
    bool status;
    String message;

    ReceiptAddCommonDetailsModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory ReceiptAddCommonDetailsModel.fromJson(Map<String, dynamic> json) => ReceiptAddCommonDetailsModel(
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
    String name;
    String displayRecNumber;
    String displayInvNumber;
    List<Staff> staff;
    List<PaymentMethod> paymentMethods;
    String invoiceId;
    String customerId;
    String receiptNumber;
    String totalAmount;
    String amountDue;
    String particulars;
    List<SelectedGroup> selectedGroups;
    List<TargetGroup> targetGroups;

    Data({
        required this.name,
        required this.displayRecNumber,
        required this.displayInvNumber,
        required this.staff,
        required this.paymentMethods,
        required this.invoiceId,
        required this.customerId,
        required this.receiptNumber,
        required this.totalAmount,
        required this.amountDue,
        required this.particulars,
        required this.targetGroups,
        required this.selectedGroups,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        name: json["name"],
        displayRecNumber: json["display_rec_number"],
        displayInvNumber: json["display_inv_number"],
        staff: List<Staff>.from(json["staff"].map((x) => Staff.fromJson(x))),
        paymentMethods: List<PaymentMethod>.from(json["payment_methods"].map((x) => PaymentMethod.fromJson(x))),
        invoiceId: json["invoice_id"],
        customerId: json["customer_id"],
        receiptNumber: json["receipt_number"],
        totalAmount: json["total_amount"],
        amountDue: json["amount_due"],
        particulars: json["particulars"],
        targetGroups: List<TargetGroup>.from(json["target_groups"].map((x) => TargetGroup.fromJson(x))),
        selectedGroups: List<SelectedGroup>.from(json["selected_groups"].map((x) => SelectedGroup.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "display_rec_number": displayRecNumber,
        "display_inv_number": displayInvNumber,
        "staff": List<dynamic>.from(staff.map((x) => x.toJson())),
        "payment_methods": List<dynamic>.from(paymentMethods.map((x) => x.toJson())),
        "invoice_id": invoiceId,
        "customer_id": customerId,
        "receipt_number": receiptNumber,
        "total_amount": totalAmount,
        "amount_due": amountDue,
        "particulars": particulars,
        "target_groups": List<dynamic>.from(targetGroups.map((x) => x.toJson())),
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
