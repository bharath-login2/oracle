class RoomDashboardResponse {
  final bool status;
  final String message;
  final RoomDashboardData data;

  RoomDashboardResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RoomDashboardResponse.fromJson(Map<String, dynamic> json) {
    return RoomDashboardResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: RoomDashboardData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class RoomDashboardData {
  final RoomDashboardCount dashboardCount;
  final RoomStatusOverview roomStatusOverview;
  final List<RecentBooking> recentBookingList;
  final List<FloorStatus> floorStatus;
  final CalendarStatus calendar;

  RoomDashboardData({
    required this.dashboardCount,
    required this.roomStatusOverview,
    required this.recentBookingList,
    required this.floorStatus,
    required this.calendar,
  });

  factory RoomDashboardData.fromJson(Map<String, dynamic> json) {
    return RoomDashboardData(
      dashboardCount: RoomDashboardCount.fromJson(json['dashboard_count']),
      roomStatusOverview:
          RoomStatusOverview.fromJson(json['room_status_overview']),
      recentBookingList: (json['recent_booking_list'] as List)
          .map((item) => RecentBooking.fromJson(item))
          .toList(),
      floorStatus: (json['floor_status'] as List)
          .map((item) => FloorStatus.fromJson(item))
          .toList(),
      calendar: CalendarStatus.fromJson(json['calendar']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dashboard_count': dashboardCount.toJson(),
      'room_status_overview': roomStatusOverview.toJson(),
      'recent_booking_list':
          recentBookingList.map((item) => item.toJson()).toList(),
      'floor_status': floorStatus.map((item) => item.toJson()).toList(),
      'calendar': calendar.toJson(),
    };
  }
}

class RoomDashboardCount {
  final int checkinCount;
  final int checkoutCount;
  final int cancelledCount;
  final int newBookingCount;

  RoomDashboardCount({
    required this.checkinCount,
    required this.checkoutCount,
    required this.cancelledCount,
    required this.newBookingCount,
  });

  factory RoomDashboardCount.fromJson(Map<String, dynamic> json) {
    return RoomDashboardCount(
      checkinCount: json['checkin_count'] as int,
      checkoutCount: json['checkout_count'] as int,
      cancelledCount: json['cancelled_count'] as int,
      newBookingCount: json['new_booking_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkin_count': checkinCount,
      'checkout_count': checkoutCount,
      'cancelled_count': cancelledCount,
      'new_booking_count': newBookingCount,
    };
  }
}

class RoomStatusOverview {
  final int availableRoomsToday;
  final int notAvailableRooms;
  final int bookedRooms;

  RoomStatusOverview({
    required this.availableRoomsToday,
    required this.notAvailableRooms,
    required this.bookedRooms,
  });

  factory RoomStatusOverview.fromJson(Map<String, dynamic> json) {
    return RoomStatusOverview(
      availableRoomsToday: json['available_rooms_today'] as int,
      notAvailableRooms: json['not_available_rooms'] as int,
      bookedRooms: json['booked_rooms'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available_rooms_today': availableRoomsToday,
      'not_available_rooms': notAvailableRooms,
      'booked_rooms': bookedRooms,
    };
  }
}

class RecentBooking {
  final String bookingId;
  final String guestName;
  final String contactNo;
  final String checkInDate;
  final String checkOutDate;
  final String bookingDate;
  final String roomNumbers;

  RecentBooking({
    required this.bookingId,
    required this.guestName,
    required this.contactNo,
    required this.checkInDate,
    required this.checkOutDate,
    required this.bookingDate,
    required this.roomNumbers,
  });

  factory RecentBooking.fromJson(Map<String, dynamic> json) {
    return RecentBooking(
      bookingId: json['booking_id'] as String,
      guestName: json['guest_name'] as String,
      contactNo: json['contact_no'] as String,
      checkInDate: json['check_in_date'] as String,
      checkOutDate: json['check_out_date'] as String,
      bookingDate: json['booking_date'] as String,
      roomNumbers: json['room_numbers'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'guest_name': guestName,
      'contact_no': contactNo,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'booking_date': bookingDate,
      'room_numbers': roomNumbers,
    };
  }
}

class FloorStatus {
  final String floorType;
  final String bookedRooms;
  final String totalRooms;

  FloorStatus({
    required this.floorType,
    required this.bookedRooms,
    required this.totalRooms,
  });

  factory FloorStatus.fromJson(Map<String, dynamic> json) {
    return FloorStatus(
      floorType: json['floor_type'] as String,
      bookedRooms: json['booked_rooms'] as String,
      totalRooms: json['total_rooms'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'floor_type': floorType,
      'booked_rooms': bookedRooms,
      'total_rooms': totalRooms,
    };
  }
}

class CalendarStatus {
   final String reportDate;
  final String checkInCount;
  final String bookedCount;
  final String cancelledCount;
  final String checkoutCount;

  CalendarStatus({
     required this.reportDate,
    required this.checkInCount,
    required this.bookedCount,
    required this.cancelledCount,
    required this.checkoutCount,
  });

  factory CalendarStatus.fromJson(Map<String, dynamic> json) {
    return CalendarStatus(
        reportDate: json['report_date'] as String,
      checkInCount: json['check_in_count'] as String,
      bookedCount: json['booked_count'] as String,
      cancelledCount: json['cancelled_count'] as String,
      checkoutCount: json['checkout_count'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_date': reportDate,
      'check_in_count': checkInCount,
      'booked_count': bookedCount,
      'cancelled_count': cancelledCount,
      'checkout_count': checkoutCount,
    };
  }
}