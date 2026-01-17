// To parse this JSON data, do
//
//     final mainClientDetailsModel = mainClientDetailsModelFromJson(jsonString);

import 'dart:convert';

MainClientDetailsModel mainClientDetailsModelFromJson(String str) =>
    MainClientDetailsModel.fromJson(json.decode(str));

String mainClientDetailsModelToJson(MainClientDetailsModel data) =>
    json.encode(data.toJson());

class MainClientDetailsModel {
  bool status;
  String message;
  Data data;

  MainClientDetailsModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MainClientDetailsModel.fromJson(Map<String, dynamic> json) =>
      MainClientDetailsModel(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  String id;
  String name;
  String emailId;
  String contactNo;
  String address;
  String pincode;
  String gstNum;
  String postOffice;
  String totalInvoiceAmount;
  String totalReceiptAmount;
  List<Invoice> invoice;
  List<Receipt> receipts;
  List<RenewalList> renewalLists;
  List<LeadList> leadLists;

  Data({
    required this.id,
    required this.name,
    required this.emailId,
    required this.contactNo,
    required this.address,
    required this.pincode,
    required this.gstNum,
    required this.postOffice,
    required this.totalInvoiceAmount,
    required this.totalReceiptAmount,
    required this.invoice,
    required this.receipts,
    required this.renewalLists,
    required this.leadLists,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"]??"",
        name: json["name"]??"",
        emailId: json["email_id"]??"",
        contactNo: json["contact_no"]??"",
        address: json["address"]??"",
        pincode: json["pincode"]??"",
        gstNum: json["gst_num"]??"",
        postOffice: json["post_office"]??"",
        totalInvoiceAmount: json["total_invoice_amount"]??"",
        totalReceiptAmount: json["total_receipt_amount"]??"",
        invoice:
            List<Invoice>.from(json["invoice"].map((x) => Invoice.fromJson(x))),
        receipts: List<Receipt>.from(
            json["receipts"].map((x) => Receipt.fromJson(x))),
        renewalLists: List<RenewalList>.from(
            json["renewal_lists"].map((x) => RenewalList.fromJson(x))),
        leadLists: List<LeadList>.from(
            json["lead_lists"].map((x) => LeadList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email_id": emailId,
        "contact_no": contactNo,
        "address": address,
        "pincode": pincode,
        "gst_num": gstNum,
        "post_office": postOffice,
        "total_invoice_amount": totalInvoiceAmount,
        "total_receipt_amount": totalReceiptAmount,
        "invoice": List<dynamic>.from(invoice.map((x) => x.toJson())),
        "receipts": List<dynamic>.from(receipts.map((x) => x.toJson())),
        "renewal_lists":
            List<dynamic>.from(renewalLists.map((x) => x.toJson())),
      };
}

class Invoice {
  String invid;
  String invoiceNumber;
  String invoiceDate;
  String status;
  String totalAmount;
  String paidAmount;
  String balanceAmount;
  String paymentMethod;
  bool isPaid;
  List<Product> products;

  Invoice(
      {required this.invid,
      required this.invoiceNumber,
      required this.invoiceDate,
      required this.status,
      required this.totalAmount,
      required this.paidAmount,
      required this.balanceAmount,
      required this.paymentMethod,
      required this.isPaid,
      required this.products});

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        invid: json["invid"]??"",
        invoiceNumber: json["invoiceNumber"]??"",
        invoiceDate: json["invoiceDate"]??"",
        status: json["status"]??"",
        totalAmount: json["totalAmount"]??"",
        paidAmount: json["paidAmount"]??"",
        balanceAmount: json["balanceAmount"]??"",
        paymentMethod: json["paymentMethod"]??"",
        isPaid: json["isPaid"],
        products: List<Product>.from(
            json["products"].map((x) => Product.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "invid": invid,
        "invoiceNumber": invoiceNumber,
        "invoiceDate": invoiceDate,
        "status": status,
        "totalAmount": totalAmount,
        "paidAmount": paidAmount,
        "balanceAmount": balanceAmount,
        "paymentMethod": paymentMethod,
        "isPaid": isPaid,
      };
}

class Receipt {
  String receiptId;
  String receiptNumber;
  String invoiceNumber;
  String receiptDate;
  String paidAmount;
  String paymentMethod;
  String collectedBy;
  String uploadedFile;

  Receipt({
    required this.receiptId,
    required this.receiptNumber,
    required this.invoiceNumber,
    required this.receiptDate,
    required this.paidAmount,
    required this.paymentMethod,
    required this.collectedBy,
    required this.uploadedFile,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
        receiptId: json["receiptId"]??"",
        receiptNumber: json["receiptNumber"]??"",
        invoiceNumber: json["invoiceNumber"]??"",
        receiptDate: json["receiptDate"]??"",
        paidAmount: json["paidAmount"]??"",
        paymentMethod: json["paymentMethod"]??"",
        collectedBy: json["collectedBy"]??"",
        uploadedFile: json["uploaded_file"]??"",
      );

  Map<String, dynamic> toJson() => {
        "receiptId": receiptId,
        "receiptNumber": receiptNumber,
        "invoiceNumber": invoiceNumber,
        "receiptDate": receiptDate,
        "paidAmount": paidAmount,
        "paymentMethod": paymentMethod,
        "collectedBy": collectedBy,
        "uploaded_file": uploadedFile,
      };
}

class RenewalList {
  String id;
  String invoiceId;
  String clientId;
  String clientName;
  String contactNo;
  String startDate;
  String endDate;
  String remainingDays;
  String products;
  String cost;
  bool isRenewed;
  bool isExpired;
  bool isPaid;
  String renewalType;
  List<ProductId> productId;

  RenewalList({
    required this.id,
    required this.invoiceId,
    required this.clientId,
    required this.clientName,
    required this.contactNo,
    required this.startDate,
    required this.endDate,
    required this.remainingDays,
    required this.products,
    required this.cost,
    required this.isRenewed,
    required this.isExpired,
    required this.isPaid,
    required this.renewalType,
    required this.productId,
  });

  factory RenewalList.fromJson(Map<String, dynamic> json) => RenewalList(
        id: json["id"]??"",
        invoiceId: json["invoice_id"]??"",
        clientId: json["client_id"]??"",
        clientName: json["client_name"]??"",
        contactNo: json["contact_no"]??"",
        startDate: json["start_date"]??"",
        endDate: json["end_date"]??"",
        remainingDays: json["remaining_days"]??"",
        products: json["products"]??"",
        cost: json["cost"]??"",
        isRenewed: json["is_renewed"]??"",
        isExpired: json["is_expired"]??"",
        isPaid: json["is_paid"]??"",
        renewalType: json["renewal_type"]??"",
        productId: List<ProductId>.from(
            json["product_id"].map((x) => ProductId.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "invoice_id": invoiceId,
        "client_id": clientId,
        "client_name": clientName,
        "contact_no": contactNo,
        "start_date": startDate,
        "end_date": endDate,
        "remaining_days": remainingDays,
        "products": products,
        "cost": cost,
        "is_renewed": isRenewed,
        "is_expired": isExpired,
        "is_paid": isPaid,
        "renewal_type": renewalType,
        "product_id": List<dynamic>.from(productId.map((x) => x.toJson())),
      };
}

class ProductId {
  String prdId;
  String prdName;
  String prdCost;
  String prdQty;

  ProductId({
    required this.prdId,
    required this.prdName,
    required this.prdCost,
    required this.prdQty,
  });

  factory ProductId.fromJson(Map<String, dynamic> json) => ProductId(
        prdId: json["prd_id"]??"",
        prdName: json["prd_name"]??"",
        prdCost: json["prd_cost"]??"",
        prdQty: json["prd_qty"]??"",
      );

  Map<String, dynamic> toJson() => {
        "prd_id": prdId,
        "prd_name": prdName,
        "prd_cost": prdCost,
        "prd_qty": prdQty,
      };
}

class Product {
  String productId;
  String qty;
  String amount;
  String productName;

  Product({
    required this.productId,
    required this.qty,
    required this.amount,
    required this.productName,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        productId: json["product_id"]??"",
        qty: json["qty"]??"",
        amount: json["amount"]??"",
        productName: json["product_name"]??"",
      );

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "qty": qty,
        "amount": amount,
        "product_name": productName,
      };
}

class LeadList {
  String callDetailsId;
  String callMasterId;
  String calledDate;
  String createdDate;
  DateTime lastCalledDate;
  int callResultId;
  String callStatusId;
  bool isNewCall;
  String followupDate;
  String scheduledDate;
  String clientName;
  String contactNumber1;
  String callResult;
  String proPicThumb;
  String staffName;
  String leadCategory;
  String priority;
  String priorityName;
  String categoryCount;
  String leadCategoryId;
  String leadSubCategoryId;
  String cost;
  String address;
  String leadSubCategory;
  String custId;
  String profilePic;
  bool isCalled;
  bool isSelected;
  bool isCustomer;

  LeadList({
    required this.callDetailsId,
    required this.callMasterId,
    required this.calledDate,
    required this.createdDate,
    required this.lastCalledDate,
    required this.callResultId,
    required this.callStatusId,
    required this.isNewCall,
    required this.followupDate,
    required this.scheduledDate,
    required this.clientName,
    required this.contactNumber1,
    required this.callResult,
    required this.proPicThumb,
    required this.staffName,
    required this.leadCategory,
    required this.priority,
    required this.priorityName,
    required this.categoryCount,
    required this.leadCategoryId,
    required this.leadSubCategoryId,
    required this.cost,
    required this.address,
    required this.leadSubCategory,
    required this.custId,
    required this.profilePic,
    required this.isCalled,
    required this.isSelected,
    required this.isCustomer,
  });

  factory LeadList.fromJson(Map<String, dynamic> json) => LeadList(
        callDetailsId: json["call_details_id"]??"",
        callMasterId: json["call_master_id"]??"",
        calledDate: json["called_date"]??"",
        createdDate: json["created_date"]??"",
        lastCalledDate: DateTime.parse(json["last_called_date"]),
        callResultId: json["call_result_id"]??"",
        callStatusId: json["call_status_id"]??"",
        isNewCall: json["is_new_call"]??"",
        followupDate: json["followup_date"]??"",
        scheduledDate: json["scheduled_date"]??"",
        clientName: json["client_name"]??"",
        contactNumber1: json["contact_number1"]??"",
        callResult: json["call_result"]??"",
        proPicThumb: json["pro_pic_thumb"]??"",
        staffName: json["staff_name"]??"",
        leadCategory: json["lead_category"]??"",
        priority: json["priority"]??"",
        priorityName: json["priority_name"]??"",
        categoryCount: json["category_count"]??"",
        leadCategoryId: json["lead_category_id"]??"",
        leadSubCategoryId: json["lead_sub_category_id"]??"",
        cost: json["cost"]??"",
        address: json["address"]??"",
        leadSubCategory: json["lead_sub_category"]??"",
        custId: json["cust_id"]??"",
        profilePic: json["profile_pic"]??"",
        isCalled: json["is_called"]??"",
        isSelected: json["is_selected"]??"",
        isCustomer: json["is_customer"]??"",
      );

  Map<String, dynamic> toJson() => {
        "call_details_id": callDetailsId,
        "call_master_id": callMasterId,
        "called_date": calledDate,
        "created_date": createdDate,
        "last_called_date":
            "${lastCalledDate.year.toString().padLeft(4, '0')}-${lastCalledDate.month.toString().padLeft(2, '0')}-${lastCalledDate.day.toString().padLeft(2, '0')}",
        "call_result_id": callResultId,
        "call_status_id": callStatusId,
        "is_new_call": isNewCall,
        "followup_date": followupDate,
        "scheduled_date": scheduledDate,
        "client_name": clientName,
        "contact_number1": contactNumber1,
        "call_result": callResult,
        "pro_pic_thumb": proPicThumb,
        "staff_name": staffName,
        "lead_category": leadCategory,
        "priority": priority,
        "priority_name": priorityName,
        "category_count": categoryCount,
        "lead_category_id": leadCategoryId,
        "lead_sub_category_id": leadSubCategoryId,
        "cost": cost,
        "address": address,
        "lead_sub_category": leadSubCategory,
        "cust_id": custId,
        "profile_pic": profilePic,
        "is_called": isCalled,
        "is_selected": isSelected,
        "is_customer": isCustomer,
      };
}
