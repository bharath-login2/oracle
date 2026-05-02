class DeleteModelOpenstock {
  final bool status;
  final String message;
  final List<dynamic> data;

  DeleteModelOpenstock({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DeleteModelOpenstock.fromJson(Map<String, dynamic> json) {
    return DeleteModelOpenstock(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? List<dynamic>.from(json['data']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}