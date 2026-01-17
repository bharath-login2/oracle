class RentalDashboardModel {
  final bool status;
  final String message;
  final RentalDashboardData data;

  RentalDashboardModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RentalDashboardModel.fromJson(Map<String, dynamic> json) {
    return RentalDashboardModel(
      status: json['status'] as bool,
      message: json['message'] as String? ?? '',
      data: RentalDashboardData.fromJson(json['data'] as Map<String, dynamic>),
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
class RentalDashboardData {
  final String filterDate;
  final int rentIssued;
  final int rentReturned;
  final int pendingReturn;
  final int rentOverdue;
  final int todayPayment;
  final int todayCash;
  final int todayBank;
  final int overdueCount;
  final List<OverdueItem> overdueList;

  RentalDashboardData({
    required this.filterDate,
    required this.rentIssued,
    required this.rentReturned,
    required this.pendingReturn,
    required this.rentOverdue,
    required this.todayPayment,
    required this.todayCash,
    required this.todayBank,
    required this.overdueCount,
    required this.overdueList,
  });

  factory RentalDashboardData.fromJson(Map<String, dynamic> json) {
    return RentalDashboardData(
      filterDate: json['filter_date'] as String? ?? '',
      rentIssued: (json['rent_issued'] as num?)?.toInt() ?? 0,
      rentReturned: (json['rent_returned'] as num?)?.toInt() ?? 0,
      pendingReturn: (json['pending_return'] as num?)?.toInt() ?? 0,
      rentOverdue: (json['rent_overdue'] as num?)?.toInt() ?? 0,
      todayPayment: (json['today_payment'] as num?)?.toInt() ?? 0,
      todayCash: (json['today_cash'] as num?)?.toInt() ?? 0,
      todayBank: (json['today_bank'] as num?)?.toInt() ?? 0,
      overdueCount: (json['overdue_count'] as num?)?.toInt() ?? 0,
      overdueList: (json['overdue_list'] as List<dynamic>?)
              ?.map((item) => OverdueItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filter_date': filterDate,
      'rent_issued': rentIssued,
      'rent_returned': rentReturned,
      'pending_return': pendingReturn,
      'rent_overdue': rentOverdue,
      'today_payment': todayPayment,
      'today_cash': todayCash,
      'today_bank': todayBank,
      'overdue_count': overdueCount,
      'overdue_list': overdueList.map((item) => item.toJson()).toList(),
    };
  }
}
class OverdueItem {
  final String customerId;
  final String totalDays;
  final String toDate;
  final String grandTotal;
  final String name;

  OverdueItem({
    required this.customerId,
    required this.totalDays,
    required this.toDate,
    required this.grandTotal,
    required this.name,
  });

  factory OverdueItem.fromJson(Map<String, dynamic> json) {
    return OverdueItem(
      customerId: json['customer_id'] as String? ?? '',
      totalDays: json['total_days'] as String? ?? '',
      toDate: json['to_date'] as String? ?? '',
      grandTotal: json['grand_total'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'total_days': totalDays,
      'to_date': toDate,
      'grand_total': grandTotal,
      'name': name,
    };
  }
}