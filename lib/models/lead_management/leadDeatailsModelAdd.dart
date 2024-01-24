class LeadDeatailsModelAdd {
  Data? data;
  bool? status;
  String? message;

  LeadDeatailsModelAdd({this.data, this.status, this.message});

  LeadDeatailsModelAdd.fromJson(Map<String, dynamic> json) {
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
  bool? voiceListerningPermission;
  bool? voiceUploadPermission;
  List<FollowUpData>? followUpData;
  List<CallHistory>? callHistory;
  List<Activities>? activities;
  List<AdditionalFields>? additionalFields;

  Data(
      {this.voiceListerningPermission,
        this.voiceUploadPermission,
        this.followUpData,
        this.callHistory,
        this.activities,
        this.additionalFields});

  Data.fromJson(Map<String, dynamic> json) {
    voiceListerningPermission = json['voiceListerningPermission'];
    voiceUploadPermission = json['voiceUploadPermission'];
    if (json['followUpData'] != null) {
      followUpData = <FollowUpData>[];
      json['followUpData'].forEach((v) {
        followUpData!.add(FollowUpData.fromJson(v));
      });
    }
    if (json['callHistory'] != null) {
      callHistory = <CallHistory>[];
      json['callHistory'].forEach((v) {
        callHistory!.add(CallHistory.fromJson(v));
      });
    }
    if (json['activities'] != null) {
      activities = <Activities>[];
      json['activities'].forEach((v) {
        activities!.add(Activities.fromJson(v));
      });
    }
    if (json['additionalFields'] != null) {
      additionalFields = <AdditionalFields>[];
      json['additionalFields'].forEach((v) {
        additionalFields!.add(AdditionalFields.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['voiceListerningPermission'] = voiceListerningPermission;
    data['voiceUploadPermission'] = voiceUploadPermission;
    if (followUpData != null) {
      data['followUpData'] = followUpData!.map((v) => v.toJson()).toList();
    }
    if (callHistory != null) {
      data['callHistory'] = callHistory!.map((v) => v.toJson()).toList();
    }
    if (activities != null) {
      data['activities'] = activities!.map((v) => v.toJson()).toList();
    }
    if (additionalFields != null) {
      data['additionalFields'] =
          additionalFields!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FollowUpData {
  String? callDetailsId;
  String? scheduledDate;
  String? date;
  String? calledDate;
  String? remarks;
  String? callMasterId;
  String? callResult;
  String? staffName;
  String? proPicThumb;
  String? callStatusId;
  String? callResultId;
  String? callResponseId;
  String? callResponse;
  bool? isCalled;
  bool? isEdit;
  bool? isDelete;
  String? dispalyDate;
  bool? isSetReminder;
  bool? isReminder;
  String? time;
  String? voiceFile;
  bool? voiceUploadPermission;
  bool? playVoicePermission;
  String? reason;
  String? reasonId;

  FollowUpData(
      {this.callDetailsId,
        this.scheduledDate,
        this.date,
        this.calledDate,
        this.remarks,
        this.callMasterId,
        this.callResult,
        this.staffName,
        this.proPicThumb,
        this.callStatusId,
        this.callResultId,
        this.callResponseId,
        this.callResponse,
        this.isCalled,
        this.isEdit,
        this.isDelete,
        this.dispalyDate,
        this.isSetReminder,
        this.isReminder,
        this.time,
        this.voiceFile,
        this.voiceUploadPermission,
        this.playVoicePermission,this.reason,this.reasonId});

  FollowUpData.fromJson(Map<String, dynamic> json) {
    callDetailsId = json['call_details_id'];
    scheduledDate = json['scheduled_date'];
    date = json['date'];
    calledDate = json['called_date'];
    remarks = json['remarks'];
    callMasterId = json['call_master_id'];
    callResult = json['call_result'];
    staffName = json['staff_name'];
    proPicThumb = json['pro_pic_thumb'];
    callStatusId = json['call_status_id'];
    callResultId = json['call_result_id'];
    callResponseId = json['call_response_id'];
    callResponse = json['call_response'];
    isCalled = json['is_called'];
    isEdit = json['is_edit'];
    isDelete = json['is_delete'];
    dispalyDate = json['dispaly_date'];
    isSetReminder = json['isSetReminder'];
    isReminder = json['isReminder'];
    time = json['time'];
    voiceFile = json['voice_file'];
    voiceUploadPermission = json['voiceUploadPermission'];
    playVoicePermission = json['playVoicePermission'];
    reason = json['reason'];
    reasonId = json['reason_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['call_details_id'] = callDetailsId;
    data['scheduled_date'] = scheduledDate;
    data['date'] = date;
    data['called_date'] = calledDate;
    data['remarks'] = remarks;
    data['call_master_id'] = callMasterId;
    data['call_result'] = callResult;
    data['staff_name'] = staffName;
    data['pro_pic_thumb'] = proPicThumb;
    data['call_status_id'] = callStatusId;
    data['call_result_id'] = callResultId;
    data['call_response_id'] = callResponseId;
    data['call_response'] = callResponse;
    data['is_called'] = isCalled;
    data['is_edit'] = isEdit;
    data['is_delete'] = isDelete;
    data['dispaly_date'] = dispalyDate;
    data['isSetReminder'] = isSetReminder;
    data['isReminder'] = isReminder;
    data['time'] = time;
    data['voice_file'] = voiceFile;
    data['voiceUploadPermission'] = voiceUploadPermission;
    data['playVoicePermission'] = playVoicePermission;
    data['reason'] = reason;
    data['reason_id'] = reasonId;
    return data;
  }
}

class CallHistory {
  String? id;
  String? staffName;
  String? callHistoryImage;
  String? sourceNumber;
  String? destinationNumber;
  String? date;
  String? startTime;
  String? endTime;
  String? time;
  int? callDuration;
  String? callDurationHr;
  String? resourceURL;
  String? status;
  bool? isAttended;
  String? direction;
  bool? isTransfered;
  bool? isplayed;
  bool? audioplayed;
  int? currentpos;
  String? currentpostlabel;

  CallHistory(
      {this.id,
        this.staffName,
        this.callHistoryImage,
        this.sourceNumber,
        this.destinationNumber,
        this.date,
        this.startTime,
        this.endTime,
        this.time,
        this.callDuration,
        this.callDurationHr,
        this.resourceURL,
        this.status,
        this.isAttended,
        this.direction,
        this.isTransfered,
        this.isplayed,
        this.audioplayed,
        this.currentpos,
        this.currentpostlabel});

  CallHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    staffName = json['staffName'];
    callHistoryImage = json['callHistoryImage'];
    sourceNumber = json['SourceNumber'];
    destinationNumber = json['DestinationNumber'];
    date = json['date'];
    startTime = json['StartTime'];
    endTime = json['EndTime'];
    time = json['time'];
    callDuration = json['CallDuration'];
    callDurationHr = json['CallDurationHr'];
    resourceURL = json['ResourceURL'];
    status = json['Status'];
    isAttended = json['isAttended'];
    direction = json['Direction'];
    isTransfered = json['isTransfered'];
    isplayed = json['isplayed'];
    audioplayed = json['audioplayed'];
    currentpos = json['currentpos'];
    currentpostlabel = json['currentpostlabel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['staffName'] = staffName;
    data['callHistoryImage'] = callHistoryImage;
    data['SourceNumber'] = sourceNumber;
    data['DestinationNumber'] = destinationNumber;
    data['date'] = date;
    data['StartTime'] = startTime;
    data['EndTime'] = endTime;
    data['time'] = time;
    data['CallDuration'] = callDuration;
    data['CallDurationHr'] = callDurationHr;
    data['ResourceURL'] = resourceURL;
    data['Status'] = status;
    data['isAttended'] = isAttended;
    data['Direction'] = direction;
    data['isTransfered'] = isTransfered;
    data['isplayed'] = isplayed;
    data['audioplayed'] = audioplayed;
    data['currentpos'] = currentpos;
    data['currentpostlabel'] = currentpostlabel;
    return data;
  }
}

class Activities {
  String? remark;
  String? createdTime;
  String? staffName;
  String? proPicThumb;

  Activities({this.remark, this.createdTime, this.staffName, this.proPicThumb});

  Activities.fromJson(Map<String, dynamic> json) {
    remark = json['remark'];
    createdTime = json['created_time'];
    staffName = json['staff_name'];
    proPicThumb = json['pro_pic_thumb'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['remark'] = remark;
    data['created_time'] = createdTime;
    data['staff_name'] = staffName;
    data['pro_pic_thumb'] = proPicThumb;
    return data;
  }
}

class AdditionalFields {
  String? id;
  String? name;
  String? value;

  AdditionalFields({this.id, this.name, this.value});

  AdditionalFields.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}