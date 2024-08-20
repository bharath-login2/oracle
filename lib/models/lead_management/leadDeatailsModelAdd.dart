// To parse this JSON data, do
//
//     final leadDeatailsModelAdd = leadDeatailsModelAddFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

LeadDeatailsModelAdd leadDeatailsModelAddFromJson(String str) => LeadDeatailsModelAdd.fromJson(json.decode(str));

String leadDeatailsModelAddToJson(LeadDeatailsModelAdd data) => json.encode(data.toJson());

class LeadDeatailsModelAdd {
    Data data;
    bool status;
    String message;

    LeadDeatailsModelAdd({
        required this.data,
        required this.status,
        required this.message,
    });

    factory LeadDeatailsModelAdd.fromJson(Map<String, dynamic> json) => LeadDeatailsModelAdd(
        data: Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
        "message": message,
    };
}

class Data {
    bool voiceListerningPermission;
    bool voiceUploadPermission;
    bool createCustomerInvoice;
    bool createRenewal;
    bool createInstallment;
    bool isCreateOrder;
    String customerId;
    List<FollowUpDatum> followUpData;
    List<CallHistory> callHistory;
    List<Activity> activities;
    List<AdditionalField> additionalFields;

    Data({
        required this.voiceListerningPermission,
        required this.voiceUploadPermission,
        required this.createCustomerInvoice,
        required this.createRenewal,
        required this.createInstallment,
        required this.isCreateOrder,
        required this.customerId,
        required this.followUpData,
        required this.callHistory,
        required this.activities,
        required this.additionalFields,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        voiceListerningPermission: json["voiceListerningPermission"],
        voiceUploadPermission: json["voiceUploadPermission"],
        createCustomerInvoice: json["createCustomerInvoice"],
        createRenewal: json["createRenewal"],
        createInstallment: json["createInstallment"],
        isCreateOrder: json["isCreateOrder"],
        customerId: json["customer_id"],
        followUpData: List<FollowUpDatum>.from(json["followUpData"].map((x) => FollowUpDatum.fromJson(x))),
        callHistory: List<CallHistory>.from(json["callHistory"].map((x) => CallHistory.fromJson(x))),
        activities: List<Activity>.from(json["activities"].map((x) => Activity.fromJson(x))),
        additionalFields: List<AdditionalField>.from(json["additionalFields"].map((x) => AdditionalField.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "voiceListerningPermission": voiceListerningPermission,
        "voiceUploadPermission": voiceUploadPermission,
        "createCustomerInvoice": createCustomerInvoice,
        "createRenewal": createRenewal,
        "createInstallment": createInstallment,
        "isCreateOrder": isCreateOrder,
        "customer_id": customerId,
        "followUpData": List<dynamic>.from(followUpData.map((x) => x.toJson())),
        "callHistory": List<dynamic>.from(callHistory.map((x) => x.toJson())),
        "activities": List<dynamic>.from(activities.map((x) => x.toJson())),
        "additionalFields": List<dynamic>.from(additionalFields.map((x) => x)),
    };
}

class Activity {
    String remark;
    String createdTime;
    String staffName;
    String proPicThumb;

    Activity({
        required this.remark,
        required this.createdTime,
        required this.staffName,
        required this.proPicThumb,
    });

    factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        remark: json["remark"],
        createdTime: json["created_time"],
        staffName: json["staff_name"],
        proPicThumb: json["pro_pic_thumb"],
    );

    Map<String, dynamic> toJson() => {
        "remark": remark,
        "created_time": createdTime,
        "staff_name": staffName,
        "pro_pic_thumb": proPicThumb,
    };
}
class AdditionalField {
    String id;
    String name;
    String value;

    AdditionalField({
        required this.id,
        required this.name,
        required this.value,
    });

    factory AdditionalField.fromJson(Map<String, dynamic> json) => AdditionalField(
        id: json["id"],
        name: json["name"],
        value: json["value"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "value": value,
    };
}

class CallHistory {
    String id;
    String staffName;
    String callHistoryImage;
    String sourceNumber;
    String destinationNumber;
    String date;
    String startTime;
    String endTime;
    String time;
    int callDuration;
    String callDurationHr;
    String resourceUrl;
    String status;
    bool isAttended;
    String direction;
    bool isTransfered;
    bool isplayed;
    bool audioplayed;
    int currentpos;
    String currentpostlabel;

    CallHistory({
        required this.id,
        required this.staffName,
        required this.callHistoryImage,
        required this.sourceNumber,
        required this.destinationNumber,
        required this.date,
        required this.startTime,
        required this.endTime,
        required this.time,
        required this.callDuration,
        required this.callDurationHr,
        required this.resourceUrl,
        required this.status,
        required this.isAttended,
        required this.direction,
        required this.isTransfered,
        required this.isplayed,
        required this.audioplayed,
        required this.currentpos,
        required this.currentpostlabel,
    });

    factory CallHistory.fromJson(Map<String, dynamic> json) => CallHistory(
        id: json["id"],
        staffName: json["staffName"],
        callHistoryImage: json["callHistoryImage"],
        sourceNumber: json["SourceNumber"],
        destinationNumber: json["DestinationNumber"],
        date: json["date"],
        startTime: json["StartTime"],
        endTime: json["EndTime"],
        time: json["time"],
        callDuration: json["CallDuration"],
        callDurationHr: json["CallDurationHr"],
        resourceUrl: json["ResourceURL"],
        status: json["Status"],
        isAttended: json["isAttended"],
        direction: json["Direction"],
        isTransfered: json["isTransfered"],
        isplayed: json["isplayed"],
        audioplayed: json["audioplayed"],
        currentpos: json["currentpos"],
        currentpostlabel: json["currentpostlabel"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "staffName": staffName,
        "callHistoryImage": callHistoryImage,
        "SourceNumber": sourceNumber,
        "DestinationNumber": destinationNumber,
        "date": date,
        "StartTime": startTime,
        "EndTime": endTime,
        "time": time,
        "CallDuration": callDuration,
        "CallDurationHr": callDurationHr,
        "ResourceURL": resourceUrl,
        "Status": status,
        "isAttended": isAttended,
        "Direction": direction,
        "isTransfered": isTransfered,
        "isplayed": isplayed,
        "audioplayed": audioplayed,
        "currentpos": currentpos,
        "currentpostlabel": currentpostlabel,
    };
}


class FollowUpDatum {
    String callDetailsId;
    String scheduledDate;
    String date;
    String calledDate;
    String remarks;
    String callMasterId;
    String callResult;
    String staffName;
    String proPicThumb;
    String callStatusId;
    String callResultId;
    String callResponseId;
    String callResponse;
    String reasonId;
    String reason;
    bool isCalled;
    bool isEdit;
    bool isDelete;
    String dispalyDate;
    bool isSetReminder;
    bool isReminder;
    String time;
    String voiceFile;
    bool voiceUploadPermission;
    bool playVoicePermission;

    FollowUpDatum({
        required this.callDetailsId,
        required this.scheduledDate,
        required this.date,
        required this.calledDate,
        required this.remarks,
        required this.callMasterId,
        required this.callResult,
        required this.staffName,
        required this.proPicThumb,
        required this.callStatusId,
        required this.callResultId,
        required this.callResponseId,
        required this.callResponse,
        required this.reasonId,
        required this.reason,
        required this.isCalled,
        required this.isEdit,
        required this.isDelete,
        required this.dispalyDate,
        required this.isSetReminder,
        required this.isReminder,
        required this.time,
        required this.voiceFile,
        required this.voiceUploadPermission,
        required this.playVoicePermission,
    });

    factory FollowUpDatum.fromJson(Map<String, dynamic> json) => FollowUpDatum(
        callDetailsId: json["call_details_id"],
        scheduledDate: json["scheduled_date"],
        date: json["date"],
        calledDate: json["called_date"],
        remarks: json["remarks"],
        callMasterId: json["call_master_id"],
        callResult: json["call_result"],
        staffName: json["staff_name"],
        proPicThumb: json["pro_pic_thumb"],
        callStatusId: json["call_status_id"],
        callResultId: json["call_result_id"],
        callResponseId: json["call_response_id"],
        callResponse: json["call_response"],
        reasonId: json["reason_id"],
        reason: json["reason"],
        isCalled: json["is_called"],
        isEdit: json["is_edit"],
        isDelete: json["is_delete"],
        dispalyDate: json["dispaly_date"],
        isSetReminder: json["isSetReminder"],
        isReminder: json["isReminder"],
        time: json["time"],
        voiceFile: json["voice_file"],
        voiceUploadPermission: json["voiceUploadPermission"],
        playVoicePermission: json["playVoicePermission"],
    );

    Map<String, dynamic> toJson() => {
        "call_details_id": callDetailsId,
        "scheduled_date": scheduledDate,
        "date": date,
        "called_date": calledDate,
        "remarks": remarks,
        "call_master_id": callMasterId,
        "call_result": callResult,
        "staff_name": staffName,
        "pro_pic_thumb": proPicThumb,
        "call_status_id": callStatusId,
        "call_result_id": callResultId,
        "call_response_id": callResponseId,
        "call_response": callResponse,
        "reason_id": reasonId,
        "reason": reason,
        "is_called": isCalled,
        "is_edit": isEdit,
        "is_delete": isDelete,
        "dispaly_date": dispalyDate,
        "isSetReminder": isSetReminder,
        "isReminder": isReminder,
        "time": time,
        "voice_file": voiceFile,
        "voiceUploadPermission": voiceUploadPermission,
        "playVoicePermission": playVoicePermission,
    };
}


