class ViewLeadCategoryModel {
  bool? status;
  String? message;
  List<Data>? data;

  ViewLeadCategoryModel({this.status, this.message, this.data});

  ViewLeadCategoryModel.fromJson(Map<String, dynamic> json) {
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
  String? leadCategoryId;
  String? leadCategory;

  Data({this.leadCategoryId, this.leadCategory});

  Data.fromJson(Map<String, dynamic> json) {
    leadCategoryId = json['lead_category_id'];
    leadCategory = json['lead_category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lead_category_id'] = leadCategoryId;
    data['lead_category'] = leadCategory;
    return data;
  }
}