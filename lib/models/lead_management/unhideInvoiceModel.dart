class UnhideInvoiceModel {
  dynamic data;
  bool? status;
  String? message;

  UnhideInvoiceModel({this.data, this.status, this.message});

  UnhideInvoiceModel.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}