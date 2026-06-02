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
        message: json["message"] ?? "",
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  List<UnverifiedReceipt> unverifiedReceipt;
  List<UnverifiedExpense> unverifiedExpense;
  List<VerifiedReceipt> verifiedReceipt;
  List<VerifiedExpense> verifiedExpense;
  List<VerifiedSalary>? verifiedSalary; // Added new field

  Data({
    required this.unverifiedReceipt,
    required this.unverifiedExpense,
    required this.verifiedReceipt,
    required this.verifiedExpense,
    this.verifiedSalary,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        unverifiedReceipt: List<UnverifiedReceipt>.from(
            json["unverified_receipt"].map((x) => UnverifiedReceipt.fromJson(x))),
        unverifiedExpense: List<UnverifiedExpense>.from(
            json["unverified_expense"].map((x) => UnverifiedExpense.fromJson(x))),
        verifiedReceipt: List<VerifiedReceipt>.from(
            json["verified_receipt"].map((x) => VerifiedReceipt.fromJson(x))),
        verifiedExpense: List<VerifiedExpense>.from(
            json["verified_expense"].map((x) => VerifiedExpense.fromJson(x))),
        verifiedSalary: json["verified_salary"] != null
            ? List<VerifiedSalary>.from(
                json["verified_salary"].map((x) => VerifiedSalary.fromJson(x)))
            : null,
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
        if (verifiedSalary != null)
          "verified_salary":
              List<dynamic>.from(verifiedSalary!.map((x) => x.toJson())),
      };
}

// Updated Receipt class for unverified receipts
class UnverifiedReceipt {
  String id;
  String clientId;
  String masterId;
  String receiptNumber;
  String receiptDate;
  String recieptAmount;
  String createdAt;
  String customerName;
  String staffName;
  String invoiceSerial;
  String invoiceNumber;
  String invType;
  String createdName;

  UnverifiedReceipt({
    required this.id,
    required this.clientId,
    required this.masterId,
    required this.receiptNumber,
    required this.receiptDate,
    required this.recieptAmount,
    required this.createdAt,
    required this.customerName,
    required this.staffName,
    required this.invoiceSerial,
    required this.invoiceNumber,
    required this.invType,
    required this.createdName,
  });

  factory UnverifiedReceipt.fromJson(Map<String, dynamic> json) => UnverifiedReceipt(
        id: json["id"].toString(),
        clientId: json["client_id"].toString(),
        masterId: json["master_id"].toString(),
        receiptNumber: json["receipt_number"].toString(),
        receiptDate: json["receipt_date"],
        recieptAmount: json["reciept_amount"].toString(),
        createdAt: json["created_at"],
        customerName: json["customer_name"],
        staffName: json["staff_name"],
        invoiceSerial: json["invoice_serial"],
        invoiceNumber: json["invoice_number"].toString(),
        invType: json["inv_type"].toString(),
        createdName: json["created_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "client_id": clientId,
        "master_id": masterId,
        "receipt_number": receiptNumber,
        "receipt_date": receiptDate,
        "reciept_amount": recieptAmount,
        "created_at": createdAt,
        "customer_name": customerName,
        "staff_name": staffName,
        "invoice_serial": invoiceSerial,
        "invoice_number": invoiceNumber,
        "inv_type": invType,
        "created_name": createdName,
      };
}

// Verified Receipt class (same structure as UnverifiedReceipt for now)
class VerifiedReceipt {
  String id;
  String clientId;
  String masterId;
  String receiptNumber;
  String receiptDate;
  String recieptAmount;
  String createdAt;
  String customerName;
  String staffName;
  String invoiceSerial;
  String invoiceNumber;
  String invType;
  String createdName;

  VerifiedReceipt({
    required this.id,
    required this.clientId,
    required this.masterId,
    required this.receiptNumber,
    required this.receiptDate,
    required this.recieptAmount,
    required this.createdAt,
    required this.customerName,
    required this.staffName,
    required this.invoiceSerial,
    required this.invoiceNumber,
    required this.invType,
    required this.createdName,
  });

