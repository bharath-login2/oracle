class UnitResponse {
  bool? status;
  String? message;
  List<UnitData>? data;

  UnitResponse({
    this.status,
    this.message,
    this.data,
  });

  UnitResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <UnitData>[];
      json['data'].forEach((v) {
        data!.add(UnitData.fromJson(v));
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

class UnitData {
  String? id;
  String? unitName;

  UnitData({
    this.id,
    this.unitName,
  });

  UnitData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    unitName = json['unit_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['unit_name'] = unitName;
    return data;
  }
}