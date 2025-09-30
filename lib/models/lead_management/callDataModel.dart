class CallHistoryResponse {
  final Data? data;
  final bool? status;
  final String? message;

  CallHistoryResponse({this.data, this.status, this.message});

  factory CallHistoryResponse.fromJson(Map<String, dynamic> json) {
    return CallHistoryResponse(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      status: json['status'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "data": data?.toJson(),
      "status": status,
      "message": message,
    };
  }
}

class Data {
  final List<CallHistoryData>? callHistory;

  Data({this.callHistory});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      callHistory: json['callHistory'] != null
          ? List<CallHistoryData>.from(
              json['callHistory'].map((x) => CallHistoryData.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "callHistory": callHistory?.map((x) => x.toJson()).toList(),
    };
  }
}

class CallHistoryData {
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

    CallHistoryData({
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

    factory CallHistoryData.fromJson(Map<String, dynamic> json) => CallHistoryData(
        id: json["id"]??"",
        staffName: json["staffName"]??"",
        callHistoryImage: json["callHistoryImage"]??"",
        sourceNumber: json["SourceNumber"]??"",
        destinationNumber: json["DestinationNumber"]??"",
        date: json["date"]??"",
        startTime: json["StartTime"]??"",
        endTime: json["EndTime"]??"",
        time: json["time"]??"",
        callDuration: json["CallDuration"]??"",
        callDurationHr: json["CallDurationHr"]??"",
        resourceUrl: json["ResourceURL"]??"",
        status: json["Status"]??"",
        isAttended: json["isAttended"]??"",
        direction: json["Direction"]??"",
        isTransfered: json["isTransfered"]??"",
        isplayed: json["isplayed"]??"",
        audioplayed: json["audioplayed"]??"",
        currentpos: json["currentpos"]??"",
        currentpostlabel: json["currentpostlabel"]??"",
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
