// To parse this JSON data, do
//
//     final staffCalldetailsModel = staffCalldetailsModelFromJson(jsonString);

import 'dart:convert';

StaffCalldetailsModel staffCalldetailsModelFromJson(String str) =>
    StaffCalldetailsModel.fromJson(json.decode(str));

String staffCalldetailsModelToJson(StaffCalldetailsModel data) =>
    json.encode(data.toJson());

class StaffCalldetailsModel {
  String message;
  Data data;
  bool status;

  StaffCalldetailsModel({
    required this.message,
    required this.data,
    required this.status,
  });

  factory StaffCalldetailsModel.fromJson(Map<String, dynamic> json) =>
      StaffCalldetailsModel(
        message: json["message"],
        data: Data.fromJson(json["data"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
        "status": status,
      };
}

class Data {
  CallDetails callDetails;
  List<CallCountByResponse> callCountByResponse;
  List<LeadStatusGraph> leadStatusGraph;
  List<String> leadCategory;
  int totalRowCount;
  List<LeadCategoryCount> leadCategoryCount;

  Data({
    required this.callDetails,
    required this.callCountByResponse,
    required this.leadStatusGraph,
    required this.leadCategory,
    required this.totalRowCount,
    required this.leadCategoryCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        callDetails: CallDetails.fromJson(json["callDetails"]),
        callCountByResponse: List<CallCountByResponse>.from(
            json["callCountByResponse"]
                .map((x) => CallCountByResponse.fromJson(x))),
        leadStatusGraph: List<LeadStatusGraph>.from(
            json["lead_status_graph"].map((x) => LeadStatusGraph.fromJson(x))),
        leadCategory: List<String>.from(json["lead_category"].map((x) => x)),
        totalRowCount: json["total_row_count"] ?? 0,
        leadCategoryCount: List<LeadCategoryCount>.from(
            json["lead_category_count"]
                .map((x) => LeadCategoryCount.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "callDetails": callDetails.toJson(),
        "callCountByResponse":
            List<dynamic>.from(callCountByResponse.map((x) => x.toJson())),
        "lead_status_graph":
            List<dynamic>.from(leadStatusGraph.map((x) => x.toJson())),
        "lead_category": List<dynamic>.from(leadCategory.map((x) => x)),
        "total_row_count": totalRowCount,
        "lead_category_count":
            List<dynamic>.from(leadCategoryCount.map((x) => x.toJson())),
      };
}

class CallCountByResponse {
  String resCount;
  String callResponseId;
  String callResponse;
  String resPercentage;

  CallCountByResponse({
    required this.resCount,
    required this.callResponseId,
    required this.callResponse,
    required this.resPercentage,
  });

  factory CallCountByResponse.fromJson(Map<String, dynamic> json) =>
      CallCountByResponse(
        resCount: json["res_count"],
        callResponseId: json["call_response_id"],
        callResponse: json["call_response"],
        resPercentage: json["resPercentage"],
      );

  Map<String, dynamic> toJson() => {
        "res_count": resCount,
        "call_response_id": callResponseId,
        "call_response": callResponse,
        "resPercentage": resPercentage,
      };
}

class CallDetails {
  String totDuration;
  String phoneCallDuration;
  int closedCalls;
  String totalCost;

  CallDetails({
    required this.totDuration,
    required this.phoneCallDuration,
    required this.closedCalls,
    required this.totalCost,
  });

  factory CallDetails.fromJson(Map<String, dynamic> json) => CallDetails(
        totDuration: json["tot_duration"],
        phoneCallDuration: json["phone_call_duration"],
        closedCalls: json["closedCalls"],
        totalCost: json["totalCost"],
      );

  Map<String, dynamic> toJson() => {
        "tot_duration": totDuration,
        "phone_call_duration": phoneCallDuration,
        "closedCalls": closedCalls,
        "totalCost": totalCost,
      };
}

class LeadCategoryCount {
  String? leadCategory;
  String? the1Count;
  String? the2Count;
  String? the3Count;
  String? the4Count;
  String? the5Count;
  String? the6Count;
  String? the7Count;
  String? the8Count;
  String? the9Count;
  String? the10Count;

  LeadCategoryCount({
    this.leadCategory,
    this.the1Count,
    this.the2Count,
    this.the3Count,
    this.the4Count,
    this.the5Count,
    this.the6Count,
    this.the7Count,
    this.the8Count,
    this.the9Count,
    this.the10Count,
  });

  factory LeadCategoryCount.fromJson(Map<String, dynamic> json) =>
      LeadCategoryCount(
        leadCategory: json["lead_category"],
        the1Count: json["1_count"],
        the2Count: json["2_count"],
        the3Count: json["3_count"],
        the4Count: json["4_count"],
        the5Count: json["5_count"],
        the6Count: json["6_count"],
        the7Count: json["7_count"],
        the8Count: json["8_count"],
        the9Count: json["9_count"],
        the10Count: json["10_count"],
      );

  Map<String, dynamic> toJson() => {
        "lead_category": leadCategory,
        "1_count": the1Count,
        "2_count": the2Count,
        "3_count": the3Count,
        "4_count": the4Count,
        "5_count": the5Count,
      };
}

class LeadStatusGraph {
  int resCount;
  String callResultId;
  String callResult;

  LeadStatusGraph({
    required this.resCount,
    required this.callResultId,
    required this.callResult,
  });

  factory LeadStatusGraph.fromJson(Map<String, dynamic> json) =>
      LeadStatusGraph(
        resCount: json["res_count"],
        callResultId: json["call_result_id"],
        callResult: json["call_result"],
      );

  Map<String, dynamic> toJson() => {
        "res_count": resCount,
        "call_result_id": callResultId,
        "call_result": callResult,
      };
}
