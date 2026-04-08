class GetLeadSourceModel {
  List<LeadSourceData>? data;
  bool? status;
  String? message;

  GetLeadSourceModel({
    this.data,
    this.status,
    this.message,
  });

  GetLeadSourceModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <LeadSourceData>[];
      json['data'].forEach((v) {
        data!.add(LeadSourceData.fromJson(v));
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

class LeadSourceData {
  String? leadSourceId;
  String? leadSource;

  LeadSourceData({
    this.leadSourceId,
    this.leadSource,
  });

  LeadSourceData.fromJson(Map<String, dynamic> json) {
    leadSourceId = json['lead_source_id']?.toString();
    leadSource = json['lead_source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lead_source_id'] = leadSourceId;
    data['lead_source'] = leadSource;
    return data;
  }
}
