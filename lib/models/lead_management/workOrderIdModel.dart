class CustomerWorkDetailsModel {
  final String? status;
  final String? message;
   List<WorkOrder>? data;

  CustomerWorkDetailsModel({this.status, this.message, this.data});

  factory CustomerWorkDetailsModel.fromJson(Map<String, dynamic> json) {
    return CustomerWorkDetailsModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? List<WorkOrder>.from(
              json['data'].map((x) => WorkOrder.fromJson(x)),
            )
          : [],
    );
  }
}

class WorkOrder {
  final String? workOrderId;

  WorkOrder({this.workOrderId});

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    return WorkOrder(
      workOrderId: json['work_order_id'],
    );
  }
}
