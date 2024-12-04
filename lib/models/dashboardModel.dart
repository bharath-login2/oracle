// To parse this JSON data, do
//
//     final dashboardModel = dashboardModelFromJson(jsonString);

import 'dart:convert';

DashboardModel dashboardModelFromJson(String str) =>
    DashboardModel.fromJson(json.decode(str));

String dashboardModelToJson(DashboardModel data) => json.encode(data.toJson());

class DashboardModel {
  bool status;
  String message;
  Data data;

  DashboardModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  String packageName;
  String startDate;
  String endDate;
  int staffCount;
  String fileStorageSize;
  String maxFileSize;
  bool expireSoon;
  String expireSoonContent;
  bool isExpired;
  int currentStaff;
  String image1;
  String profilePic;
  String scrollingText;
  List<Slide> slides;
  List<Module> modules;
  bool viewAccDashboard;
  bool viewRenewalDashboard;
  bool isWhatsappConfigured;

  Data({
    required this.packageName,
    required this.startDate,
    required this.endDate,
    required this.staffCount,
    required this.fileStorageSize,
    required this.maxFileSize,
    required this.expireSoon,
    required this.expireSoonContent,
    required this.isExpired,
    required this.currentStaff,
    required this.image1,
    required this.profilePic,
    required this.scrollingText,
    required this.slides,
    required this.modules,
    required this.viewAccDashboard,
    required this.viewRenewalDashboard,
    required this.isWhatsappConfigured,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        packageName: json["package_name"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        staffCount: json["staff_count"],
        fileStorageSize: json["file_storage_size"],
        maxFileSize: json["max_file_size"],
        expireSoon: json["expire_soon"],
        expireSoonContent: json["expire_soon_content"],
        isExpired: json["is_expired"],
        currentStaff: json["current_staff"],
        image1: json["image1"],
        profilePic: json["profile_pic"],
        scrollingText: json["scrolling_text"],
        slides: List<Slide>.from(json["slides"].map((x) => Slide.fromJson(x))),
        modules:
            List<Module>.from(json["modules"].map((x) => Module.fromJson(x))),
        viewAccDashboard: json["view_acc_dashboard"],
        viewRenewalDashboard: json["view_renewal_dashboard"],
        isWhatsappConfigured: json["is_whatsapp_configured"],
      );

  Map<String, dynamic> toJson() => {
        "package_name": packageName,
        "start_date": startDate,
        "end_date": endDate,
        "staff_count": staffCount,
        "file_storage_size": fileStorageSize,
        "max_file_size": maxFileSize,
        "expire_soon": expireSoon,
        "expire_soon_content": expireSoonContent,
        "is_expired": isExpired,
        "current_staff": currentStaff,
        "image1": image1,
        "profile_pic": profilePic,
        "scrolling_text": scrollingText,
        "slides": List<dynamic>.from(slides.map((x) => x.toJson())),
        "modules": List<dynamic>.from(modules.map((x) => x.toJson())),
        "view_acc_dashboard": viewAccDashboard,
        "view_renewal_dashboard": viewRenewalDashboard,
      };
}

class Module {
  String catId;
  String categoryName;
  String menuName;
  String image;

  Module({
    required this.catId,
    required this.categoryName,
    required this.menuName,
    required this.image,
  });

  factory Module.fromJson(Map<String, dynamic> json) => Module(
        catId: json["cat_id"],
        categoryName: json["category_name"],
        menuName: json["menu_name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "cat_id": catId,
        "category_name": categoryName,
        "menu_name": menuName,
        "image": image,
      };
}

class Slide {
  String sliderId;
  String imageUrl;

  Slide({
    required this.sliderId,
    required this.imageUrl,
  });

  factory Slide.fromJson(Map<String, dynamic> json) => Slide(
        sliderId: json["slider_id"],
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "slider_id": sliderId,
        "image_url": imageUrl,
      };
}
