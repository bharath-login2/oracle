class GroupInfoModel {
  bool? status;
  String? message;
  Data? data;

  GroupInfoModel({this.status, this.message, this.data});

  GroupInfoModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? name;
  String? createdDate;
  String? image;
  String? contactNos;
  List<ContactNumbers>? contactNumbers;

  Data(
      {this.id,
        this.name,
        this.createdDate,
        this.image,
        this.contactNos,
        this.contactNumbers});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    createdDate = json['created_date'];
    image = json['image'];
    contactNos = json['contact_nos'];
    if (json['contact_numbers'] != null) {
      contactNumbers = <ContactNumbers>[];
      json['contact_numbers'].forEach((v) {
        contactNumbers!.add(ContactNumbers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['created_date'] = createdDate;
    data['image'] = image;
    data['contact_nos'] = contactNos;
    if (contactNumbers != null) {
      data['contact_numbers'] =
          contactNumbers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ContactNumbers {
  String? id;
  String? phone;

  ContactNumbers({this.id, this.phone});

  ContactNumbers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['phone'] = this.phone;
    return data;
  }
}