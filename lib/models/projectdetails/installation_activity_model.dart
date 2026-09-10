class InstallationActivityResponse {
  final List<ActivityItem> data;
  final String message;
  final bool status;

  InstallationActivityResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory InstallationActivityResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return InstallationActivityResponse(
      data: (json['data'] as List? ?? [])
          .map(
            (e) => ActivityItem.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      message: json['message']?.toString() ?? '',
      status: json['status'] == true,
    );
  }
}

class ActivityItem {
  final String id;
  final String activityKey;
  final String status;
  final String percentage;
  final String startDate;
  final String completedDate;
  final String activityName;

  ActivityItem({
    required this.id,
    required this.activityKey,
    required this.status,
    required this.percentage,
    required this.startDate,
    required this.completedDate,
    required this.activityName,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id']?.toString() ?? '',

      // THIS IS DYNAMIC
      activityKey: json['activity_key']?.toString() ?? '',

      status: json['status']?.toString() ?? '',
      percentage: json['percentage']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      completedDate: json['completed_date']?.toString() ?? '',
      activityName: json['activity_name']?.toString() ?? '',
    );
  }
}
