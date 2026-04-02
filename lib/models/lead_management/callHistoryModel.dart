class CallHistoryModel {
  Data? data;
  bool? status;
  String? message;

  CallHistoryModel({this.data, this.status, this.message});

  CallHistoryModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  List<StaffList>? staffList;
  List<CallHistory>? callHistory;
  List<PhoneCallLog>? phoneCallLog;
  List<FollowupHistory>? followupHistory;

  Data(
      {this.staffList,
        this.callHistory,
        this.phoneCallLog,
        this.followupHistory});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['staff_list'] != null) {
      staffList = <StaffList>[];
      json['staff_list'].forEach((v) {
        staffList!.add(StaffList.fromJson(v));
      });
    }
    if (json['callHistory'] != null) {
      callHistory = <CallHistory>[];
      json['callHistory'].forEach((v) {
        callHistory!.add(CallHistory.fromJson(v));
      });
    }
    if (json['phoneCallLog'] != null) {
      phoneCallLog = <PhoneCallLog>[];
      json['phoneCallLog'].forEach((v) {
        phoneCallLog!.add(PhoneCallLog.fromJson(v));
      });
    }
    if (json['followupHistory'] != null) {
      followupHistory = <FollowupHistory>[];
      json['followupHistory'].forEach((v) {
        followupHistory!.add(FollowupHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (staffList != null) {
      data['staff_list'] = staffList!.map((v) => v.toJson()).toList();
    }
    if (callHistory != null) {
      data['callHistory'] = callHistory!.map((v) => v.toJson()).toList();
    }
    if (phoneCallLog != null) {
      data['phoneCallLog'] = phoneCallLog!.map((v) => v.toJson()).toList();
    }
    if (followupHistory != null) {
      data['followupHistory'] =
          followupHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StaffList {
  String? userId;
  String? staffName;

  StaffList({this.userId, this.staffName});

  StaffList.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    staffName = json['staff_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['staff_name'] = staffName;
    return data;
  }
}

class CallHistory {
  String? date;
  List<History>? history;

  CallHistory({this.date, this.history});

  CallHistory.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    if (json['history'] != null) {
      history = <History>[];
      json['history'].forEach((v) {
        history!.add(History.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    if (history != null) {
      data['history'] = history!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class History {
  String? leadCategory;
  String? clientName;
  String? callResult;
  String? callMasterId;
  String? callHistoryImage;
  String? sourceNumber;
  String? destinationNumber;
  String? calledDate;
  String? calledTime;
  String? time;
  String? startTime;
  String? endTime;
  int? callDuration;
  String? callDurationHr;
  String? resourceURL;
  String? status;
  bool? isAttended;
  String? direction;
  bool? isplayed;
  bool? audioplayed;
  int? currentpos;
  String? currentpostlabel;

  String? remarks;

  History(
      {this.leadCategory,
        this.clientName,
        this.callResult,
        this.callMasterId,
        this.callHistoryImage,
        this.sourceNumber,
        this.destinationNumber,
        this.calledDate,
        this.calledTime,
        this.time,
        this.startTime,
        this.endTime,
        this.callDuration,
        this.callDurationHr,
        this.resourceURL,
        this.status,
        this.isAttended,
        this.direction,
        this.isplayed,
        this.audioplayed,
        this.currentpos,
        this.currentpostlabel,
        this.remarks});

  History.fromJson(Map<String, dynamic> json) {
    leadCategory = json['lead_category'];
    clientName = json['client_name'];
    callResult = json['call_result'];
    callMasterId = json['call_master_id'];
    callHistoryImage = json['callHistoryImage'];
    sourceNumber = json['SourceNumber'];
    destinationNumber = json['DestinationNumber'];
    calledDate = json['called_date'];
    calledTime = json['calledTime'];
    time = json['time'];
    startTime = json['StartTime'];
    endTime = json['EndTime'];
    callDuration = json['CallDuration'];
    callDurationHr = json['CallDurationHr'];
    resourceURL = json['ResourceURL'];
    status = json['Status'];
    isAttended = json['isAttended'];
    direction = json['Direction'];
    isplayed = json['isplayed'];
    audioplayed = json['audioplayed'];
    currentpos = json['currentpos'];
    currentpostlabel = json['currentpostlabel'];
    remarks = json['remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lead_category'] = leadCategory;
    data['client_name'] = clientName;
    data['call_result'] = callResult;
    data['call_master_id'] = callMasterId;
    data['callHistoryImage'] = callHistoryImage;
    data['SourceNumber'] = sourceNumber;
    data['DestinationNumber'] = destinationNumber;
    data['called_date'] = calledDate;
    data['calledTime'] = calledTime;
    data['time'] = time;
    data['StartTime'] = startTime;
    data['EndTime'] = endTime;
    data['CallDuration'] = callDuration;
    data['CallDurationHr'] = callDurationHr;
    data['ResourceURL'] = resourceURL;
    data['Status'] = status;
    data['isAttended'] = isAttended;
    data['Direction'] = direction;
    data['isplayed'] = isplayed;
    data['audioplayed'] = audioplayed;
    data['currentpos'] = currentpos;
    data['currentpostlabel'] = currentpostlabel;
    data['remarks'] = remarks;
    return data;
  }

}

class PhoneCallLog {
  String? id;
  String? name;
  String? phoneNumber;
  String? callType;
  String? duration;
  String? simName;
  String? dateTime;
  String? userId;
  String? staffName;

  PhoneCallLog(
      {this.id,
        this.name,
        this.phoneNumber,
        this.callType,
        this.duration,
        this.simName,
        this.dateTime,
        this.userId,
        this.staffName});

  PhoneCallLog.fromJson(Map<String, dynamic> json) {
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

class FollowupHistory {
  String? callMasterId;
  String? clientName;
  String? contactNumber1;
  String? callDetailsId;
  String? scheduledDate;
  String? calledDate;
  String? calledTime;
  String? remarks;
  String? callResultId;
  String? callResult;
  String? staffName;
  String? proPicThumb;
  String? callResponseId;
  String? callResponse;
  String? reasonId;
  String? reason;
  String? voiceFile;
  bool? playVoicePermission;

  FollowupHistory(
      {this.callMasterId,
        this.clientName,
        this.contactNumber1,
        this.callDetailsId,
        this.scheduledDate,
        this.calledDate,
        this.calledTime,
        this.remarks,
        this.callResultId,
        this.callResult,
        this.staffName,
        this.proPicThumb,
        this.callResponseId,
        this.callResponse,
        this.reasonId,
        this.reason,
        this.voiceFile,
        this.playVoicePermission});

  FollowupHistory.fromJson(Map<String, dynamic> json) {
    callMasterId = json['call_master_id'];
    clientName = json['client_name'];
    contactNumber1 = json['contact_number1'];
    callDetailsId = json['call_details_id'];
    scheduledDate = json['scheduled_date'];
    calledDate = json['called_date'];
    calledTime = json['called_time'];
    remarks = json['remarks'];
    callResultId = json['call_result_id'];
    callResult = json['call_result'];
    staffName = json['staff_name'];
    proPicThumb = json['pro_pic_thumb'];
    callResponseId = json['call_response_id'];
    callResponse = json['call_response'];
    reasonId = json['reason_id'];
    reason = json['reason'];
    voiceFile = json['voiceFile'];
    playVoicePermission = json['playVoicePermission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['call_master_id'] = callMasterId;
    data['client_name'] = clientName;
    data['contact_number1'] = contactNumber1;
    data['call_details_id'] = callDetailsId;
    data['scheduled_date'] = scheduledDate;
    data['called_date'] = calledDate;
    data['called_time'] = calledTime;
    data['remarks'] = remarks;
    data['call_result_id'] = callResultId;
    data['call_result'] = callResult;
    data['staff_name'] = staffName;
    data['pro_pic_thumb'] = proPicThumb;
    data['call_response_id'] = callResponseId;
    data['call_response'] = callResponse;
    data['reason_id'] = reasonId;
    data['reason'] = reason;
    data['voiceFile'] = voiceFile;
    data['playVoicePermission'] = playVoicePermission;
    return data;
  }
}