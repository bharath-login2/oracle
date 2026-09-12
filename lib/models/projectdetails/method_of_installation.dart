class MethodActivityItem {
  final String id;
  final String activityKey;
  final String activityName;
  final String methodId;
  final String isDeleted;

  const MethodActivityItem({
    required this.id,
    required this.activityKey,
    required this.activityName,
    required this.methodId,
    required this.isDeleted,
  });

  factory MethodActivityItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return MethodActivityItem(
      id: json['id']?.toString() ?? '',
      activityKey: json['activity_key']?.toString() ?? '',
      activityName: json['activity_name']?.toString() ?? '',
      methodId: json['method_id']?.toString() ?? '',
      isDeleted: json['is_deleted']?.toString() ?? '',
    );
  }
}

class MethodActivityResponse {
  final List<MethodActivityItem> data;
  final String message;
  final bool status;

  const MethodActivityResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory MethodActivityResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return MethodActivityResponse(
      data: (json['data'] as List? ?? [])
          .map(
            (e) => MethodActivityItem.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      message: json['message']?.toString() ?? '',
      status: json['status'] == true,
    );
  }
}
