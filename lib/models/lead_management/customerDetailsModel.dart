class CustomerDetailsModel {
  final String status;
  final String message;
  final List<CustomerData> data;

  CustomerDetailsModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CustomerDetailsModel.fromJson(Map<String, dynamic> json) {
    return CustomerDetailsModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => CustomerData.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class CustomerData {
  final String address;
  final String postOffice;
  final String pincode;
  final String nationality;
  final String state;
  final String district;

  CustomerData({
    required this.address,
    required this.postOffice,
    required this.pincode,
    required this.nationality,
    required this.state,
    required this.district,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      address: json['address'] ?? '',
      postOffice: json['post_office'] ?? '',
      pincode: json['pincode'] ?? '',
      nationality: json['nationality'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'post_office': postOffice,
      'pincode': pincode,
      'nationality': nationality,
      'state': state,
      'district': district,
    };
  }
}
