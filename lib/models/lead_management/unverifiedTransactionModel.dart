import 'dart:convert';

UnverifiedTransactionModel unverifiedTransactionModelFromJson(String str) =>
    UnverifiedTransactionModel.fromJson(json.decode(str));

String unverifiedTransactionModelToJson(UnverifiedTransactionModel data) =>
    json.encode(data.toJson());

class UnverifiedTransactionModel {
  bool status;
  String message;
  Data data;

  UnverifiedTransactionModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UnverifiedTransactionModel.fromJson(Map<String, dynamic> json) =>
      UnverifiedTransactionModel(
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
  List<Receipt> unverifiedReceipt;
  List<Expense> unverifiedExpense;
  List<Receipt> verifiedReceipt;
  List<Expense> verifiedExpense;

  Data({
    required this.unverifiedReceipt,
    required this.unverifiedExpense,
    required this.verifiedReceipt,
    required this.verifiedExpense,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        unverifiedReceipt: List<Receipt>.from(
            json["unverified_receipt"].map((x) => Receipt.fromJson(x))),
        unverifiedExpense: List<Expense>.from(
            json["unverified_expense"].map((x) => Expense.fromJson(x))),
        verifiedReceipt: List<Receipt>.from(
            json["verified_receipt"].map((x) => Receipt.fromJson(x))),
        verifiedExpense: List<Expense>.from(
            json["verified_expense"].map((x) => Expense.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "unverified_receipt":
            List<dynamic>.from(unverifiedReceipt.map((x) => x.toJson())),
        "unverified_expense":
            List<dynamic>.from(unverifiedExpense.map((x) => x.toJson())),
        "verified_receipt":
            List<dynamic>.from(verifiedReceipt.map((x) => x.toJson())),
        "verified_expense":
            List<dynamic>.from(verifiedExpense.map((x) => x.toJson())),
      };
}

class Receipt {
  String id;
  String receiptDate;
  String receiptNo;
  String invoiceNo;
  String customerName;
  String paidAmount;
  String accountHead;
  String createdBy;
  String createdAt;
  String? remarks;

  Receipt({
    required this.id,
    required this.receiptDate,
    required this.receiptNo,
    required this.invoiceNo,
    required this.customerName,
    required this.paidAmount,
    required this.accountHead,
    required this.createdBy,
    required this.createdAt,
    this.remarks,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
        id: json["id"],
        receiptDate: json["receipt_date"],
        receiptNo: json["receipt_no"],
        invoiceNo: json["invoice_no"],
        customerName: json["customer_name"],
        paidAmount: json["paid_amount"],
        accountHead: json["account_head"],
        createdBy: json["created_by"],
        createdAt: json["created_at"],
        remarks: json["remarks"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "receipt_date": receiptDate,
        "receipt_no": receiptNo,
        "invoice_no": invoiceNo,
        "customer_name": customerName,
        "paid_amount": paidAmount,
        "account_head": accountHead,
        "created_by": createdBy,
        "created_at": createdAt,
        "remarks": remarks ?? "",
      };
}

class Expense {
  String id;
  String date;
  String fromAccount;
  String accountHead;
  String amount;
  String category;
  String createdBy;
  String createdAt;
  String? remarks;

  Expense({
    required this.id,
    required this.date,
    required this.fromAccount,
    required this.accountHead,
    required this.amount,
    required this.category,
    required this.createdBy,
    required this.createdAt,
    this.remarks,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json["id"],
        date: json["date"],
        fromAccount: json["from_account"],
        accountHead: json["account_head"],
        amount: json["amount"],
        category: json["category"],
        createdBy: json["created_by"],
        createdAt: json["created_at"],
        remarks: json["remarks"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "from_account": fromAccount,
        "account_head": accountHead,
        "amount": amount,
        "category": category,
        "created_by": createdBy,
        "created_at": createdAt,
        "remarks": remarks ?? "",
      };
}