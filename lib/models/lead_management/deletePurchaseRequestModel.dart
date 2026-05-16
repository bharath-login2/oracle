class DeletePurchaseRequestModel {
  bool? status;
  String? message;
  List<dynamic>? data;

  DeletePurchaseRequestModel({
    this.status,
    this.message,
    this.data,
  });

  DeletePurchaseRequestModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    data['data'] = this.data ?? [];
    return data;
  }
}