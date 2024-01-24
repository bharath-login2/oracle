class DashboardModel {
  bool? status;
  String? message;
  Data? data;

  DashboardModel({this.status, this.message, this.data});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? packageName;
  String? startDate;
  String? endDate;
  int? staffCount;
  String? fileStorageSize;
  String? maxFileSize;
  bool? expireSoon;
  String? expireSoonContent;
  bool? isExpired;
  int? currentStaff;
  String? image1;
  String? scrollingText;
  List<Slides>? slides;
  List<Modules>? modules;

  Data(
      {this.packageName,
        this.startDate,
        this.endDate,
        this.staffCount,
        this.fileStorageSize,
        this.maxFileSize,
        this.expireSoon,
        this.expireSoonContent,
        this.isExpired,
        this.currentStaff,
        this.image1,
        this.scrollingText,
        this.slides,
        this.modules});

  Data.fromJson(Map<String, dynamic> json) {
    packageName = json['package_name'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    staffCount = json['staff_count'];
    fileStorageSize = json['file_storage_size'];
    maxFileSize = json['max_file_size'];
    expireSoon = json['expire_soon'];
    expireSoonContent = json['expire_soon_content'];
    isExpired = json['is_expired'];
    currentStaff = json['current_staff'];
    image1 = json['image1'];
    scrollingText = json['scrolling_text'];
    if (json['slides'] != null) {
      slides = <Slides>[];
      json['slides'].forEach((v) {
        slides!.add(Slides.fromJson(v));
      });
    }
    if (json['modules'] != null) {
      modules = <Modules>[];
      json['modules'].forEach((v) {
        modules!.add(Modules.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['package_name'] = packageName;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['staff_count'] = staffCount;
    data['file_storage_size'] = fileStorageSize;
    data['max_file_size'] = maxFileSize;
    data['expire_soon'] = expireSoon;
    data['expire_soon_content'] = expireSoonContent;
    data['is_expired'] = isExpired;
    data['current_staff'] = currentStaff;
    data['image1'] = image1;
    data['scrolling_text'] = scrollingText;
    if (slides != null) {
      data['slides'] = slides!.map((v) => v.toJson()).toList();
    }
    if (modules != null) {
      data['modules'] = modules!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Slides {
  String? sliderId;
  String? imageUrl;

  Slides({this.sliderId, this.imageUrl});

  Slides.fromJson(Map<String, dynamic> json) {
    sliderId = json['slider_id'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['slider_id'] = sliderId;
    data['image_url'] = imageUrl;
    return data;
  }
}

class Modules {
  String? catId;
  String? categoryName;
  String? menuName;
  String? image;

  Modules({this.catId, this.categoryName, this.menuName, this.image});

  Modules.fromJson(Map<String, dynamic> json) {
    catId = json['cat_id'];
    categoryName = json['category_name'];
    menuName = json['menu_name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['cat_id'] = catId;
    data['category_name'] = categoryName;
    data['menu_name'] = menuName;
    data['image'] = image;
    return data;
  }
}