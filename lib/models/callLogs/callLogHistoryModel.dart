class CallLogHistoryModel {
  bool? status;
  String? message;
  List<Data>? data;

  CallLogHistoryModel({this.status, this.message, this.data});

  CallLogHistoryModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? name;
  String? phoneNumber;
  String? callType;
  String? duration;
  String? simName;
  String? dateTime;
  String? userId;
  String? staffName;

  Data(
      {this.id,
        this.name,
        this.phoneNumber,
        this.callType,
        this.duration,
        this.simName,
        this.dateTime,
        this.userId,
        this.staffName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phoneNumber = json['phone_number'];
    callType = json['callType'];
    duration = json['duration'];
    simName = json['SimName'];
    dateTime = json['date_time'];
    userId = json['user_id'];
    staffName = json['staff_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone_number'] = phoneNumber;
    data['callType'] = callType;
    data['duration'] = duration;
    data['SimName'] = simName;
    data['date_time'] = dateTime;
    data['user_id'] = userId;
    data['staff_name'] = staffName;
    return data;
  }
}