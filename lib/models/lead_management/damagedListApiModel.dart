class DamagedListApiResponse {
  final bool status;
  final String message;
  final List<DamagedReturnItem> data;

  DamagedListApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DamagedListApiResponse.fromJson(Map<String, dynamic> json) {
    return DamagedListApiResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => DamagedReturnItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class DamagedReturnItem {
  final String slNo;
  final String returnId;
  final String customerName;
  final String damagedCount;
  final String products;
  final String totalAmount;
  final Permissions permissions;

  DamagedReturnItem({
    required this.slNo,
    required this.returnId,
    required this.customerName,
    required this.damagedCount,
    required this.products,
    required this.totalAmount,
    required this.permissions,
  });

  factory DamagedReturnItem.fromJson(Map<String, dynamic> json) {
    return DamagedReturnItem(
      slNo: json['sl_no']?.toString() ?? '',
      returnId: json['return_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      damagedCount: json['damaged_count']?.toString() ?? '',
      products: json['products']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '',
      permissions: Permissions.fromJson(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sl_no': slNo,
      'return_id': returnId,
      'customer_name': customerName,
      'damaged_count': damagedCount,
      'products': products,
      'total_amount': totalAmount,
      'permissions': permissions.toJson(),
    };
  }
}

class Permissions {
  final bool view;
  final bool edit;
  final String encodedId;

  Permissions({
    required this.view,
    required this.edit,
    required this.encodedId,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) {
    return Permissions(
      view: json['view']?.toString().toLowerCase() == 'true',
      edit: json['edit']?.toString().toLowerCase() == 'true',
      encodedId: json['encoded_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'view': view.toString(),
      'edit': edit.toString(),
      'encoded_id': encodedId,
    };
  }
}