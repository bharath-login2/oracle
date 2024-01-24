class EditDesignationDetailsModel {
  Data? data;
  bool? status;
  String? message;

  EditDesignationDetailsModel({this.data, this.status, this.message});

  EditDesignationDetailsModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  String? id;
  String? designation;
  List<MenuList>? menuList;

  Data({this.id, this.designation, this.menuList});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    designation = json['designation'];
    if (json['menu_list'] != null) {
      menuList = <MenuList>[];
      json['menu_list'].forEach((v) {
        menuList!.add(MenuList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['designation'] = designation;
    if (menuList != null) {
      data['menu_list'] = menuList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MenuList {
  String? catId;
  String? categoryName;
  bool? isAvailable;
  bool? isExpand;
  List<SubMenu>? subMenu;

  MenuList(
      {this.catId,
        this.categoryName,
        this.isAvailable,
        this.isExpand,
        this.subMenu});

  MenuList.fromJson(Map<String, dynamic> json) {
    catId = json['cat_id'];
    categoryName = json['category_name'];
    isAvailable = json['is_available'];
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
    data['is_available'] = isAvailable;
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
  bool? isChecked;

  SubMenu({this.id, this.menu, this.isChecked});

  SubMenu.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    menu = json['menu'];
    isChecked = json['is_checked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['menu'] = menu;
    data['is_checked'] = isChecked;
    return data;
  }
}