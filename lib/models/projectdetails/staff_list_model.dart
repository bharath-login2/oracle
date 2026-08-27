class SiteLiftResponse {
  final List<SiteLift> data;
  final String message;
  final bool status;

  SiteLiftResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory SiteLiftResponse.fromJson(Map<String, dynamic> json) {
    return SiteLiftResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => SiteLift.fromJson(item))
          .toList(),
      message: json['message'] ?? '',
      status: json['status'] ?? false,
    );
  }
}

class SiteLift {
  final String id;
  final String siteLiftName;

  SiteLift({
    required this.id,
    required this.siteLiftName,
  });

  factory SiteLift.fromJson(Map<String, dynamic> json) {
    return SiteLift(
      id: json['id'] ?? '',
      siteLiftName: json['site_lift_name'] ?? '',
    );
  }
}
