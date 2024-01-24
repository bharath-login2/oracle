class WhatsappSettingsModel {
  bool? status;
  String? message;
  Data? data;

  WhatsappSettingsModel({this.status, this.message, this.data});

  WhatsappSettingsModel.fromJson(Map<String, dynamic> json) {
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
  Unofficial? unofficial;
  Official? official;

  Data({this.unofficial, this.official});

  Data.fromJson(Map<String, dynamic> json) {
    unofficial = json['unofficial'] != null
        ? Unofficial.fromJson(json['unofficial'])
        : null;
    official = json['official'] != null
        ? Official.fromJson(json['official'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (unofficial != null) {
      data['unofficial'] = unofficial!.toJson();
    }
    if (official != null) {
      data['official'] = official!.toJson();
    }
    return data;
  }
}

class Unofficial {
  String? acessToken;
  String? phone;
  String? instanceId;
  String? qrCodeInstanceId;
  String? qrCodeData;

  Unofficial(
      {this.acessToken,
        this.phone,
        this.instanceId,
        this.qrCodeInstanceId,
        this.qrCodeData});

  Unofficial.fromJson(Map<String, dynamic> json) {
    acessToken = json['acess_token'];
    phone = json['phone'];
    instanceId = json['instance_id'];
    qrCodeInstanceId = json['qr_code_instance_id'];
    qrCodeData = json['qr_code_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['acess_token'] = acessToken;
    data['phone'] = phone;
    data['instance_id'] = instanceId;
    data['qr_code_instance_id'] = qrCodeInstanceId;
    data['qr_code_data'] = qrCodeData;
    return data;
  }
}

class Official {
  String? phoneNumberId;
  String? accountId;
  String? permanentToken;

  Official({this.phoneNumberId, this.accountId, this.permanentToken});

  Official.fromJson(Map<String, dynamic> json) {
    phoneNumberId = json['phone_number_id'];
    accountId = json['account_id'];
    permanentToken = json['permanent_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phone_number_id'] = phoneNumberId;
    data['account_id'] = accountId;
    data['permanent_token'] = permanentToken;
    return data;
  }
}