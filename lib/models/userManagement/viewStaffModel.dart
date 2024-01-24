class ViewStaffModel {
  bool? status;
  String? message;
  Data? data;

  ViewStaffModel({this.status, this.message, this.data});

  ViewStaffModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<StaffList>? staffList;

  Data({this.staffList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['staff_list'] != null) {
      staffList = <StaffList>[];
      json['staff_list'].forEach((v) {
        staffList!.add(new StaffList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.staffList != null) {
      data['staff_list'] = this.staffList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StaffList {
  String? staffId;
  String? name;
  String? email;
  String? phoneNo;
  String? designation;
  String? branchName;
  String? imageUrl;
  bool? editPermission;
  bool? deletePermission;
  bool? changePasswordPermission;

  StaffList(
      {this.staffId,
        this.name,
        this.email,
        this.phoneNo,
        this.designation,
        this.branchName,
        this.imageUrl,
        this.editPermission,
        this.deletePermission,
        this.changePasswordPermission});

  StaffList.fromJson(Map<String, dynamic> json) {
    staffId = json['staffId'];
    name = json['name'];
    email = json['email'];
    phoneNo = json['phoneNo'];
    designation = json['designation'];
    branchName = json['branch_name'];
    imageUrl = json['imageUrl'];
    editPermission = json['edit_permission'];
    deletePermission = json['delete_permission'];
    changePasswordPermission = json['change_password_permission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['staffId'] = this.staffId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phoneNo'] = this.phoneNo;
    data['designation'] = this.designation;
    data['branch_name'] = this.branchName;
    data['imageUrl'] = this.imageUrl;
    data['edit_permission'] = this.editPermission;
    data['delete_permission'] = this.deletePermission;
    data['change_password_permission'] = this.changePasswordPermission;
    return data;
  }
}