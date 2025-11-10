// To parse this JSON data, do
//
//     final userDashboardModel = userDashboardModelFromJson(jsonString);

import 'dart:convert';

UserDashboardModel userDashboardModelFromJson(String str) =>
    UserDashboardModel.fromJson(json.decode(str));

String userDashboardModelToJson(UserDashboardModel data) =>
    json.encode(data.toJson());

class UserDashboardModel {
  String message;
  Data data;
  bool status;

  UserDashboardModel({
    required this.message,
    required this.data,
    required this.status,
  });

  factory UserDashboardModel.fromJson(Map<String, dynamic> json) =>
      UserDashboardModel(
        message: json["message"],
        data: Data.fromJson(json["data"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
        "status": status,
      };
}

class Data {
  UserData userData;
  List<UserTarget> userTarget;
  List<StaffCallTarget> staffCallTarget;
  List<UserFile> userFiles; // ✅ NEW

  Data({
    required this.userData,
    required this.userTarget,
    required this.staffCallTarget,
    required this.userFiles, // ✅ NEW
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userData: UserData.fromJson(json["UserData"]),
        userTarget: List<UserTarget>.from(
            json["UserTarget"].map((x) => UserTarget.fromJson(x))),
        staffCallTarget: List<StaffCallTarget>.from(
            json["staffCallTarget"].map((x) => StaffCallTarget.fromJson(x))),
        userFiles: List<UserFile>.from(
            (json["UserFiles"] ?? []).map((x) => UserFile.fromJson(x))), // ✅ NEW
      );

  Map<String, dynamic> toJson() => {
        "UserData": userData.toJson(),
        "UserTarget": List<dynamic>.from(userTarget.map((x) => x.toJson())),
        "staffCallTarget":
            List<dynamic>.from(staffCallTarget.map((x) => x.toJson())),
        "UserFiles": List<dynamic>.from(userFiles.map((x) => x.toJson())), // ✅ NEW
      };
}

class UserFile {
  String document;
  String link;
  String ext;

  UserFile({
    required this.document,
    required this.link,
    required this.ext,
  });

  factory UserFile.fromJson(Map<String, dynamic> json) => UserFile(
        document: json["document"] ?? "",
        link: json["link"] ?? "",
        ext: json["ext"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "document": document,
        "link": link,
        "ext": ext,
      };
}

class StaffCallTarget {
  String groupId;
  String groupName;
  String targetCall;
  String achieved;
  String progressPercentage;

  StaffCallTarget({
    required this.groupId,
    required this.groupName,
    required this.targetCall,
    required this.achieved,
    required this.progressPercentage,
  });

  factory StaffCallTarget.fromJson(Map<String, dynamic> json) =>
      StaffCallTarget(
        groupId: json["group_id"] ?? "",
        groupName: json["group_name"] ?? "",
        targetCall: json["target_call"] ?? "",
        achieved: json["achieved"] ?? "",
        progressPercentage: json["progress_percentage"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "group_name": groupName,
        "target_call": targetCall,
        "achieved": achieved,
        "progress_percentage": progressPercentage,
      };
}

class UserData {
  String userId;
  String staffName;
  String phoneNo;
  String address;
  String email;
  String proPicThumb;
  String designation;
  String profilePic;

  UserData({
    required this.userId,
    required this.staffName,
    required this.phoneNo,
    required this.address,
    required this.email,
    required this.proPicThumb,
    required this.designation,
    required this.profilePic,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        userId: json["user_id"] ?? "",
        staffName: json["staff_name"] ?? "",
        phoneNo: json["phone_no"] ?? "",
        address: json["address"] ?? "",
        email: json["email"] ?? "",
        proPicThumb: json["pro_pic_thumb"] ?? "",
        designation: json["designation"] ?? "",
        profilePic: json["profile_pic"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "staff_name": staffName,
        "phone_no": phoneNo,
        "address": address,
        "email": email,
        "pro_pic_thumb": proPicThumb,
        "designation": designation,
        "profile_pic": profilePic,
      };
}

class UserTarget {
  String groupId;
  String groupName;
  String targetAmount;
  String achieved;
  String progressPercentage;

  UserTarget({
    required this.groupId,
    required this.groupName,
    required this.targetAmount,
    required this.achieved,
    required this.progressPercentage,
  });

  factory UserTarget.fromJson(Map<String, dynamic> json) => UserTarget(
        groupId: json["group_id"] ?? "",
        groupName: json["group_name"] ?? "",
        targetAmount: json["target_amount"] ?? "",
        achieved: json["achieved"] ?? "",
        progressPercentage: json["progress_percentage"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "group_name": groupName,
        "target_amount": targetAmount,
        "achieved": achieved,
        "progress_percentage": progressPercentage,
      };
}
