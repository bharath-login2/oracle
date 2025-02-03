class CampaignsListModel {
  List<Data>? data;
  bool? message;
  bool? status;

  CampaignsListModel({this.data, this.message, this.status});

  CampaignsListModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    data['status'] = status;
    return data;
  }
}

class Data {
  String? groupId;
  String? profilePic;
  String? campaignName;
  String? campaignId;
  bool? fromMe;

  Data(
      {this.groupId,
        this.profilePic,
        this.campaignName,
        this.campaignId,
        this.fromMe});

  Data.fromJson(Map<String, dynamic> json) {
    groupId = json['group_id'];
    profilePic = json['profile_pic'];
    campaignName = json['campaign_name'];
    campaignId = json['campaign_id'];
    fromMe = json['fromMe'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_id'] = groupId;
    data['profile_pic'] = profilePic;
    data['campaign_name'] = campaignName;
    data['campaign_id'] = campaignId;
    data['fromMe'] = fromMe;
    return data;
  }
}