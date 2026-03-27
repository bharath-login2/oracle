class GoogleDriveAccountsModel {
  final bool status;
  final String message;
  final List<DriveAccount> data;

  GoogleDriveAccountsModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GoogleDriveAccountsModel.fromJson(Map<String, dynamic> json) {
    return GoogleDriveAccountsModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => DriveAccount.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class DriveAccount {
  final String id;
  final String accountEmail;
  final String isActive;

  DriveAccount({
    required this.id,
    required this.accountEmail,
    required this.isActive,
  });

  factory DriveAccount.fromJson(Map<String, dynamic> json) {
    return DriveAccount(
      id: json['id']?.toString() ?? '',
      accountEmail: json['account_email'] ?? '',
      isActive: json['is_active']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_email': accountEmail,
      'is_active': isActive,
    };
  }

  bool get isActiveBool => isActive == '1';
}
