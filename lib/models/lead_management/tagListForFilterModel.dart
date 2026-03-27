class TagListForFilterModel {
  List<TagData>? data;
  bool? status;
  String? message;

  TagListForFilterModel({
    this.data,
    this.status,
    this.message,
  });

  TagListForFilterModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <TagData>[];
      json['data'].forEach((v) {
        data!.add(TagData.fromJson(v));
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

class TagData {
  String? id;
  String? reason;

  TagData({
    this.id,
    this.reason,
  });

  TagData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reason = json['reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['reason'] = reason;
    return data;
  }
}
