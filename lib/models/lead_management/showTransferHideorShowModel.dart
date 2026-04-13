class ShowTransferHideOrShowModel {
  String? message;
  bool? data;
  bool? status;

  ShowTransferHideOrShowModel({
    this.message,
    this.data,
    this.status,
  });

  ShowTransferHideOrShowModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['data'] = this.data;
    data['status'] = status;
    return data;
  }
}
