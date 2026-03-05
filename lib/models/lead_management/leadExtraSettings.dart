
class LeadExtraSettingsResponse {
  final bool status;
  final String message;
  final LeadExtraSettingsData data;

  LeadExtraSettingsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LeadExtraSettingsResponse.fromJson(Map<String, dynamic> json) {
    return LeadExtraSettingsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: LeadExtraSettingsData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class LeadExtraSettingsData {
  final LeadSettings settings;
  final List<Reason> reasons;

  LeadExtraSettingsData({
    required this.settings,
    required this.reasons,
  });

  factory LeadExtraSettingsData.fromJson(Map<String, dynamic> json) {
    return LeadExtraSettingsData(
      settings: LeadSettings.fromJson(json['settings']),
      reasons: (json['reasons'] as List<dynamic>?)
              ?.map((e) => Reason.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settings': settings.toJson(),
      'reasons': reasons.map((e) => e.toJson()).toList(),
    };
  }
}

class LeadSettings {
  final String id;
  final String stageId;
  final String stageType;
  final String isFollowupRequired;
  final String hasReason;
  final String isReasonRequired;
  final String isFinalStage;
  final String createInvoice;
  final String createCustomer;
  final String createRenewal;
  final String createInstallment;

  LeadSettings({
    required this.id,
    required this.stageId,
    required this.stageType,
    required this.isFollowupRequired,
    required this.hasReason,
    required this.isReasonRequired,
    required this.isFinalStage,
    required this.createInvoice,
    required this.createCustomer,
    required this.createRenewal,
    required this.createInstallment,
  });

  factory LeadSettings.fromJson(Map<String, dynamic> json) {
    return LeadSettings(
      id: json['id']?.toString() ?? '',
      stageId: json['stage_id']?.toString() ?? '',
      stageType: json['stage_type'] ?? '',
      isFollowupRequired: json['is_followup_required'] ?? '',
      hasReason: json['has_reason'] ?? '',
      isReasonRequired: json['is_reason_required'] ?? '',
      isFinalStage: json['is_final_stage'] ?? '',
      createInvoice: json['create_invoice'] ?? '',
      createCustomer: json['create_customer'] ?? '',
      createRenewal: json['create_renewal'] ?? '',
      createInstallment: json['create_installment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stage_id': stageId,
      'stage_type': stageType,
      'is_followup_required': isFollowupRequired,
      'has_reason': hasReason,
      'is_reason_required': isReasonRequired,
      'is_final_stage': isFinalStage,
      'create_invoice': createInvoice,
      'create_customer': createCustomer,
      'create_renewal': createRenewal,
      'create_installment': createInstallment,
    };
  }

  bool get isFollowupRequiredBool => isFollowupRequired == 'Y';
  bool get hasReasonBool => hasReason == 'Y';
  bool get isReasonRequiredBool => isReasonRequired == 'Y';
  bool get isFinalStageBool => isFinalStage == 'Y';
  bool get createInvoiceBool => createInvoice == 'Y';
  bool get createCustomerBool => createCustomer == 'Y';
  bool get createRenewalBool => createRenewal == 'Y';
  bool get createInstallmentBool => createInstallment == 'Y';
}

class Reason {
  final String id;
  final String callResultId;
  final String reason;

  Reason({
    required this.id,
    required this.callResultId,
    required this.reason,
  });

  factory Reason.fromJson(Map<String, dynamic> json) {
    return Reason(
      id: json['id']?.toString() ?? '',
      callResultId: json['call_result_id']?.toString() ?? '',
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'call_result_id': callResultId,
      'reason': reason,
    };
  }
}
