class ExpiredListModel {
  bool? status;
  String? message;
  Data? data;

  ExpiredListModel({this.status, this.message, this.data});

  ExpiredListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  int? draw;
  int? recordsTotal;
  int? recordsFiltered;
  List<ExpiredItem>? list;

  Data({this.draw, this.recordsTotal, this.recordsFiltered, this.list});

  Data.fromJson(Map<String, dynamic> json) {
    draw = json['draw'];
    recordsTotal = json['recordsTotal'];
    recordsFiltered = json['recordsFiltered'];
    if (json['list'] != null) {
      list = <ExpiredItem>[];
      json['list'].forEach((v) {
        list!.add(ExpiredItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['draw'] = draw;
    data['recordsTotal'] = recordsTotal;
    data['recordsFiltered'] = recordsFiltered;
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ExpiredItem {
  int? slNo;
  String? rentId;
  String? customerId;
  String? customerName;
  String? products;
  int? totalAmount;
  int? daysExpired;
  String? expiredLabel;

  ExpiredItem({
    this.slNo,
    this.rentId,
    this.customerId,
    this.customerName,
    this.products,
    this.totalAmount,
    this.daysExpired,
    this.expiredLabel,
  });

  ExpiredItem.fromJson(Map<String, dynamic> json) {
    slNo = json['sl_no'];
    rentId = json['rent_id'];
    customerId = json['customer_id'];
    customerName = json['customer_name'];
    products = json['products'];
    totalAmount = json['total_amount'];
    daysExpired = json['days_expired'];
    expiredLabel = json['expired_label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sl_no'] = slNo;
    data['rent_id'] = rentId;
    data['customer_id'] = customerId;
    data['customer_name'] = customerName;
    data['products'] = products;
    data['total_amount'] = totalAmount;
    data['days_expired'] = daysExpired;
    data['expired_label'] = expiredLabel;
    return data;
  }
}