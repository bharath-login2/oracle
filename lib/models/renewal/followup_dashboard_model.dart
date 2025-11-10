// To parse this JSON data, do
//
//     final followupDashboardModel = followupDashboardModelFromJson(jsonString);

import 'dart:convert';

FollowupDashboardModel followupDashboardModelFromJson(String str) => FollowupDashboardModel.fromJson(json.decode(str));

String followupDashboardModelToJson(FollowupDashboardModel data) => json.encode(data.toJson());

class FollowupDashboardModel {
    Data data;
    bool status;
    String message;

    FollowupDashboardModel({
        required this.data,
        required this.status,
        required this.message,
    });

    factory FollowupDashboardModel.fromJson(Map<String, dynamic> json) => FollowupDashboardModel(
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
    String renewalId;
    String invoiceId;
    String leadId;
    String clientId;
    String customerName;
    String contactNo;
    String createdBy;
    String renewalStatus;
    String nextFollowUpDate;
    List<Followup> followup;
    List<FollowUpLog> followUpLog;
    String nextStartDate;
    String nextEndDate;
    List<ProductList> productLists;
    List<AllProduct> allProducts;
    List<dynamic> branch;
    List<RenewalTemplate> renewalTemplate;
    List<Staff> staff;
    List<CallResponse> callResponse;
    List<CallResult> callResult;
    List<PaymentStatusList> paymentStatusList;
    List<PaymentMethod> paymentMethods;
    List<ReasonList> reasonList;

    Data({
        required this.renewalId,
        required this.invoiceId,
        required this.leadId,
        required this.clientId,
        required this.customerName,
        required this.contactNo,
        required this.createdBy,
        required this.renewalStatus,
        required this.nextFollowUpDate,
        required this.followup,
        required this.followUpLog,
        required this.nextStartDate,
        required this.nextEndDate,
        required this.productLists,
        required this.allProducts,
        required this.branch,
        required this.renewalTemplate,
        required this.staff,
        required this.callResponse,
        required this.callResult,
        required this.paymentStatusList,
        required this.paymentMethods,
        required this.reasonList,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        renewalId: json["renewal_id"],
        invoiceId: json["invoice_id"],
        leadId: json["lead_id"],
        clientId: json["client_id"],
        customerName: json["customer_name"],
        contactNo: json["contact_no"],
        createdBy: json["created_by"],
        renewalStatus: json["renewal_status"],
        nextFollowUpDate: json["next_follow_up_date"],
        followup: List<Followup>.from(json["followup"].map((x) => Followup.fromJson(x))),
        followUpLog: List<FollowUpLog>.from(json["follow_up_log"].map((x) => FollowUpLog.fromJson(x))),
        nextStartDate: json["next_start_date"],
        nextEndDate: json["next_end_date"],
        productLists: List<ProductList>.from(json["product_lists"].map((x) => ProductList.fromJson(x))),
        allProducts: List<AllProduct>.from(json["all_products"].map((x) => AllProduct.fromJson(x))),
        branch: List<dynamic>.from(json["branch"].map((x) => x)),
        renewalTemplate: List<RenewalTemplate>.from(json["renewal_template"].map((x) => RenewalTemplate.fromJson(x))),
        staff: List<Staff>.from(json["staff"].map((x) => Staff.fromJson(x))),
        callResponse: List<CallResponse>.from(json["call_response"].map((x) => CallResponse.fromJson(x))),
        callResult: List<CallResult>.from(json["call_result"].map((x) => CallResult.fromJson(x))),
        paymentStatusList: List<PaymentStatusList>.from(json["payment_status_list"].map((x) => PaymentStatusList.fromJson(x))),
        paymentMethods: List<PaymentMethod>.from(json["payment_methods"].map((x) => PaymentMethod.fromJson(x))),
        reasonList: List<ReasonList>.from(json["reason_list"].map((x) => ReasonList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "renewal_id": renewalId,
        "invoice_id": invoiceId,
        "lead_id": leadId,
        "client_id": clientId,
        "customer_name": customerName,
        "contact_no": contactNo,
        "created_by": createdBy,
        "renewal_status": renewalStatus,
        "next_follow_up_date": nextFollowUpDate,
        "followup": List<dynamic>.from(followup.map((x) => x.toJson())),
        "follow_up_log": List<dynamic>.from(followUpLog.map((x) => x.toJson())),
        "next_start_date": nextStartDate,
        "next_end_date": nextEndDate,
        "product_lists": List<dynamic>.from(productLists.map((x) => x.toJson())),
        "all_products": List<dynamic>.from(allProducts.map((x) => x.toJson())),
        "branch": List<dynamic>.from(branch.map((x) => x)),
        "renewal_template": List<dynamic>.from(renewalTemplate.map((x) => x.toJson())),
        "staff": List<dynamic>.from(staff.map((x) => x.toJson())),
        "call_response": List<dynamic>.from(callResponse.map((x) => x.toJson())),
        "call_result": List<dynamic>.from(callResult.map((x) => x.toJson())),
        "payment_status_list": List<dynamic>.from(paymentStatusList.map((x) => x.toJson())),
        "payment_methods": List<dynamic>.from(paymentMethods.map((x) => x.toJson())),
        "reason_list": List<dynamic>.from(reasonList.map((x) => x.toJson())),
    };
}

class AllProduct {
    String id;
    String productName;
    String sellingPrice;
    String taxPercent;
    String noOfDays;
    String taxAmount;

    AllProduct({
        required this.id,
        required this.productName,
        required this.sellingPrice,
        required this.taxPercent,
        required this.noOfDays,
        required this.taxAmount,
    });

    factory AllProduct.fromJson(Map<String, dynamic> json) => AllProduct(
        id: json["id"],
        productName: json["product_name"],
        sellingPrice: json["selling_price"],
        taxPercent: json["tax_percent"],
        noOfDays: json["no_of_days"],
        taxAmount: json["tax_amount"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "selling_price": sellingPrice,
        "tax_percent": taxPercent,
        "no_of_days": noOfDays,
        "tax_amount": taxAmount,
    };
}

class CallResponse {
    String callResponseId;
    String callResponse;

    CallResponse({
        required this.callResponseId,
        required this.callResponse,
    });

    factory CallResponse.fromJson(Map<String, dynamic> json) => CallResponse(
        callResponseId: json["call_response_id"],
        callResponse: json["call_response"],
    );

    Map<String, dynamic> toJson() => {
        "call_response_id": callResponseId,
        "call_response": callResponse,
    };
}

class CallResult {
    String callResultId;
    String callResult;

    CallResult({
        required this.callResultId,
        required this.callResult,
    });

    factory CallResult.fromJson(Map<String, dynamic> json) => CallResult(
        callResultId: json["call_result_id"],
        callResult: json["call_result"],
    );

    Map<String, dynamic> toJson() => {
        "call_result_id": callResultId,
        "call_result": callResult,
    };
}

class FollowUpLog {
    String profile;
    String staffName;
    String remarks;
    String createdAt;

    FollowUpLog({
        required this.profile,
        required this.staffName,
        required this.remarks,
        required this.createdAt,
    });

    factory FollowUpLog.fromJson(Map<String, dynamic> json) => FollowUpLog(
        profile: json["profile"],
        staffName: json["staff_name"],
        remarks: json["remarks"],
        createdAt: json["created_at"],
    );

    Map<String, dynamic> toJson() => {
        "profile": profile,
        "staff_name": staffName,
        "remarks": remarks,
        "created_at": createdAt,
    };
}

class Followup {
    String dispalyDate;
    String dispalyTime;
    bool isSetReminder;
    bool isReminder;
    String time;
    String reminderId;
    String rowId;
    String remarks;
    String leadStatus;
    String leadStatusName;
    String staffName;
    String proPicThumb;
    String isCompleted;
    DateTime nextFollowupDate;
    String calledDate;
    String isEditable;

    Followup({
        required this.dispalyDate,
        required this.dispalyTime,
        required this.isSetReminder,
        required this.isReminder,
        required this.time,
        required this.reminderId,
        required this.rowId,
        required this.remarks,
        required this.leadStatus,
        required this.leadStatusName,
        required this.staffName,
        required this.proPicThumb,
        required this.isCompleted,
        required this.nextFollowupDate,
        required this.calledDate,
        required this.isEditable,
    });

    factory Followup.fromJson(Map<String, dynamic> json) => Followup(
        dispalyDate: json["dispaly_date"]??"",
        dispalyTime: json["dispaly_time"]??"",
        isSetReminder: json["isSetReminder"]??"",
        isReminder: json["isReminder"]??"",
        time: json["time"]??"",
        reminderId: json["reminder_id"]??"",
        rowId: json["row_id"]??"",
        remarks: json["remarks"]??"",
        leadStatus: json["lead_status"]??"",
        leadStatusName: json["lead_status_name"]??"",
        staffName: json["staff_name"]??"",
        proPicThumb: json["pro_pic_thumb"]??"",
        isCompleted: json["is_completed"]??"",
        nextFollowupDate: DateTime.parse(json["next_followup_date"]),
        calledDate: json["called_date"]??"",
        isEditable: json["is_editable"]??"",
    );

    Map<String, dynamic> toJson() => {
        "dispaly_date": dispalyDate,
        "dispaly_time": dispalyTime,
        "isSetReminder": isSetReminder,
        "isReminder": isReminder,
        "time": time,
        "reminder_id": reminderId,
        "row_id": rowId,
        "remarks": remarks,
        "lead_status": leadStatus,
        "lead_status_name": leadStatusName,
        "staff_name": staffName,
        "pro_pic_thumb": proPicThumb,
        "is_completed": isCompleted,
        "next_followup_date": nextFollowupDate.toIso8601String(),
        "called_date": calledDate,
        "is_editable": isEditable,
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

class PaymentStatusList {
    String paymentStatus;
    String displaySts;

    PaymentStatusList({
        required this.paymentStatus,
        required this.displaySts,
    });

    factory PaymentStatusList.fromJson(Map<String, dynamic> json) => PaymentStatusList(
        paymentStatus: json["payment_status"],
        displaySts: json["display_sts"],
    );

    Map<String, dynamic> toJson() => {
        "payment_status": paymentStatus,
        "display_sts": displaySts,
    };
}

class ProductList {
    String rowId;
    String productId;
    String productName;
    String productDescription;
    String rate;
    String qty;
    String taxPercentage;
    String taxAmount;
    String amount;

    ProductList({
        required this.rowId,
        required this.productId,
        required this.productName,
        required this.productDescription,
        required this.rate,
        required this.qty,
        required this.taxPercentage,
        required this.taxAmount,
        required this.amount,
    });

    factory ProductList.fromJson(Map<String, dynamic> json) => ProductList(
        rowId: json["row_id"],
        productId: json["product_id"],
        productName: json["product_name"],
        productDescription: json["product_description"],
        rate: json["rate"],
        qty: json["qty"],
        taxPercentage: json["tax_percentage"],
        taxAmount: json["tax_amount"],
        amount: json["amount"],
    );

    Map<String, dynamic> toJson() => {
        "row_id": rowId,
        "product_id": productId,
        "product_name": productName,
        "product_description": productDescription,
        "rate": rate,
        "qty": qty,
        "tax_percentage": taxPercentage,
        "tax_amount": taxAmount,
        "amount": amount,
    };
}

class ReasonList {
    String id;
    String reason;

    ReasonList({
        required this.id,
        required this.reason,
    });

    factory ReasonList.fromJson(Map<String, dynamic> json) => ReasonList(
        id: json["id"],
        reason: json["reason"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "reason": reason,
    };
}

class RenewalTemplate {
    String id;
    String templateName;

    RenewalTemplate({
        required this.id,
        required this.templateName,
    });

    factory RenewalTemplate.fromJson(Map<String, dynamic> json) => RenewalTemplate(
        id: json["id"],
        templateName: json["template_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "template_name": templateName,
    };
}

class Staff {
    String accountId;
    String accountName;

    Staff({
        required this.accountId,
        required this.accountName,
    });

    factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        accountId: json["account_id"],
        accountName: json["account_name"],
    );

    Map<String, dynamic> toJson() => {
        "account_id": accountId,
        "account_name": accountName,
    };
}
