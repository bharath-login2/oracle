class CommonSettingsModel {
  bool? status;
  String? message;
  Data? data;

  CommonSettingsModel({this.status, this.message, this.data});

  CommonSettingsModel.fromJson(Map<String, dynamic> json) {
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
  String? customerCareCall;
  String? customerCareWhatsapp;
  String? supportUrl;

  Data({this.customerCareCall, this.customerCareWhatsapp, this.supportUrl});

  Data.fromJson(Map<String, dynamic> json) {
    customerCareCall = json['customer_care_call'];
    customerCareWhatsapp = json['customer_care_whatsapp'];
    supportUrl = json['support_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customer_care_call'] = customerCareCall;
    data['customer_care_whatsapp'] = customerCareWhatsapp;
    data['support_url'] = supportUrl;
    return data;
  }
}