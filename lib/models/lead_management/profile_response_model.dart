class ProfileResponseModel {
  bool? status;
  String? message;
  ProfileData? data;

  ProfileResponseModel({
    this.status,
    this.message,
    this.data,
  });

  ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? ProfileData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ProfileData {
  String? staffName;
  String? email;
  String? address1;
  String? phoneNo;

  ProfileData({
    this.staffName,
    this.email,
    this.address1,
    this.phoneNo,
  });

  ProfileData.fromJson(Map<String, dynamic> json) {
    staffName = json['staff_name'];
    email = json['email'];
    address1 = json['address1'];
    phoneNo = json['phone_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['staff_name'] = staffName;
    data['email'] = email;
    data['address1'] = address1;
    data['phone_no'] = phoneNo;
    return data;
  }
}