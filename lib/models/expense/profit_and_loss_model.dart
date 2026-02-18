class ProfitAndLossModel {
  final bool? status;
  final String? message;
  final Data? data;

  ProfitAndLossModel({
    this.status,
    this.message,
    this.data,
  });

  factory ProfitAndLossModel.fromJson(Map<String, dynamic> json) {
    bool? statusValue;
    if (json['status'] != null) {
      if (json['status'] is String) {
        statusValue = json['status'].toLowerCase() == 'true';
      } else if (json['status'] is bool) {
        statusValue = json['status'];
      }
    }
    
    return ProfitAndLossModel(
      status: statusValue,
      message: json['message']?.toString(),
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status?.toString(),
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class Data {
  final List<ProfitLossItem>? list;
  final bool? manageProfitAndLoss;

  Data({
    this.list,
    this.manageProfitAndLoss,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    List<ProfitLossItem>? itemList;
    if (json['list'] != null) {
      if (json['list'] is List) {
        itemList = (json['list'] as List)
            .map((i) => ProfitLossItem.fromJson(i))
            .toList();
      } else if (json['list'] is Map) {
        itemList = [ProfitLossItem.fromJson(json['list'])];
      }
    }
    

    bool? manageProfitAndLossValue;
    if (json['manage_profit_and_loss'] != null) {
      if (json['manage_profit_and_loss'] is String) {
        manageProfitAndLossValue = json['manage_profit_and_loss'].toLowerCase() == 'true';
      } else if (json['manage_profit_and_loss'] is bool) {
        manageProfitAndLossValue = json['manage_profit_and_loss'];
      }
    }
    
    return Data(
      list: itemList,
      manageProfitAndLoss: manageProfitAndLossValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list?.map((e) => e.toJson()).toList(),
      'manage_profit_and_loss': manageProfitAndLoss?.toString(),
    };
  }
}

class ProfitLossItem {
  final String? id;
  final String? month;
  final String? year;
  final String? openingBalance;
  final String? receipt;
  final String? expense;
  final String? advance;
  final String? difference;
  final String? netExpense;
  final String? profitLoss;
  final String? closingBalance;
  final String? remark;
  final String? createdAt;
  final String? createdBy;
  final String? pettyCash;
  final String? totalAmount;
  final String? staffName;
  final String? type;

  ProfitLossItem({
    this.id,
    this.month,
    this.year,
    this.openingBalance,
    this.receipt,
    this.expense,
    this.advance,
    this.difference,
    this.netExpense,
    this.profitLoss,
    this.closingBalance,
    this.remark,
    this.createdAt,
    this.createdBy,
    this.pettyCash,
    this.totalAmount,
    this.staffName,
    this.type,
  });

  factory ProfitLossItem.fromJson(Map<String, dynamic> json) {
    return ProfitLossItem(
      id: json['id']?.toString(),
      month: json['month']?.toString(),
      year: json['year']?.toString(),
      openingBalance: json['opening_balance']?.toString(),
      receipt: json['receipt']?.toString(),
      expense: json['expense']?.toString(),
      advance: json['advance']?.toString(),
      difference: json['difference']?.toString(),
      netExpense: json['net_expense']?.toString(),
      profitLoss: json['profit_loss']?.toString(),
      closingBalance: json['closing_balance']?.toString(),
      remark: json['remark']?.toString(),
      createdAt: json['created_at']?.toString(),
      createdBy: json['created_by']?.toString(),
      pettyCash: json['petty_cash']?.toString(),
      totalAmount: json['total_amount']?.toString(),
      staffName: json['staff_name']?.toString(),
      type: json['type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'opening_balance': openingBalance,
      'receipt': receipt,
      'expense': expense,
      'advance': advance,
      'difference': difference,
      'net_expense': netExpense,
      'profit_loss': profitLoss,
      'closing_balance': closingBalance,
      'remark': remark,
      'created_at': createdAt,
      'created_by': createdBy,
      'petty_cash': pettyCash,
      'total_amount': totalAmount,
      'staff_name': staffName,
      'type': type,
    };
  }
}