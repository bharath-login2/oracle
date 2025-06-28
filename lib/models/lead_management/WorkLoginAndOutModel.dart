class WorkLoginAndOutModel {
  final bool? status;
  final String? message;
  final List<WorkLoginData> data;

  WorkLoginAndOutModel({
    this.status,
    this.message,
    required this.data,
  });

  factory WorkLoginAndOutModel.fromJson(Map<String, dynamic> json) {
    return WorkLoginAndOutModel(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => WorkLoginData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class WorkLoginData {
  final String? date;
  final String? loginTime;
  final String? logoutTime;
  final String? loginLatitude;
  final String? loginLongitude;
  final String? logoutLatitude;
  final String? logoutLongitude;

  WorkLoginData(
      {this.date,
      this.loginTime,
      this.logoutTime,
      this.loginLatitude,
      this.loginLongitude,
      this.logoutLatitude,
      this.logoutLongitude});

  factory WorkLoginData.fromJson(Map<String, dynamic> json) {
    return WorkLoginData(
      date: json['date'] ?? "",
      loginTime: json['login_time'] ?? "",
      logoutTime: json['logout_time'] ?? "",
      loginLatitude: json['login_latitude'] ?? "",
      loginLongitude: json['login_longitude'] ?? "",
      logoutLatitude: json['logout_latitude'] ?? "",
      logoutLongitude: json['logout_longitude'] ?? "",
    );
  }
}
