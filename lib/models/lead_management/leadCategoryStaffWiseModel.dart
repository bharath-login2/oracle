class LeadCategoryStaffWiseModel {
  Data? data;
  bool? status;
  String? message;

  LeadCategoryStaffWiseModel({this.data, this.status, this.message});

  LeadCategoryStaffWiseModel.fromJson(Map<String, dynamic> json) {
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
  List<StaffLeads>? staffLeads;
  List<CategoryLeads>? categoryLeads;
  List<CategoryGraph>? categoryGraph;
  PreviousDiff? previousDiff;

  Data(
      {this.staffLeads,
        this.categoryLeads,
        this.categoryGraph,
        this.previousDiff});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['staff_leads'] != null) {
      staffLeads = <StaffLeads>[];
      json['staff_leads'].forEach((v) {
        staffLeads!.add(StaffLeads.fromJson(v));
      });
    }
    if (json['category_leads'] != null) {
      categoryLeads = <CategoryLeads>[];
      json['category_leads'].forEach((v) {
        categoryLeads!.add(CategoryLeads.fromJson(v));
      });
    }
    if (json['category_graph'] != null) {
      categoryGraph = <CategoryGraph>[];
      json['category_graph'].forEach((v) {
        categoryGraph!.add(CategoryGraph.fromJson(v));
      });
    }
    previousDiff = json['previous_diff'] != null
        ? PreviousDiff.fromJson(json['previous_diff'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (staffLeads != null) {
      data['staff_leads'] = staffLeads!.map((v) => v.toJson()).toList();
    }
    if (categoryLeads != null) {
      data['category_leads'] =
          categoryLeads!.map((v) => v.toJson()).toList();
    }
    if (categoryGraph != null) {
      data['category_graph'] =
          categoryGraph!.map((v) => v.toJson()).toList();
    }
    if (previousDiff != null) {
      data['previous_diff'] = previousDiff!.toJson();
    }
    return data;
  }
}

class StaffLeads {
  String? staffId;
  String? staffName;
  String? newCount;
  String? pendingCount;
  String? followupCount;
  String? rejectedCount;
  String? confirmedCount;
  String? staffCount;
  int? staffPercentage;

  StaffLeads(
      {this.staffId,
        this.staffName,
        this.newCount,
        this.pendingCount,
        this.followupCount,
        this.rejectedCount,
        this.confirmedCount,
        this.staffCount,
        this.staffPercentage});

  StaffLeads.fromJson(Map<String, dynamic> json) {
    staffId = json['staffId'];
    staffName = json['staffName'];
    newCount = json['newCount'];
    pendingCount = json['pendingCount'];
    followupCount = json['followupCount'];
    rejectedCount = json['rejectedCount'];
    confirmedCount = json['confirmedCount'];
    staffCount = json['staffCount'];
    staffPercentage = json['staffPercentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['staffId'] = staffId;
    data['staffName'] = staffName;
    data['newCount'] = newCount;
    data['pendingCount'] = pendingCount;
    data['followupCount'] = followupCount;
    data['rejectedCount'] = rejectedCount;
    data['confirmedCount'] = confirmedCount;
    data['staffCount'] = staffCount;
    data['staffPercentage'] = staffPercentage;
    return data;
  }
}

class CategoryLeads {
  String? categoryid;
  String? categoryName;
  String? newCount;
  String? pendingCount;
  String? followupCount;
  String? rejectedCount;
  String? confirmedCount;
  String? categoryCount;

  CategoryLeads(
      {this.categoryid,
        this.categoryName,
        this.newCount,
        this.pendingCount,
        this.followupCount,
        this.rejectedCount,
        this.confirmedCount,
        this.categoryCount});

  CategoryLeads.fromJson(Map<String, dynamic> json) {
    categoryid = json['categoryid'];
    categoryName = json['categoryName'];
    newCount = json['newCount'];
    pendingCount = json['pendingCount'];
    followupCount = json['followupCount'];
    rejectedCount = json['rejectedCount'];
    confirmedCount = json['confirmedCount'];
    categoryCount = json['categoryCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['categoryid'] = categoryid;
    data['categoryName'] = categoryName;
    data['newCount'] = newCount;
    data['pendingCount'] = pendingCount;
    data['followupCount'] = followupCount;
    data['rejectedCount'] = rejectedCount;
    data['confirmedCount'] = confirmedCount;
    data['categoryCount'] = categoryCount;
    return data;
  }
}

class CategoryGraph {
  String? categoryName;
  int? categoryCount;

  CategoryGraph({this.categoryName, this.categoryCount});

  CategoryGraph.fromJson(Map<String, dynamic> json) {
    categoryName = json['categoryName'];
    categoryCount = json['categoryCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['categoryName'] = categoryName;
    data['categoryCount'] = categoryCount;
    return data;
  }
}

class PreviousDiff {
  String? leadDifference;
  bool? isIncrement;

  PreviousDiff({this.leadDifference, this.isIncrement});

  PreviousDiff.fromJson(Map<String, dynamic> json) {
    leadDifference = json['lead_difference'];
    isIncrement = json['is_increment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lead_difference'] = leadDifference;
    data['is_increment'] = isIncrement;
    return data;
  }
}