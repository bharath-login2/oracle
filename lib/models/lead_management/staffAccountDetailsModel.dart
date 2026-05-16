class StaffAccountDetailsModel {
  final String message;
  final Data data;
  final bool status;

  StaffAccountDetailsModel({
    required this.message,
    required this.data,
    required this.status,
  });

  factory StaffAccountDetailsModel.fromJson(Map<String, dynamic> json) {
    return StaffAccountDetailsModel(
      message: json['message'] ?? '',
      data: Data.fromJson(json['data']),
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
      'status': status,
    };
  }
}

class Data {
  final Salary salary;
  final Petty petty;

  Data({
    required this.salary,
    required this.petty,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      salary: json['salary'] is Map<String, dynamic>
          ? Salary.fromJson(json['salary'])
          : Salary.empty(),
      petty: json['petty'] is Map<String, dynamic>
          ? Petty.fromJson(json['petty'])
          : Petty.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salary': salary.toJson(),
      'petty': petty.toJson(),
    };
  }
}

class Salary {
  final String accountId;
  final String accountName;
  final String accountCategory;
  final String accountUserId;
  final String openingBalance;
  final String debitOrCredit;
  final String openingDate;

  Salary({
    required this.accountId,
    required this.accountName,
    required this.accountCategory,
    required this.accountUserId,
    required this.openingBalance,
    required this.debitOrCredit,
    required this.openingDate,
  });

  factory Salary.empty() {
    return Salary(
      accountId: '',
      accountName: '',
      accountCategory: '',
      accountUserId: '',
      openingBalance: '',
      debitOrCredit: '',
      openingDate: '',
    );
  }

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      accountId: json['account_id']?.toString() ?? '',
      accountName: json['account_name']?.toString() ?? '',
      accountCategory: json['Account_category']?.toString() ?? '',
      accountUserId: json['account_user_id']?.toString() ?? '',
      openingBalance: json['opening_balance']?.toString() ?? '',
      debitOrCredit: json['debit_or_credit']?.toString() ?? '',
      openingDate: json['opening_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'account_name': accountName,
      'Account_category': accountCategory,
      'account_user_id': accountUserId,
      'opening_balance': openingBalance,
      'debit_or_credit': debitOrCredit,
      'opening_date': openingDate,
    };
  }
}

class Petty {
  final String accountId;
  final String accountName;
  final String accountCategory;
  final String accountUserId;
  final String openingBalance;
  final String debitOrCredit;
  final String openingDate;

  Petty({
    required this.accountId,
    required this.accountName,
    required this.accountCategory,
    required this.accountUserId,
    required this.openingBalance,
    required this.debitOrCredit,
    required this.openingDate,
  });

  factory Petty.empty() {
    return Petty(
      accountId: '',
      accountName: '',
      accountCategory: '',
      accountUserId: '',
      openingBalance: '',
      debitOrCredit: '',
      openingDate: '',
    );
  }

  factory Petty.fromJson(Map<String, dynamic> json) {
    return Petty(
      accountId: json['account_id']?.toString() ?? '',
      accountName: json['account_name']?.toString() ?? '',
      accountCategory: json['Account_category']?.toString() ?? '',
      accountUserId: json['account_user_id']?.toString() ?? '',
      openingBalance: json['opening_balance']?.toString() ?? '',
      debitOrCredit: json['debit_or_credit']?.toString() ?? '',
      openingDate: json['opening_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'account_name': accountName,
      'Account_category': accountCategory,
      'account_user_id': accountUserId,
      'opening_balance': openingBalance,
      'debit_or_credit': debitOrCredit,
      'opening_date': openingDate,
    };
  }
}