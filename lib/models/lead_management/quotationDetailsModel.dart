class QuotationTemplateDetailsModel {
  final String? status;
  final String? message;
  final TemplateData? data;

  QuotationTemplateDetailsModel({
    this.status,
    this.message,
    this.data,
  });

  factory QuotationTemplateDetailsModel.fromJson(Map<String, dynamic> json) {
    return QuotationTemplateDetailsModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? TemplateData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class TemplateData {
  final int? templateId;
  final String? templateName;
  final List<TemplateField>? fields;

  TemplateData({
    this.templateId,
    this.templateName,
    this.fields,
  });

  factory TemplateData.fromJson(Map<String, dynamic> json) {
    return TemplateData(
      templateId: json['template_id'],
      templateName: json['template_name'],
      fields: json['fields'] != null
          ? List<TemplateField>.from(
              json['fields'].map((x) => TemplateField.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template_id': templateId,
      'template_name': templateName,
      'fields': fields?.map((x) => x.toJson()).toList(),
    };
  }
}

class TemplateField {
  final int? fieldId;
  final String? fieldName;
  final bool? isRequired;
   String? fieldData;

  TemplateField({
    this.fieldId,
    this.fieldName,
    this.isRequired,
    this.fieldData,
  });

  factory TemplateField.fromJson(Map<String, dynamic> json) {
    return TemplateField(
      fieldId: json['field_id'],
      fieldName: json['field_name'],
      isRequired: json['isRequired'],
      fieldData: json['field_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field_id': fieldId,
      'field_name': fieldName,
      'isRequired': isRequired,
      'field_data': fieldData,
    };
  }
}
