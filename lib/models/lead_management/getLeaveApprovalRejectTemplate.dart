class GetLeaveApprovalRejectTemplate {
  bool? status;
  String? message;
  List<TemplateData>? data;

  GetLeaveApprovalRejectTemplate({
    this.status,
    this.message,
    this.data,
  });

  GetLeaveApprovalRejectTemplate.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <TemplateData>[];
      json['data'].forEach((v) {
        data!.add(TemplateData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TemplateData {
  String? id;
  String? templateType;
  String? templateName;
  String? templateBody;
  String? createdAt;
  String? companyId;
  String? createdBy;
  String? updatedBy;
  String? updatedAt;
  String? deletedBy;
  String? deletedAt;
  String? isDeleted;

  TemplateData({
    this.id,
    this.templateType,
    this.templateName,
    this.templateBody,
    this.createdAt,
    this.companyId,
    this.createdBy,
    this.updatedBy,
    this.updatedAt,
    this.deletedBy,
    this.deletedAt,
    this.isDeleted,
  });

  TemplateData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    templateType = json['template_type'];
    templateName = json['template_name'];
    templateBody = json['template_body'];
    createdAt = json['created_at'];
    companyId = json['company_id']?.toString();
    createdBy = json['created_by']?.toString();
    updatedBy = json['updated_by']?.toString();
    updatedAt = json['updated_at'];
    deletedBy = json['deleted_by']?.toString();
    deletedAt = json['deleted_at'];
    isDeleted = json['is_deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['template_type'] = templateType;
    data['template_name'] = templateName;
    data['template_body'] = templateBody;
    data['created_at'] = createdAt;
    data['company_id'] = companyId;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    data['updated_at'] = updatedAt;
    data['deleted_by'] = deletedBy;
    data['deleted_at'] = deletedAt;
    data['is_deleted'] = isDeleted;
    return data;
  }
}
