class ViewLeadSubCategoryModel {
  bool? status;
  String? message;
  List<Data>? data;

  ViewLeadSubCategoryModel({this.status, this.message, this.data});

  ViewLeadSubCategoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
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