  factory VerifiedReceipt.fromJson(Map<String, dynamic> json) => VerifiedReceipt(
        id: json["id"].toString(),
        clientId: json["client_id"].toString(),
        masterId: json["master_id"].toString(),
        receiptNumber: json["receipt_number"].toString(),
        receiptDate: json["receipt_date"],
        recieptAmount: json["reciept_amount"].toString(),
        createdAt: json["created_at"],
        customerName: json["customer_name"],
        staffName: json["staff_name"],
        invoiceSerial: json["invoice_serial"],
        invoiceNumber: json["invoice_number"].toString(),
        invType: json["inv_type"].toString(),
        createdName: json["created_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "client_id": clientId,
        "master_id": masterId,
        "receipt_number": receiptNumber,
        "receipt_date": receiptDate,
        "reciept_amount": recieptAmount,
        "created_at": createdAt,
        "customer_name": customerName,
        "staff_name": staffName,
        "invoice_serial": invoiceSerial,
        "invoice_number": invoiceNumber,
        "inv_type": invType,
        "created_name": createdName,
      };
}

// Updated Expense class for unverified expenses
class UnverifiedExpense {
  String cmpnyExId;
  String expCatid;
  String fromAccount;
  String tothePerson;
  String amount;
  String trnDate;
  String company;
  String remarks;
  String fromAccountPerson;
  String toAccountPerson;
  String expCatName;
  String staffName;
  String createdAt;

  UnverifiedExpense({
    required this.cmpnyExId,
    required this.expCatid,
    required this.fromAccount,
    required this.tothePerson,
    required this.amount,
    required this.trnDate,
    required this.company,
    required this.remarks,
    required this.fromAccountPerson,
    required this.toAccountPerson,
    required this.expCatName,
    required this.staffName,
    required this.createdAt,
  });

  factory UnverifiedExpense.fromJson(Map<String, dynamic> json) => UnverifiedExpense(
        cmpnyExId: json["CmpnyExId"].toString(),
        expCatid: json["ExpCatid"].toString(),
        fromAccount: json["from_account"].toString(),
        tothePerson: json["TothePerson"].toString(),
        amount: json["Amount"].toString(),
        trnDate: json["TrnDate"],
        company: json["company"].toString(),
        remarks: json["Remarks"] ?? "",
        fromAccountPerson: json["from_account_person"],
        toAccountPerson: json["to_account_person"],
        expCatName: json["ExpCatName"],
        staffName: json["staff_name"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "CmpnyExId": cmpnyExId,
        "ExpCatid": expCatid,
        "from_account": fromAccount,
        "TothePerson": tothePerson,
        "Amount": amount,
        "TrnDate": trnDate,
        "company": company,
        "Remarks": remarks,
        "from_account_person": fromAccountPerson,
        "to_account_person": toAccountPerson,
        "ExpCatName": expCatName,
        "staff_name": staffName,
        "created_at": createdAt,
      };
}

// Verified Expense class (same structure as UnverifiedExpense)
class VerifiedExpense {
  String cmpnyExId;
  String expCatid;
  String fromAccount;
  String tothePerson;
  String amount;
  String trnDate;
  String company;
  String remarks;
  String fromAccountPerson;
  String toAccountPerson;
  String expCatName;
  String staffName;
  String createdAt;

  VerifiedExpense({
    required this.cmpnyExId,
    required this.expCatid,
    required this.fromAccount,
    required this.tothePerson,
    required this.amount,
    required this.trnDate,
    required this.company,
    required this.remarks,
    required this.fromAccountPerson,
    required this.toAccountPerson,
    required this.expCatName,
    required this.staffName,
    required this.createdAt,
  });

