class LeadMileStoneListModel {
  bool? status;
  String? message;
  Data? data;

  LeadMileStoneListModel({this.status, this.message, this.data});

  LeadMileStoneListModel.fromJson(Map<String, dynamic> json) {
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
  List<Milestones>? milestones;
  List<LeadMilestones>? leadMilestones;

  Data({this.milestones, this.leadMilestones});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['milestones'] != null) {
      milestones = <Milestones>[];
      json['milestones'].forEach((v) {
        milestones!.add(Milestones.fromJson(v));
      });
    }
    if (json['leadMilestones'] != null) {
      leadMilestones = <LeadMilestones>[];
      json['leadMilestones'].forEach((v) {
        leadMilestones!.add(LeadMilestones.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (milestones != null) {
      data['milestones'] = milestones!.map((v) => v.toJson()).toList();
    }
    if (leadMilestones != null) {
      data['leadMilestones'] =
          leadMilestones!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Milestones {
  String? milestoneId;
  String? milestone;
  bool? isChecked;

  Milestones({this.milestoneId, this.milestone, this.isChecked});

  Milestones.fromJson(Map<String, dynamic> json) {
    milestoneId = json['milestone_id'];
    milestone = json['milestone'];
    isChecked = json['is_checked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['milestone_id'] = milestoneId;
    data['milestone'] = milestone;
    data['is_checked'] = isChecked;
    return data;
  }
}

class LeadMilestones {
  String? milestoneId;
  String? milestone;
  String? userId;
  String? remarks;
  String? dateTime;
  List<UserData>? userData;

  LeadMilestones(
      {this.milestoneId,
        this.milestone,
        this.userId,
        this.remarks,
        this.dateTime,
        this.userData});

  LeadMilestones.fromJson(Map<String, dynamic> json) {
    milestoneId = json['milestone_id'];
    milestone = json['milestone'];
    userId = json['user_id'];
    remarks = json['remarks'];
    dateTime = json['date_time'];
    if (json['userData'] != null) {
      userData = <UserData>[];
      json['userData'].forEach((v) {
        userData!.add(UserData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['milestone_id'] = milestoneId;
    data['milestone'] = milestone;
    data['user_id'] = userId;
    data['remarks'] = remarks;
    data['date_time'] = dateTime;
    if (userData != null) {
      data['userData'] = userData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserData {
  String? staffId;
  String? staffName;

  UserData({this.staffId, this.staffName});

  UserData.fromJson(Map<String, dynamic> json) {
    staffId = json['staff_id'];
    staffName = json['staff_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['staff_id'] = staffId;
    data['staff_name'] = staffName;
    return data;
  }
}