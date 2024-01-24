class EditReceiptModelDetailsModel {
  Data? data;
  bool? status;
  String? message;

  EditReceiptModelDetailsModel({this.data, this.status, this.message});

  EditReceiptModelDetailsModel.fromJson(Map<String, dynamic> json) {
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
  String? receiptId;
  String? displayRecNumber;
  String? receiptNumber;
  String? displayInvNumber;
  String? receiptDate;
  String? collectedBy;
  String? paymentMethod;
  String? totalAmount;
  String? amountDue;
  String? paidAmount;
  String? checkAmount;
  String? clientName;
  String? uploadedImg;
  String? particulars;
  List<Staff>? staff;
  List<PaymentMethods>? paymentMethods;

  Data(
      {this.receiptId,
        this.displayRecNumber,
        this.receiptNumber,
        this.displayInvNumber,
        this.receiptDate,
        this.collectedBy,
        this.paymentMethod,
        this.totalAmount,
        this.amountDue,
        this.paidAmount,
        this.checkAmount,
        this.clientName,
        this.uploadedImg,
        this.particulars,
        this.staff,
        this.paymentMethods});

  Data.fromJson(Map<String, dynamic> json) {
    receiptId = json['receipt_id'];
    displayRecNumber = json['display_rec_number'];
    receiptNumber = json['receipt_number'];
    displayInvNumber = json['display_inv_number'];
    receiptDate = json['receipt_date'];
    collectedBy = json['collected_by'];
    paymentMethod = json['payment_method'];
    totalAmount = json['total_amount'];
    amountDue = json['amount_due'];
    paidAmount = json['paid_amount'];
    checkAmount = json['check_amount'];
    clientName = json['client_name'];
    uploadedImg = json['uploaded_img'];
    particulars = json['particulars'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['receipt_id'] = receiptId;
    data['display_rec_number'] = displayRecNumber;
    data['receipt_number'] = receiptNumber;
    data['display_inv_number'] = displayInvNumber;
    data['receipt_date'] = receiptDate;
    data['collected_by'] = collectedBy;
    data['payment_method'] = paymentMethod;
    data['total_amount'] = totalAmount;
    data['amount_due'] = amountDue;
    data['paid_amount'] = paidAmount;
    data['check_amount'] = checkAmount;
    data['client_name'] = clientName;
    data['uploaded_img'] = uploadedImg;
    data['particulars'] = particulars;
    if (staff != null) {
      data['staff'] = staff!.map((v) => v.toJson()).toList();
    }
    if (paymentMethods != null) {
      data['payment_methods'] =
          paymentMethods!.map((v) => v.toJson()).toList();
    }
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