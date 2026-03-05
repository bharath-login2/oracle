// rental_customer_locations.dart

class RentalCustomerLocations {
  final bool status;
  final String message;
  final List<LocationData> data;

  RentalCustomerLocations({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RentalCustomerLocations.fromJson(Map<String, dynamic> json) {
    return RentalCustomerLocations(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map(
                  (item) => LocationData.fromJson(item as Map<String, dynamic>))
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

class LocationData {
  final String id;
  final String locationName;
  final String customerId;

  LocationData({
    required this.id,
    required this.locationName,
    required this.customerId,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      id: json['id']?.toString() ?? '',
      locationName: json['location_name'] ?? '',
      customerId: json['customer_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_name': locationName,
      'customer_id': customerId,
    };
  }

  @override
  String toString() {
    return 'LocationData{id: $id, locationName: $locationName, customerId: $customerId}';
  }
}
