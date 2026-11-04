class FitStageResponse {
  final List<FitStage> data;
  final String message;
  final bool status;

  FitStageResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory FitStageResponse.fromJson(Map<String, dynamic> json) {
    return FitStageResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => FitStage.fromJson(e))
              .toList() ??
          [],
      message: json['message'] ?? '',
      status: json['status'] ?? false,
    );
  }
}

class FitStage {
  final String activityKey;
  final String activityName;

  FitStage({
    required this.activityKey,
    required this.activityName,
  });

  factory FitStage.fromJson(Map<String, dynamic> json) {
    return FitStage(
      activityKey: json['activity_key'] ?? '',
      activityName: json['activity_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_key': activityKey,
      'activity_name': activityName,
    };
  }
}
