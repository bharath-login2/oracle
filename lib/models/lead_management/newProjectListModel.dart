class NewProjectListModel {
  final bool status;
  final String message;
  final NewProjectListData? data;

  NewProjectListModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory NewProjectListModel.fromJson(Map<String, dynamic> json) {
    return NewProjectListModel(
      status: json["status"] == true,
      message: json["message"]?.toString() ?? "",
      data: json["data"] != null && json["data"] is Map<String, dynamic>
          ? NewProjectListData.fromJson(json["data"])
          : null,
    );
  }
}

class NewProjectListData {
  final String username;
  final String designation;
  final List<NewProjectItem> projectList;

  NewProjectListData({
    required this.username,
    required this.designation,
    required this.projectList,
  });

  factory NewProjectListData.fromJson(Map<String, dynamic> json) {
    var list = json["project_list"];
    List<NewProjectItem> projects = [];
    if (list != null && list is List) {
      projects = list.map((e) => NewProjectItem.fromJson(e)).toList();
    }
    return NewProjectListData(
      username: json["username"]?.toString() ?? "",
      designation: json["designation"]?.toString() ?? "",
      projectList: projects,
    );
  }
}

class NewProjectItem {
  final String id;
  final String projectName;
  final String location;
  final String clientId;
  final String workStatus;
  final String startingDate;
  final String completionDate;
  final String totalAmount;
  final bool paymentStatus;

  NewProjectItem({
    required this.id,
    required this.projectName,
    required this.location,
    required this.clientId,
    required this.workStatus,
    required this.startingDate,
    required this.completionDate,
    required this.totalAmount,
    required this.paymentStatus,
  });

  factory NewProjectItem.fromJson(Map<String, dynamic> json) {
    return NewProjectItem(
      id: json["id"]?.toString() ?? "",
      projectName: json["project_name"]?.toString() ?? "",
      location: json["location"]?.toString() ?? "",
      clientId: json["client_id"]?.toString() ?? "",
      workStatus: json["work_status"]?.toString() ?? "",
      startingDate: json["starting_date"]?.toString() ?? "",
      completionDate: json["completion_date"]?.toString() ?? "",
      totalAmount: json["total_amount"]?.toString() ?? "0.00",
      paymentStatus: json["payment_status"] == true || json["payment_status"]?.toString() == "true",
    );
  }
}
