class LeadProgressbarModel {
  bool? status;
  String? message;
  Data? data;

  LeadProgressbarModel({this.status, this.message, this.data});

  LeadProgressbarModel.fromJson(Map<String, dynamic> json) {
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
  String? totalCount;
  List<StaffLeads>? staffLeads;
  List<MissedLeads>? missedLeads;
  List<CategoryLeads>? categoryLeads;
  List<StatusLeads>? statusLeads;

  Data(
      {this.totalCount,
        this.staffLeads,
        this.missedLeads,
        this.categoryLeads,
        this.statusLeads});

  Data.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    if (json['staff_leads'] != null) {
      staffLeads = <StaffLeads>[];
      json['staff_leads'].forEach((v) {
        staffLeads!.add(StaffLeads.fromJson(v));
      });
    }
    if (json['missed_leads'] != null) {
      missedLeads = <MissedLeads>[];
      json['missed_leads'].forEach((v) {
        missedLeads!.add(MissedLeads.fromJson(v));
      });
    }
    if (json['category_leads'] != null) {
      categoryLeads = <CategoryLeads>[];
      json['category_leads'].forEach((v) {
        categoryLeads!.add(CategoryLeads.fromJson(v));
      });
    }
    if (json['status_leads'] != null) {
      statusLeads = <StatusLeads>[];
      json['status_leads'].forEach((v) {
        statusLeads!.add(StatusLeads.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalCount'] = totalCount;
    if (staffLeads != null) {
      data['staff_leads'] = staffLeads!.map((v) => v.toJson()).toList();
    }
    if (missedLeads != null) {
      data['missed_leads'] = missedLeads!.map((v) => v.toJson()).toList();
    }
    if (categoryLeads != null) {
      data['category_leads'] =
          categoryLeads!.map((v) => v.toJson()).toList();
    }
    if (statusLeads != null) {
      data['status_leads'] = statusLeads!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StaffLeads {
  String? staffName;
  String? staffId;
  String? staffCount;
  String? staffPercentage;

  StaffLeads(
      {this.staffName, this.staffId, this.staffCount, this.staffPercentage});

  StaffLeads.fromJson(Map<String, dynamic> json) {
    staffName = json['staffName'];
    staffId = json['staffId'];
    staffCount = json['staffCount'];
    staffPercentage = json['staffPercentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['staffName'] = staffName;
    data['staffId'] = staffId;
    data['staffCount'] = staffCount;
    data['staffPercentage'] = staffPercentage;
    return data;
  }
}

class MissedLeads {
  String? missedstaffName;
  String? missedstaffId;
  String? missedstaffCount;
  String? missedstaffPercentage;

  MissedLeads(
      {this.missedstaffName,
        this.missedstaffId,
        this.missedstaffCount,
        this.missedstaffPercentage});

  MissedLeads.fromJson(Map<String, dynamic> json) {
    missedstaffName = json['missedstaffName'];
    missedstaffId = json['missedstaffId'];
    missedstaffCount = json['missedstaffCount'];
    missedstaffPercentage = json['missedstaffPercentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['missedstaffName'] = missedstaffName;
    data['missedstaffId'] = missedstaffId;
    data['missedstaffCount'] = missedstaffCount;
    data['missedstaffPercentage'] = missedstaffPercentage;
    return data;
  }
}

class CategoryLeads {
  String? categoryName;
  String? categoryId;
  String? categoryCount;
  String? categoryPercentage;

  CategoryLeads(
      {this.categoryName,
        this.categoryId,
        this.categoryCount,
        this.categoryPercentage});

  CategoryLeads.fromJson(Map<String, dynamic> json) {
    categoryName = json['categoryName'];
    categoryId = json['categoryId'];
    categoryCount = json['categoryCount'];
    categoryPercentage = json['categoryPercentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['categoryName'] = categoryName;
    data['categoryId'] = categoryId;
    data['categoryCount'] = categoryCount;
    data['categoryPercentage'] = categoryPercentage;
    return data;
  }
}

class StatusLeads {
  String? statusName;
  String? statusId;
  String? statusCount;
  String? statusPercentage;

  StatusLeads(
      {this.statusName,
        this.statusId,
        this.statusCount,
        this.statusPercentage});

  StatusLeads.fromJson(Map<String, dynamic> json) {
    statusName = json['statusName'];
    statusId = json['statusId'];
    statusCount = json['statusCount'];
    statusPercentage = json['statusPercentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusName'] = statusName;
    data['statusId'] = statusId;
    data['statusCount'] = statusCount;
    data['statusPercentage'] = statusPercentage;
    return data;
  }
}