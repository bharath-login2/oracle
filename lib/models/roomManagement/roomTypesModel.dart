class RoomTypeResponse {
  final bool status;
  final String message;
  final List<RoomTypeData> data;

  RoomTypeResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RoomTypeResponse.fromJson(Map<String, dynamic> json) {
    return RoomTypeResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((item) => RoomTypeData.fromJson(item))
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

class RoomTypeData {
  final String id;
  final String roomType;

  RoomTypeData({
    required this.id,
    required this.roomType,
  });

  factory RoomTypeData.fromJson(Map<String, dynamic> json) {
    return RoomTypeData(
      id: json['id'] as String,
      roomType: json['room_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_type': roomType,
    };
  }
}