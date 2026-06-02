class SupplierLedgerResponse {
  bool? status;
  String? message;
  SupplierLedgerData? data;

  SupplierLedgerResponse({
    this.status,
    this.message,
    this.data,
  });

  SupplierLedgerResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? SupplierLedgerData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class SupplierLedgerData {
  String? supplierId;
  String? accountId;
  String? totalDebit;
  String? totalCredit;
  String? balance;
  String? totalTransactions;
  List<LedgerEntry>? ledger;

  SupplierLedgerData({
    this.supplierId,
    this.accountId,
    this.totalDebit,
    this.totalCredit,
    this.balance,
    this.totalTransactions,
    this.ledger,
  });

  SupplierLedgerData.fromJson(Map<String, dynamic> json) {
    supplierId = json['supplier_id'];
    accountId = json['account_id'];
    totalDebit = json['total_debit'];
    totalCredit = json['total_credit'];
    balance = json['balance'];
    totalTransactions = json['total_transactions'];
    if (json['ledger'] != null) {
      ledger = <LedgerEntry>[];
      json['ledger'].forEach((v) {
        ledger!.add(LedgerEntry.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['supplier_id'] = supplierId;
    data['account_id'] = accountId;
    data['total_debit'] = totalDebit;
    data['total_credit'] = totalCredit;
    data['balance'] = balance;
    data['total_transactions'] = totalTransactions;
    if (ledger != null) {
      data['ledger'] = ledger!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LedgerEntry {
  String? id;
  String? person;
  String? debit;
  String? credit;
  String? createdBy;
  String? createdDate;
  String? isDeleted;
  String? deletedDate;
  String? compareId;
  String? remarks;
  String? company;
  String? title;
  String? salarySummaryId;
  String? date;
 String? createdByName;
  LedgerEntry({
    this.id,
    this.person,
    this.debit,
    this.credit,
    this.createdBy,
    this.createdDate,
    this.isDeleted,
    this.deletedDate,
    this.compareId,
    this.remarks,
    this.company,
    this.title,
    this.salarySummaryId,
    this.date,
    this.createdByName,
  });

  LedgerEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    person = json['person'];
    debit = json['debit'];
    credit = json['credit'];
    createdBy = json['created_by'];
    createdDate = json['created_date'];
    isDeleted = json['is_deleted'];
    deletedDate = json['deleted_date'];
    compareId = json['compare_id'];
    remarks = json['remarks'];
    company = json['company'];
    title = json['title'];
    salarySummaryId = json['salary_summary_id'];
    date = json['date'];
    createdByName = json['created_by_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['person'] = person;
    data['debit'] = debit;
    data['credit'] = credit;
    data['created_by'] = createdBy;
    data['created_date'] = createdDate;
    data['is_deleted'] = isDeleted;
    data['deleted_date'] = deletedDate;
    data['compare_id'] = compareId;
    data['remarks'] = remarks;
    data['company'] = company;
    data['title'] = title;
    data['salary_summary_id'] = salarySummaryId;
    data['date'] = date;
    data['created_by_name'] = createdByName;
    return data;
  }

}