class GetRecentExpenseModel {
  Data? data;
  bool? status;
  String? message;

  GetRecentExpenseModel({this.data, this.status, this.message});

  GetRecentExpenseModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data?.toJson();
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  List<ExpenseItem>? list;
  String? totalAmount;
  int? totalRecords;

  Data({this.list, this.totalAmount, this.totalRecords});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <ExpenseItem>[];
      json['list'].forEach((v) {
        list!.add(ExpenseItem.fromJson(v));
      });
    }
    totalAmount = json['total_amount'];
    totalRecords = json['total_records'] is int
        ? json['total_records']
        : int.tryParse(json['total_records']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    data['total_amount'] = totalAmount;
    data['total_records'] = totalRecords;
    return data;
  }
}

class ExpenseItem {
  String? cmpnyExId;
  String? expCatid;
  String? fromAccount;
  String? tothePerson;
  String? amount;
  String? trnDate;
  String? company;
  String? remarks;
  String? fromAccountPerson;
  String? toAccountPerson;
  String? expCatName;
  String? staffName;
  String? createdAt;

  ExpenseItem({
    this.cmpnyExId,
    this.expCatid,
    this.fromAccount,
    this.tothePerson,
    this.amount,
    this.trnDate,
    this.company,
    this.remarks,
    this.fromAccountPerson,
    this.toAccountPerson,
    this.expCatName,
    this.staffName,
    this.createdAt,
  });

  ExpenseItem.fromJson(Map<String, dynamic> json) {
    cmpnyExId = json['CmpnyExId'];
    expCatid = json['ExpCatid'];
    fromAccount = json['from_account'];
    tothePerson = json['TothePerson'];
    amount = json['Amount'];
    trnDate = json['TrnDate'];
    company = json['company'];
    remarks = json['Remarks'];
    fromAccountPerson = json['from_account_person'];
    toAccountPerson = json['to_account_person'];
    expCatName = json['ExpCatName'];
    staffName = json['staff_name'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CmpnyExId'] = cmpnyExId;
    data['ExpCatid'] = expCatid;
    data['from_account'] = fromAccount;
    data['TothePerson'] = tothePerson;
    data['Amount'] = amount;
    data['TrnDate'] = trnDate;
    data['company'] = company;
    data['Remarks'] = remarks;
    data['from_account_person'] = fromAccountPerson;
    data['to_account_person'] = toAccountPerson;
    data['ExpCatName'] = expCatName;
    data['staff_name'] = staffName;
    data['created_at'] = createdAt;
    return data;
  }
}