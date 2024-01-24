class AddUserCommonDataModel {
  bool? status;
  String? message;
  Data? data;

  AddUserCommonDataModel({this.status, this.message, this.data});

  AddUserCommonDataModel.fromJson(Map<String, dynamic> json) {
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
  List<Designations>? designations;
  List<Branch>? branch;
  List<Users>? users;
  bool? officialWhatsappUsers;
  bool? unofficialWhatsappUsers;
  bool? phoneCallLogAccessbleUsers;

  Data(
      {this.designations,
        this.branch,
        this.users,
        this.officialWhatsappUsers,
        this.unofficialWhatsappUsers,
        this.phoneCallLogAccessbleUsers});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['designations'] != null) {
      designations = <Designations>[];
      json['designations'].forEach((v) {
        designations!.add(Designations.fromJson(v));
      });
    }
    if (json['branch'] != null) {
      branch = <Branch>[];
      json['branch'].forEach((v) {
        branch!.add(Branch.fromJson(v));
      });
    }
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
      });
    }
    officialWhatsappUsers = json['officialWhatsappUsers'];
    unofficialWhatsappUsers = json['unofficialWhatsappUsers'];
    phoneCallLogAccessbleUsers = json['phoneCallLogAccessbleUsers'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (designations != null) {
      data['designations'] = designations!.map((v) => v.toJson()).toList();
    }
    if (branch != null) {
      data['branch'] = branch!.map((v) => v.toJson()).toList();
    }
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    data['officialWhatsappUsers'] = officialWhatsappUsers;
    data['unofficialWhatsappUsers'] = unofficialWhatsappUsers;
    data['phoneCallLogAccessbleUsers'] = phoneCallLogAccessbleUsers;
    return data;
  }
}

class Designations {
  String? id;
  String? designation;

  Designations({this.id, this.designation});

  Designations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    designation = json['designation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['designation'] = designation;
    return data;
  }
}

class Branch {
  String? branchId;
  String? branchName;

  Branch({this.branchId, this.branchName});

  Branch.fromJson(Map<String, dynamic> json) {
    branchId = json['branch_id'];
    branchName = json['branch_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['branch_id'] = branchId;
    data['branch_name'] = branchName;
    return data;
  }
}

class Users {
  String? userId;
  String? staffName;

  Users({this.userId, this.staffName});

  Users.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    staffName = json['staff_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['staff_name'] = staffName;
    return data;
  }
}