class LeadSubTypeModel {
  List<Data>? data;
  bool? status;
  String? message;

  LeadSubTypeModel({this.data, this.status, this.message});

  LeadSubTypeModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  String? leadSubCategoryId;
  String? leadSubCategory;

  Data({this.leadSubCategoryId, this.leadSubCategory});

  Data.fromJson(Map<String, dynamic> json) {
    leadSubCategoryId = json['lead_sub_category_id'];
    leadSubCategory = json['lead_sub_category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['lead_sub_category_id'] = leadSubCategoryId;
    data['lead_sub_category'] = leadSubCategory;
    return data;
  }
}