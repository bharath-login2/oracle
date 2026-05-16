import 'dart:convert';

class StaffsModel {
  String status;
  List<staffsModel> data;

  StaffsModel({
    required this.status,
    required this.data,
  });

  factory StaffsModel.fromRawJson(String str) =>
      StaffsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StaffsModel.fromJson(Map<String, dynamic> json) => StaffsModel(
        status: json["status"],
        data: List<staffsModel>.from(
            json["data"].map((x) => staffsModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class staffsModel {
  String userId;
  String staffId;
  String staffName;
  String phoneNo;
  String designation;
  String branchName;

  staffsModel({
    required this.userId,
    required this.staffId,
    required this.staffName,
    required this.phoneNo,
    required this.designation,
    required this.branchName,
  });

  factory staffsModel.fromRawJson(String str) =>
      staffsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory staffsModel.fromJson(Map<String, dynamic> json) => staffsModel(
        userId: json["user_id"],
        staffId: json["staff_id"],
        staffName: json["staff_name"],
        phoneNo: json["phone_no"],
        designation: json["designation"],
        branchName: json["branch_name"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "staff_id": staffId,
        "staff_name": staffName,
        "phone_no": phoneNo,
        "designation": designation,
        "branch_name": branchName,
      };
}
