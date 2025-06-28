class ProjectListCustModel {
  final bool status;
  final String message;
  final List<ProjectExp> data;

  ProjectListCustModel(
      {required this.status, required this.message, required this.data});

  factory ProjectListCustModel.fromJson(Map<String, dynamic> json) {
    return ProjectListCustModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List).map((e) => ProjectExp.fromJson(e)).toList(),
    );
  }
}

class ProjectExp {
  final String id;
  final String projectName;
   final String customerId;
    final String customerName;
  final String fromDate;
  final String toDate;

  ProjectExp(
      {required this.id,
      required this.projectName,
      required this.customerId,
       required this.customerName,
      required this.fromDate,
      required this.toDate});

  factory ProjectExp.fromJson(Map<String, dynamic> json) {
    return ProjectExp(
      id: json['id'] ?? '',
      projectName: json['project_name'] ?? '',
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
    );
  }
}
