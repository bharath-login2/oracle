class StaffDetailsModel {
  bool? status;
  String? message;
  Data? data;

  StaffDetailsModel({this.status, this.message, this.data});

  StaffDetailsModel.fromJson(Map<String, dynamic> json) {
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
  String? userId;
  String? staffName;
  String? phoneNo;
  String? email;
  String? designationId;
  String? designation;
  String? proPicThumb;
  String? branchId;
  List<String>? staffIds;
  List<String>? staffNames;
  List<MenuList>? menuList;
  List<Privilages>? privilages;

  Data(
      {this.userId,
      this.staffName,
      this.phoneNo,
      this.email,
      this.designationId,
      this.designation,
      this.proPicThumb,
      this.branchId,
      this.staffIds,
      this.staffNames,
      this.menuList,
      this.privilages});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    staffName = json['staff_name'];
    phoneNo = json['phone_no'];
    email = json['email'];
    designationId = json['designation_id'];
    designation = json['designation'];
    proPicThumb = json['pro_pic_thumb'];
    branchId = json['branch_id'];
    staffIds = json['staff_ids'].cast<String>();
    staffNames = json['staff_names'].cast<String>();
    if (json['menu_list'] != null) {
      menuList = <MenuList>[];
      json['menu_list'].forEach((v) {
        menuList!.add(MenuList.fromJson(v));
      });
    }
    if (json['privilages'] != null) {
      privilages = <Privilages>[];
      json['privilages'].forEach((v) {
        privilages!.add(Privilages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['staff_name'] = staffName;
    data['phone_no'] = phoneNo;
    data['email'] = email;
    data['designation_id'] = designationId;
    data['designation'] = designation;
    data['pro_pic_thumb'] = proPicThumb;
    data['branch_id'] = branchId;
    data['staff_ids'] = staffIds;
    data['staff_names'] = staffNames;
    if (menuList != null) {
      data['menu_list'] = menuList!.map((v) => v.toJson()).toList();
    }
    if (privilages != null) {
      data['privilages'] = privilages!.map((v) => v.toJson()).toList();
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

class Privilages {
  String? catId;
  String? categoryName;
  bool? isPrivilageAvailable;
  bool? isPrivilageExpand;
  List<Permission>? permission;

  Privilages(
      {this.catId,
      this.categoryName,
      this.isPrivilageAvailable,
      this.isPrivilageExpand,
      this.permission});

  Privilages.fromJson(Map<String, dynamic> json) {
    catId = json['cat_id'];
    categoryName = json['category_name'];
    isPrivilageAvailable = json['is_privilage_available'];
    isPrivilageExpand = json['is_privilage_expand'];
    if (json['permission'] != null) {
      permission = <Permission>[];
      json['permission'].forEach((v) {
        permission!.add(Permission.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cat_id'] = catId;
    data['category_name'] = categoryName;
    data['is_privilage_available'] = isPrivilageAvailable;
    data['is_privilage_expand'] = isPrivilageExpand;
    if (permission != null) {
      data['permission'] = permission!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Permission {
  String? permissionId;
  String? permission;
  bool? isselected;

  Permission({this.permissionId, this.permission, this.isselected});

  Permission.fromJson(Map<String, dynamic> json) {
    permissionId = json['permission_id'];
    permission = json['permission'];
    isselected = json['Isselected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['permission_id'] = permissionId;
    data['permission'] = permission;
    data['Isselected'] = isselected;
    return data;
  }
}
