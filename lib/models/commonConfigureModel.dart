class CommonConfigureModel {
  bool? status;
  String? message;
  Data? data;

  CommonConfigureModel({this.status, this.message, this.data});

  CommonConfigureModel.fromJson(Map<String, dynamic> json) {
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
  bool? isExpired;
  bool? whatsappConfigured;
  String? supportTeamNumber;

  Data({this.isExpired, this.whatsappConfigured, this.supportTeamNumber});

  Data.fromJson(Map<String, dynamic> json) {
    isExpired = json['is_expired'];
    whatsappConfigured = json['whatsapp_configured'];
    supportTeamNumber = json['support_team_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_expired'] = isExpired;
    data['whatsapp_configured'] = whatsappConfigured;
    data['support_team_number'] = supportTeamNumber;
    return data;
  }
}