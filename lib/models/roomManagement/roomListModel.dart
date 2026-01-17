class RoomListResponse {
  final bool status;
  final String message;
  final List<RoomBookingData> data;

  RoomListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RoomListResponse.fromJson(Map<String, dynamic> json) {
    return RoomListResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((item) => RoomBookingData.fromJson(item))
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

class RoomBookingData {
  final String id;
  final String bookingDate;
  final String checkInDate;
  final String checkOutDate;
  final String statusName;
  final String customerId;
  final String name;
  final String contactNo;
  final String invoiceId;
  final String bookingId;
  final String bookingType;
  final String paymentStatus;
  final String stayType;
  final String platform;
final String roomNumber;
final String amount;
  RoomBookingData({
    required this.id,
    required this.bookingDate,
    required this.checkInDate,
    required this.checkOutDate,
    required this.statusName,
    required this.customerId,
    required this.name,
    required this.contactNo,
    required this.invoiceId,
    required this.bookingId,
    required this.bookingType,
    required this.paymentStatus,
    required this.stayType,
    required this.platform,
    required this.roomNumber,
    required this.amount,
  });

  factory RoomBookingData.fromJson(Map<String, dynamic> json) {
    return RoomBookingData(
      id: json['id'] as String,
      bookingDate: json['booking_date'] as String,
      checkInDate: json['check_in_date'] as String,
      checkOutDate: json['check_out_date'] as String,
      statusName: json['status_name'] as String,
      customerId: json['customer_id'] as String,
      name: json['name'] as String,
      contactNo: json['contact_no'] as String,
      invoiceId: json['invoice_id'] as String,
      bookingId: json['booking_id'] as String,
      bookingType: json['booking_type'] as String,
      paymentStatus: json['payment_status'] as String,
      stayType: json['stay_type'] as String,
      platform: json['platform'] as String,
      roomNumber: json['room_number'] as String,
      amount: json['amount'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_date': bookingDate,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'status_name': statusName,
      'customer_id': customerId,
      'name': name,
      'contact_no': contactNo,
      'invoice_id': invoiceId,
      'booking_id': bookingId,
      'booking_type': bookingType,
      'payment_status': paymentStatus,
      'stay_type': stayType,
      'platform': platform,
      'room_number': roomNumber,
      'amount': amount,
    };
  }
}