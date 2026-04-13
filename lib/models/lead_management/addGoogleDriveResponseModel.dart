class AddGoogleDriveResponseModel {
  bool? status;
  String? authUrl;

  AddGoogleDriveResponseModel({
    this.status,
    this.authUrl,
  });

  AddGoogleDriveResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    authUrl = json['auth_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['auth_url'] = authUrl;
    return data;
  }
}
