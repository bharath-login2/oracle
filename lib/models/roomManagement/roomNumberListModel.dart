class RoomNumberListResponse {
  final bool status;
  final String message;
  final List<RoomNumberData> data;

  RoomNumberListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RoomNumberListResponse.fromJson(Map<String, dynamic> json) {
    return RoomNumberListResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((item) => RoomNumberData.fromJson(item))
          .toList(),
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

class RoomNumberData {
  final String id;
  final String roomNo;
  final String roomName;
  final String price;
  final String taxPercentage;
  final String roomFacility;
  final String roomDescription;
  final String isMaintenance;

  RoomNumberData({
    required this.id,
    required this.roomNo,
    required this.roomName,
    required this.price,
    required this.taxPercentage,
    required this.roomFacility,
    required this.roomDescription,
    required this.isMaintenance,
  });

  factory RoomNumberData.fromJson(Map<String, dynamic> json) {
    return RoomNumberData(
      id: json['id']?.toString() ?? '',
      roomNo: json['room_no']?.toString() ?? '',
      roomName: json['room_name']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      taxPercentage: json['tax_percentage']?.toString() ?? '',
      roomFacility: json['room_facility']?.toString() ?? '',
      roomDescription: json['room_description']?.toString() ?? '',
      isMaintenance: json['is_maintenance']?.toString() ?? 'N',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_no': roomNo,
      'room_name': roomName,
      'price': price,
      'tax_percentage': taxPercentage,
      'room_facility': roomFacility,
      'room_description': roomDescription,
      'is_maintenance': isMaintenance,
    };
  }

  // Helper getter to check if room is available
  bool get isAvailable => isMaintenance.toUpperCase() != 'Y';
  
  // Helper getter for formatted price
  String get formattedPrice => '₹$price';
}