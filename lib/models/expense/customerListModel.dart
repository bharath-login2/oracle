class CustomerExpenseListModel {
  final bool status;
  final String message;
  final List<CustomerExp> data;

  CustomerExpenseListModel({required this.status, required this.message, required this.data});

  factory CustomerExpenseListModel.fromJson(Map<String, dynamic> json) {
    return CustomerExpenseListModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List).map((e) => CustomerExp.fromJson(e)).toList(),
    );
  }
}

class CustomerExp {
  final String id;
  final String name;

  CustomerExp({required this.id, required this.name});

  factory CustomerExp.fromJson(Map<String, dynamic> json) {
    return CustomerExp(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
