class GetLeaveBalanceModel {
  final bool status;
  final LeaveBalanceData data;

  GetLeaveBalanceModel({
    required this.status,
    required this.data,
  });

  factory GetLeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return GetLeaveBalanceModel(
      status: json['status'] ?? false,
      data: LeaveBalanceData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

class LeaveBalanceData {
  final LeaveType casual;
  final LeaveType saturday;

  LeaveBalanceData({
    required this.casual,
    required this.saturday,
  });

  factory LeaveBalanceData.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceData(
      casual: LeaveType.fromJson(json['casual'] ?? {}),
      saturday: LeaveType.fromJson(json['saturday'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'casual': casual.toJson(),
      'saturday': saturday.toJson(),
    };
  }
}

class LeaveType {
  final int allowed;
  final int taken;
  final int balance;

  LeaveType({
    required this.allowed,
    required this.taken,
    required this.balance,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      allowed: json['allowed'] ?? 0,
      taken: json['taken'] ?? 0,
      balance: json['balance'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowed': allowed,
      'taken': taken,
      'balance': balance,
    };
  }
}
