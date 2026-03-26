class CallLogHistoryModel {
  bool? status;
  String? message;
  Data? data;

  CallLogHistoryModel({this.status, this.message, this.data});

  CallLogHistoryModel.fromJson(Map<String, dynamic> json) {
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
  List<CallLogData>? lists;
  String? totalDuration;

  Data({this.lists, this.totalDuration});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['lists'] != null) {
      lists = <CallLogData>[];
      json['lists'].forEach((v) {
        lists!.add(CallLogData.fromJson(v));
      });
    }
    totalDuration = json['total_duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lists != null) {
      data['lists'] = lists!.map((v) => v.toJson()).toList();
    }
    data['total_duration'] = totalDuration;
    return data;
  }
}

class CallLogData {
  String? id;
  String? name;
  String? phoneNumber;
  String? callType;
  String? duration;
  String? simName;
  String? dateTime;
  String? userId;
  String? staffName;
  String? isMannual;

  CallLogData(
      {this.id,
      this.name,
      this.phoneNumber,
      this.callType,
      this.duration,
      this.simName,
      this.dateTime,
      this.userId,
      this.staffName,
      this.isMannual});

  CallLogData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    phoneNumber = json['phone_number'];
    callType = json['callType'];
    duration = json['duration'];
    simName = json['SimName'];
    dateTime = json['date_time'];
    userId = json['user_id'];
    staffName = json['staff_name'];
    isMannual = json['is_mannual']?.toString();
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
    data['is_mannual'] = isMannual;
    return data;
  }
}
