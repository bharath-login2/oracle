class ReceiptAddCommonDetailsModel {
  Data? data;
  bool? status;
  String? message;

  ReceiptAddCommonDetailsModel({this.data, this.status, this.message});

  ReceiptAddCommonDetailsModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  String? name;
  String? displayRecNumber;
  String? displayInvNumber;
  List<Staff>? staff;
  List<PaymentMethods>? paymentMethods;
  String? invoiceId;
  String? customerId;
  String? receiptNumber;
  String? totalAmount;
  String? amountDue;
  String? particulars;

  Data(
      {this.name,
        this.displayRecNumber,
        this.displayInvNumber,
        this.staff,
        this.paymentMethods,
        this.invoiceId,
        this.customerId,
        this.receiptNumber,
        this.totalAmount,
        this.amountDue,
        this.particulars});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    displayRecNumber = json['display_rec_number'];
    displayInvNumber = json['display_inv_number'];
    if (json['staff'] != null) {
      staff = <Staff>[];
      json['staff'].forEach((v) {
        staff!.add(Staff.fromJson(v));
      });
    }
    if (json['payment_methods'] != null) {
      paymentMethods = <PaymentMethods>[];
      json['payment_methods'].forEach((v) {
        paymentMethods!.add(PaymentMethods.fromJson(v));
      });
    }
    invoiceId = json['invoice_id'];
    customerId = json['customer_id'];
    receiptNumber = json['receipt_number'];
    totalAmount = json['total_amount'];
    amountDue = json['amount_due'];
    particulars = json['particulars'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['display_rec_number'] = displayRecNumber;
    data['display_inv_number'] = displayInvNumber;
    if (staff != null) {
      data['staff'] = staff!.map((v) => v.toJson()).toList();
    }
    if (paymentMethods != null) {
      data['payment_methods'] =
          paymentMethods!.map((v) => v.toJson()).toList();
    }
    data['invoice_id'] = invoiceId;
    data['customer_id'] = customerId;
    data['receipt_number'] = receiptNumber;
    data['total_amount'] = totalAmount;
    data['amount_due'] = amountDue;
    data['particulars'] = particulars;
    return data;
  }
}

class Staff {
  String? userId;
  String? staffName;

  Staff({this.userId, this.staffName});

  Staff.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    staffName = json['staff_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['staff_name'] = staffName;
    return data;
  }
}

class PaymentMethods {
  String? id;
  String? name;

  PaymentMethods({this.id, this.name});

  PaymentMethods.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}