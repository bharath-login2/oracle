class LeadTransferModel {
  bool? status;
  String? message;
  bool? data;

  LeadTransferModel({this.status, this.message, this.data});

  LeadTransferModel.fromJson(Map<String, dynamic> json) {
    if (json['status'] is bool) {
      status = json['status'];
    } else if (json['status'] is String) {
      status = json['status'].toLowerCase() == 'true';
    } else {
      status = json['status'] != null && json['status'] != 0;
    }

    message = json['message']?.toString();

    if (json['data'] is bool) {
      data = json['data'];
    } else if (json['data'] is String) {
      data = json['data'].toLowerCase() == 'true';
    } else {
      data = json['data'] != null && json['data'] != 0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['data'] = this.data;
    return data;
  }
}