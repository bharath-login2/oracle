class EditLeadModel {
  bool? status;
  String? message;
  bool? data;

  EditLeadModel({this.status, this.message, this.data});

  EditLeadModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['data'] = this.data;
    return data;
  }
}