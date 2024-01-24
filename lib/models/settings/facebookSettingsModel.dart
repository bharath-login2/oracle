class FacebookSettingsModel {
  bool? status;
  String? message;
  Data? data;

  FacebookSettingsModel({this.status, this.message, this.data});

  FacebookSettingsModel.fromJson(Map<String, dynamic> json) {
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
  List<FbData>? fbData;
  String? testToolUrl;
  String? fbConnectUrl;

  Data({this.fbData, this.testToolUrl, this.fbConnectUrl});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['fbData'] != null) {
      fbData = <FbData>[];
      json['fbData'].forEach((v) {
        fbData!.add(FbData.fromJson(v));
      });
    }
    testToolUrl = json['testToolUrl'];
    fbConnectUrl = json['fbConnectUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (fbData != null) {
      data['fbData'] = fbData!.map((v) => v.toJson()).toList();
    }
    data['testToolUrl'] = testToolUrl;
    data['fbConnectUrl'] = fbConnectUrl;
    return data;
  }
}

class FbData {
  String? id;
  String? name;
  String? imageUrl;
  String? pageId;
  String? pageName;
  String? formId;
  String? formName;
  List<AssignedStaff>? assignedStaff;
  List<NotificationUsers>? notificationUsers;
  List<FormFeilds>? formFeilds;

  FbData(
      {this.id,
        this.name,
        this.imageUrl,
        this.pageId,
        this.pageName,
        this.formId,
        this.formName,
        this.assignedStaff,
        this.notificationUsers,
        this.formFeilds});

  FbData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    pageId = json['page_id'];
    pageName = json['page_name'];
    formId = json['form_id'];
    formName = json['form_name'];
    if (json['assignedStaff'] != null) {
      assignedStaff = <AssignedStaff>[];
      json['assignedStaff'].forEach((v) {
        assignedStaff!.add(AssignedStaff.fromJson(v));
      });
    }
    if (json['notification_users'] != null) {
      notificationUsers = <NotificationUsers>[];
      json['notification_users'].forEach((v) {
        notificationUsers!.add(NotificationUsers.fromJson(v));
      });
    }
    if (json['formFeilds'] != null) {
      formFeilds = <FormFeilds>[];
      json['formFeilds'].forEach((v) {
        formFeilds!.add(FormFeilds.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['imageUrl'] = imageUrl;
    data['page_id'] = pageId;
    data['page_name'] = pageName;
    data['form_id'] = formId;
    data['form_name'] = formName;
    if (assignedStaff != null) {
      data['assignedStaff'] =
          assignedStaff!.map((v) => v.toJson()).toList();
    }
    if (notificationUsers != null) {
      data['notification_users'] =
          notificationUsers!.map((v) => v.toJson()).toList();
    }
    if (formFeilds != null) {
      data['formFeilds'] = formFeilds!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AssignedStaff {
  String? staffId;
  String? staffName;

  AssignedStaff({this.staffId, this.staffName});

  AssignedStaff.fromJson(Map<String, dynamic> json) {
    staffId = json['staffId'];
    staffName = json['staffName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['staffId'] = staffId;
    data['staffName'] = staffName;
    return data;
  }
}

class NotificationUsers {
  String? notificationUserId;
  String? notificationUserName;

  NotificationUsers({this.notificationUserId, this.notificationUserName});

  NotificationUsers.fromJson(Map<String, dynamic> json) {
    notificationUserId = json['notification_user_id'];
    notificationUserName = json['notification_user_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['notification_user_id'] = notificationUserId;
    data['notification_user_name'] = notificationUserName;
    return data;
  }
}

class FormFeilds {
  String? title;
  String? value;

  FormFeilds({this.title, this.value});

  FormFeilds.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['value'] = value;
    return data;
  }
}