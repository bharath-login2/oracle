class AttendanceStaffwiseModel {
  final bool status;
  final String message;
  final List<AttendanceData> data;

  AttendanceStaffwiseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AttendanceStaffwiseModel.fromJson(Map<String, dynamic> json) =>
      AttendanceStaffwiseModel(
        status: json["status"] as bool? ?? false,
        message: json["message"] as String? ?? "",
        data: json["data"] == null
            ? []
            : List<AttendanceData>.from(
                (json["data"] as List).map((x) => AttendanceData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class AttendanceData {
  final int totalWorkingDays;
  final List<Staff> staffList;

  AttendanceData({
    required this.totalWorkingDays,
    required this.staffList,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) => AttendanceData(
        totalWorkingDays: int.tryParse(json["total_working_days"]?.toString() ?? "0") ?? 0,
        staffList: json["staff_list"] == null
            ? []
            : List<Staff>.from(
                (json["staff_list"] as List).map((x) => Staff.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total_working_days": totalWorkingDays.toString(),
        "staff_list": List<dynamic>.from(staffList.map((x) => x.toJson())),
      };
}

class Staff {
  final String staffId;
  final String staffName;
  final double? workedDays;

  Staff({
    required this.staffId,
    required this.staffName,
    this.workedDays,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        staffId: json["staff_id"]?.toString() ?? "",
        staffName: json["staff_name"]?.toString() ?? "",
        workedDays: double.tryParse(json["worked_days"]?.toString() ?? ""),
      );

  Map<String, dynamic> toJson() => {
        "staff_id": staffId,
        "staff_name": staffName,
        "worked_days": workedDays?.toString() ?? "",
      };
}