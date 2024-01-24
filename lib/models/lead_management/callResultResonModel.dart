class CallResultResonModel {
  List<Data>? data;
  bool? status;
  String? message;

  CallResultResonModel({this.data, this.status, this.message});

  CallResultResonModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? reason;

  Data({this.id, this.reason});

  Data.fromJson(Map<String, dynamic> json) {
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