class CustomerListModel {
  List<Customer>? data;
  bool? status;
  String? message;

  CustomerListModel({this.data, this.status, this.message});

  CustomerListModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Customer>[];
      json['data'].forEach((v) {
        data!.add(Customer.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Customer {
  String? id;
  String? name;
  String? contactNo;
  String? address;
  String? address2;
  String? address3;
  String? pincode;
  String? gstNum;

  Customer(
      {this.id,
      this.name,
      this.contactNo,
      this.address,
      this.address2,
      this.address3,
      this.pincode,
      this.gstNum});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    contactNo = json['contact_no'];
    address = json['address'];
    address2 = json['address2'];
    address3 = json['address3'];
    pincode = json['pincode'];
    gstNum = json['gst_num'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['contact_no'] = contactNo;
    data['address'] = address;
    data['address2'] = address2;
    data['address3'] = address3;
    data['pincode'] = pincode;
    data['gst_num'] = gstNum;
    return data;
  }
}
