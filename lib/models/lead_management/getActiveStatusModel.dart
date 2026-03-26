class GetActiveStatusModel {
  List<CallResult>? data;
  bool? status;
  String? message;

  GetActiveStatusModel({this.data, this.status, this.message});

  GetActiveStatusModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <CallResult>[];
      json['data'].forEach((v) {
        data!.add(CallResult.fromJson(v));
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

class CallResult {
  String? callResultId;
  String? callResult;

  CallResult({this.callResultId, this.callResult});

  CallResult.fromJson(Map<String, dynamic> json) {
    callResultId = json['call_result_id']?.toString();
    callResult = json['call_result'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['call_result_id'] = callResultId;
    data['call_result'] = callResult;
    return data;
  }
}