  factory VerifiedExpense.fromJson(Map<String, dynamic> json) => VerifiedExpense(
        cmpnyExId: json["CmpnyExId"].toString(),
        expCatid: json["ExpCatid"].toString(),
        fromAccount: json["from_account"].toString(),
        tothePerson: json["TothePerson"].toString(),
        amount: json["Amount"].toString(),
        trnDate: json["TrnDate"],
        company: json["company"].toString(),
        remarks: json["Remarks"] ?? "",
        fromAccountPerson: json["from_account_person"],
        toAccountPerson: json["to_account_person"],
        expCatName: json["ExpCatName"],
        staffName: json["staff_name"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "CmpnyExId": cmpnyExId,
        "ExpCatid": expCatid,
        "from_account": fromAccount,
        "TothePerson": tothePerson,
        "Amount": amount,
        "TrnDate": trnDate,
        "company": company,
        "Remarks": remarks,
        "from_account_person": fromAccountPerson,
        "to_account_person": toAccountPerson,
        "ExpCatName": expCatName,
        "staff_name": staffName,
        "created_at": createdAt,
      };
}

// New Salary class for verified salary data
class VerifiedSalary {
  String id;
  String userId;
  String month;
  String workingDays;
  String fullDays;
  String halfDays;
  String workedDays;
  String availableLeave;
  String casualLeaveTaken;
  String saturdayLeaveTaken;
  String totalLeave;
  String lopDays;
  String salaryCreditDays;
  String totalSalary;
  String perDaySalary;
  String incentives;
  String deductions;
  String netSalary;
  String staffName;
  String verifiedByName;
  String createdAt;
  String verifiedAt;
  VerifiedSalary({
    required this.id,
    required this.userId,
    required this.month,
    required this.workingDays,
    required this.fullDays,
    required this.halfDays,
    required this.workedDays,
    required this.availableLeave,
    required this.casualLeaveTaken,
    required this.saturdayLeaveTaken,
    required this.totalLeave,
    required this.lopDays,
    required this.salaryCreditDays,
    required this.totalSalary,
    required this.perDaySalary,
    required this.incentives,
    required this.deductions,
    required this.netSalary,
    required this.staffName,
    required this.verifiedByName,
    required this.createdAt,
    required this.verifiedAt,
  });

  factory VerifiedSalary.fromJson(Map<String, dynamic> json) => VerifiedSalary(
        id: json["id"].toString(),
        userId: json["user_id"].toString(),
        month: json["month"],
        workingDays: json["working_days"].toString(),
        fullDays: json["full_days"].toString(),
        halfDays: json["half_days"].toString(),
        workedDays: json["worked_days"].toString(),
        availableLeave: json["available_leave"].toString(),
        casualLeaveTaken: json["casual_leave_taken"].toString(),
        saturdayLeaveTaken: json["saturday_leave_taken"].toString(),
        totalLeave: json["total_leave"].toString(),
        lopDays: json["lop_days"].toString(),
        salaryCreditDays: json["salary_credit_days"].toString(),
        totalSalary: json["total_salary"].toString(),
        perDaySalary: json["per_day_salary"].toString(),
        incentives: json["incentives"].toString(),
        deductions: json["deductions"].toString(),
        netSalary: json["net_salary"].toString(),
        staffName: json["staff_name"],
        verifiedByName: json["verified_by_name"],
        createdAt: json["created_at"],
        verifiedAt: json["verified_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "month": month,
        "working_days": workingDays,
        "full_days": fullDays,
        "half_days": halfDays,
        "worked_days": workedDays,
        "available_leave": availableLeave,
        "casual_leave_taken": casualLeaveTaken,
        "saturday_leave_taken": saturdayLeaveTaken,
        "total_leave": totalLeave,
        "lop_days": lopDays,
        "salary_credit_days": salaryCreditDays,
        "total_salary": totalSalary,
        "per_day_salary": perDaySalary,
        "incentives": incentives,
        "deductions": deductions,
        "net_salary": netSalary,
        "staff_name": staffName,
        "verified_by_name": verifiedByName,
        "created_at": createdAt,
        "verified_at": verifiedAt,
      };
}