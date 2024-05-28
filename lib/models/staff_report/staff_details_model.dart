// To parse this JSON data, do
//
//     final userDashboardModel = userDashboardModelFromJson(jsonString);


import 'dart:convert';

UserDashboardModel userDashboardModelFromJson(String str) => UserDashboardModel.fromJson(json.decode(str));

String userDashboardModelToJson(UserDashboardModel data) => json.encode(data.toJson());

class UserDashboardModel {
    String message;
    Data data;
    bool status;

    UserDashboardModel({
        required this.message,
        required this.data,
        required this.status,
    });

    factory UserDashboardModel.fromJson(Map<String, dynamic> json) => UserDashboardModel(
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
    UserTarget userTarget;

    Data({
        required this.userData,
        required this.userTarget,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        userData: UserData.fromJson(json["UserData"]),
        userTarget: UserTarget.fromJson(json["UserTarget"]),
    );

    Map<String, dynamic> toJson() => {
        "UserData": userData.toJson(),
        "UserTarget": userTarget.toJson(),
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
        userId: json["user_id"],
        staffName: json["staff_name"],
        phoneNo: json["phone_no"],
        address: json["address"],
        email: json["email"],
        proPicThumb: json["pro_pic_thumb"],
        designation: json["designation"],
        profilePic: json["profile_pic"],
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
    int targetCallCount;
    int targetCost;
    int achievedCalls;
    String achievedCost;

    UserTarget({
        required this.targetCallCount,
        required this.targetCost,
        required this.achievedCalls,
        required this.achievedCost,
    });

    factory UserTarget.fromJson(Map<String, dynamic> json) => UserTarget(
        targetCallCount: json["targetCallCount"],
        targetCost: json["targetCost"],
        achievedCalls: json["achievedCalls"],
        achievedCost: json["achievedCost"],
    );

    Map<String, dynamic> toJson() => {
        "targetCallCount": targetCallCount,
        "targetCost": targetCost,
        "achievedCalls": achievedCalls,
        "achievedCost": achievedCost,
    };
}
