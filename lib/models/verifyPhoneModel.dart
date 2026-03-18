class VerifyPhoneModel {
  bool? status;
  String? message;
  bool? data;

  VerifyPhoneModel({this.status, this.message, this.data});

  VerifyPhoneModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] is bool 
        ? json['status'] 
        : (json['status']?.toString().toLowerCase() == 'true' || json['status']?.toString().toLowerCase() == 'success' || json['status']?.toString() == '1');
    message = json['message']?.toString();
    data = json['data'] is bool 
        ? json['data'] 
        : (json['data']?.toString().toLowerCase() == 'true' || json['data']?.toString().toLowerCase() == 'success' || json['data']?.toString() == '1');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['data'] = this.data;
    return data;
  }
}