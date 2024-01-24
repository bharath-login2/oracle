class MenuModel {
  List<Data>? data;
  bool? status;
  String? message;

  MenuModel({this.data, this.status, this.message});

  MenuModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  String? catId;
  String? categoryName;
  bool? isExpand;
  List<SubMenu>? subMenu;

  Data({this.catId, this.categoryName, this.isExpand, this.subMenu});

  Data.fromJson(Map<String, dynamic> json) {
    catId = json['cat_id'];
    categoryName = json['category_name'];
    isExpand = json['is_expand'];
    if (json['sub_menu'] != null) {
      subMenu = <SubMenu>[];
      json['sub_menu'].forEach((v) {
        subMenu!.add(SubMenu.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cat_id'] = catId;
    data['category_name'] = categoryName;
    data['is_expand'] = isExpand;
    if (subMenu != null) {
      data['sub_menu'] = subMenu!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubMenu {
  String? id;
  String? menu;

  SubMenu({this.id, this.menu});

  SubMenu.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    menu = json['menu'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['menu'] = menu;
    return data;
  }
}