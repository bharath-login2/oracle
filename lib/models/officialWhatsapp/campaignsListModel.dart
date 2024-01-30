class CampaignsListModel {
  List<Data>? data;
  bool? message;
  bool? status;

  CampaignsListModel({this.data, this.message, this.status});

  CampaignsListModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['status'] = this.status;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['group_id'] = this.groupId;
    data['profile_pic'] = this.profilePic;
    data['campaign_name'] = this.campaignName;
    data['campaign_id'] = this.campaignId;
    data['fromMe'] = this.fromMe;
    return data;
  }
}