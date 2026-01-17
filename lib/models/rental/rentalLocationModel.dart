class RetalLocationModel {
  final bool status;
  final String message;
  final List<RetailLocation> data;

  RetalLocationModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RetalLocationModel.fromJson(Map<String, dynamic> json) {
    return RetalLocationModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<RetailLocation>.from(
              json['data'].map(
                (x) => RetailLocation.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}

class RetailLocation {
  final String id;
  final String locationName;

  RetailLocation({
    required this.id,
    required this.locationName,
  });

  factory RetailLocation.fromJson(Map<String, dynamic> json) {
    return RetailLocation(
      id: json['id'] ?? '',
      locationName: json['location_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_name': locationName,
    };
  }
}
