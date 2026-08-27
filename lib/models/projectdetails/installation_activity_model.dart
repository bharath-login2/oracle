class InstallationActivityResponse {
  final List<ActivityItem> data;

  InstallationActivityResponse({
    required this.data,
  });

  factory InstallationActivityResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> activities = json['data'] ?? [];

    return InstallationActivityResponse(
      data: activities
          .map(
            (item) => ActivityItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class ActivityItem {
  final int? id;
  final String? activity;
  final String? status;
  final dynamic percentageOfCompletion;
  final String? startDate;
  final String? completedDate;

  ActivityItem({
    this.id,
    this.activity,
    this.status,
    this.percentageOfCompletion,
    this.startDate,
    this.completedDate,
  });

  factory ActivityItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ActivityItem(
      id: json['id'],
      activity: json['activity']?.toString(),
      status: json['status']?.toString(),
      percentageOfCompletion:
          json['percentage_of_completion'] ?? json['percentageOfCompletion'],
      startDate:
          json['start_date']?.toString() ?? json['startDate']?.toString(),
      completedDate: json['completed_date']?.toString() ??
          json['completedDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity': activity,
      'status': status,
      'percentage_of_completion': percentageOfCompletion,
      'start_date': startDate,
      'completed_date': completedDate,
    };
  }
}
