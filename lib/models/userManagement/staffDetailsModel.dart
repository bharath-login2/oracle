class StaffDetailsModel {
  bool? status;
  String? message;
  Data? data;

  StaffDetailsModel({this.status, this.message, this.data});

  StaffDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] as bool?;
    message = json['message'] as String?;
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
  String? designationsingleId;
  String? designationsingle;
  String? proPicThumb;
  String? branchId;
  List<String>? staffIds;
  List<DesignationList>? designationList;
  List<String>? staffNames;
  List<MenuList>? menuList;
  List<Privilages>? privilages;

  Data({
    this.userId,
    this.staffName,
    this.phoneNo,
    this.email,
    this.designationsingleId,
    this.designationsingle,
    this.proPicThumb,
    this.branchId,
    this.staffIds,
    this.designationList,
    this.staffNames,
    this.menuList,
    this.privilages,
  });

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'] as String?;
    staffName = json['staff_name'] as String?;
    phoneNo = json['phone_no'] as String?;
    email = json['email'] as String?;
    designationsingleId = json['designation_id']??"";
    designationsingle = json['designation']??"";
    proPicThumb = json['pro_pic_thumb'] as String?;
    branchId = json['branch_id'] as String?;
    staffIds = (json['staff_ids'] as List?)?.map((e) => e as String).toList();
    staffNames = (json['staff_names'] as List?)?.map((e) => e as String).toList();

    if (json['designations'] != null) {
      designationList = (json['designations'] as List)
          .map((v) => DesignationList.fromJson(v))
          .toList();
    }
    if (json['menu_list'] != null) {
      menuList = (json['menu_list'] as List)
          .map((v) => MenuList.fromJson(v))
          .toList();
    }
    if (json['privilages'] != null) {
      privilages = (json['privilages'] as List)
          .map((v) => Privilages.fromJson(v))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['staff_name'] = staffName;
    data['phone_no'] = phoneNo;
    data['email'] = email;
    data['designation_id'] = designationsingleId;
    data['designation'] = designationsingle;
    data['pro_pic_thumb'] = proPicThumb;
    data['branch_id'] = branchId;
    data['staff_ids'] = staffIds;
    data['staff_names'] = staffNames;
   if (designationList != null) {
    data['designations'] = designationList!.map((v) => v.toJson()).toList();
  }

    if (menuList != null) {
      data['menu_list'] = menuList!.map((v) => v.toJson()).toList();
    }
    if (privilages != null) {
      data['privilages'] = privilages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DesignationList {
  String? designationId;
  String? designation;

  DesignationList({this.designationId, this.designation});

  DesignationList.fromJson(Map<String, dynamic> json) {
    designationId = json['id'] as String? ?? "";
    designation = json['designation'] as String? ?? "";
  }

  Map<String, dynamic> toJson() => {
        'id': designationId,
        'designation': designation,
      };
}

class MenuList {
  String? catId;
  String? categoryName;
  bool? isAvailable;
  bool? isExpand;
  List<SubMenu>? subMenu;

  MenuList({this.catId, this.categoryName, this.isAvailable, this.isExpand, this.subMenu});

  MenuList.fromJson(Map<String, dynamic> json) {
    catId = json['cat_id'] as String?;
    categoryName = json['category_name'] as String?;
    isAvailable = json['is_available'] as bool?;
    isExpand = json['is_expand'] as bool?;
    if (json['sub_menu'] != null) {
      subMenu = (json['sub_menu'] as List)
          .map((v) => SubMenu.fromJson(v))
          .toList();
    }
  }

  Map<String, dynamic> toJson() => {
        'cat_id': catId,
        'category_name': categoryName,
        'is_available': isAvailable,
        'is_expand': isExpand,
        'sub_menu': subMenu?.map((v) => v.toJson()).toList(),
      };
}

class SubMenu {
  String? id;
  String? menu;
  bool? isChecked;

  SubMenu({this.id, this.menu, this.isChecked});

  SubMenu.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String?,
        menu = json['menu'] as String?,
        isChecked = json['is_checked'] as bool?;

  Map<String, dynamic> toJson() => {'id': id, 'menu': menu, 'is_checked': isChecked};
}

class Privilages {
  String? catId;
  String? categoryName;
  bool? isPrivilageAvailable;
  bool? isPrivilageExpand;
  List<Permission>? permission;

  Privilages({this.catId, this.categoryName, this.isPrivilageAvailable, this.isPrivilageExpand, this.permission});

  Privilages.fromJson(Map<String, dynamic> json) {
    catId = json['cat_id'] as String?;
    categoryName = json['category_name'] as String?;
    isPrivilageAvailable = json['is_privilage_available'] as bool?;
    isPrivilageExpand = json['is_privilage_expand'] as bool?;
    permission = (json['permission'] as List?)?.map((v) => Permission.fromJson(v)).toList();
  }

  Map<String, dynamic> toJson() => {
        'cat_id': catId,
        'category_name': categoryName,
        'is_privilage_available': isPrivilageAvailable,
        'is_privilage_expand': isPrivilageExpand,
        'permission': permission?.map((v) => v.toJson()).toList(),
      };
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