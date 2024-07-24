// To parse this JSON data, do
//
//     final campaignEditModel = campaignEditModelFromJson(jsonString);

import 'dart:convert';

CampaignSampleModel campaignSampleModelFromJson(String str) => CampaignSampleModel.fromJson(json.decode(str));


class CampaignSampleModel {
    String message;
    bool data;
    bool status;

    CampaignSampleModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory CampaignSampleModel.fromJson(Map<String, dynamic> json) => CampaignSampleModel(
        message: json["message"],
        data: json["data"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data,
        "status": status,
    };
}
