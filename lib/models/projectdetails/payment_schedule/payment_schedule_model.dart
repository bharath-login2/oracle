class PaymentScheduleResponse {
  final bool status;
  final String message;
  final PaymentScheduleData? data;

  PaymentScheduleResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory PaymentScheduleResponse.fromJson(Map<String, dynamic> json) {
    return PaymentScheduleResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? PaymentScheduleData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PaymentScheduleData {
  final List<PaymentScheduleRecord> records;
  final PaymentScheduleSummary summary;

  PaymentScheduleData({
    required this.records,
    required this.summary,
  });

  factory PaymentScheduleData.fromJson(Map<String, dynamic> json) {
    return PaymentScheduleData(
      records: (json['records'] as List<dynamic>? ?? [])
          .map((e) => PaymentScheduleRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] is Map<String, dynamic>
          ? PaymentScheduleSummary.fromJson(
              json['summary'] as Map<String, dynamic>)
          : PaymentScheduleSummary.empty(),
    );
  }
}

class PaymentScheduleRecord {
  final String id;
  final String projectId;
  final String clientId;
  final String unitNo;
  final String unitName;
  final String siteLiftNo;
  final String siteLiftName;
  final List<String> stageIds;
  final String stageNames;
  final String percentage;
  final String amount;
  final String scheduledAmount;
  final String deductionAmount;
  final String extraworkAmount;
  final String totalAmount;
  final String paidAmount;
  final String balanceAmount;
  final String paymentStatus;
  final String dueDate;
  final String dueDateRaw;
  final String isLocked;

  PaymentScheduleRecord({
    required this.id,
    required this.projectId,
    required this.clientId,
    required this.unitNo,
    required this.unitName,
    required this.siteLiftNo,
    required this.siteLiftName,
    required this.stageIds,
    required this.stageNames,
    required this.percentage,
    required this.amount,
    required this.scheduledAmount,
    required this.deductionAmount,
    required this.extraworkAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceAmount,
    required this.paymentStatus,
    required this.dueDate,
    required this.dueDateRaw,
    required this.isLocked,
  });

  bool get locked => isLocked.toUpperCase() == 'Y';

  factory PaymentScheduleRecord.fromJson(Map<String, dynamic> json) {
    String s(String key, [String fallback = '']) =>
        json[key]?.toString() ?? fallback;

    final rawStage = json['stage_id'];
    final List<String> stages = rawStage is List
        ? rawStage.map((e) => e.toString()).toList()
        : (rawStage == null || rawStage.toString().isEmpty
            ? <String>[]
            : <String>[rawStage.toString()]);

    return PaymentScheduleRecord(
      id: s('id'),
      projectId: s('project_id'),
      clientId: s('client_id'),
      unitNo: s('unit_no'),
      unitName: s('unit_name'),
      siteLiftNo: s('site_lift_no'),
      siteLiftName: s('site_lift_name'),
      stageIds: stages,
      stageNames: s('stage_names'),
      percentage: s('percentage', '0'),
      amount: s('amount', '0'),
      scheduledAmount: s('scheduled_amount', '0'),
      deductionAmount: s('deduction_amount', '0'),
      extraworkAmount: s('extrawork_amount', '0'),
      totalAmount: s('total_amount', '0'),
      paidAmount: s('paid_amount', '0'),
      balanceAmount: s('balance_amount', '0'),
      paymentStatus: s('payment_status'),
      dueDate: s('due_date'),
      dueDateRaw: s('due_date_raw'),
      isLocked: s('is_locked'),
    );
  }
}

class PaymentScheduleSummary {
  final String totalScheduledAmount;
  final String totalDeductionAmount;
  final String totalExtraworkAmount;
  final String totalAmount;
  final String totalPaidAmount;
  final String totalBalance;

  PaymentScheduleSummary({
    required this.totalScheduledAmount,
    required this.totalDeductionAmount,
    required this.totalExtraworkAmount,
    required this.totalAmount,
    required this.totalPaidAmount,
    required this.totalBalance,
  });

  factory PaymentScheduleSummary.empty() => PaymentScheduleSummary(
        totalScheduledAmount: '0.00',
        totalDeductionAmount: '0.00',
        totalExtraworkAmount: '0.00',
        totalAmount: '0.00',
        totalPaidAmount: '0.00',
        totalBalance: '0.00',
      );

  factory PaymentScheduleSummary.fromJson(Map<String, dynamic> json) {
    String s(String key) => json[key]?.toString() ?? '0.00';

    return PaymentScheduleSummary(
      totalScheduledAmount: s('total_scheduled_amount'),
      totalDeductionAmount: s('total_deduction_amount'),
      totalExtraworkAmount: s('total_extrawork_amount'),
      totalAmount: s('total_amount'),
      totalPaidAmount: s('total_paid_amount'),
      totalBalance: s('total_balance'),
    );
  }
}
